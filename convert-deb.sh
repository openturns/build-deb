#!/bin/bash

# add dist name to the version, cause reprepro (the .deb mirror mananger) do
# not want to add the same package for 2 different codename of the same linux distrib (e.g ubuntu 18.04 and 20.04).

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
dpkg -e $DEB
dpkg -x $DEB .

# modify ot version
OT_VERSION="1.15-1"
OT_MODVERSION="$OT_VERSION$code"
sed -i -e "s/$OT_VERSION/$OT_MODVERSION/" DEBIAN/control

if ! grep -q "Version: $OT_MODVERSION" DEBIAN/control
then
  sed -i -e "s/^\(Version: .*\)$/\1$code/" DEBIAN/control
fi

# modify hmat control
if grep -q "hmat-oss" <<< "$DEB"
then
  HMAT_VERSION="1.6.1-1"
  HMAT_MODVERSION="${HMAT_VERSION}${code}"
  sed -i -e "s/= $HMAT_VERSION/= $HMAT_MODVERSION/" DEBIAN/control
fi

# modify nlopt control
if grep -q "nlopt" <<< "$DEB"
then
  NLOPT_VERSION="2.4.2+dfsg-1~bpo70+1"
  NLOPT_MODVERSION="${NLOPT_VERSION}${code}"
  sed -i -e "s/= $NLOPT_VERSION/= $NLOPT_MODVERSION/" DEBIAN/control
fi

cat DEBIAN/control

# rebuild deb
# tree $WORKDIR
mkdir -p ${outdir}
dpkg-deb -b $WORKDIR ${outdir}/$DEB2

rm -rf $TMPDIR
