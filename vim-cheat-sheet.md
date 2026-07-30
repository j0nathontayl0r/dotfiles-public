# Vim Cheat Sheet -- UHK 2.0 (60% Keyboard)

> Printable quick-reference for Vim motions and commands on the Ultimate Hacking Keyboard 2.0.
> Covers Base, Mod, and Fn layer interactions.

---

## UHK Layer Reference (Defaults)

| UHK Combo          | Result       | UHK Combo          | Result       |
|---------------------|-------------|---------------------|-------------|
| `Mod + I`           | Up Arrow    | `Mod + Y`           | Page Up     |
| `Mod + K`           | Down Arrow  | `Mod + H`           | Page Down   |
| `Mod + J`           | Left Arrow  | `Mod + U`           | Home        |
| `Mod + L`           | Right Arrow | `Mod + O`           | End         |
| `Mod + ~` or `Mod + Q` | Escape  | `Mod + P`           | Delete      |
| `Mod + A`           | Caps Lock   | `Mod + ;`           | Insert      |
| `Mod + 1-9`         | F1-F9       | `Mod + 0 / - / =`  | F10/F11/F12 |

---

## Escaping (Critical on 60%)

| Action              | Keys                        | Notes                             |
|---------------------|-----------------------------|-----------------------------------|
| Exit Insert to Normal | `Mod + ~` or `Mod + Q`    | UHK Escape -- use whichever is comfortable |
| Exit Insert (alt)   | `Ctrl + [`                  | No layer needed -- fastest on 60% |
| Exit Insert (alt)   | `jj` or `jk` (if mapped)   | Add `inoremap jj <Esc>` to config |
| Exit Visual to Normal | `Mod + ~` / `Ctrl + [`    | Same as above                     |
| Close cmd-line / popup | `Mod + ~` / `Ctrl + [`   | Same as above                     |

> **Tip:** `Ctrl + [` is the single best habit on a 60% -- it's Escape without any layer.

---

## Modes

| Key         | Mode               | Key         | Mode               |
|-------------|---------------------|-------------|---------------------|
| `i`         | Insert (before cursor) | `v`      | Visual (char)       |
| `I`         | Insert (start of line) | `V`      | Visual (line)       |
| `a`         | Insert (after cursor)  | `Ctrl+v` | Visual (block)      |
| `A`         | Insert (end of line)   | `R`      | Replace mode        |
| `o`         | Open line below     | `:`         | Command-line        |
| `O`         | Open line above     | `/`         | Search forward      |

---

## Movement -- Basics

| Key         | Motion                     | Key         | Motion                    |
|-------------|----------------------------|-------------|---------------------------|
| `h`         | Left one char              | `0`         | Start of line             |
| `j`         | Down one line              | `^`         | First non-blank char      |
| `k`         | Up one line                | `$`         | End of line               |
| `l`         | Right one char             | `g_`        | Last non-blank char       |

> **No arrows needed** -- `hjkl` is on the base layer. Your hands never leave home row.

---

## Movement -- Words

| Key         | Motion                     | Key         | Motion                    |
|-------------|----------------------------|-------------|---------------------------|
| `w`         | Next word start             | `b`        | Previous word start       |
| `W`         | Next WORD start             | `B`        | Previous WORD start       |
| `e`         | Next word end               | `ge`       | Previous word end         |

---

## Movement -- Vertical / Scrolling

| Key           | Motion                    | UHK Equivalent        |
|---------------|---------------------------|-----------------------|
| `Ctrl + u`    | Half-page up              | (base layer)          |
| `Ctrl + d`    | Half-page down            | (base layer)          |
| `Ctrl + b`    | Full page up              | (base layer)          |
| `Ctrl + f`    | Full page down            | (base layer)          |
| `gg`          | Go to first line          | (base layer)          |
| `G`           | Go to last line           | (base layer)          |
| `{number}G`   | Go to line {number}      | (base layer)          |
| `{`           | Previous paragraph        | (base layer)          |
| `}`           | Next paragraph            | (base layer)          |
| `%`           | Jump to matching bracket  | (base layer)          |

> **Tip:** Prefer `Ctrl+u/d` over `Mod+Y/H` (Page Up/Down). Vim's half-page scroll keeps context.

---

## Movement -- Search / Find

