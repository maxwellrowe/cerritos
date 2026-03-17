<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xsl xs ou ouc">
	<xsl:import href="functions-workshop.xsl" />
	<xsl:import href="ou-variables.xsl" />
	<xsl:import href="ou-forms.xsl" />
	<xsl:import href="template-matches.xsl" />
	<xsl:import href="accessibility-link-icons.xsl" />
	<xsl:param name="ou:navigation" />

	<!-- removes unnecessary whitespace between elements. 	-->
	<xsl:strip-space elements="*" />
	<xsl:output omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<!--######## Emergency Notice ########-->
<xsl:choose>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='alertsdiv-2']/option[@selected='true' and @value='info-white']">
			<div id="emergencyNotice-2" class="WhiteInfo">
<!--         			<div class="right pointer"><img class="close-icon-2" alt="close" src="/_resources/images/home/close-x-2-12-blk.png"/></div> -->
				<span class="fa fa-info-circle">&#160;</span>
				<span class="e-body"><xsl:apply-templates select="document/ouc:div[@label='alertsdiv-2']" /></span>
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='alertsdiv-2']/option[@selected='true' and @value='info-blue']">
			<div id="emergencyNotice-2" class="BlueInfo">
<!--         		<div class="right pointer"><img class="close-icon" alt="close" src="/_resources/images/home/close-x-2-12-blk.png"/></div>  -->
				<span class="fa fa-info-circle">&#160;</span>
				<span class="e-body"><xsl:apply-templates select="document/ouc:div[@label='alertsdiv-2']" /></span>
			</div>
		</xsl:when>
	    <xsl:when test="document/ouc:properties[@label='config']/parameter[@name='alertsdiv-2']/option[@selected='true' and @value='info-green']">
			<div id="emergencyNotice-2" class="GreenInfo">
<!--         		<div class="right pointer"><img class="close-icon" alt="close" src="/_resources/images/home/close-x-2-12-blk.png"/></div>  -->
				<span class="fa fa-info-circle">&#160;</span>
				<span class="e-body"><xsl:apply-templates select="document/ouc:div[@label='alertsdiv-2']" /></span>
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='alertsdiv-2']/option[@selected='true' and @value='warning']">
			<div id="emergencyNotice-2" class="YellowWarning">
<!--         		<div class="right pointer"><img class="close-icon-2" alt="close" src="/_resources/images/home/close-x-2-12-blk.png"/></div> -->
				<span class="fa fa-warning">&#160;</span>
				<span class="e-body"><xsl:apply-templates select="document/ouc:div[@label='alertsdiv-2']" /></span>
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='alertsdiv-2']/option[@selected='true' and @value = 'emergency']">
			<div id="emergencyNotice-2" class="RedAlert">
<!--         		<div class="right pointer"><img class="close-icon-2" alt="close" src="/_resources/images/home/close-x-2-12-blk.png"/></div>  -->
				<span class="fa fa-exclamation-triangle">&#160;</span>
				<span class="e-body"><xsl:apply-templates select="document/ouc:div[@label='alertsdiv-2']" /></span>
			</div>
		</xsl:when>
		<xsl:otherwise>
				
		</xsl:otherwise>
	</xsl:choose>

    <!--######## end Emergency Notice ########--> 

	</xsl:template>
	
</xsl:stylesheet>



