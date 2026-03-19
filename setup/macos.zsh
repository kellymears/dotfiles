###############################################################################
# Keyboard & Input                                                            #
###############################################################################

# KeyRepeat — how fast a held key repeats characters.
# Each unit ≈ 15 ms. Lower = faster. System Preferences bottoms out at 2.
#
#   1  = ~15 ms  (fastest possible — may double-strike on some keyboards)
#   2  = ~30 ms  (fastest safe value)                  ← current
#   6  = ~90 ms  (macOS default)
#  10  = ~150 ms
#
# Why: Anything above 2 feels sluggish for Vim-style hjkl navigation.
# Recommended: 2
defaults write NSGlobalDomain KeyRepeat -int 2

# InitialKeyRepeat — delay before a held key starts repeating.
# Each unit ≈ 15 ms. System Preferences bottoms out at 15.
#
#  10  = ~150 ms (very short — easy to trigger accidental repeats)
#  15  = ~225 ms                                       ← current
#  25  = ~375 ms (macOS default)
#  35  = ~525 ms
#
# Why: The default 375 ms pause before repeat kicks in feels laggy.
# Recommended: 15 — responsive without accidental repeats.
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# com.apple.keyboard.fnState — what the Fn key row does by default.
#
#   true  = F1–F12 act as function keys; hold Fn for media controls  ← current
#   false = F1–F12 act as media/brightness keys; hold Fn for F-keys  (macOS default)
#
# Why: IDEs, terminals, and Vim all bind F-keys. Media keys are easy to
#      reach via Fn, but reachable F-keys need no modifier.
# Recommended: true
defaults write NSGlobalDomain com.apple.keyboard.fnState -bool true

# AppleKeyboardUIMode — full keyboard access in dialogs and controls.
# Allows Tab/Shift-Tab to navigate all controls (buttons, checkboxes, etc.),
# not just text fields and lists.
#
#   0  = text fields & lists only (macOS default)
#   2  = all controls (macOS Sonoma+ setting)
#   3  = all controls (works on older macOS too)       ← current
#
# Why: Without this, Tab skips buttons in Save/Cancel dialogs. With it,
#      you can confirm or dismiss any dialog without touching the mouse.
# Recommended: 3 — broadest compatibility across macOS versions.
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# ApplePressAndHoldEnabled — press-and-hold behavior for character keys.
#
#   true  = show accent/character picker popup (é, ñ, ü…)  ← current
#   false = key repeat on hold (no accent picker)
#
# Why: Most "developer defaults" lists set false to enable key repeat
#      everywhere. However, key repeat already works with the KeyRepeat
#      setting above — this only controls whether the accent picker appears.
#      If you type in multiple languages, keep true. If you never need
#      accented characters, false removes the picker popup.
# Recommended: true if multilingual; false if English-only.
defaults write -g ApplePressAndHoldEnabled -bool true

# com.apple.trackpad.scaling — trackpad tracking speed.
#
#   0.0 = slowest
#   1.0 = macOS default
#   3.0 = maximum                                      ← current
#
# Why: Max speed minimizes wrist movement on large displays.
# Recommended: 3 — adjust down if you need pixel-precise work.
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3

# NSAutomaticSpellingCorrectionEnabled — auto-correct misspelled words.
#
#   true  = macOS silently replaces words it thinks are wrong (macOS default)
#   false = no auto-correction                         ← current
#
# Why: Auto-correct fights you in terminals, code editors, and Markdown.
#      It also silently changes technical terms and variable names.
# Recommended: false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# NSAutomaticCapitalizationEnabled — auto-capitalize first letter of sentences.
#
#   true  = capitalize automatically (macOS default)
#   false = no auto-capitalization                     ← current
#
# Why: Interferes with writing code, CLI commands, and filenames.
# Recommended: false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# NSAutomaticDashSubstitutionEnabled — replace -- with em-dash (—).
#
#   true  = smart dashes on (macOS default)
#   false = literal dashes preserved                   ← current
#
# Why: Breaks CLI flags (--verbose → —verbose), Markdown, and code.
# Recommended: false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# NSAutomaticPeriodSubstitutionEnabled — double-space inserts a period.
#
#   true  = double-space → ". " (macOS default)
#   false = double-space stays as two spaces            ← current
#
# Why: Unexpected in any context where double-space is intentional
#      (Markdown line breaks, code formatting).
# Recommended: false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# NSAutomaticQuoteSubstitutionEnabled — replace straight quotes with curly.
#
#   true  = "smart quotes" on (macOS default)
#   false = literal straight quotes preserved           ← current
#
# Why: Curly quotes break shell commands, JSON, code, and config files.
#      Possibly the most dangerous auto-substitution for developers.
# Recommended: false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

