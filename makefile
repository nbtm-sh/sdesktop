RM = rm
SED = sed -i
APPTAINER_BUILD = apptainer build
CONTAINER_DIR = ./container
INSTALL_MKDIR = install -d -m755
INSTALL_BIN = install -m755

VERSION ?= 0.1.0
PREFIX ?= /apps/opt/sdesktop/${VERSION}
GPU_PREFIX ?=/apps/opt/sdesktop/${VERSION}-gpu
TEST_PREFIX ?=/apps/opt/sdesktop/${VERSION}-test

clean:
	$(RM) ./container/sdesktop.sif

sif:
	$(APPTAINER_BUILD) ${CONTAINER_DIR}/sdesktop.sif ${CONTAINER_DIR}/sdesktop.def

install:
	$(INSTALL_MKDIR) ${PREFIX}/bin
	$(INSTALL_MKDIR) ${PREFIX}/container
	$(INSTALL_BIN) ./srun.desktop.sh ${PREFIX}/bin/sdesktop
	$(INSTALL_BIN) ./sdesktop.sh ${PREFIX}/bin/sdesktop.sh
	$(INSTALL_BIN) ./start.sh ${PREFIX}/start.sh
	$(SED) 's/VERSION=/VERSION=${VERSION}/g' ${PREFIX}/start.sh
	$(INSTALL_BIN) ./container/sdesktop.sif ${PREFIX}/container/sdesktop.sif
	$(INSTALL_MKDIR) ${GPU_PREFIX}/bin
	$(INSTALL_MKDIR) ${GPU_PREFIX}/container
	$(INSTALL_BIN) ./srun.desktop.sh ${GPU_PREFIX}/bin/sdesktop
	$(INSTALL_BIN) ./sdesktop.sh ${GPU_PREFIX}/bin/sdesktop.sh
	$(INSTALL_BIN) ./start-gpu.sh ${GPU_PREFIX}/start.sh
	$(INSTALL_BIN) ./container/sdesktop.sif ${GPU_PREFIX}/container/sdesktop.sif
	$(INSTALL_MKDIR) ${TEST_PREFIX}/bin
	$(INSTALL_MKDIR) ${TEST_PREFIX}/container
	$(INSTALL_BIN) ./srun.desktop.sh ${TEST_PREFIX}/bin/sdesktop
	$(INSTALL_BIN) ./sdesktop.sh ${TEST_PREFIX}/bin/sdesktop.sh
	$(INSTALL_BIN) ./start-gpu.sh ${TEST_PREFIX}/start.sh
	$(SED) 's/VERSION=/VERSION=${VERSION}/g' ${TEST_PREFIX}/start.sh
	$(INSTALL_BIN) ./container/sdesktop.sif ${TEST_PREFIX}/container/sdesktop.sif
uninstall:
	$(RM) ${PREFIX}/bin/sdesktop
	$(RM) ${PREFIX}/bin/sdesktop.sh
	$(RM) ${PREFIX}/bin/container/sdesktop.sif
