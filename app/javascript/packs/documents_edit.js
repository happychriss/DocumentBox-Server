// Sorting the order of docs by updating the position hidden field
// Using HTML5 as it works together with touch-punch.js
require("jquery-ui");
require("flatpickr/dist/flatpickr.css")
require("flatpickr/dist/themes/confetti.css")
require("pretty-checkbox/dist/pretty-checkbox.css")

var sel_obj = null


// Document edit does all actions before update, information is stored in in hidden input fields
// reorder pages, delete pages and remove pages
DeleteRemovePages = function () {
    $(".action_link").click(function (e) {

        // if link is clicked on the page, add page-id to hidden input field
        if ($(this).hasClass("delete_link")) {

            $('<input>').attr({
                type: 'hidden',
                name: 'delete_pages[]',
                value: this.id
            }).appendTo($(".edit_document"))
        } else {
            $('<input>').attr({
                type: 'hidden',
                name: 'remove_pages[]',
                value: this.id
            }).appendTo($(".edit_document"))
        }

        // remove the page from the DOM (fade out)
        let cache = $(this).closest('li');
        cache.fadeOut(300, function () {
            cache.remove();
        });

        // if I am the last page (removed document not included), delete the links
        if ($(".doc_sort_list").children().length === 2) {
            $(".action_link").remove()
        }

        e.preventDefault()
    })

}

// Sort of pages in documents edit with drag and drop
// to omit to many events, using "dragstop"
// important t
UpdateDocumentPages = function () {

    // images are draggable=true by default - we dont want to dragg the images
    $("img").each(function () {
        this.setAttribute("draggable", "false")
    })

    $(".sortable").each(function () {
        $(this).on("dragstart", function (e) {
            sel_obj = e.target
            $(this).find('.clickzoom').addClass("no_clickzoom"); //prevent event propagation, so clickzoom will not be triggerd
            $(this).addClass("dragstop")
        })

        $(this).on("dragend", function (e) {
            e.preventDefault();
        })

        // https://medium.com/@reiberdatschi/common-pitfalls-with-html5-drag-n-drop-api-9f011a09ee6c
        $(this).on("dragenter", function (e) {
            e.preventDefault();
            $(this).addClass("dragstop")
        })

        $(this).on("dragleave", function (e) {
            e.preventDefault();
            $(this).removeClass("dragstop")
        })

        $(this).on("dragover", function (e) {
            e.preventDefault();
            let my_target = e.target.closest('li')
            if ((sel_obj != null) &&
                e.target.classList.contains('sortable') &&  //this important, as event is not only triggered by "li sortable"
                (sel_obj !== my_target) ) {
                if (isBefore(sel_obj, my_target)) {
                    e.target.parentNode.insertBefore(sel_obj, my_target)
                } else {
                    e.target.parentNode.insertBefore(sel_obj, my_target.nextElementSibling)
                }
            }
        })
    })

}

function isBefore(el1, el2) {
    let cur
    if (el2.parentNode === el1.parentNode) {
        for (cur = el1.previousSibling; cur; cur = cur.previousSibling) {
            if (cur === el2) return true
        }
    }
    return false;
}

$(document).ready(function () {
    UpdateDocumentPages();
    DeleteRemovePages();
});




