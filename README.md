# PerDot

This is my Personal Dotfiles for a minimal recently [Arch Linux](https://wiki.archlinux.org/title/Arch_Linux) installation.

This might cause problems on Arch-based distributions or those with pre-existing configurations.

I'll maintain the repository and, if possible, add more features at my own pace.

## Instalation

```bash
git clone --depth 1 https://github.com/luantorv/perdot.git ~/perdot
cd ~/perdot
chmod +x ./bin/* ./scripts/*.sh
./bin/perdot
```

## Update flow

`perdot update` will:
1. Pull latest changes from the dotfiles repository
2. Resolve configurations against installed package versions
3. Apply only relevant configuration updates

Backups are stored under:
`state/backups/<timestamp>/`

Manual rollback can be done by restoring files from that directory.

## perdot doctor

Checks system readiness without applying any changes.

Examples:
- `perdot doctor`
- `perdot doctor --strict`
