.PHONY: build push

build:
	docker build --build-arg=student=test --build-arg=pepper=1337 -t knittl/ctf .

push:
	docker push knittl/ctf
