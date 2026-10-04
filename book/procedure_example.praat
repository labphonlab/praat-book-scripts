# procedure_example.praat
# procedureの基本構文
#
# 『Praatで学ぶ音声研究の方法』ch09掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.

; --- procedureの定義 ---
procedure checkFile: .path$
  ; procedure内の変数名はドット（.）で始めることでローカルスコープになる
  if not fileReadable(.path$)
    exitScript: "ファイルが見つかりません: ", .path$
  endif
  appendInfoLine: "ファイル確認OK: ", .path$
endproc

procedure toNaStr: .val, .decimals
  ; 数値をNA文字列に変換するユーティリティ
  if .val <> undefined
    .result$ = fixed$(.val, .decimals)
  else
    .result$ = "NA"
  endif
endproc

; --- procedureの呼び出し ---
@checkFile: "audio/sp01_a.wav"
@checkFile: "audio/sp02_a.wav"

basename$   = "sp01_a"
output_csv$ = "procedure_example.csv"
mean_f0     = 168.8226
writeFileLine: output_csv$, "file,mean_f0"
@toNaStr: mean_f0, 2
appendFileLine: output_csv$, basename$, ",", toNaStr.result$
