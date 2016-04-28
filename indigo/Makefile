##
## create docker image for tork/indigo
##
## `make run` to test within the docker
##

# http://eli.thegreenplace.net/2013/12/18/makefile-functions-and-color-output
include ../color.mk

all: Dockerfile
	$(call colorecho, "docker info")
	docker info
	$(call colorecho, "docker images")
	docker images
	$(call colorecho, "docker build")
	docker build -t tork/indigo .
	$(call colorecho, "docker images")
	docker images tork/indigo

run:
	docker run --rm --env="DISPLAY" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" -i -t tork/indigo /bin/bash

test:
	docker run --rm -i -t tork/indigo rospack list # check if ros environment is set
	#docker run --rm -i -t tork/indigo rostest denso_launch vs060.test # check denso (need to wait for 1.1.5)
	#docker run --rm -i -t tork/indigo rostest hironx_ros_bridge test-hironx-ros-bridge-pose.test # test hironx


clean:
	# rm old docker image
	$(call colorecho, "rm old docker images")
	docker images | grep none && docker rmi $$(docker images | awk '/^<none>/ { print $$3 }') || echo "oK"

allclean:
	$(call colorecho, "rm stpped containers")
	test `docker ps -a | wc -l` -gt 1 && docker ps -a | tail -n +2 | cut -d\  -f1 | xargs docker rm || echo "ok"
	make clean

