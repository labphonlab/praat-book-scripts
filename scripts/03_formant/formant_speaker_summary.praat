# formant_speaker_summary.praat
# 話者別にフォルマント統計をまとめる
#
# 『Praatで学ぶ音声研究の方法』付録A-25（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

# ── このスクリプトについて ───────────────────────────────
# 話者ごとにフォルマントの分布をまとめる。
# 話者間の比較の前に、各話者の測定が妥当かを確かめるために使う。
#
# 入力: root/話者名/*.wav という構成のフォルダ
# 出力: formant_speaker_summary.csv
#   speaker              話者名
#   n_files n_measured   ファイル数と測定できた件数
#   f1_mean f1_sd        F1の平均と標準偏差
#   f2_mean f2_sd        F2の平均と標準偏差
#   f1_min f1_max        F1の範囲
#   f2_min f2_max        F2の範囲
#
# 読み方・注意:
#   - n_measured が n_files より目立って少ない話者は、
#     max_formant の設定がその話者に合っていない疑いがある。
#   - 話者間で f1_mean が大きく違うのは自然である（声道長の差）。
#     Lobanov正規化はこの差を取り除くためのものである。
#   - f1_max が 1200 Hz を大きく超える話者は、取り違えを疑う。
#     formant_manual_flag.praat で該当ファイルを特定できる。

form Formant summary by speaker
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Root_folder
  sentence Output_csv
  positive Max_formant_hz 5500
  positive Measure_at_relative 0.5
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if root_folder$ = ""
  root_folder$ = pbs_root$ + "/sample/bySpeaker/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/formant_speaker_summary.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

Create Strings as directory list: "dirs", root_folder$
dirs = selected("Strings")
n_spk = Get number of strings

writeFileLine: output_csv$, "speaker,n_files,n_measured,f1_mean,f1_sd,f2_mean,f2_sd,f1_min,f1_max,f2_min,f2_max"

for s from 1 to n_spk
  selectObject: dirs
  spk$ = Get string: s
  Create Strings as file list: "wavs", root_folder$ + spk$ + "/*.wav"
  wavs = selected("Strings")
  n_files = Get number of strings

  s1 = 0
  s2 = 0
  q1 = 0
  q2 = 0
  n_ok = 0
  f1min = 1e9
  f1max = 0
  f2min = 1e9
  f2max = 0

  for i from 1 to n_files
    selectObject: wavs
    f$ = Get string: i
    snd = Read from file: root_folder$ + spk$ + "/" + f$
    dur = Get total duration
    t = measure_at_relative * dur
    formant = To Formant (burg): 0, 5, max_formant_hz, 0.025, 50
    f1 = Get value at time: 1, t, "hertz", "linear"
    f2 = Get value at time: 2, t, "hertz", "linear"
    removeObject: formant, snd
    if f1 <> undefined and f2 <> undefined
      n_ok = n_ok + 1
      s1 = s1 + f1
      s2 = s2 + f2
      q1 = q1 + f1 * f1
      q2 = q2 + f2 * f2
      if f1 < f1min
        f1min = f1
      endif
      if f1 > f1max
        f1max = f1
      endif
      if f2 < f2min
        f2min = f2
      endif
      if f2 > f2max
        f2max = f2
      endif
    endif
  endfor

  if n_ok >= 2
    m1 = s1 / n_ok
    m2 = s2 / n_ok
    sd1 = sqrt(max((q1 - n_ok * m1 * m1) / (n_ok - 1), 0))
    sd2 = sqrt(max((q2 - n_ok * m2 * m2) / (n_ok - 1), 0))
    appendFileLine: output_csv$, spk$, ",", n_files, ",", n_ok, ",",
    ... fixed$(m1,1), ",", fixed$(sd1,1), ",", fixed$(m2,1), ",", fixed$(sd2,1), ",",
    ... fixed$(f1min,1), ",", fixed$(f1max,1), ",", fixed$(f2min,1), ",", fixed$(f2max,1)
  else
    appendFileLine: output_csv$, spk$, ",", n_files, ",", n_ok, ",NA,NA,NA,NA,NA,NA,NA,NA"
  endif

  removeObject: wavs
endfor

removeObject: dirs
appendInfoLine: "完了: ", n_spk, " 話者 → ", output_csv$
