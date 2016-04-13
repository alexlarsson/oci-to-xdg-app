#!/bin/sh

ROOTFS=`python -c 'import sys, json; print json.load(open("config.json"))["root"]["path"]'`
EXEC=`python -c 'import sys, json, pipes; print " ".join(pipes.quote(arg) for arg in json.load(open("config.json"))["process"]["args"])'`

if [ `id -u` == 0 ]; then
    echo "Don't run this as root"
    exit 1
fi

ostree init --repo=repo --mode=archive-z2 &> /dev/null || true

rm -rf platform
mkdir -p platform/files

cp metadata.runtime platform/metadata
cp -ra $ROOTFS/usr/* platform/files
cp -ra $ROOTFS/etc platform/files

ostree commit --repo=repo -s "commit runtime" --owner-uid=0 --owner-gid=0 --generate-sizes --no-xattrs --branch=runtime/org.hello.Platform/x86_64/master platform

rm -rf app
mkdir -p app/files

sed "s|@@COMMAND@@|$EXEC|" metadata.app > app/metadata
cp -ra $ROOTFS/app/* app/files

ostree commit --repo=repo -s "commit app" --owner-uid=0 --owner-gid=0 --generate-sizes --no-xattrs --branch=app/org.hello.App/x86_64/master app
ostree summary -u --repo=repo
