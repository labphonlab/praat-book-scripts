# script_8_4_batch_full.praat
# Script 8.4：エラーハンドリング付き完全版batch template
#
# 『Praatで学ぶ音声研究の方法』ch08掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form Batch Processing Full
  sentence Audio_folder audio/
  sentence Output_csv   results/output.csv
  sentence Error_log    results/errors.csv
  sentence Resume_file  results/processed.txt
  real     Floor        75
  real     Ceiling     300
endform

; 出力ファイルの初期化
if not fileReadable(output_csv$)
  writeFileLine: output_csv$, "filename,duration_s,f0_mean,f0_sd"
endif
if not fileReadable(error_log$)
  writeFileLine: error_log$, "filename,message"
endif

; 処理済みリストの読み込み（再開用）
if fileReadable(resume_file$)
  processed$ = readFile$(resume_file$)
else
  processed$ = ""
endif

Create Strings as file list: "wavfiles", audio_folder$ + "*.wav"
selectObject: "Strings wavfiles"
n = Get number of strings
n_ok    = 0
n_skip  = 0
n_error = 0

appendInfoLine: "=== batch処理開始: ", n, " ファイル ==="

for i from 1 to n
  selectObject: "Strings wavfiles"
  filename$ = Get string: i
  # 注: ファイル名に ".wav" が複数含まれる場合は不正確になる
  basename$ = filename$ - ".wav"

  ; 途中再開チェック（処理済みならスキップ）
  if index(processed$, basename$ + newline$) > 0
    n_skip = n_skip + 1
    goto next_file
  endif

  appendInfoLine: i, "/", n, ": ", basename$

  ; ファイル存在確認
  if not fileReadable(audio_folder$ + filename$)
    appendFileLine: error_log$, basename$, ",ファイルが読み込めません"
    n_error = n_error + 1
    goto next_file
  endif

  snd = Read from file: audio_folder$ + filename$
  dur = Get total duration

  ; Pitch抽出（失敗してもスキップ）
  ; 「変数 = nocheck コマンド」の形は成功時も代入されないため、
  ; nocheckは代入なしのコマンド単体に付け、成否はnumberOfSelected()で判定する
  selectObject: snd
  nocheck To Pitch (ac): 0, floor, 15, "no", 0.03, 0.45, 0.01, 0.35, 0.14, ceiling

  if numberOfSelected("Pitch") > 0
    pit = selected("Pitch")
    selectObject: pit
    f0_mean = Get mean:               0, 0, "Hertz"
    f0_sd   = Get standard deviation: 0, 0, "Hertz"
    removeObject: pit
  else
    f0_mean = undefined
    f0_sd   = undefined
  endif

  f0_mean$ = if f0_mean <> undefined then fixed$(f0_mean, 2) else "NA" fi
  f0_sd$   = if f0_sd   <> undefined then fixed$(f0_sd,   2) else "NA" fi

  appendFileLine: output_csv$,
    ... basename$, ",", fixed$(dur, 4), ",", f0_mean$, ",", f0_sd$

  removeObject: snd

  ; 処理済みリストに追記（再開用）
  appendFileLine: resume_file$, basename$
  n_ok = n_ok + 1

  label next_file
  ; （スキップ済み）
endfor

removeObject: "Strings wavfiles"

appendInfoLine: "=== 完了 ==="
appendInfoLine: "処理済み: ", n_ok, " / スキップ: ", n_skip, " / エラー: ", n_error
appendInfoLine: "出力: ", output_csv$
if n_error > 0
  appendInfoLine: "エラーログ: ", error_log$
endif
