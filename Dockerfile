FROM hashicorp/packer

ENV ANSIBLE_VERSION 2.10
ENV PYTHONUNBUFFERED 1 

# Configure virtual deps
RUN set -euxo pipefail \
&&  sed -i 's/http\:\/\/dl-cdn.alpinelinux.org/https\:\/\/alpine.global.ssl.fastly.net/g' /etc/apk/repositories \
&&  apk add --no-cache --update --virtual .build-deps g++ \
                                                      python3-dev \
                                                      build-base \
                                                      libffi-dev \
                                                      openssl-dev
# Configure python3
RUN apk add --no-cache --update python3 \
                                ca-certificates \
                                openssh-client \
                                sshpass \
                                dumb-init \
                                su-exec \
&&  python3 -m ensurepip \
&&  rm -r /usr/lib/python*/ensurepip \
&&  pip3 install --no-cache --upgrade pip \
                                      setuptools \
                                      wheel \
&&  rm -f /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python \
&&  rm -f /usr/bin/pip && ln -s pip3 /usr/bin/pip

# Install ansible 
RUN pip3 install --no-cache ansible==${ANSIBLE_VERSION}

# Remove useless packeages and cache
RUN apk del --no-cache --purge .build-deps \
&&  rm -rf /var/cache/apk/* \
&&  rm -rf /root/.cache 

ENTRYPOINT ["/bin/sh", "-c"]
