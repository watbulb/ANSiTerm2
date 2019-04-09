#
# ANSiTerm2 build targets
# Note: targets with double hashmark will be populated in `make help`
#

PROJECT       := ansiterm2
IDENTIFIER    := sh.potato.ansiterm2
CHECKSUM      := $(shell cat VERSION | cut -d: -f1 | xargs)
VERSION       := $(shell cat VERSION | cut -d: -f2 | xargs)
SIGNID		  := 52AMYRYD66

GIT_CASK      := https://raw.githubusercontent.com/watbulb/ANSiTerm2/$(VERSION)/ansiterm2.rb
GIT_PKG       := https://github.com/watbulb/ANSiTerm2/releases/download/\#{version}/ansiterm2.pkg
LOCAL_CASK    := ansiterm2.rb
LOCAL_PKG     := http://localhost:8000/ansiterm2.pkg

CONFDIR       := .config/ansiterm2
FONTDIR       := Library/Fonts
PROFILEDIR    := Library/Application\ Support/iTerm2/DynamicProfiles

PKG_SCRIPTS   := pkg/scripts
PKG_PROPS     := pkg/requirements.plist
PKG_DIST      := pkg/distribution.xml
PROFILE_PLIST := profile/$(IDENTIFIER)
SRC           := docs font profile trigger
PKG_OBJ		  := ansiterm2.pkg
OBJLIST       := sh.potato.ansiterm2.pkg $(PKG_OBJ)
OBJ 		  : $(OBJLIST)


# build the staging directory for .pkg creation
$(IDENTIFIER).pkg:
	@mkdir -p $@; rm -rf $@/*
	@mkdir -p $@/$(FONTDIR) $@/$(PROFILEDIR) $@/$(CONFDIR)


# build the archive (pkg) used for brew cask
$(PKG_OBJ): $(IDENTIFIER).pkg
	cp -r $(SRC) $^/$(CONFDIR)
	touch $^/$(PROFILEDIR)/$(IDENTIFIER).plist
	cp $^/$(CONFDIR)/font/* $^/$(FONTDIR)
	# build stage one of the package distro (core files)
	pkgbuild \
		--version $(VERSION) \
		--identifier $^ \
		--ownership preserve \
		--scripts $(PKG_SCRIPTS) \
		--root $^ \
		stage1_$@
	# build a final package distribution (linked stages)
	productbuild \
		--product $(PKG_PROPS) \
		--distribution $(PKG_DIST) \
		$@
	@rm stage1_$@


# when installing locally we need to update the cask to point to local URL
update_url:
	sed -i '' -e 's_url.*\".*_url "$(LOCAL_PKG)"_g' $(LOCAL_CASK)


# when installing locally we need to update the local archive checksum in the cask
update_checksum:
	sed -i '' -e "s/sha256.*'/sha256 '$(shell sha256sum $(PKG_OBJ) | cut -d' ' -f1)'/g" $(LOCAL_CASK)


all: ## (default) clean and build brew cask
all: clean OBJ


test: ## test client functionality (execute from inside ANSiTerm2)
	@echo "[-] ERROR: Currently not implemented!"
	@exit 1


audit: ## audit the brew cask
	brew cask audit $(LOCAL_CASK)


release: ## create signed release of ansiterm2.pkg
release: $(PKG_OBJ) | update_checksum
	productsign --sign $(SIGNID) $^ $^.signed
	mv $^.signed $^
	sed -i '' -e 's_url.*\".*_url "$(GIT_PKG)"_g' $(LOCAL_CASK)
	sha256sum $^


bumpver: ## bump versions to the version you've specified (NEWVER)
bumpver: VERSION README.md $(LOCAL_CASK) $(PKG_DIST)
ifeq ($(NEWVER),)
	@echo "[-] ERROR: NEWVER has not been supplied to make!"
	@exit 1
else
	$(foreach file,$^,sed -i '' -e 's/$(VERSION)/$(NEWVER)/g' $(file) ;)
	sed -i '' -e "s/$(CHECKSUM)/$(shell sha256sum $(PKG_OBJ) | cut -d' ' -f1)/g" VERSION
endif


install: ## install ANSiTerm2 (using git)
	HOMEBREW_INSTALL_BADGE="📟" \
	HOMEBREW_NO_AUTO_UPDATE=1   \
		brew cask install $(GIT_CASK)


install_local: ## install ANSiTerm2 (using local changes)
install_local: all | update_url update_checksum
	$(shell killall -9 python || :)
	python -m SimpleHTTPServer >/dev/null 2>&1 &
	HOMEBREW_INSTALL_BADGE="📟" \
	HOMEBREW_NO_AUTO_UPDATE=1   \
		brew cask install --verbose $(LOCAL_CASK)


uninstall: ## uninstall ANSiTerm2 brew cask
	brew cask uninstall --verbose $(PROJECT)


help: ## show this help dialog
	@echo
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
	@echo


clean: ## clean this project
	rm -rf $(OBJLIST)


.PHONY: $(OBJ) \
		update_url update_checksum \
		test audit release install uninstall clean help
.NOTPARALLEL: $(OBJ) \
		update_url update_checksum \
		test audit release install uninstall clean help
.DEFAULT_TARGET: all

