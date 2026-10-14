#!/usr/bin/env bash

# ════════════════════════════════
# CONFIG
# ════════════════════════════════
DELIM="|"
DEFAULT_TEXT="Nothing playing"

# ════════════════════════════════
# FUNCTIONS
# ════════════════════════════════

get_media_data() {
    local raw_data status artist title player album

    # Fetch metadata (single call)
    raw_data=$(playerctl metadata \
        --format "{{status}}${DELIM}{{artist}}${DELIM}{{title}}${DELIM}{{playerName}}${DELIM}{{album}}" \
        2>/dev/null)

    # If nothing is active
    if [[ -z "$raw_data" ]]; then
        printf '{"text": "%s", "class": "stopped"}\n' "$DEFAULT_TEXT"
        return
    fi

    # Parse
    IFS="$DELIM" read -r status artist title player album <<< "$raw_data"

    # ════════════════════════════════
    # FALLBACKS
    # ════════════════════════════════

    # Artist fallback (YouTube, browsers, etc.)
    if [[ -z "$artist" || "$artist" == "null" ]]; then
        artist="${album:-$player}"
    fi

    # Title fallback
    if [[ -z "$title" || "$title" == "null" ]]; then
        title="Unknown"
    fi

    # ════════════════════════════════
    # OUTPUT
    # ════════════════════════════════

    printf '{"text": "%s - %s", "class": "%s"}\n' \
        "$artist" "$title" "${status,,}"
}

# ════════════════════════════════
# MAIN LOOP (OPTIMIZED)
# ════════════════════════════════

# Instead of aggressive polling, use follow mode (better performance)
playerctl -F metadata --format "{{status}}" 2>/dev/null | while read -r _; do
    get_media_data
done

# Fallback (in case playerctl -F fails)
while true; do
    get_media_data
    sleep 2
done
