# vowel_extractor.praat
# Script 11.1の前提条件
#
# 『Praatで学ぶ音声研究の方法』ch11掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Vowel Extractor
  sentence Audio_folder       audio/
  sentence Textgrid_folder    textgrids/
  integer  Phone_tier         1
  sentence Target_labels      a i u e o
  real     Formant_ceiling    5500
  real     Pitch_floor        75
  real     Pitch_ceiling      300
  real     Bw1_threshold      200
  real     Bw2_threshold      300
  sentence Output_csv         results/vowels.csv
endform

; 出力フォルダが存在しない場合は事前に作成しておくこと（results/フォルダが必要）
; macOS/Linux: mkdir -p results/
; フォルダ作成（Windows）: md results\

writeFileLine: output_csv$,
  ... "file,speaker,vowel,row_n,interval_n,start_s,end_s,duration_ms,",
  ... "f1_50,f2_50,f3_50,bw1_50,bw2_50,",
  ... "f0_mean,f0_sd,voiced_frac,int_mean,reliable"

; ------------------------------
; 数値→文字列変換procedure（undefined → "NA"）
# 有声区間率を計算する（11.2節参照）
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

procedure num_to_str: .val, .decimals
  if .val <> undefined
    .s$ = fixed$(.val, .decimals)
  else
    .s$ = "NA"
  endif
endproc
; ------------------------------

Create Strings as file list: "wavfiles", audio_folder$ + "*.wav"
selectObject: "Strings wavfiles"
n_files = Get number of strings
n_total = 0

appendInfoLine: "=== 処理開始: ", n_files, " ファイル ==="

for i from 1 to n_files
  selectObject: "Strings wavfiles"
  filename$ = Get string: i
  basename$ = filename$ - ".wav"
  tgpath$   = textgrid_folder$ + basename$ + ".TextGrid"

  appendInfoLine: i, "/", n_files, ": ", basename$

  if fileReadable(audio_folder$ + filename$) and fileReadable(tgpath$)

    ; 話者IDをファイル名から取得（アンダースコアまでの部分）
    underscore = index(basename$, "_")
    if underscore > 0
      speaker$ = left$(basename$, underscore - 1)
    else
      speaker$ = basename$
    endif

    ; オブジェクト作成
    snd     = Read from file: audio_folder$ + filename$
    tg      = Read from file: tgpath$

    selectObject: snd
    pit     = To Pitch (ac): 0, pitch_floor, 15, "no",
      ... 0.03, 0.45, 0.01, 0.35, 0.14, pitch_ceiling
    selectObject: snd
    fmt     = To Formant (burg): 0, 5, formant_ceiling, 0.025, 50
    selectObject: snd
    int_obj = To Intensity: 100, 0, "yes"

    selectObject: tg
    n_int = Get number of intervals: phone_tier

    for j from 1 to n_int
      selectObject: tg
      label$ = Get label of interval: phone_tier, j

      ; 空ラベルを除外してから、対象ラベルかどうかを確認する
      if label$ <> "" and index(" " + target_labels$ + " ", " " + label$ + " ") > 0

        xmin = Get start time of interval: phone_tier, j
        xmax = Get end time of interval:   phone_tier, j
        dur  = (xmax - xmin) * 1000
        mid  = xmin + (xmax - xmin) / 2

        ; --- Formant測定（中点） ---
        selectObject: fmt
        f1  = Get value at time:     1, mid, "Hertz", "Linear"
        f2  = Get value at time:     2, mid, "Hertz", "Linear"
        f3  = Get value at time:     3, mid, "Hertz", "Linear"
        bw1 = Get bandwidth at time: 1, mid, "Hertz", "Linear"
        bw2 = Get bandwidth at time: 2, mid, "Hertz", "Linear"

        @num_to_str: f1,  1
        f1_str$  = num_to_str.s$
        @num_to_str: f2,  1
        f2_str$  = num_to_str.s$
        @num_to_str: f3,  1
        f3_str$  = num_to_str.s$
        @num_to_str: bw1, 1
        bw1_str$ = num_to_str.s$
        @num_to_str: bw2, 1
        bw2_str$ = num_to_str.s$

        ; --- Pitch測定（区間統計）---
        selectObject: pit
        f0_mean     = Get mean:               xmin, xmax, "Hertz"
        f0_sd       = Get standard deviation: xmin, xmax, "Hertz"
        ; 有声区間率はフレームを走査して計算する
        @voiced_fraction: pit, xmin, xmax
        voiced_frac = voiced_fraction.result

        @num_to_str: f0_mean, 2
        f0_mean_str$ = num_to_str.s$
        @num_to_str: f0_sd, 2
        f0_sd_str$ = num_to_str.s$
        @num_to_str: voiced_frac, 4
        vfrac_str$ = num_to_str.s$

        ; --- Intensity測定 ---
        selectObject: int_obj
        int_mean = Get mean: xmin, xmax, "dB"
        @num_to_str: int_mean, 2
        int_str$ = num_to_str.s$

        ; --- Reliableフラグ（経験則ベース） ---
        ; bandwidth閾値は経験則。論文には使用した閾値を必ず明記すること
        if bw1 <> undefined and bw2 <> undefined
          if bw1 < bw1_threshold and bw2 < bw2_threshold
            reliable = 1
          else
            reliable = 0
          endif
        else
          reliable = 0
        endif

        # ファイルをまたいだ通し番号
        n_total = n_total + 1

        # interval_n には区間番号 j をそのまま出力する
        appendFileLine: output_csv$,
          ... basename$, ",", speaker$, ",", label$, ",",
          ... n_total, ",", j, ",", fixed$(xmin, 4), ",", fixed$(xmax, 4), ",",
          ... fixed$(dur, 2), ",",
          ... f1_str$, ",", f2_str$, ",", f3_str$, ",",
          ... bw1_str$, ",", bw2_str$, ",",
          ... f0_mean_str$, ",", f0_sd_str$, ",", vfrac_str$, ",",
          ... int_str$, ",", reliable

      endif
    endfor

    removeObject: snd, tg, pit, fmt, int_obj

  else
    appendInfoLine: "  スキップ（ファイル未発見）: ", basename$
  endif
endfor

# Stringsオブジェクトも削除する
removeObject: "Strings wavfiles"
appendInfoLine: "=== 完了 ==="
appendInfoLine: "総測定数: ", n_total
appendInfoLine: "出力: ", output_csv$
