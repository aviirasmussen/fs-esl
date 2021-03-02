# Freeswitch event handler system 

Installs a minimal Freeswitch container, and a Mojolicious web server that serves as an interface into FS events

## Reference installation

 - Ubuntu 20.04.1 LTS (Focal Fossa).

## Ubuntu
 - sudo apt update
 - sudo apt upgrade
 - sudo apt install net-tools
 - sudo apt install docker.io
 - sudo apt install <your choise if editor>
 - sudo systemctl enable --now docker
 - sudo usermod -aG docker <your ubuntu username>
 - sudo systemctl enable docker.service
 - sudo systemctl enable containerd.service
 - sudo systemctl start docker.servic

exit terminal and login again, then test your docker with the hello-world image
 - docker run hello-world
 
## install docker-compose
 - https://docs.docker.com/compose/install/

### check version
docker --version
## Docker

### Freeswitch

In the Dockerfile you can edit the command to start with FS console (-c) or with no console (-nc)

 - #CMD ["/usr/bin/freeswitch", "-nonat", "-nf", "-c"]
 - #CMD ["/usr/bin/freeswitch", "-nonat", "-nf", "-nc"]

build image:

 - docker build . -t fs --no-cache

run container

 - docker run --name fs -d --net host fs

access container

 - docker exec -i -t fs /bin/bash

### Mojolicious FS event handler

NB!! Edit Dockerfile and src/templates/index.html.ep and replace 192.168.1.32 with your chooice of ip-adress

build image:

 - docker build . -t esl --no-cache

run container

 - docker run --name esl -d -v $PWD/src/:/usr/local/esl --net host esl

access container

 - docker exec -i -t esl /bin/bash
