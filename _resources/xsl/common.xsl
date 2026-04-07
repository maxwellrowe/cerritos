<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY amp   "&#38;">
<!ENTITY copy   "&#169;">
<!ENTITY gt   "&#62;">
<!ENTITY hellip "&#8230;">
<!ENTITY laquo  "&#171;">
<!ENTITY lsaquo   "&#8249;">
<!ENTITY lsquo   "&#8216;">
<!ENTITY lt   "&#60;">
<!ENTITY nbsp   "&#160;">
<!ENTITY quot   "&#34;">
<!ENTITY raquo  "&#187;">
<!ENTITY rsaquo   "&#8250;">
<!ENTITY rsquo   "&#8217;">
]>

<!--
	Common XSL
	
	Common XSL
	Imported by all page type-specific stylesheets, and imports utility stylesheets.
	Defines html, xsl templates and functions used globally throughout the implementation
	Defines outer html structure and common include content.

	Created Oct 2025
-->

<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xsl xs ou ouc">
	
	<xsl:import href="_shared/variables.xsl" />
    <xsl:import href="_shared/functions.xsl" />
	<xsl:import href="functions-workshop.xsl" />
	<xsl:import href="ou-variables.xsl" />
	<xsl:import href="ou-forms.xsl" />
	<xsl:import href="template-matches.xsl" />
	<xsl:import href="accessibility-link-icons.xsl" />
	<xsl:import href="_shared/galleries.xsl" />
	<xsl:import href="_shared/galleries-fade.xsl" />
	<!--<xsl:import href="_shared/galleries-custom-buttons.xsl" />-->
    <xsl:import href="_shared/forms.xsl" />
	<xsl:import href="_shared/components.xsl" />
	<xsl:import href="_shared/mailto.xsl" />
	
	<!-- Breadcrumbs -->
	<xsl:import href="_shared/breadcrumbs.xsl" />
	
	<xsl:param name="ou:navigation" />

	<!-- removes unnecessary whitespace between elements. 	-->
	<xsl:strip-space elements="*" />

	<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no" />
	
	<!-- Global Variables -->
	<xsl:variable name="Author" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='author']/@content)" />
	<xsl:variable name="Keywords" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='keywords']/@content)"/>
	<xsl:variable name="Description" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='description']/@content)"/>
	<xsl:variable name="Robots" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='robots']/@content)"/>
	<xsl:variable name="Title" select="normalize-space(document/ouc:properties[@label='metadata']/title)" />
	<xsl:variable name="LeftNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='LeftNav']/text())" />
	<xsl:variable name="DeptInfo" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='DeptInfo']/text())" />
	<xsl:variable name="TrackingInclude" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='TrackingInclude']/text())" />
	<xsl:variable name="WebCss" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='WebCss']/text())" />
	
	<!-- Set Body Class Param - this can be overwritten in "page-content" template -->
	<xsl:param name="body-classes" as="xs:string" select="''"/>
	
	<xsl:template match="/">
		
		<html lang="en-us">
			<head>				
				<!-- head include -->
				<xsl:copy-of select="ou:includeFile('/_resources/includes/head.inc')"/><xsl:text>&#xA;</xsl:text>

				<!-- inserts 'cerritos college' in title if not there -->
				<title>
					<xsl:choose>
						<xsl:when test="contains(lower-case($Title), 'cerritos college') = true "><xsl:value-of select="normalize-space($Title)" disable-output-escaping="yes" /></xsl:when>
						<xsl:otherwise><xsl:value-of select="normalize-space($Title)" disable-output-escaping="yes" /> - Cerritos College</xsl:otherwise>
					</xsl:choose>
				</title>
				
				<!-- META -->
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
				<link rel="canonical" href="{concat($domain,$ou:dirname,'/',$ou:filename)}" />
				<meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />
				
				<!-- Structured Data -->
				<script type="application/ld+json">
				<xsl:text>{
				  "@context":"https://schema.org",
				  "@type":"CollegeOrUniversity",
				  "name":"Cerritos College",
				  "url":"https://www.cerritos.edu/",
				  "logo":"https://www.cerritos.edu/_resources/images/common/cerritos-college-logo.svg",
				  "sameAs":[
					"https://www.facebook.com/cerritoscollege",
					"https://twitter.com/cerritoscollege",
					"https://www.linkedin.com/school/cerritos-college/"
				  ],
				  "address":{
					"@type":"PostalAddress",
					"streetAddress":"11110 Alondra Blvd",
					"addressLocality":"Norwalk",
					"addressRegion":"CA",
					"postalCode":"90650",
					"addressCountry":"US"
				  },
				  "contactPoint":{
					"@type":"ContactPoint",
					"telephone":"+1-562-860-2451",
					"contactType":"Customer Service",
					"areaServed":"US"
				  }
				}</xsl:text>
				</script>

				<!-- WebPage: pulls from your XSL variables -->
				<script type="application/ld+json">
				<xsl:text>{ "@context":"https://schema.org","@type":"WebPage"</xsl:text>

				<!-- name -->
				<xsl:if test="string-length($Title) &gt; 0">
				  <xsl:text>,"name":"</xsl:text><xsl:value-of select="$Title"/><xsl:text>"</xsl:text>
				</xsl:if>

				<!-- description -->
				<xsl:if test="string-length($Description) &gt; 0">
				  <xsl:text>,"description":"</xsl:text><xsl:value-of select="$Description"/><xsl:text>"</xsl:text>
				</xsl:if>

				<!-- author (if you use it) -->
				<xsl:if test="string-length($Author) &gt; 0">
				  <xsl:text>,"author":{"@type":"Person","name":"</xsl:text><xsl:value-of select="$Author"/><xsl:text>"}</xsl:text>
				</xsl:if>

				<!-- keywords -->
				<xsl:if test="string-length($Keywords) &gt; 0">
				  <xsl:text>,"keywords":"</xsl:text><xsl:value-of select="$Keywords"/><xsl:text>"</xsl:text>
				</xsl:if>

				<!-- robots (as about page indexing signals; optional) -->
				<xsl:if test="string-length($Robots) &gt; 0">
				  <xsl:text>,"isPartOf":{"@type":"WebSite","name":"Cerritos College"}</xsl:text>
				</xsl:if>

				<!-- canonical URL (use your own variable if you have it; static home is safe fallback) -->
				<xsl:text>,"url":"https://www.cerritos.edu/"}</xsl:text>
				</script>
				<!-- END Structured Data-->
				
				<!-- Dept style sheet -->
                <xsl:if test="string-length($WebCss) > 0 ">
                    <xsl:choose>
                        <!-- if it's a full path -->
                        <xsl:when test="contains($WebCss, '/')">
                            <link href="{$WebCss}" rel="stylesheet" type="text/css" media="all" /><xsl:text>&#xA;</xsl:text>
                        </xsl:when>
                        <!-- if it's just a file name -->
                        <xsl:otherwise>
                            <link href="{concat($firstdir,'/_includes/assets/',$WebCss)}" rel="stylesheet" type="text/css" media="all" /><xsl:text>&#xA;</xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>

				<!-- _props.pcf stylesheet -->
				<xsl:if test="doc-available(concat($ou:root,$ou:site,$ou:dirname,'/_props.pcf'))">
					<xsl:variable name="dirProps" select="document(concat($ou:root,$ou:site,$ou:dirname,'/_props.pcf'))" />
					<xsl:variable name="custom_css" select="$dirProps//parameter[@name='section-css-dir-file']" />
					<xsl:if test="$custom_css != ''">
						<link href="{$custom_css}" rel="stylesheet" type="text/css" media="all" />
					</xsl:if>
				</xsl:if>

				<!-- Special tracking code if any for this page -->
				<xsl:if test="string-length($TrackingInclude) > 0 ">  		  
					<!--<xsl:copy-of select="ou:includeFile($TrackingInclude)"/>-->
					<xsl:call-template name="unparsed-include-file">
						<xsl:with-param name="path" select="ou:includeFile($TrackingInclude)"/>
					</xsl:call-template>
				</xsl:if>
				
				<!-- reCAPTCHA version 2 -->
				<script src='https://www.google.com/recaptcha/api.js'></script>
				<xsl:if test="$ou:action = 'pub'">
					<xsl:processing-instruction name="php">
						if (file_exists($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.css.html')) {
						include($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.css.html');
						}
						?</xsl:processing-instruction>
				</xsl:if>
				
				<link rel="stylesheet" href="{{f:80147691}}" media="screen" />
      <link rel="stylesheet" type="text/css" href="{{f:80147689}}" media="screen" />
      <link rel="stylesheet" type="text/css" href="{{f:80147690}}" media="screen" />
				
				<link rel="stylesheet" href="{{f:80147702}}" type="text/css" />
     			<link rel="stylesheet" href="{{f:80147701}}" type="text/css" />
				
				<!-- Optional Add to head of page -->
				<xsl:call-template name="page-head" />
				
			</head>
			
			<!--Body ID variable NEW -->
			<xsl:variable name="body_id">
				<xsl:choose>
					<xsl:when test="ou:pcf-param('body_id') != ''">
						<xsl:value-of select="ou:pcf-param('body_id')" />
					</xsl:when>
					<xsl:otherwise></xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
				
			<body class="{$body-classes}" id="{$body_id}">
				
				<!-- Cerritos main google tracking code -->
				<xsl:comment> Cerritos main google tracking code </xsl:comment><xsl:text>&#xA;</xsl:text>
				<xsl:copy-of select="ou:includeFile('/_resources/includes/google-tag-manager-body-script.inc')"/>
				
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
					
					<!-- Hero NEW -->
					<xsl:if test="ou:pcf-param('custom-hero') = 'enabled'">
						<xsl:apply-templates select="document/ouc:div[@label='page_hero']" />
					</xsl:if>

					<!-- Optional Add To Header-->
					<xsl:call-template name="page-header" />
					
				</header>
				
				<!-- Call Page -->
				<xsl:call-template name="page-content"/><!-- Each page is unique -->
				
				<footer>
					<!-- footer -->
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
				</footer>
                
				<!-- Footer Scripts -->
				<xsl:call-template name="footer-scripts" />
				
			</body>
		</html>	 
    </xsl:template>
	
	
	<!-- START Footer Scripts Template -->
	<xsl:template name="footer-scripts">
		<script src="{{f:80151160}}"></script>
		<noscript>Your browser does not support JavaScript!</noscript>
		<script src="{{f:80151167}}"></script>
		<noscript>Your browser does not support JavaScript!</noscript>
		<xsl:call-template name="gallery-footcode">
			<xsl:with-param name="domain" />
		</xsl:call-template>

		<xsl:call-template name="form-footcode" />

		<!-- _props.pcf javascript file -->
		<xsl:if test="doc-available(concat($ou:root,$ou:site,$ou:dirname,'/_props.pcf'))">
			<xsl:variable name="dirProps" select="document(concat($ou:root,$ou:site,$ou:dirname,'/_props.pcf'))" />
			<xsl:variable name="custom_js" select="$dirProps//parameter[@name='section-js-dir-file']" />
			<xsl:if test="$custom_js != ''">
				<script src="{$custom_js}" defer="true"></script>
			</xsl:if>
		</xsl:if>

		<xsl:if test="$ou:action = 'pub'">
			<xsl:processing-instruction name="php">
				if (file_exists($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.alerts.html')) {
				include($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.alerts.html');
				}
				?</xsl:processing-instruction>
		</xsl:if>
	</xsl:template>
	<!-- END Footer Scripts Template -->
	
	<!-- in case not defined in page type xsl, leave for debugging purposes -->
	<xsl:template name="page-content"><p>No template defined.</p></xsl:template>
	<xsl:template name="page-head" />
	<xsl:template name="page-header"/>
	<xsl:template name="template-headcode"/>
	<xsl:template name="template-footcode"/>
    
</xsl:stylesheet>