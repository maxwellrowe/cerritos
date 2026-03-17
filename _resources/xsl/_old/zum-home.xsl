<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xsl xs ou ouc">
	
<!--### optional left nav only and main content  ###-->
	
	<xsl:import href="functions-workshop.xsl" />
	<xsl:import href="ou-variables.xsl" />
	<xsl:import href="template-matches.xsl" />
	<xsl:import href="ou-forms.xsl" />
	<xsl:import href="accessibility-all.xsl" />

	<xsl:param name="ou:navigation" />

	<!-- removes unnecessary whitespace between elements. 	-->
	<xsl:strip-space elements="*" />
	
<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no" /> 

<xsl:template match="/">

	<!--<xsl:variable name="Web" select="document/ouc:properties[@label='config']/parameter[@name='Web']" />-->
	<xsl:variable name="Author" select="document/ouc:properties[@label='metadata']/meta[@name='author']/@content" />
	<xsl:variable name="Keywords" select="document/ouc:properties[@label='metadata']/meta[@name='keywords']/@content"/>
	<xsl:variable name="Description" select="document/ouc:properties[@label='metadata']/meta[@name='description']/@content"/>
	<xsl:variable name="Robots" select="document/ouc:properties[@label='metadata']/meta[@name='robots']/@content"/>
	<xsl:variable name="WebCss" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='WebCss']/text())" />
	<xsl:variable name="Title" select="document/ouc:properties[@label='metadata']/title" />
	<xsl:variable name="TopNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='TopNav']/text())" />

	<html lang="en-us">
      <head>
        <meta http-equiv="X-UA-Compatible" content="text/html;IE=edge" />
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
        <meta http-equiv="Content-Script-Type" content="text/html;text/JavaScript" />
        <meta http-equiv="Content-Style-Type" content="text/html;text/css" />
        <meta name="viewport" content="width=device-width,user-scalable = yes,initial-scale = 1.0" />
		 <!-- puts cerritos college in title -->
        <title>
			<xsl:choose>
				<xsl:when test="contains(lower-case($Title), 'cerritos college') = true ">
					<xsl:value-of select="$Title" disable-output-escaping="yes" />
				</xsl:when>
				<xsl:otherwise>
					Cerritos College - <xsl:value-of select="$Title" disable-output-escaping="yes" />
				</xsl:otherwise>
			</xsl:choose>
        </title>
		<meta name="author" content="{$Author}" />
        <meta name="keywords" content="{$Keywords}" />
        <meta name="description" content="{$Description}" />
		<meta name="robots" content="all" />
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />
        <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
		  
        <xsl:comment> cerritos legacy CSS </xsl:comment>
		<link href="{{f:80151058}}" rel="stylesheet" type="text/css" media="all" /><xsl:text>&#xA;</xsl:text>
        <xsl:comment> editor styles </xsl:comment>
        <link href="{{f:80151080}}" rel="stylesheet" type="text/css" media="all" />
       	<xsl:comment> 2017 styles </xsl:comment>
        <link href="/_resources/css/2017.css" rel="stylesheet" type="text/css" media="all" />
		<xsl:comment> home page styles </xsl:comment>
        <link href="{{f:80151057}}" rel="stylesheet" type="text/css" media="all" />

		<script type="text/javascript" src="{{f:80151144}}"></script>
		<script type="text/javascript" src="/_resources/js/calendar_condensed.js"></script>
		  
	<!-- main google tracking code -->
		 <xsl:copy-of select="ou:includeFile('/_resources/includes/google-tag-manager-body-script.inc')"/>



	<!-- removes the / from the dirname for the choose statement below -->
	<xsl:variable name="firstdirtest" select="substring(concat('/',tokenize($dirname,'/')[2]),2)" />  
		  
	<!-- which additional tracking code to include-->
	<xsl:choose>
	<xsl:when test="lower-case($firstdirtest) = 'cerritostrainsu'">
		<xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics-cerritostrainsu.inc')"/>
	</xsl:when>
	<xsl:when test="lower-case($firstdirtest) = 'counseling'">
		<xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics-counseling.inc')"/>
	</xsl:when>
	<xsl:when test="lower-case($firstdirtest) = 'music'">
		<xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics-music.inc')"/>
	</xsl:when>
		<xsl:when test="lower-case($firstdirtest) = 'professional-relations'">
		<xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics-prof-rel.inc')"/>
	</xsl:when>
		<xsl:when test="lower-case($firstdirtest) = 'teachertrac'">
		<xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics-teachertrac.inc')"/>
	</xsl:when>
		<xsl:when test="lower-case($firstdirtest) = 'theater'">
		<xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics-theater.inc')"/>
	</xsl:when>
	</xsl:choose>
		  
	<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
	<script type="text/javascript">
		$(document).ready(function(){
    		$(".close-icon").click(function(){
       		 $("#emergencyNotice").hide(750);
    		});
		});
	</script>
      </head>
		 <body>
		<!--######## Emergency Notice ########-->

	<xsl:choose>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value='info-white']">
			<div id="emergencyNotice" class="WhiteInfo">
				<div class="right pointer"><img class="close-icon" alt="x" src="{{f:80150862}}" /></div>
				<xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" />
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value='info-blue']">
			<div id="emergencyNotice" class="BlueInfo">
				<div class="right pointer"><img class="close-icon" alt="x" src="{{f:80150862}}" /></div>
				<xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" />
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value='warning']">
			<div id="emergencyNotice" class="YellowWarning">
				<div class="right pointer"><img class="close-icon" alt="x" src="{{f:80150862}}" /></div>
				<xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" />
			</div>
		</xsl:when>
		<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='AlertsDiv']/option[@selected='true' and @value = 'emergency']">
			<div id="emergencyNotice" class="RedAlert">
				<div class="right pointer"><img class="close-icon" alt="x" src="{{f:80150862}}" /></div>
				<xsl:apply-templates select="document/ouc:div[@label='alertsdiv']" />
			</div>
		</xsl:when>
		<xsl:otherwise>
				
		</xsl:otherwise>
	</xsl:choose>

    <!--######## end Emergency Notice ########--> 
			 
		 	<!-- global header -->
		 	<xsl:copy-of select="ou:includeFile('/_resources/includes/header.inc')"/>
 <div id="content">
			 <!-- left menu -->
			<xsl:comment> left menu  </xsl:comment>
			<xsl:apply-templates select="document/ouc:div[@label='leftmenu']" />
			 
			<!-- main content -->
			<xsl:comment> main content  </xsl:comment>
			<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
</div>
			<!-- global footer -->
			<xsl:copy-of select="ou:includeFile('/_resources/includes/footer.inc')"/>
		
		  </body>
		</html>	 
	</xsl:template>	

</xsl:stylesheet>



