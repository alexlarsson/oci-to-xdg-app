#!/bin/sh

docker build -t hello-world .
ID=`docker run -d hello-world true`
rm -rf rootfs
mkdir rootfs
docker export $ID | tar -C rootfs -xvf -
chmod -R a+r rootfs
