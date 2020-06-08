DeleteNo = function () {
    $('#cb_no_delete').on('click', function () {
        CheckBoxChange(this)
    });

    $('#lb_no_delete').on('change', function () {
        ListBoxChange(this)
    });
}
    ListBoxChange = function (obj) {
        var value = $(obj).val();
        if (value != '') {
            $('#cb_no_delete').attr('disabled', 'disabled');
        }
        else {
            $('#cb_no_delete').removeAttr('disabled');
        }

    }

    CheckBoxChange = function (obj) {
        if ($(obj).is(':checked')) {
            $('#lb_no_delete').attr('disabled', 'disabled');
        }
        else {
            $('#lb_no_delete').removeAttr('disabled');
        }
    }


$(document).ready(function () {
    CheckBoxChange($('#cb_no_delete'));
    ListBoxChange($('#lb_no_delete'));
    DeleteNo();
});