###############################################################################
# Dock & Mission Control                                                      #
###############################################################################

# autohide — automatically hide and show the Dock.
#
#   true  = Dock hides when not in use                 ← current
#   false = Dock always visible (macOS default)
#
# Why: Reclaims ~70px of screen real estate on every display.
# Recommended: true
defaults write com.apple.dock autohide -bool true

# autohide-delay — seconds before the Dock appears when you hover the edge.
#
#   0      = instant, no delay                         ← current
#   0.5    = macOS default
#   1000   = effectively disabled (hidden forever)
#
# Why: The default 0.5s delay makes the Dock feel unresponsive.
#      0 makes it appear the instant your cursor hits the edge.
# Recommended: 0
defaults write com.apple.dock autohide-delay -float 0

# tilesize — Dock icon size in pixels.
#
#   16–128 valid range
#   48     = macOS default
#   65     = slightly larger than default              ← current
#
# Why: Larger icons are easier to identify at a glance.
# Recommended: 48–65, depending on display size and icon count.
defaults write com.apple.dock tilesize -int 65

# mineffect — animation when minimizing windows.
#
#   "genie" = the wobbly genie lamp effect (macOS default)
#   "scale" = simple scale-down animation              ← current
#   "suck"  = hidden option — vortex/drain effect (not in System Preferences)
#
# Why: Scale is the fastest and least distracting animation.
# Recommended: "scale"
defaults write com.apple.dock mineffect -string "scale"

# minimize-to-application — where minimized windows go.
#
#   true  = minimize into the app's Dock icon          ← current
#   false = minimize to a separate section on the right side of the Dock (macOS default)
#
# Why: Keeps the Dock tidy — minimized windows don't sprawl across it.
# Recommended: true
defaults write com.apple.dock minimize-to-application -bool true

# show-recents — show recently opened apps in the Dock.
#
#   true  = show a "Recent Applications" section (macOS default)
#   false = hide recent apps                           ← current
#
# Why: Recent apps clutter the Dock with transient icons. If you want
#      an app in the Dock, pin it deliberately.
# Recommended: false
defaults write com.apple.dock show-recents -bool false

# show-process-indicators — dots under running apps in the Dock.
#
#   true  = show dots                                  ← current (macOS default)
#   false = no indicator for running apps
#
# Why: Without indicators it's hard to tell what's actually running.
# Recommended: true
defaults write com.apple.dock show-process-indicators -bool true

# showhidden — dim icons of hidden (Cmd+H) applications.
#
#   true  = translucent icons for hidden apps          ← current
#   false = all icons fully opaque (macOS default)
#
# Why: Visual feedback for which apps are hidden vs. visible.
# Recommended: true
defaults write com.apple.dock showhidden -bool true

# mru-spaces — auto-rearrange Spaces based on most recent use.
#
#   true  = Spaces reorder themselves automatically (macOS default)
#   false = Spaces stay in the order you arranged them ← current
#
# Why: Auto-rearranging makes spatial memory useless. "Desktop 3"
#      should always be Desktop 3, not whatever you used last.
# Recommended: false
defaults write com.apple.dock mru-spaces -bool false

