# Distributed filesystem

This project is a distributed filesystem based on *LizardFS* [http://docs.lizardfs.com](docs.lizardfs.com) wrapped into docker instances.

The client for this filesystem is also a *LizardFS* Docker instance but includes Haskell code to interact with the filesystem. 

# Quickstart

## Docker and Lizardfs

The docker configuration files as well as the Lizardfs configuration files were the biggest part of this project, you can find all these scripts in the **docker-lizardfs/** forlder.

## Server side

First you need to launch a master:

```bash
docker run -i hugodelval/lizardfs-master bash -c "service lizardfs-master restart && bash"
```

In this tutorial we will then refer to ```$MASTER_IP``` as the IP address of the master node. **Please replace this variable with the actual IP of the Docker node.**

```bash
$MASTER_IP = 172.17.0.2 # for example
```

To make sure the service is always up we can launch a master-shadow node, which is ready at any moment to take the role of the master node (by syncing each actions and so on..) :

```bash
docker run -i --add-host=mfsmaster:$MASTER_IP hugodelval/lizardfs-shadow bash -c "service lizardfs-master restart && bash"
```

Then we need one or several metalogger node(s) which store the metadata for each file/directory (location, size..) in a distributed fashion (information duplicated).

```bash
docker run -i --add-host=mfsmaster:$MASTER_IP hugodelval/lizardfs-metalogger bash -c "service lizardfs-metalogger restart && bash"
```

The last step for the sever side of the filesystem is to launch the actual chunkserver nodes, in these nodes will be the actual data (the files). The files will be replicated as well (see later).

```bash
docker run -i --add-host=mfsmaster:$MASTER_IP hugodelval/lizardfs-chunkserver bash -c "service lizardfs-chunkserver restart && bash"
```

## Client side

### FUSE

The first thing you need to do on the client side is to activate the *FUSE* module [https://en.wikipedia.org/wiki/Filesystem_in_Userspace](.wikipedia.org/wiki/Filesystem_in_Userspace). This is used to mount a filesystem over the network and use it as if it were local. By using *FUSE* and *LizardFS* we take advantage of all the power of the Linux Filesystem and we end up  having an **extremely quicker and robuster filesystem than if we were using an HTTP based distributed filesystem.** 

To activate *FUSE* on your Linux, type:

```bash
modprobe fuse
```

To check if it is enabled, type:

```bash
lsmod  | grep fuse
```

### Launching client

We are ready to launch the actual client !

```bash
docker run -i --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined --add-host=mfsmaster:$MASTER_IP hugodelval/lizardfs-client-stack /app/run.sh
```

Note that we need to add a Linux capacity to Docker (SYS_ADMIN) as well as the *FUSE* device and some security options to allow Docker to use *FUSE* and *LizardFS*

That's it congratulations!! You now have a fully functional distributed filesystem :) Let's now dig in a bit in the details of the implementation.

# Why LizardFS ?

## Overview

![alt text](https://raw.githubusercontent.com/HugoDelval/client-fs/master/res/lfs.png "LizardFS overview")

## Modularity

Each server can have one or more role (metadata, chunkserver, master and so on..). So it is easy to add a server if this functionnality takes to long (for example if there is a lack of space we can just pop another chunkserver really easily).

Another advantage of the modularity of *LizardFS* is the cost of the servers, each server can have a specialised hardware depending of its functionnality (ex: big HDD/SSD for the chunkservers).

## Reliability

Tests have been done on *LizardFS* by huge companies [https://www.reddit.com/r/DataHoarder/comments/3igkm2/can_you_please_share_your_experience_with_lizardfs/](www.reddit.com/r/DataHoarder/comments/3igkm2/can_you_please_share_your_experience_with_lizardfs/). They tested it for many days with 10 parallel FIO processes running 24 hours each, every FIO made up of a variable number (10 to 100) threads, on many nodes in parallel. And causing hard resets randomly while doing it. **Very few file systems work well doing that**. *LizardFS* was able to work flawlessly even in very hard conditions.

## Very good posix FS layer

*LizardFS* exposes only a traditional file system (through FUSE), not an object store and through a layer the CephFS posix layer.

## Snapshots

Snapshots are istantaneous, redirect-on-write (like NetApp's WAFL) so only changes are written to disk. 

## Goals
The LizardFS concept of goal is extremely powerful. You can ask for chunks to be placed on a specific kind of disk (for example, one copy on SSD and one on rotational), geographical (one copy here and one in the remote datacenter) and you can set the number of replicas file by file. Goal can be set per file, and changed at any time.

## Usability

There is a quite easy to use Web interface (cf ```docker run -d -p 9425:9425 --add-host="mfsmaster:172.17.0.2" hugodelval/lizardfs-cgi```), and a good set of command line tools.

## Autoscrubbing

Chunks are CRC verified, and periodically rechecked. If change is detected, **it gets rewritten transparently from one of the copies.**

## Performance

There is plenty of benchmarks in the web that compare distributed filesystems, one of them (which summurize the whole idea) is located here : [http://mrbluecoat.blogspot.ie/2016/02/updated-distributed-file-system.html](httpmrbluecoat.blogspot.ie/2016/02/updated-distributed-file-system.html)

From the conclusion of this benchmark we can conclude that *GlusterFS* and *LizardFS* are today on the top of the distributed filesystem. LizardFS was much faster than *GlusterFS* (at the cost of higher CPU usage).

In terms of setup and configuration (which is crucial for maintaining the filesystem during time), *GlusterFS* was easiest, followed by *LizardFS*.

From this benchmark we can see that both *GlusterFS* and *LizardFS* are both great distributed filesystem and we will be using *LizardFS* in this project due to the performance of this filesystem.


# Functionalities

- [x] Distributed Transparent File Access

	As said previously, *LizardFS* is efficient and extremely robust, with error recovery and so on.

- [x] Replication

	Go with the robustest of *LizardFS*, you can easily specify (cf configuration files & Docker) how many copies you want of which files.

- [x] Caching

	Caching is also supported by *LizardFS*

- [x] Directory Service 

	This is done via the metadatas server and the master server.

- [x] Lock Service 

	Locking a file is done by taking advantage of the filesystem itself to avoid slowing down the system by requesting a REST API. The locking system is based on lockfiles.

- [ ] Transactions

	TODO

- [ ] Security

	TODO


# What was hard in this project?

Working with both *LizardFS* and *Docker*, which are 2 complex projects, was quite hard. Both applications need some configurations to work together and *Docker* needs a lot of parameters to let *LizardFS* works properly.
