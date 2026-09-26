# spectrogram_settings_report.praat
# Script 4.1：設定を記録して論文用記述を生成する
#
# 『Praatで学ぶ音声研究の方法』ch04掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form Spectrogram Settings Report
  real Window_length_ms  5.0
  real Dynamic_range_dB 60.0
  real Frequency_max_hz 8000.0
  word Window_function   Gaussian
endform

wl$ = fixed$(window_length_ms, 1)
dr$ = fixed$(dynamic_range_dB, 0)
fm$ = fixed$(frequency_max_hz, 0)

appendInfoLine: "=== スペクトログラム設定 ==="
appendInfoLine: "窓長:           ", wl$, " ms"
appendInfoLine: "ダイナミックレンジ: ", dr$, " dB"
appendInfoLine: "表示周波数上限:  ", fm$, " Hz"
appendInfoLine: "窓関数:          ", window_function$
appendInfoLine: ""
appendInfoLine: "=== 論文用記述（日本語）==="
appendInfoLine: "スペクトログラムは", window_function$, "窓（窓長", wl$, " ms）を使用した。"
appendInfoLine: "表示範囲は0〜", fm$, " Hz、ダイナミックレンジは", dr$, " dBとした。"
appendInfoLine: ""
appendInfoLine: "=== Figure caption (English) ==="
appendInfoLine: "Wideband spectrogram (", window_function$, " window, window length: ",
  ... wl$, " ms; dynamic range: ", dr$, " dB; frequency range: 0–", fm$, " Hz)."
