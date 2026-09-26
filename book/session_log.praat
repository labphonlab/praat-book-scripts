# session_log.praat
# セッションログの自動出力
#
# 『Praatで学ぶ音声研究の方法』ch12掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

procedure dump_session_log: .output_csv$, .pitch_floor, .pitch_ceiling,
  ... .formant_ceiling, .bw1_threshold, .bw2_threshold, .target_labels$

  ; ログファイル名をCSVと同じ場所に生成する
  .log$ = .output_csv$ - ".csv" + "_session_log.txt"

  ; 日時をファイル名に使える形式に変換する
  ; date$()は "Mon Apr 28 15:48:32 2026" 形式を返す
  .date_raw$ = date$()
  .year$  = right$(.date_raw$, 4)
  # 月の略称（Apr等）
  .month$ = mid$(.date_raw$, 5, 3)

  writeFileLine: .log$, "=== Session Log ==="
  appendFileLine: .log$, "Date:          ", .date_raw$
  appendFileLine: .log$, "Praat version: ", praatVersion$
  appendFileLine: .log$, "Script:        vowel_extractor.praat"
  appendFileLine: .log$, ""
  appendFileLine: .log$, "--- Analysis Parameters ---"
  appendFileLine: .log$, "pitch_floor:      ", .pitch_floor,     " Hz"
  appendFileLine: .log$, "pitch_ceiling:    ", .pitch_ceiling,   " Hz"
  appendFileLine: .log$, "formant_ceiling:  ", .formant_ceiling, " Hz"
  appendFileLine: .log$, "bw1_threshold:    ", .bw1_threshold,   " Hz  (経験則)"
  appendFileLine: .log$, "bw2_threshold:    ", .bw2_threshold,   " Hz  (経験則)"
  appendFileLine: .log$, "target_labels:    ", .target_labels$
  appendFileLine: .log$, ""
  appendFileLine: .log$, "--- Output ---"
  appendFileLine: .log$, "Output CSV:    ", .output_csv$
  appendFileLine: .log$, "=== End Log ==="

  appendInfoLine: "Session log: ", .log$
endproc

; 呼び出し（分析完了後）
@dump_session_log: output_csv$, pitch_floor, pitch_ceiling,
  ... formant_ceiling, bw1_threshold, bw2_threshold, target_labels$
