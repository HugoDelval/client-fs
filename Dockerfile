FROM debian:jessie

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y wget

##################
## lizardfs
##################

RUN apt-get install -y lsb-release
RUN wget -O - http://packages.lizardfs.com/lizardfs.key | apt-key add -
RUN echo "deb http://packages.lizardfs.com/debian/$(lsb_release -sc) $(lsb_release -sc) main" > /etc/apt/sources.list.d/lizardfs.list
RUN echo "deb-src http://packages.lizardfs.com/debian/$(lsb_release -sc) $(lsb_release -sc) main" >> /etc/apt/sources.list.d/lizardfs.list
RUN apt-get update

##################
## lizardfs-client
##################

RUN apt-get install -y lizardfs-client
RUN mkdir -p /mnt/lizardfs

##################
## stack
##################

RUN useradd stack
RUN mkdir -p /home/stack/.stack && chown stack:stack /home/stack/ -R
RUN mkdir /app
RUN wget -qO- https://get.haskellstack.org/ | sh
ADD . /app
RUN rm -rf /app/.stack-work
RUN cd /app && stack setup && stack build
