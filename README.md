# Devops Tech-talk : Consul

#### Team Members:
----
1. Ankit Kumar (akumar18)
2. Ashutosh Chaturvedi (achatur)
3. Ayush Gupta (agupta25)  
4. Shivam Gulati (sgulati2)

### What is Consul  

Consul is a tool for discovering and configuring services in your infrastructure. It can be used by the DevOps as well as Application developers.
It has the following features:

1. Service Discovery
  1.  Consul clients can provide or discover services
  2.  Can use API, MYSQL or DNS, HTTP as needed.
2. Health checking
  1. Provide Health checks like webserver status, memory consumption
  2.  This helps to keep an eye on health of the cluster
  3.  It also allows to re-route traffic when hosts are unhelthy or have failed.
3. Key/ Value Store
  1. Key value storage allows for dynamicconfiguration, feature flags, electing the leader, etc.
  2. HTTP API requests can be made to achieve the same.
4. Multi Datacenter
  1. Supports datacenters across geography
  2. Easy to add layers to the system as needed.

### Architecture

In Figure 1 below, we have two datacenters here to show since Consul supports multiple datacenters. Each datacenter contains few clients and few servers. Having a lot of servers makes the consensus slower but increases the availability due to failure of machines and improvements performances. That being said, clients can be easily scales to thousands of machines,

A gossip pool is maintained which contains all the nodes in a datacenter. This has below benefits:
1. Automatic discovery, hence no configuration for clients with server addresses.
2. Node failure detection is distributed.
3. Scalable
4. Message passing to notify events.

A single leader is elected in each datacenter and it performs priviledged roles like processing all queries and transactions. The same are alo replicated across peers. A non-leader forwards Remote Procedure Calls to the leader in cluster.
 
Bringing a new datacenter online is easy. Since servers operate in the WAN pool, it allows cross-datacenter requests. When a server receives a request for a different datacenter, it forwards it to a random server in the correct datacenter. It may forward it to the local leader.

This results in a very low coupling between datacenters, but because of failure detection, connection caching and multiplexing, cross-datacenter requests are relatively fast and reliable.

