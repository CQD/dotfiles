#!/usr/bin/env bash

# https://code.claude.com/docs/en/statusline

input=$(cat)

# 單次 jq 呼叫取出所有欄位（省 fork）
{
  read -r CTX_SIZE
  read -r INPUT_TOKENS
  read -r OUTPUT_TOKENS
  read -r SESSION_PCT
  read -r SESSION_RST_TIME
  read -r DIR
} < <(jq -r -c '
  (.context_window.context_window_size // 0),
  ((.context_window.current_usage.input_tokens // 0)
   + (.context_window.current_usage.cache_creation_input_tokens // 0)
   + (.context_window.current_usage.cache_read_input_tokens // 0)),
  (.context_window.current_usage.output_tokens // 0),
  (.rate_limits.five_hour.used_percentage // 0),
  (.rate_limits.five_hour.resets_at // 0),
  .workspace.current_dir
' <<< "$input")


# Context Windows 長條圖
BAR_W=30
C_IN=$'\033[36m'    # cyan  — input
C_OUT=$'\033[33m'   # yellow — output
C_FREE=$'\033[90m'  # gray  — unused
C_RST=$'\033[0m'

TOTAL=$(( INPUT_TOKENS + OUTPUT_TOKENS ))
CONTEXT_PCT=$(( TOTAL * 100 / CTX_SIZE ))

IN_W=$(( INPUT_TOKENS * BAR_W / CTX_SIZE ))
OUT_W=$(( OUTPUT_TOKENS * BAR_W / CTX_SIZE ))
(( INPUT_TOKENS  > 0 && IN_W  == 0 )) && IN_W=1
(( OUTPUT_TOKENS > 0 && OUT_W == 0 )) && OUT_W=1
(( IN_W + OUT_W > BAR_W )) && OUT_W=$(( BAR_W - IN_W ))
FREE_W=$(( BAR_W - IN_W - OUT_W ))

printf -v in_bar   '%*s' "$IN_W"   ''; in_bar=${in_bar// /█}
printf -v out_bar  '%*s' "$OUT_W"  ''; out_bar=${out_bar// /█}
printf -v free_bar '%*s' "$FREE_W" ''; free_bar=${free_bar// /░}

CONTEXT_BAR="${C_IN}${in_bar}${C_OUT}${out_bar}${C_FREE}${free_bar}${C_RST} ${CONTEXT_PCT}%"

# Session Limit
C_OK=$'\033[36m'
C_NOTI=$'\033[32m'
C_WARN=$'\033[33m'
C_ERR=$'\033[31m'

NOW=${EPOCHSECONDS:-$(date +%s)}

(( RESET_IN_SEC = SESSION_RST_TIME - NOW ))
if   (( RESET_IN_SEC >= 3600 )); then RESET_IN=" ($(( RESET_IN_SEC / 3600 ))h$(( RESET_IN_SEC % 3600 / 60 ))m)"
elif (( RESET_IN_SEC >= 60   )); then RESET_IN=" ($(( RESET_IN_SEC / 60 ))m$(( RESET_IN_SEC % 60 ))s)"
elif (( RESET_IN_SEC  < 0    )); then RESET_IN=""
else                                  RESET_IN=" (${RESET_IN_SEC}s)"
fi

if   (( SESSION_PCT >= 90 )); then C_SESSION=$C_ERR
elif (( SESSION_PCT >= 75 )); then C_SESSION=$C_WARN
elif (( SESSION_PCT >= 50 )); then C_SESSION=$C_NOTI
else                               C_SESSION=$C_OK
fi

SESSION_BAR="${C_SESSION}${SESSION_PCT}%${C_RST}${RESET_IN}"

# Final line
echo  "📁 ${DIR##*/} | 📖 ${CONTEXT_BAR} | 🕐 ${SESSION_BAR}"

