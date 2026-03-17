<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="ou xsl ouc">
	
	<xsl:strip-space elements="*" />
	
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes" />
	
	<xsl:param name="ou:action"/>
	
	<!--/**********************************************
		* 			   Color 1 Theme Vars   	  *
	**********************************************/-->
	
	<!--************** COLOR 1 **************-->
	<xsl:param name="color-1"><xsl:value-of select="/document/ouc:properties/config-colors/parameter[@name='color-1']"/></xsl:param>
	<xsl:param name="color-1-dark"><xsl:value-of select="/document/ouc:properties/config-colors/parameter[@name='color-1-dark']"/></xsl:param>
	
	<!--************** COLOR 1 GENERAL COLORS **************-->
	<xsl:param name="color-1-header-color"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-1-header-color']"/></xsl:param>	
	<xsl:param name="color-1-footer-background"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-1-footer-background']"/></xsl:param>
	<xsl:param name="color-1-footer-link"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-1-footer-link']"/></xsl:param>
	<xsl:param name="color-1-footer-link-hover"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-1-footer-link-hover']"/></xsl:param>
	<xsl:param name="color-1-footer-text"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-1-footer-text']"/></xsl:param>
	<xsl:param name="color-1-disclaimer-background"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-1-disclaimer-background']"/></xsl:param>	
	
	<!--/**********************************************
		* 			   Color 2 Theme Vars     	  *
	**********************************************/-->	
	
	<!--************** COLOR 2 **************-->	
	<xsl:param name="color-2"><xsl:value-of select="/document/ouc:properties/config-colors/parameter[@name='color-2']"/></xsl:param>
	<xsl:param name="color-2-dark"><xsl:value-of select="/document/ouc:properties/config-colors/parameter[@name='color-2-dark']"/></xsl:param>
	
	<!--************** COLOR 2 GENERAL COLORS **************-->
	<xsl:param name="color-2-header-color"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-2-header-color']"/></xsl:param>	
	<xsl:param name="color-2-footer-background"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-2-footer-background']"/></xsl:param>
	<xsl:param name="color-2-footer-link"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-2-footer-link']"/></xsl:param>
	<xsl:param name="color-2-footer-link-hover"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-2-footer-link-hover']"/></xsl:param>
	<xsl:param name="color-2-footer-text"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-2-footer-text']"/></xsl:param>
	<xsl:param name="color-2-disclaimer-background"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-2-disclaimer-background']"/></xsl:param>
	
	<!--/**********************************************
		* 			   Color 3 Theme Vars     	  *
	**********************************************/-->	
	
	<!--************** COLOR 3 **************-->	
	<xsl:param name="color-3"><xsl:value-of select="/document/ouc:properties/config-colors/parameter[@name='color-3']"/></xsl:param>
	<xsl:param name="color-3-dark"><xsl:value-of select="/document/ouc:properties/config-colors/parameter[@name='color-3-dark']"/></xsl:param>
	
	<!--************** COLOR 3 GENERAL COLORS **************-->
	<xsl:param name="color-3-header-color"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-3-header-color']"/></xsl:param>	
	<xsl:param name="color-3-footer-background"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-3-footer-background']"/></xsl:param>
	<xsl:param name="color-3-footer-link"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-3-footer-link']"/></xsl:param>
	<xsl:param name="color-3-footer-link-hover"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-3-footer-link-hover']"/></xsl:param>
	<xsl:param name="color-3-footer-text"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-3-footer-text']"/></xsl:param>
	<xsl:param name="color-3-disclaimer-background"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-3-disclaimer-background']"/></xsl:param>
	
	<!--/**********************************************
		* 			   Color 4 Theme Vars     	  *
	**********************************************/-->	
	
	<!--************** COLOR 4 **************-->	
	<xsl:param name="color-4"><xsl:value-of select="/document/ouc:properties/config-colors/parameter[@name='color-4']"/></xsl:param>
	<xsl:param name="color-4-dark"><xsl:value-of select="/document/ouc:properties/config-colors/parameter[@name='color-4-dark']"/></xsl:param>
	
	<!--************** COLOR 4 GENERAL COLORS **************-->
	<xsl:param name="color-4-header-color"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-4-header-color']"/></xsl:param>	
	<xsl:param name="color-4-footer-background"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-4-footer-background']"/></xsl:param>
	<xsl:param name="color-4-footer-link"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-4-footer-link']"/></xsl:param>
	<xsl:param name="color-4-footer-link-hover"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-4-footer-link-hover']"/></xsl:param>
	<xsl:param name="color-4-footer-text"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-4-footer-text']"/></xsl:param>
	<xsl:param name="color-4-disclaimer-background"><xsl:value-of select="/document/ouc:properties/config-general/parameter[@name='color-4-disclaimer-background']"/></xsl:param>
	
	<xsl:template name="config-preview">
		<html lang="en">
			<head>
				<link href="//netdna.bootstrapcdn.com/bootswatch/3.1.0/cerulean/bootstrap.min.css" rel="stylesheet"/>
				<style>
					body{ font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; }
					.ox-regioneditbutton { display: none; }
				</style>
			</head>
			
			<body id="properties">
				
				<div class="container">
					<div class="row">
						<div class="col-xs-12">
							<h1>Color Configuration</h1>
							<p class="lead">To configure the theme colors, please check out this page and go to the Page Properties screen.  Changes will take effect immediately in OU Campus - this file <strong class="text-danger">MUST</strong> be published in order for your changes to take affect on the email templates.</p>	
						</div>
					</div>
					
					<div class="row">					
						<xsl:for-each select="ouc:properties[@label='color']">
							<div class="col-xs-6">
								<xsl:if test="position() mod 2 = 0">
									<xsl:attribute name="style">border-left: 1px solid rgb(238, 238, 238);</xsl:attribute>
								</xsl:if>
								<h2>Theme <xsl:value-of select="position()"/> Color Configuration</h2>
								<hr/>
								<div class="row">
									<div class="col-xs-12">
										<h4><xsl:value-of select="config-colors/parameter/@section"/></h4>
										<p>
											The main colors of your theme.  These colors define the color of your headings, panels, links etc.
										</p>
									</div>
								</div>
								<div class="row">
									<xsl:for-each select="config-colors/parameter">
										<div class="col-xs-4">
											<dl>
												<xsl:call-template name="preview-display"/>
												<br/>
											</dl>
										</div>
									</xsl:for-each>
								</div>
								<div class="row">
									<div class="col-xs-12">
										<h4><xsl:value-of select="config-general/parameter/@section"/></h4>
										<p>
											The colors of specific components of your theme.
										</p>
									</div>
								</div>
								<div class="row">
									<xsl:for-each select="config-general/parameter">
										<div class="col-xs-4">
											<dl>
												<xsl:call-template name="preview-display"/>
												<br/>
											</dl>
										</div>
									</xsl:for-each>
								</div>	
							</div>
						</xsl:for-each>
					</div>					
				</div>			
				<!-- To disable OU Campus from going straight to WYSIWYG when in edit mode. -->
				<div style="display:none;"><ouc:div label="fake" group="fake" button="hide"/></div>
			</body>
		</html>
		
	</xsl:template>
	
	<xsl:template name="preview-display">
		<dt><xsl:value-of select="@prompt"/></dt>
		<dd>
			<xsl:choose>
				<xsl:when test=". = ''">
					<button type="button" style="background-color:#D43F3A; color:white;" class="btn">No color value</button>
				</xsl:when>
				<xsl:otherwise>
					<button type="button" style="background-color:{.}; color:{.}; text-shadow:none; border:1px solid #333333;" title="{.}" class="btn"><xsl:value-of select="@prompt"/></button>
				</xsl:otherwise>
			</xsl:choose>
		</dd>
	</xsl:template>
	
</xsl:stylesheet>
