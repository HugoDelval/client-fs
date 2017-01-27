FROM debian:jessie

RUN apt-get update
RUN apt-get upgrade -y

##################
## lizardfs
##################

RUN apt-get install -y wget
RUN wget -O - http://packages.lizardfs.com/lizardfs.key | apt-key add -
RUN apt-get install -y lsb-release

RUN echo "deb http://packages.lizardfs.com/debian/$(lsb_release -sc) $(lsb_release -sc) main" > /etc/apt/sources.list.d/lizardfs.list
RUN echo "deb-src http://packages.lizardfs.com/debian/$(lsb_release -sc) $(lsb_release -sc) main" >> /etc/apt/sources.list.d/lizardfs.list

RUN apt-get update

###################
## lizardfs-cgiserv
###################

RUN apt-get install -y lizardfs-cgiserv

CMD service lizardfs-cgiserv start
