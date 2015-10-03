###########################################################
#
# perl-module-signature
#
###########################################################

PERL-MODULE-SIGNATURE_SITE=http://search.cpan.org/CPAN/authors/id//A/AU/AUTRIJUS
PERL-MODULE-SIGNATURE_VERSION=0.54
PERL-MODULE-SIGNATURE_SOURCE=Module-Signature-$(PERL-MODULE-SIGNATURE_VERSION).tar.gz
PERL-MODULE-SIGNATURE_DIR=Module-Signature-$(PERL-MODULE-SIGNATURE_VERSION)
PERL-MODULE-SIGNATURE_UNZIP=zcat
PERL-MODULE-SIGNATURE_MAINTAINER=NSLU2 Linux <nslu2-linux@yahoogroups.com>
PERL-MODULE-SIGNATURE_DESCRIPTION=Module-Signature - Module signature file manipulation.
PERL-MODULE-SIGNATURE_SECTION=util
PERL-MODULE-SIGNATURE_PRIORITY=optional
PERL-MODULE-SIGNATURE_DEPENDS=perl, perl-par-dist, perl-algorithm-diff, perl-text-diff, perl-digest-sha
PERL-MODULE-SIGNATURE_SUGGESTS=
PERL-MODULE-SIGNATURE_CONFLICTS=

PERL-MODULE-SIGNATURE_IPK_VERSION=2

PERL-MODULE-SIGNATURE_CONFFILES=


PERL-MODULE-SIGNATURE_BUILD_DIR=$(BUILD_DIR)/perl-module-signature
PERL-MODULE-SIGNATURE_SOURCE_DIR=$(SOURCE_DIR)/perl-module-signature
PERL-MODULE-SIGNATURE_IPK_DIR=$(BUILD_DIR)/perl-module-signature-$(PERL-MODULE-SIGNATURE_VERSION)-ipk
PERL-MODULE-SIGNATURE_IPK=$(BUILD_DIR)/perl-module-signature_$(PERL-MODULE-SIGNATURE_VERSION)-$(PERL-MODULE-SIGNATURE_IPK_VERSION)_$(TARGET_ARCH).ipk

PERL-MODULE-SIGNATURE_PATCHES=$(PERL-MODULE-SIGNATURE_SOURCE_DIR)/Makefile.PL.patch


$(DL_DIR)/$(PERL-MODULE-SIGNATURE_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-MODULE-SIGNATURE_SITE)/$(PERL-MODULE-SIGNATURE_SOURCE)

perl-module-signature-source: $(DL_DIR)/$(PERL-MODULE-SIGNATURE_SOURCE) $(PERL-MODULE-SIGNATURE_PATCHES)