# expose-group-apps — group windows by application in Mission Control.
#
#   true  = windows grouped by app                     ← current
#   false = all windows shown individually (macOS default)
#
# Why: Grouping makes it easier to find the right window when many
#      are open — you see app clusters instead of a wall of rectangles.
# Recommended: true
defaults write com.apple.dock expose-group-apps -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# AppleShowAllFiles — show hidden files (dotfiles) in Finder.
#
#   true  = show dotfiles and hidden files             ← current
#   false = hide them (macOS default)
#
# Why: Developers need to see .gitignore, .env, .zshrc, etc.
#      Toggle on-the-fly with Cmd+Shift+. in any Finder window.
# Recommended: true
defaults write com.apple.finder AppleShowAllFiles -bool true

# AppleShowAllExtensions — always show file extensions.
#
#   true  = extensions always visible                  ← current
#   false = extensions hidden for "known" types (macOS default)
#
# Why: Hiding extensions is a security risk (malware.app looks like
#      malware.pdf) and causes confusion when files share a name.
# Recommended: true
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# _FXShowPosixPathInTitle — show the full POSIX path in the Finder title bar.
#
#   true  = title shows /Users/you/Documents/…        ← current
#   false = title shows just the folder name (macOS default)
#
# Why: Eliminates ambiguity when multiple folders share the same name.
# Recommended: true
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# _FXSortFoldersFirst — sort folders above files in Finder.
#
#   true  = folders come first                         ← current
#   false = folders and files sort together alphabetically (macOS default)
#
# Why: Mirrors the convention of every file manager on Linux and Windows.
#      Makes directory structures easier to scan.
# Recommended: true
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# FXEnableExtensionChangeWarning — warn when changing a file extension.
#
#   true  = show "Are you sure?" dialog (macOS default)
#   false = no warning                                 ← current
#
# Why: The warning is redundant if you know what you're doing. You can
#      always undo a rename with Cmd+Z.
# Recommended: false
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# QuitMenuItem — allow quitting Finder via Cmd+Q.
#
#   true  = Cmd+Q quits Finder (it relaunches automatically) ← current
#   false = Finder has no Quit menu item (macOS default)
#
# Why: Lets you restart Finder quickly to pick up config changes,
#      and treats it consistently with every other app.
# Recommended: true
defaults write com.apple.finder QuitMenuItem -bool true

# ShowPathbar — show the path bar at the bottom of Finder windows.
#
#   true  = path bar visible                           ← current
#   false = hidden (macOS default)
#
# Why: Clickable breadcrumb trail showing the full directory hierarchy.
#      Double-click any segment to jump there.
# Recommended: true
defaults write com.apple.finder ShowPathbar -bool true

# ShowStatusBar — show the status bar at the bottom of Finder windows.
#
#   true  = status bar visible                         ← current
#   false = hidden (macOS default)
#
# Why: Shows item count and available disk space at a glance.
# Recommended: true
defaults write com.apple.finder ShowStatusBar -bool true

# WarnOnEmptyTrash — confirm before emptying the Trash.
#
#   true  = show "Are you sure?" dialog (macOS default)
#   false = empty immediately                          ← current
#
# Why: The Trash is itself the safety net — a second confirmation adds
#      friction without meaningful protection.
# Recommended: false
defaults write com.apple.finder WarnOnEmptyTrash -bool false

# FXDefaultSearchScope — default search scope when searching in Finder.
#
#   "SCev" = This Mac (searches the entire machine)    ← current
#   "SCcf" = Current Folder (scoped to the open folder)
#   "SCsp" = Previous Scope (remembers last choice)
#
# Why: "This Mac" finds files regardless of where you are. Some developers
#      prefer "SCcf" to avoid noise from unrelated directories.
# Recommended: "SCcf" for project-focused work; "SCev" if you often
#   search for files whose location you don't know.
defaults write com.apple.finder FXDefaultSearchScope -string "SCev"

# FXPreferredViewStyle — default Finder view mode.
#
#   "icnv" = Icon View
#   "Nlsv" = List View
#   "clmv" = Column View                              ← current
#   "Flwv" = Cover Flow / Gallery View
#
# Why: Column View shows the directory hierarchy spatially and lets you
#      drill into nested folders without opening new windows.
# Recommended: "clmv" — best for navigating deep directory trees.
defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

