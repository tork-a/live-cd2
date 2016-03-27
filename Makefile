all: vagrant indigo builder

vagrant:
	(cd vagrant; make)

indigo:
	(cd indigo; make)

builder:
	(cd builder; make)

.PHONY:	vagrant indigo builder
