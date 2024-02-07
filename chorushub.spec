# -*- mode: python ; coding: utf-8 -*-
# flake8: noqa
import shutil

a = Analysis(
    ['src/chorushub/app.py'],
    pathex=[],
    binaries=[(shutil.which('hg'), 'usr/bin')],
    datas=[],
    hiddenimports=['hgdemandimport', 'mercurial', 'os', 'sys'],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)

# hg_libs = Tree()
mono_libs = Tree(
    'build/prime/mono/usr/lib',
    prefix='usr/lib',
    excludes=['pkgconfig'],
    typecode='BINARY',
)
sil_libs = Tree('build/prime/sil', typecode='BINARY')

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    mono_libs,
    sil_libs,
    [],
    name='chorushub',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
