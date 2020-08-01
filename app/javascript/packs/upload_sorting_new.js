require("jquery-ui")
require("flatpickr/dist/flatpickr.css")
require("flatpickr/dist/themes/confetti.css")
require("pretty-checkbox/dist/pretty-checkbox.css")

import {NeverDeleteCheckBox, UploadSorting} from './module_upload_sorting'

function PDFPrint() {
    // if problems are here, the event https://intellij-support.jetbrains.com/hc/en-us/community/posts/360003442619-JS-Event-depreciated-warning-in-inspector
    // https://api.jquery.com/submit/
    // submit button for upload
    $('#new_document').submit(function (event) {

        let button_id = event.originalEvent.submitter.id;
        if (button_id === 'id_pdf_btn') {
            if (!(window.confirm("No backup, only PDF is generated"))) {
                return false;
            }
        }

        // how to include all ul/li documents into the form: https://stackoverflow.com/questions/3287336/best-way-to-submit-ul-via-post
        $.post($(this).attr('action'), $(this).serialize() + "&" + button_id, null, "script");
        return false;
    });
}


// Depending on button presses (Scann or Upload) the menue is shown
// For the scanner, only a waiting circle is shown, in background the scanner is called - after callback the menue is displayed
function PrepareScanUploadMenue() {

    $('.button_to').bind('ajax:beforeSend', function (e) {
        let button_pressed = this[0].id  // this returns the form and not the button, but first element is the button pressed

        $('#info_menu').hide()

        if (button_pressed === 'btn_start_upload') {
            // Upload  selected - just enable the hidden menue
            $('#scan_menu').fadeOut('medium', function () {
                $('#btn_start_upload').prop("disabled", true);
                $('#scan_menu_link').prop("disabled", false);
                $('#file_upload_my_file').val('')
                $('#upload_result').empty()

                $('#upload_menu').fadeIn('medium')
                e.preventDefault();
            })
        } else {
            // Scan Menue selected - this will render the scan menue, as event is propagated
            $('#upload_menu').fadeOut('medium', function () {
                $('#scan_menu').fadeIn('medium')
                $('#scan_menu_link').prop("disabled", true);
                $('#btn_start_upload').prop("disabled", false);
            })
        }
    });

    // ***************+ Upload a file *********************************************************
    // Triggers the autocomit after file upload (browse), the form-input button is hidden
    // form.submit did not work, triggered hmtl
    $('#file_upload_my_file').change(function (e) {
        $('#upload_result').empty().append('Loading...').css("color", "black");
        $("#submit_for_upload").click()
    })

}


$(document).ready(function () {
    UploadSorting();
    PrepareScanUploadMenue();
    NeverDeleteCheckBox();
    PDFPrint();
});
