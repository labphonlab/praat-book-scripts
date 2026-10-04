# reliability_intra.praat
# Script 5.1：intra-rater ICC・κ計算スクリプト
#
# 『Praatで学ぶ音声研究の方法』Script 5.1掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Intra-rater Reliability Calculator
  sentence Csv_file       results/annotations_test_retest.csv
  # 1=数値ICC, 0=カテゴリκ
  boolean  Numeric_data   1
  # カテゴリκの場合のみ使用。データに現れうる全カテゴリ名をカンマ区切りで指定する
  sentence Category_labels PAUSE,FLUENT
  sentence Output_log     results/reliability_intra_log.txt
endform

table = Read Table from comma-separated file: csv_file$
selectObject: table
n = Get number of rows

if numeric_data = 1

  ; ===== ICC計算（2way mixed；consistency型・absolute agreement型の両方を出す） =====
  ; Step1: 全測定値の平均と各測定の平均を計算する
  ; 欠損（undefined）のペアは除外し、実際に使う非欠損ペア数(n_valid)を
  ; 別途数える。以降の平均・SS・MSはすべてn_validで割ること
  ; （nで割ると欠損ペアを分母に含めてしまい値が歪む）
  sum_t1  = 0
  sum_t2  = 0
  n_valid = 0
  for i from 1 to n
    selectObject: table
    v1 = Get value: i, "value_t1"
    v2 = Get value: i, "value_t2"
    if v1 <> undefined and v2 <> undefined
      sum_t1  = sum_t1 + v1
      sum_t2  = sum_t2 + v2
      n_valid = n_valid + 1
    endif
  endfor
  ; n_validが2未満だと被験者間・被験者内のばらつきを分解できず、
  ; 以降の式は0除算または無意味な値になる。ここで打ち切る
  if n_valid < 2

    writeFileLine: output_log$, "=== Intra-rater Reliability: ICC ==="
    appendFileLine: output_log$, "n (rows in CSV): ", n
    appendFileLine: output_log$, "n (valid pairs used): ", n_valid
    appendFileLine: output_log$, "エラー: 有効な非欠損ペア数（n_valid）が2未満のためICCを計算できない。"
    appendFileLine: output_log$, "少なくとも2組以上の有効なペアを含むCSVを用意すること。"

    appendInfoLine: "エラー: n_valid = ", n_valid, " のためICCを計算できない（2以上が必要）"

  else

    grand_mean = (sum_t1 + sum_t2) / (2 * n_valid)

    ; Step2: SS（平方和）の計算
    # 被験者間SS
    ss_between = 0
    # 被験者内SS（測定誤差）
    ss_within  = 0
    # 測定時点間SS
    ss_time    = 0

    mean_t1 = sum_t1 / n_valid
    mean_t2 = sum_t2 / n_valid

    for i from 1 to n
      selectObject: table
      v1 = Get value: i, "value_t1"
      v2 = Get value: i, "value_t2"
      if v1 <> undefined and v2 <> undefined
        row_mean = (v1 + v2) / 2
        ss_between = ss_between + 2 * (row_mean - grand_mean)^2
        ss_within  = ss_within  + (v1 - row_mean)^2 + (v2 - row_mean)^2
      endif
    endfor
    ss_time = n_valid * (mean_t1 - grand_mean)^2 + n_valid * (mean_t2 - grand_mean)^2

    ; Step3: MS（平均二乗）と ICC（consistency型・absolute agreement型の両方）
    ; 分母は総行数nではなく非欠損ペア数n_validを使う
    k_measurements = 2
    ms_between = ss_between / (n_valid - 1)
    ms_within  = (ss_within - ss_time) / (n_valid - 1)
    if ms_within < 0
      # 負にならないよう調整
      ms_within = 0
    endif
    ms_time = ss_time / (k_measurements - 1)

    ; ICC（2-way mixed, consistency）：測定時点間のズレは不一致に数えない
    if ms_between + ms_within > 0
      icc = (ms_between - ms_within) / (ms_between + ms_within)
    else
      icc = undefined
    endif
    icc_str$ = if icc <> undefined then fixed$(icc, 4) else "NA" fi

    ; ICC（2-way mixed, absolute agreement）：測定時点間のズレ（ms_time）も
    ; 分散成分に含める。intra-rater/test-retestではこちらがより妥当な既定値
    denom_abs = ms_between + (k_measurements - 1) * ms_within +
      ... (k_measurements / n_valid) * (ms_time - ms_within)
    if denom_abs > 0
      icc_abs = (ms_between - ms_within) / denom_abs
    else
      icc_abs = undefined
    endif
    icc_abs_str$ = if icc_abs <> undefined then fixed$(icc_abs, 4) else "NA" fi

    writeFileLine: output_log$, "=== Intra-rater Reliability: ICC ==="
    appendFileLine: output_log$, "n (rows in CSV): ", n
    appendFileLine: output_log$, "n (valid pairs used): ", n_valid
    appendFileLine: output_log$, "MS_between:  ", fixed$(ms_between, 4)
    appendFileLine: output_log$, "MS_within:   ", fixed$(ms_within, 4)
    appendFileLine: output_log$, "MS_time:     ", fixed$(ms_time, 4)
    appendFileLine: output_log$, "ICC (consistency):        ", icc_str$
    appendFileLine: output_log$, "ICC (absolute agreement): ", icc_abs_str$
    appendFileLine: output_log$, ""
    appendFileLine: output_log$, "intra-rater/test-retestではabsolute agreementをデフォルトとして"
    appendFileLine: output_log$, "報告することを推奨する（Koo & Li, 2016）。consistencyは、測定者間の"
    appendFileLine: output_log$, "系統的オフセットを許容してよい設計でのみ使うこと。"
    appendFileLine: output_log$, ""
    appendFileLine: output_log$, "解釈の目安（Koo & Li, 2016）:"
    appendFileLine: output_log$, "  < 0.50: 低い / 0.50-0.75: 中程度 / 0.75-0.90: 高い / > 0.90: 非常に高い"

    appendInfoLine: "ICC (consistency) = ", icc_str$, "　ICC (absolute agreement) = ", icc_abs_str$

  endif

