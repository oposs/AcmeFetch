#  Copyright (C) 2015 Tobias Oetiker

AUTOMAKE_OPTIONS =  foreign

SUFFIXES = .1 .man

MJ_SCRIPT = acmefetch

SUBDIRS = thirdparty etc

BIN = bin/$(MJ_SCRIPT)

THIRDPARTY_DIR := $(shell pwd)/thirdparty

MAN = man/$(MJ_SCRIPT).1
POD = doc/$(MJ_SCRIPT).pod

PERLTESTS := $(shell test -d t && find t -name "*.t")

EXTRA_DIST = VERSION cpanfile COPYRIGHT LICENSE CHANGES.md AUTHORS bootstrap README.md Containerfile nfpm.yaml $(BIN) $(POD) $(PERLTESTS)

YEAR := $(shell date +%Y)
DATE := $(shell date +%Y-%m-%d)

datadir = $(prefix)

imandir = $(mandir)/man1
iman_DATA = $(MAN)

doc/%.pod: bin/% VERSION
	$(AM_V_GEN)mkdir -p doc;grep -A100000 '=head1 NAME' $< > $@

man/%.1: bin/% VERSION
	$(AM_V_GEN)mkdir -p man; test $(POD2MAN) = "no" || $(POD2MAN) --release=$(VERSION) --center=$(PACKAGE_NAME) $<  > $@

dist_bin_SCRIPTS = $(BIN)

dist-hook: $(POD)
	$(PERL) -i -p -e 's/#VERSION#/$(PACKAGE_VERSION)/g;s/#YEAR#/$(YEAR)/g;s/#DATE#/$(DATE)/g;'  $(distdir)/README.md $(distdir)/COPYRIGHT
	$(PERL) -i -p -e 's/^my .*# VERSION/my \$$VERSION = q{$(PACKAGE_VERSION)}; # VERSION/' $(distdir)/$(BIN)

install-exec-hook:
	if [ -n "$(PERL5LIB)" ]; then cd "$(DESTDIR)$(exec_prefix)" && $(PERL) -i -p -e 's{.*# PERL5LIB}{use lib qw($(PERL5LIB)); # PERL5LIB}' $(BIN); fi
	cd "$(DESTDIR)$(exec_prefix)" && $(PERL) -i -p -e 's{^use .*# LIBDIR}{use lib qw($(libdir)/perl5); # LIBDIR}' $(BIN)
	cd "$(DESTDIR)$(exec_prefix)" && $(PERL) -i -p -e 's{^#!.*perl.*}{#!$(PERL)};' $(BIN)
	cd "$(DESTDIR)$(exec_prefix)" && $(PERL) -i -p -e 's|^\s+my .*# CONFFILE|    my \$$cfg = loadCfg(\$$opt{cfg} // "$(sysconfdir)/$(MJ_SCRIPT).cfg"); # CONFFILE|' $(BIN)
	cd "$(DESTDIR)$(exec_prefix)" && $(PERL) -i -p -e 's/^my .*# VERSION/my \$$VERSION = q{$(PACKAGE_VERSION)}; # VERSION/' $(BIN)

check-local: test

test:
	$(PERL) "-MExtUtils::Command::MM" "-e" "test_harness(0, 'thirdparty/lib/perl5')" $(PERLTESTS)
