<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   "&#160;">
<!ENTITY lsaquo   "&#8249;">
<!ENTITY rsaquo   "&#8250;">
<!ENTITY laquo  "&#171;">
<!ENTITY raquo  "&#187;">
<!ENTITY copy   "&#169;">
]>
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
	
	<html lang="en-us">
	<head>
		<!-- head include -->
		<xsl:copy-of select="ou:includeFile('/_resources/includes/head-2.inc')"/>
		
     	<!-- inserts 'cerritos college' in title if not there -->
     	 <title>
			<xsl:choose>
				<xsl:when test="contains(lower-case($Title), 'cerritos college') = true "><xsl:value-of select="normalize-space($Title)" disable-output-escaping="yes" /></xsl:when>
				<xsl:otherwise><xsl:value-of select="normalize-space($Title)" disable-output-escaping="yes" /> - Cerritos College</xsl:otherwise>
			</xsl:choose>
        </title>
		<meta name="author" content="{$Author}" />
        <meta name="keywords" content="{$Keywords}" />
        <meta name="description" content="{$Description}" />
		<meta name="copyright" content="Cerritos College"/>
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />

		<style>body {margin:15px;}</style>
		
	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics.inc')"/>
	<!-- which additional tracking code to include-->
	<!-- removes the / from the dirname for the choose statement below -->
	<xsl:variable name="firstdirtest" select="substring(concat('/',tokenize($dirname,'/')[2]),2)" />  
	<xsl:choose>
	<xsl:when test="lower-case($firstdirtest) = 'cerritostrainsu'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-cerritostrainsu.inc')"/>
	</xsl:when>
	<xsl:when test="lower-case($firstdirtest) = 'counseling'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-counseling.inc')"/>
	</xsl:when>
	<xsl:when test="lower-case($firstdirtest) = 'music'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-music.inc')"/>
	</xsl:when>
		<xsl:when test="lower-case($firstdirtest) = 'professional-relations'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-prof-rel.inc')"/>
	</xsl:when>
		<xsl:when test="lower-case($firstdirtest) = 'teachertrac'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-teachertrac.inc')"/>
	</xsl:when>
		<xsl:when test="lower-case($firstdirtest) = 'theater'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-theater.inc')"/>
	</xsl:when>
	</xsl:choose>
	
</head>

<body>

	<!-- main content -->
	<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />

</body>
		</html>	 
	</xsl:template>	

</xsl:stylesheet>



