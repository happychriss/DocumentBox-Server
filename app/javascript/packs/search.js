// enable drag and drop for the search pages
require("jquery-ui/ui/widgets/sortable")
require("jquery-ui/ui/widgets/draggable")
require("jquery-ui/ui/widgets/droppable")
require("pretty-checkbox/dist/pretty-checkbox.css")

DropPages = function () {
    $(".search_draggable").draggable({
        revert: 'invalid',
        zIndex: 2000,
        stop: function(event,ui) {
            $(this).find('.clickzoom').addClass("no_clickzoom"); //prevent event propagation, so clickzoom will not be triggerd
        }

    });

    $(".search_droppable").droppable({
        accept: ".search_draggable",
        drop: function( event, ui ) {
            var drop_id=this.id;
            var drag_id=ui.draggable.attr("id");

            var parameters = 'drop_id='+drop_id+"&"+'drag_id='+drag_id;
            $.post("add_page", parameters,  function(data, status)
            {
                console.log(status);
            });


        }

    });

};

$(document).ready(function () {
    DropPages();

});

