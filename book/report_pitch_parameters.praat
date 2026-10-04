# report_pitch_parameters.praat
# Script 2.2：論文用パラメータ記述の自動生成
#
# 『Praatで学ぶ音声研究の方法』ch02掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

form Pitch Analysis Parameters
  real Floor               50
  real Top                800
  real Time_step            0
  real Silence_threshold 0.09
  real Voicing_threshold 0.50
  word Method              filtered_autocorrelation
endform

if time_step = 0
  tstep_str$ = "自動（floor依存）"
else
  tstep_str$ = fixed$(time_step, 3) + " s"
endif

appendInfoLine: "=== 論文用記述文 ==="
appendInfoLine: ""
appendInfoLine: "【日本語】"
appendInfoLine: "F0分析にはPraatのfiltered autocorrelation法を使用した（Pitch floor: ",
  ... floor, " Hz、Pitch top: ", top, " Hz、time step: ", tstep_str$, "、"
appendInfoLine: "silence threshold: ", silence_threshold,
  ... "、voicing threshold: ", voicing_threshold,
  ... "; Boersma, 1993; Boersma, Weenink & Shchupak, 2026）。"
appendInfoLine: ""
appendInfoLine: "【English】"
appendInfoLine: "F0 was extracted using Praat's filtered autocorrelation method ",
  ... "(pitch floor: ", floor, " Hz, pitch top: ", top, " Hz, ",
  ... "time step: ", tstep_str$, ", "
appendInfoLine: "silence threshold: ", silence_threshold,
  ... ", voicing threshold: ", voicing_threshold,
  ... "; Boersma, 1993; Boersma, Weenink & Shchupak, 2026)."
