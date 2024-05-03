#!/bin/sh

set -xe

usage()
{
  echo "Usage: $0 [uid] [gid]"
  exit 1
}

parent_dir=`readlink -f $0`
parent_dir=`dirname $parent_dir`

triplets="ubuntu:noble:xUbuntu_24.04 ubuntu:jammy:xUbuntu_22.04 debian:bullseye:Debian_11 debian:bookworm:Debian_12"
cd /tmp
for triplet in ${triplets}
do
  distro=`echo "${triplet}" | cut -d ":" -f 1`
  code=`echo "${triplet}" | cut -d ":" -f 2`
  tag=`echo "${triplet}" | cut -d ":" -f 3`
  wget --no-check-certificate --recursive --no-parent -A.deb -R "*dbgsym*" -P input/${distro}/${code} --no-directories https://download.opensuse.org/repositories/science:/openturns/${tag}/all/
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

# sudo apt-get -y install liblapack-dev python3-numpy python3-six python3-pandas python3-pydot libceres-dev coinor-libipopt-dev libcminpack-dev libdlib-dev libnlopt-cxx-dev libhdf5-dev libmpc-dev libmpfr-dev libmuparser-dev libprimesieve-dev libtbb-dev libeigen3-dev libboost-serialization-dev libfftw3-dev && sudo dpkg -i output/ubuntu/focal/*.deb && exit 0

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
