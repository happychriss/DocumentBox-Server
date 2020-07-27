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
    var sort_org_x_position=null;

    $(".uploaded").each(function (index) {
        // THIS is LI
        $(this).on("dragstart", function (e) {
//            $(this).find('.clickzoom').addClass("no_clickzoom"); //prevent event propagation, so clickzoom will not be triggerd
            dragUpload = e.target;
            $(this).addClass("dragstop")
            $(this).fadeTo("fast",0)
        });
    });

    target.ondragstart = function (e) {
        sort_org_x_position=e.clientX
        console.log(sort_org_x_position)
    }

    // this is the UL (target)
    target.ondrop = function (e) {
        e.preventDefault()
        if (dragUpload != null) {
            console.log("Drop into Target-Sorting")
            var a = document.getElementById(dragUpload.id)
            if (a.classList.contains("uploaded")) {
                console.log("Coming fresh from Upload")
                a.classList.add("sorting")
                a.classList.remove("uploaded")
                a.classList.add("page_sort")
                target.appendChild(a)

            // Pages are reorderd in the target list
            } else {
                console.log("target:"+e.clientX.toString())

                if (e.clientX>sort_org_x_position) {
                    console.log("append")
                    target.append(a)
                } else {
                    console.log("prepend")
                    target.prepend(a)
                }
            }
            a.classList.remove("dragstop")
            align_pages()
        }
    }

    source.ondrop = function (e) {
        e.preventDefault()
        if (dragUpload != null) {
            console.log("Drop back to upload")
            let a = document.getElementById(dragUpload.id)
            if (a.classList.contains("sorting")) {

                a.classList.remove("sorting")
                a.classList.remove("page_sort")
                a.classList.remove("drag_stop")
                a.classList.add("uploaded")
                a.removeAttribute("style")
                a.style.zIndex = 'auto'

                source.appendChild(a)

                align_pages()
            }
        }
    }

    source.ondragend = function (e) {
        if (dragUpload != null && dragUpload != this) {
            let a = document.getElementById(dragUpload.id)
            $(a).fadeTo("fast",1)
            a.classList.remove("dragstop")
        }
    }


    source.ondragover = function (e) {
        console.log("Dragover-Source")
        if (dragUpload != null && dragUpload != this) {
            e.preventDefault();
        }
    }

    target.ondragover = function (e) {
        console.log("Dragover-Target")
        if (dragUpload != null && dragUpload != this) {
            e.preventDefault();
        }
    }



}
