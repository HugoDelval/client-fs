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

##################
## lizardfs-master
##################

RUN apt-get install -y lizardfs-master
RUN cp /var/lib/mfs/metadata.mfs.empty /var/lib/mfs/metadata.mfs
RUN cp /etc/mfs/mfsmaster.cfg.dist /etc/mfs/mfsmaster.cfg
RUN cp /etc/mfs/mfsexports.cfg.dist /etc/mfs/mfsexports.cfg
RUN cp /etc/mfs/mfsgoals.cfg.dist /etc/mfs/mfsgoals.cfg
RUN cp /etc/mfs/mfstopology.cfg.dist /etc/mfs/mfstopology.cfg

RUN sed -i 's/LIZARDFSMASTER_ENABLE=false/LIZARDFSMASTER_ENABLE=true/g' /etc/default/lizardfs-master
CMD service lizardfs-master start

# CMD mfsmaster -d start
