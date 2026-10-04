# HarmonyOS API 26 CI image

This image contains the official Linux Command Line Tools 26.0.0.851 archive, release SDK 26.0.0.105, Hvigor 6.26.8, its bundled Node.js, and JDK 21. It uses the SDK's original layout and checks its API and release metadata during the build.

The versioned image path is:

```text
ghcr.io/thu-info-community/harmonyos-pipeline-docker/harmonyos-ci-image:26.0.0.851
```

The tag becomes available after publishing. It is not an existing upstream tag.

## Build locally

Download the official Linux archive from the [Huawei download center](https://developer.huawei.com/consumer/cn/download/command-line-tools-for-hmos) and put `commandline-tools-linux-x64-26.0.0.851.zip` in this directory. ZIP files are excluded from Git. The Dockerfile verifies SHA256 `ab604bd92721d5cbcafd154e6461d46b9f1b105e7b89eab04a9d046681198082` before extraction; the archive is mounted during extraction and is not retained in an image layer.

```sh
docker build -t ghcr.io/thu-info-community/harmonyos-pipeline-docker/harmonyos-ci-image:26.0.0.851 .
docker run --rm ghcr.io/thu-info-community/harmonyos-pipeline-docker/harmonyos-ci-image:26.0.0.851 bash -c 'node --version && java -version && ohpm --version'
```

## Publish with GitHub Actions

Set the repository secret `HARMONY_CLT_URL` to a download URL for the same official archive. The workflow does not print the URL and verifies the fixed checksum. Run **Docker Build and Publish** manually, or push the `26.0.0.851` Git tag. The job builds and validates the image before publishing that version to GHCR; it does not overwrite `latest`.

Set the GHCR package visibility to Internal for organization access. Under Manage Actions access, grant `thu-info-community/thu-info-app` read access; the application workflow authenticates with its `GITHUB_TOKEN` and `packages: read` permission. The application CI uses the path above by default; the repository variable `HARMONY_CI_IMAGE` can override the full image reference, including a digest.

## Tool locations

The tools are installed in `/opt/harmonyos-tools/command-line-tools`. `DEVECO_SDK_HOME` points to its `sdk` directory, and `OHOS_BASE_SDK_HOME` points to `sdk/default/openharmony`. `bin/hvigorw` uses the bundled Hvigor release. Applications should configure their `@ohos` npm scope for `https://repo.harmonyos.com/npm/` when using an external Node installation.
