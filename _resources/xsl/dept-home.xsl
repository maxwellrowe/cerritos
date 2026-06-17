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
	<xsl:param name="body-classes" select="'department home'"/>
	
	<!-- Additional Vars -->
	<xsl:variable name="HeroBgImage" select="ou:pcf-param('hero-bg-image')" />
	<xsl:variable name="PopularLinksHide" select="ou:pcf-param('lp-hide-popular-links')" />
	<xsl:variable name="TopPanelRandomBG" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='TopPanelRandomBG']/text())" />
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
		<xsl:if test="string-length($TopPanelRandomBG) > 0">
			<script type="text/javascript"><xsl:text>&#xA;</xsl:text>
				<xsl:value-of select="$TopPanelRandomBG" disable-output-escaping="yes" /><xsl:text>&#xA;</xsl:text>
			</script><xsl:text>&#xA;</xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template name="page-content">
		<xsl:choose>
			<xsl:when test="ou:pcf-param('page-fullwidth') = 'true'">
				<main id="maincontent">
					<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />	
				</main>
			</xsl:when>
			<xsl:otherwise>
				<div class="container-xxl py-5">
					<div class="row">
						<xsl:choose>
							<xsl:when test="ou:pcf-param('hide-left-nav') = 'true' and ou:pcf-param('hide-dept-info') = 'true'">
								<!-- Main Content -->
								<main id="maincontent" class="col-12">
									<div id="skiptocontent"></div>
									<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />	
								</main>
							</xsl:when>
							<xsl:otherwise>
								

								<!-- Main Content -->
								<main id="maincontent" class="col-12 col-lg-8 col-xl-9">
									<div id="skiptocontent"></div>

									<!-- introduction -->
									<div class="department-statement">
										<xsl:apply-templates select="document/ouc:div[@label='introduction']" />
									</div>

									<!-- home links -->
									<xsl:apply-templates select="document/ouc:div[@label='homelinks']" />
									<br class="clearall" clear="all" />

									<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />	
									
									<div id="othercontent">
										<!-- other content -->
										<xsl:apply-templates select="document/ouc:div[@label='othercontent']" />
									</div>
								</main>
								
								<!-- Sidebar -->
								<div class="col-12 col-lg-4 col-xl-3">
									<xsl:if test="lower-case(normalize-space(ou:pcf-param('hide-left-nav'))) != 'true'">
										<div class="d-none d-lg-block">
											<xsl:call-template name="sidebar-nav"/>
										</div>
									</xsl:if>
									<xsl:if test="lower-case(normalize-space(ou:pcf-param('hide-dept-info'))) != 'true'">
										<xsl:call-template name="sidebar-info"/>
									</xsl:if>
								</div>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

</xsl:stylesheet>
