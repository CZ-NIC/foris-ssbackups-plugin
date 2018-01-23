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
      } else {
        // TODO Error message
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
          // TODO display some nice message
          alert(data.result);
          switch (data.result) {
            case "passed":
              break;
            case "gpg_error":
              break;
            case "connection_error":
              break;
          }
        } else {
          // TODO error message
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        // TODO render error
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
          // TODO display some nice message
          alert(data.result);
          switch (data.result) {
            case "passed":
              break;
            case "not_found":
              break;
            case "connection_error":
              break;
          }
        } else {
          // TODO error message
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        // TODO render error
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
          // TODO display some nice message
          alert(data.result);
          switch (data.result) {
            case "passed":
              break;
            case "not_found":
              break;
            case "connection_error":
              break;
          }
        } else {
          // TODO error message
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        // TODO render error
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
          // TODO display some nice message
          alert(data.result);
          switch (data.result) {
            case "passed":
              break;
            case "not_found":
              break;
            case "gpg_error":
              break;
            case "connection_error":
              break;
          }
        } else {
          // TODO error message
        }
      },
      error: function(jqXHR, textStatu, errorThrown) {
        // TODO render error
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
