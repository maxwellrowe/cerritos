$(document).ready(function () {
	console.log('hi');
    $('#menuLeft').find('li a').each(function () {
        if (window.location.href.indexOf($(this).attr('href')) != -1) {
            $('#menuLeft').find('li').removeClass('selected');
            $(this).parent().addClass('selected');
        }
    });
});
