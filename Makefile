PROJECT := ansiterm2
FORMULA := ansiterm2.rb

SRC := font profile trigger
OBJ := ansiterm2.tar.gz

ansiterm2.tar.gz: ## build ANSiterm2 brew formula
ansiterm2.tar.gz:
	tar -cjf $@ $(SRC)

all: ## (default) clean and build ANSiterm2 brew formula
all: clean $(OBJ)

test: ## test ANSiterm2 client functionality (execute from ANSiterm2)
test: all
	@echo "[-] ERROR: Currently not implemented!"
	@exit 1

brewtest: ## test ANSiterm2 brew formula creation/installation
brewtest: install
	brew audit $(FORMULA)

install: ## install ANSiterm2
install: all
	@sed -i '' -e 's/sha256.*\".*/sha256   "$(shell sha256sum $(OBJ) | cut -d" " -f1)"/g' $(FORMULA)
	@python -m SimpleHTTPServer >/dev/null 2>&1 & 
	brew install -s $(FORMULA)
	@killall -KILL python

clean: ## clean this project
	rm -f $(OBJ)

help: ## show this help dialog
	@echo
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
	@echo

.PHONY       : $(OBJ) all test brewtest install clean help
.NOTPARALLEL : $(OBJ) all test brewtest install clean help
.DEFAULT_GOAL: all
# vim: ts=4 sw=4 et
