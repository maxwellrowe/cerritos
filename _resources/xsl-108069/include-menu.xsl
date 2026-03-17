<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xsl xs ou ouc">
	
<!--###  left nav content  ###-->
	
	<xsl:import href="functions-workshop.xsl" />
	<xsl:import href="ou-variables.xsl" />
	<xsl:import href="ou-forms.xsl" />
	<xsl:import href="template-matches.xsl" />
	<xsl:import href="accessibility-link-icons.xsl" />

	<!-- removes unnecessary whitespace between elements. 	-->
	<xsl:strip-space elements="*" />
	<xsl:output omit-xml-declaration="yes" />
	
	<!-- 10/09/18 Added by Samuel to accomodate left menu mini calendar -->
	<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no" />

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$ou:action != 'pub'">
				<html lang="en">
					<head><title>Page Navigation</title></head>
					<body>
						<xsl:variable name="Title" select="normalize-space(document/ouc:properties[@label='metadata']/title)" />
						<xsl:apply-templates select="document/ouc:div[@label='includemenu']" />
					</body>
				</html>
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="Title" select="normalize-space(document/ouc:properties[@label='metadata']/title)" />
				<xsl:apply-templates select="document/ouc:div[@label='includemenu']" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="attribute()|text()|comment()" mode="#all">
		<xsl:copy />
	</xsl:template>
	<xsl:template match="element()" mode="#all">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="attribute()|node()" mode="#current"/>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>
