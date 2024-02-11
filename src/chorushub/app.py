import argparse
import os
import pythonnet
import sys

from pathlib import Path

from .chorushubserver import ChorusHubServer


def main():
    parser = argparse.ArgumentParser(prog='ChorusHub')
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        '--start', action='store_true',
        help='start the ChorusHub service'
    )
    group.add_argument(
        '--stop', action='store_true',
        help='stop the ChorusHub service'
    )
    group.add_argument(
        '--restart', action='store_true',
        help='restart the ChorusHub service'
    )
    args = parser.parse_args()
    set_runtime_env()
    server = ChorusHubServer()
    if args.start:
        server.start()
    elif args.stop:
        server.stop()
    elif args.restart:
        server.stop()
        server.start()


def set_runtime_env():
    if getattr(sys, 'frozen', False) and hasattr(sys, '_MEIPASS'):
        app_root = Path(sys._MEIPASS)
        # sys.path.append(f"{app_root}/usr/lib/mono")
    elif os.getenv('SNAP'):
        # app_root = Path(os.getenv('SNAP'))
        app_root = Path(f"{os.getenv('SNAP')}")
        # sys.path.append(f"{os.getenv('SNAP')}/usr/lib")
    else:
        app_root = Path('/')
    mono_path = [
        f"{app_root}/usr/lib",
        f"{app_root}/usr/lib/mono/4.5",
        # f"{app_root}/usr/lib/mono/gac",
    ]
    # export ACLOCAL_PATH=${PKG_DIR}/share/aclocal
    # export C_INCLUDE_PATH=${PKG_DIR}/include
    # export FONTCONFIG_PATH=${PKG_DIR}/etc/fonts
    # os.environ['LD_RUN_PATH'] = os.getenv('LD_LIBRARY_PATH', '')
    os.environ['MONO_CONFIG'] = f"{app_root}/chorushub/config"
    os.environ['MONO_CFG_DIR'] = f"{app_root}/etc"
    os.environ['MONO_GAC_PREFIX'] = f"{app_root}"
    os.environ['MONO_PATH'] = ':'.join(mono_path)
    os.environ['MONO_LOG_LEVEL'] = 'debug'
    os.environ['MONO_LOG_MASK'] = 'cfg,dll'
    # export MONO_REGISTRY_PATH=~/.mono/registry
    # export PKG_CONFIG_PATH=$PKG_DIR/lib64/pkgconfig:$PKG_CONFIG_PATH
    # export XDG_DATA_HOME=${PKG_DIR}/etc/fonts

    # Setup Python.NET
    pythonnet.load(
        'mono',
        libmono=f"{app_root}/usr/lib/libmono-2.0.so.1",
    )


if __name__ == '__main__':
    main()
