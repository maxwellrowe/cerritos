<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xsl xs ou ouc">
	
	<xsl:import href="_shared/variables.xsl" />
    <xsl:import href="_shared/functions.xsl" />
	
	<xsl:import href="template-matches.xsl" />
	<xsl:import href="functions-workshop.xsl" />
	<xsl:import href="ou-variables.xsl" />
	<xsl:import href="accessibility-link-icons.xsl" />
	<xsl:import href="ou-forms.xsl" />
	
	

	<xsl:import href="_shared/galleries.xsl" />
	<xsl:import href="_shared/galleries-fade.xsl" />
	<xsl:import href="_shared/forms.xsl" />
	
	<xsl:param name="ou:navigation" />

	<!-- removes unnecessary whitespace between elements. 	-->
	<xsl:strip-space elements="*" />
	
<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no" /> 

<xsl:template match="/">

	<xsl:variable name="Author" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='author']/@content)" />
	<xsl:variable name="Keywords" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='keywords']/@content)"/>
	<xsl:variable name="Description" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='description']/@content)"/>
	<xsl:variable name="Robots" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='robots']/@content)"/>
	<xsl:variable name="Title" select="normalize-space(document/ouc:properties[@label='metadata']/title)" />
	<xsl:variable name="PageCSS" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='PageCSS']/text())" />
	<xsl:variable name="Popular" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='Popular']/text())" />
	
	<html lang="en-us">
	<head>
		<!-- head include -->
		<xsl:copy-of select="ou:includeFile('/_resources/includes/head.inc')"/>
		
     	<!-- title -->
     	<title><xsl:value-of select="$Title" disable-output-escaping="yes" /><!-- - Cerritos College--></title>
		<meta name="author" content="{$Author}" />
        <meta name="keywords" content="{$Keywords}" />
        <meta name="description" content="{$Description}" />
		<meta name="robots" content="{$Robots}" />
		<meta name="copyright" content="Cerritos College"/>
		<meta property="og:site_name" content="Cerritos College" />
		<meta property="og:title" content="{$Title}" />
		<meta property="og:description" content="{$Description}" />
		<meta property="og:type" content="website" />
		<meta property="og:url" content="https://www.cerritos.edu/" />
		<meta property="og:image" content="https://www.cerritos.edu/_resources/images/common/cerritos-college-logo.svg" />
		<style type="text/css"><xsl:text>&#xA;</xsl:text>
			<xsl:value-of select="$PageCSS" disable-output-escaping="yes"  /><xsl:text>&#xA;</xsl:text>
		</style><xsl:text>&#xA;</xsl:text>
		
		<!-- our google key  -->
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />

	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-tag-manager-body-script.inc')"/>

<xsl:call-template name="gallery-headcode">
                    <xsl:with-param name="domain" />
                </xsl:call-template>
		
		<xsl:call-template name="form-headcode" />
		
		<!-- reCAPTCHA version 2 -->
		<script src='https://www.google.com/recaptcha/api.js'></script>
		<xsl:if test="$ou:action = 'pub'">
			<xsl:processing-instruction name="php" expand-text="no">
				if (file_exists($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.css.html')) {
				include($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.css.html');
				}
				?</xsl:processing-instruction>
		</xsl:if>
		
		<link rel="stylesheet" href="{{f:80147702}}" type="text/css" />
     	<link rel="stylesheet" href="{{f:80147701}}" type="text/css" />
</head>
	 
<body class="landing-page">
	<header role="banner">
	<!--######## Global Safety Alert ######## -->
	<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
			<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="'/_resources/includes/global-safety-alert.inc'"/>
			</xsl:call-template>
	
	<!-- 8/31/21 Samuel Chavez: Add secondary alert for extra messages beyond COVID stand-in message -->
			<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="'/_resources/includes/global-safety-alert-2.inc'"/>
			</xsl:call-template>
	

	<!-- header -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header.inc')"/>
<div class="heading" role="region">
        <div id="about-header">
            <h2><xsl:value-of select="$Title" disable-output-escaping="yes" /></h2>
        </div>
	
		<!-- popularlinks -->
	<ul class="popular">
		<xsl:value-of select="$Popular" disable-output-escaping="yes" />
	</ul>
    </div>
	</header>
	<div class="body-wrap">
    <div id="content" role="main">    
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
		
	<!-- bottom feature 
    <div id="BottomFeature">
		<div class="feature-content">
			<xsl:apply-templates select="document/ouc:div[@label='bottomfeature']" />
		</div>
    </div>-->
</div>
	</div>
<!-- footer -->
	<div role="contentinfo">
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer.inc')"/>
	
	<!-- Cerritos direct edit button. 3 params: site, dirname, filename -->
	<div id="lastUpdate">
		<div class="container">
			<xsl:copy-of select="ou:includeFile('/_resources/includes/footer-bottom.inc')"/>
		<xsl:call-template name="CerritosDirectEditButton">
			<xsl:with-param name="site1" select="$ou:site" />
			<xsl:with-param name="dirname1" select="$ou:dirname" />
			<xsl:with-param name="filename1" select="$ou:filename" />
		</xsl:call-template>
		</div>
	</div>
	 	<script src="{{f:80151160}}"></script>
	<noscript>Your browser does not support JavaScript!</noscript>
	<script src="{{f:80151167}}"></script>
	<noscript>Your browser does not support JavaScript!</noscript>
	
	<xsl:call-template name="gallery-footcode">
                    <xsl:with-param name="domain" />
                </xsl:call-template>
                
    <xsl:call-template name="form-footcode" />
</div>
	<xsl:if test="$ou:action = 'pub'">
 	<xsl:processing-instruction name="php" expand-text="no">
 		if (file_exists($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.alerts.html')) {
 			include($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.alerts.html');
 		}
 	?</xsl:processing-instruction>
 </xsl:if>
</body>
		</html>	 
	</xsl:template>	
	
</xsl:stylesheet>



