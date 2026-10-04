# pitch_stats_batch.praat
# Script 2.1：F0統計量一括抽出（mean/SD/voiced fraction）
#
# 『Praatで学ぶ音声研究の方法』ch02掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Pitch Statistics Batch
  sentence Audio_folder   audio/
  sentence Textgrid_folder textgrids/
  integer  Tier            1
  real     Floor          50
  real     Top            800
  real     Voicing_threshold 0.50
  real     Silence_threshold 0.09
  sentence Output_csv     results/pitch_stats.csv
endform

writeFileLine: output_csv$, "file,label,t_start,t_end,duration_ms,f0_mean,f0_sd,f0_min,f0_max,voiced_fraction"

Create Strings as file list: "wavfiles", audio_folder$ + "*.wav"
selectObject: "Strings wavfiles"
n = Get number of strings

for i from 1 to n
  selectObject: "Strings wavfiles"
  filename$ = Get string: i
  basename$ = filename$ - ".wav"
  tgpath$   = textgrid_folder$ + basename$ + ".TextGrid"

  ; 両ファイルが存在する場合のみ処理する
  if fileReadable(audio_folder$ + filename$) and fileReadable(tgpath$)

    snd = Read from file: audio_folder$ + filename$
    selectObject: snd
    pit = To Pitch (filtered autocorrelation): 0, floor, top, 15, "no",
      ... silence_threshold, voicing_threshold, 0.055, 0.35, 0.14, 0.03

    tg = Read from file: tgpath$
    selectObject: tg
    n_int = Get number of intervals: tier

    for j from 1 to n_int
      selectObject: tg
      label$ = Get label of interval: tier, j

      ; 空ラベルを除き、ラベルのある区間のみ処理する
      if label$ <> ""
        t1     = Get start time of interval: tier, j
        t2     = Get end time of interval:   tier, j
        dur_ms = (t2 - t1) * 1000

        selectObject: pit
        f0_mean = Get mean:               t1, t2, "Hertz"
        f0_sd   = Get standard deviation: t1, t2, "Hertz"
        f0_min  = Get minimum:            t1, t2, "Hertz", "parabolic"
        f0_max  = Get maximum:            t1, t2, "Hertz", "parabolic"
        ; 有声区間率はPitchフレームを走査して計算する（第11章のprocedure）
        @voiced_fraction: pit, t1, t2
        vfrac   = voiced_fraction.result

        f0_mean$ = if f0_mean <> undefined then fixed$(f0_mean, 2) else "NA" fi
        f0_sd$   = if f0_sd   <> undefined then fixed$(f0_sd,   2) else "NA" fi
        f0_min$  = if f0_min  <> undefined then fixed$(f0_min,  2) else "NA" fi
        f0_max$  = if f0_max  <> undefined then fixed$(f0_max,  2) else "NA" fi
        vfrac$   = if vfrac   <> undefined then fixed$(vfrac,   4) else "NA" fi

        appendFileLine: output_csv$,
          ... basename$, ",", label$, ",",
          ... fixed$(t1, 4), ",", fixed$(t2, 4), ",", fixed$(dur_ms, 1), ",",
          ... f0_mean$, ",", f0_sd$, ",", f0_min$, ",", f0_max$, ",", vfrac$
      endif
    endfor

    removeObject: tg, pit, snd

  else
    appendInfoLine: "スキップ（ファイル未発見）: ", basename$
  endif
endfor

removeObject: "Strings wavfiles"
appendInfoLine: "完了: ", n, " ファイルを処理 → ", output_csv$

# 有声区間率を計算する（第11章11.2節参照）
procedure voiced_fraction: .pitch, .t1, .t2
  selectObject: .pitch
  .n_all = Get number of frames
  if .t1 = 0 and .t2 = 0
    .from = Get time from frame number: 1
    .to   = Get time from frame number: .n_all
  else
    .from = .t1
    .to   = .t2
  endif
  .n_voiced = 0
  .n_total  = 0
  for .k from 1 to .n_all
    .t = Get time from frame number: .k
    if .t >= .from and .t <= .to
      .n_total = .n_total + 1
      .f = Get value in frame: .k, "Hertz"
      if .f <> undefined
        .n_voiced = .n_voiced + 1
      endif
    endif
  endfor
  if .n_total > 0
    .result = .n_voiced / .n_total
  else
    .result = undefined
  endif
endproc
