# version_check.praat
# Script 1.1：バージョン確認スクリプト
#
# 『Praatで学ぶ音声研究の方法』ch01掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

version$ = praatVersion$
appendInfoLine: "=============================="
appendInfoLine: "Praat バージョン確認"
appendInfoLine: "=============================="
appendInfoLine: "バージョン: ", version$
appendInfoLine: "確認日時:   ", date$()
appendInfoLine: ""
appendInfoLine: "=== 論文用記述（日本語）==="
appendInfoLine: "音声分析にはPraat（バージョン", version$,
  ... "; Boersma, Weenink & Shchupak, 2026）を使用した。"
appendInfoLine: ""
appendInfoLine: "=== Methods section (English) ==="
appendInfoLine: "Acoustic analyses were performed using Praat (version ", version$,
  ... "; Boersma, Weenink, & Shchupak, 2026)."
