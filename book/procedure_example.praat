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
@checkFile: "audio/sp01.wav"
@checkFile: "audio/sp02.wav"

@toNaStr: mean_f0, 2
appendFileLine: output_csv$, basename$, ",", toNaStr.result$
