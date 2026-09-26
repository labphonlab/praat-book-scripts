# metadata_merge.praat
# Script 8.5：batch出力にメタデータを自動付加するscript
#
# 『Praatで学ぶ音声研究の方法』ch08掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form Metadata Merge
  sentence Features_csv    results/features.csv
  sentence Metadata_csv    data/speaker_info.csv
  sentence Output_csv      results/features_with_meta.csv
  # features CSV の話者ID列名
  word     Speaker_col     speaker
  # metadata CSV のID列名
  word     Meta_id_col     speaker_id
endform

feat_tbl = Read Table from comma-separated file: features_csv$
meta_tbl = Read Table from comma-separated file: metadata_csv$

selectObject: meta_tbl
n_meta = Get number of rows

; metadata を配列に展開する（高速マッチングのため）
for m from 1 to n_meta
  selectObject: meta_tbl
  meta_id$[m]   = Get value: m, meta_id_col$
  meta_sex$[m]  = Get value: m, "sex"
  meta_age$[m]  = Get value: m, "age"
  meta_dial$[m] = Get value: m, "dialect"
endfor

selectObject: feat_tbl
n_feat = Get number of rows
n_cols = Get number of columns

; ヘッダーを生成する
header$ = ""
for c from 1 to n_cols
  selectObject: feat_tbl
  col$ = Get column label: c
  header$ = if c = 1 then col$ else header$ + "," + col$ fi
endfor
header$ = header$ + ",sex,age,dialect"
writeFileLine: output_csv$, header$

n_merged  = 0
n_missing = 0

for i from 1 to n_feat
  selectObject: feat_tbl
  spk$ = Get value: i, speaker_col$

  ; 最も近いmetadataを検索する
  found = 0
  sex$  = "NA"
  age$  = "NA"
  dial$ = "NA"
  for m from 1 to n_meta
    if meta_id$[m] = spk$ and found = 0
      sex$  = meta_sex$[m]
      age$  = meta_age$[m]
      dial$ = meta_dial$[m]
      found = 1
    endif
  endfor

  ; 行データを読み込んで出力する
  row$ = ""
  for c from 1 to n_cols
    selectObject: feat_tbl
    ; Praatはコマンド呼び出しを引数の中に直接ネストできないため、
    ; 列名を一度変数に受けてから値を取得する
    col$ = Get column label: c
    val$ = Get value: i, col$
    row$ = if c = 1 then val$ else row$ + "," + val$ fi
  endfor
  appendFileLine: output_csv$, row$, ",", sex$, ",", age$, ",", dial$

  if found = 1
    n_merged = n_merged + 1
  else
    appendInfoLine: "警告: メタデータなし → ", spk$
    n_missing = n_missing + 1
  endif
endfor

removeObject: feat_tbl, meta_tbl
appendInfoLine: "メタデータ統合完了: 成功=", n_merged, " / 欠損=", n_missing
