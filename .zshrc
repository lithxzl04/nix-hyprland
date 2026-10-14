# ---------- Zsh options ----------
setopt HIST_IGNORE_ALL_DUPS   # drop older duplicate entries from history
bindkey -e                    # emacs keymap
WORDCHARS=${WORDCHARS//[\/]}  # treat "/" as a word boundary (Ctrl-W stops at slashes)

# ---------- Module settings ----------
ZSH_AUTOSUGGEST_MANUAL_REBIND=1               # faster; autosuggestions is last in .zimrc
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# ---------- Zim bootstrap ----------
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Download zimfw if missing
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi

# Install missing modules and regenerate init.zsh when .zimrc changes
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi

source ${ZIM_HOME}/init.zsh

# ---------- Keybindings (after modules load) ----------
# history-substring-search: Up/Down or Ctrl-P/N search history by what you've typed
zmodload -F zsh/terminfo +p:terminfo
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
unset key
fastfetch
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
