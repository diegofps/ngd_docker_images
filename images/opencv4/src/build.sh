#!/bin/bash

git clone --recursive https://github.com/opencv/opencv.git

cd opencv
git reset --hard 4.2.0

rm -rf build && mkdir build && cd build

# For a basic build
# cmake .. -DOPENCV_GENERATE_PKGCONFIG=ON -DCMAKE_BUILD_TYPE=RELEASE -DWITH_OPENGL=ON -DCMAKE_INSTALL_PREFIX=/usr/local
 
# If you want the qt interface and a few more optimizations use
#sudo apt install qtbase5-dev -yq
#cmake .. -DOPENCV_GENERATE_PKGCONFIG=ON -DCMAKE_BUILD_TYPE=RELEASE -DWITH_OPENGL=ON -DCMAKE_INSTALL_PREFIX=/usr/local -DWITH_QT=ON -DWITH_OPENMP=ON -DWITH_OPENCL=ON -DOPENCV_FORCE_3RDPARTY_BUILD=ON -DOPENCV_ENABLE_NONFREE=ON

cmake .. \
    -DOPENCV_GENERATE_PKGCONFIG=ON \
    -DCMAKE_BUILD_TYPE=RELEASE \
    -DWITH_OPENGL=ON \
    -DCMAKE_INSTALL_PREFIX=/usr/local \
    -DWITH_QT=OFF \
    -DWITH_OPENMP=ON \
    -DWITH_OPENCL=ON \
    -DOPENCV_FORCE_3RDPARTY_BUILD=ON \
    -DOPENCV_ENABLE_NONFREE=ON

# Build and install
make -j `nproc`
make install
 
cp ./unix-install/opencv4.pc /usr/share/pkgconfig/opencv.pc

rm -rf /src/opencv

