<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xsl ou ouc">

	<xsl:import href="common.xsl"/>
	<xsl:template name="page-content">
		<table align="center" class="container float-center">
			<tbody>
				<tr>
					<xsl:element name="{$cell}">
						<xsl:if test="ouc:properties/parameter[@name='show-date']/option[@selected='true']/@value = 'show'"><!--Date stamp-->
							<table class="row">
								<tr>
									<xsl:element name="{$cell}">
										<xsl:attribute name="class" select="'small-12 large-12 columns large-12-first large-12-last'"/>
										<p class="date"><xsl:value-of select="ouc:properties/parameter[@name='date']" /></p>
									</xsl:element>
								</tr>
							</table>
						</xsl:if>
						<xsl:apply-templates select="ouc:div[@label='main-content']" />
					</xsl:element>
					<xsl:call-template name="expander"/>
				</tr>
			</tbody>
		</table>
	</xsl:template>
</xsl:stylesheet>
