class Ansiterm2 < Formula
    desc "
    ANSiTerm2 is a set of configurations, triggers and patches
    that turn iTerm2 into a fully fledged modern BBS client, modem support included!
    The last hope for a working and maintainable modern BBS client for macOS.

    Author:   Dayton Pidhirney (watbulb)
    "
    homepage "telnet://bbs.potato.sh:2323"
    url      "http://localhost:8000/ansiterm2.tar.gz"
    version  "0.1a"
    sha256   "880e4c1e0dd19f011ff7778b3b42fe1580e196a2cb6c22a11694d70bfd0a15c7"
    bottle   :unneeded
    
    # telnet is required for connecting to remote terminals
    depends_on "telnet"

    # lrzsz is required for zmodem transfers
    depends_on "lrzsz"
    
    def install	    
        # @XXX: rather poor way to check for Cask dependency
        #		since brew doesn't support formulas which depend
        #       on Casks, sadly...
	  	system "/usr/local/bin/brew", "cask", "install", "iterm2"
	  	
	  	# install ANSiTerm2 to formula share
        share.mkpath
        share.install "font"
        share.install "trigger"
        share.install "profile"
    	
        # install Amiga fonts:
        # @XXX: a Cask is required to write to ~/Library/Fonts
        #       so for now we just prompt the user to install them
        #		if they don't yet exist
        username   = ENV["USER"]
        fontprompt = false
    	Dir.glob("font/*.ttf") { |file|
	    	if not(File.exist?("/Users/#{username}/Library/Fonts/#{file}"))
	    		%x(open font/#{file})
	    		fontprompt = true
			end
    	}

        if(fontprompt)
            # prompt for font installation and iTerm2 configuration documentation
        	puts
        	puts "Some FontBook window(s) should have appeared!"
        	puts "Please install the desired Amiga fonts into your system!"
        	puts '(simply click "Install Font" in each window for the fonts you want to install)'
        end
        
        puts
        puts "Please run the following command to 'activate' or 'update' ANSiTerm2:"
        puts "cp #{share}/profile/* ~/Library/Application\\ Support/iTerm2/DynamicProfiles/"
        puts
        puts "ANSiTerm2 can be activated once iTerm2 is opened by pressing ctrl+cmd+0"
        puts
    end
end

# vim: ts=4 sw=4 et
