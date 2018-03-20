<div id="ssbackups-backups">
    %if backups:
  <form method='post' class="config-form" action='{{ url("config_action", page_name="ssbackups", action="backup-action") }}' id="ssbackups-table-form">
    <input type="hidden" name="csrf_token" value="{{ get_csrf_token() }}">
    <table id="ssbackups-backups-table">
        <thead>
            <tr>
                <th>{{ trans("Name") }}</th>
                <th>{{ trans("Date") }}</th>
                <th>{{ trans("Keep") }}</th>
                <th></th>
            </tr>
        </thead>
        <tbody>
    %for record in backups:
            <tr id="backup-{{ record["id"] }}">
                <td>{{ record["name"] }}</td>
                <td>{{ record["created"] }}</td>
                <td>{{ record["on_demand"] }}</td>
                <td>
                    <input style="display: none" id="password-{{ record["id"] }}" name="password-{{ record["id"] }}" type="password" class="inline-password">
                    <button name="download-and-restore" value="{{ record["id"] }}" type="submit" id="restore-{{ record["id"] }}">
                        {{ trans("Restore") }}
                    </button>
                    <button name="set-on-demand" value="{{ record["id"] }}" style="visibility: {{ "hidden" if record["on_demand"] else "visible"  }}" type="submit" id="keep-{{ record["id"] }}">
                        {{ trans("Keep") }}
                    </button>
                    <button name="delete" value="{{ record["id"] }}" type="submit" id="delete-{{ record["id"] }}">
                        {{ trans("Delete") }}
                    </button>
                </td>
            </tr>
    %end
        </tbody>
    </table>
  </form>

    %else:
  <p id="ssbackups-no-backups">{{ trans("No remote backups found.") }}</p>
    %end
</div>
