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
	Dept Home - Updated 2025
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
	<xsl:param name="body-classes" select="'department'"/>
	
	<!-- Additional Vars -->
	<xsl:variable name="HeroBgImage" select="ou:pcf-param('hero-bg-image')" />
	<xsl:variable name="PopularLinksHide" select="ou:pcf-param('lp-hide-popular-links')" />
	<xsl:variable name="TopPanelCSS" select="ou:pcf-param('TopPanelCSS')" />
	
	<!-- Page Head Template -->
	<xsl:template name="page-head">
		<xsl:if test="not($TopPanelCSS = '')">
			<style>
				<xsl:copy-of select="$TopPanelCSS" />
			</style>
		</xsl:if>
	</xsl:template>
	
	
	<!-- Page Header Template-->
	<xsl:template name="page-header">
		<!-- Top Panel Editable Region -->
		<xsl:if test="not($HeroBgImage = '')">
			<style>
				.department #top-panel {
					background-image: url(<xsl:value-of select="$HeroBgImage" />) !important;
				}
			</style>
		</xsl:if>
		<xsl:if test="$PopularLinksHide = 'hide'">
			<style>
				.department #top-panel .top-panel-content {
					display: none !important;
				}
			</style>
		</xsl:if>
		<xsl:apply-templates select="document/ouc:div[@label='toppanel']" />
	</xsl:template>
	
	<!-- Page Content Template -->
	<xsl:template name="page-content">
		
		<div class="body-wrap">
			<div class="clearfix">
				<div class="row">
					<!-- Sidebar -->
					<xsl:call-template name="sidebar"/>

					<!-- Main Content - 2 Column -->
					<div id="maincontent" class="col-sm-8 col-md-9" role="main">
						<div id="skiptocontent"></div>

						<!-- Breadcrumbs START - based on imported templates -->
						<xsl:variable name="legacy-breadcrumbs" select="ou:pcf-param('legacy-breadcrumbs')" />
						<xsl:choose>
							<xsl:when test="ou:pcf-param('hide-breadcrumbs') and ou:pcf-param('hide-breadcrumbs') = 'true'">
								<!-- Do Nothing -->
							</xsl:when>
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when test="$legacy-breadcrumbs = 'enabled'">
										<xsl:call-template name="legacyBreadcrumbs"/>
									</xsl:when>
									<xsl:when test="$legacy-breadcrumbs != 'disabled'">
										<xsl:call-template name="legacyBreadcrumbs"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:call-template name="breadcrumbsList"/>
									</xsl:otherwise>
								</xsl:choose>
							</xsl:otherwise>
						</xsl:choose>
						<!-- Breadcrumbs END -->

						<!-- Dept Home with Editable Regions -->
						<div id="contentcontainer">

							<!-- heading -->
							<h2><xsl:value-of select="$Title" disable-output-escaping="yes" /></h2>

							<!-- introduction -->
							<div class="department-statement">
								<xsl:apply-templates select="document/ouc:div[@label='introduction']" />
							</div>

							<!-- home links -->
							<xsl:apply-templates select="document/ouc:div[@label='homelinks']" />
							<br class="clearall" clear="all" />

							<!-- main content -->
							<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
						</div>
						<div id="othercontent">
							<!-- other content -->
							<xsl:apply-templates select="document/ouc:div[@label='othercontent']" />
						</div>
					</div>
				</div>
			</div>
		</div>
	
	</xsl:template>

</xsl:stylesheet>