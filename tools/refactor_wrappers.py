#!/usr/bin/env python3
# tools/refactor_wrappers.py
# Usage: python3 tools/refactor_wrappers.py [target-dir]
# This script makes conservative replacements to route sys.* calls to the utils wrappers.

import sys, os, re, shutil

REPLACEMENTS = [
    (re.compile(r'\bsys\.io\.File\.getContent\('), 'utils.FileSystemSafe.readText('),
    (re.compile(r'\bsys\.io\.File\.getBytes\('), 'utils.FileSystemSafe.readBytes('),
    (re.compile(r'\bsys\.io\.File\.saveContent\('), 'utils.FileSystemSafe.writeText('),
    (re.compile(r'\bsys\.FileSystem\.readDirectory\('), 'utils.FileSystemSafe.readDirectory('),
    (re.compile(r'\bsys\.FileSystem\.exists\('), 'utils.AssetSafe.exists('),
    (re.compile(r'\bhxCodec\.play\('), 'utils.VideoPlayer.play('),
    (re.compile(r'\bhxvlc\.play\('), 'utils.VideoPlayer.play('),
    (re.compile(r'\bAssets\.getBitmapData\('), 'utils.AssetSafe.getBitmapDataSafe('),
]

EXTENSIONS = ('.hx', '.hxml', '.xml', '.js')

def process_file(path):
    with open(path, 'r', encoding='utf-8') as f: txt = f.read()
    orig = txt
    for pattern, repl in REPLACEMENTS:
        txt = pattern.sub(repl, txt)
    if txt != orig:
        bak = path + '.bak'
        shutil.copy2(path, bak)
        with open(path, 'w', encoding='utf-8') as f: f.write(txt)
        print("Updated:", path)

def walk(root):
    for dirpath, dirnames, filenames in os.walk(root):
        for fn in filenames:
            if fn.endswith(EXTENSIONS):
                process_file(os.path.join(dirpath, fn))

if __name__ == '__main__':
    target = sys.argv[1] if len(sys.argv) > 1 else '.'
    walk(target)
