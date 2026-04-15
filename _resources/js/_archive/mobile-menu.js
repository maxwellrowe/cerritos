// Mobile menu toggle
		$('.navbar-toggle').click(function(){
			if(!$('.cover').length) {
				$('body').append('<div class="cover"></div>');
			}
			$('.cover').fadeIn('fast');
			$('.siteNavigation').addClass('open').show().animate({
				right: "-15px"
			}, 300 );
			return false;
		});
		$('.menuClose').click(function(){
			$('.cover').fadeOut('fast');
			$('.siteNavigation').removeClass('open').animate({
				right: "-390px"
			}, 300, function() {
				$('.siteNavigation').hide();
			});
			return false;
		});

$(document).ready(function() {
	$('.student-testimonials').owlCarousel({
	loop:true,
	margin:0,
	nav:false,
	dots:true,
	autoplay: true,
	autoplayTimeout:9000,
	autoplayHoverPause:true,
	navRewind: false,
	responsive:{
	0:{
	items:1
	},
	600:{
	items:1
	},
	1000:{
	items:1
}
}
});
});


$(document).ready(function() {	
// Select all links with hashes
$('a[href*="#"]')
  // Remove links that don't actually link to anything
  .not('[href="#"]')
  .not('[href="#0"]')
  .not('[data-toggle]')
  .click(function(event) {
    // On-page links
    if (
      location.pathname.replace(/^\//, '') === this.pathname.replace(/^\//, '') 
      && 
      location.hostname === this.hostname
    ) {
      // Figure out element to scroll to
      var target = $(this.hash);
      target = target.length ? target : $('[name=' + this.hash.slice(1) + ']');
      // Does a scroll target exist?
      if (target.length) {
        // Only prevent default if animation is actually gonna happen
        event.preventDefault();
        $('html, body').animate({
          scrollTop: target.offset().top
        }, 1000, function() {
          // Callback after animation
          // Must change focus!
          var $target = $(target);
          $target.focus();
          if ($target.is(":focus")) { // Checking if the target was focused
            return false;
          } else {
            $target.attr('tabindex','-1'); // Adding tabindex for elements not focusable
            $target.focus(); // Set focus again
          }
        });
      }
    }
  });

  });

jQuery(document).ready(function($){
	// browser window scroll (in pixels) after which the "back to top" link is shown
	var offset = 300,
		//browser window scroll (in pixels) after which the "back to top" link opacity is reduced
		offset_opacity = 1200,
		//duration of the top scrolling animation (in ms)
		scroll_top_duration = 700,
		//grab the "back to top" link
		$back_to_top = $('.back-to-top');

	//hide or show the "back to top" link
	$(window).scroll(function(){
		( $(this).scrollTop() > offset ) ? $back_to_top.addClass('is-visible') : $back_to_top.removeClass('is-visible fade-out');
		if( $(this).scrollTop() > offset_opacity ) { 
			$back_to_top.addClass('fade-out');
		}
	});

	//smooth scroll to top
	$back_to_top.on('click', function(event){
		event.preventDefault();
		$('body,html').animate({
			scrollTop: 0 ,
		 	}, scroll_top_duration
		);
	});

});

