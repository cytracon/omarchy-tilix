# Tilix (Cytracon) — Omarchy plugin

Omarchy Quattro bar widget for **[Cytracon Tilix](https://github.com/cytracon/tilix)** `1.9.8-cytracon.12`.

This listing is a **Quickshell bar plugin**. It does **not** ship the GTK Tilix binary. Left-click opens a panel with the installed version; right-click launches Tilix when `~/.local/bin/tilix` is present.

## Install the plugin

```bash
omarchy plugin add https://github.com/cytracon/omarchy-tilix.git --enable
```

The widget lands in the left bar section. Move it in Omarchy bar settings.

## Remove the plugin

```bash
omarchy plugin remove io.github.cytracon.tilix
```

Removal deletes only the plugin checkout under `~/.config/omarchy/plugins/`. It does **not** uninstall Tilix or change `xdg-terminals.list`.

## Install Tilix (the terminal)

User-local, no root. On Omarchy:

```bash
omarchy install tilix
```

That writes `~/.local/libexec/tilix`, a Wayland wrapper at `~/.local/bin/tilix`, Hyprland rules, and `xdg-terminal-exec` keys so Super+Return can use Tilix. App docs: [cytracon/tilix](https://github.com/cytracon/tilix). Removing this plugin does not uninstall Tilix.

## What the panel shows

| Field | Typical value |
|-------|----------------|
| App | Tilix (Cytracon) |
| Version | `1.9.8-cytracon.12` |
| VTE | 0.84 |
| GTK | 3.24.52 |
| Session | Wayland, tiled Hyprland `terminal` tag |
| AI Tools (defaults) | Grok, Codex, Example (`ai-cli`) |
| Extra tools | Preferences → AI Tools (Add / Duplicate) |

Shops, bookmarks, and extra CLIs stay in the user's GSettings / `~/.config/tilix`. They are not part of this plugin.

## Cytracon Tilix 1.9.8-cytracon.12

Tiling GTK3 + VTE terminal forked for Omarchy / Hyprland:

- Native Arch/LDC build, `GDK_BACKEND=wayland`
- `xdg-terminal-exec` (`X-TerminalArg*`) so Omarchy can treat it as the default terminal
- Tiled windows (not the 875×600 `floating-window` dialog tag)
- Header: Bookmarks (`Ctrl+Shift+B`), AI (`Ctrl+Shift+A`), Ops (`Ctrl+Shift+Q`)
- Preferences → AI Tools: pipe-separated `name|start|resume {id}|list`
- Nautilus + Nemo “open here”
- Omarchy theme-set hook for the default profile
- Install prefix `~/.local` — no root

Upstream: [gnunn1/tilix](https://github.com/gnunn1/tilix) (MPL-2.0). This plugin is MIT.

## Security

- No install hooks, daemons, privilege escalation, or network clients
- No writes to Hyprland / GSettings / `xdg-terminals.list`
- Left-click only toggles the panel
- Right-click runs the fixed path `$HOME/.local/bin/tilix` when that file exists
- “Source” opens `https://github.com/cytracon/tilix` via `omarchy-launch-browser`

Omarchy plugins run unsandboxed. Review `Panel.qml` before enabling.

## License

MIT for this plugin. Cytracon Tilix remains MPL-2.0.
