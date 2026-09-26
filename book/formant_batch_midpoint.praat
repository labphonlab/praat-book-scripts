# formant_batch_midpoint.praat
# 母音の中点でF1・F2・F3を一括抽出する
#
# 『Praatで学ぶ音声研究の方法』付録A-19掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form Formant Batch Midpoint
  sentence Audio_folder /audio/
  sentence Textgrid_folder /textgrid/
  sentence Target_tier phones
  sentence Vowel_labels a i u e o
  real Max_formant 5500
  integer Max_formants 5
  sentence Output_csv results/formants.csv
endform

header$ = "file,label,t_mid,dur,F1,F2,F3"
writeFileLine: output_csv$, header$

Create Strings as file list: "wavfiles", audio_folder$ + "*.wav"
n = Get number of strings

for i from 1 to n
  selectObject: "Strings wavfiles"
  wavname$ = Get string: i
  stem$ = wavname$ - ".wav"
  tgpath$ = textgrid_folder$ + stem$ + ".TextGrid"

  if fileReadable (tgpath$)
    Read from file: audio_folder$ + wavname$
    snd = selected("Sound")
    To Formant (burg): 0, max_formants, max_formant, 0.025, 50
    fmt = selected("Formant")

    Read from file: tgpath$
    tg = selected("TextGrid")
    # tier名から番号を探す（この動作をする単独コマンドはない）
    n_tiers  = Get number of tiers
    tier_idx = 0
    for k from 1 to n_tiers
      tname$ = Get tier name: k
      if tname$ = target_tier$
        tier_idx = k
      endif
    endfor

    if tier_idx > 0
      n_int = Get number of intervals: tier_idx
      for j from 1 to n_int
        # ループ内でFormantを選択するので毎回TextGridを選び直す
        selectObject: tg
        lbl$ = Get label of interval: tier_idx, j
        if lbl$ <> "" and index (" " + vowel_labels$ + " ", " " + lbl$ + " ") > 0
          t1 = Get start time of interval: tier_idx, j
          t2 = Get end time of interval:   tier_idx, j
          mid = (t1 + t2) / 2
          dur = t2 - t1

          selectObject: fmt
          f1 = Get value at time: 1, mid, "hertz", "linear"
          f2 = Get value at time: 2, mid, "hertz", "linear"
          f3 = Get value at time: 3, mid, "hertz", "linear"

          f1$ = if f1 <> undefined then fixed$(f1,1) else "NA" fi
          f2$ = if f2 <> undefined then fixed$(f2,1) else "NA" fi
          f3$ = if f3 <> undefined then fixed$(f3,1) else "NA" fi

          appendFileLine: output_csv$,
            ... stem$, ",", lbl$, ",",
            ... fixed$(mid,4), ",", fixed$(dur,4), ",",
            ... f1$, ",", f2$, ",", f3$
        endif
      endfor
    endif
    removeObject: tg, fmt, snd
  endif
endfor
appendInfoLine: "formant抽出完了"
