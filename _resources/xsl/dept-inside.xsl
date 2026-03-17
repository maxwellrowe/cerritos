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
	New Page (Dept Inside) Updated 2025
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
	<xsl:param name="body-classes" select="'department inside'"/>
	
	<xsl:template name="page-content">
	
		<div class="body-wrap">
			<div class="clearfix">

			   <!-- Sidebar -->
			   <xsl:call-template name="sidebar"/>


				<!-- Main Content -->
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
									<xsl:call-template name="breadcrumbsList" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
					</xsl:choose>
					<!-- Breadcrumbs END -->



					<!-- Inside Page Content with Editable Region -->
					<div id="contentcontainer">
						<!-- heading -->
						<h2><xsl:value-of select="$Title" disable-output-escaping="yes" /></h2>

						<!-- other inside content -->
						<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />								

					</div>
				</div>
			</div>
		</div>
	
	</xsl:template>

</xsl:stylesheet>