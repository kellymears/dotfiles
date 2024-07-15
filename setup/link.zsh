local dotfiles_dir=$HOME/.dotfiles
local vscode_user_dir=$HOME/Library/Application\ Support/Code/User

ln -s $dotfiles_dir/.zshrc                         $HOME/.zshrc
ln -s $dotfiles_dir/config/.ackrc                  $HOME/.ackrc
ln -s $dotfiles_dir/config/.gitconfig              $HOME/.gitconfig
ln -s $dotfiles_dir/config/.gitignore              $HOME/.gitignore
ln -s $dotfiles_dir/config/.skhdrc                 $HOME/.skhdrc
ln -s $dotfiles_dir/config/.yabairc                $HOME/.yabairc
ln -s $dotfiles_dir/config/vscode/settings.json    $vscode_user_dir/settings.json
ln -s $dotfiles_dir/config/vscode/keybindings.json $vscode_user_dir/keybindings.json
