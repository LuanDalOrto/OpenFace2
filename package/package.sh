#!/usr/bin/env bash
##
## Copyright (C) 2020 Hanson Robotics - All Rights Reserved
##
## For development please contact <dev@hansonrobotics.com>
##
##

package() {
    local reponame=openface2

    mkdir -p $BASEDIR/src
    rsync -r --delete \
        --exclude ".git" \
        --exclude "package" \
        $BASEDIR/../ $BASEDIR/src/$reponame

    local install_dir=/usr/local
    get_version $1

	pushd $BASEDIR/src/$reponame >/dev/null
        mkdir -p build
        cd build
        cmake -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_INSTALL_PREFIX=$install_dir -D CMAKE_CXX_FLAGS="-std=c++11" -D CMAKE_EXE_LINKER_FLAGS="-std=c++11" ..
        make -j8
        make install
	popd >/dev/null

    local name=head-openface2
    local desc="OpenFace 2.2.0: a facial behavior analysis toolkit"
    local url="https://api.github.com/repos/hansonrobotics/$reponame/releases"

    fpm -s dir -t deb -n "${name}" -v "${version#v}" --vendor "${VENDOR}" \
        --url "${url}" --description "${desc}" ${ms} \
        --deb-no-default-config-files \
        -p $BASEDIR/${name}_VERSION_ARCH.deb \
        -d "libopenblas-dev" \
        $install_dir/bin/FaceLandmarkImg=${install_prefix}/bin/ \
        $install_dir/bin/FaceLandmarkVid=${install_prefix}/bin/ \
        $install_dir/bin/FaceLandmarkVidMulti=${install_prefix}/bin/ \
        $install_dir/bin/FeatureExtraction=${install_prefix}/bin/ \
        $install_dir/etc/OpenFace=${install_prefix}/etc/ \
        $install_dir/include/OpenFace=${install_prefix}/include/ \
        $install_dir/lib/cmake/OpenFace=${install_prefix}/lib/cmake/ \
        $install_dir/lib/libFaceAnalyser.a=${install_prefix}/lib/ \
        $install_dir/lib/libGazeAnalyser.a=${install_prefix}/lib/ \
        $install_dir/lib/libLandmarkDetector.a=${install_prefix}/lib/ \
        $install_dir/lib/libUtilities.a=${install_prefix}/lib/

    rm -r $BASEDIR/src
}

if [[ $(readlink -f ${BASH_SOURCE[0]}) == $(readlink -f $0) ]]; then
    BASEDIR=$(dirname $(readlink -f ${BASH_SOURCE[0]}))
    source $BASEDIR/common.sh
    set -e

    package
fi
