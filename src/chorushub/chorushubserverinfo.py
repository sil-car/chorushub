import logging

from .chorushuboptions import ChorusHubOptions

import pythonnet  # noqa: F401
import clr
clr.AddReference('System.Net')
from System.Net import IPAddress  # noqa: E402
from System.Net import IPEndPoint  # noqa: E402
from System.Net.Sockets import SocketOptionLevel  # noqa: E402
from System.Net.Sockets import SocketOptionName  # noqa: E402
from System.Net.Sockets import UdpClient  # noqa: E402


class ChorusHubServerInfo:
    def __init__(self, ip_address, port, hostname, version):
        self._chorus_hub_server_info = None
        self._ip_address = ip_address
        self._port = port
        self.hostname = hostname
        self.version_of_server_chorus_hub = version
        self.version_of_this_code = 3

    def parse(self, parameters):
        start = parameters.index('?')
        parameters = parameters[start+1:len(parameters)-start-1]

        host = self.get_value(parameters, "hostname")
        address = self.get_value(parameters, "address")
        port = self.get_value(parameters, "port")
        version = int(self.get_value(parameters, "version"))
        return ChorusHubServerInfo(address, port, host, version)

    def get_value(self, parameters, name):
        query_parameters = {}
        query_segments = parameters.split('&')
        for segment in query_segments:
            parts = segment.split('=')
            if not parts:
                continue
            key = parts[0].strip('? ')
            val = parts[1].strip()
            query_parameters[key] = val

        r = query_parameters.get(name)
        return r

    def is_chorus_hub_info(self, parameters):
        return parameters.startswith("ChorusHubInfo")

    def server_is_compatible_with_this_client(self, version):
        return self.version_of_server_chorus_hub == self.version_of_this_code

    def to_string(self):
        s = "ChorusHubInfo?"
        props = {
            'version': self.version_of_this_code,
            'address': self._ip_address,
            'port': self._port,
            'hostname': self.hostname,
        }
        for k, v in props.items():
            s = f"{s}{k}={v}&"
        return s.rstrip('&')

    def service_uri(self):
        return f"net.tcp://{self._ipAddress}:{ChorusHubOptions.service_port}"

    def get_hg_http_uri(self, directory_name):
        # The "chorushub" pretend user name here is to help build helpful error
        # reports if something goes wrong. The error-explainer can look at the
        # url and know that we were trying to reach a chorus hub, and give more
        # helpful advice.
        return f"http://chorushub@{self._ip_address}:{self._port}/{directory_name}"  # noqa: E501

    def find_server_information(self):
        ip_endpoint = self.start_finding()
        for _ in range(20):
            if self._chorus_hub_server_info is not None:
                break
            # time.sleep(0.2)
        self.stop_finding(ip_endpoint)
        return self._chorus_hub_server_info

    def start_finding(self):
        ip_endpoint = IPEndPoint(IPAddress, ChorusHubOptions.advertising_port)
        udp_client = UdpClient()

        # This reuse business is in hopes of avoiding the dreaded "Only one
        # usage of each socket address is normally permitted"
        udp_client.Client.SetSocketOption(
            SocketOptionLevel.Socket,
            SocketOptionName.ReuseAddress,
            True,
        )
        udp_client.Bind(ip_endpoint)
        udp_client.BeginReceive(
            self.receive_finding_callback,
            (udp_client, ip_endpoint),
        )
        return udp_client

    def stop_finding(self):
        try:
            self.udp_client.close()
            logging.debug("Finder Stopped")
        except Exception as e:
            # not worth bothering the user
            logging.debug(e)

    def receive_finding_callback(self, args):
        try:
            udp_client = args[0]
            # var udpClient = (UdpClient)((object[])args.AsyncState)[0];
            if udp_client.client is None:
                return

            ip_endpoint = args[1]
            # var ipEndPoint = (IPEndPoint)((object[])args.AsyncState)[1];
            receive_bytes = udp_client.EndReceive(args, ip_endpoint)
        except Exception:  # ObjectDisposedException:
            # This is actually the expected behavior, if there is no chorus hub
            # out there!
            # http://stackoverflow.com/questions/4662553/how-to-abort-sockets-beginreceive
            # Note the check for Client == null above seems to help some...
            return

        try:
            s = receive_bytes.decode()
            if self.is_chorus_hub_info(s):
                self._chorus_hub_server_info = self.parse(s)
        except Exception as e:
            logging.debug(e)
