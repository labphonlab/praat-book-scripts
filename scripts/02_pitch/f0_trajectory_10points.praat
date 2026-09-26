# f0_trajectory_10points.praat
# F0軌跡を10点等間隔で抽出する
#
# 『Praatで学ぶ音声研究の方法』付録A-12（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。

# ── このスクリプトについて ───────────────────────────────
# 各ファイルのF0を、長さで正規化した等間隔の点で取り出す。
# 長さの違う発話どうしで、F0の形（上昇か下降か）を比べるための下ごしらえ。
#
# 入力: WAVの入ったフォルダ、取り出す点数
# 出力: f0_trajectory.csv（縦持ち。1行が1点）
#   filename       ファイル名
#   point          何点目か（1から）
#   rel_position   発話全体を1としたときの相対位置
#   time_s         実時刻（秒）
#   f0_hz          その時刻のF0（Hz）。無声なら NA
#
# 読み方・注意:
#   - 点は (k-0.5)/n の位置に置く。両端ちょうどを取ると、
#     発話の立ち上がり・終わりの不安定な部分を拾いやすい。
#   - 縦持ちにしてあるので、点数を変えても列構成は変わらない。
#     Rなら tidyr::pivot_wider() で横持ちに変えられる。
#   - NA は「測定に失敗した」ではなく「その時刻は無声だった」を含む。
#     両者を区別したいときは voiced_fraction.praat と併せて見る。

form F0 trajectory at equidistant points
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
  positive N_points 10
  positive Pitch_floor 75
  positive Pitch_ceiling 600
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/f0_trajectory_10points.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

# 縦持ち（long format）で出す。点数を変えても列構成が変わらず、R側で扱いやすい。
writeFileLine: output_csv$, "filename,point,rel_position,time_s,f0_hz"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  dur = Get total duration
  pitch = To Pitch: 0, pitch_floor, pitch_ceiling

  for k from 1 to n_points
    # 両端は境界効果を受けやすいので、区間の中央側に等間隔で置く
    rel = (k - 0.5) / n_points
    t = rel * dur
    selectObject: pitch
    f0 = Get value at time: t, "Hertz", "linear"
    if f0 = undefined
      f0$ = "NA"
    else
      f0$ = fixed$(f0, 2)
    endif
    appendFileLine: output_csv$, f$, ",", k, ",", fixed$(rel, 4), ",", fixed$(t, 4), ",", f0$
  endfor

  removeObject: pitch, snd
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイル × ", n_points, " 点 → ", output_csv$
