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
OT_VERSION="1.24-1"
OT_MODVERSION="$OT_VERSION$code"
sed -i -e "s/$OT_VERSION/$OT_MODVERSION/" DEBIAN/control

if ! grep -q "Version: $OT_MODVERSION" DEBIAN/control
then
  sed -i -e "s/^\(Version: .*\)$/\1$code/" DEBIAN/control
fi

# modify cuba control
if grep -q "cuba" <<< "$DEB"
then
  CUBA_VERSION="4.2.2-1"
  sed -i -e "s/= ${CUBA_VERSION}/= ${CUBA_VERSION}${code}/" DEBIAN/control
fi

# modify pagmo control
if grep -q "pagmo" <<< "$DEB"
then
  PAGMO_VERSION="2.19.1-1"
  sed -i -e "s/= ${PAGMO_VERSION}/= ${PAGMO_VERSION}${code}/" DEBIAN/control
fi

# modify mixmod control
if grep -q "mixmod" <<< "$DEB"
then
  MIXMOD_VERSION="2.1.11-1"
  sed -i -e "s/= ${MIXMOD_VERSION}/= ${MIXMOD_VERSION}${code}/" DEBIAN/control
fi

cat DEBIAN/control

# rebuild deb
# tree $WORKDIR
mkdir -p ${outdir}
dpkg-deb -b $WORKDIR ${outdir}/$DEB2

rm -rf $TMPDIR