| Key              | Motion                       |
|------------------|------------------------------|
| `f{char}`        | Jump **to** next {char}      |
| `F{char}`        | Jump **to** prev {char}      |
| `t{char}`        | Jump **until** next {char}   |
| `T{char}`        | Jump **until** prev {char}   |
| `;`              | Repeat last f/F/t/T          |
| `,`              | Repeat last f/F/t/T (reverse)|
| `/pattern`       | Search forward               |
| `?pattern`       | Search backward              |
| `n`              | Next search match            |
| `N`              | Previous search match        |
| `*`              | Search word under cursor (fwd)|
| `#`              | Search word under cursor (bck)|

---

## Operators (combine with motions)

| Key   | Operator       | Example         | Effect                        |
|-------|----------------|-----------------|-------------------------------|
| `d`   | Delete         | `dw`            | Delete word                   |
| `c`   | Change         | `ci"`           | Change inside quotes          |
| `y`   | Yank (copy)    | `yy`            | Yank entire line              |
| `>`   | Indent right   | `>}`            | Indent to next paragraph      |
| `<`   | Indent left    | `<}`            | Unindent to next paragraph    |
| `gu`  | Lowercase      | `guw`           | Lowercase word                |
| `gU`  | Uppercase      | `gUw`           | Uppercase word                |
| `=`   | Auto-indent    | `=G`            | Auto-indent to end of file    |

---

## Operator + Motion Combos (most used)

| Combo          | Effect                          |
|----------------|---------------------------------|
| `dd`           | Delete line                     |
| `cc`           | Change line                     |
| `yy`           | Yank line                       |
| `D`            | Delete to end of line           |
| `C`            | Change to end of line           |
| `Y`            | Yank line (same as `yy`)        |
| `x`            | Delete char under cursor        |
| `s`            | Delete char + enter insert      |
| `S`            | Delete line + enter insert      |
| `dw`           | Delete word                     |
| `cw`           | Change word                     |
| `diw`          | Delete inner word               |
| `ciw`          | Change inner word               |
| `daw`          | Delete a word (+ space)         |
| `di"`          | Delete inside `"`               |
| `ci(`          | Change inside `()`              |
| `da{`          | Delete around `{}`              |
| `dit`          | Delete inside HTML tag          |
| `yi'`          | Yank inside `'`                 |

---

## Text Objects (used with operators)

| Object   | Inner (`i`)            | Around (`a`)           |
|----------|------------------------|------------------------|
| `w`      | word                   | word + spaces          |
| `W`      | WORD                   | WORD + spaces          |
| `s`      | sentence               | sentence + space       |
| `p`      | paragraph              | paragraph + newline    |
| `"` `'` `` ` `` | inside quotes   | quotes + delimiters    |
| `(` `)`  | inside parens          | parens + delimiters    |
| `[` `]`  | inside brackets        | brackets + delimiters  |
| `{` `}`  | inside braces          | braces + delimiters    |
| `t`      | inside HTML/XML tag    | tag + delimiters       |

---

## Editing

| Key         | Action                        | Key         | Action                        |
|-------------|-------------------------------|-------------|-------------------------------|
| `p`         | Paste after                   | `u`         | Undo                          |
| `P`         | Paste before                  | `Ctrl + r`  | Redo                          |
| `J`         | Join line below               | `.`         | Repeat last change            |
| `r{char}`   | Replace single char           | `~`         | Toggle case of char           |
| `xp`        | Swap two characters           | `>>` / `<<` | Indent / unindent line        |

---

## Marks & Jumps

| Key           | Action                          |
|---------------|---------------------------------|
| `m{a-z}`      | Set local mark                  |
| `'{a-z}`      | Jump to mark (line)             |
| `` `{a-z} ``  | Jump to mark (exact position)   |
| `Ctrl + o`    | Jump to older position          |
| `Ctrl + i`    | Jump to newer position          |
| `''`          | Jump to last jump position      |
| `'.`          | Jump to last edit position      |
| `gd`          | Go to local definition (LSP)    |
| `gr`          | Go to references (LSP)         |

---

## Registers & Macros

| Key              | Action                          |
|------------------|---------------------------------|
| `"{reg}y`        | Yank into register {reg}        |
| `"{reg}p`        | Paste from register {reg}       |
| `"0p`            | Paste last yank (not delete)    |
| `"+y` / `"+p`    | System clipboard yank / paste   |
| `q{a-z}`         | Start recording macro           |
| `q`              | Stop recording macro            |
| `@{a-z}`         | Play macro                      |
| `@@`             | Repeat last macro               |
| `:reg`           | Show all registers              |

---

## Windows & Splits

