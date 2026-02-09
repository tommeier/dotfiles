# Personal Preferences

## Coding Style
- Prefer simple, minimal solutions over clever abstractions
- Use existing patterns and conventions in the codebase
- 2-space indentation (4 for Python, tabs for Go/Makefiles)
- Avoid over-engineering: no premature abstractions, no speculative features
- Don't add comments, docstrings, or type annotations to code you didn't change

## Stack
- Primary: Ruby on Rails, RSpec, PostgreSQL
- Secondary: JavaScript/TypeScript, Node.js
- Shell: zsh on macOS
- Editor: VS Code
- Versions managed by mise (.tool-versions)

## Git
- Commits are GPG-signed (may need --no-gpg-sign in non-interactive contexts)
- Write concise commit messages focused on "why" not "what"
- Don't push unless explicitly asked
- Don't amend commits unless explicitly asked

## Testing
- Run tests with `bundle exec rspec`
- Use --fail-fast when iterating on a fix

## Tools
- Use modern CLI tools when available: ripgrep (rg), fd, bat, eza, zoxide, delta
- Use `gh` CLI for GitHub operations
- Use `bundle exec` for Ruby commands, not global gems
- Use `rake` for project tasks

## Shell
- Use `$HOME` or `~` instead of hardcoded paths
- Shell scripts use 2-space indentation, no shebangs for sourced files
- Machine-specific config belongs in ~/.localrc (not tracked)
