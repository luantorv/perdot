# BOOTSTRAP.md

This document describes **how to reproduce the perdot environment end-to-end** on a minimal Arch Linux installation, in an explicit, controlled manner without mandatory hidden abstractions.

The goal is not to automate everything, but rather **to clearly explain each step**: what it does, why it exists, and which parts are optional.

This accomplishes the same objectives as similar projects, but **transparently and without obfuscation**.

---

## 0. General Philosophy

perdot **is not a system installer** nor a graphical session manager.

* Does not modify getty automatically
* Does not edit your shell without notice
* Does not start Hyprland for you
* Does not assume you want a display manager

All that perdot does is:

> **orchestrate reproducible configurations**

Everything else is documented.

---

## 1. Expected Starting Point

Base system:

* Arch Linux (minimal installation)
* User created (non-root)
* Internet access
* TTY login functional

Recommended minimal packages:

```sh
pacman -S git base-devel
```

---

## 2. Clone the Repository

From your user account:

```sh
git clone https://github.com/USER/perdot.git
cd perdot
```

Do not copy individual files. perdot **requires a complete git repository**.

---

## 3. Install perdot

```sh
./bin/perdot install
```

This performs:

* Initializes `~/perdot/state`
* Prepares backups
* Creates the symlink `~/.local/bin/perdot`

After this:

```sh
perdot --help
```

If the command is not found, ensure that:

```sh
echo $PATH | grep .local/bin
```

If not present, add it manually to your shell.

---

## 4. Update Configurations

```sh
perdot update
```

This:

* Resolves installed package versions
* Applies corresponding configurations
* Creates backups when necessary

Optional:

```sh
perdot update --packages --services --verbose
```

Nothing is installed or restarted without explicit flags.

---

## 5. User Environment Setup

```sh
perdot setup
```

This prepares:

* Required systemd --user units
* Runtime directories
* Auxiliary links

⚠ **Important**: perdot does NOT start graphical services or sessions.

---

## 6. Start Hyprland (Manual)

From the TTY:

```sh
Hyprland
```

If everything is correct:

* The session should start
* EWW, mako, swww, etc. should load

If something fails:

```sh
perdot doctor --verbose
```

---

## 7. (Optional) Display Manager

perdot **does not install or configure display managers automatically**.

If you want a managed login experience, you can set this up yourself:

### Option A: greetd

```sh
pacman -S greetd greetd-tuigreet
```

Configure `/etc/greetd/config.toml`:

```toml
[default_session]
command = "Hyprland"
user = "YOUR_USER"
```

Enable:

```sh
sudo systemctl enable greetd
```

---

### Option B: SDDM (less recommended)

```sh
pacman -S sddm
sudo systemctl enable sddm
```

Configure Hyprland session manually.

---

## 8. (Optional) Explicit Automation

If you want to replicate a *ready-at-boot* experience:

* Display manager enabled
* Hyprland as default session
* User services enabled

None of this is done by perdot automatically.

This is **a conscious decision**, not a limitation.

---

## 9. Final Verification

```sh
perdot status
perdot doctor
```

If both succeed:

* The environment is correctly reproduced
* Future updates are performed with `perdot update`

---

## 10. Quick Summary

| Step | Action            |
| ---: | ----------------- |
|    1 | Clone repository  |
|    2 | `perdot install`  |
|    3 | `perdot update`   |
|    4 | `perdot setup`    |
|    5 | Start Hyprland    |
|    6 | (Optional) DM     |

---

If you were looking for a magic installer, this is not it.
If you were looking for control, reproducibility, and transparency: welcome.