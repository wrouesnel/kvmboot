# Copyright 2012 Cloudbase Solutions Srl
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.
#
# Modified by Will Rouesnel (2021)
# This version is for Windows 2019 and loads the SSH keys into the administrative
# authorized keys file.

import os
import subprocess

from oslo_log import log as oslo_logging

from cloudbaseinit import conf as cloudbaseinit_conf
from cloudbaseinit import exception
from cloudbaseinit.plugins.common import base


CONF = cloudbaseinit_conf.CONF
LOG = oslo_logging.getLogger(__name__)


class SetUserSSHPublicKeysWin19kPlugin(base.BasePlugin):

    def execute(self, service, shared_data):
        public_keys = service.get_public_keys()
        if not public_keys:
            LOG.debug('Public keys not found in metadata')
            return base.PLUGIN_EXECUTION_DONE, False
        
        programdata_dir = os.environ.get("PROGRAMDATA",None)
        if not programdata_dir:
            raise exception.CloudbaseInitException("Could not find PROGRAMDATA dir")

        authorized_keys_path = os.path.join(programdata_dir, "ssh" ,"administrators_authorized_keys")
        LOG.info("Writing SSH public keys in: %s" % authorized_keys_path)
        with open(authorized_keys_path, 'w') as f:
            for public_key in public_keys:
                # All public keys are space-stripped.
                f.write(public_key + "\n")

        # We have to ensure this file gets proper permissions as per
        # https://serverfault.com/questions/873064/public-key-authentication-windows-port-of-openssh
        subprocess.check_call(["icacls", authorized_keys_path, "/inheritance:r"])
        subprocess.check_call(["icacls", authorized_keys_path, "/grant", "SYSTEM:F"])
        subprocess.check_call(["icacls", authorized_keys_path, "/grant", "BUILTIN\Administrators:F"])
        subprocess.check_call(["icacls", authorized_keys_path, "/remove", "NT AUTHORITY\Authenticated Users"])

        return base.PLUGIN_EXECUTION_DONE, False
