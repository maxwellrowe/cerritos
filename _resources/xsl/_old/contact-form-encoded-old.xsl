<?xml version="1.0" encoding="UTF-8" ?>
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
	
	<xsl:import href="E:/omniupdate/staging/oucampus/2017/www-cerritos-edu/_resources_2016/xsl/functions-workshop.xsl" />
	<xsl:import href="E:/omniupdate/staging/oucampus/2017/www-cerritos-edu/_resources_2016/xsl/accessibility-all.xsl" />
	<xsl:import href="E:/omniupdate/staging/oucampus/2017/www-cerritos-edu/_resources_2016/xsl/ou-variables.xsl" />
	<xsl:import href="E:/omniupdate/staging/oucampus/2017/www-cerritos-edu/_resources_2016/xsl/template-matches.xsl" />
	<xsl:import href="E:/omniupdate/staging/oucampus/2017/www-cerritos-edu/_resources_2016/xsl/ou-forms.xsl" />
	<xsl:param name="ou:navigation" />

	<!-- removes unnecessary whitespace between elements. 	-->
	<xsl:strip-space elements="*" />
	
<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no" /> 

<xsl:template match="/">

	<xsl:variable name="Author" select="document/ouc:properties[@label='metadata']/meta[@name='author']/@content" />
	<xsl:variable name="Keywords" select="document/ouc:properties[@label='metadata']/meta[@name='keywords']/@content"/>
	<xsl:variable name="Description" select="document/ouc:properties[@label='metadata']/meta[@name='description']/@content"/>
	<xsl:variable name="Robots" select="document/ouc:properties[@label='metadata']/meta[@name='robots']/@content"/>
	<xsl:variable name="WebCss" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='WebCss']/text())" />
	<xsl:variable name="LeftNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='LeftNav']/text())" />
	<xsl:variable name="Title" select="document/ouc:properties[@label='metadata']/title" />
	<xsl:variable name="TrackingCode" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='TrackingCode']/text())" />
	
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
		<link href="/_resources_2016/bootstrap/css/bootstrap-copy.css" rel="stylesheet" type="text/css" media="all"/>
        <xsl:comment> Custom styles for this template </xsl:comment>
      	<link href="/_resources_2016/css/html5_2014_template.css" rel="stylesheet" type="text/css" media="all"/>
        <xsl:comment> IE10 viewport hack for Surface/desktop Windows 8 bug </xsl:comment><xsl:text>&#xA;</xsl:text>
        <script src="/_resources_2016/bootstrap/js/ie10-viewport-bug-workaround.js" type="text/javascript">
          //comment
        </script>

		<xsl:if test="lower-case($firstdir)!='/secure'">
        <xsl:comment> HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries </xsl:comment>
        <xsl:comment> <![CDATA[[if lt IE 9]>
<script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
<script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
<![endif]]]> </xsl:comment><xsl:text>&#xA;</xsl:text>
			</xsl:if>
       <link rel="stylesheet" type="text/css" media="all" href="/_resources_2016/bootstrap/css/jquery-ui.css" /><xsl:text>&#xA;</xsl:text>
        <script type="text/javascript" src="/_resources_2016/bootstrap/js/jquery-ui.min.js">
          //comment
        </script>
		  <script type="text/javascript" src="/_resources_2016/js/top_level_2014.js">
          //comment
        </script>
        <script type="text/javascript" src="/_resources_2016/swfobject/swfobject.js">
          //comment
        </script>
        <script type="text/javascript" src="/_resources_2016/js/calendar.js">
          //comment
        </script>
        <script type="text/javascript" src="/_resources_2016/js/calendar_condensed.js">
          //comment
        </script>
        <script type="text/javascript" src="/_resources_2016/js/academic_calendar.js">
          //comment
        </script><xsl:text>&#xA;</xsl:text>
        <link href="*** Broken Link ***" rel="stylesheet" type="text/css" media="all" />
		  <link href="/_resources_2016/css/css3_tables_min.css" rel="stylesheet" type="text/css" media="all" />
        <xsl:comment><![CDATA[[if lt IE 8]>
<link href="/_resources_2016/css/css2_tables_min.css" rel="stylesheet" type="text/css" media="all" />
        <![endif]]]></xsl:comment>
	<xsl:choose>
	<xsl:when test="contains($WebCss, '/')">
		<link href="{normalize-space($WebCss)}" rel="stylesheet" type="text/css" media="all" /><xsl:text>&#xA;</xsl:text>
	</xsl:when>
		<xsl:otherwise>
			<link href="{concat($firstdir,'/_includes/assets/',normalize-space($WebCss))}" rel="stylesheet" type="text/css" media="all" /><xsl:text>&#xA;</xsl:text>
		</xsl:otherwise>
	</xsl:choose>

		 <xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics.inc')"/>
      <!-- which additional tracking code to include-->
			<!-- removes the / from the dirname for the choose statement below -->
	<xsl:variable name="firstdirtest" select="substring(concat('/',tokenize($dirname,'/')[2]),2)" />  
		  
	<xsl:choose>
	<xsl:when test="lower-case($firstdirtest) = 'cerritostrainsu'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-cerritostrainsu.inc')"/>
	</xsl:when>
	<xsl:when test="lower-case($firstdirtest) = 'counseling'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-counseling.inc')"/>
	</xsl:when>
	<xsl:when test="lower-case($firstdirtest) = 'music'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-music.inc')"/>
	</xsl:when>
		<xsl:when test="lower-case($firstdirtest) = 'professional-relations'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-prof-rel.inc')"/>
	</xsl:when>
		<xsl:when test="lower-case($firstdirtest) = 'teachertrac'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-teachertrac.inc')"/>
	</xsl:when>
		<xsl:when test="lower-case($firstdirtest) = 'theater'">
		<xsl:copy-of select="ou:includeFile('/_resources_2016/includes/google-analytics-theater.inc')"/>
	</xsl:when>
	</xsl:choose>
        <xsl:comment> Bootstrap core JavaScript placed here so pages load faster </xsl:comment><xsl:text>&#xA;</xsl:text>
        
        <script src="/_resources_2016/bootstrap/js/jquery1.11.1.min.js">
          //comment
        </script>
        <script src="/_resources_2016/bootstrap/js/bootstrap.min.js" type="text/javascript">
          //comment
        </script>
        
		  <xsl:if test="string-length($TrackingCode) > 0 ">  		  
			<xsl:copy-of select="ou:includeFile($TrackingCode)"/>
		 </xsl:if>
        
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
                    <img src="/_resources_2016/images/home-icon-16x.gif" class="goButton" alt="Cerritos home" />
                  </a>
                  <li>
                    <form name="KeyWordSearch" method="get" action="http://www.cerritos.edu/default/abc-search.htm" role="search">
                      <label for="q">
                        <span class="sr-only">Search</span>
                        <input name="q" type="text" id="q" title="Search" value="Search" onfocus="this.value=''" class="FormFieldSearch" />&#160;</label><input type="image" name="searchButton2" id="searchButton2" title="Submit Search" class="goButton desktopDisplay" src="/_resources_2016/images/magnifying-glass-16.png" alt="Submit Search" />
                    </form>
                  </li>
                  <li>
                    <a href="*** Broken Link ***" class="AccessLink" role="link">Help</a>
                  </li>
                  <li>
                    <a href="*** Broken Link ***">ABC Index</a>
                  </li>
                  <li>
                    <a href="*** Broken Link ***">
                      <img alt="wheelchair" src="/_resources_2016/images/wheelchair_icon16h.png" class="goButton" />
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
            <img src="/_resources_2016/images/CerritosCollegeWordMark-260-eee.png" alt="Cerritos College" class="cclogo" />
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
                <img id="logoNavImg" src="/_resources_2016/images/1x1t.gif" alt="Cerritos College Norwalk, CA" title="Cerritos College Norwalk, CA" />
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
				  <xsl:otherwise>
				  		<xsl:call-template name="MainContent"/>
				  </xsl:otherwise>
			  </xsl:choose>
		<!-- end choose columns #####-->
			  
		</div>
          <xsl:comment> end page container  </xsl:comment>
			
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
<li>Last Update: <a href="javascript:void(0);" onclick="popupWarningEdit('http://oucampus.cerritos.edu/10?skin=oucampus&amp;account=Cerritos&amp;site=cms-cerritos-edu&amp;action=de&amp;path={concat($ou:dirname,'/',ou:replaceFileExtension($ou:filename,'pcf'))}');"><xsl:value-of select="ou:dateFromDateTime($ou:modified,'/')" /></a></li>

