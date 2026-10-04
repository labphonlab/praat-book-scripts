# mfc_to_r.praat
# Script 15.4：ExperimentMFC結果R用CSV変換（完全版）
#
# 『Praatで学ぶ音声研究の方法』ch15掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form MFC to R Converter
  sentence Input_table     results/sp01_session01.Table
  sentence Participant_id  sp01
  integer  Session_number  1
  sentence Condition       condition_A
  # 反応時間の下限閾値（ms）
  real     Rt_min_ms       150
  # 反応時間の上限閾値（ms）
  real     Rt_max_ms       5000
  sentence Output_csv      results/sp01_session01_clean.csv
endform

table = Read from file: input_table$
selectObject: table
n_rows = Get number of rows

writeFileLine: output_csv$,
  ... "participant,session,condition,trial,stimulus,vot_ms,response,",
  ... "rt_ms,rt_flag,responded_pa"

n_valid   = 0
n_invalid = 0

for i from 1 to n_rows
  selectObject: table
  stimulus$     = Get value: i, "stimulus"
  response$     = Get value: i, "response"
  rt_raw$       = Get value: i, "reactionTime"
  rt_s          = number(rt_raw$)
  rt_ms         = if rt_s <> undefined then rt_s * 1000 else undefined fi

  ; 刺激ファイル名からVOT値（数字+ms）を抽出する
  ; ファイル名形式: vot_step01_10ms → 10を抽出
  # 最後の _ の次の位置
  vot_pos = rindex(stimulus$, "_") + 1
  vot_end = index(stimulus$, "ms") - 1
  if vot_pos > 0 and vot_end >= vot_pos
    vot_str$ = mid$(stimulus$, vot_pos, vot_end - vot_pos + 1)
    vot_ms_v = number(vot_str$)
  else
    vot_ms_v = undefined
  endif

  vot_str$    = if vot_ms_v <> undefined then string$(round(vot_ms_v)) else "NA" fi
  rt_str$     = if rt_ms    <> undefined then fixed$(rt_ms, 0)  else "NA" fi
  responded_pa = if response$ = "pa" then 1 else 0 fi

  ; 反応時間フラグの設定
  if rt_ms = undefined
    rt_flag$ = "missing"
    n_invalid = n_invalid + 1
  elsif rt_ms < rt_min_ms or rt_ms > rt_max_ms
    rt_flag$ = "outlier"
    n_invalid = n_invalid + 1
  else
    rt_flag$ = "valid"
    n_valid   = n_valid + 1
  endif

  appendFileLine: output_csv$,
    ... participant_id$, ",", session_number, ",", condition$, ",",
    ... i, ",", stimulus$, ",", vot_str$, ",", response$, ",",
    ... rt_str$, ",", rt_flag$, ",", responded_pa
endfor

removeObject: table
appendInfoLine: "=== 前処理完了 ==="
appendInfoLine: "有効試行: ", n_valid, " / 無効試行（outlier+missing）: ", n_invalid
appendInfoLine: "出力 → ", output_csv$
