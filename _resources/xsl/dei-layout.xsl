<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xsl xs ou ouc">
	
	<xsl:import href="functions-workshop.xsl" />
	<xsl:import href="ou-variables.xsl" />
	<xsl:import href="ou-forms.xsl" />
	<xsl:import href="accessibility-link-icons.xsl" />
	<xsl:import href="template-matches.xsl" />

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
	<xsl:variable name="WebCss" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='WebCss']/text())" />
	<html lang="en-us">
	<head>
		<!-- head include -->
		<xsl:copy-of select="ou:includeFile('/_resources/includes/head-6.inc')"/>
		
     	<!-- title -->
     	<title><xsl:value-of select="$Title" disable-output-escaping="yes" /></title>
		<meta name="author" content="{$Author}" />
        <meta name="keywords" content="{$Keywords}" />
        <meta name="description" content="{$Description}" />
		<meta name="robots" content="{$Robots}" />
		<meta name="copyright" content="Cerritos College"/>
		<style type="text/css"><xsl:text>&#xA;</xsl:text>
			<xsl:value-of select="$PageCSS" disable-output-escaping="yes"  /><xsl:text>&#xA;</xsl:text>
		</style><xsl:text>&#xA;</xsl:text>
		
		<!-- dept style sheet -->
				<xsl:if test="string-length($WebCss) > 0 ">
					<xsl:choose>
						<!-- if it's a full path -->
						<xsl:when test="contains($WebCss, '/')">
							<link href="{$WebCss}" rel="stylesheet" type="text/css" media="all" />
						</xsl:when>
						<!-- if it's just a file name -->
						<xsl:otherwise>
							<link href="{concat($firstdir,'/_includes/assets/',$WebCss)}" rel="stylesheet" type="text/css" media="all" /><xsl:text>&#xA;</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:if>
		
		<!-- our google key  -->
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />

	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-tag-manager-body-script.inc')"/>


		
		
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
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header-3.inc')"/>
		</header>
	<main role="main">
<div class="heading">	
	
<!-- home top panel -->
	<xsl:apply-templates select="document/ouc:div[@label='toppanel']" />
    </div>
	<div class="container-fluid">
    <div id="content" class="row">    
    <div id="skiptocontent" class="col-xs-12">
	</div>

        <!-- main content -->
		<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
		


</div>
	</div>
		
	</main>
	<footer role="contentinfo">
<!-- footer -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer-3.inc')"/>
	
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
	</footer>
</body>
		</html>	 
	</xsl:template>	
	
</xsl:stylesheet>



