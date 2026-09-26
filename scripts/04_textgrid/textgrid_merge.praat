# textgrid_merge.praat
# 同名のTextGridどうしを層単位で統合する
#
# 『Praatで学ぶ音声研究の方法』付録A-31（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

# ── このスクリプトについて ───────────────────────────────
# 2つのフォルダにある同名のTextGridを、層単位で1つに統合する。
# 2人の作業者が別々に注釈した結果をまとめる場面を想定する。
#
# 入力: フォルダA、フォルダB
# 出力: 統合したTextGrid、および merge_report.csv
#   stem      拡張子を除いたファイル名
#   in_a in_b それぞれのフォルダにあれば1
#   merged    統合できたら1
#
# 読み方・注意:
#   - ファイル名が一致するものだけを対にする。片方にしか無い
#     ファイルは統合せず、レポートに残す。黙って落とさない。
#   - merged が0の行は必ず確認すること。命名の揺れ（大文字小文字、
#     全角半角）で対にならないことがよくある。
#   - 統合後は層数が両者の合計になる。同じ名前の層が2つ並ぶので、
#     どちらが誰の注釈かを層名で区別できるようにしておくとよい。
#   - 検者間一致率を計算するなら、統合してから
#     書籍第5章のスクリプト（A-41〜A-43）に渡す。

form Merge TextGrids
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Folder_a
  sentence Folder_b
  sentence Output_folder
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if folder_a$ = ""
  folder_a$ = pbs_root$ + "/sample/tg_a/"
endif
if folder_b$ = ""
  folder_b$ = pbs_root$ + "/sample/tg_b/"
endif
if output_folder$ = ""
  output_folder$ = pbs_root$ + "/results/textgrid_merge/"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 2人の作業者が別々に注釈した結果を1つにまとめる、という場面を想定する。
# ファイル名（ステム）が一致するものだけを対にする。
# 片方にしか無いファイルは統合せず、一覧に残して見落とさないようにする。

createDirectory: output_folder$
Create Strings as file list: "a", folder_a$ + "*.TextGrid"
a = selected("Strings")
na = Get number of strings

writeFileLine: output_folder$ + "merge_report.csv", "stem,in_a,in_b,merged"
n_merged = 0
n_unpaired = 0

for i from 1 to na
  selectObject: a
  f$ = Get string: i
  # 存在確認に file list を使うと、無いパスをフォルダとして開こうとして失敗する。
  # fileReadable で直接見る。
  if fileReadable(folder_b$ + f$)
    tga = Read from file: folder_a$ + f$
    tgb = Read from file: folder_b$ + f$
    selectObject: tga, tgb
    m = Merge
    Save as text file: output_folder$ + f$
    removeObject: tga, tgb, m
    n_merged = n_merged + 1
    appendFileLine: output_folder$ + "merge_report.csv", f$ - ".TextGrid", ",1,1,1"
  else
    n_unpaired = n_unpaired + 1
    appendFileLine: output_folder$ + "merge_report.csv", f$ - ".TextGrid", ",1,0,0"
  endif
endfor

removeObject: a
appendInfoLine: "統合 ", n_merged, " 件 / 相手が無かったもの ", n_unpaired, " 件"
appendInfoLine: "出力: ", output_folder$
