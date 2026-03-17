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

	<!-- only used for home page -->
	<link rel="stylesheet" href="{{f:80151057}}"/>
	
	<!-- only used for home page -->
    <script src="{{f:80151147}}"></script>

	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-tag-manager-body-script.inc')"/>


		
</head>
	 
<body class="home-page">
	
	<!--######## Global Safety Alert ########
	<xsl:copy-of select="ou:includeFile('/_resources/includes/global-safety-alert.inc')"/>-->
	<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
			<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="'/_resources/includes/global-safety-alert.inc'"/>
			</xsl:call-template>
	
<div class="body-wrap">
	<!-- header -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header.inc')"/>
	
    <div id="photoDivNew" class="flexslider">
        <ul class="slides">
            <li>
                <img src="{{f:80150896}}" alt="Slide" title="Slide"/>
                <div class="slide-content">
                  <h4>ONE CAMPUS FOR ALL</h4>
                    <h3>INCLUSIVE AND DIVERSE</h3>
                    <a class="button" href="#">REVIEW OUR DIVERSITY PROGRAM</a>
                </div>
            </li>
            <li>
                <img src="{{f:80150701}}" alt="Slide" title="Slide"/>
            </li>
        </ul>
    </div>
	<div id="skiptocontent"></div>
    <div id="contentDiv" class="clearfix">
        <div id="EventsDiv">
            <h3>Events</h3>
            <div class="col-md-4">
                <div class="image">
                    <img src="{{f:80150843}}" alt="Events Image" title="Events Image"/>
                </div>
                <h4>HEADER FOR STORY HERE</h4>
                <p>Lorem ipsum dolor sit amet, consect etur adipiscing elit.Etiam suscipit turpis vel maximus
                    ornare...</p>
            </div>
            <div class="col-md-4">
                <div class="image">
                    <img src="{{f:80150783}}" alt="Events Image" title="Events Image"/>
                </div>
                <h4>HEADER FOR STORY HERE THIS ONE IS A BIT LONGER OR LONGER</h4>
                <p>Lorem ipsum dolor sit amet, consect etur...</p>
            </div>
            <div class="col-md-4">
                <div class="image">
                    <img src="{{f:80150903}}" alt="Events Image" title="Events Image"/>
                </div>
                <h4>HEADER FOR STORY HERE THIS ONE IS A BIT LONGER OR LONGER</h4>
                <p>Lorem ipsum dolor sit amet, consect etur adipiscing elit.Etiam suscipit turpis vel maximus
                    ornare...</p>
            </div>
            <a class="button pull-right" href="#">More Campus Events</a>
        </div>
        <div id="NewsDiv">
            <h3>News</h3>
            <div class="col-md-4">
                <div class="image">
                    <img src="{{f:80150711}}" alt="News Image" title="News Image"/>
                </div>
                <h4>HEADER FOR STORY HERE</h4>
                <p>Lorem ipsum dolor sit amet, consect etur adipiscing elit.Etiam suscipit turpis vel maximus
                    ornare...</p>
            </div>
            <div class="col-md-4">
                <div class="image">
                    <img src="/_resources/images/home/cerritos-home-new-2.jpg" alt="News Image" title="News Image"/>
                </div>
                <h4>HEADER FOR STORY HERE THIS ONE IS A BIT LONGER OR LONGER</h4>
                <p>Lorem ipsum dolor sit amet, consect etur...</p>
            </div>
            <div class="col-md-4">
                <div class="image">
                    <img src="/_resources/images/home/cerritos-home-news-3%20.jpg" alt="News Image" title="News Image"/>
                </div>
                <h4>HEADER FOR STORY HERE THIS ONE IS A BIT LONGER OR LONGER</h4>
                <p>Lorem ipsum dolor sit amet, consect etur adipiscing elit.Etiam suscipit turpis vel maximus
                    ornare...</p>
            </div>
            <a class="button pull-right" href="#">More News</a>
        </div>
    </div>
	<!-- bottom feature -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/bottomfeature.inc')"/>
    </div>
	<!-- footer -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer.inc')"/>
</body>
		</html>	 
	</xsl:template>	

</xsl:stylesheet>



