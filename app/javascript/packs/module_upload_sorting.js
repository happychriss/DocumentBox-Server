function align_pages() {
    var items = $('.page_sort');
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
        } else {
            $(this).css("margin-left", '0px');
        }
        $(this).css("z-index", z);
        z = z - 1

        b_margin = true;
    });

}
export function UploadSorting() {
    console.log("I am in UploadSorting")

    let source = document.getElementById("sortable1");
    let target = document.getElementById("sortable2");

    // images are draggable=true by default - we dont want to dragg the images
    $("img").each(function () {
        this.setAttribute("draggable", "false")
    });

    var dragUpload = null;

    $(".uploaded").each(function (index) {
        $(this).on("dragstart", function (e) {
            console.log("Event-Dragable");
//            $(this).find('.clickzoom').addClass("no_clickzoom"); //prevent event propagation, so clickzoom will not be triggerd
            dragUpload = e.target;
        });
    });

    target.ondrop = function (e) {
        if (dragUpload != null) {
            console.log("Drop into Sorting")
            var a = document.getElementById(dragUpload.id)
            if (a.classList.contains("uploaded")) {
                console.log("Coming fresh from Upload")

                a.classList.add("sorting")
                a.classList.remove("uploaded")
                a.firstElementChild.classList.add("page_sort")
                target.appendChild(a)
            } else {
                target.prepend(a)
            }

            e.preventDefault()
            align_pages()
        }
    }

    source.ondrop = function (e) {
        if (dragUpload != null) {
            console.log("Drop back to upload")
            let a = document.getElementById(dragUpload.id)
            a.classList.remove("sorting")
            a.classList.add("uploaded")

            let li_element=a.firstElementChild
            li_element.classList.remove("page_sort")
            li_element.removeAttribute("style")
            li_element.css("z-index", 'auto')

            source.appendChild(a)
            e.preventDefault()
            align_pages()
        }
    }


    source.ondragover = function (e) {
        console.log("Dragover-Source")
        if (dragUpload != null && dragUpload != this) {
            e.preventDefault();
        }
    }

    target.ondragover = function (e) {
        console.log("Dragover")
        if (dragUpload != null && dragUpload != this) {
            e.preventDefault();
        }
    }

    target.ondragleave = function (e) {
        console.log("Dragleave")
        if (dragUpload != null && dragUpload != this) {
            e.preventDefault();
        }
    }

    target.ondragend = function (e) {
        console.log("Dragend")
        if (dragUpload != null) {
            dragUpload = null
        }
        e.preventDefault();
    }


};
