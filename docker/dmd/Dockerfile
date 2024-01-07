FROM debian:bookworm-slim

ARG COMPILER=dmd
ARG COMPILER_VERSION=2.106.1

RUN apt-get update && apt-get install -y curl libcurl4 build-essential zlib1g-dev libssl-dev \
 && curl -fsS -o /tmp/install.sh https://dlang.org/install.sh

RUN bash /tmp/install.sh -p /dlang install "${COMPILER}-${COMPILER_VERSION}" \
 && rm /tmp/install.sh \
 && apt-get auto-remove -y curl build-essential \
 && apt-get install -y gcc cmake \
 && rm -rf /var/cache/apt /dlang/${COMPILER}-*/lib32 /dlang/dub-1.0.0/dub.tar.gz

ENV PATH=/dlang/${COMPILER}-${COMPILER_VERSION}/linux/bin64:${PATH} \
    LD_LIBRARY_PATH=/dlang/${COMPILER}-${COMPILER_VERSION}/linux/lib64 \
    LIBRARY_PATH=/dlang/${COMPILER}-${COMPILER_VERSION}/linux/lib64

WORKDIR /src

COPY . .

#RUN dub build --compiler=dmd