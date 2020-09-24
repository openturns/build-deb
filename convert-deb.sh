#!/bin/bash

# add dist name to the version, cause reprepro (the .deb mirror mananger) do
# not want to add the same package for 2 different codename of the same linux distrib (e.g ubuntu 12.04 and 13.04).

set -xe

if [ $# -lt 1 ]; then
  echo "usage: $0 package.deb code outdir"
  echo "exiting"
  exit 1
fi

DEB=$1
code=$2
outdir=$3
DEB2=`basename ${DEB}|sed "s|1_amd64|1${code}_amd64|g"`

# temporary dir
TMPDIR=$(mktemp -d /tmp/deb.XXXXXX)
if test "$?" != "0"
then
  echo "mktemp failed. Exiting."
  exit 1
fi
WORKDIR=$TMPDIR/workdir
mkdir -p $WORKDIR && cd $WORKDIR

# extract deb
ar xv $DEB
rm debian-binary

# extract control
WORKDIR2=$TMPDIR/workdir2
mkdir -p $WORKDIR2
if test -f control.tar.xz
then
  tar xJf control.tar.xz -C $WORKDIR2
else
  # old format
  tar xzf control.tar.gz -C $WORKDIR2
fi
rm control.tar.*

# extract data
tar xJf data.tar.xz
rm data.tar.xz

# new control
mkdir DEBIAN
cp $WORKDIR2/control DEBIAN
cat DEBIAN/control
sed -i -e "s/^\(Version: .*\)$/\1${code}/" DEBIAN/control

# rebuild deb
tree $WORKDIR
mkdir -p ${outdir}
dpkg-deb -b $WORKDIR ${outdir}/$DEB2

rm -rf $TMPDIR
