# script_8_3_pitch_batch.praat
# Script 8.3：pitch一括抽出（TextGridとの連携）
#
# 『Praatで学ぶ音声研究の方法』ch08掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Pitch Batch Extraction
  sentence Audio_folder    audio/
  sentence Textgrid_folder textgrids/
  integer  Tier            1
  real     Floor           50
  real     Top            800
  sentence Output_csv      results/pitch_batch.csv
endform

writeFileLine: output_csv$, "file,label,t_start,t_end,dur_s,f0_mean,f0_sd"

Create Strings as file list: "wavfiles", audio_folder$ + "*.wav"
selectObject: "Strings wavfiles"
n = Get number of strings

for i from 1 to n
  selectObject: "Strings wavfiles"
  filename$ = Get string: i
  # 注: ファイル名に ".wav" が複数含まれる場合は不正確になる
  basename$ = filename$ - ".wav"
  tgpath$   = textgrid_folder$ + basename$ + ".TextGrid"

  if fileReadable(audio_folder$ + filename$) and fileReadable(tgpath$)

    snd = Read from file: audio_folder$ + filename$
    selectObject: snd
    pit = To Pitch (filtered autocorrelation): 0, floor, top, 15, "no", 0.03, 0.09, 0.50, 0.055, 0.35, 0.14
    ; filtered autocorrelation法（本書の標準）。floorの直後の引数がtop。詳細は第2章参照
    tg  = Read from file: tgpath$
    selectObject: tg
    n_int = Get number of intervals: tier

    for j from 1 to n_int
      selectObject: tg
      label$ = Get label of interval: tier, j
      if label$ <> ""
        t1  = Get start time of interval: tier, j
        t2  = Get end time of interval:   tier, j
        dur = t2 - t1

        selectObject: pit
        f0_mean = Get mean:               t1, t2, "Hertz"
        f0_sd   = Get standard deviation: t1, t2, "Hertz"

        ; undefined を NA に変換する
        f0_mean$ = if f0_mean <> undefined then fixed$(f0_mean, 2) else "NA" fi
        f0_sd$   = if f0_sd   <> undefined then fixed$(f0_sd,   2) else "NA" fi

        appendFileLine: output_csv$,
          ... basename$, ",", label$, ",",
          ... fixed$(t1, 4), ",", fixed$(t2, 4), ",", fixed$(dur, 4), ",",
          ... f0_mean$, ",", f0_sd$
      endif
    endfor

    # 依存関係を考慮して「作成した逆順で削除」するのが一般的な慣習
    removeObject: tg, pit, snd

  else
    appendInfoLine: "スキップ（ファイル未発見）: ", basename$
  endif
endfor

removeObject: "Strings wavfiles"
appendInfoLine: "完了: ", n, " ファイルを処理 → ", output_csv$
