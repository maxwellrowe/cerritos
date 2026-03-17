<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xsl xs ou ouc">
	
	<xsl:import href="functions-workshop.xsl" />
	<xsl:import href="ou-variables.xsl" />
	<xsl:import href="template-matches.xsl" />
	<xsl:import href="ou-forms.xsl" />
	<xsl:import href="accessibility-all.xsl" />

	<xsl:param name="ou:navigation" />

	<!-- removes unnecessary whitespace between elements. 	-->
	<xsl:strip-space elements="*" />
	
<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no" /> 

<xsl:template match="/">

	<xsl:variable name="Author" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='author']/@content)" />
	<xsl:variable name="Keywords" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='keywords']/@content)"/>
	<xsl:variable name="Description" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='description']/@content)"/>
	<xsl:variable name="Title" select="normalize-space(document/ouc:properties[@label='metadata']/title)" />

	<html lang="en-us">
	<head>
		<!-- header include -->
		<xsl:copy-of select="ou:includeFile('/_resources/includes/head-2.inc')"/>
		
     	<!-- title -->
     	<title><xsl:value-of select="$Title" disable-output-escaping="yes" /></title>
		<meta name="author" content="{$Author}" />
        <meta name="keywords" content="{$Keywords}" />
        <meta name="description" content="{$Description}" />
		<meta name="copyright" content="Cerritos College"/>
		
		<!-- our google verification key for the home page -->
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />

	<!-- only used for home page -->
	<link rel="stylesheet" href="{{f:80151057}}"/>
	
	<!-- only used for home page -->
    <script src="{{f:80151147}}"></script>

	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics.inc')"/>
		
</head>
	 
<body class="home-page">
	
	<!--######## Emergency Notice ########-->

	<xsl:choose>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value='info-white']">
			<div id="emergencyNotice">
				<div class="WhiteInfo">
        			<div class="right pointer"><img class="close-icon" alt="x" src="{{f:80150862}}"/></div>  
					<i class="fa fa-exclamation-triangle"></i>
            		<xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" />
    			</div>
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value='info-blue']">
			<div id="emergencyNotice">
				<div class="BlueInfo">
        		<div class="right pointer"><img class="close-icon" alt="x" src="{{f:80150862}}"/></div>  
				<i class="fa fa-exclamation-triangle"></i>
            	<xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" />
    			</div>
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value='warning']">
			<div id="emergencyNotice">
				<div class="YellowWarning">
        		<div class="right pointer"><img class="close-icon" alt="x" src="{{f:80150862}}"/></div>  
				<i class="fa fa-exclamation-triangle"></i>
            	<xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" />
    			</div>
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value = 'emergency']">
			<div id="emergencyNotice">
				<div class="RedAlert">
        		<div class="right pointer"><img class="close-icon" alt="x" src="{{f:80150862}}"/></div>  
				<i class="fa fa-exclamation-triangle"></i>
            	<xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" />
    			</div>
			</div>
		</xsl:when>
		<xsl:otherwise>
				
		</xsl:otherwise>
	</xsl:choose>

    <!--######## end Emergency Notice ########--> 
	
<div class="body-wrap">
	<!-- header -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header-2.inc')"/>
	
    <div id="photoDivNew" class="flexslider">
        <ul class="slides">
            <li>
                <img src="{{f:80150896}}" alt="Slide" title="Slide"/>
                <div class="slide-content">
                  <h4>ONE CAMPUS FOR ALL</h4>
                    <h3>INCLUSIVE AND DIVERSE</h3>
                    <a class="button" href="#">REVIEW OUR DIVERSITY PROGRAM</a>
                </div>
            </li>
            <li>
                <img src="{{f:80150701}}" alt="Slide" title="Slide"/>
            </li>
        </ul>
    </div>
	<div id="skiptocontent"></div>
    <div id="contentDiv" class="clearfix">
        <div id="EventsDiv">
			<script>
				$("#EventsDiv").load("/scripts/home-events-2.ashx?feed=http://www.cerritos.edu/calendar/rss/home-news.php&amp;cid=51");
			</script><noscript>The calendar requires javascript enabled.</noscript>
        </div>
        <div id="NewsDiv">
            <script>
				$("#NewsDiv").load("/scripts/home-news-2.ashx?feed=http://www.cerritos.edu/calendar/rss/home-news.php&amp;cid=50");
			</script><noscript>The calendar requires javascript enabled.</noscript>
        </div>
    </div>
	<!-- bottom feature -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/bottomfeature.inc')"/>
    </div>
	<!-- footer -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer-2.inc')"/>
	<div id="lastUpdate">Last Update: <a href="javascript:void(0);" onclick="popupWarningEdit('http://oucampus.cerritos.edu/10?skin=oucampus&amp;account=2017&amp;site=www-cerritos-edu&amp;action=de&amp;path={concat($ou:dirname,'/',ou:replaceFileExtension($ou:filename,'pcf'))}');"><xsl:value-of select="ou:dateFromDateTime($ou:modified,'/')" /></a></div>
</body>
		</html>	 
	</xsl:template>	

</xsl:stylesheet>



