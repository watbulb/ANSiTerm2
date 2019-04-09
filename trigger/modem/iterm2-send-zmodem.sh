#!/bin/sh

INSTALLED="$(osascript -e 'tell application "iTerm2" to version')"
FILE=$(
osascript -e 'tell application "iTerm2" to activate' \
          -e 'tell application "iTerm2" to set thefile to choose file with prompt "Choose a file to send"' \
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
    /usr/local/bin/sz -q -E -e -b -8 "${FILE}" && sleep 1
    echo; echo; echo
fi
