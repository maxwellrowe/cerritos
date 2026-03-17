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
	
<!--### this style sheet presumes a flat directory structure
where each web is listed in the root. 
each web folder has 
its own _resources folder storing the css and nav includes, 
new files and new images. existing images before migration
are located in /uploads/[web] for public files  ###-->
	
	<xsl:import href="functions-workshop.xsl" />
	<xsl:import href="ou-variables.xsl" />
	<xsl:import href="template-matches.xsl" />
	<xsl:import href="ou-forms.xsl" />
	<xsl:import href="accessibility-link-icons.xsl" />
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
	<xsl:variable name="TopNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='TopNav']/text())" />
	<xsl:variable name="BottomNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='BottomNav']/text())" />
	<xsl:variable name="LeftNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='LeftNav']/text())" />
	<xsl:variable name="RightNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='RightNav']/text())" />
	<xsl:variable name="Title" select="document/ouc:properties[@label='metadata']/title" />

	<html lang="en-us">
      <head>
        <meta http-equiv="X-UA-Compatible" content="text/html;IE=edge" />
        <meta http-equiv="cache-control" content="text/html;no-cache" />
        <meta http-equiv="expires" content="text/html;-1" />
        <meta http-equiv="pragma" content="text/html;no-cache" />
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
        <meta http-equiv="Content-Script-Type" content="text/html;text/JavaScript" />
        <meta http-equiv="Content-Style-Type" content="text/html;text/css" />
        <meta name="viewport" content="width=device-width,user-scalable = yes,initial-scale = 1.0" />
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
		<meta name="robots" content="{$Robots}" />
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />
        <link rel="shortcut icon" href="/favicon.ico" type="image/x-icon" />
        <xsl:comment> Bootstrap core CSS </xsl:comment>
		<link href="*** Broken Link ***" rel="stylesheet" type="text/css" media="all" />
        <xsl:comment> Custom styles for this template </xsl:comment>
        <link href="*** Broken Link ***" rel="stylesheet" type="text/css" media="all" />
        <xsl:comment> IE10 viewport hack for Surface/desktop Windows 8 bug </xsl:comment><xsl:text>&#xA;</xsl:text>
        <script src="{{f:80151045}}" type="text/javascript">
          //comment
        </script>

		<xsl:if test="lower-case($firstdir)!='/secure'">
        <xsl:comment> HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries </xsl:comment>
        <xsl:comment> <![CDATA[[if lt IE 9]>
<script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
<script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
<![endif]]]> </xsl:comment><xsl:text>&#xA;</xsl:text>
			</xsl:if>
        <link rel="stylesheet" type="text/css" media="all" href="*** Broken Link ***" /><xsl:text>&#xA;</xsl:text>
        <script type="text/javascript" src="/_resources/bootstrap/js/jquery-ui.min.js">
          //comment
        </script>
		  <script type="text/javascript" src="/_resources/js/top_level_2014.js">
          //comment
        </script>
        <script type="text/javascript" src="/_resources/swfobject/swfobject.js">
          //comment
        </script>
        <script type="text/javascript" src="/_resources/js/calendar.js">
          //comment
        </script>
        <script type="text/javascript" src="/_resources/js/calendar_condensed.js">
          //comment
        </script>
        <script type="text/javascript" src="/_resources/js/academic_calendar.js">
          //comment
        </script><xsl:text>&#xA;</xsl:text>
        <link href="*** Broken Link ***" rel="stylesheet" type="text/css" media="all" />
		  <link href="/_resources/css/css3_tables_min.css" rel="stylesheet" type="text/css" media="all" />
        <xsl:comment><![CDATA[[if lt IE 8]>
<link href="/_resources/css/css2_tables_min.css" rel="stylesheet" type="text/css" media="all" />
        <![endif]]]></xsl:comment>
	<xsl:choose>
	<xsl:when test="contains($WebCss, '/')">
		<link href="{normalize-space($WebCss)}" rel="stylesheet" type="text/css" media="all" /><xsl:text>&#xA;</xsl:text>
	</xsl:when>
		<xsl:otherwise>
			<link href="{concat($firstdir,'/_includes/assets/',normalize-space($WebCss))}" rel="stylesheet" type="text/css" media="all" /><xsl:text>&#xA;</xsl:text>
		</xsl:otherwise>
	</xsl:choose>

		 <xsl:copy-of select="ou:includeFile('/_resources/includes/google-tag-manager-body-script.inc')"/>


      <xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics-cerritostrainsu.inc')"/>
        <xsl:comment> Bootstrap core JavaScript placed here so pages load faster </xsl:comment><xsl:text>&#xA;</xsl:text>
        
        <script src="/_resources/bootstrap/js/jquery1.11.1.min.js">
          //comment
        </script>
        <script src="/_resources/bootstrap/js/bootstrap.min.js" type="text/javascript">
          //comment
        </script>
        
        
      </head>
		 <body>
			 <noscript>Your browser does not support JavaScript!</noscript>
        <xsl:comment> glow </xsl:comment>
        <div class="box-shadow-page">
          <xsl:comment> nav </xsl:comment>
          <div id="navigationDiv" class="container cc-inverse">
            <div id="global-nav-div" class="navbar-collapse collapse" role="navigation" aria-label="global-nav-div">
              <ul class="nav-cc">
                <li class="sr-only">
                  <a href="#maincontent" class="AccessLink">Skip Navigation</a>
                </li>
                <li>
                  <a href="*** Broken Link ***">
                    <img src="*** Broken Link ***" class="goButton" alt="Cerritos home" />
                  </a>
                  <li>
                    <form name="KeyWordSearch" method="get" action="http://www.cerritos.edu/default/abc-search.aspx" role="search">
                      <label for="qry">
                        <span class="sr-only">Search</span>
                        <input name="qry" type="text" id="qry" title="Search" value="Search" onfocus="this.value=''" class="FormFieldSearch" />&#160;</label><input type="image" name="searchButton2" id="searchButton2" title="Submit Search" class="goButton desktopDisplay" src="{{f:80164132}}" alt="Submit Search" />
                    </form>
                  </li>
                  <li>
                    <a href="http://www.cerritos.edu/default/abc-help.aspx" class="AccessLink" role="link">Help</a>
                  </li>
                  <li>
                    <a href="http://www.cerritos.edu/default/abc-search.aspx">ABC Index</a>
                  </li>
                  <li>
                    <a href="*** Broken Link ***">
                      <img alt="wheelchair" src="*** Broken Link ***" class="goButton" />
                    </a>
                  </li>
                  <li>
                    <ul id="translations">
                      <li>
                        <a href="http://translate.google.com/translate?%3Fhl%3Den&amp;hl=en&amp;langpair=en|es&amp;tbb=1&amp;ie=utf-8&amp;u=http://cms.cerritos.edu{$ou:path}" class="AccessLink">Español</a>
                      </li>
                      <li>
                        <a href="http://translate.google.com/translate?%3Fhl%3Den&amp;hl=en&amp;langpair=en|tl&amp;tbb=1&amp;ie=utf-8&amp;u=http://cms.cerritos.edu{$ou:path}" class="AccessLink">Tagalog</a>
                      </li>
                      <li>
                        <a href="http://translate.google.com/translate?%3Fhl%3Den&amp;hl=en&amp;langpair=en|vi-CN&amp;tbb=1&amp;ie=utf-8&amp;u=http://cms.cerritos.edu{$ou:path}" class="AccessLink">Việt</a>
                      </li>
                      <li>
                        <a href="http://translate.google.com/translate?%3Fhl%3Den&amp;hl=en&amp;langpair=en|ko&amp;tbb=1&amp;ie=utf-8&amp;u=http://cms.cerritos.edu{$ou:path}" class="AccessLink">한국</a>
                      </li>
                      <li>
                        <a href="http://translate.google.com/translate?%3Fhl%3Den&amp;hl=en&amp;langpair=en|zh-CN&amp;tbb=1&amp;ie=utf-8&amp;u=http://cms.cerritos.edu{$ou:path}" class="AccessLink">中国版</a>
                      </li>
                    </ul>
                  </li>
                </li>
              </ul>
            </div>
          </div>
          <xsl:comment> header </xsl:comment>
          <div id="headerDiv" class="container cc-default" role="banner">
            <img src="*** Broken Link ***" alt="Cerritos College" class="cclogo" />
            <button type="button" class="navbar-toggle nav-button" data-toggle="collapse" data-target="#global-nav-div">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <h1 class="sr-only">
              <a href="*** Broken Link ***">Cerritos College <xsl:value-of select="document/ouc:properties[@label='metadata']/title" disable-output-escaping="yes" /></a>
            </h1>
			  <h2 class="h2-header-text"><xsl:value-of select="document/ouc:properties[@label='metadata']/title" disable-output-escaping="yes" /></h2>
            <div id="logoNavDiv">
              <a href="*** Broken Link ***">
                <img id="logoNavImg" src="{{f:80150582}}" alt="Cerritos College Norwalk, CA" title="Cerritos College Norwalk, CA" />
              </a>
            </div>
          </div>
          <div id="mainDiv" class="container ">
            <xsl:comment> main row </xsl:comment>

			  
		<!-- choose columns #####-->
			  <xsl:choose>
				  <!-- LeftAndMainContent -->
				  <xsl:when test="document/ouc:properties[@label='config']/parameter[@name='Layout']/option[@selected='true' and @value='left-main']">
					  	<xsl:call-template name="LeftAndMainContent"/>
					 
				  </xsl:when>
				  <!-- MainAndRightContent -->
				  <xsl:when test="document/ouc:properties[@label='config']/parameter[@name='Layout']/option[@selected='true' and @value='main-right']">
					  		<xsl:call-template name="MainAndRightContent"/>
				  </xsl:when>
				  <!-- LeftMainRightContent -->
				  <xsl:when test="document/ouc:properties[@label='config']/parameter[@name='Layout']/option[@selected='true' and @value = 'left-main-right']">
					  <xsl:call-template name="LeftMainRightContent"/>
				  </xsl:when>
				  <xsl:otherwise>
				  		<xsl:call-template name="MainContent"/>
				  </xsl:otherwise>
			  </xsl:choose>
		<!-- end choose columns #####-->
			  

		</div>
          <xsl:comment> end page container  </xsl:comment>
			
			<div id="bottomMenuDiv" class="container" role="navigation" aria-label="bottom-nav-div">
        <div class="horizontal-menu-decor-bar">&nbsp;</div><div>&nbsp;<a href="*** Broken Link ***">Cerritos College</a> - <a href="*** Broken Link ***">Economic Development</a> ©</div><p><script type="text/javascript"><![CDATA[
var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
]]></script><script type="text/javascript"><![CDATA[
try {
var pageTracker = _gat._getTracker("UA-15119850-1");
pageTracker._trackPageview();
} catch(err) {}]]></script></p></div>
			
			<!--##### footer #####-->
          <xsl:comment> footer  </xsl:comment>
          <div id="footerDiv" class="container center" role="contentinfo">
            Cerritos College, <a href="http://maps.google.com/maps?q=11110+Alondra+Boulevard,+Norwalk,+CA&amp;hl=en&amp;sll=37.269174,-119.306607&amp;sspn=28.513119,15.358887&amp;oq=11110+alondra&amp;hnear=11110+Alondra+Blvd,+Norwalk,+Los+Angeles,+California+90650&amp;t=m&amp;z=17">11110 Alondra Blvd., Norwalk, CA 90650</a> (562) 860-2451 | <a href="mailto:community@Cerritos.edu">Contact Us</a> 
          </div>
          <xsl:comment> end footer  </xsl:comment>
        </div>
        <xsl:comment> end glow  </xsl:comment>
        <xsl:comment> disclaimer </xsl:comment>
        <div id="DisclaimerDiv" class="container-disclaimer">
          <ul class=" nav-cc-footer center">
			<li>
              <a class="DisclaimerLink" href="http://www.cerritos.edu/sitemap">Site Map</a>
            </li>
			<li>
              <a class="DisclaimerLink" href="http://www.cerritos.edu/report508/">Report Accessibility Issues</a>
            </li>
            <li>
              <a class="DisclaimerLink" href="*** Broken Link ***">Disclaimer</a>
            </li>
            <li>
              <a class="DisclaimerLink" href="*** Broken Link ***">Web Administrator</a>
            </li>
            <li>
              <a class="DisclaimerLink" href="https://get.adobe.com/reader/">Download Adobe Reader</a>
            </li>
		<li><!-- Cerritos direct edit button. 3 params: site, dirname, filename -->
		<xsl:call-template name="CerritosDirectEditButton">
			<xsl:with-param name="site1" select="$ou:site" />
			<xsl:with-param name="dirname1" select="$ou:dirname" />
			<xsl:with-param name="filename1" select="$ou:filename" />
		</xsl:call-template>
		</li>

