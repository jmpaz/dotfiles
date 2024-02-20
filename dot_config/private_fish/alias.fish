alias cat='bat'
alias ls='eza --icons'
alias tree='eza --tree'

alias fe='yazi'
alias yz='yazi'
alias cz='chezmoi'
alias lg='lazygit'
alias zj='zellij'

alias copy='xclip -selection clipboard'
alias cpimg='copy -t image/png -i'

# Warn when about to pip install globally
alias pip='pip_wrapper'

# List files being tracked by git
alias print-staged='git ls-files --stage | awk "{print \$4}" | grep -v -e "__init__.py" -e "requirements.txt" -e ".gitignore"'
