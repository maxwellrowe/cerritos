// JavaScript Document
$(document).ready( function() {
				
				// initialize accordion
				$('#Accordion ul').each( function() {
					var currentURI = window.location.href;
					var links = $('a', this);
					var collapse = true;
					for (var i = 0; i < links.size(); i++) {
						var elem = links.eq(i);
						var href = elem.attr('href');
						var hrefLength = href.length;
						var compareTo = currentURI.substr(-1*hrefLength);
						
						if (href == compareTo) {
							collapse = false;
							break;
						}
					};
					if (collapse) {
						$(this).hide();
					}
				});
				
				// on click, show this element and hide all others
				$('#Accordion > li').click( function() {
					var me = $(this).children('ul');
					$('#Accordion ul').not(me).slideUp();
					me.slideDown();
				});
				
				
			});
			
			function setActive() {
  aObj = document.getElementById('Accordion').getElementsByTagName('a');
  for(i=0;i<aObj.length;i++) { 
    if(document.location.href.indexOf(aObj[i].href)>=0) {
      aObj[i].className='selected';
    }
  }
  
}
window.onload = setActive;
