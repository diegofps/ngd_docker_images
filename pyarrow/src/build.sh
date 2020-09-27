#!/bin/bash

# Arrow C++

git clone --recursive https://github.com/apache/arrow.git

cd /src/arrow
git checkout maint-0.15.x

mkdir -p /src/arrow/cpp/build
cd /src/arrow/cpp/build

cmake .. \
      -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
      -DCMAKE_INSTALL_LIBDIR=lib  \
      -DARROW_FLIGHT=ON \
      -DARROW_GANDIVA=ON  \
      -DARROW_ORC=ON  \
      -DARROW_WITH_BZ2=ON \
      -DARROW_WITH_ZLIB=ON  \
      -DARROW_WITH_ZSTD=ON  \
      -DARROW_WITH_LZ4=ON \
      -DARROW_WITH_SNAPPY=ON  \
      -DARROW_WITH_BROTLI=ON  \
      -DARROW_PARQUET=ON  \
      -DARROW_PYTHON=ON \
      -DARROW_PLASMA=ON \
      -DARROW_CUDA=OFF \
      -DARROW_BUILD_TESTS=OFF \
      -DARROW_BUILD_EXAMPLES=ON \
      -DARROW_BUILD_BENCHMARKS=ON \
      -DARROW_BUILD_BENCHMARKS_REFERENCE=ON \
      -DARROW_BUILD_UTILITIES=ON \
      -DPARQUET_BUILD_EXECUTABLES=ON \
      -DPARQUET_BUILD_EXAMPLES=ON \
      -DPYTHON_EXECUTABLE=/usr/bin/python3

make -j `nproc`
make install

# PYARROW

mkdir -p /src/arrow/python
cd /src/arrow/python

pip3 install -r requirements.txt 

ln -s /usr/local/lib/libparquet.so /usr/local/lib/libparquet_shared.so

python3 setup.py build_ext --inplace
python3 setup.py sdist
pip3 install dist/pyarrow-0.15.1.dev36*.tar.gz

rm -rf /src/arrow
