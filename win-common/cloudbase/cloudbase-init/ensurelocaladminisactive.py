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
# Ensure the local admin account is active early in the provisioning cycle
# so that SetUserPassword works properly on fast systems.

import os
import subprocess

from oslo_log import log as oslo_logging

from cloudbaseinit import conf as cloudbaseinit_conf
from cloudbaseinit import exception
from cloudbaseinit.plugins.common import base


CONF = cloudbaseinit_conf.CONF
LOG = oslo_logging.getLogger(__name__)


class EnsureLocalAdminIsActive(base.BasePlugin):

    def execute(self, service, shared_data):
        subprocess.call(["net", "user", "Administrator", "/active:yes"])
        return base.PLUGIN_EXECUTION_DONE, False
