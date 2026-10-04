#!/usr/bin/env python3
"""書籍原稿から、ファイル名コメントを持つPraatスクリプトを抽出する。

配布物と書籍本文が食い違わないための唯一の経路。手でコピーしない。
使い方: python3 tools/extract_from_manuscript.py <manuscript_dir>
"""
import re, sys, json, pathlib
from collections import Counter

HEADER = """# {file}
# {title}
#
# 『Praatで学ぶ音声研究の方法』{where}掲載スクリプト
# https://github.com/labphonlab/praat-book-scripts
#
# Copyright (c) 2026 Takeshi Ishihara
# Released under the MIT License. See LICENSE for details.
"""

PAT_ID   = re.compile(r'^#\s*([A-Z]-\d+)\s*[:：]\s*([A-Za-z0-9_]+\.praat)')
PAT_FILE = re.compile(r'^#\s*([A-Za-z0-9_]+\.praat)')

def main(mdir, outdir):
    mdir, outdir = pathlib.Path(mdir), pathlib.Path(outdir)
    (outdir / "book").mkdir(parents=True, exist_ok=True)
    items = []
    for f in sorted(mdir.glob("*.md")):
        txt = f.read_text()
        # 終端フェンスは行頭のものだけ。文字列の中に ``` を含むコードがあり、
        # 行中の ``` を終端と誤認するとスクリプトが途中で切れる（実際に起きた）。
        for m in re.finditer(r'^```praat\n(.*?)^```\s*$', txt, re.S | re.M):
            # 紙版で省く範囲の印（#@omit-in-print: … / #@end-omit）は書籍の組版用なので落とす。
            # 配布するのは常に全文。
            code = "\n".join(l for l in m.group(1).split("\n")
                             if not re.match(r'\s*#@(omit-in-print:|end-omit)', l))
            first = code.split('\n')[0].strip()
            a, b = PAT_ID.match(first), PAT_FILE.match(first)
            if not (a or b):
                continue
            # 「[完全版はGitHubを参照]」等のスタブは実行できないので配布に含めない。
            # 中身が無いファイルを置くと、書籍の案内先が空という事故になる。
            if "完全版はGitHub" in code or "GitHubを参照" in code:
                continue
            name = a.group(2) if a else b.group(1)
            rid = a.group(1) if a else None
            before = txt[:m.start()]
            sc = re.findall(r'\*\*Script\s+([0-9]+\.[0-9]+)[^*]*\*\*', before)
            heads = re.findall(r'^#{2,4}\s+(.+)$', before, re.M)
            title = (heads[-1] if heads else name).strip()
            title = re.sub(r'[\U0001F300-\U0001FAFF\u2190-\u21FF\u2600-\u27BF]', '', title)
            title = re.sub(r'^[A-Z]-\d+[:：]\s*', '', title).strip(' 　')
            script_no = sc[-1] if sc else None
            if rid:
                where = f"付録{rid}"
            elif script_no:
                where = f"Script {script_no}"
            else:
                where = f.stem
            items.append(dict(file=name, id=rid, script=script_no,
                              chapter=f.stem, title=title, code=code))
    dup = [k for k, v in Counter(i['file'] for i in items).items() if v > 1]
    if dup:
        sys.exit(f"ファイル名が重複している: {dup}")
    for it in items:
        where = f"付録{it['id']}" if it['id'] else (f"Script {it['script']}" if it['script'] else it['chapter'])
        body = it['code']
        # 先頭のファイル名コメント行は書き直すので落とす
        lines = body.split('\n')
        while lines and lines[0].strip().startswith('#'):
            lines.pop(0)
        body = '\n'.join(lines).strip('\n')
        text = HEADER.format(file=it['file'], title=it['title'], where=where) + "\n" + body + "\n"
        (outdir / "book" / it['file']).write_text(text)
    manifest = [{k: v for k, v in i.items() if k != 'code'} for i in items]
    (outdir / "book" / "_manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=1) + "\n")
    print(f"抽出 {len(items)} 本 → {outdir/'book'}")

if __name__ == "__main__":
    md = sys.argv[1] if len(sys.argv) > 1 else \
        pathlib.Path.home() / "Projects/books/praat-book-claudecode/manuscript"
    main(md, pathlib.Path(__file__).parent.parent)
