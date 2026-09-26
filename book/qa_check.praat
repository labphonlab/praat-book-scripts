# qa_check.praat
# Script 8.6：QA自動チェックscript
#
# 『Praatで学ぶ音声研究の方法』ch08掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form QA Check
  sentence Features_csv    results/features.csv
  real     F0_min_hz       50
  real     F0_max_hz       500
  real     Duration_min_ms 10
  real     Duration_max_ms 60000
  real     Na_warn_pct     20
  sentence Report_file     results/qa_report.txt
endform

table = Read Table from comma-separated file: features_csv$
selectObject: table
n_rows = Get number of rows

n_na_f0  = 0
n_bad_f0 = 0
n_bad_dur = 0

writeFileLine:  report_file$, "=== QA Report === ", date$()
appendFileLine: report_file$, "Input: ", features_csv$, " / Rows: ", n_rows

for i from 1 to n_rows
  selectObject: table

  ; F0 NA・範囲外チェック
  f0_str$ = Get value: i, "f0_mean"
  if f0_str$ = "NA" or f0_str$ = ""
    n_na_f0 = n_na_f0 + 1
  else
    f0_val = number(f0_str$)
    if f0_val <> undefined
      if f0_val < f0_min_hz or f0_val > f0_max_hz
        n_bad_f0 = n_bad_f0 + 1
        file$ = Get value: i, "file"
        appendFileLine: report_file$, "F0範囲外: ", file$, " → ", fixed$(f0_val, 1), " Hz"
      endif
    endif
  endif

  ; 持続時間チェック（duration_ms列がある場合）
  dur_str$ = Get value: i, "duration_ms"
  if dur_str$ <> "NA" and dur_str$ <> ""
    dur_val = number(dur_str$)
    if dur_val <> undefined
      if dur_val < duration_min_ms or dur_val > duration_max_ms
        n_bad_dur = n_bad_dur + 1
        file$ = Get value: i, "file"
        appendFileLine: report_file$, "持続時間異常: ", file$, " → ", fixed$(dur_val, 0), " ms"
      endif
    endif
  endif
endfor

na_pct = n_na_f0 / n_rows * 100
appendFileLine: report_file$, ""
appendFileLine: report_file$, "F0 NA率:      ", fixed$(na_pct, 1), "%"
appendFileLine: report_file$, "F0 範囲外:    ", n_bad_f0, " 件"
appendFileLine: report_file$, "持続時間異常: ", n_bad_dur, " 件"

if na_pct > na_warn_pct
  appendFileLine: report_file$, "⚠️ 警告: NA率が閾値を超えています（", fixed$(na_warn_pct, 0), "%）"
  appendInfoLine:              "⚠️ 警告: F0 NA率 = ", fixed$(na_pct, 1), "%"
else
  appendFileLine: report_file$, "✅ F0 NA率は正常範囲内です"
  appendInfoLine:              "✅ QA完了: 重大な問題なし"
endif

removeObject: table
appendInfoLine: "QAレポート → ", report_file$
