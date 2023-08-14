#!/bin/sh

echo "Generating a new SSH key for GitHub..."

ssh-keygen -t ed25519 -C $EMAIL -f ~/.ssh/id_ed25519

eval "$(ssh-agent -s)"

touch ~/.ssh/config
echo "Host *\n AddKeysToAgent yes\n UseKeychain yes\n IdentityFile ~/.ssh/id_ed25519" | tee ~/.ssh/config

ssh-add -K ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub | pbcopy

echo "run 'pbcopy < ~/.ssh/id_ed25519.pub' and paste that into GitHub"
echo "Then run ssh -T git@github.com"
