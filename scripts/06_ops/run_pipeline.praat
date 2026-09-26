# run_pipeline.praat — 設定ファイル駆動の一括実行
#
# 『Praatで学ぶ音声研究の方法』サポートスクリプト集（研究運用編）
# https://github.com/labphonlab/praat-book-scripts
# Copyright (c) 2026 Takeshi Ishihara / 言叢出版
# 本書の購入者に限り、研究・教育目的での使用および改変を許諾する。
# 再配布・再公開は不可。詳細は LICENSE を参照。
#
# ── 使い方 ─────────────────────────────────────────────
# 1. config/settings.csv と config/speakers.csv を自分のデータに合わせて直す
# 2. このファイルをPraatで開いて Run
# 3. 途中で止まったら、もう一度 Run すれば続きから走る
#
# 設定をスクリプトに直書きしないのは、解析条件を後から辿れるようにするため。
# 論文の方法欄に書く値が、そのままCSVとして残る。
#
# ── 出力 ───────────────────────────────────────────────
# results/measurements.csv   1行1ファイルの測定値
# logs/run_*.log             時刻付きの実行記録
# state/done.csv             済んだ処理（再開に使う。消すと最初からやり直す）

include lib/ops.praat

form 一括実行
  comment 空欄のまま OK で、同梱サンプルと config/ の設定を使います。
  sentence Settings_csv
  sentence Speakers_csv
  boolean 最初からやり直す 0
endform

root$ = defaultDirectory$
if settings_csv$ = ""
  settings_csv$ = root$ + "/config/settings.csv"
endif
if speakers_csv$ = ""
  speakers_csv$ = root$ + "/config/speakers.csv"
endif

createDirectory: root$ + "/../../results"
createDirectory: root$ + "/../../results/ops"
createDirectory: root$ + "/../../results/ops/logs"
createDirectory: root$ + "/../../results/ops/state"
stamp$ = replace$(replace$(date$(), " ", "_", 0), ":", "", 0)
@log_open: root$ + "/../../results/ops/logs/run_" + stamp$ + ".log"
@log: "研究運用パック 一括実行"
@log: "設定: " + settings_csv$

@cfg_load: settings_csv$
@cfg: "input_root"
input_root$ = cfg.value$
@cfg: "output_dir"
output_dir$ = cfg.value$
@cfg: "measure_at_relative"
rel = cfg.value
@cfg: "formant_n"
formant_n = cfg.value
@cfg: "f1_plausible_min"
f1lo = cfg.value
@cfg: "f1_plausible_max"
f1hi = cfg.value
@cfg: "f2_plausible_min"
f2lo = cfg.value
@cfg: "f2_plausible_max"
f2hi = cfg.value
@cfg: "max_bandwidth_ratio"
bwmax = cfg.value

@resolve: root$, input_root$
in_root$ = resolve.out$
@resolve: root$, output_dir$
out_dir$ = resolve.out$
createDirectory: out_dir$
out_csv$ = out_dir$ + "/measurements.csv"

# --- チェックポイント -------------------------------------------
ckpt$ = root$ + "/../../results/ops/state/done.csv"
if 最初からやり直す
  if fileReadable(ckpt$)
    deleteFile: ckpt$
  endif
  if fileReadable(out_csv$)
    deleteFile: out_csv$
  endif
  @log: "state と results を消して最初から実行する"
endif
@ckpt_load: ckpt$
@log: "済み記録: " + string$(ckpt_load.n) + " 件"

if not fileReadable(out_csv$)
  writeFileLine: out_csv$, "speaker,filename,f0_mean_hz,f0_sd_hz,voiced_fraction,"
  ... + "f1_hz,f2_hz,b1_hz,flag,reason,pitch_floor,pitch_ceiling,max_formant"
endif

# --- 話者別設定 --------------------------------------------------
spk_table = Read Table from comma-separated file: speakers_csv$
n_spk = Get number of rows
@log: "話者設定: " + string$(n_spk) + " 名"

