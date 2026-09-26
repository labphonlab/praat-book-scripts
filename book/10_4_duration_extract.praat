# 10_4_duration_extract.praat
# Script 10.4：指定ラベルの持続時間を全ファイルで計測してCSV出力
#
# 『Praatで学ぶ音声研究の方法』ch10掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form Duration Extraction
  sentence Textgrid_folder textgrids/
  integer  Tier             1
  sentence Target_label     a
  boolean  All_labels       0
  sentence Output_csv       results/durations.csv
endform

writeFileLine: output_csv$,
  ... "file,tier,label,interval_n,xmin,xmax,duration_ms"

Create Strings as file list: "tgfiles", textgrid_folder$ + "*.TextGrid"
selectObject: "Strings tgfiles"
n_files   = Get number of strings
n_total   = 0
n_skip    = 0

appendInfoLine: n_files, " ファイルを処理します"

for i from 1 to n_files
  selectObject: "Strings tgfiles"
  fn$      = Get string: i
  basename$ = fn$ - ".TextGrid"
  appendInfoLine: i, "/", n_files, ": ", basename$

  if fileReadable(textgrid_folder$ + fn$)
    tg    = Read from file: textgrid_folder$ + fn$
    selectObject: tg
    n_int = Get number of intervals: tier

    for j from 1 to n_int
      selectObject: tg
      label$ = Get label of interval: tier, j

      ; 対象ラベルかどうかを判定
      if all_labels = 1 and label$ <> ""
        match = 1
      elsif label$ = target_label$
        match = 1
      else
        match = 0
      endif

      if match = 1
        xmin = Get start time of interval: tier, j
        xmax = Get end time of interval:   tier, j
        dur  = (xmax - xmin) * 1000

        appendFileLine: output_csv$,
          ... basename$, ",", tier, ",", label$, ",",
          ... j, ",", fixed$(xmin, 4), ",", fixed$(xmax, 4), ",", fixed$(dur, 2)
        n_total = n_total + 1
      endif
    endfor

    removeObject: tg
  else
    appendInfoLine: "  スキップ（ファイルなし）: ", basename$
    n_skip = n_skip + 1
  endif
endfor

removeObject: "Strings tgfiles"
appendInfoLine: "=== 処理完了 ==="
appendInfoLine: "抽出区間数: ", n_total, " / スキップ: ", n_skip
appendInfoLine: "出力: ", output_csv$
