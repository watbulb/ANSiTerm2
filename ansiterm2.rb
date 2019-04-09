cask 'ansiterm2' do
    version '0.1b'
    sha256 '37c8d10fec7943a993b388843dbd1a132976bf5cc6d92a5d8df70822222e2184'

    url "https://github.com/watbulb/ANSiTerm2/releases/download/#{version}/ansiterm2.pkg"
    appcast 'https://github.com/watbulb/ANSiTerm2/releases.atom'
    name 'ANSiTerm2'
    homepage 'https://github.com/watbulb/ANSiTerm2'
    
    # mavericks or above is required for iTerm2
    depends_on macos: '>= :mavericks'

    # ANSiTerm2 depends on the following for client modem functionality
    depends_on formula:  'telnet'
    depends_on formula:  'lrzsz'

    # Some users install iTerm2 from it's website, so it won't show in installed Casks
    if not(Dir.exist?("/Applications/iTerm.app"))
        depends_on cask: 'iterm2'
    end
    
    # install secure signed (Apple Developer) package installer
    # note: this doesn't even need root, which makes it even more secure :)
    installer script: {
        executable: '/usr/sbin/installer',
        args:       ['-pkg', 'ansiterm2.pkg', '-target', 'CurrentUserHomeDirectory']
    }
    
    # remove pacakge by product-ids
    # note: unfortunately since brew doesn't support uninstalling HOME based
    #       packages, we have to rely on removing them manually, this is why brew is shit.
    uninstall delete: [
        '~/Library/Application Support/iTerm2/DynamicProfiles/sh.potato.ansiterm2.plist',
        '~/.config/ansiterm2'
    ]

end
