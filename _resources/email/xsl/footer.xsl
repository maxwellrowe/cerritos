<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY amp   "&#38;">
<!ENTITY nbsp   "&#160;">
]>
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="ou xsl ouc">
	
	<xsl:import href="dependencies.xsl"/>
	
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes" />
	
	<xsl:template name="footer-display">
		<xsl:param name="context" select="." /> <!-- This allows us to set the context item for all of the XPATHs used later. This is so we can use this footer from an external staging page. -->
		<table class="footer row">
			<tr>
				<xsl:element name="{$cell}">
					<table class="footer-container" align="center">
						<tbody>
							<tr>
								<xsl:element name="{$cell}">
									<!-- Footer Logo -->
									<table class="row">
										<tbody>
											<tr>
												<xsl:element name="{$cell}">
													<xsl:attribute name="class" select="'small-12 large-12 columns large-12-first large-12-last'"/>
													<table>
														<tr>
															<xsl:element name="{$cell}">
																<center>
																	<img class="float-center" src="{$context/ouc:properties/parameter[@name='footer-logo']}" alt="" align="middle"/>
																</center>
															</xsl:element>
														</tr>
													</table>
												</xsl:element>
												<xsl:call-template name="expander"/>
											</tr>
										</tbody>
									</table>
								</xsl:element>
							</tr>
						</tbody>
					</table>
					<!-- END Footer logo -->
					<!-- Social Media Text -->								
					<xsl:if test="$context/ouc:properties/parameter[@name='social-text'] != ''">
						<table class="footer-container" align="center">
							<tbody>
								<tr>
									<xsl:element name="{$cell}">
										<xsl:attribute name="class" select="'small-12 large-12 columns large-12-first large-12-last'"/>
										<table>
											<tr>
												<xsl:element name="{$cell}">
													<h4 class="text-center"><xsl:value-of select="$context/ouc:properties/parameter[@name='social-text']"/></h4>
												</xsl:element>
											</tr>
										</table>
									</xsl:element>
									<xsl:call-template name="expander"/>
								</tr>
							</tbody>
						</table>
					</xsl:if>
					<!-- END Social Media Text -->
					
					
					<!-- Social Media Icons -->
					<table class="footer-container" align="center">
						<tbody>
							<tr>
								<xsl:element name="{$cell}">
									<xsl:for-each-group select="$context/ouc:properties[@label='social-media']/parameter[. != '']" group-by="position() lt 6">
										<table class="row">
											<tr>
												<xsl:element name="{$cell}"><xsl:attribute name="class" select="'large-offset-1'"/></xsl:element>
												<xsl:for-each select="current-group()">
													<xsl:element name="{$cell}">
														<a href="{@prompt/..}">
															<img src="{concat($ou:httproot, '_resources/email/images/icons/', substring-before(@name,'-link'), '.jpg')}" 
																style="-webkit-border-radius:500px;-moz-border-radius:500px;border-radius:500px;"
																class="float-center" align="middle" alt="{@prompt}" />
														</a>
													</xsl:element>
													<xsl:call-template name="expander"/>
												</xsl:for-each>
												<xsl:element name="{$cell}"><xsl:attribute name="class" select="'large-offset-1'"/></xsl:element>
											</tr>
										</table>
										<xsl:call-template name="spacer">
											<xsl:with-param name="height" select="16"/>
										</xsl:call-template>
									</xsl:for-each-group>
								</xsl:element>
							</tr>
						</tbody>
					</table>
					<!-- END Social Media Icons -->
					
					<!-- Copyright and links -->
					<table class="footer-container" align="center">
						<tr>
							<xsl:element name="{$cell}">
								<table class="row">
									<tr>
										<xsl:element name="{$cell}">
											<xsl:attribute name="class" select="'small-12 large-12 columns large-12-first large-12-last'"/>
											<p class="text-center"><xsl:value-of select="$context/ouc:properties/parameter[@name='copyright']"/> | <xsl:if test="$context/ouc:properties/parameter[@name='terms']!=''"><a href="{$context/ouc:properties/parameter[@name='terms']}">Terms of Use</a> | </xsl:if><xsl:if test="$context/ouc:properties/parameter[@name='privacy']!=''"><a href="{$context/ouc:properties/parameter[@name='privacy']}">Privacy Policy</a></xsl:if>
												<xsl:if test="$ou:action = 'pub'"><xsl:choose><xsl:when test="$context/ouc:properties/parameter[@name='unsubscribe']/option[@selected='true']/@value = 'show'"> | 
													
													<unsubscribe>Unsubscribe</unsubscribe></xsl:when><xsl:otherwise><unsubscribe style="display:none;color:#444444;text-decoration:none;">Unsubscribe</unsubscribe>
														<style type="text/css">unsubscribe hidden with permission #283818
														</style></xsl:otherwise></xsl:choose></xsl:if>
											</p>
										</xsl:element>
										<xsl:call-template name="expander"/>
									</tr>
								</table>
							</xsl:element>
						</tr>
					</table>
					<!-- END Copyright and links -->
				</xsl:element>
			</tr>
		</table>	
	</xsl:template>
	
	<xsl:template match="/document">
		<!--For the page preview only, basic properties file set up-->
		<xsl:choose>
			<xsl:when test="$ou:action != 'pub'">
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
							<h1>Footer Properties</h1>
							To edit the following footer propeties, please check out this page and go to the Page Properties screen.<br/>
							This footer must be published before changes will appear on subsequently published emails. Previously published emails will remain unchanged until republished. <br/> 
							<br/>
							
							<h2>Properties for the Footer Template</h2>
							<!--Loop through both the config label, and the social-media label for the page preview-->
							<dl>	
								<xsl:for-each select="ouc:properties/parameter">
									<dt><xsl:value-of select="@prompt"/></dt>
									<dd>
										<xsl:choose>
											<xsl:when test=". = ''">
												<p style="color:red;"><strong>This footer value is empty and will not display.</strong></p>
											</xsl:when>
											<xsl:when test="@type = 'radio'">
												<p><xsl:value-of select="option[@selected = 'true']"/></p>
											</xsl:when>
											<xsl:otherwise>
												<p><xsl:value-of select="."/></p>
											</xsl:otherwise>
										</xsl:choose>
									</dd>
									<br/>
								</xsl:for-each>
							</dl>	
						</div>
						
						<!-- To disable OU Campus from going straight to WYSIWYG when in edit mode. -->
						<div style="display:none;"><ouc:div label="fake" group="fake" button="hide"/></div>
					</body>
				</html>	
			</xsl:when>
			<xsl:otherwise>
				<!--Displays the footer-->
				<xsl:call-template name="footer-display" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="spacer">
		<xsl:param name="height" as="xs:integer"/>
		<table class="spacer float-center">
			<tbody>
				<tr>
					<td height="{$height}px" style="font-size:{$height}px;line-height:{$height}px;">
						<xsl:if test="$ou:action = 'pub'">&nbsp;</xsl:if>
					</td>
				</tr>
			</tbody>
		</table>
	</xsl:template>
	
</xsl:stylesheet>