</ul>
        </div>
			 <xsl:comment> end disclaimer </xsl:comment>
		      </body>
		</html>	 
	</xsl:template>	
			
	<!--################## templates ################# -->
	
<xsl:template name="LeftAndMainContent">
	<xsl:variable name="Recipient1" select="document/ouc:properties[@label='config']/parameter[@name='Recipient1']/text()" />
		<xsl:variable name="Recipient2" select="document/ouc:properties[@label='config']/parameter[@name='Recipient2']/text()" />
		<xsl:variable name="Recipient3" select="document/ouc:properties[@label='config']/parameter[@name='Recipient3']/text()" />
		<xsl:variable name="Recipient4" select="document/ouc:properties[@label='config']/parameter[@name='Recipient4']/text()" />
		<xsl:variable name="Recipient5" select="document/ouc:properties[@label='config']/parameter[@name='Recipient5']/text()" />
		<xsl:variable name="Recipient6" select="document/ouc:properties[@label='config']/parameter[@name='Recipient6']/text()" />
		<xsl:variable name="ConfirmationPage" select="document/ouc:properties[@label='config']/parameter[@name='ConfirmationPage']/text()" />
		<xsl:variable name="Subject" select="document/ouc:properties[@label='config']/parameter[@name='Subject']/text()" />
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
					<ouc:div>
					<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
						<xsl:call-template name="unparsed-include-file">
							<xsl:with-param name="path" select="$LeftNav"/>
						</xsl:call-template>
					</ouc:div>
						</xsl:if>
                </div>
              </div>
               <xsl:comment> end left col </xsl:comment>
                <xsl:comment> right col </xsl:comment>
              <div class="col-md-9-right">
                <div id="maincontent" class="pageletMedium-right" role="main">
					 <!-- Breadcrumbs -->
                 	<xsl:call-template name="Breadcrumbs"/>
                  <!-- end Breadcrumbs -->
                  <xsl:comment> heading </xsl:comment>
					<!-- page heading -->
                    <h2 class="pageletHeadingMedium">
						<xsl:value-of select="$Title" disable-output-escaping="yes" />
					</h2>
                  <xsl:comment> body content </xsl:comment>
					<!-- body column -->
					<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
										<div>

