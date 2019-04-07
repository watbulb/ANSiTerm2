class Ansiterm2 < Formula
    desc "
    ANSiTerm2 is a set of configurations, triggers and patches
    that turn iTerm2 into a fully fledged modern BBS client, modem support included!
    The last hope for a working and maintainable modern BBS client for macOS.

    Author:   Dayton Pidhirney (watbulb)
    "
    homepage "https://www.phenomprod.com/"
    url      "https://github.com/watbulb/ANSiTerm2/releases/download/#{version}/ansiterm2.tar.gz"
    version  "0.1a-rc1"
    sha256   "024b507f811c3b0b80329a55e88c9765339c9a5d34d87fc8f7ac864ba79718b5"
    bottle   :unneeded
    
    # lrzsz is required for zmodem transfers
    depends_on "lrzsz"
    
    # telnet is required for connecting to remote terminals
    depends_on "telnet"
    
    def install	    
        # @XXX: rather poor way to check for Cask dependency
        #       since brew doesn't support formulas which depend
        #       on Casks, sadly...
	  	system "/usr/local/bin/brew", "cask", "install", "iterm2"
    	
        # install Amiga fonts:
        # @XXX: a Cask is required to write to ~/Library/Fonts
        #       so for now we just prompt the user to install topaz
        #		if it doesn't yet exist
        username   = ENV["USER"]
        fontprompt = false
	    if not(File.exist?("/Users/#{username}/Library/Fonts/TopazPlus_a1200_v1.0.ttf"))
	    	%x(open font/TopazPlus_a1200_v1.0.ttf)
	    	fontprompt = true
		end
    	
    	# replace the dynamic_profile username in the ANSiTerm2 profile
    	profile = "profile/sh.potato.ansiterm2.plist"
    	IO.write(profile, File.open(profile) do |f|
            f.read.gsub("replacement_user", username)
        end)
    	
        # install ANSiTerm2 to formula share
        share.mkpath
        share.install "doc"
        share.install "font"
        share.install "trigger"
        share.install "profile"
    	
    	# prompt for font installation and iTerm2 configuration documentation
        if(fontprompt)
            puts
            puts "A FontBook window should have appeared!"
            puts "Please install the required Amiga font onto your system!"
            puts '(simply click "Install Font" within the FontBook window)'
        end
        
        puts
        puts "Please run the following command to 'activate' or 'update' ANSiTerm2:"
        puts "cp #{share}/profile/* ~/Library/Application\\ Support/iTerm2/DynamicProfiles/"
        puts
        puts "ANSiTerm2 can be activated once iTerm2 is opened by pressing CTRL+CMD+0"
        puts
    end
end

# vim: ts=4 sw=4 et
