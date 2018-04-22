FROM debian:buster-slim

RUN apt-get update && apt-get install -y curl libcurl3 build-essential zlib1g-dev libssl-dev \
 && curl -fsS -o /tmp/install.sh https://dlang.org/install.sh \
 && bash /tmp/install.sh -p /dlang install dmd \
 && bash /tmp/install.sh -p /dlang install ldc \
 && rm /tmp/install.sh \
 && apt-get auto-remove -y curl build-essential \
 && apt-get install -y gcc cmake \
 && rm -rf /var/cache/apt /dlang/${COMPILER}-*/lib32 /dlang/dub-1.0.0/dub.tar.gz

ENV PATH=/dlang/${COMPILER}-${COMPILER_VERSION}/bin:${PATH} \
    LD_LIBRARY_PATH=/dlang/${COMPILER}-${COMPILER_VERSION}/lib \
    LIBRARY_PATH=/dlang/${COMPILER}-${COMPILER_VERSION}/lib

WORKDIR /src

COPY . .

RUN dub build --compiler=dmd
RUN dub build --compiler=ldc2

CMD ["dub", "test"]
