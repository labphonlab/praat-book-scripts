# formant_bw_filter.praat
# Script 3.2：bandwidthフィルタリング付き抽出
#
# 『Praatで学ぶ音声研究の方法』ch03掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form Formant Bandwidth Filter
  sentence Audio_folder    audio/
  sentence Textgrid_folder textgrids/
  integer  Tier             1
  real     Ceiling       5500
  real     Bw1_max       200
  real     Bw2_max       300
  sentence Output_csv     results/formants_reliable.csv
endform

writeFileLine: output_csv$,
  ... "file,label,t_mid,f1,f2,f3,bw1,bw2,reliable"

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
    fmt = To Formant (burg): 0, 5, ceiling, 0.025, 50

    tg = Read from file: tgpath$
    selectObject: tg
    n_int = Get number of intervals: tier

    for j from 1 to n_int
      selectObject: tg
      label$ = Get label of interval: tier, j

      if label$ <> ""
        t1  = Get start time of interval: tier, j
        t2  = Get end time of interval:   tier, j
        mid = (t1 + t2) / 2

        selectObject: fmt
        f1  = Get value at time:     1, mid, "Hertz", "Linear"
        f2  = Get value at time:     2, mid, "Hertz", "Linear"
        f3  = Get value at time:     3, mid, "Hertz", "Linear"
        bw1 = Get bandwidth at time: 1, mid, "Hertz", "Linear"
        bw2 = Get bandwidth at time: 2, mid, "Hertz", "Linear"

        ; undefinedをNAに変換
        f1$  = if f1  <> undefined then fixed$(f1,  1) else "NA" fi
        f2$  = if f2  <> undefined then fixed$(f2,  1) else "NA" fi
        f3$  = if f3  <> undefined then fixed$(f3,  1) else "NA" fi
        bw1$ = if bw1 <> undefined then fixed$(bw1, 1) else "NA" fi
        bw2$ = if bw2 <> undefined then fixed$(bw2, 1) else "NA" fi

        ; bandwidth条件による信頼性フラグ（経験則: F1<200Hz, F2<300Hz を参考値として設定）
        ; bw1・bw2は連続値として出力し、研究者が閾値を後から調整できるようにしている
        if bw1 <> undefined and bw2 <> undefined
          if bw1 < bw1_max and bw2 < bw2_max
            reliable = 1
          else
            reliable = 0
          endif
        else
          # undefinedの場合は信頼性低とマーク
          reliable = 0
        endif

        ; bw値も出力する（後から閾値を変えて再フィルタリングできるよう情報を保持）
        appendFileLine: output_csv$,
          ... basename$, ",", label$, ",", fixed$(mid, 4), ",",
          ... f1$, ",", f2$, ",", f3$, ",",
          ... bw1$, ",", bw2$, ",", reliable
      endif
    endfor

    removeObject: tg, fmt, snd

  else
    appendInfoLine: "スキップ: ", basename$
  endif
endfor

removeObject: "Strings wavfiles"
appendInfoLine: "完了 → ", output_csv$
