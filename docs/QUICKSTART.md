# perdot – Quickstart

This guide explains how to reproduce the perdot environment from scratch
on a minimal Arch Linux installation.

>[!TIP]
> For faster instalation: [BOOTSTRAP.md](https://github.com/luantorv/perdot/blob/main/docs/BOOTSTRAP.md)

## Requirements

- Arch Linux (minimal install)
- Internet connection
- git

## 1. Clone the repository

```sh
git clone https://github.com/usuario/perdot.git
cd perdot
```

## 2. Install perdot

```sh
./bin/perdot install
```

This will:

- install perdot globally in ~/.local/bin
- initialize internal state
- apply base configurations

## 3. Update configurations

```sh
perdot update
```

Optional flags:
- `--packages`
- `--services`
- `--verbose`

## 4. Setup user environment

```sh
perdot setup
```

This prepares:
- systemd user services
- autostart components
- runtime requirements

## 5. Start Hyprland

perdot does NOT start graphical sessions.

From TTY, run:

```sh
hyprland
```

or configure a display manager manually.