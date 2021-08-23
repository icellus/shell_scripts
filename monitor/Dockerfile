FROM python:buster

ARG CHANGE_SOURCE=true
RUN if [ ${CHANGE_SOURCE} = true ]; then \
    # Change application source from deb.debian.org to aliyun source
#    sed -i 's/deb.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
#    sed -i 's/security.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list && \
#    sed -i 's/security-cdn.debian.org/mirrors.tuna.tsinghua.edu.cn/' /etc/apt/sources.list \
    sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.ustc.edu.cn/' /etc/apt/sources.list && \
    sed -i 's/security-cdn.debian.org/mirrors.ustc.edu.cn/' /etc/apt/sources.list \
;fi

RUN set -eux; \
    apt-get update; \
    apt-get install -yq --no-install-recommends \
            libgl1-mesa-glx \
            unzip \
            curl \
            chromium \
            bash \
            lrzsz \
            vim;
