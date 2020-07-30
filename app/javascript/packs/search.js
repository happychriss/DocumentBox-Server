// enable drag and drop for the search pages

require("jquery-ui");
require("pretty-checkbox/dist/pretty-checkbox.css");

DropPages = function () {

    var dragSrcEl = null;

    $(".search_draggable").each(function (index) {

        $(this).attr('draggable', 'true');

        $(this).on("dragstart", function (e) {
            $(this).find('.clickzoom').addClass("no_clickzoom"); //prevent event propagation, so clickzoom will not be triggerd
            dragSrcEl = e.target;
            $(dragSrcEl).fadeTo('medium',0.2)
        });
    });


    $(".search_droppable").each(function (index) {

        $(this).on("drop", function (e) {
            if (dragSrcEl != null && dragSrcEl!= this) {
                e.stopPropagation()
                e.stopImmediatePropagation()
                e.preventDefault()

                var drop_id = e.target.parentElement.parentElement.id //ID is in the top div
                var drag_id = dragSrcEl.id
                var parameters = 'drop_id=' + drop_id + "&" + 'drag_id=' + drag_id;
                $.post("add_page", parameters, function (data, status) {
                });
                e.target.setAttribute('draggable','false')
            }
        })

        $(this).on("dragover", function (e) {
            if (dragSrcEl != null && dragSrcEl != this) {
                e.preventDefault();
                e.target.style.opacity = '0.1';
            }
        })

        $(this).on("dragleave", function (e) {
            if (dragSrcEl != null && dragSrcEl!= this) {
            e.preventDefault();
            e.target.style.opacity = '1';
        }})

        $(this).on("dragend", function (e) {
            e.preventDefault();
            $(dragSrcEl).fadeTo('medium',1)
        })
    });

};



$(document).ready(function () {
    DropPages();

});

