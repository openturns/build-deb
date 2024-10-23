
FROM ubuntu:jammy
RUN apt-get -y update && apt-get -y install sudo binutils curl gnupg rng-tools reprepro wget tree xz-utils
