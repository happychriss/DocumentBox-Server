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
//        $('#sortable2').sortable();
        let button_id = event.originalEvent.submitter.id;
        if (button_id === 'id_pdf_btn') {
            if (!(window.confirm("No backup, only PDF is generated"))) {
                return false;
            }
        }

        // how to include all ul/li documents into the form: https://stackoverflow.com/questions/3287336/best-way-to-submit-ul-via-post
        $.post($(this).attr('action'), $(this).serialize() + "&" + button_id , null, "script");
        return false;
    });
}

function AddScannerSpinner() {

    $('#scan_menu_link').bind('ajax:beforeSend', function () {
        $('#scan_menu_spinner').show();
    });


};


// https://code.google.com/p/jqueryrotate/w/list




$(document).ready(function () {
    UploadSorting();
    AddScannerSpinner();
    NeverDeleteCheckBox();
    PDFPrint();
});
