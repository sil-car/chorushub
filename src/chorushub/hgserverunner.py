import logging
import psutil
import subprocess
# import threading
from pathlib import Path


class HgServeRunner:
    def __init__(self, root_folder, port):
        self.port = port
        self._root_folder = Path(root_folder)
        self._access_log_path = Path(self._root_folder) / "accessLog.txt"
        self._log_path = Path(self._root_folder) / "log.txt"
        # self._hg_serve_thread = None
        self._hg_serve_proc = None

    def start(self):
        try:
            old_hg = self.find_running_hg_proc()
            if old_hg:
                logging.debug(f"hg server already running: {old_hg}")
                old_hg.kill()
                try:
                    old_hg.wait(timeout=10)
                except psutil.TimeoutExpired:
                    logging.error(
                        "ChorusHub was unable to stop an old hg from"
                        "running. It will now give up. You should stop the"
                        "server and run it again after killing whatever"
                        "'hg' process is running."
                    )
                    return False
                logging.debug(f"Stopped {old_hg}")

            if self._access_log_path.exists():
                self._access_log_path.unlink()

            if not self._root_folder.is_dir():
                self._root_folder.mkdir()

            logging.info("Starting Mercurial Server")

            self.write_config_file()

            arguments = [
                "serve",
                "-A", self._access_log_path.name,
                "-E", self._log_path.name,
                "-p", f"{self.port}",
                "--verbose",
            ]
            # TODO: See if there is a python library for Mercurial rather than
            # using a subprocess.
            # self._hg_serve_thread = threading.Thread(
            #     target=subprocess.run,
            #     args=[['hg', *arguments]],
            #     kwargs={'cwd': str(self._root_folder)},
            #     daemon=True,
            # )
            # self._hg_serve_thread.start()
            self._hg_serve_proc = subprocess.Popen(
                ['hg', *arguments],
                cwd=str(self._root_folder),
            )
            logging.debug(f"Started hg server from {str(self._root_folder)} on *:{self.port}.")  # noqa: E501
            return True

        except Exception as e:
            logging.error(f"{e}")
            return False

    def stop(self):
        # if (
        #     self._hg_serve_thread is not None and
        #     self._hg_serve_thread.is_alive()
        # ):
        if (
            self._hg_serve_proc is not None and
            not self._hg_serve_proc.poll()
        ):
            logging.info("Hg Server Stopping...")
            # self._hg_serve_thread.kill()
            self._hg_serve_proc.kill()
            # if self._hg_serve_thread.join(timeout=2):
            #     logging.info("Hg Server Stopped")
            # else:
            #     logging.error("***Gave up on hg server stopping")
            # self._hg_serve_thread = None
            self._hg_serve_proc = None
            logging.debug("Stopped hg server.")

    def dispose(self):
        self.stop()

    def write_config_file(self):
        config = (
            "[web]\n"
            "allow_push = *\n"
            "push_ssl = No\n"
            "\n"
            "[paths]\n"
            f"/ = {self._root_folder}/*"
        )

        config_path = Path(self._root_folder) / 'hgweb.config'
        if config_path.exists():
            config_path.unlink()

        config_path.write_text(config)

    def check_for_failed_pushes(self):
        if not self._access_log_path.exists():
            return

        with self._access_log_path.open() as f:
            for line in f.readlines():
                start = line.index('GET /') + 5
                end = line.index('?')
                if '404' in line and (start > 9 and end > 0):
                    name = line[start:end-start]
                    directory = self._root_folder / name
                    if not directory.is_dir():
                        logging.info(f"Creating new folder \"{name}\"")
                        directory.mkdir()

                    hg_dir = directory / '.hg'
                    if not hg_dir.is_dir():
                        logging.info(f"Initializing blank repository: {name}")
                        subprocess.run(['hg', 'init', directory])

    def find_running_hg_proc(self):
        for p in psutil.process_iter():
            if p.name() == 'hg':
                logging.debug(f"hg proc: {p}")
                return p