| Key               | Action                         | Notes                       |
|--------------------|-------------------------------|-----------------------------|
| `Ctrl + w, s`     | Split horizontal               | base layer                  |
| `Ctrl + w, v`     | Split vertical                 | base layer                  |
| `Ctrl + w, q`     | Close split                    | base layer                  |
| `Ctrl + w, o`     | Close other splits             | base layer                  |
| `Ctrl + w, =`     | Equalize split sizes           | base layer                  |
| `Ctrl + h`        | Move to left split             | vim-tmux-navigator          |
| `Ctrl + j`        | Move to split below            | vim-tmux-navigator          |
| `Ctrl + k`        | Move to split above            | vim-tmux-navigator          |
| `Ctrl + l`        | Move to right split            | vim-tmux-navigator          |

> **Tip:** `Ctrl + h/j/k/l` seamlessly moves between Vim splits AND tmux panes with `vim-tmux-navigator`.

---

## Buffers & Tabs

| Command             | Action                      |
|---------------------|-----------------------------|
| `:e {file}`         | Open file in buffer         |
| `:bn` / `:bp`       | Next / previous buffer     |
| `:bd`               | Close buffer                |
| `:ls`               | List buffers                |
| `:tabnew {file}`    | Open file in new tab        |
| `gt` / `gT`         | Next / previous tab        |

---

## Command-Line Essentials

| Command             | Action                         |
|---------------------|--------------------------------|
| `:w`                | Save                           |
| `:q`                | Quit                           |
| `:wq` or `ZZ`      | Save & quit                    |
| `:q!` or `ZQ`      | Quit without saving            |
| `:x`                | Save (if changed) & quit       |
| `:%s/old/new/g`     | Replace all in file            |
| `:%s/old/new/gc`    | Replace all (confirm each)     |
| `:noh`              | Clear search highlight         |
| `:set number`       | Show line numbers              |
| `:!{cmd}`           | Run shell command              |

---

## LSP Keybindings (from your config)

| Key              | Action                       |
|------------------|------------------------------|
| `gd`             | Go to definition             |
| `gr`             | Go to references             |
| `K`              | Hover documentation          |
| `<Space>rn`      | Rename symbol                |
| `<Space>ca`      | Code action                  |
| `[d`             | Previous diagnostic          |
| `]d`             | Next diagnostic              |

---

## UHK 2.0 / Vim Interaction Tips

| Scenario                     | Avoid (layer required)     | Prefer (base layer)           |
|------------------------------|----------------------------|-------------------------------|
| Escape to Normal mode        | `Mod + ~` / `Mod + Q`     | **`Ctrl + [`**                |
| Navigate by page             | `Mod + Y/H` (PgUp/PgDn)   | **`Ctrl + u/d`** (half-page)  |
| Go to start / end of line    | `Mod + U/O` (Home/End)     | **`0` / `^` / `$`**          |
| Delete character             | `Mod + P` (Delete key)     | **`x`** in Normal mode        |
| Arrow key navigation         | `Mod + I/J/K/L`            | **`h/j/k/l`**                 |
| F-keys (e.g. for leader)     | `Mod + 1-9`               | Remap to `<Space>` leader     |
| Insert mode arrow nav        | `Mod + I/J/K/L`            | **Exit, navigate, re-enter**  |

> **Golden rule:** If you're reaching for the Mod layer, there's probably a Vim motion that does it better from the base layer.

---

## Recommended `init.lua` Additions for 60%

```lua
-- Fast escape from insert mode (no Mod layer needed)
vim.keymap.set("i", "jk", "<Esc>", { noremap = true })

-- Quick save
vim.keymap.set("n", "<leader>w", ":w<CR>")

-- Clear search highlight
vim.keymap.set("n", "<leader>h", ":noh<CR>")

-- Move lines up/down in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
```

---

## Vim Grammar Cheat Formula

```
[count] [operator] [motion/text-object]
```

| Example     | Read as                               |
|-------------|---------------------------------------|
| `3dw`       | 3x delete word                       |
| `ci"`       | change inside double quotes           |
| `y2j`       | yank 2 lines down                     |
| `d/foo`     | delete until "foo"                    |
| `>ip`       | indent inner paragraph                |
| `gUiw`      | uppercase inner word                  |
| `2dd`       | delete 2 lines                        |
| `ct)`       | change until closing paren            |
| `vip`       | visually select inner paragraph       |
| `=at`       | auto-indent around HTML tag           |

---

*Generated for UHK 2.0 + Neovim -- `Ctrl+[` is your best friend on 60% -- Leader = `Space`*
