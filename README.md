# macbe-keyboard

A Belgian keyboard layout for Linux (KDE Plasma on Wayland) that matches the
**Mac Belgian keyboard**, for example on a Debian VM running on a MacBook.

It starts from the standard Belgian layout and changes only what differs on the Mac:

| Key / combination   | Gives |
|---------------------|-------|
| Top-left key        | `@`   |
| Shift + top-left    | `#`   |
| Option + `(`        | `{`   |
| Option + Shift + `(`| `[`   |
| Option + `)`        | `}`   |
| Option + Shift + `)`| `]`   |
| Option + Shift + L  | `\|`  |
| Option + N, Space   | `~`   |
| Option + Shift + `:`| `\`   |

The layout is installed in your home folder (`~/.config/xkb/symbols/macbe`), so it
needs no root access and system updates won't overwrite it.

## Install

```bash
git clone https://github.com/<you>/macbe-keyboard.git
cd macbe-keyboard
./install.sh
```

Or with [go-task](https://taskfile.dev):

```bash
task install          # VM on a Mac (top-left key swapped), the default
task install:native   # keyboard that sends the keys normally
task uninstall        # back to the standard Belgian layout
```

If the keys don't change right away, log out and back in.

### Options

```
./install.sh [--variant swapped|basic] [--alt any|right]
./install.sh --uninstall
```

- `--variant swapped` (default): for VMs (UTM, Parallels, VMware) that swap the
  top-left `@` key with the `< >` key next to left Shift.
- `--variant basic`: for keyboards that send these keys normally.
- `--alt any` (default): either Option key types the extra characters. Shortcuts
  that use left Alt, such as menu accelerators, may stop working.
- `--alt right`: only the right Option key types the extra characters.

The script replaces the layout list and the keyboard options in `~/.config/kxkbrc`.

### Which variant do I need?

Run `wev` (`sudo apt install wev`) and press the top-left key:

- `sym: twosuperior` means use `--variant basic`.
- `sym: less` means use `--variant swapped`.

## Adding keys

Edit `symbols/macbe` and run `./install.sh` again. Each key lists its characters as
`[ plain, Shift, Option, Option+Shift ]`, for example:

```
key <AC09> { [ l, L, notsign, bar ] };   // Option+Shift+L = |
```

`task check` tests that the file compiles (needs `sudo apt install libxkbcommon-tools`).

## Notes

- KDE's layout picker only lists the layouts that come with the system, so `macbe`
  won't appear there. If you change layouts in System Settings and press Apply, run
  `./install.sh` again.
- Tested on Debian 13 (trixie), KDE Plasma 6, Wayland.
