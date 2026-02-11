FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gcc \
    make \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/Baron-von-Riedesel/JWasm.git /tmp/jwasm \
    && cd /tmp/jwasm \
    && make -f GccUnix.mak \
    && cp build/GccUnixR/jwasm /usr/local/bin/ \
    && rm -rf /tmp/jwasm

RUN apt-get update && apt-get install -y \
    mingw-w64 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
CMD ["/bin/bash"]