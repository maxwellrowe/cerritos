$(document).ready(function () {
    $('#menuLeft').find('li a').each(function () {
        if (window.location.href.indexOf($(this).attr('href')) != -1) {
            $('#menuLeft').find('li').removeClass('selected');
            $(this).parent().addClass('selected');
			$(this).parent('li').parent('ul').parent('li').addClass('selected');
        }
    });
});
