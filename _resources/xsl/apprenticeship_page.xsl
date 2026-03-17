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
	Apprenticeship Page Template by Mackey 2025
-->

<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<xsl:import href="apprenticeship_common.xsl"/>
	
	<xsl:template name="page-content">
		<!-- Get Vars -->
		<xsl:variable name="dirProps" select="document(concat($ou:root,$ou:site,$ou:dirname,'/_props.pcf'))" />
		<xsl:variable name="Title" select="normalize-space(document/ouc:properties[@label='metadata']/title)" />
		
		<!-- Heading if no custom hero -->
		<xsl:if test="ou:pcf-param('custom-hero') = 'disabled'">
			<h2><xsl:value-of select="$Title" disable-output-escaping="yes" /></h2>
		</xsl:if>
		
		<!-- Main Content -->
		<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
	</xsl:template>
</xsl:stylesheet>