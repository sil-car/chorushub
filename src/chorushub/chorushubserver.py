﻿import clr
import logging

from pathlib import Path

from .advertiser import Advertiser
from .chorushuboptions import ChorusHubOptions
from .hgserverunner import HgServeRunner


clr.AddReference('System.ServiceModel')
clr.AddReference('ChorusHub')
clr.AddReference('LibChorus')
from Chorus.ChorusHub import IChorusHubService  # noqa: E402
from ChorusHub import ChorusHubService  # noqa: E402
import System  # noqa: E402
from System import IDisposable  # noqa: E402
from System.ServiceModel import NetTcpBinding  # noqa: E402
from System.ServiceModel import SecurityMode  # noqa: E402
from System.ServiceModel import ServiceHost  # noqa: E402
from System.ServiceModel.Description import ServiceDebugBehavior  # noqa: E402


class ChorusHubServer(IDisposable):
    __namespace__ = 'ChorusHub'

    def __init__(self, chorushuboptions=None):
        if not chorushuboptions:
            self.chorushuboptions = ChorusHubOptions()
        else:
            self.chorushuboptions = chorushuboptions
        self.service_port = self.chorushuboptions.service_port
        self._hg_server = None
        self._advertiser = None
        self._service_host = None

    # <summary>
    #
    # </summary>
    # <param name="includeMercurialServer">During tests that don't actually
    # involve send/receive/clone, you can speed things up by setting this
    # to false</param>
    def start(self, include_mercurial_server=True):
        logging.debug(f"running {self.__class__}.start()")
        root_dir = Path(self.chorushuboptions._root_directory)
        root_dir.mkdir(exist_ok=True, parents=True)
        try:
            # Mercurial (hg) service
            if include_mercurial_server:
                self._hg_server = HgServeRunner(
                    self.chorushuboptions._root_directory,
                    self.chorushuboptions.mercurial_port,
                )
                if not self._hg_server.start():
                    logging.error("Failed to start Hg Server")
                    return False

            # Advertiser service
            self._advertiser = Advertiser(self.chorushuboptions.advertising_port)  # noqa: E501
            self._advertiser.start()

            # .NET service
            self._service_host = ServiceHost(clr.GetClrType(ChorusHubService))
            self.enable_sending_exceptions_to_client()
            address = f"net.tcp://localhost:{self.service_port}"
            # Can't access 'None' attribute directly b/c Python keyword:
            # https://stackoverflow.com/a/68755869
            binding = NetTcpBinding(getattr(SecurityMode, 'None'))
            logging.debug(f"{binding=}")
            self._service_host.AddServiceEndpoint(
                clr.GetClrType(IChorusHubService),
                binding,
                address,
            )
            self._service_host.Open()
            return True
        except Exception as e:
            log_message = "ChorusHub failed to start:\n"
            if isinstance(e, System.InvalidOperationException):
                log_message += f"{e.Message}"
            else:
                log_message += f"{e}"
            logging.error(log_message)
            self._advertiser._proc.kill()
            self._hg_server._hg_serve_proc.kill()
            return False

    def enable_sending_exceptions_to_client(self):
        debug = None
        behaviors = self._service_host.Description.Behaviors
        for b in behaviors:
            if 'ServiceDebugBehavior' in b.ToString():
                debug = b
                break
        logging.debug(f"{debug=}")

        if debug is None:
            b = ServiceDebugBehavior()
            b.IncludeExceptionDetailInFaults = True
            self._service_host.Description.Behaviors.Add(b)
        else:
            # make sure setting is turned ON
            if not hasattr(debug, 'IncludeExceptionDetailInFaults'):
                debug.IncludeExceptionDetailInFaults = True

    def stop(self):
        logging.debug(f"running {self.__class__}.stop()")
        if self._advertiser is not None:
            self._advertiser.stop()
            self._advertiser = None
        if self._hg_server is not None:
            self._hg_server.stop()
            self._hg_server = None
        if self._service_host is None:
            return

        self._service_host.Close()
        self._service_host = None

    def dispose(self):
        logging.debug(f"running {self.__class__}.dispose()")
        self.stop()

    def do_occasional_background_tasks(self):
        if self._hg_server is not None:
            self._hg_server.check_for_failed_pushes()
