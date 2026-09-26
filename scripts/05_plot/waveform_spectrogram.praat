# waveform_spectrogram.praat
# 波形とスペクトログラムを縦に並べて描く
#
# 『Praatで学ぶ音声研究の方法』付録A-38（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

# ── このスクリプトについて ───────────────────────────────
# 波形（上段）とスペクトログラム（下段）を縦に並べた図を
# ファイルごとにPDFで出す。
#
# 入力: WAVの入ったフォルダ、窓長（秒）
# 出力: ファイルごとに1枚のPDF
#
# 読み方・注意:
#   - 窓長で見えるものが変わる。0.005秒前後は広帯域スペクトログラムで、
#     フォルマントが横縞として見える。0.03秒前後は狭帯域で、
#     倍音が横線として見える。目的に応じて使い分ける。
#   - 上段と下段は時間軸が揃えてある。波形で見た振幅の変化と
#     スペクトルの変化を対応付けて読める。
#   - 濃さの範囲（dynamic range）は既定で50 dB。雑音の多い録音では
#     40 dB程度に狭めると見やすくなる。

form Waveform and spectrogram
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_folder
  positive Spectrogram_max_hz 5000
  positive Window_length_s 0.005
  boolean One_file_per_pdf 1
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/waveform_spectrogram/"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 窓長0.005秒は広帯域スペクトログラム（フォルマントが見える）、
# 0.03秒前後にすると狭帯域（倍音が見える）になる。目的で使い分ける。

createDirectory: output_folder$
Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings

for i from 1 to n
  selectObject: list
  f$ = Get string: i
  stem$ = f$ - ".wav"
  snd = Read from file: input_folder$ + f$
  dur = Get total duration

  Erase all
  # 上段: 波形
  Select outer viewport: 0, 6, 0, 2.5
  selectObject: snd
  Draw: 0, 0, 0, 0, "yes", "Curve"

  # 下段: スペクトログラム
  Select outer viewport: 0, 6, 2.2, 5.5
  spec = To Spectrogram: window_length_s, spectrogram_max_hz, 0.002, 20, "Gaussian"
  Paint: 0, 0, 0, 0, 100, "yes", 50, 6, 0, "no"
  Marks bottom every: 1, 0.1, "yes", "yes", "no"
  Marks left every: 1, 1000, "yes", "yes", "no"
  Text bottom: "yes", "時間 (s)"
  Text left: "yes", "周波数 (Hz)"

  Save as PDF file: output_folder$ + stem$ + ".pdf"
  removeObject: spec, snd
endfor

removeObject: list
appendInfoLine: "作図 ", n, " 件 → ", output_folder$
