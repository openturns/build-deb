#!/bin/sh

set -xe

usage()
{
  echo "Usage: $0 VERSION [uid] [gid]"
  exit 1
}

test $# -ge 1 || usage

VERSION=$1

cd /tmp
cp -rv /io/debian /io/ubuntu .
for triplet in ubuntu:xenial:xUbuntu_16.04 ubuntu:bionic:xUbuntu_18.04 ubuntu:focal:xUbuntu_20.04
do
  distro=`echo "${triplet}" | cut -d ":" -f 1`
  code=`echo "${triplet}" | cut -d ":" -f 2`
  tag=`echo "${triplet}" | cut -d ":" -f 3`
  wget --no-check-certificate --recursive --no-parent -A.deb -P deb/${distro}/${code} --no-directories https://download.opensuse.org/repositories/science:/openturns/${tag}/amd64/
  for debfile in `ls deb/${distro}/${code}`
  do
    echo "deb=${debfile}"
    reprepro --basedir ${distro} includedeb ${code} deb/${distro}/${code}/${debfile}
  done
done

if test -n "${uid}" -a -n "${gid}"
then
  sudo rm -rf /io/ubuntu /io/debian
  sudo cp -rv ubuntu debian /io
  sudo chown ${uid}:${gid} /io/ubuntu /io/debian
fi
