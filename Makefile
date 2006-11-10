SHELL = /bin/sh

program = gscan2pdf
version = $(shell sed -n 's/^my \$$version *= *"\(.*\)";/\1/p' < $(program))
year = $(shell date +%Y)
author = Jeffrey Ratcliffe
email = ra28145@users.sourceforge.net

LOCALE = .
DIST_BIN = /usr/bin
DIST_LOCALE = /usr/share/locale

PO = $(wildcard po/*.po)

tar : $(program)-$(version).tar.gz

dist : htdocs/download/debian/binary/$(program)-$(version).deb

web : htdocs/index.html

pot : po/$(program).pot

po.tar.gz : po/$(program).pot $(PO)
	cd po; tar cfvz po.tar.gz $(program).pot *.po
	mv po/po.tar.gz .

locale : $(PO)
	for file in $(PO); do \
         msgfmt -c $$file; \
         po=$${file#*/}; \
         mkdir --parents $(LOCALE)/$${po%%.po}/LC_MESSAGES; \
         mv messages.mo $(LOCALE)/$${po%%.po}/LC_MESSAGES/$(program).mo; \
         mkdir --parents tmp$(DIST_LOCALE)/$${po%%.po}/LC_MESSAGES; \
         cp $(LOCALE)/$${po%%.po}/LC_MESSAGES/$(program).mo \
                                    tmp$(DIST_LOCALE)/$${po%%.po}/LC_MESSAGES; \
         done

$(program) : ;

install : $(program)
	cp $(program) $(DIST_BIN)
	for file in $(PO); do \
         po=$${file#*/}; \
         mkdir --parents $(DIST_LOCALE)/$${po%%.po}/LC_MESSAGES; \
         cp $(LOCALE)/$${po%%.po}/LC_MESSAGES/$(program).mo \
                                      $(DIST_LOCALE)/$${po%%.po}/LC_MESSAGES; \
         done
	cp $(program).desktop /usr/share/applications

uninstall : $(program)
	rm $(DIST_BIN)/$(program) $(DIST_LOCALE)/*/LC_MESSAGES/$(program).mo \
	    /usr/share/applications/$(program).desktop

$(program)-$(version).tar.gz : $(program) Makefile INSTALL LICENSE COPYING $(PO)
	mkdir --parents ../$(program)-$(version)/deb ../$(program)-$(version)/po
	cp $(program) $(program).desktop Makefile INSTALL LICENSE COPYING \
	                                       History ../$(program)-$(version)
	cp $(PO) ../$(program)-$(version)/po
	cp deb/debian-binary deb/control ../$(program)-$(version)/deb
	cd .. ; tar cfvz $(program)-$(version).tar.gz $(program)-$(version)
	mv ../$(program)-$(version).tar.gz .
	rm -r ../$(program)-$(version)

deb/control : $(program)
	cp deb/control deb/control_tmp
	sed 's/^Version:.*/Version: $(version)/' < deb/control_tmp > deb/control
	rm deb/control_tmp

htdocs/download/debian/binary/$(program)-$(version).deb : tmp/DEBIAN/md5sums
	dpkg-deb -b tmp $(program)-$(version).deb
	cp $(program)-$(version).deb htdocs/download/debian/binary

tmp/DEBIAN/md5sums : $(program) deb/control locale
	mkdir --parents tmp/DEBIAN tmp$(DIST_BIN) tmp/usr/share/applications
	cp deb/control tmp/DEBIAN
	cp $(program) tmp$(DIST_BIN)
	chmod a+rx tmp$(DIST_BIN)/$(program)
	cp $(program).desktop tmp/usr/share/applications
	cd tmp ; md5sum $(shell find tmp -type f | \
                        awk '/.\// { print substr($$0, 5) }') > DEBIAN/md5sums

htdocs/download/debian/binary/Packages.gz : htdocs/download/debian/binary/$(program)-$(version).deb
	cd htdocs/download/debian ; \
         dpkg-scanpackages binary /dev/null | gzip -9c > binary/Packages.gz

remote-dist : htdocs/download/debian/binary/$(program)-$(version).deb htdocs/download/debian/binary/Packages.gz
	scp htdocs/download/debian/binary/$(program)-$(version).deb \
            htdocs/download/debian/binary/Packages.gz \
	    ra28145@shell.sf.net:/home/groups/g/gs/$(program)/htdocs/download/debian/binary

htdocs/index.html : $(program)
	pod2html --title=$(program)-$(version) $(program) > htdocs/index.html

remote-web : htdocs/index.html
	scp htdocs/index.html ra28145@shell.sf.net:/home/groups/g/gs/$(program)/htdocs/

po/$(program).pot : $(program)
	xgettext -L perl --keyword=get -o - $(program) | \
         sed 's/SOME DESCRIPTIVE TITLE/messages.pot for $(program)/' | \
         sed 's/PACKAGE VERSION/$(program)-$(version)/' | \
         sed "s/YEAR THE PACKAGE'S COPYRIGHT HOLDER/$(year) $(author)/" | \
         sed 's/PACKAGE/$(program)/' | \
         sed 's/FIRST AUTHOR <EMAIL@ADDRESS>, YEAR/$(author) <$(email)>, $(year)/' | \
         sed 's/Report-Msgid-Bugs-To: /Report-Msgid-Bugs-To: $(email)/' \
         > $@

clean :
	rm -r $(program)-$(version).deb* tmp $(program)-$(version).tar.gz