n_done = 0
n_skip = 0
n_fail = 0
n_flag = 0

for s from 1 to n_spk
  selectObject: spk_table
  spk$ = Get value: s, "speaker"
  p_floor = Get value: s, "pitch_floor"
  p_ceil = Get value: s, "pitch_ceiling"
  maxf = Get value: s, "max_formant"

  spk_dir$ = in_root$ + "/" + spk$
  Create Strings as file list: "wavs", spk_dir$ + "/*.wav"
  wavs = selected("Strings")
  nf = Get number of strings
  @log: spk$ + ": " + string$(nf) + " ファイル (floor=" + string$(p_floor)
  ... + " ceiling=" + string$(p_ceil) + " maxF=" + string$(maxf) + ")"

  for i from 1 to nf
    selectObject: wavs
    f$ = Get string: i

    @ckpt_done: "measure", spk$, f$
    if ckpt_done.found
      n_skip = n_skip + 1
    else
      # 1ファイルの失敗で全体を止めない。記録して次へ進む。
      snd = Read from file: spk_dir$ + "/" + f$
      dur = Get total duration
      t = rel * dur

      pitch = To Pitch: 0, p_floor, p_ceil
      f0m = Get mean: 0, 0, "Hertz"
      f0sd = Get standard deviation: 0, 0, "Hertz"
      n_fr = Get number of frames
      n_v = Count voiced frames
      removeObject: pitch

      selectObject: snd
      formant = To Formant (burg): 0, formant_n, maxf, 0.025, 50
      f1 = Get value at time: 1, t, "hertz", "linear"
      f2 = Get value at time: 2, t, "hertz", "linear"
      b1 = Get bandwidth at time: 1, t, "hertz", "linear"
      removeObject: formant, snd

      reason$ = ""
      if f1 = undefined or f2 = undefined
        reason$ = "測定不能"
        n_fail = n_fail + 1
      else
        if f1 >= f2
          reason$ = reason$ + "F1>=F2;"
        endif
        if f1 < f1lo or f1 > f1hi
          reason$ = reason$ + "F1範囲外;"
        endif
        if f2 < f2lo or f2 > f2hi
          reason$ = reason$ + "F2範囲外;"
        endif
        if b1 <> undefined and f1 > 0
          if b1 / f1 > bwmax
            reason$ = reason$ + "B1過大;"
          endif
        endif
      endif
      if reason$ = ""
        flag = 0
        reason$ = "ok"
      else
        flag = 1
        n_flag = n_flag + 1
      endif

      if n_fr > 0
        vf$ = fixed$(n_v / n_fr, 4)
      else
        vf$ = "NA"
      endif

      appendFileLine: out_csv$, spk$, ",", f$, ",",
      ... if f0m = undefined then "NA" else fixed$(f0m, 2) fi, ",",
      ... if f0sd = undefined then "NA" else fixed$(f0sd, 3) fi, ",", vf$, ",",
      ... if f1 = undefined then "NA" else fixed$(f1, 1) fi, ",",
      ... if f2 = undefined then "NA" else fixed$(f2, 1) fi, ",",
      ... if b1 = undefined then "NA" else fixed$(b1, 1) fi, ",",
      ... flag, ",", reason$, ",", p_floor, ",", p_ceil, ",", maxf

      @ckpt_mark: "measure", spk$, f$
      n_done = n_done + 1
    endif
  endfor
  removeObject: wavs
endfor

removeObject: spk_table, cfg_load.table, ckpt_load.table

@log: "--- 集計 ---"
@log: "新たに処理: " + string$(n_done) + " / 既済みで飛ばした: " + string$(n_skip)
@log: "測定不能: " + string$(n_fail) + " / 要確認の印: " + string$(n_flag)
@log: "結果: " + out_csv$
@log: "完了"

appendInfoLine: ""
appendInfoLine: "品質レポートを作るには qc_report.praat を実行してください。"