</ul>
        </div>
			 <xsl:comment> end disclaimer </xsl:comment>
		      </body>
		</html>	 
	</xsl:template>	
			
	<!--################## templates ################# -->
	
<xsl:template name="LeftAndMainContent">
	 <xsl:variable name="LeftNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='LeftNav']/text())" />
	<xsl:variable name="Title" select="document/ouc:properties[@label='metadata']/title" />
         <!-- left and body columns -->
             <div id="contentDiv" class="row">
               <xsl:comment> left col </xsl:comment>
              <div class="col-md-3" role="navigation" aria-label="left-nav-div">
                <div class="pageletSmall">
                  <div class="sidebar-decor-bar">&#160;</div>
                  <xsl:comment> left nav links </xsl:comment>
				<!-- include left nav -->
					<xsl:if test="string-length($LeftNav)>0 and $LeftNav!='none'">  
					<div id="menuLeft">
						<!-- added for ticket #38482, used function from file that does the same as above logic. -->
						<xsl:call-template name="unparsed-include-file">
							<xsl:with-param name="path" select="$LeftNav"/>
						</xsl:call-template>
					</div>
					</xsl:if>
                </div>
              </div>
               <xsl:comment> end left col </xsl:comment>
                <xsl:comment> right col </xsl:comment>
              <div class="col-md-9-right">
                <div id="maincontent" class="pageletMedium-right" role="main">

                  <xsl:comment> heading </xsl:comment>
					<!-- page heading 
                    <h2 class="pageletHeadingMedium">
						<xsl:value-of select="$Title" disable-output-escaping="yes" />
					</h2> -->
                  <xsl:comment> body content </xsl:comment>
					<!-- body column -->
					<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
                </div>
              </div>
               <xsl:comment> end rt col </xsl:comment>
            </div>
            <xsl:comment> end main row </xsl:comment>
  </xsl:template>
	
	
	<xsl:template name="LeftMainRightContent">
         <!-- left body right columns -->
		<xsl:variable name="LeftNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='LeftNav']/text())" />
		<xsl:variable name="RightNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='RightNav']/text())" />
		<xsl:variable name="Title" select="document/ouc:properties[@label='metadata']/title" />
               <xsl:comment> left col </xsl:comment>
               <div class="col-md-3-left-right" role="navigation" aria-label="left-nav-div">
                <div class="pageletSmall">
                  <div class="sidebar-decor-bar">&#160;</div>
                  <xsl:comment> left nav links </xsl:comment>
				<!-- include left nav -->
					<xsl:if test="string-length($LeftNav)>0 and $LeftNav!='none'">  
					<ouc:div>
					<xsl:choose>
						<xsl:when test="($ou:action='edt')">
							<xsl:comment> com.omniupdate.div label="LeftNav" button-text="Left Menu" button="702" group="Everyone" toolbar="Menu" path="<xsl:value-of select="$LeftNav"/>" </xsl:comment>
						</xsl:when>
						<xsl:otherwise>
						<xsl:copy-of select="ou:includeFile($LeftNav)"/>
						</xsl:otherwise>
					</xsl:choose>
					</ouc:div>
					</xsl:if>
                </div>
              </div>
               <xsl:comment> end left col </xsl:comment>
                <xsl:comment> main col </xsl:comment>
               <div class="col-md-6-middle">
          <div id="maincontent" class="pageletMedium-middle" role="main">

                  <xsl:comment> heading </xsl:comment>
					<!-- page heading -->
                    <h2 class="pageletHeadingMedium">
						<xsl:value-of select="$Title" disable-output-escaping="yes" />
					</h2>
                  <xsl:comment> body content </xsl:comment>
					<!-- body column -->
					<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
                </div>
              </div>
               <xsl:comment> end main col </xsl:comment>
               <!-- right col -->
		<xsl:comment> right col </xsl:comment>
