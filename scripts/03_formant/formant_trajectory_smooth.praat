# formant_trajectory_smooth.praat
# フォルマント軌跡を追跡・平滑化して出力する
#
# 『Praatで学ぶ音声研究の方法』付録A-26（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

# ── このスクリプトについて ───────────────────────────────
# フォルマント軌跡を Track で追跡し直し、生の値と並べて出す。
# 追跡がどこで効いたかを確かめられるようにしてある。
#
# 入力: WAVの入ったフォルダ、参照とするF1・F2・F3
# 出力: formant_trajectory_smooth.csv（縦持ち）
#   filename            ファイル名
#   point time_s        点番号と時刻
#   f1_raw f2_raw       To Formant (burg) の生の出力
#   f1_tracked f2_tracked  Track で追跡し直した値
#
# 読み方・注意:
#   - 生の出力はフレーム間でフォルマントが入れ替わることがある
#     （F2とF3の交代など）。Track は参照値の近くに割り当て直す。
#   - 参照値は話者の平均的な値に合わせる。既定値は成人男性の目安である。
#     女性話者では 550 / 1650 / 2750 あたりから試す。
#   - raw と tracked が大きく違う点は、そこで取り違えが起きていた印。
#     多い場合は max_formant の設定自体を見直す。
#   - Track は値を「もっともらしく」する。もっともらしさは
#     正しさではない。formant_trajectory_plot.praat で目視すること。

form Smoothed formant trajectory
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
  positive Max_formant_hz 5500
  positive N_points 20
  positive Reference_f1 500
  positive Reference_f2 1500
  positive Reference_f3 2500
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/formant_trajectory_smooth.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# To Formant (burg) の生の出力はフレーム間で入れ替わることがある（F2とF3の交代など）。
# Track はフォルマントを参照値の近くに割り当て直し、軌跡を連続させる。
# 参照値は話者の平均的な値に合わせること。既定値は成人男性のおおよその値である。

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,point,time_s,f1_raw,f2_raw,f1_tracked,f2_tracked"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  dur = Get total duration
  raw = To Formant (burg): 0, 5, max_formant_hz, 0.025, 50
  tracked = Track: 3, reference_f1, reference_f2, reference_f3, 3850, 4950, 1, 1, 1

  for k from 1 to n_points
    t = (k - 0.5) / n_points * dur
    selectObject: raw
    r1 = Get value at time: 1, t, "hertz", "linear"
    r2 = Get value at time: 2, t, "hertz", "linear"
    selectObject: tracked
    t1 = Get value at time: 1, t, "hertz", "linear"
    t2 = Get value at time: 2, t, "hertz", "linear"
    appendFileLine: output_csv$, f$, ",", k, ",", fixed$(t, 4), ",",
    ... if r1 = undefined then "NA" else fixed$(r1,1) fi, ",",
    ... if r2 = undefined then "NA" else fixed$(r2,1) fi, ",",
    ... if t1 = undefined then "NA" else fixed$(t1,1) fi, ",",
    ... if t2 = undefined then "NA" else fixed$(t2,1) fi
  endfor

  removeObject: raw, tracked, snd
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイル → ", output_csv$
