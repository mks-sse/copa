#!/bin/sh

set -ex;

image=$1
report=$2
patched_tag=$3
timeout=$4
connection_format=$5
format=$6
output_file=$7
retry_on_timeout=$8
max_retries=$9

# parse image into image name
image_no_tag=$(echo "$image" | cut -d':' -f1)

# check if output_file has been set
if [ -z "$output_file" ]
then
    output=""
else
    output="--format $format --output ./data/$output_file"
fi

# check selected method of buildkit connection
case "$connection_format" in
    # through a buildx instance
    "buildx")
        docker buildx create --name=copa-action
        docker buildx use --default copa-action
        connection="--addr buildx://copa-action"
    ;;
    # through a running buildkit container over tcp
    "buildkit-container")
        connection="--addr tcp://127.0.0.1:8888"
    ;;
    # through the default docker buildkit endpoint enabled with a custom socket
    "custom-socket")
        connection=""
    ;;
esac

# run copa to patch image
OUTPUT_MESSAGE=$(copa patch -i "$image" -r ./data/"$report" -t "$patched_tag" $connection --timeout $timeout $output)
if [ $? -eq 0 ]
then
    patched_image="$image_no_tag:$patched_tag"
    echo "patched-image=$patched_image" >> "$GITHUB_OUTPUT"
elif echo "$OUTPUT_MESSAGE" | grep -q "exceeded timeout"
then
    if [ "$retry_on_timeout" = "false" ]
    then
        echo "Error patching image $image with copa"
        exit 1
    else
        retries=0
        while [ $retries -lt $max_retries ]
        do
            if copa patch -i "$image" -r ./data/"$report" -t "$patched_tag" $connection --timeout $timeout $output;
            then
                patched_image="$image_no_tag:$patched_tag"
                echo "patched-image=$patched_image" >> "$GITHUB_OUTPUT"
                break
            else
                retries=$((retries + 1))
            fi
        done
    fi
else
    echo "Error patching image $image with copa"
    exit 1
fi
