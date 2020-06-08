UpdateCoverPages = function () {
    $('#new_cover_folder').on('change', function () {
        $.ajax({
            url: "/show_cover_pages/" + this.value,
            dataType : 'script'
        });

    });
}

$(document).ready(function () {
    UpdateCoverPages();
});