$(PERL-MODULE-SIGNATURE_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-MODULE-SIGNATURE_SOURCE) $(PERL-MODULE-SIGNATURE_PATCHES)
	$(MAKE) perl-par-dist-stage perl-algorithm-diff-stage perl-text-diff-stage perl-digest-sha-stage
	rm -rf $(BUILD_DIR)/$(PERL-MODULE-SIGNATURE_DIR) $(PERL-MODULE-SIGNATURE_BUILD_DIR)
	$(PERL-MODULE-SIGNATURE_UNZIP) $(DL_DIR)/$(PERL-MODULE-SIGNATURE_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	cat $(PERL-MODULE-SIGNATURE_PATCHES) | $(PATCH) -d $(BUILD_DIR)/$(PERL-MODULE-SIGNATURE_DIR) -p1
	mv $(BUILD_DIR)/$(PERL-MODULE-SIGNATURE_DIR) $(PERL-MODULE-SIGNATURE_BUILD_DIR)
	(cd $(PERL-MODULE-SIGNATURE_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl" \
		$(PERL_HOSTPERL) Makefile.PL \
		PREFIX=$(TARGET_PREFIX) \
	)
	touch $(PERL-MODULE-SIGNATURE_BUILD_DIR)/.configured

perl-module-signature-unpack: $(PERL-MODULE-SIGNATURE_BUILD_DIR)/.configured

$(PERL-MODULE-SIGNATURE_BUILD_DIR)/.built: $(PERL-MODULE-SIGNATURE_BUILD_DIR)/.configured
	rm -f $(PERL-MODULE-SIGNATURE_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-MODULE-SIGNATURE_BUILD_DIR) \
	PERL5LIB="$(STAGING_LIB_DIR)/perl5/site_perl"
	touch $(PERL-MODULE-SIGNATURE_BUILD_DIR)/.built

perl-module-signature: $(PERL-MODULE-SIGNATURE_BUILD_DIR)/.built

$(PERL-MODULE-SIGNATURE_BUILD_DIR)/.staged: $(PERL-MODULE-SIGNATURE_BUILD_DIR)/.built
	rm -f $(PERL-MODULE-SIGNATURE_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-MODULE-SIGNATURE_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-MODULE-SIGNATURE_BUILD_DIR)/.staged

perl-module-signature-stage: $(PERL-MODULE-SIGNATURE_BUILD_DIR)/.staged

$(PERL-MODULE-SIGNATURE_IPK_DIR)/CONTROL/control:
	@$(INSTALL) -d $(PERL-MODULE-SIGNATURE_IPK_DIR)/CONTROL
	@rm -f $@
	@echo "Package: perl-module-signature" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(PERL-MODULE-SIGNATURE_PRIORITY)" >>$@
	@echo "Section: $(PERL-MODULE-SIGNATURE_SECTION)" >>$@
	@echo "Version: $(PERL-MODULE-SIGNATURE_VERSION)-$(PERL-MODULE-SIGNATURE_IPK_VERSION)" >>$@
	@echo "Maintainer: $(PERL-MODULE-SIGNATURE_MAINTAINER)" >>$@
	@echo "Source: $(PERL-MODULE-SIGNATURE_SITE)/$(PERL-MODULE-SIGNATURE_SOURCE)" >>$@
	@echo "Description: $(PERL-MODULE-SIGNATURE_DESCRIPTION)" >>$@
	@echo "Depends: $(PERL-MODULE-SIGNATURE_DEPENDS)" >>$@
	@echo "Suggests: $(PERL-MODULE-SIGNATURE_SUGGESTS)" >>$@
	@echo "Conflicts: $(PERL-MODULE-SIGNATURE_CONFLICTS)" >>$@

$(PERL-MODULE-SIGNATURE_IPK): $(PERL-MODULE-SIGNATURE_BUILD_DIR)/.built
	rm -rf $(PERL-MODULE-SIGNATURE_IPK_DIR) $(BUILD_DIR)/perl-module-signature_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(PERL-MODULE-SIGNATURE_BUILD_DIR) DESTDIR=$(PERL-MODULE-SIGNATURE_IPK_DIR) install
	find $(PERL-MODULE-SIGNATURE_IPK_DIR)$(TARGET_PREFIX) -name 'perllocal.pod' -exec rm -f {} \;
	(cd $(PERL-MODULE-SIGNATURE_IPK_DIR)$(TARGET_PREFIX)/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	find $(PERL-MODULE-SIGNATURE_IPK_DIR)$(TARGET_PREFIX) -type d -exec chmod go+rx {} \;
	$(MAKE) $(PERL-MODULE-SIGNATURE_IPK_DIR)/CONTROL/control
	echo $(PERL-MODULE-SIGNATURE_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-MODULE-SIGNATURE_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-MODULE-SIGNATURE_IPK_DIR)

perl-module-signature-ipk: $(PERL-MODULE-SIGNATURE_IPK)

perl-module-signature-clean:
	-$(MAKE) -C $(PERL-MODULE-SIGNATURE_BUILD_DIR) clean

perl-module-signature-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-MODULE-SIGNATURE_DIR) $(PERL-MODULE-SIGNATURE_BUILD_DIR) $(PERL-MODULE-SIGNATURE_IPK_DIR) $(PERL-MODULE-SIGNATURE_IPK)
