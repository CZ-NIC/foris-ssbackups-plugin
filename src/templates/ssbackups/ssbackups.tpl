%rebase("config/base.tpl", **locals())

<div id="page-ssbackups-plugin" class="config-page">
    %include("_messages.tpl")
    <div class="message success" id="ssbackup-success" style="display: none"></div>
    <div class="message error" id="ssbackup-error" style="display: none"></div>

    <p>{{ trans("Server side backups allow you to store the router's configuration on a remote server.") }}</p>
    <p>{{ trans("The password you set is submitted every time a backup is used. The password isn't stored anywhere and it is not renewable, so in case of a forgotten password, you will not be able access backups and will have to delete and reinstall the package. ") }}</p>
    <p>{{ trans("Server side backups are created automatically every night as well as manually. The service stores up to seven backups, additional backups are gradually overwritten unless the user selects Keep. Once the backup is kept, it will remain stored on a remote server until deleted. ") }}</p>
    %if not password_ready:
    <div class="message warning">{{ trans("In order to create remote backups, you first need to set the password.") }}</div>
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
