# qc_report.praat — 品質チェックレポートの自動生成
#
# 『Praatで学ぶ音声研究の方法』サポートスクリプト集（研究運用編）
# https://github.com/labphonlab/praat-book-scripts
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.
#
# run_pipeline.praat の出力から、そのまま論文の方法欄に書ける形の
# 要約を作る。「何件測って、何件を除外し、何件を目視で確認したか」は
# 報告すべき情報だが、後から数え直すのは手間なので自動化する。
#
# ── 出力 ───────────────────────────────────────────────
# results/qc_report.txt    人が読む要約
# results/qc_summary.csv   話者別の集計（表計算ソフト用）

include lib/ops.praat

form 品質チェックレポート
  comment 空欄のまま OK で results/measurements.csv を読みます。
  sentence Measurements_csv
  positive 端に貼り付いたと見なす割合 0.1
endform

root$ = defaultDirectory$
if measurements_csv$ = ""
  measurements_csv$ = root$ + "/../../results/ops/measurements.csv"
endif
if not fileReadable(measurements_csv$)
  exitScript: "測定結果が無い。先に run_pipeline.praat を実行すること: ", measurements_csv$
endif

tbl = Read Table from comma-separated file: measurements_csv$
n = Get number of rows

report$ = root$ + "/../../results/ops/qc_report.txt"
summary$ = root$ + "/../../results/ops/qc_summary.csv"

writeFileLine: report$, "品質チェックレポート"
appendFileLine: report$, "生成: ", date$()
appendFileLine: report$, "対象: ", measurements_csv$
appendFileLine: report$, ""
appendFileLine: report$, "── 全体 ──"
appendFileLine: report$, "測定対象  ", n, " ファイル"

n_fail = 0
n_flag = 0
for r from 1 to n
  selectObject: tbl
  reason$ = Get value: r, "reason"
  flag$ = Get value: r, "flag"
  if reason$ = "測定不能"
    n_fail = n_fail + 1
  endif
  if flag$ = "1"
    n_flag = n_flag + 1
  endif
endfor

appendFileLine: report$, "測定不能  ", n_fail, " ファイル (", fixed$(100 * n_fail / n, 1), "%)"
appendFileLine: report$, "要確認    ", n_flag, " ファイル (", fixed$(100 * n_flag / n, 1), "%)"
appendFileLine: report$, "問題なし  ", n - n_flag, " ファイル (", fixed$(100 * (n - n_flag) / n, 1), "%)"
appendFileLine: report$, ""

# --- 話者別 ------------------------------------------------------
appendFileLine: report$, "── 話者別 ──"
writeFileLine: summary$, "speaker,n_files,n_flag,flag_rate,f0_mean,f0_min,f0_max,"
... + "pitch_floor,pitch_ceiling,floor_margin_ratio,ceiling_margin_ratio,setting_warning"

Create Strings as tokens: "", " "
seen = selected("Strings")
Remove
# 話者名の一覧を作る
selectObject: tbl
spk_list$ = ""
for r from 1 to n
  s$ = Get value: r, "speaker"
  if index(spk_list$, "|" + s$ + "|") = 0
    spk_list$ = spk_list$ + "|" + s$ + "|"
  endif
endfor

