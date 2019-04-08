#!/bin/sh

INSTALLED="$(osascript -e 'tell application "iTerm2" to version')"
FILE=$(
osascript -e 'tell application "iTerm2" to activate' \
          -e 'tell application "iTerm2" to set thefile to choose folder with prompt "Choose a folder to place received files in"' \
          -e "do shell script (\"echo \"&(quoted form of POSIX path of thefile as Unicode text)&\"\")"
)

if [ ! "${INSTALLED}" ]; then
    echo "[-] FATAL: Somehow iTerm2 is not installed! Aborting!"
    exit 1
elif [ ! "${FILE}" ]; then
    # send zmodem cancel if user cancelled prompt
    print \\x18\\x18\\x18\\x18\\x18 && sleep 1
    echo; echo; echo
else
    cd "${FILE}" || :
    /usr/local/bin/rz -E -e -b && sleep 1
    echo; echo; echo
fi
