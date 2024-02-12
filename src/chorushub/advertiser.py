import logging
import socket
import multiprocessing
import time

from .chorushuboptions import ChorusHubOptions
# FIXME: ChorusHubServerInfo is only needed for
#   Advertiser.update_advertisement_based_on_current_ip()
# Using workaround for now.
# from .chorushubserverinfo import ChorusHubServerInfo


class Advertiser:
    def __init__(self, port):
        self._proc = None
        self._endpoint = None
        self._send_bytes = None
        self._current_ip_address = None
        self.port = port

    def start(self):
        ip = "255.255.255.255"
        self._endpoint = (ip, self.port)
        self._proc = multiprocessing.Process(target=self.work)
        self._proc.start()
        logging.info(f"Started Advertiser on {ip}:{self.port}.")

    def stop(self):
        if self._proc is None:
            return

        logging.info("Advertiser Stopping...")
        self._proc.kill()
        self._proc.join(timeout=2)
        self._proc = None
        logging.info("Stopped Advertiser.")

    def dispose(self):
        self.stop()

    def work(self):
        with socket.socket(
            socket.AF_INET,
            socket.SOCK_DGRAM,
            socket.IPPROTO_UDP,
        ) as sock:
            while True:
                self.update_advertisement_based_on_current_ip()
                logging.info(f"Sending: {self._send_bytes}")
                if self._send_bytes:
                    sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
                    sock.sendto(self._send_bytes, self._endpoint)
                time.sleep(1)

    def update_advertisement_based_on_current_ip(self):
        current_ip = self.get_local_ip_address()
        if not current_ip:
            self._send_bytes = None
        elif self._current_ip_address != current_ip:
            self._current_ip_address = current_ip
            # FIXME: Using workaround to avoid chorushubserverinfo module.
            # server_info = ChorusHubServerInfo(
            #     self._current_ip_address,
            #     str(ChorusHubOptions.mercurial_port),
            #     socket.gethostname(),
            #     ChorusHubServerInfo.version_of_this_code,
            # )
            # self._send_bytes = server_info.to_string()
            s = "ChorusHubInfo?"
            props = {
                'version': 3,
                'address': self._current_ip_address,
                'port': str(ChorusHubOptions.mercurial_port),
                'hostname': socket.gethostname(),
            }
            for k, v in props.items():
                s += f"{k}={v}&"
            self._send_bytes = s.rstrip('&').encode()

    def get_local_ip_address(self):
        with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
            sock.connect(('1.1.1.1', 80))
            local_ip = sock.getsockname()[0]
            return local_ip
            # if isinstance(local_ip, list):
            #     if len(local_ip) > 1:
            #         m = "This machine has more than one IP address"
            #         logging.warning(m)
            #     return local_ip[0]
            # else:
            #     logging.warning("Could not determine IP Address!")
            #     return None
