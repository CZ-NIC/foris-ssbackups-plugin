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
                <th></th>
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
                    <button name="download-and-restore" value="{{ record["id"] }}" type="submit">
                        {{ trans("Restore") }}
                    </button>
                </td>
                <td>
        %if not record["on_demand"]:
                    <button name="set-on-demand" value="{{ record["id"] }}" type="submit">
                        {{ trans("Keep") }}
                    </button>
        %end
                </td>
                <td>
                    <button name="delete" value="{{ record["id"] }}" type="submit">
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
