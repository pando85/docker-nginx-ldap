#!/bin/bash

set -e

realpath() { python -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$1"; }

WORKDIR=$(dirname $(realpath $0))
IMAGE_NAME="pando85/nginx-ldap"

build_and_push() {
    docker build . -t $1
    docker build . -f Dockerfile.min -t $1-min
    docker push $1
    docker push $1-min
}

create_images() {
    base_dir=${WORKDIR}/../$1/alpine
    cd $base_dir
    version=$(cat ${base_dir}/Dockerfile | grep "ENV NGINX_VERSION" | cut -d' ' -f3)
    build_and_push $IMAGE_NAME:$version
    build_and_push $IMAGE_NAME:$1

    if [ $1 == 'stable' ];then
        build_and_push $IMAGE_NAME:latest
    fi
}

if [ -z "${DOCKERHUB_USERNAME}" ] && [ -z "${DOCKERHUB_PASSWORD}" ]; then
    echo "DOCKERHUB_USERNAME or DOCKERHUB_PASSWORD is not set."
    exit 1
fi

docker login -u $DOCKERHUB_USERNAME -p $DOCKERHUB_PASSWORD
create_images stable
create_images mainline
