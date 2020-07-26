import consumer from "./consumer"
import {UploadSorting} from '../packs/module_upload_sorting'



consumer.subscriptions.create("UploadUpdateChannel", {
    connected() {
        // Called when the subscription is ready for use on the server
    },

    disconnected() {
        // Called when the subscription has been terminated by the server
    },

    received(data) {

        // Called when there's incoming data on the websocket for this channel
        let page_id = data.page_id
        let page_html = data.page_html
        let update_source = data.update_source
        let result_message = data.result_message
        let scan_complete = data.scan_complete

        // **********+ Uploaded from Converter, updating an existing page

        if (update_source === 'Converter') {
            $('#convert_status').text(result_message);
            if (page_id !== '') {
                let p_div = $('#' + data.page_id + '.uploaded')
                if (p_div.length) {
                    p_div.replaceWith(page_html)
                    UploadSorting();
                }
            }
        }

        // **********+ Uploaded from Scanner, appending an new page

        if (update_source === 'Scanner') {
            $('#scanner_status').text(result_message)

            if (scan_complete === true) {
                $('#scann_working_spinner').hide();
                $('#scann_button').prop('disabled', false);
                $('#color').prop('disabled', false);
            }

            if (page_id !== '') {
                $("#sortable1").append(page_html)
                UploadSorting();
            }

        }



    }
});
