<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xsl xs ou ouc">
	
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

	<xsl:variable name="Author" select="document/ouc:properties[@label='metadata']/meta[@name='author']/@content" />
	<xsl:variable name="Keywords" select="document/ouc:properties[@label='metadata']/meta[@name='keywords']/@content"/>
	<xsl:variable name="Description" select="document/ouc:properties[@label='metadata']/meta[@name='description']/@content"/>
	<xsl:variable name="Title" select="document/ouc:properties[@label='metadata']/title" />

	<html lang="en-us">
	<head>
		<!-- header include -->
		<xsl:copy-of select="ou:includeFile('/_resources/includes/head-2.inc')"/>
		
     	<!-- title -->
     	<title><xsl:value-of select="$Title" disable-output-escaping="yes" /></title>
		<meta name="author" content="{$Author}" />
        <meta name="keywords" content="{$Keywords}" />
        <meta name="description" content="{$Description}" />
		<meta name="copyright" content="Cerritos College"/>
		
		<!-- our google verification key for the home page -->
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />


	<!-- IE Conditionals from current Cerritos.edu site -->
	<!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
      <script src="{{f:80151045}}" type="text/javascript">
          //comment
        </script>
      <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
      <!-- [if lt IE 9]>
	  <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
	  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
	  <![endif] -->
 	<!--[if lt IE 8]>
	<link href="/_resources/css/css2_tables_min.css" rel="stylesheet" type="text/css" media="all" />
        <![endif]-->
	<!-- End Conditionals -->
	
	<!-- only used for home page -->
    <script src="{{f:80151147}}"></script>

	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-tag-manager-body-script.inc')"/>


		
</head>
	 
<body class="home-page">

<div class="body-wrap">
	<!-- header -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header.inc')"/>
	<div id="skiptocontent"></div>
    <div id="contentDiv" class="clearfix">
		<div>
		<h2 style="margin-top:2.5em;color:navy;">CALENDAR</h2>
			<hr style="background:navy;height:.2em;margin:0 0 1.5em 0;"/>
		<div id="CalendarDiv"></div>
		<script>
			$("#CalendarDiv").load("/scripts/campus-calendar.ashx?feed=http://www.cerritos.edu/calendar/rss/campus-calendar.php&amp;limit=100");
		</script><noscript>The calendar requires javascript enabled.</noscript>
    </div>
		</div>
    </div>
	<!-- footer -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer.inc')"/>
</body>
		</html>	 
	</xsl:template>	

	<!-- remove img height and width attributes and add photo class -->
	<xsl:template match="img/@width|img/@height">
		<xsl:attribute name="class">photo</xsl:attribute>
	</xsl:template>
	<xsl:template match="node()|@*">
  <xsl:copy>
   <xsl:apply-templates select="node()|@*"/>
  </xsl:copy>
 </xsl:template>
	
</xsl:stylesheet>



