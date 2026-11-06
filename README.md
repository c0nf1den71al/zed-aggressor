# Aggressor Script — Zed extension

Syntax highlighting and language support for **Cobalt Strike Aggressor Script**
(`.cna`) in the [Zed](https://zed.dev) editor.

Aggressor Script is built on the [Sleep](http://sleep.dashnine.org/) scripting
language, so this extension understands both: Sleep core syntax (scalars/arrays/
hashes, `sub`, closures, HOES object expressions, control flow, string
interpolation) **and** Aggressor's own top-level constructs (`on`, `alias`,
`ssh_alias`, `command`, `popup`/`menu`/`item`, `set`, `bind`, `import`).

The parser itself lives in the companion grammar, **`tree-sitter-aggressor`**
(shipped alongside this folder).

---

## What you get

- **Syntax highlighting** — keywords, Sleep/Aggressor built-in functions
  (`bshell`, `blog`, `beacon_command_register`, `data_query`, …) distinct from
  your own subs, Beacon arg variables (`$1`, `$2`, `@_`) called out, string
  interpolation (`$var`, `%h`, `@a`, and the padded `$[10]name` form), `\c`
  color codes, `&func` references, `[new Class: …]` / `[$obj method: …]`
  object expressions, and class/namespace names.
- **Comment toggling** with `#`.
- **Bracket matching & auto-close** for `{} [] ()` and quotes.
- **Auto-indentation** inside blocks, argument lists and object expressions.
- **Outline view / breadcrumbs** — every `sub`, `alias`, `command`, `on`,
  `set`, `popup`, menu `item`, and `bind` shows up in the symbol outline
  (`cmd-shift-o`).

---

## Install

```sh
git clone https://github.com/c0nf1den71al/zed-aggressor
# Zed → Extensions → Install Dev Extension → pick that folder
```

---

## Layout

```
zed-aggressor/
  extension.toml                  # manifest + grammar source
  setup-local.sh                  # wires in the local grammar via file://
  languages/
    aggressor/
      config.toml                 # file suffixes, comments, brackets, indent
      highlights.scm              # token → highlight captures
      brackets.scm                # bracket pairs
      indents.scm                 # indentation rules
      outline.scm                 # symbol outline
```

---

## Customizing

**Add a built-in function** so it highlights distinctly from your own subs:
open `languages/aggressor/highlights.scm`, find the `function.builtin`
`#any-of?` lists, and add the name. (Anything not listed still highlights as a
normal `@function` call — the list only promotes names to the "built-in"
color.) Re-run the dev-extension rebuild in Zed.

**Change colors:** the capture names here (`@function.builtin`,
`@variable.special`, `@keyword`, etc.) are standard Zed syntax keys, so they
follow whatever theme you use. Override specific ones under
`"experimental.theme_overrides"` → `"syntax"` in your Zed settings.

---

## Notes & limitations

- Aggressor/Sleep makes `;` statement terminators effectively optional; the
  grammar accepts both styles (the official examples mix them).
- The built-in-function list covers Sleep core plus the common Cobalt Strike
  Beacon/API functions. It is easy to extend (see above) and is not meant to be
  exhaustive of every API across every CS version.
- There is no language server — this is highlighting, indentation, brackets and
  outline, not completion or diagnostics.
