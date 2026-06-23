#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name // "–"')
EFFORT=$(echo "$input" | jq -r '.effort.level // empty')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
USED=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
MAX=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
FIVE_H_PCT=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
SEVEN_D_PCT=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
SEVEN_D_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

RESET='\033[0m'
CINNABAR='\033[38;5;202m'  # model name
LAVENDER='\033[38;5;183m'  # effort level
TEAL='\033[38;5;116m'      # gauge labels
MUTED='\033[38;5;147m'     # reset time
WHITE='\033[38;5;255m'     # pipe + percentage
LINE_C='\033[38;5;240m'    # ─── lines
D='\033[38;5;111m'         # eza d → current tokens
R='\033[38;5;221m'         # eza r → /
W='\033[38;5;209m'         # eza w → max tokens
X='\033[38;5;120m'         # eza x → k unit

HMAP=(157 193 192 228 222 216 217 211 210 204)

build_bar() {
  local pct=$1 filled bar=""
  filled=$((pct * 10 / 100))
  for i in 0 1 2 3 4 5 6 7 8 9; do
    [ "$i" -lt "$filled" ] && bar="${bar}\\033[38;5;${HMAP[$i]}m█" || bar="${bar}\\033[38;5;237m░"
  done
  printf '%b%b' "$bar" "$RESET"
}

fmt_tokens() {
  local n=$1
  if   [ "$n" -ge 1000000 ]; then printf '%b%d.%d%bM%b' "$D" $((n/1000000)) $(( (n%1000000)/100000 )) "$X" "$RESET"
  elif [ "$n" -ge 1000    ]; then printf '%b%d%bk%b'     "$D" $((n/1000))    "$X" "$RESET"
  else printf '%b%d%b' "$D" "$n" "$RESET"; fi
}

fmt_tokens_max() {
  local n=$1
  if   [ "$n" -ge 1000000 ]; then printf '%b%d.%d%bM%b' "$W" $((n/1000000)) $(( (n%1000000)/100000 )) "$X" "$RESET"
  elif [ "$n" -ge 1000    ]; then printf '%b%d%bk%b'     "$W" $((n/1000))    "$X" "$RESET"
  else printf '%b%d%b' "$W" "$n" "$RESET"; fi
}

fmt_reset() {
  local at=$1 now diff d h m
  [ -z "$at" ] && return
  now=$(date +%s); diff=$((at - now))
  [ "$diff" -le 0 ] && printf 'now' && return
  d=$((diff/86400)); h=$(( (diff%86400)/3600 )); m=$(( (diff%3600)/60 ))
  if   [ "$d" -gt 0 ]; then printf '%dd%dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%dh%dm' "$h" "$m"
  else printf '%dm' "$m"; fi
}

SEP="${WHITE} | ${RESET}"

# Model + effort
SEG="${CINNABAR}${MODEL}${RESET}"
[ -n "$EFFORT" ] && SEG="${SEG} ${LAVENDER}${EFFORT}${RESET}"

# Context gauge
CTX_PCT=${PCT:-0}
CTX_BAR=$(build_bar "$CTX_PCT")
USED_F=$(fmt_tokens "$USED"); MAX_F=$(fmt_tokens_max "$MAX")
SEG="${SEG}${SEP}${TEAL}ctx ${RESET}${CTX_BAR} ${WHITE}${CTX_PCT}%${RESET} ${USED_F}${R}/${RESET}${MAX_F}"

# 5-hour rate limit
if [ -n "$FIVE_H_PCT" ]; then
  P=$(printf '%.0f' "$FIVE_H_PCT")
  BAR=$(build_bar "$P"); RST=$(fmt_reset "$FIVE_H_RESET")
  S="${TEAL}5hr ${RESET}${BAR} ${WHITE}${P}%${RESET}"
  [ -n "$RST" ] && S="${S} ${MUTED}~${RST}${RESET}"
  SEG="${SEG}${SEP}${S}"
fi

# 7-day rate limit
if [ -n "$SEVEN_D_PCT" ]; then
  P=$(printf '%.0f' "$SEVEN_D_PCT")
  BAR=$(build_bar "$P"); RST=$(fmt_reset "$SEVEN_D_RESET")
  S="${TEAL}7day ${RESET}${BAR} ${WHITE}${P}%${RESET}"
  [ -n "$RST" ] && S="${S} ${MUTED}~${RST}${RESET}"
  SEG="${SEG}${SEP}${S}"
fi

printf '%b\n' "$SEG$RESET"
