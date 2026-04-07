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

	<xsl:param name="ou:navigation" />

	<!-- removes unnecessary whitespace between elements. 	-->
	<xsl:strip-space elements="*" />
	
<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no" /> 

<xsl:template match="/">

	<xsl:variable name="Author" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='author']/@content)" />
	<xsl:variable name="Keywords" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='keywords']/@content)"/>
	<xsl:variable name="Description" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='description']/@content)"/>
	<xsl:variable name="Robots" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='robots']/@content)"/>
	<xsl:variable name="Title" select="normalize-space(document/ouc:properties[@label='metadata']/title)" />
	<xsl:variable name="PageCSS" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='PageCSS']/text())" />

	<html lang="en-us">
	<head>		
		<!-- header include -->
		<xsl:copy-of select="ou:includeFile('/_resources/includes/head.inc')"/>
		
     	<!-- title -->
     	<title><xsl:value-of select="$Title" disable-output-escaping="yes" /></title>
		<meta name="author" content="{$Author}" />
        <meta name="keywords" content="{$Keywords}" />
        <meta name="description" content="{$Description}" />
		<meta name="robots" content="{$Robots}" />
		<meta name="copyright" content="Cerritos College"/>
		<meta name="thumbnail" content="https://www.cerritos.edu/public-relations/_includes/images/full-color-100x130.png" />
		<meta property="og:site_name" content="Cerritos College" />
		<meta property="og:title" content="{$Title} - Job Training, New Jobs, Career Training, Trade Careers, New Career" />
		<meta property="og:description" content="{$Description}" />
		<meta property="og:type" content="website" />
		<meta property="og:url" content="https://www.cerritos.edu/" />
		<meta property="og:image" content="https://www.cerritos.edu/_resources/images/common/cerritos-college-logo.svg" />
		<link rel="canonical" href="{concat($domain,'/',$ou:filename)}" />
		<style type="text/css"><xsl:text>&#xA;</xsl:text>
			<xsl:value-of select="$PageCSS" disable-output-escaping="yes"  /><xsl:text>&#xA;</xsl:text>
		</style><xsl:text>&#xA;</xsl:text>
		<xsl:if test="$ou:action = 'pub'">
			<xsl:processing-instruction name="php">
				if (file_exists($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.css.html')) {
				include($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.css.html');
				}
				?</xsl:processing-instruction>
		</xsl:if>
		
		<!-- our google verification key for the home page -->
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />

	<!-- only used for home page -->
	<link rel="stylesheet" href="{{f:80151057}}"/>

	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-tag-manager-body-script.inc')"/>


		
	<script type="application/ld+json">
  {
    "@context": "http://schema.org",
    "@type": "Organization",
    "name": "Cerritos Community College",
    "sameAs" : [
      "https://www.facebook.com/cerritoscollege/",
      "https://twitter.com/cerritoscollege",
      "https://www.youtube.com/channel/UCmQYFzgOkYGPAAfHuNe7mOg",
      "https://www.instagram.com/cerritoscollege/"
    ],
    "image" : "https://www.cerritos.edu/services/_includes/images/resources-2-large.jpg",
	"url" : "https://www.cerritos.edu",
    "logo" : "https://www.cerritos.edu/_resources/images/common/cerritos-college-logo.svg",
    "telephone" : "+15628602451",
    "location": {
      "@type": "Place",
      "geo": {
        "@type": "GeoCoordinates",
        "latitude": "33.8831622",
        "longitude": "-118.0973493"
        }
      },
    "address" : {
      "@type" : "PostalAddress",
      "streetAddress" : "11110 Alondra Blvd",
      "addressLocality" : "Norwalk",
      "addressRegion" : "CA",
      "postalCode" : "90650",
      "addressCountry" : "USA"
      },
    "description" : "Cerritos College is a public comprehensive community college in Norwalk, California, offering degrees and certificates in 87 areas of study in nine divisions.",
    "foundingDate": "1955"
   }
</script>
		
</head>
	 
<body class="home-page">
	<header role="banner">
	<!--######## Global Safety Alert ########
	<xsl:copy-of select="ou:includeFile('/_resources/includes/global-safety-alert.inc')"/>-->
	<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
			<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="'/_resources/includes/global-safety-alert.inc'"/>
			</xsl:call-template>
	
	<!-- 8/31/21 Samuel Chavez: Add secondary alert for extra messages beyond COVID stand-in message -->
			<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="'/_resources/includes/global-safety-alert-2.inc'"/>
			</xsl:call-template>
	

	<!-- header -->
	
		<xsl:copy-of select="ou:includeFile('/_resources/includes/header.inc')"/>
	</header>
<main role="main">
		<div id="photoDivNew" class="flexslider">
				<!-- flexslider slides -->
				<xsl:apply-templates select="document/ouc:div[@label='homesliders']" />
		</div>
	
	
	
	<div id="skiptocontent"></div>
    <div id="contentDiv" class="clearfix">
		
		<div class="container journey">
			<div class="row">
			  <div>
				<h2><strong>Start Your Journey</strong></h2>
				<!--<p class="lead">Find your path to success. If your journey is to transfer to a four-year college, find a new career training program, or earn a certificate or degree, Cerritos College is the right place.
		 </p>-->
			  </div>
			  <div>
				  
				  <div class="row j_items">
					  
					<div class="col-md-4">
						<img src="{{f:80150733}}" alt="Career and technical education student"/>
						<h3 class="j_sub_txt center">Discover something new through our career-training programs</h3>
						<p><a href="{{f:80139690}}" class="button center">Job Training and Education</a></p>
					</div>
					  
					<div class="col-md-4">
						<img src="{{f:80150735}}" alt="Student Major in art"/>
						<h3 class="j_sub_txt center">Choose the right major that leads you to a certificate or degree</h3>
						<p><a href="{{f:80279350}}" class="button center">Learning and Career Pathways</a></p>
					</div>
					  
					  <div class="col-md-4">
						<img src="{{f:80150734}}" alt="Transfer Program Students"/>
						<h3 class="j_sub_txt center">Your dream school is closer than you think</h3>
						<p><a href="{{f:80280184}}" class="button center">Transfer Center</a></p>
					</div>
					  
				  </div>
			</div>
		</div>
  </div>
		
	<div class="news-wrapper">
		<div class="container">
  			<div class="row">
				<div id="NewsDiv">
					<!--<script>
						$("#NewsDiv").load("/scripts/home-news-3.ashx?feed=http://www.cerritos.edu/calendar/rss/home-news.php&amp;cid=50");
					</script><noscript>The calendar requires javascript enabled.</noscript>-->
				    
					
					<xsl:choose>
				        <xsl:when test="$ou:action = 'pub'">
				            <xsl:variable name="news-feed-url"><xsl:choose>
				                <xsl:when test="/document/ouc:properties[@label='config']/parameter[@name='news-feed-url']/text() != ''"><xsl:value-of select="/document/ouc:properties[@label='config']/parameter[@name='news-feed-url']" /></xsl:when>
				                <xsl:otherwise>https://www.cerritos.edu/_resources/rss/newsroom.xml</xsl:otherwise>
				            </xsl:choose></xsl:variable>
				            <script>
				                $("#NewsDiv").load("/_resources/php/wnl/calendar-home-news-display-3.php?feed=<xsl:value-of select="$news-feed-url" />&amp;num_items=3");
				            </script><noscript>The calendar requires javascript enabled.</noscript>
				        </xsl:when>
				        <xsl:otherwise>
				            <div class="col-md-12">
				                <div class="event postcard-left" style="clear: both;display: table;margin-bottom: 15px;position: relative;">
				                    <div class="event-text" style="color: #555555;font-size: 16px;line-height: 20px;position: relative;/*! top: -10px; */vertical-align: bottom;">
				                        <h2>
				                            News items will be displayed on publish.
				                        </h2>
				                    </div>
				                </div>
				            </div>
				        </xsl:otherwise>
				    </xsl:choose>
					
					
				    <!--
<xsl:choose>
				        <xsl:when test="$ou:action = 'pub'">
				            <xsl:variable name="news-feed-url"><xsl:choose>
				                <xsl:when test="/document/ouc:properties[@label='config']/parameter[@name='news-feed-url']/text() != ''"><xsl:value-of select="/document/ouc:properties[@label='config']/parameter[@name='news-feed-url']" /></xsl:when>
				                <xsl:otherwise>http://www.cerritos.edu/calendar/rss/feed.php</xsl:otherwise>
				            </xsl:choose></xsl:variable>
				            <script>
				                $("#NewsDiv").load("/_resources/php/wnl/calendar-home-news-display.php?feed=<xsl:value-of select="$news-feed-url" />&amp;num_items=3");
				            </script><noscript>The calendar requires javascript enabled.</noscript>
				        </xsl:when>
				        <xsl:otherwise>
				            <div class="col-md-12">
				                <div class="event postcard-left" style="clear: both;display: table;margin-bottom: 15px;position: relative;">
				                    <div class="event-text" style="color: #555555;font-size: 16px;line-height: 20px;position: relative;/*! top: -10px; */vertical-align: bottom;">
				                        <h4>
				                            News items will be displayed on publish.
				                        </h4>
				                    </div>
				                </div>
				            </div>
				        </xsl:otherwise>
				    </xsl:choose>
-->
        		</div>
	  		</div>
		</div>
	</div>
		
  		<div class="container">
			<div class="row">
			    <div id="EventsDiv">
			        <!--<script>
			            $("#EventsDiv").load("/scripts/home-events-4.ashx?feed=http://www.cerritos.edu/calendar/rss/home-news.php&amp;cid=51");
			            </script><noscript>The calendar requires javascript enabled.</noscript>-->
			        
<!-- 			        <xsl:choose>
			            <xsl:when test="$ou:action = 'pub'">
			                <xsl:variable name="calendar-feed-url"><xsl:choose>
			                    <xsl:when test="/document/ouc:properties[@label='config']/parameter[@name='calendar-feed-url']/text() != ''"><xsl:value-of select="/document/ouc:properties[@label='config']/parameter[@name='calendar-feed-url']" /></xsl:when>
			                    <xsl:otherwise>https://www.cerritos.edu/calendar/rss/feed.php</xsl:otherwise>
			                </xsl:choose></xsl:variable>
			                <script>
			                    $("#EventsDiv").load("/_resources/php/wnl/calendar-home-events-display.php?feed=<xsl:value-of select="$calendar-feed-url" />&amp;num_items=3");
			                </script><noscript>The calendar requires javascript enabled.</noscript>
			            </xsl:when>
			            <xsl:otherwise>
			                <div class="col-md-12">
			                    <div class="event postcard-left" style="clear: both;display: table;margin-bottom: 15px;position: relative;">
			                        <div class="event-text" style="color: #555555;font-size: 16px;line-height: 20px;position: relative;/*! top: -10px; */vertical-align: bottom;">
			                            <h2>
			                                Calendar items will be displayed on publish.
			                            </h2>
			                        </div>
			                    </div>
			                </div>
			            </xsl:otherwise>
			        </xsl:choose> -->
					<xsl:choose>
									<xsl:when test="$ou:action = 'pub'">
										<xsl:variable name="formatted-feed-url" select="replace(/document/ouc:properties[@label='config']/parameter[@name='full-rss-feed'], '&amp;', '%26')" />
										<script type="text/javascript"> <!--src="/_resources/js/Homepage-EventsDiv-Script.js"-->
											 $("#EventsDiv").load("/_resources/php/wnl/calendar-home-events-display-omni-dev-only.php?feed=<xsl:value-of select="$formatted-feed-url" />&amp;num_items=3"); 
										</script><noscript>The calendar requires javascript enabled.</noscript>
									</xsl:when>
									<xsl:otherwise>
										<div class="col-md-12">
											<div class="event postcard-left" style="clear: both;display: table;margin-bottom: 15px;position: relative;">
												<div class="event-text" style="color: #555555;font-size: 16px;line-height: 20px;position: relative;/*! top: -10px; */vertical-align: bottom;">
													<h2>
														Events will be displayed on publish.
													</h2>
												</div>
											</div>
										</div>
									</xsl:otherwise>
								</xsl:choose>
			    </div>
			</div>
		</div>

		
		 
		
        
    </div>
	<!-- bottom feature -->
		<xsl:apply-templates select="document/ouc:div[@label='bottomfeature']" />
</main>
<!-- footer -->
<footer role="contentinfo">
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer.inc')"/>
	
	<!-- Cerritos direct edit button. 3 params: site, dirname, filename -->
	<div id="lastUpdate" >
		<div class="container">
			<xsl:copy-of select="ou:includeFile('/_resources/includes/footer-bottom.inc')"/>
		<xsl:call-template name="CerritosDirectEditButton">
			<xsl:with-param name="site1" select="$ou:site" />
			<xsl:with-param name="dirname1" select="$ou:dirname" />
			<xsl:with-param name="filename1" select="$ou:filename" />
		</xsl:call-template>
		</div>
	</div>
	<!-- only used for home page - moved to footer 10/27/2023 -->
    <script src="{{f:80151147}}"></script>
	<script src="{{f:80151160}}"></script>
	<noscript>Your browser does not support JavaScript!</noscript>
	<script src="{{f:80151167}}"></script>
	<noscript>Your browser does not support JavaScript!</noscript>
	 <xsl:if test="$ou:action = 'pub'">
		 <xsl:processing-instruction name="php">
			 if (file_exists($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.alerts.html')) {
			 include($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.alerts.html');
			 }
			 ?</xsl:processing-instruction>
	</xsl:if>
</footer>
</body>
		</html>	 
	</xsl:template>	

</xsl:stylesheet>