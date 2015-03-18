.EXPORT_ALL_VARIABLES:

TARGET	:= car
TOPDIR	:= $(shell /bin/pwd)
SUBDIRS	:= src

##############################################

#srctree	:= /home/kim6515516/git/kbuild
#srctree := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
srctree := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
export srctree objtree

CONFIG_SHELL := $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
          else if [ -x /bin/bash ]; then echo /bin/bash; \
          else echo sh; fi ; fi)

HOSTCC       = gcc
HOSTCXX      = g++
HOSTCFLAGS   = -Wall -Wno-char-subscripts -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer
HOSTCXXFLAGS = -O2
export CONFIG_SHELL HOSTCC HOSTCXX HOSTCFLAGS HOSTCXXFLAGS

################################################

#include $(TOPDIR)/Config.mk

#all : compile $(OBJS)
#	$(CC) $(OBJS) $(addsuffix /built-in.o, $(SUBDIRS)) -o $(TARGET)

all : compile

#include $(TOPDIR)/Rules.mk
compile:
	@for dir in $(SUBDIRS); do \
        make -C $$dir || exit $?; \
        done


clean:
	@for dir in $(SUBDIRS); do \
        make -C $$dir clean; \
        done
	rm -rf *.o *.i *.s $(TARGET)



#############################################################
# We need some generic definitions (do not try to remake the file).
include $(srctree)/scripts/Kbuild.include
PHONY += scripts_basic
scripts_basic:
	$(Q)$(MAKE) $(build)=scripts/basic
	$(Q)rm -f .tmp_quiet_recordmcount

config: scripts_basic FORCE
	$(Q)$(MAKE) $(build)=scripts/kconfig $@


menuconfig: scripts_basic FORCE
	$(Q)$(MAKE) $(build)=scripts/kconfig $@
	sh tools/convert-config-to-header.sh .config src/include/generated.h

mrproper-dirs      := $(addprefix _mrproper_,scripts)
PHONY += $(mrproper-dirs) mrproper
$(mrproper-dirs):
	$(Q)$(MAKE) $(clean)=$(patsubst _mrproper_%,%,$@)

mrproper: $(mrproper-dirs)

PHONY += FORCE
FORCE:

# Declare the contents of the .PHONY variable as phony.  We keep that
# information in a variable so we can use it in if_changed and friends.
.PHONY: $(PHONY)

