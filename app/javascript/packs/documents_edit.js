// Sorting the order of docs by updating the position hidden field
require("jquery-ui/ui/widgets/sortable")
require("jquery-ui/ui/widgets/draggable")
require("jquery-ui/ui/widgets/droppable")
require("flatpickr/dist/flatpickr.css")
require("flatpickr/dist/themes/confetti.css")

UpdateDocumentPages = function () {

    $('.doc_sort_list').sortable({
        dropOnEmpty: false,
        items: 'li',
        opacity: 0.4,
        scroll: true,
        update: function(e,ui) {
            $.ajax({
                type: 'post',
                data: $('.doc_sort_list').sortable('serialize') ,
                dataType: 'script',
                complete: function(request) {
                    $('#docs').effect('highlight');
                },

                url: '/sort_pages'
            })

            ui.item.find('.clickzoom').addClass("no_clickzoom"); //prevent event propagation, so clickzoom will not be triggerd

        }

    });
};

$(document).ready(function () {
    UpdateDocumentPages();
//    SimplePollStatus();

});




