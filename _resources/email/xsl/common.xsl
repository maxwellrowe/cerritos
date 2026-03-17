<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xsl xs ou ouc">
	
	<xsl:import href="dependencies.xsl"/>
	<xsl:import href="footer.xsl" />
	<xsl:include href="snippets.xsl"/>
	
	<xsl:param name="bodyClass" select="/document/ouc:properties/parameter[@name='theme']/option[@selected='true']/@value" />
	
	<xsl:output method="xhtml" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" include-content-type="no"
		doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd" />
	
	<xsl:template match="/document"><!-- begin html -->
		<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">
			<head>
				<xsl:call-template name="headcode"/> <!-- common headcode -->
				<xsl:call-template name="additional-headcode"/> <!-- each pagetype may have a version of this template -->
				<xsl:apply-templates select="headcode/node()"/>
				<xsl:call-template name="editor-plugins-css"/>
				<title><xsl:value-of select="ouc:properties[@label='metadata']/title"/></title>
				<!-- copy meta tags from pcf, but only those with content -->
				<xsl:apply-templates select="ouc:properties[@label='metadata']/meta[string-length(@content)>0]"/>
				<!--<xsl:if test="$ou:action = 'edt'">
					<style type="text/css">body table.container {width:80% !important;}</style>
				</xsl:if>-->
			</head>
			<body>
				<table class="body">
					<tr>
						<xsl:element name="{$cell}">
							<xsl:attribute name="class" select="'float-center'"/>
							<xsl:attribute name="align" select="'center'"/>
							<xsl:attribute name="valign" select="'top'"/>
							<center>
								<xsl:call-template name="spacer">
									<xsl:with-param name="height" select="5"/>
								</xsl:call-template>
								<xsl:call-template name="header"/>
								<xsl:call-template name="page-content"/> <!-- each pagetype has a unique version of this template -->
								<xsl:call-template name="footer"/>
							</center>
						</xsl:element>
					</tr>
				</table>
				<!--Necescary based on the site, otherwise the direct edit button will show up-->
				<div id="hidden" style='display:none;font-size:0px;'><xsl:comment> com.omniupdate.ob </xsl:comment><xsl:comment> /com.omniupdate.ob </xsl:comment></div>
				<xsl:call-template name="editor-plugins-js"/>
			</body>
		</html>
		<!-- end html -->
	</xsl:template>
	
	<xsl:template name="headcode">
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<meta name="viewport" content="width=device-width"/>
		
		<style type="text/css">
			<!-- Include the default INK CSS files (and add any additional base theming includes.) -->
			<xsl:copy-of select="ou:includeCSS('/_resources/email/css/core.css')" /><!--Default Email Theme CSS-->
			<xsl:copy-of select="ou:includeCSS('/_resources/email/css/button.css')" /><!-- OU Button Color CSS-->
			<xsl:copy-of select="ou:includeCSS('/_resources/email/css/panels.css')" /><!-- OU Modified CSS for panel styles -->
			
			<!-- Selecting the custom color theme-->
			<xsl:variable name="color-theme" select="ouc:properties/parameter[@name='color-theme']/option[@selected='true']/@value"/>
			<xsl:choose>
				<xsl:when test="starts-with($color-theme, 'theme')">
					<xsl:copy-of select="ou:includeCustomCSS(concat('/_resources/email/includes/_color-config-',ouc:properties/parameter[@name='color-theme']/option[@selected='true']/@value,'.css'))"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="ou:includeCSS(concat('/_resources/email/css/themes/',ouc:properties/parameter[@name='color-theme']/option[@selected='true']/@value,'-theme.css'))"/>
				</xsl:otherwise>
			</xsl:choose>
		</style>
	
		
	</xsl:template>
	
	<xsl:template name="header">
		<!--View email in browser page property-->
		<xsl:if test="ouc:properties/parameter[@name = 'browser-link']/option[@selected='true']/@value = 'show'">
			<table class="browser-container">
				<tr>
					<xsl:element name="{$cell}">
						<table class="row browser-link">
							<tr>
								<xsl:element name="{$cell}">
									<xsl:attribute name="class" select="'small-12 large-12 columns first last'"/>
									<xsl:choose>
										<xsl:when test="$ou:action = 'pub'">
											<p class="text-center"><em>Having trouble viewing this email? Try it in your
												<webversion>browser</webversion></em></p>
										</xsl:when>
										<xsl:otherwise>
											<p class="text-center"><em>Having trouble viewing this email? Try it in your
												browser</em>.</p>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
								<xsl:call-template name="expander"/>
							</tr>
						</table>
					</xsl:element>
				</tr>
			</table>
			
		</xsl:if>
		<!--Header logo-->
		<table align="center" class="wrapper header">
			<tr>
				<xsl:element name="{$cell}">
					<xsl:attribute name="class" select="'wrapper-inner header'"/>
					<table align="center" class="container header">
						<tbody>
							<tr>
								<xsl:element name="{$cell}">
									<table class="row collapse">
										<tbody>
											<tr>
												<xsl:element name="{$cell}">
													<xsl:attribute name="class" select="'small-12 large-12 columns'"/>
													<xsl:attribute name="valign" select="'middle'"/>
													<table>
														<tr>
															<xsl:element name="{$cell}">
																<xsl:attribute name="style" select="'padding:10px 10px 0 10px'"/>
																<img class="center" src="{ouc:properties/parameter[@name='header-logo']}" alt="Header Logo" align="middle"/>
															</xsl:element>
														</tr>
													</table>
												</xsl:element>
											</tr>
										</tbody>
									</table>
								</xsl:element>
								<xsl:call-template name="expander"/>
							</tr>
						</tbody>
					</table>
				</xsl:element>
			</tr>
		</table>
	</xsl:template>
	<!--Footer - Edited via pcf in includes folder-->
	<!--Needs to be cleaned up more to eliminate unparsed-text-->
	<xsl:template name="footer">
		<xsl:variable name="footer-location" select="ouc:properties/parameter[@name='footer']"/>
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:copy-of select="ou:includeFile($footer-location)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="footer-display">
					<xsl:with-param name="context" select="document(concat($ou:root,$ou:site,replace($footer-location, '(\.inc)', '.pcf')))/document" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<!--View email disclaimer content controlled via page property-->
		<xsl:if test="ouc:properties/parameter[@name='disclaimer']/option[@value = 'show']/@selected = 'true'">
			<xsl:call-template name="spacer">
				<xsl:with-param name="height" select="6"/>
			</xsl:call-template>
			<table class="container disclaimer">
				<tr>
					<xsl:element name="{$cell}">
						<table class="row">
							<tr>
								<xsl:element name="{$cell}">
									<xsl:attribute name="class" select="'large-12-first large-12-last small-12 large-12 columns'"/>
									<xsl:choose>
										<xsl:when test="ouc:properties/parameter[@name='disclaimer-type']/option[@value = 'global']/@selected = 'true'">
											<xsl:copy-of select="ou:includeFile('/_resources/email/includes/disclaimer.inc')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:apply-templates select="ouc:div[@label='disclaimer']" />
										</xsl:otherwise>
									</xsl:choose>
								</xsl:element>
							</tr>
						</table>
					</xsl:element>
					<xsl:call-template name="expander"/>
				</tr>
			</table>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="editor-plugins-css">
		<xsl:if test="$ou:action = 'edt'">
			<link rel="stylesheet" href="https://cdn.omniupdate.com/table-separator/v1/table-separator.css" />
		</xsl:if>
	</xsl:template>

	<xsl:template name="editor-plugins-js">
		<xsl:if test="$ou:action = 'edt'">
			<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
			<script src="https://cdn.omniupdate.com/table-separator/v1/table-separator.js" defer="defer"></script>
		</xsl:if>
	</xsl:template>
	
	<!-- in case not defined in pagetype xsl -->
	<xsl:template name="page-content"><p>No template defined.</p></xsl:template><!-- leave for debugging purposes -->
	<xsl:template name="additional-headcode"/>
	
</xsl:stylesheet>