![Architecture](https://github.com/shivamgulati1991/Consul_DevOpsDemo/blob/master/Images/architecture.png)
Figure 1: Consul architecture

### How to Install Consul

1. To install Consul, click [here](https://www.consul.io/downloads.html) to download the package. This contains the packages for Mac, Windows, Linux, FreeBSD and Solaris systems. 
   More details at [Installation](https://github.ncsu.edu/achatur/DevOpsTechTalk/blob/master/Installation)
2. After downloading, unzip the package.
3. Copy the consul binary to PATH variable. On Unix, ~/bin and /usr/local/bin are installation directories depending upon the access you need.
4. If you are on an OS X machine, run the below command

  ```
  $ brew install consul
  ```
5. For Linux,
  ```
  cd /usr/local/bin
  wget https://dl.bintray.com/mitchellh/consul/0.3.0_linux_amd64.zip
  unzip *.zip
  rm *.zip
  ```

6. To check if Consul was successfully installed, run

  ```
  $ consul
  ```

6. You should get the below screen which shows you the commands you can run with Consul.
![Installation](https://github.ncsu.edu/achatur/DevOpsTechTalk/blob/master/Images/installation.JPG)
Figure 2: Consul Install

7. In case of an error, it could be that your PATH variable wasn't set properly. Verify that again.


### Running Consul
To illustrate the use of consul with a demo follow the steps given below:
 + Install vagrant on your system.
 + Setup Vagrant Nodes (Two nodes atleast) using the sample [Vagrantfile](https://github.com/hashicorp/consul/blob/master/demo/vagrant-cluster/Vagrantfile).
 + Use the different commands in the [file](https://github.ncsu.edu/achatur/DevOpsTechTalk/blob/master/scripts/run.sh) to run server on one node and client on the other node.
 + For enabling access to the UI, forward the port 8500 from the vagrant box to your host system. This can be done by adding the following line to the corresponding node (generally server) in your vagrantfile's network configuration:
```
n1.vm.network "forwarded_port", guest: 8500, host: 8500
```
 + The URL for the consul UI is: http://localhost:8500/ui
**Note**: The Vagrantfile we provided is a link to the Vagrantfile provided in original consul's repository, in the demo section.

### Pros and Cons

#### Pros     

1. It has more high-level features like service monitoring.
2. There is another project out of Hashicorp that will read/set environment variable for processes from Consul.
    https://github.com/hashicorp/envconsul
3. Better documentation - Easier to install and configure this.
4. You can make DNS queries directly against Consul agent! Nice! No need for SkyDNS or Helix
5. You can add arbitrary checks! Nice, if you are into that sort of thing.
6. Understands the notion of a datacenter. Each cluster is confined to datacenter but the cluster is able to communicate with other datacenters/clusters.
7. At Skybox, we might use this feature to separate docker tracks, even if they live on same host.
8. It has a rudimentary web UI- http://demo.consul.io/ui/

#### Cons
1. Need some configuration management tool to install it
2. Manual bootstrapping
3. Security Flaw - Encryption not during transit (only at storage)
4. Naive Implementation



### Comparison with related tools
The problems Consul solves are varied, but each individual feature has been solved by many different systems. Although there is no single system that provides all the features of Consul, there are other options available to solve some of these problems.

#### CONSUL VS. ZOOKEEPER, DOOZERD, ETCD

 1. Multi-datacenter functionality available using gossip system that links server nodes and clients.
 2. ZooKeeper and etcd provide only a primitive K/V store and require that application developers build their own system to provide service discovery.
 3. Health checking is less complex and more feature rich.  

#### CONSUL VS. CHEF, PUPPET, ETC.

Configuration management tools like Puppet, Chef, and other tools are used to build service discovery mechanisms. This is usually done by querying global state to construct configuration files on each node during a periodic convergence run. This approach has disadvantages such as:  
 1. The configuration information is static and cannot update any more frequently than convergence runs which can be minutes as well as hours.  
 2. There is no mechanism to incorporate the system state in the configuration.
 3. Challenging to support multiple datacenters as a central group of servers must manage all datacenters.  

Consul has below advantages above these other tools:  
 1. No or little dependency over external components.
 2. Uses DNS or HTTP APIs, no configuration required in advance.
 3. Richer health checking system: Both service and host level checks. 
 4. Consul also provides an integrated key/value store for configuration and multi-datacenter support.  
 
#### CONSUL VS. NAGIOS, SENSU

Nagios and Sensu are both tools built for monitoring. They are used to quickly notify operators when an issue occurs.  
 1. Difficult to scale as large fleets quickly reach the limit of vertical scaling, and Nagios does not easily scale horizontally.
 2. In case of Sensu, the central broker has scaling limits and acts as a single point of failure in the system.
 
As compared to these tools, Consul provides below features:
 1. Consul runs all checks locally, like Sensu, avoiding placing a burden on central servers.
 2. The status of checks is maintained by the Consul servers, which are fault tolerant and have no single point of failure. 
 3. Consul can scale to vastly more checks because it relies on edge-triggered updates.
 4. The gossip protocol used between clients and servers integrates a distributed failure detector. This means that if a Consul agent fails, the failure will be detected, and thus all checks being run by that node can be assumed failed.
 
#### CONSUL VS. SERF  

Serf is a node discovery and orchestration tool and is the only tool discussed so far that is built on an eventually-consistent gossip model with no centralized servers. It provides a number of features, including group membership, failure detection, event broadcasts, and a query mechanism. However, Serf does not provide any high-level features such as service discovery, health checking or key/value storage. Consul is a complete system providing all of those features.  
The internal gossip protocol used within Consul is in fact powered by the Serf library: Consul leverages the membership and failure detection features and builds upon them to add service discovery. By contrast, the discovery feature of Serf is at a node level, while Consul provides a service and node level abstraction.  

### Conclusion

### Screencast of demo
[![Consul.io](https://img.youtube.com/vi/AmjLgHQUSPU/0.jpg)](https://www.youtube.com/watch?v=AmjLgHQUSPU)

### Talk

[Presentation Link](https://github.com/shivamgulati1991/Consul_DevOpsDemo/blob/master/Presentation_TechTalk.pdf)

### Resources

1. https://www.consul.io/
2. https://github.com/hashicorp/consul
3. https://www.digitalocean.com/community/tutorials/an-introduction-to-using-consul-a-service-discovery-system-on-ubuntu-14-04
4. https://technologyconversations.com/2015/09/08/service-discovery-zookeeper-vs-etcd-vs-consul/
