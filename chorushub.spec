# -*- mode: python ; coding: utf-8 -*-
# flake8: noqa
import argparse
import shutil

parser = argparse.ArgumentParser()
parser.add_argument('-d', '--debug', action='store_true')
args = parser.parse_args()

a = Analysis(
    [shutil.which('chorushub'), shutil.which('hg')],
    pathex=[],
    binaries=[(shutil.which('hg'), 'usr/bin')],
    datas=[],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)

# Add external files.
mono_bins = Tree(
    'build/prime/mono/usr/bin',
    prefix='usr/bin',
    typecode='BINARY',
)
mono_libs = Tree(
    'build/prime/mono/usr/lib',
    prefix='usr/lib',
    excludes=['pkgconfig'],
    typecode='BINARY',
)
sil_libs = Tree('build/prime/sil', typecode='BINARY')

pyz = PYZ(a.pure)

kwargs = {
    'name': 'chorushub',
    'debug': False,
    'bootloader_ignore_signals': False,
    'strip': False,
    'upx': True,
    'upx_exclude': [],
    'runtime_tmpdir': None,
    'console': True,
    'disable_windowed_traceback': False,
    'argv_simulation': False,
    'target_arch': None,
    'codesign_identity': None,
    'entitlements_file': None,
}
if args.debug:
    kwargs['debug'] = True

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    mono_bins,
    mono_libs,
    sil_libs,
    [],
    **kwargs,
)
