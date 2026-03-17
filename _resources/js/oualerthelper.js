$( document ).ready(function() {
	 
	setTimeout(myfunc, 100);
	window.addEventListener("resize", function(event) {
    		myfunc();
  	});
	
});

	function myfunc(){
		
		var x = document.getElementsByClassName("oualerts-is-active");
		var y = document.getElementById("emergencyNotice");
		var oHeight = y.offsetHeight;
		var s = "padding-top: "
		var s2 = "px; position: relative; min-height: 100%; top: 0px;"
		s = s.concat('', oHeight.toString());
		s = s.concat('',s2);
		x[0].setAttribute('style', s);
	}
	
