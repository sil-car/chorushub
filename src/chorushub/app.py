import argparse

from .chorushubserver import ChorusHubServer


def main():
    parser = argparse.ArgumentParser(prog='ChorusHub')
    group = parser.add_mutually_exclusive_group
    group.add_argument(
        'start', action='store_true',
        help='start the ChorusHub service'
    )
    group.add_argument(
        'stop', action='store_true',
        help='stop the ChorusHub service'
    )
    group.add_argument(
        'restart', action='store_true',
        help='restart the ChorusHub service'
    )
    args = parser.parse_args()
    server = ChorusHubServer()
    if args.start:
        server.start()
    elif args.stop:
        server.stop()
    elif args.restart:
        server.stop()
        server.start()


if __name__ == '__main__':
    main()
