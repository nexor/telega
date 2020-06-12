FROM dlang2/dmd-ubuntu

WORKDIR /dlang/app

RUN apt-get update && apt-get install -y jq

COPY dub.* ./

RUN dub describe | jq '.["packages"][0]["dependencies"]|.[]' | xargs -I{} dub -v fetch {}
