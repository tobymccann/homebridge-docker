default: build

# Default target to build the image
build:
	docker build -t homebridge-docker .

clean:
	-docker kill homebridge
	-docker rm homebridge

# Target to build and run and subsequently remove image
run: build
	docker run --net=host --rm \
		-p "51826:51826" \
		-v "$(shell pwd)/config.json:/var/homebridge/.homebridge/config.json" \
		-v "$(shell pwd)/plugins.txt:/var/homebridge/.homebridge/plugins.txt" \
		-v "$(shell pwd)/persist:/var/homebridge/.homebridge/persist" \
		homebridge-docker

# Target to drop into an interractive shell
shell: build
	docker run --net=host --rm \
		-p "51826:51826" \
		-v "$(shell pwd)/config.json:/var/homebridge/.homebridge/config.json" \
		-v "$(shell pwd)/plugins.txt:/var/homebridge/.homebridge/plugins.txt" \
		-v "$(shell pwd)/persist:/var/homebridge/.homebridge/persist" \
		-it homebridge-docker bash

# Target to buld and run in detached mode (continuously)
go: build
	make clean
	docker run --net=host -d \
		-p "51826:51826" \
		-v "$(shell pwd)/config.json:/var/homebridge/.homebridge/config.json" \
		-v "$(shell pwd)/plugins.txt:/var/homebridge/.homebridge/plugins.txt" \
		-v "$(shell pwd)/persist:/var/homebridge/.homebridge/persist" \
		--name homebridge \
		--restart=always \
		homebridge-docker

# Tags dev image so it can be pushed
tag: build
	docker tag homebridge-docker tobymccann/homebridge-docker

# Pushes tagged image to docker hub
push: tag
	docker push tobymccann/homebridge-docker
