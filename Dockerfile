
FROM debian:stretch

RUN apt-get -y update
RUN echo "Europe/Dublin" > /etc/timezone
RUN apt-get install tzdata
RUN dpkg-reconfigure -f noninteractive tzdata
RUN apt-get -y install sudo curl gnupg rng-tools reprepro wget tree
RUN gpg --no-tty --batch --full-generate-key
