RM = rm
APPTAINER_BUILD = apptainer build
CONTAINER_DIR = ./container
INSTALL_MKDIR = install -d -m755
INSTALL_BIN = install -m755

VERSION ?= 0.0.1
PREFIX ?= /apps/opt/sdesktop/${VERSION}

clean:
	$(RM) ./container/sdesktop.sif

sif:
	$(APPTAINER_BUILD) ${CONTAINER_DIR}/sdesktop.sif ${CONTAINER_DIR}/sdesktop.def

install:
	$(INSTALL_MKDIR) ${PREFIX}/bin
	$(INSTALL_MKDIR) ${PREFIX}/bin/container
	$(INSTALL_BIN) ./srun.desktop.sh ${PREFIX}/bin/sdesktop
	$(INSTALL_BIN) ./sdesktop.sh ${PREFIX}/bin/sdesktop.sh
	$(INSTALL_BIN) ./container/sdesktop.sif ${PREFIX}/bin/container/sdesktop.sif
uninstall:
	$(RM) ${PREFIX}/bin/sdesktop
	$(RM) ${PREFIX}/bin/sdesktop.sh
	$(RM) ${PREFIX}/bin/container/sdesktop.sif