# FXInfoPanesExpanded — which panes are expanded by default in Get Info.
# Saves a few clicks when you open File → Get Info (Cmd+I).
#
#   General    = file size, created/modified dates
#   OpenWith   = default app association
#   Privileges = read/write permissions
#
# Why: These three panes are the most commonly needed. The rest
#      (e.g. Preview, Comments) stay collapsed until you need them.
defaults write com.apple.finder FXInfoPanesExpanded -dict \
  General    -bool true \
  OpenWith   -bool true \
  Privileges -bool true

# DSDontWriteNetworkStores — prevent .DS_Store files on network volumes.
#
#   true  = no .DS_Store on network mounts             ← current
#   false = write .DS_Store everywhere (macOS default)
#
# Why: .DS_Store files on shared drives pollute other users' views
#      and cause noise in version control on network-mounted repos.
# Recommended: true
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# DSDontWriteUSBStores — prevent .DS_Store files on USB volumes.
#
#   true  = no .DS_Store on USB drives                 ← current
#   false = write .DS_Store everywhere (macOS default)
#
# Why: Same rationale as network stores — keeps external drives clean.
# Recommended: true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

###############################################################################
# Screenshots                                                                 #
###############################################################################

# location — where screenshots are saved.
#
#   macOS default: ~/Desktop
#   current:       ~/Documents/screenshots
#
# Why: Screenshots clutter the Desktop. A dedicated folder keeps them
#      organized and easy to find.
# Recommended: ~/Documents/screenshots or ~/Pictures/screenshots
defaults write com.apple.screencapture location -string "${HOME}/Documents/screenshots"

# disable-shadow — remove the drop shadow from window screenshots.
#
#   true  = no shadow (clean, transparent edges)       ← current
#   false = include the macOS window shadow (macOS default)
#
# Why: The shadow adds ~40px of padding on all sides and looks bad
#      when pasted onto non-white backgrounds (docs, Slack, PRs).
# Recommended: true
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Windows & Dialogs                                                           #
###############################################################################

# NSNavPanelExpandedStateForSaveMode / …2 — expand Save dialogs by default.
# (Both keys are needed — apps may check either one.)
#
#   true  = Save dialog opens in expanded (full Finder) mode ← current
#   false = Save dialog opens in compact mode (macOS default)
#
# Why: The compact Save dialog hides the file browser, forcing you to
#      click the disclosure arrow every time. Expanded mode shows the
#      full directory tree immediately.
# Recommended: true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# NSDocumentSaveNewDocumentsToCloud — default save location.
#
#   true  = new documents default to iCloud Drive (macOS default)
#   false = new documents default to local disk        ← current
#
# Why: Local-first avoids surprise iCloud syncs, storage limits, and
#      latency when saving. You can always choose iCloud explicitly.
# Recommended: false
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

# NSQuitAlwaysKeepsWindows — Resume (reopen windows on app launch).
#
#   true  = restore previous windows on launch (macOS default)
#   false = start fresh                                ← current
#
# Why: Resume can reopen dozens of stale windows and slows down app
#      launch. For apps where you want restore (e.g. Terminal), the
#      app's own preferences handle it.
# Recommended: false
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

# AppleFontSmoothing — subpixel font rendering / font smoothing level.
#
#   0  = none (sharp, may look jagged on non-Retina)
#   1  = light
#   2  = medium
#   3  = strong (heavy smoothing)                      ← current
#
# Note: On Apple Silicon with Retina displays, the visible difference
#       between 1–3 is negligible. This mainly helps on external
#       non-Retina monitors.
# Why: Strong smoothing improves text clarity on non-Apple LCDs.
# Recommended: 3
defaults write NSGlobalDomain AppleFontSmoothing -int 3

###############################################################################
# Developer & Utilities                                                       #
###############################################################################

