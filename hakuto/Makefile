##
## create docker image for hakuto-tork
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
	docker build -t tork/hakuto .
	$(call colorecho, "docker images")
	docker images tork/hakuto

run:
	#ndocker run --rm --env="DISPLAY" --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" -i -t tork/hakuto /bin/bash
	(docker stop hakuto; docker rm -f hakuto; echo "ok")
	sudo lsof -i :80  || echo "OK"  # apache2
	sudo lsof -i :8080 || echo "OK" # gzweb
	sudo lsof -i :7681 || echo "OK" # gzweb (roslib.js)
	sudo lsof -i :9001 || echo "OK" # supervisor
	sudo lsof -i :9090 || echo "OK" # websokcet
	docker run --name hakuto -d -p 80:80 -p 8080:8080 -p 7681:7681 -p 9001:9001 -p 9090:9090 -t tork/hakuto # /bin/bash
	@echo "gnome-open http://localhost:9001 # for supervisor console"
	@echo "gnome-open http://localhost:8080 # for gzweb"
	@echo "gnome-open http://localhost/joystick.html # for IF"

test: run
	bash -xc 'LOG=""; while [ `echo "$$LOG" |  grep -c "Successfully spawned model"` -ne 1 ]; do LOG=`docker ps | grep -v CONTAINER | cut -f1 -d\  | head -n1 | xargs docker logs`; echo "waiting..."; sleep 1; done; echo $$LOG # wait for server to startup'
	sleep 5 # make sure that server has been started
	curl -s --retry 5 http://localhost/ -o - | grep -iPo '(?<=<title>)(.*)(?=</title>)' # apache
	curl -s --retry 5 http://localhost:9001 -o - | grep -iPo '(?<=<title>)(.*)(?=</title>)'  # console
	curl -s --retry 5 http://localhost:8080 -o - | grep -iPo '(?<=<title>)(.*)(?=</title>)'  # gzweb
	curl -s --retry 5 http://localhost/joystick -o - | grep -iPo '(?<=<title>)(.*)(?=</title>)' # interface

push:
	docker push tork/hakuto

clean:
	# rm old docker image
	$(call colorecho, "rm old docker images")
	docker images | grep none && docker rmi -f $$(docker images | awk '/^<none>/ { print $$3 }') || echo "oK"

allclean:
	$(call colorecho, "rm stpped containers")
	test `docker ps -a | wc -l` -gt 1 && docker ps -a | tail -n +2 | cut -d\  -f1 | xargs docker rm || echo "ok"
	make clean

