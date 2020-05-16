/* Required markup sample

 <div class='preview'>
 <img src="small.jpg" alt="" bigpic='big.jpg'>
 <div/>

 <%=link_to(image_tag(doc.get_image_path+'s.jpg', :class => 'zoom'),edit_sort_path(doc.id), :bigjpg=>doc.get_image_path+'.jpg', :id=>count_id)%>
 */

clickzoom = function() {

    $("#container").on('click','.clickzoom',function(e) {

        if ($(this).hasClass('no_clickzoom')){
            $(this).removeClass('no_clickzoom');
            return
        }

        if ($("#click_zoom").length!=0){
            $("#click_zoom").remove();
        } else {

        var big_image_name = $(this).attr('bigjpg');
        var newImg = new Image();
        newImg.src =big_image_name;
        newImg.id='click_zoom';


        new_window = $("#container").append(newImg);

        e.stopPropagation();

        new_window.on('click',function() {
            $("#click_zoom").remove();
        })
        }

    });
};


// starting the script on page load
$(document).ready(function() {
    clickzoom();
});
