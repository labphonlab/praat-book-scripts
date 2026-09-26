# latin_square.praat
# Script 15.2：参加者番号から条件均等化を決定するスクリプト
#
# 『Praatで学ぶ音声研究の方法』ch15掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form Latin Square Counterbalancing
  integer  Participant_number  1
  sentence Conditions          "condition_A condition_B condition_C"
  sentence Output_order        results/condition_order.txt
endform

; 条件を配列に展開する
n_cond = 0
rest$  = conditions$
while rest$ <> ""
  n_cond = n_cond + 1
  pos = index(rest$, " ")
  if pos > 0
    cond$[n_cond] = left$(rest$, pos - 1)
    rest$          = right$(rest$, length(rest$) - pos)
  else
    cond$[n_cond] = rest$
    rest$          = ""
  endif
endwhile

; 参加者番号からグループを決定する（0始まり）
group = (participant_number - 1) mod n_cond

; ラテン方格のシフト量に基づいて条件を並べ替える
writeFileLine: output_order$, "参加者番号: ", participant_number
appendFileLine: output_order$, "グループ: ", group + 1, " / ", n_cond
appendFileLine: output_order$, ""
appendFileLine: output_order$, "条件提示順序:"

for i from 1 to n_cond
  ; シフト後のindex（0始まり、mod でラップ）
  shifted_idx = (group + i - 1) mod n_cond + 1
  appendFileLine: output_order$, "  ", i, ". ", cond$[shifted_idx]
  appendInfoLine: "条件 ", i, ": ", cond$[shifted_idx]
endfor

appendInfoLine: "条件順序を保存 → ", output_order$
