################################################################################
#
# ch341
#
################################################################################

CH341_VERSION = 1.5
CH341_SOURCE = CH341SER_LINUX.ZIP
CH341_SITE = https://cdn.sparkfun.com/assets/learn_tutorials/8/4/4
CH341_LICENSE = GPL-2.0, 
CH341_LICENSE_FILES = COPYING
CH341_EXTRACT_CMDS = $(UNZIP) -j $(CH341_DL_DIR)/$(CH341_SOURCE) -d $(BUILD_DIR)/ch341-$(CH341_VERSION)

$(eval $(kernel-module))
$(eval $(generic-package))
