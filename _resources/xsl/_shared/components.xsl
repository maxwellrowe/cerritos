<?xml version="1.0" encoding="UTF-8" ?>
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
<xsl:stylesheet version="3.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="xsl xs ou ouc">	

	<xsl:template match="ouc:component[@name='slider-2']">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="slides">
		<xsl:for-each select="slide">  
			<xsl:call-template name="slide">
				<xsl:with-param name="position" select="position()"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="buttons">
		<xsl:choose>
			
				<xsl:when test=".//a[@class='dlinkPage']/@href !='' ">
					<div class="buttons"><a class="dlinkPage" href="{.//a[@class='dlinkPage']/@href}">d</a>&nbsp;<button id="toggle-custom-2">Pause</button></div>
				</xsl:when>
				
				<xsl:otherwise>
					<div class="buttons"><button id="toggle-custom-2">Pause</button></div>
				</xsl:otherwise>
				
		</xsl:choose>
	</xsl:template>

	<xsl:template name="slide">
		<xsl:param name="position"/>
		<div>
			<img src="{.//img/@src}" alt="{.//img/@alt}" />
						<div class="slick-caption">											
							<xsl:if test=".//div[@class='mainHeadingText'] !='' ">
								<div class="mainHeadingText">
										<xsl:value-of select=".//div[@class='mainHeadingText']"/>								
								</div>
							</xsl:if>

							<xsl:if test=".//div[@class='subHeadingText'] !='' ">
								<div class="subHeadingText">
										<xsl:copy-of select=".//div[@class='subHeadingText']"/>
								</div>
							</xsl:if>
							
							<xsl:if test=".//a[@class='button']/@href !='' ">
									<a class="button" href="{.//a[@class='button']/@href}"><xsl:value-of select=".//a[@class='button']"/></a>								
							</xsl:if>
						</div>		
		
		</div>
						
	</xsl:template>	

</xsl:stylesheet>
