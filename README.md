# Copacetic Action

[Marketplace](https://github.com/marketplace/actions/copacetic-action)

This action patches vulnerable containers using [Copa](https://github.com/project-copacetic/copacetic).
Copacetic Action is supported with Copa version 0.3.0 and later.

## Inputs

| Name               | Type   | Required | Default  | Description                                           |
| ------------------ | ------ | -------- | -------- | ----------------------------------------------------- |
| `image`            | String | True     |          | Image reference to patch                              |
| `image-report`     | String | True     |          | Trivy JSON vulnerability report of the image to patch |
| `patched-tag`      | String | True     |          | Patched image tag                                     |
| `timeout`          | String | False    | `5m`     | Timeout for `copa patch`                              |
| `buildkit-version` | String | False    | `latest` | Buildkit version                                      |
| `copa-version`     | String | False    | `latest` | Copa version                                          |

## Outputs

| Name            | Type   | Description                          |
| --------------- | ------ | ------------------------------------ |
| `patched-image` | String | Image reference of the patched image |

## Example usage

https://github.com/sozercan/copa-action/blob/1318614969da67670fc36a7be0f55c4d5c3f1de8/.github/workflows/patch.yaml#L1-L64
