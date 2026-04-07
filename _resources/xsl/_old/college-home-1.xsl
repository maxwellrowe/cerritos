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
	<xsl:import href="link-icons.xsl" />
	<xsl:import href="global-footer.xsl" />

	<xsl:param name="ou:navigation" />

	<!-- removes unnecessary whitespace between elements. 	-->
	<xsl:strip-space elements="*" />
	
<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no" /> 

<xsl:template match="/">

	<xsl:variable name="Author" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='author']/@content)" />
	<xsl:variable name="Keywords" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='keywords']/@content)"/>
	<xsl:variable name="Description" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='description']/@content)"/>
	<xsl:variable name="Title" select="normalize-space(document/ouc:properties[@label='metadata']/title)" />
	<xsl:variable name="PageCSS" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='PageCSS']/text())" />

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
		<style type="text/css">
			<xsl:value-of select="$PageCSS" disable-output-escaping="yes"  />
		</style>
		
		<!-- our google verification key for the home page -->
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />

	<!-- only used for home page -->
	<link rel="stylesheet" href="{{f:80151057}}"/>
	
	<!-- only used for home page -->
    <script src="{{f:80151147}}"></script>

	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-tag-manager-body-script.inc')"/>


		
</head>
	 
<body class="home-page">
	
	<!--######## Global Safety Alert ########
	<xsl:copy-of select="ou:includeFile('/_resources/includes/global-safety-alert.inc')"/>-->
	<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
			<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="'/_resources/includes/global-safety-alert.inc'"/>
			</xsl:call-template>
	
<div class="body-wrap">
	<!-- header -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header.inc')"/>
	
    <div id="photoDivNew" class="flexslider">
        <ul class="slides">
            <!-- flexslider slides -->
			<xsl:apply-templates select="document/ouc:div[@label='homesliders']" />
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
	<div id="BottomFeature">
		<xsl:apply-templates select="document/ouc:div[@label='bottomfeature']" />
	</div>
    </div>
<!-- footer -->
	<xsl:call-template name="globalfooter"/>
</body>
		</html>	 
	</xsl:template>	

	<!-- remove img height and width attributes and add photo class -->
	<xsl:template match="img/@width|img/@height">
		<xsl:attribute name="class">photo</xsl:attribute>
	</xsl:template>

	
</xsl:stylesheet>