<form id="ContactForm" action="http://www.cerritos.edu/scripts/FormToMail.aspx" method="post" name="ContactForm">
<p><!-- EMAIL RECIPIENTS==YOU MUST CHANGE THESE --><input name="_recipients" type="hidden" value="{ou:processEmails($Recipient1,$Recipient2,$Recipient3,$Recipient4,$Recipient5,$Recipient6)}" /> <!-- REQUIRED FIELDS --><input name="_requiredFields" type="hidden" value="Name,Email,Request" /> <!-- reply to address taken from a form field (choose _replyToField or _replyTo) --><input name="_replyToField" type="hidden" value="Email" /> <!-- EMAIL SUBJECT --><input name="_subject" type="hidden" value="{$Subject}" /> <!-- ADD THE DATE AND TIME (OPTIONAL==CHOOSE ONLY ONE, true or false) --><input name="_DateAndTime" type="hidden" value="true" /> <input name="_envars" type="hidden" value="HTTP_REFERER" />  <!-- CONFIRMATION REDIRECT --> <input name="_redirect" type="hidden" value="{$ConfirmationPage}" /></p>
<p><label for="Name"><strong>* Name:</strong></label><br /><input id="Name" alt="Name" name="Name" type="text" required="true" /></p>
<p><label for="Email"><strong>* Email:</strong></label><br /><input id="Email" alt="Email" name="Email" type="text" required="true" /></p>
<p><label for="Phone"><strong>Phone:</strong></label><br /><input id="Phone" alt="Phone" name="Phone" type="text" /></p>	
<p><label for="Request"><strong>* Request:</strong></label><br /><textarea id="Request" cols="40" rows="4" name="Request" required="true"></textarea></p>
<script src="https://www.google.com/recaptcha/api/challenge?k=6LcRfAYAAAAAAGMBvBVpJMeBSBLhNWOyqVxgksJ6"></script>
<script src="https://api-secure.recaptcha.net/challenge?k=6LcRfAYAAAAAAGMBvBVpJMeBSBLhNWOyqVxgksJ6" type="text/javascript"></script>
<noscript><br /><iframe frameborder="0" height="300" name="CAPTCHA_Form" src="https://api-secure.recaptcha.net/noscript?k=6LcRfAYAAAAAAGMBvBVpJMeBSBLhNWOyqVxgksJ6" title="CAPTCHA Form" width="500" >contact form</iframe><label for="recaptcha_challenge_field">Verify the Text<textarea cols="40" id="recaptcha_challenge_field" name="recaptcha_challenge_field" rows="3"></textarea></label><input name="recaptcha_response_field" type="hidden" value="manual_challenge" /></noscript><br /> <input id="Submit" alt="Submit" type="submit" value="Submit" /> <input id="Reset" alt="Reset" type="reset" value="Reset" /> *Required Fields</form></div>
                </div>
              </div>
               <xsl:comment> end rt col </xsl:comment>
            </div>
            <xsl:comment> end main row </xsl:comment>
  </xsl:template>

	<xsl:template name="MainContent">
		<xsl:variable name="Recipient1" select="document/ouc:properties[@label='config']/parameter[@name='Recipient1']/text()" />
		<xsl:variable name="Recipient2" select="document/ouc:properties[@label='config']/parameter[@name='Recipient2']/text()" />
		<xsl:variable name="Recipient3" select="document/ouc:properties[@label='config']/parameter[@name='Recipient3']/text()" />
		<xsl:variable name="Recipient4" select="document/ouc:properties[@label='config']/parameter[@name='Recipient4']/text()" />
		<xsl:variable name="Recipient5" select="document/ouc:properties[@label='config']/parameter[@name='Recipient5']/text()" />
		<xsl:variable name="Recipient6" select="document/ouc:properties[@label='config']/parameter[@name='Recipient6']/text()" />
		<xsl:variable name="ConfirmationPage" select="document/ouc:properties[@label='config']/parameter[@name='ConfirmationPage']/text()" />
		<xsl:variable name="Subject" select="document/ouc:properties[@label='config']/parameter[@name='Subject']/text()" />
         <!-- single column -->
		<xsl:variable name="Title" select="document/ouc:properties[@label='metadata']/title" />
                <xsl:comment> single col </xsl:comment>
              <div class="col-md-12">
                <div id="maincontent" class="pageletMedium-full" role="main">
					 <!-- Breadcrumbs -->
                 <xsl:call-template name="Breadcrumbs"/>
                  <xsl:comment> heading </xsl:comment>
					<!-- page heading -->
                    <h2 class="pageletHeadingMedium">
						<xsl:value-of select="$Title" disable-output-escaping="yes" />
					</h2>
                  <xsl:comment> body content </xsl:comment>
					<!-- body column -->
					<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
					
					<div>

