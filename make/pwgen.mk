###########################################################
#
# pwgen
# 
###########################################################
#
PWGEN_SITE=http://$(SOURCEFORGE_MIRROR)/sourceforge/pwgen
PWGEN_VERSION=2.06
PWGEN_SOURCE=pwgen-$(PWGEN_VERSION).tar.gz
PWGEN_DIR=pwgen-$(PWGEN_VERSION)
PWGEN_UNZIP=zcat
PWGEN_MAINTAINER=Don Lubinski <nlsu2@shine-hs.com>
PWGEN_DESCRIPTION=The pwgen  program generates passwords which are designed to be easily memorized by humans, while being as secure  as  possible.  Human-memorable  passwords  are  never  going  to be as secure as completely completely random passwords.  In particular, passwords generated by  pwgen without  the  -s option should not be used in places where the password could be attacked via an off-line brute-force attack.    On  the  other hand,  completely  randomly  generated  passwords have a tendency to be written down, and are subject to being compromised in that fashion.
PWGEN_SECTION= Security
PWGEN_PRIORITY=optional

#
# PWGEN_IPK_VERSION should be incremented when the ipk changes.
#
PWGEN_IPK_VERSION=1

#
# PWGEN_CONFFILES should be a list of user-editable files
# PWGEN_CONFFILES=/etc/pwgend.conf $(TARGET_PREFIX)/etc/init.d/S05pwgend


#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
PWGEN_CPPFLAGS=
PWGEN_LDFLAGS=
PWGEN_CFLAGS=$(TARGET_CFLAGS) 

#
# PWGEN_BUILD_DIR is the directory in which the build is done.
# PWGEN_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# PWGEN_IPK_DIR is the directory in which the ipk is built.
# PWGEN_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
PWGEN_BUILD_DIR=$(BUILD_DIR)/pwgen
PWGEN_SOURCE_DIR=$(SOURCE_DIR)/pwgen
PWGEN_IPK_DIR=$(BUILD_DIR)/pwgen-$(PWGEN_VERSION)-ipk
PWGEN_IPK=$(BUILD_DIR)/pwgen_$(PWGEN_VERSION)-$(PWGEN_IPK_VERSION)_$(TARGET_ARCH).ipk

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(PWGEN_SOURCE):
	$(WGET) -P $(DL_DIR) $(PWGEN_SITE)/$(PWGEN_SOURCE)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
pwgen-source: $(DL_DIR)/$(PWGEN_SOURCE) 

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
$(PWGEN_BUILD_DIR)/.configured: $(DL_DIR)/$(PWGEN_SOURCE) 
	rm -rf $(BUILD_DIR)/$(PWGEN_DIR) $(PWGEN_BUILD_DIR)
	$(PWGEN_UNZIP) $(DL_DIR)/$(PWGEN_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test "$(BUILD_DIR)/$(PWGEN_DIR)" != "$(PWGEN_BUILD_DIR)" ; \
		then mv $(BUILD_DIR)/$(PWGEN_DIR) $(PWGEN_BUILD_DIR) ; \
	fi
	(cd $(PWGEN_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(STAGING_CPPFLAGS)" \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(PWGEN_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(PWGEN_LDFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=$(TARGET_PREFIX) \
		--disable-nls \
		--disable-static \
	)
	touch $(PWGEN_BUILD_DIR)/.configured

pwgen-unpack: $(PWGEN_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(PWGEN_BUILD_DIR)/.built: $(PWGEN_BUILD_DIR)/.configured
	rm -f $(PWGEN_BUILD_DIR)/.built
	$(MAKE) -C $(PWGEN_BUILD_DIR)
	touch $(PWGEN_BUILD_DIR)/.built

#
# This is the build convenience target.
#
pwgen: $(PWGEN_BUILD_DIR)/.built


# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/pwgen
#
$(PWGEN_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PWGEN_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: pwgen" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PWGEN_PRIORITY)" >>$@
	@echo "Section: $(PWGEN_SECTION)" >>$@
	@echo "Version: $(PWGEN_VERSION)-$(PWGEN_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PWGEN_MAINTAINER)" >>$@
	@echo "Source: $(PWGEN_SITE)/$(PWGEN_SOURCE)" >>$@
	@echo "Description: $(PWGEN_DESCRIPTION)" >>$@
#
#
# This builds the IPK file.
#
# Binaries should be installed into $(PWGEN_IPK_DIR)$(TARGET_PREFIX)/sbin or $(PWGEN_IPK_DIR)$(TARGET_PREFIX)/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
#
# You may need to patch your application to make it use these locations.
#
$(PWGEN_IPK): $(PWGEN_BUILD_DIR)/.built
	rm -rf $(PWGEN_IPK_DIR) $(BUILD_DIR)/pwgen_*_$(TARGET_ARCH).ipk
	$(INSTALL) -d $(PWGEN_IPK_DIR)$(TARGET_PREFIX)/bin
	$(INSTALL) -m 755 $(PWGEN_BUILD_DIR)/pwgen $(PWGEN_IPK_DIR)$(TARGET_PREFIX)/bin
	$(STRIP_COMMAND) $(PWGEN_IPK_DIR)$(TARGET_PREFIX)/bin/*
	$(INSTALL) -d $(PWGEN_IPK_DIR)$(TARGET_PREFIX)/man/man1
	$(INSTALL) -m 644 $(PWGEN_BUILD_DIR)/pwgen.1 $(PWGEN_IPK_DIR)$(TARGET_PREFIX)/man/man1
	$(MAKE) $(PWGEN_IPK_DIR)/CONTROL/control
	echo $(PWGEN_CONFFILES) | sed -e 's/ /\n/g' > $(PWGEN_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PWGEN_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(PWGEN_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
pwgen-ipk: $(PWGEN_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
pwgen-clean:
	rm -f $(PWGEN_BUILD_DIR)/.built
	-$(MAKE) -C $(PWGEN_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
pwgen-dirclean:
	rm -rf $(BUILD_DIR)/$(PWGEN_DIR) $(PWGEN_BUILD_DIR) $(PWGEN_IPK_DIR) $(PWGEN_IPK)
