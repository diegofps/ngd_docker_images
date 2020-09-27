FROM diegofpsouza/pandas:0.0.1

ENV ARROW_HOME="/usr/local"
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PYARROW_WITH_FLIGHT=1
ENV PYARROW_WITH_GANDIVA=1
ENV PYARROW_WITH_ORC=1
#ENV PYARROW_WITH_CUDA=1
ENV PYARROW_WITH_PARQUET=1
ENV PYARROW_WITH_PLASMA=1
ENV PARQUET_HOME="/usr/local"

RUN apt install build-essential git cmake ninja-build libboost-all-dev flex bison clang \
    liblz4-dev libzstd-dev rapidjson-dev zstd lbzip2 bzip2 libc-ares-dev libc-ares2 libgrpc-dev libgrpc3 \
    libre2-dev llvm-7-dev libssl-dev libgtest-dev liburiparser-dev \
    libbrotli-dev protobuf-compiler protobuf-c-compiler \
    python3 python3-pip -yq

RUN pip3 install cython pytest psutil lz4 re2 six setuptools wheel twine

WORKDIR /src

COPY src .

RUN /src/build.sh && rm -rf /src

WORKDIR /
