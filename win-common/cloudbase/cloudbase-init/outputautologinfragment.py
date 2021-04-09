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
# Output an autologin.xml fragment to allow a 1 time administrator login with
# the OOBE file execution.

import os
import subprocess

from oslo_log import log as oslo_logging

from cloudbaseinit import conf as cloudbaseinit_conf
from cloudbaseinit import exception
from cloudbaseinit.plugins.common import base


CONF = cloudbaseinit_conf.CONF
LOG = oslo_logging.getLogger(__name__)


class OutputAutologinFragment(base.BasePlugin):

    def _get_password(self, service, shared_data):
        injected = False
        if CONF.inject_user_password:
            password = service.get_admin_password()
        else:
            password = None

        if not password:
            password = shared_data.get(plugin_constant.SHARED_DATA_PASSWORD)

        return password, injected

    def execute(self, service, shared_data):
        user_name = service.get_admin_username() or CONF.username
        password, injected = self._get_password(service, shared_data)

        if not password:
            LOG.info("Not emitting fragment: no password available")
            return base.PLUGIN_EXECUTION_DONE, False

        with open("C:\\Windows\\Panther\\autologin.xml", "w") as f:
            f.write("""<AutoLogon>
    <Username>{username}</Username>
    <Password>
        <Value>{password}</Value>
        <PlainText>true</PlainText>
    </Password>
    <Enabled>true</Enabled>
    <!-- Need to login once to let final setup complete.
    Commands below log out once finished.-->
    <LogonCount>1</LogonCount>
</AutoLogon>
""".format(username=user_name, password=password))

        return base.PLUGIN_EXECUTION_DONE, False