n_warn = 0
pos = 1
while index(spk_list$, "|") > 0
  spk_list$ = right$(spk_list$, length(spk_list$) - index(spk_list$, "|"))
  end_i = index(spk_list$, "|")
  if end_i = 0
    spk_list$ = ""
  else
    spk$ = left$(spk_list$, end_i - 1)
    spk_list$ = right$(spk_list$, length(spk_list$) - end_i)

    cnt = 0
    fl = 0
    sum_f0 = 0
    n_f0 = 0
    min_f0 = 1e9
    max_f0 = 0
    floor_v = 0
    ceil_v = 0
    for r from 1 to n
      selectObject: tbl
      s$ = Get value: r, "speaker"
      if s$ = spk$
        cnt = cnt + 1
        f$ = Get value: r, "flag"
        if f$ = "1"
          fl = fl + 1
        endif
        v$ = Get value: r, "f0_mean_hz"
        if v$ <> "NA"
          v = number(v$)
          sum_f0 = sum_f0 + v
          n_f0 = n_f0 + 1
          if v < min_f0
            min_f0 = v
          endif
          if v > max_f0
            max_f0 = v
          endif
        endif
        floor_v = Get value: r, "pitch_floor"
        ceil_v = Get value: r, "pitch_ceiling"
      endif
    endfor

    warn$ = "ok"
    if n_f0 > 0
      mean_f0 = sum_f0 / n_f0
      # 設定の妥当性: 実測F0が floor / ceiling に近すぎるなら設定が不適切。
      # 端に貼り付いたF0は、真の値ではなく設定に切られた値である疑いがある。
      fm = (min_f0 - floor_v) / floor_v
      cm = (ceil_v - max_f0) / ceil_v
      if fm < 端に貼り付いたと見なす割合
        warn$ = "floorが高すぎる疑い"
        n_warn = n_warn + 1
      endif
      if cm < 端に貼り付いたと見なす割合
        if warn$ = "ok"
          warn$ = "ceilingが低すぎる疑い"
        else
          warn$ = warn$ + "+ceilingが低すぎる疑い"
        endif
        n_warn = n_warn + 1
      endif
      appendFileLine: summary$, spk$, ",", cnt, ",", fl, ",",
      ... fixed$(fl / cnt, 4), ",", fixed$(mean_f0, 2), ",",
      ... fixed$(min_f0, 2), ",", fixed$(max_f0, 2), ",",
      ... floor_v, ",", ceil_v, ",", fixed$(fm, 4), ",", fixed$(cm, 4), ",", warn$
      appendFileLine: report$, spk$, "  ", cnt, " ファイル / 要確認 ", fl,
      ... " / F0 ", fixed$(min_f0, 0), "-", fixed$(max_f0, 0), " Hz  [", warn$, "]"
    else
      appendFileLine: summary$, spk$, ",", cnt, ",", fl, ",",
      ... fixed$(fl / cnt, 4), ",NA,NA,NA,", floor_v, ",", ceil_v, ",NA,NA,F0が取れていない"
      appendFileLine: report$, spk$, "  ", cnt, " ファイル / F0が1件も取れていない"
      n_warn = n_warn + 1
    endif
  endif
endwhile

appendFileLine: report$, ""
appendFileLine: report$, "── 設定の点検 ──"
if n_warn = 0
  appendFileLine: report$, "pitch_floor / pitch_ceiling は実測F0の範囲を十分に含んでいる。"
else
  appendFileLine: report$, "設定に疑いのある話者が ", n_warn, " 件ある。"
  appendFileLine: report$, "実測F0が設定の端に近い場合、その値は真の値ではなく"
  appendFileLine: report$, "設定で切られた値である疑いがある。config/speakers.csv を"
  appendFileLine: report$, "見直してから再実行すること（state/done.csv を消せば再測定する）。"
endif

appendFileLine: report$, ""
appendFileLine: report$, "── 方法欄に書ける文（下書き）──"
appendFileLine: report$, "音響分析には Praat (Boersma & Weenink) を使用した。"
appendFileLine: report$, "F0 とフォルマントは話者ごとに設定した分析範囲で自動抽出し、"
appendFileLine: report$, "計 ", n, " 件のうち ", n_flag, " 件 (", fixed$(100 * n_flag / n, 1),
... "%) に自動判定で確認の印が付いたため、目視で確認した。"
if n_fail > 0
  appendFileLine: report$, "うち ", n_fail, " 件は測定できず、分析から除外した。"
endif

removeObject: tbl

writeInfoLine: "品質チェックレポートを作成した。"
appendInfoLine: ""
appendInfoLine: "  ", report$
appendInfoLine: "  ", summary$
appendInfoLine: ""
appendInfoLine: "測定 ", n, " 件 / 要確認 ", n_flag, " 件 / 測定不能 ", n_fail, " 件 / 設定に疑い ", n_warn, " 件"
