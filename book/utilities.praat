# utilities.praat
# 実用的なprocedureの例
#
# 『Praatで学ぶ音声研究の方法』ch09掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

; 数値をNA文字列に変換する
procedure toStr: .val, .dec
  if .val <> undefined
    .s$ = fixed$(.val, .dec)
  else
    .s$ = "NA"
  endif
endproc

; ファイルの存在を確認して読み込む（存在しなければスキップ）
procedure safeRead: .path$
  # PraatのObject IDは正の整数なので、0を「読み込み失敗」の番兵値として使う
  .obj = 0
  if fileReadable(.path$)
    .obj = Read from file: .path$
  else
    appendInfoLine: "スキップ（ファイルなし）: ", .path$
  endif
endproc

; ===== 使用例 =====
@safeRead: "audio/sp01.wav"
if safeRead.obj <> 0
  snd = safeRead.obj
  selectObject: snd
  dur = Get total duration
  @toStr: dur, 3
  appendInfoLine: "持続時間: ", toStr.s$, " s"
  removeObject: snd
endif
