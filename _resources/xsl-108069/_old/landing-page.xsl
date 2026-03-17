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
	<xsl:import href="accessibility-link-icons.xsl" />

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
		<!-- head include -->
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
		
		<!-- our google key  -->
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />

	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics.inc')"/>
		
</head>
	 
<body class="landing-page">
	
	<!--######## Global Safety Alert ######## -->
	<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
			<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="'/_resources/includes/global-safety-alert.inc'"/>
			</xsl:call-template>
	
<div class="body-wrap">
	<!-- header -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header-3.inc')"/>
<div class="heading">
        <div id="about-header">
            <h2><xsl:value-of select="$Title" disable-output-escaping="yes" /></h2>
        </div>
        <ul class="popular">
            <li><h4>Popular</h4></li>
            <li><a href="#"><i class="fa fa-question-circle"></i> Why Cerritos</a></li>
            <li><a href="#"><i class="fa fa-newspaper-o"></i> Facts At A Glance</a></li>
            <li><a href="/events"><i class="fa fa-calendar"></i> Calendar</a></li>
            <li><a href="/map"><i class="fa fa-map-marker"></i> Campus Map</a></li>
            <li><a href="/abcindex"><i class="fa fa-phone-square"></i> Directory</a></li>
        </ul>
    </div>
	
    <div id="content">    
    <div id="skiptocontent">
		<p class="lead-in">
        <!-- landing intro -->
		<xsl:apply-templates select="document/ouc:div[@label='landingintro']" />
		</p></div>

        <!-- main content -->
		<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
		
    <div id="contentDiv" class="clearfix">
		<!-- other content -->
		<xsl:apply-templates select="document/ouc:div[@label='othercontent']" />
    </div>
		
	<!-- bottom feature -->
    <div id="BottomFeature">
		<div class="feature-content">
			<xsl:apply-templates select="document/ouc:div[@label='bottomfeature']" />
		</div>
    </div>
</div>
	</div>
<!-- footer -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer-2.inc')"/>
	
	<!-- Cerritos direct edit button. 3 params: site, dirname, filename -->
	<div id="lastUpdate">
		<xsl:call-template name="CerritosDirectEditButton">
			<xsl:with-param name="site1" select="$ou:site" />
			<xsl:with-param name="dirname1" select="$ou:dirname" />
			<xsl:with-param name="filename1" select="$ou:filename" />
		</xsl:call-template>
	</div>
</body>
		</html>	 
	</xsl:template>	
	
</xsl:stylesheet>



