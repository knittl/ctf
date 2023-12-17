.PHONY: build push

build:
	docker build --build-arg=student=fabian --build-arg=pepper=12345 -t knittl/ctf:fabian .

push:
	docker push knittl/ctf:fabian
