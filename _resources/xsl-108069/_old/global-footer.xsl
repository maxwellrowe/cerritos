<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xsl xs ou ouc">
	
	<!-- footer for all templates -->
	
	<!-- 	The following template matches all elements, rewrites them in the current namespace, then processes any attributes and children it may have. -->
	<xsl:template name="globalfooter">
		<div id="social-wrap">
<div id="social" class="clearfix">
    <div class="col-md-4">
        <h3>Stay Connected</h3>
    </div>
    <div class="col-md-8">
        <div class="social-buttons">
            <section class="mobile-row">
                <a class="social inverse" href="https://www.facebook.com/cerritoscollege/" target="_blank"><i class="fa fa-facebook"></i></a>
                <a class="social inverse" href="https://www.instagram.com" target="_blank"><i class="fa fa-instagram"></i></a>
                <a class="social inverse" href="https://twitter.com/cerritoscollege" target="_blank"><i class="fa fa-twitter"></i></a>
                <a class="social inverse" href="https://www.snapchat.com" target="_blank"><i class="fa fa-snapchat-ghost"></i></a>
            </section>
            <section class="mobile-row">
                <a class="social inverse" href="https://plus.google.com" target="_blank"><i class="fa fa-google-plus"></i></a>
                <a class="social inverse" href="https://www.youtube.com/channel/UCmQYFzgOkYGPAAfHuNe7mOg" target="_blank"><i class="fa fa-youtube-play"></i></a>
                <div class="sharethis-inline-share-buttons"></div>
            </section>
        </div>
        <div class="click-throughs">
            <a class="button inverse" href="http://social.pomona.edu" rel="external" target="_blank">Visit Our Social Media Hub</a>
            <div class="sharethis-inline-share-buttons"></div>
			        </div>
    </div>
</div>
</div>
<div id="footer-wrap">
<div id="footer" class="clearfix">
    <div class="col-md-4 info">
        <h5>CERRITOS COLLEGE</h5>
        <p>
            11110 Alondra Blvd.<br/>
            Norwalk, California 90650<br/>
            [<a href ="/map">Campus map</a>]
        </p>
        <p>Phone: <a href="tel:+15628602451">(562) 860-2451</a><br/>
            Emergency: <a href="tel:+15624023674">(562) 402-3674</a>
        </p>
    </div>
    <div class="col-md-8">
        <div class="col-md-4">
            <a href="/admissions-and-records/catalogue-schedule/">Schedule of Classes</a>
            <a href="/admissions-and-records/catalogue-schedule/">Class Catalog</a>
            <a href="https://ep-secure.cerritos.edu/psp/por91prd/EMPLOYEE/EMPL/h/?tab=PAPP_GUEST" rel="external" class="inverse">MyCerritos</a>
            <a href="https://cerritos.instructure.com/login/canvas" rel="external" class="inverse">Canvas</a>
            <a href="https://orgsync.com/login/cerritos-college" rel="external" class="inverse">OrgSync</a>
        </div>
        <div class="col-md-4">
            <a href="{{d:9121100}}">Campus Police <i class="fa fa-exclamation-triangle"></i></a>
            <a href="/about/accreditation/">Accreditation</a>
            <a href="{{d:9127996}}">Disabled Students <i class="fa fa-wheelchair"></i></a>
            <div class="external-links">
                <a href="https://get.adobe.com/reader/" rel="external" class="inverse">Download Adobe Reader</a>
                <a href="http://www.microsoft.com/en-us/download/details.aspx?id=4" rel="external" class="inverse">Download MS Word Viewer</a>
                <a href="http://www.microsoft.com/en-us/download/details.aspx?id=10" rel="external" class="inverse">Download MS Excel Viewer</a>
                <a href="http://www.microsoft.com/en-us/download/details.aspx?id=13" rel="external" class="inverse">Download MS PowerPoint Viewer</a>
            </div>
        </div>
        <div class="col-md-4">
            <a href="{{d:9131091}}">Send Website Feedback</a>
            <a href="{{f:80275967}}">Disclaimer</a>
				<!-- last update link -->	
	Last Update: <a href="javascript:void(0);" onclick="popupWarningEdit('http://oucampus.cerritos.edu/10?skin=oucampus&amp;account=2017&amp;site=www-cerritos-edu&amp;action=de&amp;path={concat($ou:dirname,'/',ou:replaceFileExtension($ou:filename,'pcf'))}');"><xsl:value-of select="ou:dateFromDateTime($ou:modified,'/')" /></a>
            TRANSLATE THIS PAGE
            <div id="google_translate_element"></div><script type="text/javascript">
                function googleTranslateElementInit() {
                    new google.translate.TranslateElement({pageLanguage: 'en', layout: google.translate.TranslateElement.InlineLayout.SIMPLE, autoDisplay: false}, 'google_translate_element');
                }
            </script><script type="text/javascript" src="//translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
        </div>
    </div>

</div>
</div>
<a class="back-to-top" href="#"><img alt="Back to Top" title="Back to Top" src="{{f:80150918}}"/></a>

	</xsl:template>

</xsl:stylesheet>
