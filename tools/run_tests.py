#!/usr/bin/env python3
"""配布スクリプトを実際にPraatで走らせる。

Praatは実行時エラーでも終了コード0を返す。したがって終了コードは信用せず、
出力に "Error" が現れるかどうかで判定する。
"""
import json, pathlib, shutil, subprocess, sys

ROOT  = pathlib.Path(__file__).parent.parent
PRAAT = "/Applications/Praat.app/Contents/MacOS/Praat"
FX    = pathlib.Path("/tmp/pbs_fx/")

def praat(script, args):
    r = subprocess.run([PRAAT, "--run", "--FULL-TRUST", "--no-pref-files", str(script), *args],
                       capture_output=True, text=True, timeout=120)
    return (r.stdout + r.stderr).strip()

def form_args(path):
    """フォームの項目数ぶんの引数を作る。文字列項目は空にして既定値を使わせる。

    optionmenu の選択肢はメニューごとに数える。全体で通し取りすると、
    2つ目のメニューに1つ目の選択肢を渡してしまう（実際に起きた）。
    """
    import re
    body = re.search(r'^form .*?\n(.*?)^endform\n', path.read_text(), re.S | re.M).group(1)
    lines = [l.strip() for l in body.splitlines()]
    args = []
    i = 0
    while i < len(lines):
        s = lines[i]
        if re.match(r'(sentence|text)\s', s):
            args.append("")
        elif s.startswith('word '):
            m = re.match(r'word\s+\S+\s+(\S+)', s)
            args.append(m.group(1) if m else "x")
        elif s.startswith('optionmenu'):
            # 直後に続く option 行のうち最初のものを使う
            j = i + 1
            first = None
            while j < len(lines) and lines[j].startswith('option '):
                if first is None:
                    first = lines[j].split(None, 1)[1].strip()
                j += 1
            args.append(first if first else "1")
            i = j
            continue
        else:
            m = re.match(r'(positive|real|integer|natural|boolean|choice)\s+\S+\s+(\S+)', s)
            if m:
                args.append(m.group(2))
        i += 1
    return args


def main():
    only = sys.argv[1] if len(sys.argv) > 1 else None
    cases = json.loads((ROOT / "tests/cases.json").read_text())
    if FX.exists():
        shutil.rmtree(FX)
    out = praat(ROOT / "tests/make_fixtures.praat", [str(FX) + "/"])
    if "Error" in out:
        sys.exit(f"フィクスチャ生成に失敗した:\n{out}")

    ok = fail = skip = 0
    problems = []
    for c in cases:
        path = ROOT / c["script"]
        if only and only not in c["script"]:
            continue
        if not path.exists():
            skip += 1
            problems.append((c["script"], "ファイルが無い"))
            continue
        args = [a.replace("{FX}", str(FX) + "/") for a in c.get("args", [])]
        res = praat(path, args)
        if "Error" in res or "not performed" in res:
            fail += 1
            problems.append((c["script"], res.split("\n")[0][:120]))
        else:
            for exp in c.get("expect_files", []):
                f = pathlib.Path(exp.replace("{FX}", str(FX) + "/"))
                if not f.exists():
                    fail += 1
                    problems.append((c["script"], f"出力が作られない: {f.name}"))
                    break
            else:
                ok += 1
    print(f"引数あり: 実行 {ok+fail+skip} 本 / 成功 {ok} / 失敗 {fail} / 未作成 {skip}")
    for name, msg in problems:
        print(f"  ✗ {name}: {msg}")

    # 読者が実際にたどる経路。フォルダを空欄のまま実行して同梱サンプルで動くか。
    z_ok = z_ng = 0
    for p in sorted(ROOT.glob("scripts/*/*.praat")):
        if only and only not in str(p):
            continue
        res = praat(p, form_args(p))
        if "Error" in res or "not performed" in res:
            z_ng += 1
            print(f"  ✗ 無設定起動 {p.name}: {res.splitlines()[0][:100]}")
        else:
            z_ok += 1
    print(f"無設定起動: 成功 {z_ok} / 失敗 {z_ng}")
    return 1 if (fail or skip or z_ng) else 0

if __name__ == "__main__":
    sys.exit(main())
