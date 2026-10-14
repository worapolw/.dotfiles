# .dotfiles

My personal dev environment: fish, tmux, vim, eza, fzf, ripgrep, fastfetch, mise, Claude Code, plus terminal config (foot on Linux, kitty on macOS).

## Install

One-liner. No clone needed, since every config is downloaded from this repo's `main` branch:

```bash
curl -fsSL https://raw.githubusercontent.com/worapolw/.dotfiles/main/install.sh | bash
```

> The script uses `sudo` to install packages, so it will ask for your password.
> Read [`install.sh`](install.sh) before you pipe it into bash.

Or from a clone:

```bash
git clone https://github.com/worapolw/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./install.sh
```

### Supported platforms

| OS     | Package manager             | Terminal |
| ------ | --------------------------- | -------- |
| Fedora | `dnf`                       | foot     |
| Ubuntu | `apt` (+ PPAs for fish 4, fastfetch, eza) | foot     |
| macOS  | Homebrew (`Brewfile`)       | kitty    |

## What it does

- **Packages**: fish, fzf, ripgrep, vim, tmux, eza, bat, fastfetch, git
- **Fonts**: Symbols Nerd Font (Linux; via cask on macOS). The terminal configs expect **Berkeley Mono**, which isn't free, so install it yourself.
- **Terminal**: foot config, set as the default terminal (Linux), or kitty config (macOS)
- **mise**: installed to `~/.local/bin`, activated in bash and fish, with shell completions
- **fish**: custom prompt, `ls` → `eza`, fastfetch login greeting with a cat logo
- **tmux**: [tpm](https://github.com/tmux-plugins/tpm) + `.tmux.conf`, with fish as the default shell
- **git**: `~/.gitconfig`
- **vim**: [vim-plug](https://github.com/junegunn/vim-plug), `.vimrc` and after/ plugin & ftplugin configs
- **Claude Code**: installs it and sets up the custom status line (`~/.claude/statusline.sh`)

## After installing

1. Log out and back in, or open a new terminal, to pick up fish, fonts and mise.
2. In tmux, press `prefix` + `I` to install tmux plugins.
3. In vim, run `:PlugInstall`.

> **Note:** the script overwrites some files, including `~/.gitconfig`, `~/.vimrc`, `~/.tmux.conf` and the fish/fastfetch configs. Back up anything you want to keep first.
