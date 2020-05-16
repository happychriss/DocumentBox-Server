require("jquery-ui/ui/widgets/sortable")
require("jquery-ui/ui/widgets/draggable")
require("jquery-ui/ui/widgets/droppable")
require("flatpickr/dist/flatpickr.css")

Sortable1 = function (){
    $("li","#sortable1").draggable({
        placeholder: "spaceholder", //trick not to display any spaceholder
        cancel: "a.ui-icon", // clicking an icon won't initiate dragging
        revert: "invalid", // when not dropped, the item will revert back to its initial position
        containment: "document",
        cursor: "move",
        zIndex:10        ,
        stop: function (ev, ui) {
            align_pages();
        }
    });


    $("#sortable1").droppable({
        accept: "#sortable2 li",
        activeClass: "ui-state-highlight",
        drop: function( event, ui ) {
            a=ui.draggable;
            a.removeAttr('style');
            a.removeClass('page_sort').addClass('preview');
            a.appendTo(this);
            a.css("z-index", 'auto');
        }
    });
}


SortPages = function () {

// sorted pages, on mouseover make page top (z-index, store old index), on mouse out reset z-indes
    $('#sortable2').on('mouseenter mouseleave', '.page_sort .preview_footer', function (event) {
        var page = $(this).parent();

        if (event.type == 'mouseenter') {
            page.data("old-z-index", page.css("z-index"));

            page.css("z-index", "10000");
            page.css("background", "darkgrey");
            $('.document_sort_frame .preview').each(function () {
                if ($(this)[0] != $(page)[0]) {
                    $(this).fadeTo(0, 0.3)
                }
            })


        } else {
            $('.document_sort_frame .preview').each(function () {
                if ($(this)[0] != $(page)[0]) {
                    $(this).fadeTo(0, 1)
                }
            })
            page.css("z-index", page.data("old-z-index"))
            page.css("background", "#d3d3d3")

        }
    });



    $("#sortable2").droppable({
        drop: function (ev, ui) {
            a=ui.draggable;
            a.removeAttr( 'style' );
            a.addClass('page_sort');
            a.appendTo(this);
        }
    });

    // when a sortable page is deleted, the destroy_page.js.erb sends updatesort to re-sort the pages
    $("#sortable2").bind('updatesort', function () {
        align_pages();
    });


    // if problems are here, the event https://intellij-support.jetbrains.com/hc/en-us/community/posts/360003442619-JS-Event-depreciated-warning-in-inspector
    // https://api.jquery.com/submit/
    // submit button for upload
    $('#new_document').submit(function (event ) {
        $('#sortable2').sortable();
        let button_id = event.originalEvent.submitter.id;
        if (button_id=='id_pdf_btn') {
            if (!(window.confirm("No backup, only PDF is generated"))) {
                return false;
            }
        }

        $.post($(this).attr('action'), $(this).serialize() + "&" + button_id+"&" +$('#sortable2').sortable('serialize'), null, "script");
        return false;
    });

}

function align_pages() {
    var items = $('.document_sort_frame .preview');
    items.fadeTo(0, 1);

    var page_size = 350;
    var sort_box_with = $('.document_sort_frame').innerWidth();
    var max_size = sort_box_with - 150
    var n = items.length;
    var z = n + 100

    var margin = ((n * page_size) - max_size) / (n - 1);
    if (margin < 0) {
        margin = 0
    }

    var b_margin = false;
    items.each(function () {

        if (b_margin) {
            $(this).css("margin-left", -margin + 'px');
        }
        else {
            $(this).css("margin-left", '0px');
        }
        $(this).css("z-index", z);
        z = z - 1

        b_margin = true;
    });

}

AddScannerSpinner = function () {

$('#scan_menu_link').bind('ajax:beforeSend', function() {
    $('#scan_menu_spinner').show();
});


};

// https://code.google.com/p/jqueryrotate/w/list


//****************************************************************************************


//****************************************************************************************

$(document).ready(function () {
    Sortable1();
    SortPages();
    AddScannerSpinner();
});
