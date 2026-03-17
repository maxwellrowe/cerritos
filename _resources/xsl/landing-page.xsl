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
	Landing Page Updated 2025
-->

<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<!-- Imports -->
	<xsl:import href="common.xsl"/>
	<xsl:import href="_shared/sidebar.xsl" />
	
	<!-- Set Body Classes-->
	<xsl:param name="body-classes" select="'landing-page'"/>
	
	<!-- Additional Variables -->
	<xsl:variable name="Popular" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='Popular']/text())" />
	<xsl:variable name="PageCSS" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='PageCSS']/text())" />
	<xsl:variable name="HeroBgImage" select="ou:pcf-param('hero-bg-image')" />
	<xsl:variable name="IntroductionHide" select="ou:pcf-param('lp-hide-introduction')" />
	<xsl:variable name="PopularLinksHide" select="ou:pcf-param('lp-hide-popular-links')" />
	<xsl:variable name="BottomFeatureHide" select="ou:pcf-param('lp-hide-bottom-feature')" />
	<xsl:variable name="OtherHide" select="ou:pcf-param('lp-hide-other-content')" />
	
	<!-- Additional Page Head Template -->
	<xsl:template name="page-head">
		<!-- CSS -->
		<style type="text/css"><xsl:text>&#xA;</xsl:text>
			<xsl:value-of select="$PageCSS" disable-output-escaping="yes"  /><xsl:text>&#xA;</xsl:text>
		</style><xsl:text>&#xA;</xsl:text>
		
		<!-- Gallery Headcode -->
		<xsl:call-template name="gallery-headcode">
			<xsl:with-param name="domain" />
		</xsl:call-template>
		
		<!-- Form Headcode -->
		<xsl:call-template name="form-headcode" />
	</xsl:template>
	
	<!-- Additional Page Header Template-->
	<xsl:template name="page-header">
		<div class="heading" role="region">
			<!-- Hero -->
			<xsl:choose>
				<xsl:when test="not($HeroBgImage = '')">
					<div id="about-header" style="background-image: url({$HeroBgImage})">
						<h2><xsl:value-of select="$Title" disable-output-escaping="yes" /></h2>
					</div>
				</xsl:when>
				<xsl:otherwise>
					<div id="about-header">
						<h2><xsl:value-of select="$Title" disable-output-escaping="yes" /></h2>
					</div>
				</xsl:otherwise>
			</xsl:choose>
			
			<!-- Popular Links -->
			<xsl:if test="not($PopularLinksHide = 'hide')">
				<ul class="popular">
					<xsl:value-of select="$Popular" disable-output-escaping="yes" />
				</ul>
			</xsl:if>
		</div>
	</xsl:template>
	
	<!-- Page Content Template -->
	<xsl:template name="page-content">
		<div class="body-wrap">
			<div id="content" role="main">  
				<div id="skiptocontent"></div>
				<xsl:if test="not($IntroductionHide = 'hide')">
					<p class="lead-in">
					<!-- Landing Intro -->
						<xsl:apply-templates select="document/ouc:div[@label='landingintro']" />
					</p>
				</xsl:if>
				<!-- Main Content -->
				<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
				
				<xsl:if test="not($OtherHide = 'hide')">
					<div id="contentDiv" class="clearfix">
						<!-- Other Content -->
						<xsl:apply-templates select="document/ouc:div[@label='othercontent']" />
					</div>
				</xsl:if>
				<!-- Bottom Feature -->
				<xsl:if test="not($BottomFeatureHide = 'hide')">
					<div id="BottomFeature">
						<div class="feature-content">
							<xsl:apply-templates select="document/ouc:div[@label='bottomfeature']" />
						</div>
					</div>
				</xsl:if>
			</div>
		</div>
	
	</xsl:template>

</xsl:stylesheet>