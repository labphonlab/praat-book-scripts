# pitch_smoothed_batch.praat
# pitchを平滑化して統計量を比較する
#
# 『Praatで学ぶ音声研究の方法』付録A-17（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。

# ── このスクリプトについて ───────────────────────────────
# F0軌跡を平滑化し、平滑化前後の統計量を並べて出す。
# 平滑化がデータをどれだけ変えたかを、捨てずに記録するためのもの。
#
# 入力: WAVの入ったフォルダ、平滑化の帯域幅（Hz）
# 出力: pitch_smoothed.csv
#   filename        ファイル名
#   mean_raw        平滑化前の平均F0
#   sd_raw          平滑化前の標準偏差
#   mean_smooth     平滑化後の平均F0
#   sd_smooth       平滑化後の標準偏差
#   sd_reduction    標準偏差の減少率（1 - sd_smooth/sd_raw）
#
# 読み方・注意:
#   - Smooth は平滑化と同時に無声フレームを補間する。軌跡の見た目は
#     整うが、無声区間にも値が入る。したがって有声区間率や
#     無声区間の分析を、平滑化後のPitchから取ってはいけない。
#   - sd_reduction が大きいファイルは、平滑化で情報が多く失われている。
#     0.5を超えるなら、平滑化が強すぎないか、あるいは元の抽出に
#     オクターブ誤りが多くないかを疑う。
#   - 帯域幅は小さいほど平滑化が強い。10 Hz あたりが出発点になる。

form Smoothed pitch batch
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_csv
  positive Pitch_floor 75
  positive Pitch_ceiling 600
  positive Smoothing_bandwidth_hz 10
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_csv$ = ""
  output_csv$ = pbs_root$ + "/results/pitch_smoothed_batch.csv"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# Smooth は平滑化と同時に無声フレームを補間する。
# 軌跡の見た目は整うが、無声区間まで値が埋まるので、
# 有声区間率などの指標を平滑化後のPitchから取ってはいけない。

Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

writeFileLine: output_csv$, "filename,mean_raw,sd_raw,mean_smooth,sd_smooth,sd_reduction"

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  snd = Read from file: input_folder$ + f$
  pitch = To Pitch: 0, pitch_floor, pitch_ceiling

  mean_raw = Get mean: 0, 0, "Hertz"
  sd_raw = Get standard deviation: 0, 0, "Hertz"

  selectObject: pitch
  smooth = Smooth: smoothing_bandwidth_hz
  mean_sm = Get mean: 0, 0, "Hertz"
  sd_sm = Get standard deviation: 0, 0, "Hertz"

  if mean_raw = undefined or sd_raw = undefined
    appendFileLine: output_csv$, f$, ",NA,NA,NA,NA,NA"
  else
    if sd_raw > 0
      red$ = fixed$(1 - sd_sm / sd_raw, 4)
    else
      red$ = "NA"
    endif
    appendFileLine: output_csv$, f$, ",", fixed$(mean_raw,2), ",", fixed$(sd_raw,3), ",",
    ... fixed$(mean_sm,2), ",", fixed$(sd_sm,3), ",", red$
  endif

  removeObject: pitch, smooth, snd
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイル → ", output_csv$
