# vot_measure.praat
# VOTの測定方法
#
# 『Praatで学ぶ音声研究の方法』ch04掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form VOT Measurement
  sentence Textgrid_folder textgrids/
  integer  Burst_tier      2
  integer  Vowel_tier      3
  sentence Output_csv      results/vot.csv
endform

writeFileLine: output_csv$, "file,token,burst_t,vowel_onset_t,vot_ms"

Create Strings as file list: "tgfiles", textgrid_folder$ + "*.TextGrid"
selectObject: "Strings tgfiles"
n = Get number of strings

for i from 1 to n
  selectObject: "Strings tgfiles"
  fn$ = Get string: i
  stem$ = fn$ - ".TextGrid"
  Read from file: textgrid_folder$ + fn$
  tg = selected("TextGrid")

  n_bursts = Get number of points: burst_tier
  for j from 1 to n_bursts
    selectObject: tg
    t_burst = Get time of point: burst_tier, j

    ; vowel_onset tier から最も近い点を取得
    n_vo = Get number of points: vowel_tier
    t_vo = undefined
    for k from 1 to n_vo
      selectObject: tg
      t_k = Get time of point: vowel_tier, k
      if t_k > t_burst and (t_vo = undefined or t_k < t_vo)
        t_vo = t_k
      endif
    endfor

    if t_vo <> undefined
      vot_ms = (t_vo - t_burst) * 1000
      appendFileLine: output_csv$,
        ... stem$, ",", j, ",",
        ... fixed$(t_burst, 4), ",", fixed$(t_vo, 4), ",", fixed$(vot_ms, 2)
    endif
  endfor

  removeObject: tg
endfor

removeObject: "Strings tgfiles"
appendInfoLine: "完了: ", n, " ファイルを処理 → ", output_csv$
