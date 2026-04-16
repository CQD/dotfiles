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


C_OK=$'\033[32m'
C_NOTI=$'\033[36m'
C_WARN=$'\033[33m'
C_ERR=$'\033[31m'

# Context Windows 長條圖
BAR_W=15
C_FREE=$'\033[90m'  # gray  — unused quota
C_RST=$'\033[0m'

TOTAL=$(( INPUT_TOKENS + OUTPUT_TOKENS ))
CONTEXT_PCT=$(( TOTAL * 100 / CTX_SIZE ))

if   ((  CONTEXT_PCT >= 70 )); then C_BAR=$C_ERR
elif ((  CONTEXT_PCT >= 30 )); then C_BAR=$C_WARN
elif ((  CONTEXT_PCT >= 20 )); then C_BAR=$C_NOTI
else C_BAR=$C_OK
fi

USED_W8=$(( (TOTAL * BAR_W * 8 / CTX_SIZE) ))
USED_W=$(( USED_W8 / 8 ))
USED_W8=$(( USED_W8 % 8))

(( TOTAL > 0 && USED_W8  == 0 )) && USED_W8=1
FREE_W=$(( BAR_W - USED_W ))
(( USED_W8 > 0 )) && FREE_W=$(( FREE_W - 1 ))

if   (( USED_W8 == 7 )); then end_bar=▉
elif (( USED_W8 == 6 )); then end_bar=▊
elif (( USED_W8 == 5 )); then end_bar=▋
elif (( USED_W8 == 4 )); then end_bar=▌
elif (( USED_W8 == 3 )); then end_bar=▍
elif (( USED_W8 == 2 )); then end_bar=▎
elif (( USED_W8 == 1 )); then end_bar=▏
else end_bar=''; FREE_W=$(( FREE_W + 1 ))
fi

printf -v used_bar '%*s' "$USED_W" ''; used_bar=${used_bar// /█}
printf -v free_bar '%*s' "$FREE_W" ''; # free_bar=${free_bar// /░}

CONTEXT_BAR="${C_BAR}${used_bar}${end_bar}${C_FREE}${free_bar}${C_RST} ${C_BAR}${CONTEXT_PCT}%${C_RST}"

# Session Limit

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

printf -v SESSION_PCT '%.0f' "$SESSION_PCT"
SESSION_BAR="${C_SESSION}${SESSION_PCT}%${C_RST}${RESET_IN}"

# Final line
echo "📁 ${DIR##*/} | 📖 ${CONTEXT_BAR} | 🕐 ${SESSION_BAR}"