<form id="ContactForm" action="{{f:80119247}}" method="post" name="ContactForm">
<p><!-- EMAIL RECIPIENTS==YOU MUST CHANGE THESE --><input name="_recipients" type="hidden" value="{ou:processEmails($Recipient1,$Recipient2,$Recipient3,$Recipient4,$Recipient5,$Recipient6)}" /> <!-- REQUIRED FIELDS --><input name="_requiredFields" type="hidden" value="Name,Email,Request" /> <!-- reply to address taken from a form field (choose _replyToField or _replyTo) --><input name="_replyToField" type="hidden" value="Email" /> <!-- EMAIL SUBJECT --><input name="_subject" type="hidden" value="{$Subject}" /> <!-- ADD THE DATE AND TIME (OPTIONAL==CHOOSE ONLY ONE, true or false) --><input name="_DateAndTime" type="hidden" value="true" /> <input name="_envars" type="hidden" value="HTTP_REFERER" />  <!-- CONFIRMATION REDIRECT --> <input name="_redirect" type="hidden" value="{$ConfirmationPage}" /></p>
<p><label for="Name"><strong>* Name:</strong></label><br /><input id="Name" alt="Name" name="Name" type="text" required="true" /></p>
<p><label for="Email"><strong>* Email:</strong></label><br /><input id="Email" alt="Email" name="Email" type="text" required="true" /></p>
<p><label for="Phone"><strong>Phone:</strong></label><br /><input id="Phone" alt="Phone" name="Phone" type="text" /></p>
<p><label for="Request"><strong>* Request:</strong></label><br /><textarea id="Request" cols="40" rows="4" name="Request" required="true"></textarea></p>
<script src="https://www.google.com/recaptcha/api/challenge?k=6LcRfAYAAAAAAGMBvBVpJMeBSBLhNWOyqVxgksJ6"></script>
<script src="https://api-secure.recaptcha.net/challenge?k=6LcRfAYAAAAAAGMBvBVpJMeBSBLhNWOyqVxgksJ6" type="text/javascript"></script>
<noscript><br /><iframe frameborder="0" height="300" name="CAPTCHA_Form" src="https://api-secure.recaptcha.net/noscript?k=6LcRfAYAAAAAAGMBvBVpJMeBSBLhNWOyqVxgksJ6" title="CAPTCHA Form" width="500" >contact form</iframe><label for="recaptcha_challenge_field">Verify the Text<textarea cols="40" id="recaptcha_challenge_field" name="recaptcha_challenge_field" rows="3"></textarea></label><input name="recaptcha_response_field" type="hidden" value="manual_challenge" /></noscript><br /> <input id="Submit" alt="Submit" type="submit" value="Submit" /> <input id="Reset" alt="Reset" type="reset" value="Reset" /> *Required Fields</form></div>
                </div>
              </div>   
            <xsl:comment> end main row </xsl:comment>
	</xsl:template>
	
	<xsl:template name="Breadcrumbs">
		
	<!-- removes the / from the dirname for the if statement below -->
	<xsl:param name="firstdirtest" select="substring(concat('/',tokenize($dirname,'/')[2]),2)" />
	<xsl:param name="Title" select="document/ouc:properties[@label='metadata']/title" />
	<xsl:param name="BrcPageTitle" select="document/ouc:properties[@label='config']/parameter[@name='BrcPageTitle']/text()" />
		
	<xsl:for-each select="document(concat('file:', $ou:root, $ou:site, '/_resources_2016/xml/breadcrumbs-list.xml'))/breadcrumbslist/breadcrumbs">

	<xsl:variable name="subsite_folder" select="subsite_folder[text()]"/>
	<xsl:variable name = "subsite_title" select="subsite_title[text()]" />
	<xsl:variable name = "dept_folder" select="dept_folder[text()]"  />
	<xsl:variable name = "dept_title" select="dept_title[text()]"  />
	<xsl:variable name = "division_folder" select="division_folder[text()]"  />
	<xsl:variable name = "division_title" select="division_title[text()]"  />
