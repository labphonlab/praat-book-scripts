#!/usr/bin/env python3
"""book/ の書籍掲載スクリプトを実際にPraatで走らせる。

原稿から抽出しただけでは、それが動く保証はない。実際に走らせる。

書籍のスクリプトは説明のための断片や、GUI操作を前提にしたものを含む。
それらは「失敗」ではないので、走らせる前に分類する。
  runnable    … バッチで走らせて結果を見る
  interactive … View & Edit など画面操作を伴う。実行対象外
  fragment    … 手続き定義のみなど、単体では走らない。構文だけ見る
"""
import json, pathlib, re, shutil, subprocess, sys

ROOT  = pathlib.Path(__file__).parent.parent
PRAAT = "/Applications/Praat.app/Contents/MacOS/Praat"
FX       = pathlib.Path("/tmp/pbs_book_fx")
PRISTINE = pathlib.Path("/tmp/pbs_book_pristine")

INTERACTIVE = re.compile(r'^\s*(View & Edit|Edit|pause|beginPause|demo\b)', re.M)

# 引数の埋め方: フォーム項目名から用途を推測する
def fill_args(path):
    body = re.search(r'^form .*?\n(.*?)^endform\n', path.read_text(), re.S | re.M)
    if not body:
        return []
    args = []
    for line in body.group(1).splitlines():
        s = line.strip()
        m = re.match(r'(sentence|text|word)\s+(\w+)\s*(.*)$', s)
        if m:
            args.append(guess_path(m.group(2).lower(), m.group(3).strip()))
            continue
        m = re.match(r'(positive|real|integer|natural|boolean|choice)\s+\S+\s+(\S+)', s)
        if m:
            args.append(m.group(2))
            continue
        m = re.match(r'(positive|real|integer|natural|boolean)\s+\S+\s*$', s)
        if m:
            args.append("1")
            continue
        if s.startswith('optionmenu'):
            args.append("__OPTION__")
    return args


OUTISH = ('output', 'out_', 'result', 'save', 'dest', 'export', 'log',
          'report', 'project', 'target_folder', 'backup', 'converted')


def guess_path(name, default):
    fx = str(FX)
    if any(k in name for k in OUTISH):
        if 'csv' in name or (default and default.endswith('.csv')):
            return f"{fx}/out/{name}.csv"
        if 'folder' in name or 'dir' in name or (default and default.endswith('/')):
            return f"{fx}/out/{name}/"
        if 'textgrid' in name:
            return f"{fx}/out/{name}.TextGrid"
        if 'pdf' in name:
            return f"{fx}/out/{name}.pdf"
        if 'wav' in name or 'sound' in name:
            return f"{fx}/out/{name}.wav"
        return f"{fx}/out/{name}"
    if 'textgrid' in name and ('file' in name or 'input' in name or name.endswith('textgrid')):
        return f"{fx}/audio/spk1_a.TextGrid"
    if 'file' in name and ('wav' in name or 'sound' in name or 'input' in name or 'audio' in name):
        return f"{fx}/audio/spk1_a.wav"
    if 'folder' in name or 'dir' in name or 'path' in name or 'root' in name:
        if 'textgrid' in name or 'grid' in name:
            return f"{fx}/audio/"
        return f"{fx}/audio/"
    if 'csv' in name or 'table' in name:
        return f"{fx}/in/table.csv"
    if 'file' in name:
        return f"{fx}/audio/spk1_a.wav"
    # 経路でない文字列項目は既定値をそのまま使う
    return default if default else "x"


def option_first(path):
    """optionmenu の最初の選択肢を返す。"""
    t = path.read_text()
    return re.findall(r'^\s*option\s+(\S+)', t, re.M)


CLASSIFICATION = json.loads((ROOT / "tests/book_classification.json").read_text())
ARG_OVERRIDES = json.loads((ROOT / "tests/book_args.json").read_text())


def classify(path):
    """バッチ実行で検証できないものは、理由を書いた表で管理する。

    自動判定だけに任せると、なぜ除外したのかが後から分からなくなる。
    """
    for kind in ("interactive", "excerpt"):
        if path.name in CLASSIFICATION[kind]:
            return kind
    if INTERACTIVE.search(path.read_text()):
        return "interactive"
    return "runnable"


def main():
    only = sys.argv[1] if len(sys.argv) > 1 else None
    # 原本を1回だけ作る
    shutil.rmtree(PRISTINE, ignore_errors=True)
    r = subprocess.run([PRAAT, "--run", "--FULL-TRUST", "--no-pref-files",
                        str(ROOT / "tests/make_book_fixtures.praat"), str(PRISTINE) + "/"],
                       capture_output=True, text=True)
    if "Error" in (r.stdout + r.stderr):
        sys.exit("フィクスチャ生成に失敗:\n" + r.stdout + r.stderr)

    results = {"ok": [], "fail": [], "interactive": [], "excerpt": []}
    for p in sorted(ROOT.glob("book/*.praat")):
        if only and only not in p.name:
            continue
        kind = classify(p)
        if kind in ("interactive", "excerpt"):
            results[kind].append(p.name)
            continue
        ov = ARG_OVERRIDES.get(p.name)
        if ov:
            args = [a.replace("{FX}", str(FX)) for a in ov["args"]]
        else:
            args = fill_args(p)
        opts = option_first(p)
        oi = 0
        for i, a in enumerate(args):
            if a == "__OPTION__":
                args[i] = opts[oi] if oi < len(opts) else "1"
                oi += 1
        # 1本ごとにフィクスチャを作り直す。前のスクリプトが書き込んだ結果を
        # 次のスクリプトが入力として読むと、通ったか壊れたか分からなくなる。
        shutil.rmtree(FX, ignore_errors=True)
        shutil.copytree(PRISTINE, FX)
        (FX / "out").mkdir(parents=True, exist_ok=True)
        # 書き出し先フォルダは、利用者が用意した状態を再現して先に作る
        for a in args:
            if a.startswith(str(FX)):
                d = pathlib.Path(a if a.endswith("/") else str(pathlib.Path(a).parent))
                d.mkdir(parents=True, exist_ok=True)
        rr = subprocess.run([PRAAT, "--run", "--FULL-TRUST", "--no-pref-files", str(p), *args],
                            capture_output=True, text=True, timeout=180)
        out = (rr.stdout + rr.stderr).strip()
        if "Error" in out or "not completed" in out:
            results["fail"].append((p.name, out.split("\n")[0][:130]))
        else:
            results["ok"].append(p.name)

    print(f"実行可能 {len(results['ok'])+len(results['fail'])} 本: "
          f"成功 {len(results['ok'])} / 失敗 {len(results['fail'])}")
    print(f"対話前提 {len(results['interactive'])} 本 / 抜粋 {len(results['excerpt'])} 本 は実行対象外")
    for n, m in results["fail"]:
        print(f"  ✗ {n}: {m}")
    if results["interactive"]:
        print("  対話前提:", ", ".join(results["interactive"]))
    if results["excerpt"]:
        print("  抜粋:", ", ".join(results["excerpt"]))
    return 1 if results["fail"] else 0


if __name__ == "__main__":
    sys.exit(main())
