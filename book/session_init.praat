# session_init.praat
# Script 15.3：セッション管理ファイルを自動生成するスクリプト
#
# 『Praatで学ぶ音声研究の方法』ch15掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。

form Session Initialization
  sentence Participant_id   sp01
  integer  Session_number   1
  sentence Condition        condition_A
  sentence Experimenter     researcher_name
  sentence Project_dir      experiment_project/
endform

; 参加者フォルダを確認する
participant_dir$ = project_dir$ + "participants/" + participant_id$ + "/"
session_file$    = participant_dir$ + "session_" + string$(session_number) + ".txt"

; セッションファイルを生成する
writeFileLine: session_file$, "=== Session Information ==="
appendFileLine: session_file$, "participant_id:   ", participant_id$
appendFileLine: session_file$, "session_number:   ", session_number
appendFileLine: session_file$, "condition:        ", condition$
appendFileLine: session_file$, "experimenter:     ", experimenter$
appendFileLine: session_file$, "date_time:        ", date$()
appendFileLine: session_file$, "status:           started"
appendFileLine: session_file$, ""
appendFileLine: session_file$, "=== Checklist ==="
appendFileLine: session_file$, "[ ] インフォームドコンセント取得"
appendFileLine: session_file$, "[ ] ヘッドフォン音量確認"
appendFileLine: session_file$, "[ ] 練習試行完了"
appendFileLine: session_file$, "[ ] 本番試行完了"
appendFileLine: session_file$, "[ ] 結果ファイル保存確認"
appendFileLine: session_file$, ""
appendFileLine: session_file$, "completion_flag: not_completed   ; 実験完了後に手動で「completed」に変更"

appendInfoLine: "セッション管理ファイル生成: ", session_file$
appendInfoLine: "参加者: ", participant_id$, " / セッション: ", session_number
appendInfoLine: "条件: ", condition$