<div class="col-md-3-left-right" role="navigation" aria-label="right-nav-div">
          <div class="pageletSmall">
            <div class="sidebar-decor-bar">&#160;</div>
<!-- right nav links -->
			   <xsl:if test="string-length($RightNav) >0 and $RightNav !='none'">  
			  		<ouc:div>
					<xsl:choose>
						<xsl:when test="($ou:action='edt')">
							<xsl:comment> com.omniupdate.div label="RightNav" button-text="Right Menu" button="702" group="Everyone" toolbar="Menu" path="<xsl:value-of select="$RightNav"/>" </xsl:comment>
						</xsl:when>
						<xsl:otherwise>
						<xsl:copy-of select="ou:includeFile($RightNav)"/>
						</xsl:otherwise>
					</xsl:choose>
					</ouc:div>
			  </xsl:if>
	</div>
        </div>
<!-- end right col -->
		<xsl:comment> end right col </xsl:comment>
            <xsl:comment> end main row </xsl:comment>
  </xsl:template>
	
	
	<xsl:template name="MainAndRightContent">
         <!-- body and right columns -->
		<xsl:variable name="RightNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='RightNav']/text())" />	
		<xsl:variable name="Title" select="document/ouc:properties[@label='metadata']/title" />
                <xsl:comment> main col </xsl:comment>
               <div class="col-md-9-left">
          <div id="maincontent" class="pageletMedium-left" role="main">

                  <xsl:comment> heading </xsl:comment>
					<!-- page heading -->
                    <h2 class="pageletHeadingMedium">
						<xsl:value-of select="$Title" disable-output-escaping="yes" />
					</h2>
                  <xsl:comment> body content </xsl:comment>
					<!-- body column -->
					<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
                </div>
              </div>
             <xsl:comment> end main col </xsl:comment>
			<xsl:comment> right col </xsl:comment>
               <div class="col-md-3" role="navigation" aria-label="right-nav-div">
                <div class="pageletSmall">
                  <div class="sidebar-decor-bar">&#160;</div>
                  <xsl:comment> right nav links </xsl:comment>
				<!-- include right nav -->
					<xsl:if test="string-length($RightNav) >0 and $RightNav !='none'">  
					<ouc:div>
					<xsl:choose>
						<xsl:when test="($ou:action='edt')">
							<xsl:comment> com.omniupdate.div label="RightNav" button-text="Right Menu" button="702" group="Everyone" toolbar="Menu" path="<xsl:value-of select="$RightNav"/>" </xsl:comment>
						</xsl:when>
						<xsl:otherwise>
						<xsl:copy-of select="ou:includeFile($RightNav)"/>
						</xsl:otherwise>
					</xsl:choose>
					</ouc:div>
					</xsl:if>
               </div>
               <xsl:comment> end right col </xsl:comment>
            </div>
            <xsl:comment> end main row </xsl:comment>
  </xsl:template>
	

	<xsl:template name="MainContent">
         <!-- single column -->
		<xsl:variable name="Title" select="document/ouc:properties[@label='metadata']/title" />
                <xsl:comment> single col </xsl:comment>
              <div class="col-md-12">
                <div id="maincontent" class="pageletMedium-full" role="main">

                  <xsl:comment> heading </xsl:comment>
					<!-- page heading -->
                    <h2 class="pageletHeadingMedium">
						<xsl:value-of select="$Title" disable-output-escaping="yes" />
					</h2>
                  <xsl:comment> body content </xsl:comment>
					<!-- body column -->
					<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
                </div>
              </div>   
            <xsl:comment> end main row </xsl:comment>
	</xsl:template>
	
	
	
</xsl:stylesheet>



