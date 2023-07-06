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

```
sh ./build.sh
```

You'll then have a file `ubuntu-IOx-aarch64-<VERSION>.tar.gz` in your build directory. This can be used unchanged in Cisco IOx Local Manager, or in applications like Cisco IoT Operations Dashboard.

