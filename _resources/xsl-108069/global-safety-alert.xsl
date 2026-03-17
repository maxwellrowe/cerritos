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
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value='info-white']">
			<div id="emergencyNotice" class="WhiteInfo">
        			<div class="right pointer"><img class="close-icon" alt="close" src="{{f:80150862}}"/></div> 
				<span class="fa fa-info-circle">&#160;</span>
				<span class="e-body"><xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" /></span>
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value='info-blue']">
			<div id="emergencyNotice" class="BlueInfo">
        		<div class="right pointer"><img class="close-icon" alt="close" src="{{f:80150862}}"/></div> 
				<span class="fa fa-info-circle">&#160;</span>
				<span class="e-body"><xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" /></span>
			</div>
		</xsl:when>
	   <xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value='info-green']">
			<div id="emergencyNotice" class="GreenInfo">
        		<div class="right pointer"><img class="close-icon" alt="close" src="{{f:80150862}}"/></div> 
				<span class="fa fa-info-circle">&#160;</span>
				<span class="e-body"><xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" /></span>
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value='warning']">
			<div id="emergencyNotice" class="YellowWarning">
        		<div class="right pointer"><img class="close-icon" alt="close" src="{{f:80150862}}"/></div> 
				<span class="fa fa-warning">&#160;</span>
				<span class="e-body"><xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" /></span>
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value = 'emergency']">
			<div id="emergencyNotice" class="RedAlert">
        		<div class="right pointer"><img class="close-icon" alt="close" src="{{f:80150862}}"/></div>  
				<span class="fa fa-exclamation-triangle">&#160;</span>
				<span class="e-body"><xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" /></span>
			</div>
		</xsl:when>
		<xsl:otherwise>
				
		</xsl:otherwise>
	</xsl:choose>

    <!--######## end Emergency Notice ########--> 

	</xsl:template>
	
</xsl:stylesheet>



