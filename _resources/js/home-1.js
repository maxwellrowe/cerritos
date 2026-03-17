$(window).load(function() {
    $('.flexslider').flexslider({
        animationLoop: false,
		pausePlay: true,
		slideshowSpeed: 14000,
		smoothHeight: true,
		animation: "slide",
		touch: true,
		start: function() {
      		$('.flexslider li').on('click', function(e){
       		 stopVideos();
      		});
      		$('.flexslider li').on('click', function(e){
       		 stopVideos();
     	 });
		
		
    }	
		
    });
});

$('.flex-pauseplay').click(function(){ stopVideos(); return false; });

function stopVideos() {
  $('.iframe-vid').each(function() {
  this.contentWindow.postMessage('{"event":"command","func":"pauseVideo","args":""}', '*')
  });
}
