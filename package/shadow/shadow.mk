################################################################################
#
# linux-pam
#
################################################################################

SHADOW_VERSION = 4.9
SHADOW_SOURCE = shadow-$(SHADOW_VERSION).tar.xz
SHADOW_SITE =  https://github.com/shadow-maint/shadow/releases/download/v$(SHADOW_VERSION)
SHADOW_AUTORECONF = YES
SHADOW_AUTORECONF_OPTS = -fiv
SHADOW_CONF_OPTS = \
	--sysconfdir=/etc \
        --with-group-name-max-length=32

SHADOW_DEFS = FAIL_DELAY               \
              LASTLOG_ENAB             \
              MAIL_CHECK_ENAB          \
              OBSCURE_CHECKS_ENAB      \
              PORTTIME_CHECKS_ENAB     \
              QUOTAS_ENAB              \
              CONSOLE MOTD_FILE        \
              FTMP_FILE NOLOGINS_FILE  \
              ENV_HZ PASS_MIN_LEN      \
              SU_WHEEL_ONLY            \
              CRACKLIB_DICTPATH        \
              PASS_CHANGE_TRIES        \
              PASS_ALWAYS_WARN         \
              CHFN_AUTH ENCRYPT_METHOD \
              ENVIRON_FILE

SHADOW_PROGRAMS = chfn \
		  chgpasswd \
                  chpasswd \
                  chsh \
                  groupadd \
                  groupdel \
                  groupmems \
                  groupmod \
                  newusers \
                  useradd \
                  userdel \
                  usermod

ifeq ($(BR2_PACKAGE_CRACKLIB),y)
SHADOW_CONF_OPTS += --with-libcrack
endif

# Install default pam config (deny everything except login)
define SHADOW_INSTALL_CONFIG
	$(INSTALL) -m 0644 -D package/shadow/passwd.pam \
		$(TARGET_DIR)/etc/pam.d/passwd
	$(INSTALL) -m 0644 -D package/shadow/su.pam \
		$(TARGET_DIR)/etc/pam.d/su	
	$(INSTALL) -m 0644 -D package/shadow/chage.pam \
		$(TARGET_DIR)/etc/pam.d/chage	
	$(INSTALL) -m 0644 -D package/shadow/sudo.pam \
		$(TARGET_DIR)/etc/pam.d/sudo	
	$(INSTALL) -m 0644 -D package/shadow/login.pam \
		$(TARGET_DIR)/etc/pam.d/login
        $(INSTALL) -v -m 0644 $(TARGET_DIR)/etc/login.defs $(TARGET_DIR)/etc/login.defs.orig

endef

#Modifie definitions on login.defs
define SHADOW_MODIFY_DEFS

    $(foreach defs, $(SHADOW_DEFS),     
          $(SED) 's/^${defs}/# &/' $(TARGET_DIR)/etc/login.defs
     )
endef

ifeq ($(BR2_PACKAGE_CRACKLIB),y)
     SHADOW_INSTALL_CONFIG += $(SED) 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' $(TARGET_DIR)/etc/login.defs
endif

define SHADOW_CREATE_FILES	
	$(foreach PROGRAM,$(SHADOW_PROGRAMS),
           $(INSTALL) -v -m644 $(TARGET_DIR)/etc/pam.d/chage $(TARGET_DIR)/etc/pam.d/${PROGRAM}
           $(SED) "s/chage/${PROGRAM}/" $(TARGET_DIR)/etc/pam.d/${PROGRAM}
        )
endef

SHADOW_POST_INSTALL_TARGET_HOOKS += SHADOW_INSTALL_CONFIG SHADOW_MODIFY_DEFS SHADOW_CREATE_FILES

$(eval $(autotools-package))
