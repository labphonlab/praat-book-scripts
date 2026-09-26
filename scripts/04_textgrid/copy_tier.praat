# copy_tier.praat
# あるTextGridの層を別のTextGridに複製する
#
# 『Praatで学ぶ音声研究の方法』付録A-28（骨格）の完全版
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

# ── このスクリプトについて ───────────────────────────────
# あるTextGridの1層を、別のTextGridに複製して足す。
# 別の作業者が付けた層を自分の注釈に取り込む場面を想定する。
#
# 入力: 複製元のTextGrid、複製先のTextGrid、複製する層番号
# 出力: 層が足された新しいTextGrid（別名で保存）
#
# 読み方・注意:
#   - 元のファイルは書き換えない。上書きは取り返しがつかない。
#   - 2つのTextGridの時間領域（xmin/xmax）が違う場合、
#     Merge は両方を含む領域に広げる。対応する音声と
#     長さが合っているかを確かめること。
#   - 層は末尾に追加される。順番を変えたいときはPraatのGUIで
#     Modify → Move tier を使う。

form Copy a tier between TextGrids
  comment 空欄のまま OK を押すと、同梱のサンプル音声で動きます。
  comment 自分のデータを使うときだけフォルダを指定してください。
  sentence Source_textgrid
  sentence Target_textgrid
  positive Source_tier 1
  sentence Output_textgrid
endform

# --- 既定値の解決 ------------------------------------------------
# 空欄で実行された項目を、同梱サンプルと results/ で埋める。
# 読み込み専用の確認ができるよう、出力は必ず results/ 側に向ける。
pbs_root$ = defaultDirectory$ + "/../.."
if source_textgrid$ = ""
  source_textgrid$ = pbs_root$ + "/sample/tg_b/spk1_a.TextGrid"
endif
if target_textgrid$ = ""
  target_textgrid$ = pbs_root$ + "/sample/tg_a/spk1_a.TextGrid"
endif
if output_textgrid$ = ""
  output_textgrid$ = pbs_root$ + "/results/copy_tier.TextGrid"
endif
createDirectory: pbs_root$ + "/results"
# -----------------------------------------------------------------

# 別の作業者が付けた層を自分のTextGridに取り込む、といった場面で使う。
# 元ファイルは書き換えず、別名で保存する。上書きは事故のもとである。

src = Read from file: source_textgrid$
n_src = Get number of tiers
if source_tier > n_src
  exitScript: "層番号が範囲外: ", source_tier, " / 全", n_src, "層"
endif
one = Extract one tier: source_tier

tgt = Read from file: target_textgrid$
n_before = Get number of tiers

selectObject: tgt, one
merged = Merge
n_after = Get number of tiers
Save as text file: output_textgrid$

removeObject: src, one, tgt, merged
appendInfoLine: "層 ", source_tier, " を複製した"
appendInfoLine: "層数 ", n_before, " → ", n_after
appendInfoLine: "保存: ", output_textgrid$