# CrashReporter DialogType — what happens when an app crashes.
#
#   "none"      = silently ignore crashes              ← current
#   "basic"     = simple "Report" / "OK" dialog
#   "developer" = detailed crash report with stack trace
#   "server"    = headless logging (macOS Server)
#
# Why: Crash dialogs are disruptive during development when apps crash
#      frequently. Crash logs are still written to ~/Library/Logs/
#      DiagnosticReports/ regardless of this setting.
# Recommended: "none" if crashes are routine during development;
#   "developer" if you want to see stack traces immediately.
defaults write com.apple.CrashReporter DialogType -string "none"

# DevMode — allow Help Viewer windows to go behind other windows.
#
#   true  = Help Viewer is a normal, non-floating window ← current
#   false = Help Viewer always floats on top (macOS default)
#
# Why: The always-on-top behavior is infuriating when you're trying
#      to follow instructions and code at the same time.
# Recommended: true
defaults write com.apple.helpviewer DevMode -bool true

# RichText — TextEdit default document format.
#
#   0  = plain text (.txt)                             ← current
#   1  = rich text (.rtf) (macOS default)
#
# Why: TextEdit opens as a lightweight plain-text editor, useful for
#      quick notes and viewing config files without formatting noise.
# Recommended: 0
defaults write com.apple.TextEdit RichText -int 0

# LSQuarantine — the "Are you sure you want to open this application
# downloaded from the Internet?" dialog (Gatekeeper first-run prompt).
#
#   true  = show the quarantine dialog (macOS default)
#   false = suppress the dialog                        ← current
#
# Note: On Big Sur and later, this setting is increasingly unreliable.
#       macOS may still show the dialog for notarization checks regardless
#       of this preference. Use `xattr -d com.apple.quarantine <app>` for
#       individual apps if this doesn't take effect.
# Why: The dialog appears for every downloaded app and CLI tool.
# Recommended: false — but verify it works on your macOS version.
defaults write com.apple.LaunchServices LSQuarantine -bool false

###############################################################################
# Software Update & App Store                                                 #
###############################################################################

# AutoUpdate — automatically install app updates from the App Store.
#
#   true  = auto-update apps                           ← current
#   false = manual updates only (macOS default pre-Ventura)
#
# Why: Keeps apps patched without manual intervention.
# Recommended: true
defaults write com.apple.commerce AutoUpdate -bool true

# AutomaticCheckEnabled — check for macOS and app updates automatically.
#
#   true  = check in background                        ← current (macOS default)
#   false = never check
#
# Why: You want to know when updates are available, even if you don't
#      install them immediately.
# Recommended: true
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# AutomaticDownload — download updates in the background.
#
#   1  = download automatically                        ← current
#   0  = don't download until manually triggered
#
# Why: Updates are ready to install when you choose, without waiting
#      for the download.
# Recommended: 1
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# ConfigDataInstall — download apps purchased on other Macs.
#
#   1  = sync purchases automatically                  ← current
#   0  = don't sync
#
# Why: Keeps your Macs in sync without manually re-downloading apps.
# Recommended: 1
defaults write com.apple.SoftwareUpdate ConfigDataInstall -int 1

# CriticalUpdateInstall — install system data files and security updates.
#
#   1  = install automatically                         ← current
#   0  = manual only
#
# Why: Security patches should never wait for you to remember.
# Recommended: 1
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

###############################################################################
# Time Machine                                                                #
###############################################################################

# DoNotOfferNewDisksForBackup — suppress "Use this disk for backup?" prompts.
#
#   true  = don't prompt when new drives are connected ← current
#   false = prompt for every new drive (macOS default)
#
# Why: Plugging in a USB drive shouldn't trigger a Time Machine dialog
#      every time, especially for drives used for other purposes.
# Recommended: true
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
# Kill affected applications                                                  #
###############################################################################

APPS=(
  Finder
  Dock
  SystemUIServer
)

for APP in "${APPS[@]}"; do
  killall "$APP" &>/dev/null
done
