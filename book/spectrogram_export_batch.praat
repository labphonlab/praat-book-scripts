# spectrogram_export_batch.praat
# Script 4.2：スペクトログラム＋TextGridをPDFで一括出力する
#
# 『Praatで学ぶ音声研究の方法』ch04掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form Spectrogram Export Batch
  sentence Audio_folder    audio/
  sentence Textgrid_folder textgrids/
  boolean  Overlay_formant 0
  real     Window_length   0.005
  real     Dynamic_range   60
  real     Freq_max        8000
  real     Ceiling         5500
  sentence Output_folder   figures/
endform

Create Strings as file list: "wavfiles", audio_folder$ + "*.wav"
selectObject: "Strings wavfiles"
n = Get number of strings

for i from 1 to n
  selectObject: "Strings wavfiles"
  wav$ = Get string: i
  stem$ = wav$ - ".wav"
  tgpath$ = textgrid_folder$ + stem$ + ".TextGrid"

  if fileReadable(audio_folder$ + wav$)
    snd = Read from file: audio_folder$ + wav$
    selectObject: snd
    total_dur = Get total duration

    ; スペクトログラム作成
    To Spectrogram: window_length, freq_max, 0.002, 20, "Gaussian"
    spec = selected("Spectrogram")

    ; フォルマント軌跡（オプション）
    if overlay_formant = 1
      selectObject: snd
      fmt = To Formant (burg): 0, 5, ceiling, 0.025, 50
    endif

    ; --- 描画 ---
    Select outer viewport: 0, 15, 0, 5
    Erase all

    ; スペクトログラム本体
    selectObject: spec
    Paint: 0, total_dur, 0, freq_max, 100, "yes", dynamic_range, 6, 0, "no"

    ; フォルマントオーバーレイ（指定時）
    if overlay_formant = 1
      selectObject: fmt
      Red
      Draw tracks: 0, total_dur, freq_max, "no"
      Black
    endif

    ; TextGridオーバーレイ表示
    if fileReadable(tgpath$)
      Read from file: tgpath$
      tg = selected("TextGrid")
      selectObject: snd
      plusObject: tg
      Draw: 0, total_dur, "yes", "yes", "no"
      removeObject: tg
    endif

    ; 軸
    Marks bottom every: 1, 0.05, "yes", "yes", "no"
    Text bottom: "yes", "時間 (s)"
    Marks left every: 1, 1000, "yes", "yes", "no"
    Text left: "yes", "周波数 (Hz)"

    ; 出力
    Select inner viewport: 0, 15, 0, 5
    Save as PDF file: output_folder$ + stem$ + ".pdf"
    Erase all

    ; クリーンアップ
    if overlay_formant = 1
      removeObject: fmt
    endif
    removeObject: spec, snd
    appendInfoLine: i, "/", n, ": ", stem$, ".pdf"
  else
    appendInfoLine: "スキップ: ", wav$
  endif
endfor

removeObject: "Strings wavfiles"
appendInfoLine: "完了: ", n, " ファイルを処理 → ", output_folder$
