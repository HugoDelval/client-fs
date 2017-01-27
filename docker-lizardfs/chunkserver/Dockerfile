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

#######################
## lizardfs-chunkserver
#######################

RUN apt-get install -y lizardfs-chunkserver
RUN cp /etc/mfs/mfschunkserver.cfg.dist /etc/mfs/mfschunkserver.cfg
RUN cp /etc/mfs/mfshdd.cfg.dist /etc/mfs/mfshdd.cfg

RUN mkdir -p /srv/mfs-data/
RUN chown -R mfs:mfs /srv/mfs-data/
RUN echo "/srv/mfs-data" >> /etc/mfs/mfshdd.cfg

RUN sed -i 's/LIZARDFSCHUNKSERVER_ENABLE=false/LIZARDFSCHUNKSERVER_ENABLE=true/g' /etc/default/lizardfs-chunkserver
CMD service lizardfs-chunkserver start

# CMD mfschunkserver -d start
