.PHONY: test build push

build:
	docker build --build-arg=student=test --build-arg=pepper=1337 -t knittl/ctf .

push:
	docker push knittl/ctf

test:
	@if ./test.sh; then echo '[OK] All tests passed'; else echo '[ERR] Tests failed!'; fi

