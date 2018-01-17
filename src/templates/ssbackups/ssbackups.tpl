%rebase("config/base.tpl", **locals())

<div id="page-ssbackups-plugin" class="config-page">
    %include("_messages.tpl")

    <p>{{ trans("Server side backups allows user to store...") }}</p>
    <p>{{ trans("Password description") }}</p>
    <p>{{ trans("Ssbackups frequency") }}</p>
    <h3>{{ trans("Create remote backup") }}</h3>
    <form action="{{ request.fullpath }}" method="post" id="create-remote-backup-form" class="config-form">
      <input type="hidden" name="csrf_token" value="{{ get_csrf_token() }}">
      %for field in form.active_fields:
          %include("_field.tpl", field=field)
      %end
      <button type="submit" name="send">{{ trans("Create") }}</button>
    </form>

    <h3>{{ trans("Remote backups") }}</h3>
    %include("ssbackups/_backups.tpl", backups=backups)
</div>
