# Dockerfile for SETSM image
ARG VERSION=latest
ARG COMPILER=intel
FROM ubuntu:$VERSION as builder

ARG COMPILER
ARG VERSION

RUN apt-get update && apt-get install --no-install-recommends -y \
    libgeotiff-dev \
    libgeotiff[0-9]+ \
    g++ \
    git \
    ca-certificates \
    make \
    wget \
    gnupg2 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN echo clear cache
SHELL ["/bin/bash", "-c"]
# If building Intel version, then install Intel compiler
RUN if [ "$COMPILER" = 'intel' ]; then \
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB; \
apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB; \
rm GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB; \
echo "deb https://apt.repos.intel.com/oneapi all main" | tee /etc/apt/sources.list.d/oneAPI.list; \
apt update; \
apt-get install -y intel-oneapi-compiler-dpcpp-cpp-and-cpp-classic; \
source /opt/intel/oneapi/setvars.sh; \
echo $PATH; \
icpc -V; \
echo **DONE**; \
fi

WORKDIR /opt

COPY ./* /opt/

ENV PATH="/opt:${PATH}"
RUN echo $PATH
ENV COMPILER=$COMPILER
RUN ["/bin/bash", "-c", "make COMPILER=$COMPILER INCS=-I/usr/include/geotiff"]

FROM ubuntu:$VERSION as runner

RUN apt-get update && apt-get install --no-install-recommends -y \
        libgeotiff[0-9]+ \
        libgomp1 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir /opt/setsmdir
COPY --from=builder /opt/setsm /opt/setsmdir/
ENV PATH="/opt/setsmdir:${PATH}"

CMD setsm