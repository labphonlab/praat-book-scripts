# 10_2_tier_cross.praat
# Script 10.2：tier間照合スクリプト（完全版）
#
# 『Praatで学ぶ音声研究の方法』ch10掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Tier Cross Extraction
  sentence Audio_folder    audio/
  sentence Textgrid_folder textgrids/
  integer  Phone_tier      1
  integer  Word_tier       2
  real     Floor           75
  real     Ceiling        300
  sentence Output_csv      results/tier_cross.csv
endform

writeFileLine: output_csv$,
  ... "file,word,phone,phone_n,xmin,xmax,dur_ms,f0_mean"

Create Strings as file list: "wavfiles", audio_folder$ + "*.wav"
selectObject: "Strings wavfiles"
n_files = Get number of strings

for i from 1 to n_files
  selectObject: "Strings wavfiles"
  filename$ = Get string: i
  basename$ = filename$ - ".wav"
  tgpath$   = textgrid_folder$ + basename$ + ".TextGrid"

  if fileReadable(audio_folder$ + filename$) and fileReadable(tgpath$)

    audio = Read from file: audio_folder$ + filename$
    tg    = Read from file: tgpath$
    selectObject: audio
    pit   = To Pitch (ac): 0, floor, 15, "no",
      ... 0.03, 0.45, 0.01, 0.35, 0.14, ceiling

    selectObject: tg
    n_words = Get number of intervals: word_tier

    for w from 1 to n_words
      selectObject: tg
      word_label$ = Get label of interval: word_tier, w

      # 空ラベルをスキップ
      if word_label$ <> ""

        word_xmin = Get start time of interval: word_tier, w
        word_xmax = Get end time of interval:   word_tier, w

        ; xmin + 0.0001: 境界の直後のphone区間を確実に取得する
        p_start = Get interval at time: phone_tier, word_xmin + 0.0001
        p_end   = Get interval at time: phone_tier, word_xmax - 0.0001

        for p from p_start to p_end
          selectObject: tg
          phone_label$ = Get label of interval: phone_tier, p

          # 空ラベルをスキップ
          if phone_label$ <> ""

            phone_xmin = Get start time of interval: phone_tier, p
            phone_xmax = Get end time of interval:   phone_tier, p
            phone_dur  = (phone_xmax - phone_xmin) * 1000

            selectObject: pit
            f0_mean = Get mean: phone_xmin, phone_xmax, "Hertz"

            ; undefined を NA に変換してCSVに出力
            f0_str$ = if f0_mean <> undefined then fixed$(f0_mean, 2) else "NA" fi

            appendFileLine: output_csv$,
              ... basename$, ",", word_label$, ",", phone_label$, ",",
              ... p, ",", fixed$(phone_xmin, 4), ",", fixed$(phone_xmax, 4), ",",
              ... fixed$(phone_dur, 1), ",", f0_str$
          endif
        endfor

      endif
    endfor

    removeObject: audio, tg, pit

  else
    appendInfoLine: "スキップ（ファイル未発見）: ", basename$
  endif
endfor

removeObject: "Strings wavfiles"
appendInfoLine: "完了 → ", output_csv$
