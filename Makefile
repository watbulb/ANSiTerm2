#
# ANSiTerm2 build targets
# Note: targets with double hashmark will be populated in `make help`
#

PROJECT       := ansiterm2
CHECKSUM      := $(shell cat VERSION | cut -d: -f1 | xargs)
VERSION       := $(shell cat VERSION | cut -d: -f2 | xargs)

LOCAL_FORMULA := ansiterm2.rb
LOCAL_ARCHIVE := "http://localhost:8000/ansiterm2.tar.gz"
GIT_FORMULA   := "https://raw.githubusercontent.com/watbulb/ANSiTerm2/$(VERSION)/ansiterm2.rb"
GIT_ARCHIVE   := "https://github.com/watbulb/ANSiTerm2/releases/download/$(VERSION)/ansiterm2.tar.gz"

FONTDIR       := ~/Library/Fonts
PROFILEDIR    := ~/Library/Application\ Support/iTerm2/DynamicProfiles/

SRC           := doc font profile trigger
OBJ           := ansiterm2.tar.gz


# builds the archive used for brew formula
ansiterm2.tar.gz:
	tar -cjf $@ $(SRC)

	
# when installing locally we need to update the formula to point to local URL
update_localurl:
	sed -i '' -e 's_url.*\".*_url $(LOCAL_ARCHIVE)_g' $(LOCAL_FORMULA)


# when installing locally we need to update the local archive checksum in the formula
update_checksum:
	sed -i '' -e 's/sha256.*\".*/sha256 "$(shell sha256sum $(OBJ) | cut -d" " -f1)"/g' $(LOCAL_FORMULA)


all: ## (default) clean and build brew formula
all: clean $(OBJ)


test: ## test client functionality (execute from inside ANSiTerm2)
test: all
	@echo "[-] ERROR: Currently not implemented!"
	@exit 1


brewtest: ## test brew formula creation/installation
brewtest: install
	brew audit $(LOCAL_FORMULA)


install: ## install ANSiTerm2 regularly (using git)
install: all
	@HOMEBREW_INSTALL_BADGE="📟" \
	 HOMEBREW_NO_AUTO_UPDATE=1   \
		brew install -s $(GIT_FORMULA)


install_local: ## install ANSiTerm2 using local changes
install_local: update_localurl | all update_checksum
	@python -m SimpleHTTPServer >/dev/null 2>&1 &
	@HOMEBREW_INSTALL_BADGE="📟" \
	 HOMEBREW_NO_AUTO_UPDATE=1   \
		brew install -s $(LOCAL_FORMULA)
	@killall -KILL python


# @TODO: once ANSiTerm2 is casked this should all be handled by `brew remove`
uninstall: ## uninstall ANSiTerm2 brew formula
	@$(foreach font,$(shell ls -p font/.), rm -f $(FONTDIR)/$(font) || : ;)
	@echo "removed font files successfully"
	@$(foreach profile,$(shell ls -p profile/.), rm -f $(PROFILEDIR)/$(profile) || : ;)
	@echo "removed profile successfully"
	brew remove ansiterm2


help: ## show this help dialog
	@echo
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
	@echo


clean: ## clean this project
	rm -f $(OBJ)


.PHONY: $(OBJ) \
		update_localurl update_checksum \
		test brewtest install uninstall clean help
.NOTPARALLEL: $(OBJ) \
		update_localurl update_checksum \
		test brewtest install uninstall clean help
