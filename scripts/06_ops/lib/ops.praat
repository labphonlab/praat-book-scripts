# ops.praat — 研究運用パックの共通手続き
#
# 『Praatで学ぶ音声研究の方法』サポートスクリプト集（研究運用編）
# https://github.com/labphonlab/praat-book-scripts
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# ここには「バッチを研究に載せる」ために要る4つの仕組みを置いている。
#   1. 設定ファイルの読み込み（数値をスクリプトに直書きしない）
#   2. 実行ログ（いつ・何を・どう処理したかを残す）
#   3. チェックポイント（落ちた所から再開する）
#   4. 集計（結果とログから品質レポートを作る）

# --- 設定ファイル -------------------------------------------------
# key,value 形式のCSVを読み、@cfg で引く。
procedure cfg_load: .path$
  if not fileReadable(.path$)
    exitScript: "設定ファイルが読めない: ", .path$
  endif
  cfg_load.table = Read Table from comma-separated file: .path$
endproc

procedure cfg: .key$
  selectObject: cfg_load.table
  .row = Search column: "key", .key$
  if .row = 0
    exitScript: "設定に項目が無い: ", .key$
  endif
  .value$ = Get value: .row, "value"
  .value = number(.value$)
endproc

# --- ログ ---------------------------------------------------------
# 標準出力に出すだけでは、長時間のバッチで何が起きたか後から追えない。
# 画面とファイルの両方に、時刻付きで残す。
procedure log_open: .path$
  log_open.path$ = .path$
  createDirectory: .path$ - (right$(.path$, length(.path$) - rindex(.path$, "/") + 1))
  writeFileLine: .path$, "# 実行開始 ", date$()
endproc

procedure log: .msg$
  .line$ = "[" + mid$(date$(), 12, 8) + "] " + .msg$
  appendInfoLine: .line$
  appendFileLine: log_open.path$, .line$
endproc

# --- チェックポイント ---------------------------------------------
# 100ファイルの80本目で落ちたとき、最初からやり直さないための仕組み。
# 済んだ組み合わせを1行ずつ書き足し、再実行時は読み込んで飛ばす。
procedure ckpt_load: .path$
  ckpt_load.path$ = .path$
  if fileReadable(.path$)
    ckpt_load.table = Read Table from comma-separated file: .path$
    selectObject: ckpt_load.table
    ckpt_load.n = Get number of rows
  else
    writeFileLine: .path$, "step,speaker,file"
    ckpt_load.table = Create Table with column names: "ckpt", 0, "step speaker file"
    ckpt_load.n = 0
  endif
endproc

procedure ckpt_done: .step$, .speaker$, .file$
  .found = 0
  if ckpt_load.n > 0
    selectObject: ckpt_load.table
    for .r from 1 to ckpt_load.n
      .s$ = Get value: .r, "step"
      .p$ = Get value: .r, "speaker"
      .f$ = Get value: .r, "file"
      if .s$ = .step$ and .p$ = .speaker$ and .f$ = .file$
        .found = 1
      endif
    endfor
  endif
endproc

procedure ckpt_mark: .step$, .speaker$, .file$
  appendFileLine: ckpt_load.path$, .step$, ",", .speaker$, ",", .file$
  selectObject: ckpt_load.table
  Append row
  ckpt_load.n = ckpt_load.n + 1
  Set string value: ckpt_load.n, "step", .step$
  Set string value: ckpt_load.n, "speaker", .speaker$
  Set string value: ckpt_load.n, "file", .file$
endproc

# --- 相対パスの解決 -----------------------------------------------
procedure resolve: .base$, .path$
  if left$(.path$, 1) = "/"
    .out$ = .path$
  else
    .out$ = .base$ + "/" + .path$
  endif
endproc
