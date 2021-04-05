# Dockerfile for SETSM image
ARG VERSION=latest
ARG COMPILER=gnu
FROM ubuntu:$VERSION as builder

RUN apt-get update && apt-get install --no-install-recommends -y \
    libgeotiff-dev \
    libgeotiff[0-9]+ \
    g++ \
    git \
    ca-certificates \
    make \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /opt

COPY ./* /opt/
ENV PATH="/opt:${PATH}"
RUN ["make", "COMPILER=$COMPILER", "INCS=-I/usr/include/geotiff"]

FROM ubuntu:$VERSION as runner

RUN apt-get update && apt-get install --no-install-recommends -y \
        libgeotiff[0-9]+ \
        libgomp1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/setsmdir
COPY --from=builder /opt/setsm /opt/setsmdir/
ENV PATH="/opt/setsmdir:${PATH}"

CMD setsm