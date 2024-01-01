.PHONY: fabian mtd fhlug push build

build:
	docker build --build-arg=student=test --build-arg=pepper=1337 -t knittl/ctf .
	# docker build --build-arg=student=test -t knittl/ctf .

fabian:
	docker build --build-arg=student=fabian --build-arg=pepper=12345 -t knittl/ctf:fabian .

mtd:
	docker build --build-arg=course=HYP --build-arg=student=mtd --build-arg=pepper=123456789 -t knittl/ctf:mtd .

fhlug:
	docker build --build-arg=course=TUX --build-arg=student=fhLUG --build-arg=pepper=abcdef -t knittl/ctf:fhlug .

push:
	docker push knittl/ctf:fabian
	docker push knittl/ctf:mtd
	docker push knittl/ctf:fhlug
