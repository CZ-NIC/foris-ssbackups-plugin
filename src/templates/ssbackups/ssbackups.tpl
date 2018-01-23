%rebase("config/base.tpl", **locals())

<div id="page-ssbackups-plugin" class="config-page">
    %include("_messages.tpl")

    <p>{{ trans("Server side backups allows user to store...") }}</p>
    <p>{{ trans("Password description") }}</p>
    <p>{{ trans("Ssbackups frequency") }}</p>
    %if not password_ready:
    <div class="message warning">{{ trans("In order to create remote backups you need to set the password first.") }}</div>
    %end
    <form action="{{ request.fullpath }}" method="post" class="config-form">
      <input type="hidden" name="csrf_token" value="{{ get_csrf_token() }}">
      %for field in form.active_fields:
          %include("_field.tpl", field=field)
      %end
      <button type="submit" name="send">{{ trans("Set password") }}</button>
    </form>
    <h3>{{ trans("Remote backups") }}</h3>
    %include("ssbackups/_backups.tpl", backups=backups)

    %if password_ready:
    <form action="{{ request.fullpath }}" method="post" id="create-remote-backup-form" class="config-form" action="{{ url("config_ajax", page_name="ssbackups") }}?action=create_and_upload">
      <input type="hidden" name="csrf_token" value="{{ get_csrf_token() }}">
      <button type="submit" name="send">{{ trans("Create") }}</button>
    </form>
    %end
</div>
