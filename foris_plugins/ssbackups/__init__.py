# Foris ssbackups plugin
# Copyright (C) 2018 CZ.NIC, z. s. p. o. <https://www.nic.cz>
#
# Foris is distributed under the terms of GNU General Public License v3.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import base64
import bottle
import os


from datetime import datetime

from foris import fapi, validators
from foris.config import ConfigPageMixin, add_config_page
from foris.config_handlers import BaseConfigHandler
from foris.form import Password
from foris.plugins import ForisPlugin
from foris.state import current_state
from foris.utils.translators import gettext_dummy as gettext, gettext as _


EXTRA_TRANSLATIONS = [
    _('Creating an automatic Cloud Backup from your router failed.'),
]


class SsbackupsPluginConfigHandler(BaseConfigHandler):
    userfriendly_title = gettext("Cloud Backups")

    def get_form(self):
        form = fapi.ForisForm("create_and_upload", self.data)
        section = form.add_section(
            name="passwords",
            title=self.userfriendly_title,
        )
        section.add_field(
            Password, name="password", label=_("Password"), required=True,
            validators=validators.LenRange(6, 128)
        )
        section.add_field(
            Password, name="password_validation", label=_("Password (repeat)"), required=True,
            validators=validators.EqualTo(
                "password", "password_validation", _("Passwords are not equal.")
            )
        )

        def form_cb(data):
            res = current_state.backend.perform(
                "ssbackups", "set_password",
                {"password": base64.b64encode(data["password"].encode()).decode()}
            )
            return "save_result", res  # store {"result": ...} to be used later...

        form.add_callback(form_cb)
        return form


class SsbackupsPluginPage(ConfigPageMixin, SsbackupsPluginConfigHandler):
    slug = "ssbackups"
    menu_order = 80
    template = "ssbackups/ssbackups"
    template_type = "jinja2"

    def save(self, *args, **kwargs):
        return super(SsbackupsPluginPage, self).save(*args, **kwargs)

    def _prepare_render_args(self, args):
        args['PLUGIN_NAME'] = SsbackupsPlugin.PLUGIN_NAME
        args['PLUGIN_STYLES'] = SsbackupsPlugin.PLUGIN_STYLES
        args['PLUGIN_STATIC_SCRIPTS'] = SsbackupsPlugin.PLUGIN_STATIC_SCRIPTS
        args['PLUGIN_DYNAMIC_SCRIPTS'] = SsbackupsPlugin.PLUGIN_DYNAMIC_SCRIPTS
        args['backups'] = []  # will be rendered later using js
        args['password_ready'] = \
            current_state.backend.perform("ssbackups", "password_ready")["result"] == "passed"

    def render(self, **kwargs):
        self._prepare_render_args(kwargs)
        return super(SsbackupsPluginPage, self).render(**kwargs)

    def _prepare_list_data(self, data):
        for record in data:
            parsed = datetime.strptime(record["created"], "%Y-%m-%dT%H:%M:%S.%fZ")
            # parsed is in utc we need to convert it to localtime
            timestamp = (parsed - datetime(1970, 1, 1)).total_seconds()  # convert to timestamp
            parsed_local = datetime.fromtimestamp(timestamp)  # convert to local datetime
            record["created"] = parsed_local.strftime("%Y-%m-%d %H:%M:%S")
        data.sort(key=lambda x: x["id"])
        return data

    def _action_list(self):
        # this could raise an exception in this case js should render that this request failed
        data = current_state.backend.perform("ssbackups", "list")
        return bottle.template(
            "ssbackups/_backups.html.j2",
            backups=self._prepare_list_data(data["backups"]),
            template_adapter=bottle.Jinja2Template,
        )

    def _get_post_item(self, name):
        if bottle.request.method != 'POST':
            raise bottle.HTTPError(405, "Method not allowed.")
        try:
            return bottle.request.POST.get(name)
        except KeyError:
            raise bottle.HTTPError(400, "%s is missing." % name)

    def _action_create_and_upload(self):
        bottle.response.set_header("Content-Type", "application/json")
        return current_state.backend.perform(
            "ssbackups", "create_and_upload",
        )

    def _action_delete(self):
        backup_id = self._get_post_item("id")
        bottle.response.set_header("Content-Type", "application/json")
        return current_state.backend.perform(
            "ssbackups", "delete",
            {"id": int(backup_id)}
        )

    def _action_set_on_demand(self):
        backup_id = self._get_post_item("id")
        bottle.response.set_header("Content-Type", "application/json")
        return current_state.backend.perform(
            "ssbackups", "set_on_demand",
            {"id": int(backup_id)}
        )

    def _action_download_and_restore(self):
        backup_id = self._get_post_item("id")
        password = self._get_post_item("password")
        bottle.response.set_header("Content-Type", "application/json")
        return current_state.backend.perform(
            "ssbackups", "download_and_restore",
            {"id": int(backup_id), "password": base64.b64encode(password.encode()).decode()}
        )

    def call_ajax_action(self, action):
        if action == "list":
            return self._action_list()

        elif action == "create_and_upload":
            return self._action_create_and_upload()

        elif action == "delete":
            return self._action_delete()

        elif action == "set_on_demand":
            return self._action_set_on_demand()

        elif action == "download_and_restore":
            return self._action_download_and_restore()

        raise ValueError("Unknown AJAX action.")


class SsbackupsPlugin(ForisPlugin):
    PLUGIN_NAME = "ssbackups"
    DIRNAME = os.path.dirname(os.path.abspath(__file__))

    PLUGIN_STYLES = [
        "css/ssbackups.css"
    ]
    PLUGIN_STATIC_SCRIPTS = [
    ]
    PLUGIN_DYNAMIC_SCRIPTS = [
        "ssbackups.js"
    ]

    def __init__(self, app):
        super(SsbackupsPlugin, self).__init__(app)
        add_config_page(SsbackupsPluginPage)
