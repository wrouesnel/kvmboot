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
# Loads and modifies the Unattend.xml file to replace the ComputerName stanza.

import os
# from lxml import etree

from oslo_log import log as oslo_logging

from cloudbaseinit.osutils import factory as osutils_factory
from cloudbaseinit import conf as cloudbaseinit_conf
from cloudbaseinit import exception
from cloudbaseinit.plugins.common import base


CONF = cloudbaseinit_conf.CONF
LOG = oslo_logging.getLogger(__name__)


class UpdateComputerNameInUnattend(base.BasePlugin):

    def execute(self, service, shared_data):
        osutils = osutils_factory.get_os_utils()
        metadata_host_name = service.get_host_name()

        if not metadata_host_name:
            LOG.debug('Hostname not found in metadata')
            metadata_host_name = ""

        template = os.path.join(
            os.environ["WINDIR"], "Panther", "Unattend.xml")

        output = os.path.join(os.environ["WINDIR"], "Panther", "Unattend.xml")

        # tree = etree.parse("win-common/cloudbase/cloudbase-init/Unattend.xml")
        # root = tree.getroot()
        # t = root.xpath('/ns:unattend/ns:settings[@pass="specialize"]/ns:component[@name="Microsoft-Windows-Shell-Setup"]/ns:ComputerName',
        #       namespaces={
        #           "ns" : "urn:schemas-microsoft-com:unattend"
        #       })
        # t[0].text = metadata_host_name

        with open(template, "rt") as f:
            output_data = f.read()
            output_data = output_data.replace(
                "<ComputerName>PROVISIONING</ComputerName>",
                "<ComputerName>{}</ComputerName>".format(metadata_host_name))

        with open(output, "wt") as f:
            #f.write(etree.tostring(tree, pretty_print=True))
            f.write(output_data)

        return base.PLUGIN_EXECUTION_DONE, False
