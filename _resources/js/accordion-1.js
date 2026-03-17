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
						
						if (href == compareTo && href.indexOf("#") == -1) {
							collapse = false;
							//add open class to parent span a
							$(links).parent('li').parent('ul').parent('li').children('span').children('a').removeClass('closed');
							$(links).parent('li').parent('ul').parent('li').children('span').children('a').addClass('open');
							break;
						}
					};
					if (collapse) {
						$(this).hide();
					}
				});

				//click function
				$("#Accordion").delegate('span', 'click', function(event) {
					var a = $(this).children('a');
					var ul = $(this).next('ul');
					if (ul.is(':visible')) {
						ul.slideUp(250);
						//add closed class to buttons not clicked 
						$(a).removeClass('open'); 
						$(a).addClass('closed'); 
					} else {
						$('#Accordion ul').not(ul).slideUp(500);
						ul.slideDown(250);
						//add open class to this clicked button
						$(a).removeClass('closed');
						$(a).addClass('open'); 
					}
					//add the closed class to a elements not children of this a element clicked
					$('#Accordion li span a').not(a).removeClass('open');
					$('#Accordion li span a').not(a).addClass('closed');
					//disable the normal jump behavior for # in a tag
					event.preventDefault();
				});
	//onload		
	function setActive() {
  	var aObj = document.getElementById('Accordion').getElementsByTagName('a');
  	var i;
  	for(i=0;i<aObj.length;i++) { 
		//add selected to a tags without the # in the url
		if(document.location.href.indexOf(aObj[i].href)>=0 && aObj[i].href.indexOf("#") == -1) { 
      		aObj[i].className='selected';
		}
    }
  }

window.onload = setActive;
});

