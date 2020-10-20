#!/usr/bin/env sh


# Get the source
git clone --recursive https://github.com/openalpr/openalpr.git


# Build the native source
mkdir -p /src/openalpr/src/build

cd /src/openalpr/src/build
ls ../../..
cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc ..

make -j `nproc`
make install

echo -e '\nbase @@@#@##\nbase @@@####' >> /usr/share/openalpr/runtime_data/postprocess/br.patterns


# Install Python3 module
apt purge libopenalpr
rm -rf /usr/local/lib/python3.5/dist-packages/openalpr*

cd /src/openalpr/src/bindings/python/
python3 setup.py install


# Cleanup
rm -rf /src/openalpr
