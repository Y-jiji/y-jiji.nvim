# Neovim Config

Minimal Neovim configuration targeting terminal emulators with Kitty graphics protocol support (Kitty, Ghostty, WezTerm).

## Dependencies

### System packages

| Package | Provides | Used by |
|---------|----------|---------|
| [poppler](https://poppler.freedesktop.org/) | `pdftoppm`, `pdfinfo` | `lua/pdf.lua` — inline PDF viewer |
| [yazi](https://yazi-rs.github.io/) | `yazi` | `lua/yazi.lua` — file picker |
| [rust-analyzer](https://rust-analyzer.github.io/) | `rust-analyzer` | Rust LSP |
| [texlab](https://github.com/latex-lsp/texlab) | `texlab` | LaTeX LSP |
| [clangd](https://clangd.llvm.org/) | `clangd` | C/C++/CUDA LSP |
| [tinymist](https://github.com/Myriad-Dreamin/tinymist) | `tinymist` | Typst LSP |
| [lua-language-server](https://github.com/LuaLS/lua-language-server) | `lua-language-server` | Lua LSP |
| [cargo](https://doc.rust-lang.org/cargo/) | `cargo` | Build step for tinymist-kitty |

#### Arch Linux

```sh
pacman -S poppler yazi rust-analyzer texlab clangd lua-language-server
```

### Neovim

Requires **Neovim >= 0.10** (uses `vim.lsp.config`, `vim.base64`, treesitter `main` branch).

### Terminal

A terminal supporting **Kitty Unicode image placeholders** is required for inline image features (`pdf.lua`, `tinymist-kitty`):

- Kitty >= 0.28
- Ghostty
- WezTerm

These features do **not** work inside tmux.

## Plugins (managed by lazy.nvim)

| Plugin | Purpose |
|--------|---------|
| [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Syntax highlighting |
| [tinymist-kitty](https://github.com/Y-jiji/tinymist-kitty) | Inline Typst preview via Kitty protocol |
| [smear-cursor.nvim](https://github.com/sphamba/smear-cursor.nvim) | Animated cursor |
| [lean.nvim](https://github.com/Julian/lean.nvim) | Lean 4 support |

## Local modules (`lua/`)

| Module | Description |
|--------|-------------|
| `pdf.lua` | Inline PDF viewer using Kitty graphics protocol. Opens `.pdf` files with `nvim file.pdf` or `:e file.pdf`. Pages are converted lazily at 200 DPI. Navigate with `j`/`k` (next/prev page), `gg`/`G` (first/last), `q` (close). |
| `yazi.lua` | Yazi file picker integration (`<Space>-`). |

## Colorscheme

`brutal` — custom colorscheme in `colors/brutal.lua`. Treesitter highlighting is preferred; Vim syntax is used as fallback when no parser is available.
