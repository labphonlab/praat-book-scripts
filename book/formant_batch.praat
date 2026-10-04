# formant_batch.praat
# Script 3.1：母音区間のF1・F2・F3を一括抽出
#
# 『Praatで学ぶ音声研究の方法』ch03掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Formant Batch Extraction
  sentence Audio_folder    audio/
  sentence Textgrid_folder textgrids/
  integer  Tier             1
  real     Ceiling       5500
  integer  Num_formants     5
  real     Window_length  0.025
  sentence Output_csv     results/formants.csv
endform

writeFileLine: output_csv$,
  ... "file,label,t_start,t_end,dur_ms,t_25,t_50,t_75,",
  ... "f1_25,f2_25,f3_25,f1_50,f2_50,f3_50,f1_75,f2_75,f3_75"

Create Strings as file list: "wavfiles", audio_folder$ + "*.wav"
selectObject: "Strings wavfiles"
n = Get number of strings

for i from 1 to n
  selectObject: "Strings wavfiles"
  filename$ = Get string: i
  basename$ = filename$ - ".wav"
  tgpath$   = textgrid_folder$ + basename$ + ".TextGrid"

  if fileReadable(audio_folder$ + filename$) and fileReadable(tgpath$)

    snd = Read from file: audio_folder$ + filename$
    selectObject: snd
    fmt = To Formant (burg): 0, num_formants, ceiling, window_length, 50

    tg = Read from file: tgpath$
    selectObject: tg
    n_int = Get number of intervals: tier

    for j from 1 to n_int
      selectObject: tg
      label$ = Get label of interval: tier, j

      if label$ <> ""
        t1  = Get start time of interval: tier, j
        t2  = Get end time of interval:   tier, j
        dur_ms = (t2 - t1) * 1000

        ; 25%・50%・75%の3時点で測定
        t25 = t1 + (t2 - t1) * 0.25
        t50 = t1 + (t2 - t1) * 0.50
        t75 = t1 + (t2 - t1) * 0.75

        selectObject: fmt
        f1_25 = Get value at time: 1, t25, "Hertz", "Linear"
        f2_25 = Get value at time: 2, t25, "Hertz", "Linear"
        f3_25 = Get value at time: 3, t25, "Hertz", "Linear"
        f1_50 = Get value at time: 1, t50, "Hertz", "Linear"
        f2_50 = Get value at time: 2, t50, "Hertz", "Linear"
        f3_50 = Get value at time: 3, t50, "Hertz", "Linear"
        f1_75 = Get value at time: 1, t75, "Hertz", "Linear"
        f2_75 = Get value at time: 2, t75, "Hertz", "Linear"
        f3_75 = Get value at time: 3, t75, "Hertz", "Linear"

        ; undefinedをNAに変換して出力
        ; undefinedをNAに変換（インライン処理）
        ; 注: procedureはPraatバージョンにより挙動が異なるため
        ;     ここではif-fi 形式のインライン変換を使用する
        f1_25$ = if f1_25 <> undefined then fixed$(f1_25, 1) else "NA" fi
        f2_25$ = if f2_25 <> undefined then fixed$(f2_25, 1) else "NA" fi
        f3_25$ = if f3_25 <> undefined then fixed$(f3_25, 1) else "NA" fi
        f1_50$ = if f1_50 <> undefined then fixed$(f1_50, 1) else "NA" fi
        f2_50$ = if f2_50 <> undefined then fixed$(f2_50, 1) else "NA" fi
        f3_50$ = if f3_50 <> undefined then fixed$(f3_50, 1) else "NA" fi
        f1_75$ = if f1_75 <> undefined then fixed$(f1_75, 1) else "NA" fi
        f2_75$ = if f2_75 <> undefined then fixed$(f2_75, 1) else "NA" fi
        f3_75$ = if f3_75 <> undefined then fixed$(f3_75, 1) else "NA" fi

        appendFileLine: output_csv$,
          ... basename$, ",", label$, ",",
          ... fixed$(t1, 4), ",", fixed$(t2, 4), ",", fixed$(dur_ms, 1), ",",
          ... fixed$(t25, 4), ",", fixed$(t50, 4), ",", fixed$(t75, 4), ",",
          ... f1_25$, ",", f2_25$, ",", f3_25$, ",",
          ... f1_50$, ",", f2_50$, ",", f3_50$, ",",
          ... f1_75$, ",", f2_75$, ",", f3_75$
      endif
    endfor

    removeObject: tg, fmt, snd

  else
    appendInfoLine: "スキップ（ファイル未発見）: ", basename$
  endif
endfor

removeObject: "Strings wavfiles"
appendInfoLine: "完了: ", n, " ファイルを処理 → ", output_csv$
