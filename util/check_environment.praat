# check_environment.praat
# 実行環境を確認する
#
# 『Praatで学ぶ音声研究の方法』サポートスクリプト集
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.
#
# うまく動かないときに、まず何が足りないかを切り分けるためのものです。

writeInfoLine: "=== 実行環境の確認 ==="
appendInfoLine: ""
appendInfoLine: "Praatバージョン: ", praatVersion$, "  (数値: ", praatVersion, ")"

if praatVersion >= 7000
  appendInfoLine: "  7.0系です。コマンドラインからの書き出しには --FULL-TRUST が要ります。"
  appendInfoLine: "  GUIのScript editorから実行する場合は不要です。"
elsif praatVersion >= 6400
  appendInfoLine: "  6.4系です。本スクリプト集は動作しますが、書籍は7.0.02を基準にしています。"
else
  appendInfoLine: "  【要更新】6.4より前の版です。praat.org から新しい版を入れてください。"
endif

appendInfoLine: ""
appendInfoLine: "このスクリプトの位置: ", defaultDirectory$
root$ = defaultDirectory$ + "/.."

appendInfoLine: ""
appendInfoLine: "--- 同梱物の確認 ---"
n_missing = 0
paths$# = {"/sample/audio/spk1_a.wav", "/sample/bySpeaker/spk1/spk1_a.wav",
... "/sample/tg_a/spk1_a.TextGrid", "/sample/fixture_truth.csv",
... "/scripts/02_pitch/pitch_percentile.praat", "/book/wav_list_to_csv.praat"}
for i from 1 to size(paths$#)
  if fileReadable(root$ + paths$# [i])
    appendInfoLine: "  ok   ", paths$# [i]
  else
    appendInfoLine: "  なし ", paths$# [i]
    n_missing = n_missing + 1
  endif
endfor

appendInfoLine: ""
if n_missing > 0
  appendInfoLine: "【問題】", n_missing, " 件が見つかりません。"
  appendInfoLine: "ZIPを展開したフォルダ構成のまま実行してください。"
  appendInfoLine: "スクリプトだけを別の場所へ移すと、同梱サンプルを参照できません。"
else
  appendInfoLine: "同梱物はそろっています。START_HERE.praat を実行してください。"
endif

appendInfoLine: ""
appendInfoLine: "--- 書き出しの可否 ---"
createDirectory: root$ + "/results"
writeFileLine: root$ + "/results/_write_test.txt", "ok"
if fileReadable(root$ + "/results/_write_test.txt")
  deleteFile: root$ + "/results/_write_test.txt"
  appendInfoLine: "  results/ に書き出せます。"
else
  appendInfoLine: "  【問題】書き出せません。フォルダの権限を確認してください。"
endif
