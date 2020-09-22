#!/bin/sh

set -xe

usage()
{
  echo "Usage: $0 VERSION [uid] [gid]"
  exit 1
}

test $# -ge 1 || usage

VERSION=$1

gpg --import /io/private.key
gpg --list-keys

cd /tmp
cp -rv /io/debian /io/ubuntu .
for triplet in ubuntu:xenial:xUbuntu_16.04
#ubuntu:bionic:xUbuntu_18.04 ubuntu:focal:xUbuntu_20.04
do
  distro=`echo "${triplet}" | cut -d ":" -f 1`
  code=`echo "${triplet}" | cut -d ":" -f 2`
  tag=`echo "${triplet}" | cut -d ":" -f 3`
  wget --no-check-certificate --recursive --no-parent -A.deb -P deb/${distro}/${code} --no-directories https://download.opensuse.org/repositories/science:/openturns/${tag}/amd64/
  tree deb/${distro}/${code}/
  for debfile in `find deb/${distro}/${code}/ -name "*.deb"`
  do
    reprepro --basedir ${distro} includedeb ${code} ${debfile}
  done
  tree ${distro}
done

uid=$2
gid=$3
if test -n "${uid}" -a -n "${gid}"
then
  for distro in ubuntu
  do
    cp -rv ${distro}/* /io/${distro}
    chown ${uid}:${gid} /io/${distro}
  done
fi
