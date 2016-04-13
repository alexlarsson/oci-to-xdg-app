#!/bin/sh

if [ `id -u` == 0 ]; then
    echo "Don't run this as root"
fi
xdg-app --user remote-add --no-gpg-verify test-oci repo
xdg-app --user install test-oci org.hello.Platform
xdg-app --user install test-oci org.hello.App

xdg-app --user update org.hello.Platform
xdg-app --user update org.hello.App

echo Running app:
xdg-app run org.hello.App