<!-- test for public folder or secure folder -->
	<xsl:if test="lower-case($subsite_folder)=lower-case($firstdirtest) or concat($firstdir,'/',lower-case($subsite_folder),'/') = concat('/secure', lower-case($seconddir),'/')">
	<xsl:variable name="page_title"> 
		<xsl:choose>
			<xsl:when test="normalize-space($BrcPageTitle)!=''">
				<xsl:value-of select="$BrcPageTitle" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$Title" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable> 
<!-- variable for secure folder prefix, '/secure' -->
		<xsl:variable name="final_subsite_folder"> 
		<xsl:choose>
			<xsl:when test="concat($firstdir,'/',lower-case($subsite_folder),'/') = concat('/secure', lower-case($seconddir),'/')">
				<xsl:value-of select="concat('secure/', lower-case($subsite_folder))" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$subsite_folder" />
			</xsl:otherwise>
		</xsl:choose>
		</xsl:variable>
		
	 <div id="BreadcrumbList">
                    <xsl:choose>
                      <xsl:when test="(normalize-space($division_title)='' and normalize-space($dept_title)='')">
                        <ol vocab="http://schema.org/" typeof="BreadcrumbList">
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="*** Broken Link ***">
                              <span property="name">Cerritos College</span>
                            </a>
                            <meta property="position" content="1" />
                          </li>
                          ›
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$final_subsite_folder}/">
                              <span property="name">
                                <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="2" />
                          </li>
						›
                          <li property="itemListElement" typeof="ListItem">
							  <span property="name">
                                <xsl:value-of select="$page_title" disable-output-escaping="yes" />
							  </span>
                            <meta property="position" content="3" />
                          </li>
                        </ol>
                      </xsl:when>
                      <xsl:when test="(normalize-space($division_title)!='' and normalize-space($dept_title)='')">
                        <ol vocab="http://schema.org/" typeof="BreadcrumbList">
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="*** Broken Link ***">
                              <span property="name">Cerritos College</span>
                            </a>
                            <meta property="position" content="1" />
                          </li>
                          ›
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$division_folder}/">
                              <span property="name">
                                <xsl:value-of select="$division_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="2" />
                          </li>
                          ›
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$final_subsite_folder}/">
                              <span property="name">
                                <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="3" />
                          </li>
							›
                          <li property="itemListElement" typeof="ListItem">
							  <span property="name">
                                <xsl:value-of select="$page_title" disable-output-escaping="yes" />
							  </span>
                            <meta property="position" content="4" />
                          </li>
                        </ol>
                      </xsl:when>
                      <xsl:when test="(normalize-space($division_title)='' and normalize-space($dept_title)!='')">
                        <ol vocab="http://schema.org/" typeof="BreadcrumbList">
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="*** Broken Link ***">
                              <span property="name">Cerritos College</span>
                            </a>
                            <meta property="position" content="1" />
                          </li>
                          ›
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$dept_folder}/">
                              <span property="name">
                                <xsl:value-of select="$dept_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="2" />
                          </li>
                          ›
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$final_subsite_folder}/">
                              <span property="name">
                                <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="3" />
                          </li>
							›
                          <li property="itemListElement" typeof="ListItem">
							  <span property="name">
                                <xsl:value-of select="$page_title" disable-output-escaping="yes" />
							  </span>
                            <meta property="position" content="4" />
                          </li>
                        </ol>
                      </xsl:when>
                      <xsl:otherwise>
                        <ol vocab="http://schema.org/" typeof="BreadcrumbList">
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="*** Broken Link ***">
                              <span property="name">Cerritos College</span>
                            </a>
                            <meta property="position" content="1" />
                          </li>
                          ›
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$division_folder}/">
                              <span property="name">
                                <xsl:value-of select="$division_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="2" />
                          </li>
                          ›
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$dept_folder}/">
                              <span property="name">
                                <xsl:value-of select="$dept_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="3" />
                          </li>
                          ›
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$final_subsite_folder}/">
                              <span property="name">
                                <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="4" />
                          </li>
							›
                          <li property="itemListElement" typeof="ListItem">
							  <span property="name">
                                <xsl:value-of select="$page_title" disable-output-escaping="yes" />
							  </span>
                            <meta property="position" content="5" />
                          </li>
                        </ol>
                      </xsl:otherwise>
                    </xsl:choose>
                  </div>
				</xsl:if>
		</xsl:for-each>
			
	</xsl:template>
	
	<xsl:function name="ou:processEmails">
		<xsl:param name="Recipient1"/>
		<xsl:param name="Recipient2"/>
		<xsl:param name="Recipient3"/>
		<xsl:param name="Recipient4"/>
		<xsl:param name="Recipient5"/>
		<xsl:param name="Recipient6"/>
		
		<xsl:if test="string-length($Recipient1) > 0"><xsl:value-of select="ou:parseString(substring-before($Recipient1,'@cerritos.edu'))"/></xsl:if>
		<xsl:if test="string-length($Recipient2) > 0">,<xsl:value-of select="ou:parseString(substring-before($Recipient2,'@cerritos.edu'))"/></xsl:if>
		<xsl:if test="string-length($Recipient3) > 0">,<xsl:value-of select="ou:parseString(substring-before($Recipient3,'@cerritos.edu'))"/></xsl:if>
		<xsl:if test="string-length($Recipient4) > 0">,<xsl:value-of select="ou:parseString(substring-before($Recipient4,'@cerritos.edu'))"/></xsl:if>
		<xsl:if test="string-length($Recipient5) > 0">,<xsl:value-of select="ou:parseString(substring-before($Recipient5,'@cerritos.edu'))"/></xsl:if>
		<xsl:if test="string-length($Recipient6) > 0">,<xsl:value-of select="ou:parseString(substring-before($Recipient6,'@cerritos.edu'))"/></xsl:if>

	</xsl:function>
	
		<!--xsl:function name="ou:processEmail">
		<xsl:param name="Recipient"/>
		<xsl:if test="string-length($Recipient) > 0">
			<xsl:value-of select="ou:parseString(substring-before($Recipient,'@cerritos.edu'))"/>
		</xsl:if>
	</xsl:function>
	
	<xsl:function name="ou:processEmail2">
		<xsl:param name="Recipient"/>
		<xsl:if test="string-length($Recipient) > 0">
			,<xsl:value-of select="ou:parseString(substring-before($Recipient,'@cerritos.edu'))"/>
		</xsl:if>
	</xsl:function-->
	
	<xsl:function name="ou:parseString">
    <xsl:param name="text"/>
    <xsl:analyze-string select="lower-case($text)" regex=".">
        <xsl:matching-substring>
			<xsl:choose>
			<xsl:when test=". = 'a'">
				<xsl:value-of select="9" />
			</xsl:when>
			<xsl:when test=". = 'b'">
				<xsl:value-of select="8" />
			</xsl:when>
			<xsl:when test=". = 'c'">
				<xsl:value-of select="7" />
			</xsl:when>
			<xsl:when test=". = 'd'">
				<xsl:value-of select="6" />
			</xsl:when>
			<xsl:when test=". = 'e'">
				<xsl:value-of select="5" />
			</xsl:when>
			<xsl:when test=". = 'f'">
				<xsl:value-of select="4" />
			</xsl:when>
			<xsl:when test=". = 'g'">
				<xsl:value-of select="3" />
			</xsl:when>
			<xsl:when test=". = 'h'">
				<xsl:value-of select="2" />
			</xsl:when>
			<xsl:when test=". = 'i'">
				<xsl:value-of select="1" />
			</xsl:when>
			<xsl:when test=". = 'j'">
				<xsl:value-of select="0" />
			</xsl:when>
			<xsl:when test=". = 'k'">
				<xsl:value-of select="'!'" />
			</xsl:when>
			<xsl:when test=". = 'l'">
				<xsl:value-of select="'`'" />
			</xsl:when>
			<xsl:when test=". = 'm'">
				<xsl:value-of select="'~'" />
			</xsl:when>
			<xsl:when test=". = 'n'">
				<xsl:value-of select="'$'" />
			</xsl:when>
			<xsl:when test=". = 'o'">
				<xsl:value-of select="'%'" />
			</xsl:when>
			<xsl:when test=". = 'p'">
				<xsl:value-of select="'^'" />
			</xsl:when>
			<xsl:when test=". = 'q'">
				<xsl:value-of select="'*'" />
			</xsl:when>
			<xsl:when test=". = 'r'">
				<xsl:value-of select="'('" />
			</xsl:when>
			<xsl:when test=". = 's'">
				<xsl:value-of select="')'" />
			</xsl:when>
			<xsl:when test=". = 't'">
				<xsl:value-of select="'['" />
			</xsl:when>
			<xsl:when test=". = 'u'">
				<xsl:value-of select="']'" />
			</xsl:when>
			<xsl:when test=". = 'v'">
				<xsl:value-of select="'|'" />
			</xsl:when>
			<xsl:when test=". = 'w'">
            	<xsl:value-of select="'/'" />
            </xsl:when>
            <xsl:when test=". = 'x'">
            	<xsl:value-of select="'\'" />
            </xsl:when>
			<xsl:when test=". = 'y'">
				<xsl:value-of select="'-'" />
			</xsl:when>
			<xsl:when test=". = 'z'">
				<xsl:value-of select="'_'" />
			</xsl:when>
		</xsl:choose>
        </xsl:matching-substring>
    </xsl:analyze-string>
</xsl:function>
</xsl:stylesheet>



