Foris.ssbackupsHideMsg = function(element) {
    if ($(element).is(":visible")) {
        $(element).hide("fast")
    }
    $(element).text("");
};

Foris.ssbackupsShowMsg = function(element, error) {
    if ($(element).is(":visible")) {
        $(element).hide("fast")
        $(element).text(error);
        $(element).show("fast");
    } else {
        $(element).text(error);
        $(element).show("slow");
    }
};


Foris.download_backups = function(new_array, changed_array, delete_array) {
  $("#ssbackups-no-backups").text('{{ trans("Loading backup list...") }}');
  $.get('{{ url("config_ajax", page_name="ssbackups") }}', {action: "list"})
    .done(function(response, status, xhr) {
      if (xhr.status == 200) {
        $("#ssbackups-backups").replaceWith(response);  // replace the table
        // TODO highglight new, changed, deleted
        Foris.overrideDelete();
        Foris.overrideSetOnDemand();
        Foris.overrideDownloadAndRestore();
        Foris.ssbackupsHideMsg("#ssbackup-error");
      } else {
        Foris.ssbackupsHideMsg("#ssbackup-success");
        Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to download the backup list.') }}");
      }
    })
};

Foris.overrideCreateBackup = function () {
  var newBackupForm = $("#create-remote-backup-form");
  newBackupForm.submit(function(event) {
    event.preventDefault();
    var data = newBackupForm.serialize();
    data += "&action=create_and_upload";
    $.ajax({
      type: "POST",
      url: '{{ url("config_ajax", page_name="ssbackups") }}',
      data: data,
      success: function(data, text, xhr) {
        if (xhr.status == 200) {
          // Data are reload by WS just display some message here
          switch (data.result) {
            case "passed":
                Foris.ssbackupsHideMsg("#ssbackup-error");
                Foris.ssbackupsShowMsg("#ssbackup-success", "{{ trans('The backup was successfully created.') }}");
              break;
            case "gpg_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to encrypt the backup.') }}");
              break;
            case "connection_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to connect to the ssbackup server.') }}");
              break;
          }
        } else {
          Foris.ssbackupsHideMsg("#ssbackup-success");
          Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to create a backup.') }}");
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        Foris.ssbackupsHideMsg("#ssbackup-success");
        Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to create a backup.') }}");
      }
    });
  });
};

Foris.overrideDelete = function () {
  $('#ssbackups-table-form button[name="delete"]').click(function (event) {
    event.preventDefault();
    var data = $(this).parents("form:first").serialize();
    data += "&action=delete&id=" + $(this).val();
    $.ajax({
      type: "POST",
      url: '{{ url("config_ajax", page_name="ssbackups") }}',
      data: data,
      success: function(data, text, xhr) {
        if (xhr.status == 200) {
          switch (data.result) {
            case "passed":
                Foris.ssbackupsHideMsg("#ssbackup-error");
                Foris.ssbackupsShowMsg("#ssbackup-success", "{{ trans('The backup was successfully deleted.') }}");
              break;
            case "not_found":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('The backup was not found.') }}");
              break;
            case "connection_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to connect to the ssbackup server.') }}");
              break;
          }
        } else {
          Foris.ssbackupsHideMsg("#ssbackup-success");
          Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to delete the backup.') }}");
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        Foris.ssbackupsHideMsg("#ssbackup-success");
        Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to delete the backup.') }}");
      }
    });
  });
};

Foris.overrideSetOnDemand = function () {
  $('#ssbackups-table-form button[name="set-on-demand"]').click(function (event) {
    event.preventDefault();
    var id = $(this).val();
    var data = $(this).parents("form:first").serialize();
    data += "&action=set_on_demand&id=" + id;
    $.ajax({
      type: "POST",
      url: '{{ url("config_ajax", page_name="ssbackups") }}',
      data: data,
      success: function(data, text, xhr) {
        if (xhr.status == 200) {
          switch (data.result) {
            case "passed":
                Foris.ssbackupsHideMsg("#ssbackup-error");
                Foris.ssbackupsShowMsg("#ssbackup-success", "{{ trans('The backup was successfully marked to keep.') }}");
              break;
            case "not_found":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('The backup was not found.') }}");
              break;
            case "connection_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to connect to the ssbackup server.') }}");
              break;
          }
        } else {
          Foris.ssbackupsHideMsg("#ssbackup-success");
          Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to keep the backup.') }}");
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        Foris.ssbackupsHideMsg("#ssbackup-success");
        Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to keep the backup.') }}");
      }
    });
  });
};


Foris.overrideDownloadAndRestore = function () {
  $('#ssbackups-table-form button[name="download-and-restore"]').click(function (event) {
    event.preventDefault();
    // TODO implement a propper password prompt using javascript
    var password = window.prompt("{{ trans('Enter password for backup:') }}")
    var id = $(this).val();
    var data = $(this).parents("form:first").serialize();
    data += "&action=download_and_restore&id=" + id + "&password=" + password;
    $.ajax({
      type: "POST",
      url: '{{ url("config_ajax", page_name="ssbackups") }}',
      data: data,
      success: function(data, text, xhr) {
        if (xhr.status == 200) {
          switch (data.result) {
            case "passed":
                Foris.ssbackupsHideMsg("#ssbackup-error");
                Foris.ssbackupsShowMsg("#ssbackup-success", "{{ trans('The backup was successfully restored.') }}");
              break;
            case "not_found":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('The backup was not found.') }}");
              break;
            case "gpg_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to decrypt the backup.') }}");
              break;
            case "connection_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to connect to the ssbackup server.') }}");
              break;
          }
        } else {
          Foris.ssbackupsHideMsg("#ssbackup-success");
          Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to restore the backup.') }}");
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        Foris.ssbackupsHideMsg("#ssbackup-success");
        Foris.ssbackupsShowMsg("#ssbackup-error", "{{ trans('Failed to restore the backup.') }}");
      }
    });
  });
};

Foris.WS["ssbackups"] = function(msg) {
    switch(msg["action"]) {
      case "delete":
        Foris.download_backups([], [], [msg.data.id]);
        break;
      case "create_and_upload":
        Foris.download_backups([msg.data.id], [], []);
        break;
      case "set_on_demand":
        Foris.download_backups([], [msg.data.id], []);
        break;
      case "download_and_restore":
        location.reload();
        break;
    }
};

$(document).ready(function() {
  Foris.download_backups([], [], []);
  Foris.overrideCreateBackup();
});
