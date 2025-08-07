# iox-aarch64-ubuntu

Ubuntu for Cisco ARM-based devices with IOx support (Cisco IR1101, IR1800, IE3400,....).

For small and efficiently running containers I recommend to use Alpine instead of Ubuntu, but I guess too many people are not clear on the difference between a VM and a container and tend to go what what they are most famlilar with. If this is what you want, this repo will help you get there.

### Clone the repository

```
git clone https://github.com/etychon/iox-aarch64-ubuntu.git
cd iox-aarch64-ubuntu
```

### Build

I have made this very simple: 

```sh
sh ./build.sh
```

You'll then have a file `ubuntu-IOx-aarch64-<VERSION>.tar.gz` in your build directory. This can be used unchanged in Cisco IOx Local Manager, or in applications like Cisco IoT Operations Dashboard.

Note that if you are using a version of Docker than is more recent that version 24, you'll need `ioxclient` version 1.18 or later. Check the `ioxclient` version with the `-v` option:

```sh
[etychon@squeeze iox-aarch64-ubuntu (main ✗)]$ ioxclient -v
ioxclient version 1.18.0.0
```

### Disable app-signature

Starting Cisco IOS-XE 17.15.1 the application signature verification is enabled by defaut, this means only Cisco-signed applications can be installed unless this is explicitly disabled. Before attemting to install this application, disable application signature verification with:

```sh
Router#app-hosting verification disable
App signature verification disabled successfully
```

### Enable IOx and IOx interface

IOx apps will communicate with IOS-XE and the rest of the network stack using a dedicated interface VirtualPortGroupX where X is a number. 

We'll need to configure the interface, assign IP addresses, enable DHCP server, and NAT to allow your IOx apps to access the rest of the network stack. 

Here is an example:

```sh
interface VirtualPortGroup0
 ip address 192.168.35.1 255.255.255.0
 ip nat inside
 ipv6 enable

ip dhcp pool ioxpool
 network 192.168.35.0 255.255.255.0
 default-router 192.168.35.1
 dns-server 192.168.35.1

 interface GigabitEthernet0/0/0
   ip nat outside

ip access-list extended IOxRange
  10 permit ip 192.168.35.0 0.0.0.255 any

ip nat inside source list IOxRange interface GigabitEthernet0/0/0 overload

ip dns server

iox
```

### Download IOx app on the router

If this absence of application management - like for example Cisco Catalyst SD-WAN Manager, the app can be manually installed on the router. While this is not practical nor recommended for any production deployment, this is possible.

Download the IOx app created previously on the router, for example here with FTP:

```sh
Router#copy ftp: bootflash:
Address or name of remote host []? 192.168.2.3
Source filename []? ubuntu-IOx-aarch64-1.5.tar.gz
Destination filename [ubuntu-IOx-aarch64-1.5.tar.gz]?
Accessing ftp://192.168.2.3/ubuntu-IOx-aarch64-1.5.tar.gz...!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
[OK - 142891328/4096 bytes]

142891328 bytes copied in 43.120 secs (3313806 bytes/sec)
```

Install the IOx app:

```sh
Router#app-hosting install appid ubuntu package bootflash:ubuntu-IOx-aarch64-1.5.tar.gz
Installing package 'bootflash:ubuntu-IOx-aarch64-1.5.tar.gz' for 'ubuntu'. Use 'show app-hosting list' for progress.
```

Verify the app is installed (called "deployed" in the IOx world):

```sh
Router#show app-hosting list
App id                                   State
---------------------------------------------------------
ubuntu                                   DEPLOYED
guestshell                               RUNNING
```

Now configure the IOx app's parameters, specifically how the app will access the network and how much resources will be allocated:

```sh

```


Activate and then start the IOx app. The activation step locks the required resources, and make sure there is enough, and is needed before starting the app: 

```sh
Router#app-hosting activate appid ubuntu
ubuntu activated successfully
Current state is: ACTIVATED

Router#app-hosting start appid ubuntu
ubuntu started successfully
Current state is: RUNNING
```

Now that the app is running, you can connect to the app console for example like so and check version as well as access the network that to the previously configured NAT:

```sh
Router#app-hosting connect appid ubuntu session
# more /etc/issue.net
Ubuntu 24.04.2 LTS
# ping www.cisco.com
PING e2867.dsca.akamaiedge.net (23.12.148.114) 56(84) bytes of data.
64 bytes from a23-12-148-114.deploy.static.akamaitechnologies.com (23.12.148.114): icmp_seq=1 ttl=58 time=11.0 ms
64 bytes from a23-12-148-114.deploy.static.akamaitechnologies.com (23.12.148.114): icmp_seq=2 ttl=58 time=14.7 ms
^C
```



