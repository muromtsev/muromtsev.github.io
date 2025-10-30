#!/usr/bin/env bash

# Установка зависимостей Jekyll
bundle install

# Настройка Git
git config --global --add safe.directory /workspaces/muromtsev.github.io

# Права доступа
sudo chown -R vscode:vscode /workspaces/muromtsev.github.io

# Node.js зависимости (если нужны)
if [ -f package.json ]; then
  bash -i -c "nvm install --lts && nvm install-latest-npm"
  npm i
  npm run build
fi

# Install dependencies for shfmt extension
curl -sS https://webi.sh/shfmt | sh &>/dev/null

# Add OMZ plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
sed -i -E "s/^(plugins=\()(git)(\))/\1\2 zsh-syntax-highlighting zsh-autosuggestions\3/" ~/.zshrc

# Avoid git log use less
echo -e "\nunset LESS" >>~/.zshrc

echo "Dev container setup complete!"