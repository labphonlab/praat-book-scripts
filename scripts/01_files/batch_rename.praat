# batch_rename.praat
# ファイル名を一括で付け替える（連番・プレフィックス付与）
#
# 『Praatで学ぶ音声研究の方法』付録A-6（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# 注意: 書き出しを伴うため、コマンドラインからは --FULL-TRUST を付けて実行する。
#   Praat --run --FULL-TRUST batch_rename.praat <引数...>

# ── このスクリプトについて ───────────────────────────────
# フォルダ内のWAVを読み込み、連番付きの新しい名前で別フォルダに書き出す。
# 元のファイルは変更しない。名前の対応表を必ず残すので、後から元をたどれる。
#
# 入力: WAVの入ったフォルダ
# 出力: output_folder/ に改名済みWAV、および rename_map.csv
#   old_name   元のファイル名
#   new_name   新しいファイル名
#
# 読み方・注意:
#   - 連番はゼロ詰めにしてある。1, 2, ..., 10 のままだと辞書順で
#     「1, 10, 2」と並び、後段のバッチ処理で順序が狂う。
#   - keep_original_name を1にすると元の名前を末尾に残す。
#     由来を追える代わりに名前は長くなる。
#   - 改名は情報を捨てる操作である。rename_map.csv を消さないこと。

form Batch rename
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Input_folder
  sentence Output_folder
  sentence Prefix spk
  positive Digits 3
  boolean Keep_original_name 0
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if input_folder$ = ""
  input_folder$ = pbs_root$ + "/sample/audio/"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/batch_rename/"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

createDirectory: output_folder$
Create Strings as file list: "files", input_folder$ + "*.wav"
list = selected("Strings")
n = Get number of strings
if n = 0
  exitScript: "WAVファイルが見つからない: ", input_folder$
endif

writeFileLine: output_folder$ + "rename_map.csv", "old_name,new_name"

for i from 1 to n
  selectObject: list
  old$ = Get string: i

  # 連番はゼロ詰めにする。1,2,...,10 が辞書順で並ばない事故を防ぐため。
  seq$ = string$(i)
  while length(seq$) < digits
    seq$ = "0" + seq$
  endwhile

  if keep_original_name
    stem$ = old$ - ".wav"
    new$ = prefix$ + "_" + seq$ + "_" + stem$ + ".wav"
  else
    new$ = prefix$ + "_" + seq$ + ".wav"
  endif

  snd = Read from file: input_folder$ + old$
  Save as WAV file: output_folder$ + new$
  removeObject: snd

  appendFileLine: output_folder$ + "rename_map.csv", old$, ",", new$
endfor

removeObject: list
appendInfoLine: "完了: ", n, " ファイルを ", output_folder$, " に書き出した"
appendInfoLine: "対応表: ", output_folder$, "rename_map.csv"
