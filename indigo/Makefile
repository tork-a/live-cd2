##
## create docker image for tork/indigo
##
## `make run` to test within the docker
##

# http://eli.thegreenplace.net/2013/12/18/makefile-functions-and-color-output
include ../color.mk
UPDATED_DATE=$(shell wget -S http://packages.ros.org/ros/ubuntu/dists/trusty/Release  -O - | grep Date) ## need to set last update of package.ros.org
CURRENT_DATE=$(shell date +%Y%m%d_%H%M%S)
GIT_TAG=$(shell git describe --abbrev=0 --tags)

all: Dockerfile
	$(call colorecho, "docker info")
	docker info
	$(call colorecho, "docker images")
	docker images
	$(call colorecho, "docker build")
	cp ../CHANGELOG.rst CHANGELOG.rst
	echo "" >> CHANGELOG.rst
	echo "git log --oneline" >> CHANGELOG.rst
	echo "-----------------" >> CHANGELOG.rst
	echo "" >> CHANGELOG.rst
	git log --oneline >> CHANGELOG.rst
	cp Dockerfile Dockerfile.tmp
	sed -i 's#@UPDATED_DATE@#$(UPDATED_DATE)#' Dockerfile.tmp
	sed -i 's#@CURRENT_DATE@#$(CURRENT_DATE)#' Dockerfile.tmp
	sed -i 's#@GIT_TAG@#$(GIT_TAG)#'  Dockerfile.tmp
	docker build -f Dockerfile.tmp -t tork/indigo:latest .
	rm Dockerfile.tmp CHANGELOG.rst
	$(call colorecho, "docker images")
	docker images tork/indigo

run:
	docker run --rm --env="DISPLAY" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" -i -t tork/indigo /bin/bash

test:
	docker run --rm -i -t tork/indigo rospack list # check if ros environment is set
	#docker run --rm -i -t tork/indigo rostest denso_launch vs060.test # check denso (need to wait for 1.1.5)
	#docker run --rm -i -t tork/indigo rostest hironx_ros_bridge test-hironx-ros-bridge-pose.test # test hironx

push:
	docker push tork/indigo

clean:
	# rm old docker image
	$(call colorecho, "rm old docker images")
	docker images | grep none && docker rmi $$(docker images | awk '/^<none>/ { print $$3 }') || echo "oK"

allclean:
	$(call colorecho, "rm stpped containers")
	test `docker ps -a | wc -l` -gt 1 && docker ps -a | tail -n +2 | cut -d\  -f1 | xargs docker rm || echo "ok"
	make clean

