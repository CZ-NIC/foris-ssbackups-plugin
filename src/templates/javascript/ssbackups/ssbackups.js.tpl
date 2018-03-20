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

Foris.ssbackupsMessages = {
    loadingList: "{{ trans('Loading backup list...') }}",
    failedToDownloadList: "{{ trans('Failed to download the list of  backups.') }}",
    backupCreated: "{{ trans('A backup was successfully created.') }}",
    failedToEncrypt: "{{ trans('Failed to encrypt the backup.') }}",
    failedToConnect: "{{ trans('Failed to connect to the ssbackup server.') }}",
    failedToCreateBackup: "{{ trans('Failed to create a backup.') }}",
    backupDeleted: "{{ trans('The backup was successfully deleted.') }}",
    backupNotFound: "{{ trans('The backup was not found.') }}",
    failedToDelete: "{{ trans('Failed to delete the backup.') }}",
    backupKept: "{{ trans('The backup was successfully marked to keep.') }}",
    failedToKeep: "{{ trans('Failed to keep the backup.') }}",
    backupRestored: "{{ trans('The backup was successfully restored.') }}",
    failedToDecrypt: "{{ trans('Failed to decrypt the backup. You probably inserted a wrong password.') }}",
    failedToRestore: "{{ trans('Failed to restore the backup.') }}",
}


Foris.download_backups = function(new_array, changed_array, delete_array) {
  $("#ssbackups-no-backups").text(Foris.ssbackupsMessages.loadingList);
  $.get('{{ url("config_ajax", page_name="ssbackups") }}', {action: "list"})
    .done(function(response, status, xhr) {
      if (xhr.status == 200) {
        $("#ssbackups-backups").replaceWith(response);  // replace the table
        // TODO highglight new, changed, deleted according to *_array vars
        Foris.overrideDelete();
        Foris.overrideSetOnDemand();
        Foris.overrideDownloadAndRestore();
        Foris.ssbackupsHideMsg("#ssbackup-error");
      } else {
        Foris.ssbackupsHideMsg("#ssbackup-success");
        Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToDownloadList);
      }
    })
    .fail(function(response, status, xhr) {
        Foris.ssbackupsHideMsg("#ssbackup-success");
        Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToDownloadList);
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
                Foris.ssbackupsShowMsg("#ssbackup-success", Foris.ssbackupsMessages.backupCreated);
              break;
            case "gpg_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToEncrypt);
              break;
            case "connection_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToConnect);
              break;
          }
        } else {
          Foris.ssbackupsHideMsg("#ssbackup-success");
          Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToCreateBackup);
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        Foris.ssbackupsHideMsg("#ssbackup-success");
        Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToCreateBackup);
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
                Foris.ssbackupsShowMsg("#ssbackup-success", Foris.ssbackupsMessages.backupDeleted);
              break;
            case "not_found":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.backupNotFound);
              break;
            case "connection_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToConnect);
              break;
          }
        } else {
          Foris.ssbackupsHideMsg("#ssbackup-success");
          Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToDelete);
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        Foris.ssbackupsHideMsg("#ssbackup-success");
        Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToDelete);
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
                Foris.ssbackupsShowMsg("#ssbackup-success", Foris.ssbackupsMessages.backupKept);
              break;
            case "not_found":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.backupNotFound);
              break;
            case "connection_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToConnect);
              break;
          }
        } else {
          Foris.ssbackupsHideMsg("#ssbackup-success");
          Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToKeep);
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        Foris.ssbackupsHideMsg("#ssbackup-success");
        Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToKeep);
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
                Foris.ssbackupsShowMsg("#ssbackup-success", Foris.ssbackupsMessages.backupRestored);
              break;
            case "not_found":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.backupNotFound);
              break;
            case "gpg_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToDecrypt);
              break;
            case "connection_error":
                Foris.ssbackupsHideMsg("#ssbackup-success");
                Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToConnect);
              break;
          }
        } else {
          Foris.ssbackupsHideMsg("#ssbackup-success");
          Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToRestore);
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        Foris.ssbackupsHideMsg("#ssbackup-success");
        Foris.ssbackupsShowMsg("#ssbackup-error", Foris.ssbackupsMessages.failedToRestore);
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