else

  ; ===== Cohen's κ計算（カテゴリ数に依存しない一般化版） =====
  ; Category_labelsに列挙された既知カテゴリ名（カンマ区切り）で混同行列の
  ; 行・列を作り、一般化されたP_o・P_eからκを求める。想定外のラベルが
  ; データ中に見つかった場合は、黙って誤集計せずスクリプトを打ち切る
  labels = Create Strings as tokens: category_labels$, ","
  selectObject: labels
  n_categories = Get number of strings
  if n_categories < 2
    exitScript: "Category_labelsには2つ以上のカテゴリ名をカンマ区切りで指定すること",
      ... "（例：PAUSE,FLUENT）。"
  endif

  ; カテゴリごとにt1・t2での出現数を数える表
  cat_counts = Create Table with column names: "cat_counts", n_categories,
    ... "label n_t1 n_t2"
  for k from 1 to n_categories
    selectObject: labels
    lab$ = Get string: k
    selectObject: cat_counts
    Set string value: k, "label", lab$
    Set numeric value: k, "n_t1", 0
    Set numeric value: k, "n_t2", 0
  endfor
  removeObject: labels

  n_agree  = 0
  n_total  = 0

  for i from 1 to n
    selectObject: table
    lab_t1$ = Get value: i, "label_t1"
    lab_t2$ = Get value: i, "label_t2"

    if lab_t1$ <> "" and lab_t2$ <> ""

      ; カテゴリ表の中からlab_t1$・lab_t2$と完全一致する行番号を探す
      idx1 = 0
      idx2 = 0
      for k from 1 to n_categories
        selectObject: cat_counts
        cat_lab$ = Get value: k, "label"
        if cat_lab$ = lab_t1$
          idx1 = k
        endif
        if cat_lab$ = lab_t2$
          idx2 = k
        endif
      endfor

      ; 想定外のラベル（Category_labelsに含まれない）はここでエラーにする
      if idx1 = 0
        exitScript: "行 ", i, " のlabel_t1「", lab_t1$,
          ... "」はCategory_labelsに含まれていない。"
      endif
      if idx2 = 0
        exitScript: "行 ", i, " のlabel_t2「", lab_t2$,
          ... "」はCategory_labelsに含まれていない。"
      endif

      n_total = n_total + 1
      if lab_t1$ = lab_t2$
        n_agree = n_agree + 1
      endif

      selectObject: cat_counts
      cnt1 = Get value: idx1, "n_t1"
      Set numeric value: idx1, "n_t1", cnt1 + 1
      cnt2 = Get value: idx2, "n_t2"
      Set numeric value: idx2, "n_t2", cnt2 + 1
    endif
  endfor

  if n_total > 0
    po = n_agree / n_total
    ; P_e = Σ_k（カテゴリkがt1に出た割合 × t2に出た割合）
    ; カテゴリ数が2でも3以上でも同じ式で一般化して計算できる
    pe = 0
    for k from 1 to n_categories
      selectObject: cat_counts
      cnt1 = Get value: k, "n_t1"
      cnt2 = Get value: k, "n_t2"
      pe = pe + (cnt1 / n_total) * (cnt2 / n_total)
    endfor
    if pe < 1
      kappa = (po - pe) / (1 - pe)
      kappa_str$ = fixed$(kappa, 4)
    else
      ; P_e = 1（全raterが常に同一カテゴリのみを選んだ場合）は
      ; κ = (P_o - P_e) / (1 - P_e) の分母が0になり数学的に未定義である。
      ; この場合κ = 1と決め打ちしない（一致していても偶然一致との区別が
      ; そもそもできないため、値は定義されない）
      kappa_str$ = "undefined (P_e = 1)"
    endif
    po_str$    = fixed$(po, 4)
    pe_str$    = fixed$(pe, 4)
  else
    kappa_str$ = "NA"
    po_str$    = "NA"
    pe_str$    = "NA"
  endif

  writeFileLine: output_log$, "=== Intra-rater Reliability: Cohen's κ ==="
  appendFileLine: output_log$, "カテゴリ数: ", n_categories, " (", category_labels$, ")"
  appendFileLine: output_log$, "n (pairs): ", n_total
  appendFileLine: output_log$, "P_o (実際の一致率): ", po_str$
  appendFileLine: output_log$, "P_e (期待一致率):   ", pe_str$
  appendFileLine: output_log$, "κ:                  ", kappa_str$
  appendFileLine: output_log$, ""
  appendFileLine: output_log$, "注: P_e = 1の場合、κは0/0となり数学的に未定義である（全員が同じ"
  appendFileLine: output_log$, "1カテゴリのみを選んだケースであり、偶然一致と実際の一致を区別できない）。"
  appendFileLine: output_log$, "注: 重み付きκ（順序尺度カテゴリでの近い誤りを軽く扱う版）が必要な"
  appendFileLine: output_log$, "場合はRの irr::kappa2(weight = \"squared\") 等を使用すること。"

  removeObject: cat_counts
  appendInfoLine: "κ = ", kappa_str$
endif

removeObject: table
appendInfoLine: "ログ出力: ", output_log$
