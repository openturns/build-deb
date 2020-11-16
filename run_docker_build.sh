#!/bin/sh

set -xe

usage()
{
  echo "Usage: $0 [uid] [gid]"
  exit 1
}

parent_dir=`readlink -f $0`
parent_dir=`dirname $parent_dir`

triplets="ubuntu:xenial:xUbuntu_16.04 ubuntu:bionic:xUbuntu_18.04 ubuntu:focal:xUbuntu_20.04 ubuntu:groovy:xUbuntu_20.10 debian:stretch:Debian_9.0 debian:buster:Debian_10"
cd /tmp
for triplet in ${triplets}
do
  distro=`echo "${triplet}" | cut -d ":" -f 1`
  code=`echo "${triplet}" | cut -d ":" -f 2`
  tag=`echo "${triplet}" | cut -d ":" -f 3`
  wget --no-check-certificate --recursive --no-parent -A.deb -R "*dbgsym*" -P input/${distro}/${code} --no-directories https://download.opensuse.org/repositories/science:/openturns/${tag}/amd64/
  tree input/${distro}/${code}/
  for debfile in `find input/${distro}/${code}/ -name "*.deb"`
  do
    ${parent_dir}/convert-deb.sh $PWD/${debfile} ${code} $PWD/output/${distro}/${code}
  done
done

cp -rv /io/debian /io/ubuntu .
gpg --import /io/private.key
gpg --list-keys
cd /tmp
for triplet in ${triplets}
do
  distro=`echo "${triplet}" | cut -d ":" -f 1`
  code=`echo "${triplet}" | cut -d ":" -f 2`
  tree output/${distro}
  for debfile in `find output/${distro}/${code} -name "*.deb"`
  do
    reprepro --basedir ${distro} includedeb ${code} ${debfile}
  done
done

uid=$1
gid=$2
if test -n "${uid}" -a -n "${gid}"
then
  for distro in ubuntu debian
  do
    cp -rv ${distro}/* /io/${distro}
    chown ${uid}:${gid} /io/${distro}
  done
fi
