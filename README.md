# onovy-mass
My own Debian mass-commiter

## Tools

### check-all
checks already checked out repository (current directory). Changes are not automatically pushed after check if you didn't uncomment "git push" in check-all script.

Example:
```
$ cd package
$ ../onovy-mass/check-all
```

### clone-check-all
clone from Salsa and check one repository

Example:
```
$ ./clone-check-all openstack-team/clients/python-qinlingclient.git
```

### parallel-clone-check-all
clones from Salsa and checks list of repositories in parallel. Please "apt install parallel" first.

Example:
```
$ head -n 2 openstack 
openstack-team/clients/python-osc-placement.git
openstack-team/clients/python-qinlingclient.git
$ ./parallel-clone-check-all openstack
```
