 $("#menuLeft a").click(function (e) {
     //if ($(this).attr("href") == '#') {
         e.preventDefault();
         $(this).closest('li').children('ul').toggle();
     //}
 });
//$( window ).load(function() {
////  $("#menuLeft li a").css('menu','hidden');
//});
