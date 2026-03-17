<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY amp   "&#38;">
<!ENTITY copy   "&#169;">
<!ENTITY gt   "&#62;">
<!ENTITY lt   "&#60;">
<!ENTITY nbsp   "&#160;">
]>
<xsl:stylesheet version="3.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
xmlns="http://www.w3.org/1999/xhtml"
exclude-result-prefixes="xsl xs ou ouc">
	
	<!-- System Params - don't edit -->
	<xsl:param name="ou:action"/>
	<xsl:param name="ou:root"/>
	<xsl:param name="ou:site"/>
	<xsl:param name="ou:path"/>
	<xsl:param name="ou:dirname"/>
	<xsl:param name="ou:filename"/>
	<xsl:param name="ou:username"/>
	<xsl:param name="ou:lastname"/>
	<xsl:param name="ou:firstname"/>
	<xsl:param name="ou:email"/>
	<xsl:param name="ou:httproot"/>
	<xsl:param name="ou:ftproot"/>
	<xsl:param name="ou:ftphome"/>
	<xsl:param name="ou:ftpdir"/>
	<xsl:param name="ou:created" as="xs:dateTime"/>
	<xsl:param name="ou:modified" as="xs:dateTime"/>
	<xsl:param name="ou:feed"/>
	
	<!-- Implementation Specific Variables -->
	<xsl:param name="bodyClass" />
	<!-- for various concatenation purposes -->
	<xsl:param name="dirname" select="if(string-length($ou:dirname) = 1) then $ou:dirname else concat($ou:dirname,'/')" />
	<xsl:param name="domain" select="substring($ou:httproot,1,string-length($ou:httproot)-1)" /> 				
	
	
	<xsl:variable name="cell" select="if($ou:action = 'pub') then 'th' else 'td'"/>
	
	<xsl:template name="expander">
		<xsl:element name="{$cell}">
			<xsl:attribute name="class" select="'expander'"/>
		</xsl:element>
	</xsl:template>
	
	
	<!--
		OU GET TEXTUAL CONTENT
		Use when checking for any content (prep for an "if empty" check)
		Gets string representation of any node and its subnodes, replaces &nbsp; with space, and trims all whitespace
	-->
	<xsl:function name="ou:textual-content">
		<xsl:param name="element"/>
		<xsl:value-of select="normalize-space(replace(string($element), '&nbsp;', ' '))" />
	</xsl:function>
	
	<!-- Functions: the following functions are used to include the CSS or include files relevant to the pages. -->
	<xsl:function name="ou:includeCSS">
		<xsl:param name="fullpath" />
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:copy-of select="ou:ssi($fullpath)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="unparsed-text(concat($ou:root,$ou:site,$fullpath))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ou:includeCustomCSS">
		<xsl:param name="fullpath" />
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:copy-of select="ou:ssi($fullpath)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="unparsed-text(concat(substring($ou:httproot, 1, string-length($ou:httproot) - 1),$fullpath))" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ou:includeFile">
		<xsl:param name="fullpath" />
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:copy-of select="ou:ssi($fullpath)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment> ouc:div label="<xsl:value-of select="$fullpath"/>" path="<xsl:value-of select="$fullpath"/>" </xsl:comment> <xsl:comment> /ouc:div </xsl:comment> 
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ou:ssi">
		<xsl:param name="fullpath"/>
		<xsl:processing-instruction name="php"> include($_SERVER['DOCUMENT_ROOT'] . "<xsl:value-of select="$fullpath" />"); </xsl:processing-instruction>
	</xsl:function>
	
	<!-- Generic template matches (for parsing and copying content) -->
	<!-- The following template matches all items except processing instructions, copies them, then processes any children. -->
	<xsl:template match="attribute()|text()|comment()"><xsl:copy /></xsl:template>
	<xsl:template match="element()"><xsl:element name="{name()}"><xsl:apply-templates select="attribute()|node()"/></xsl:element></xsl:template>
	<xsl:template match="processing-instruction()"><xsl:processing-instruction name="php"><xsl:value-of select="." disable-output-escaping="yes" /></xsl:processing-instruction></xsl:template>
	
	<!-- OUC Dynamic 3rd Level Tagging -->
	<xsl:template match="ouc:div">
		<xsl:copy>
			<xsl:attribute name="wysiwyg-class"><xsl:value-of select="$bodyClass" /></xsl:attribute>
			<xsl:apply-templates select="attribute()|node()" />
		</xsl:copy>
	</xsl:template>
	<!-- To skip over any ouc tags while not in edit mode -->
	<xsl:template match="ouc:*[$ou:action !='edt']"><xsl:apply-templates /></xsl:template>
	
	<!-- Visual warning for broken dependencies tags -->
	<xsl:template match="a[contains(@href,'*** Broken')]"><a href="{@href}" style="color: red;"><xsl:value-of select="."/></a> <span style="color: red;">[BROKEN LINK]</span></xsl:template>
	
	<xsl:template match="processing-instruction('pcf-stylesheet')" /><!-- For PCF-stylesheets -->
</xsl:stylesheet>
