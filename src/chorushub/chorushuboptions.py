import os
from pathlib import Path


class ChorusHubOptions:
    # These numbers were selected by looking at the IANA registry and
    # intentionally *not* picking, "undefined" ones (which could become
    # defined in the future), but rather ones already assigned to stuff
    # that looks unlikely to be running on the same subnet
    # <summary>
    # "Controller Pilot Data Link Communication"
    # </summary>
    advertising_port = 5911
    # <summary>
    # "Flight Information Services"
    # </summary>
    service_port = 5912
    # <summary>
    # "Automatic Dependent Surveillance"
    # </summary>
    mercurial_port = 5913

    def __init__(self, root_dir=None):
        if root_dir:
            self._root_directory = Path(root_dir)
        else:
            if os.name == 'posix':
                self._root_directory = Path.home() / 'ChorusHub'
            else:
                self._root_directory = Path('C:') / 'ChorusHub'

    # <summary>
    # Path to a folder where all the repositories will be placed.
    # </summary>
    def root_directory(self):
        def get():
            if not self._root_directory.exists():
                self._root_directory.mkdir()
            return self._root_directory
