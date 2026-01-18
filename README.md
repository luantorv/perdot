# PerDot

This is my Personal Dotfiles for a minimal recently [Arch Linux](https://wiki.archlinux.org/title/Arch_Linux) installation.

This might cause problems on Arch-based distributions or those with pre-existing configurations.

I'll maintain the repository and, if possible, add more features at my own pace.

## Philosophy

perdot is **not** a desktop environment, not a session manager,
and not a background service.

Its purpose is simple:

- manage configuration files via symlinks
- adapt configs to installed package versions
- prepare (but not control) the user session
- remain invisible once its job is done

perdot never runs as a daemon and does not own your system.
If perdot is removed, your system keeps working.

## Repository layout

```
perdot/
├── bin/                # Entry point (perdot command)
├── scripts/            # Internal logic (resolver, install, update, etc.)
├── files/              # Dotfiles and systemd units
│   ├── hyprland/
│   ├── kitty/
│   ├── zsh/
│   └── systemd/user/
├── mappings/           # Package → target path mappings
├── state/              # Runtime state (backups, logs, locks)
└── README.md
```

>[!IMPORTANT]
>The `state/` directory is runtime-only and can be safely deleted.

## Typical workflow

Clone the repository:

```sh
git clone https://github.com/luantorv/perdot.git ~/perdot
cd ~/perdot
```

Install perdot:

```sh
bin/perdot install
```

Prepare the user environment:

```sh
perdot setup
```

Update later:

```sh
perdot update
```

Check status:

```sh
perdot status
```

## systemd user services

perdot may provide minimal user systemd units when upstream
does not provide them or they are required for proper functionality.

These units are:
- minimal
- optional
- standard systemd user services

perdot only links and enables them.

>[!IMPORTANT]
> perdot does not create its own services.

## Tested stack

- Hyprland
- EWW
- Rofi
- Mako
- swww
- cliphist
- kitty
- zsh

Other setups may work but are not guaranteed.

## Disclaimer

This project is primarily designed for personal use.
Feel free to adapt it, fork it, or break it.

## Author:

Reis Viera, Luis
- GitHub: [@luantorv](https://github.com/luantorv/)
- Discord: [@luis_](https://discord.com/users/711613864386625618)