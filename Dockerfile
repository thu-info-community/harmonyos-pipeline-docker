# syntax=docker/dockerfile:1.7
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl zstd zip unzip python3 openjdk-21-jdk \
    build-essential git \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV HARMONY_TOOLS_HOME=/opt/harmonyos-tools/command-line-tools
ENV DEVECO_SDK_HOME=${HARMONY_TOOLS_HOME}/sdk
ENV OHOS_BASE_SDK_HOME=${DEVECO_SDK_HOME}/default/openharmony
ENV DEVECO_NODE_HOME=${HARMONY_TOOLS_HOME}/tool/node
ENV NODE_HOME=${DEVECO_NODE_HOME}
ENV PATH=${JAVA_HOME}/bin:${NODE_HOME}/bin:${HARMONY_TOOLS_HOME}/bin:${OHOS_BASE_SDK_HOME}/toolchains:${PATH}

# Bind the official archive during extraction so it is not retained in an image layer.
RUN --mount=type=bind,source=commandline-tools-linux-x64-26.0.0.821.zip,target=/tmp/clt.zip \
    echo '58da7359019e9360a8bb82da0cd1d3b3b26fedc338379f257849f2162e3ac1fc  /tmp/clt.zip' | sha256sum -c - \
    && mkdir -p /opt/harmonyos-tools \
    && unzip -q /tmp/clt.zip -d /opt/harmonyos-tools \
    && chmod +x ${HARMONY_TOOLS_HOME}/bin/* \
    && printf '%s\n' '@ohos:registry=https://repo.harmonyos.com/npm/' > /root/.npmrc

RUN node -e "const fs=require('node:fs'); const root=process.env.HARMONY_TOOLS_HOME; for(const variant of ['openharmony','hms']) { for(const component of ['ets','js','native','toolchains']) { const file=variant==='openharmony'?'oh-uni-package.json':'uni-package.json'; const meta=JSON.parse(fs.readFileSync(root+'/sdk/default/'+variant+'/'+component+'/'+file)); if(Number(meta.apiVersion)!==26 || meta.releaseType!=='Release') throw new Error('Expected release API 26 SDK'); }} for(const pkg of ['hvigor','hvigor-ohos-plugin']) { const meta=JSON.parse(fs.readFileSync(root+'/hvigor/'+pkg+'/package.json')); if(meta.version!=='6.26.4') throw new Error('Expected Hvigor 6.26.4'); }" \
    && java -version && node --version && ohpm --version

WORKDIR /workspace
CMD ["bash"]
