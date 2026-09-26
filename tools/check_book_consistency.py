#!/usr/bin/env python3
"""書籍の記述と、この配布パッケージの実体が食い違っていないか検査する。

書籍は「GitHubに◯本ある」と読者に約束する。中身を足したり減らしたりすれば
その数はずれる。人が両方を見て直し続けるのは続かないので、機械で見張る。

    python3 tools/check_book_consistency.py [書籍リポジトリのパス]
"""
import json, pathlib, re, sys

ROOT = pathlib.Path(__file__).parent.parent
DEFAULT_BOOK = pathlib.Path.home() / "Projects/books/praat-book-claudecode"


def actual():
    recipe = [p for p in ROOT.glob("scripts/0[1-5]_*/*.praat")]
    extra = [p for p in ROOT.glob("scripts/0[67]_*/*.praat")]
    book = sorted(ROOT.glob("book/*.praat"))
    cls = json.loads((ROOT / "tests/book_classification.json").read_text())
    excluded = set(cls["interactive"]) | set(cls["excerpt"])
    return {
        "recipe": len(recipe),
        "extra": len(extra),
        "book": len(book),
        "total": len(recipe) + len(extra) + len(book),
        "runnable_book": len([p for p in book if p.name not in excluded]),
        "interactive": len(cls["interactive"]),
        "excerpt": len(cls["excerpt"]),
    }


def main():
    bookdir = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_BOOK
    a = actual()
    print("配布物の実体")
    print(f"  scripts/01-05 骨格の完全版   {a['recipe']:3} 本")
    print(f"  scripts/06-07 研究運用・図版 {a['extra']:3} 本")
    print(f"  book/         書籍掲載        {a['book']:3} 本"
          f"（実行検証 {a['runnable_book']} / 対話前提 {a['interactive']} / 抜粋 {a['excerpt']}）")
    print(f"  合計                         {a['total']:3} 本")

    ap = bookdir / "manuscript/appendix_A.md"
    if not ap.exists():
        print(f"\n書籍リポジトリが見つからないので突き合わせを行わない: {ap}")
        return 0
    t = ap.read_text()

    problems = []
    # 「◯本」と書かれた箇所のうち、配布本数を指すものを拾う
    for pat, key, where in [
        (r'骨格の完全版(\d+)本', "recipe", "A.0の表: 骨格の完全版"),
        (r'書籍掲載(\d+)本', "book", "A.0の表: 書籍掲載"),
        (r'研究運用・図版(\d+)本', "extra", "A.0の表: 研究運用・図版"),
        (r'GitHubで無料ダウンロード（(\d+)本', "total", "まとめの見出し"),
    ]:
        m = re.search(pat, t)
        if m and int(m.group(1)) != a[key]:
            problems.append(f"{where}が「{m.group(1)}本」だが実体は {a[key]} 本")
    m = re.search(r'完全版(\d+)本に加え、本文と本付録に掲載したスクリプト(\d+)本、'
                  r'および研究運用・図版のスクリプト(\d+)本', t)
    if m:
        for i, key, label in ((1, "recipe", "骨格"), (2, "book", "書籍掲載"), (3, "extra", "研究運用・図版")):
            if int(m.group(i)) != a[key]:
                problems.append(f"まとめ本文: {label}「{m.group(i)}本」だが実体は {a[key]} 本")

    # 有料販売の記述が残っていないか（無償配布に一本化したため）
    for kw in ("有料", "booth.pm", "円）で販売", "販売している"):
        if kw in t:
            problems.append(f"付録Aに有料販売の記述が残っている: 「{kw}」")

    # 書籍が案内するファイル名が配布物にあるか
    named = set(re.findall(r'\|\s*A-\d+\s*\|\s*([a-z0-9_]+\.praat)', t))
    have = {p.name for p in ROOT.glob("scripts/*/*.praat")} | {p.name for p in ROOT.glob("book/*.praat")}
    missing = sorted(named - have)
    if missing:
        problems.append(f"書籍の表にあるが配布物に無い: {missing}")

    print(f"\n書籍との突き合わせ: 不整合 {len(problems)} 件")
    for x in problems:
        print(f"  ✗ {x}")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
