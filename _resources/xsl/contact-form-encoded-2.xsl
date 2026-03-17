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
	<xsl:import href="accessibility-link-icons.xsl" />

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
	<xsl:variable name="LeftNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='LeftNav']/text())" />
	<xsl:variable name="DeptInfo" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='DeptInfo']/text())" />
	<xsl:variable name="TrackingInclude" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='TrackingInclude']/text())" />
	<xsl:variable name="WebCss" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='WebCss']/text())" />
		<xsl:variable name="Recipient1" select="document/ouc:properties[@label='config']/parameter[@name='Recipient1']/text()" />
		<xsl:variable name="Recipient2" select="document/ouc:properties[@label='config']/parameter[@name='Recipient2']/text()" />
		<xsl:variable name="Recipient3" select="document/ouc:properties[@label='config']/parameter[@name='Recipient3']/text()" />
		<xsl:variable name="Recipient4" select="document/ouc:properties[@label='config']/parameter[@name='Recipient4']/text()" />
		<xsl:variable name="Recipient5" select="document/ouc:properties[@label='config']/parameter[@name='Recipient5']/text()" />
		<xsl:variable name="Recipient6" select="document/ouc:properties[@label='config']/parameter[@name='Recipient6']/text()" />
		<xsl:variable name="ConfirmationPage" select="document/ouc:properties[@label='config']/parameter[@name='ConfirmationPage']/text()" />
		<xsl:variable name="Subject" select="document/ouc:properties[@label='config']/parameter[@name='Subject']/text()" />
	
	<html lang="en-us">
	<head>
		<!-- head include -->
		<xsl:copy-of select="ou:includeFile('/_resources/includes/head-6.inc')"/>
		
     	<!-- inserts 'cerritos college' in title if not there -->
     	 <title>
			<xsl:choose>
				<xsl:when test="contains(lower-case($Title), 'cerritos college') = true "><xsl:value-of select="normalize-space($Title)" disable-output-escaping="yes" /></xsl:when>
				<xsl:otherwise>Cerritos College - <xsl:value-of select="normalize-space($Title)" disable-output-escaping="yes" /></xsl:otherwise>
			</xsl:choose>
        </title>
		<meta name="author" content="{$Author}" />
        <meta name="keywords" content="{$Keywords}" />
        <meta name="description" content="{$Description}" />
		<meta name="copyright" content="Cerritos College"/>
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />
		
		<!-- dept style sheet -->
		<xsl:if test="string-length($WebCss) > 0 ">
		<xsl:choose>
			<!-- if it's a full path -->
			<xsl:when test="contains($WebCss, '/')">
				<link href="{$WebCss}" rel="stylesheet" type="text/css" media="all" /><xsl:text>&#xA;</xsl:text>
			</xsl:when>
			<!-- if it's just a file name -->
			<xsl:otherwise>
				<link href="{concat($firstdir,'/_includes/assets/',$WebCss)}" rel="stylesheet" type="text/css" media="all" /><xsl:text>&#xA;</xsl:text>
			</xsl:otherwise>
		</xsl:choose>
		</xsl:if>

	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-tag-manager-body-script.inc')"/>


	
	
	<!-- special tracking code if any for this page -->
	<xsl:if test="string-length($TrackingInclude) > 0 ">  		  
		<!--<xsl:copy-of select="ou:includeFile($TrackingInclude)"/>-->
		<xsl:call-template name="unparsed-include-file">
			<xsl:with-param name="path" select="ou:includeFile($TrackingInclude)"/>
		</xsl:call-template>
	</xsl:if>
		
		<script src='https://www.google.com/recaptcha/api.js'></script>

		
</head>

<body class="department inside">
	
	<!--######## Global Safety Alert ######## -->
	<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
			<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="'/_resources/includes/global-safety-alert.inc'"/>
			</xsl:call-template>
	

	<!-- header -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header-3.inc')"/>
		<div class="body-wrap">
<div class="clearfix">
	
	<!-- left nav -->
        <div id="sidebar" class="col-sm-4 col-md-3">
			<div id="skiptonavigation">
				<div id="menuLeft" class="nopanel">
				<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
				<xsl:call-template name="unparsed-include-file">
					<xsl:with-param name="path" select="$LeftNav"/>
				</xsl:call-template>
				</div>
			</div>
			<div>
			<div id="deptinfo">
				<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
				<xsl:call-template name="unparsed-include-file">
					<xsl:with-param name="path" select="$DeptInfo"/>
				</xsl:call-template>
			</div>
			</div>
        </div>
	
	<!-- main content -->
        <div id="maincontent" class="col-sm-8 col-md-9">
			<div id="skiptocontent"></div>
			
			<!-- breadcrumbs -->
               <xsl:call-template name="BreadcrumbsList"/>
			
				<!-- inside page with one edit region -->
				<div id="contentcontainer">
					<!-- heading -->
					<h2><xsl:value-of select="$Title" disable-output-escaping="yes" /></h2>

					<!-- other inside content -->
					<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
					
<div>
<form id="ContactForm" action="http://www.cerritos.edu/scripts/FormToMail.aspx" method="post" name="ContactForm">
<p><!-- EMAIL RECIPIENTS==YOU MUST CHANGE THESE --><input name="_recipients" type="hidden" value="{ou:processEmails($Recipient1,$Recipient2,$Recipient3,$Recipient4,$Recipient5,$Recipient6)}" /> <!-- REQUIRED FIELDS --><input name="_requiredFields" type="hidden" value="Name,Email,Request" /> <!-- reply to address taken from a form field (choose _replyToField or _replyTo) --><input name="_replyToField" type="hidden" value="Email" /> <!-- EMAIL SUBJECT --><input name="_subject" type="hidden" value="{$Subject}" /> <!-- ADD THE DATE AND TIME (OPTIONAL==CHOOSE ONLY ONE, true or false) --><input name="_DateAndTime" type="hidden" value="true" /> <input name="_envars" type="hidden" value="HTTP_REFERER,HTTP_USER_AGENT,REMOTE_ADDR" />  <!-- CONFIRMATION REDIRECT --> <input name="_redirect" type="hidden" value="{$ConfirmationPage}" /></p>
<p><label for="Name"><strong>* Name:</strong></label><br /><input id="Name" name="Name" type="text" required="true" /></p>
<p><label for="Email"><strong>* Email:</strong></label><br /><input id="Email" name="Email" type="text" required="true" /></p>
<p><label for="Phone"><strong>Phone:</strong></label><br /><input id="Phone" name="Phone" type="text" /></p>	
<p><label for="Request"><strong>* Request:</strong></label><br /><textarea id="Request" cols="40" rows="4" name="Request" required="true"></textarea></p>
	
<div class="g-recaptcha" data-sitekey="6LcxUk4UAAAAAMyg221MHklN6E_axt_jNmxZ69fI"></div>

	
	<br /> <input id="Submit" type="submit" value="Submit" /> <label for="Reset" style="border: 0;clip: rect(0 0 0 0);height: 1px;margin: -1px;overflow: hidden;padding: 0;position: absolute;width: 1px;">Reset</label><input id="Reset" type="reset" value="Reset" /> * Required Fields</form></div>
				</div>
        </div>
    </div>
</div>
	
<!-- footer -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer-3.inc')"/>
	
	<!-- Cerritos direct edit button. 3 params: site, dirname, filename -->
	<div id="lastUpdate">
		<div class="container">
			<xsl:copy-of select="ou:includeFile('/_resources/includes/footer-bottom.inc')"/>
		<xsl:call-template name="CerritosDirectEditButton">
			<xsl:with-param name="site1" select="$ou:site" />
			<xsl:with-param name="dirname1" select="$ou:dirname" />
			<xsl:with-param name="filename1" select="$ou:filename" />
		</xsl:call-template>
		</div>
	</div>
	  <script src="{{f:80151160}}"></script>
</body>
		</html>	 
	</xsl:template>	
	
	<!-- Breadcrumbs template -->
	<xsl:template name="BreadcrumbsList">
		
	<!-- removes the / from the dirname for the if statement below -->
	<xsl:param name="firstdirtest" select="substring(concat('/',tokenize($dirname,'/')[2]),2)" />
	<xsl:param name="Title" select="document/ouc:properties[@label='metadata']/title" />
	<xsl:param name="BrcPageTitle" select="document/ouc:properties[@label='config']/parameter[@name='BrcPageTitle']/text()" />
		
	<xsl:for-each select="document(concat('file:', $ou:root, $ou:site, '/_resources/xml/breadcrumbs-list.xml'))/breadcrumbslist/breadcrumbs">

	<xsl:variable name="subsite_folder" select="subsite_folder[text()]"/>
	<xsl:variable name = "subsite_title" select="subsite_title[text()]" />
	<xsl:variable name = "dept_folder" select="dept_folder[text()]"  />
	<xsl:variable name = "dept_title" select="dept_title[text()]"  />
	<xsl:variable name = "division_folder" select="division_folder[text()]"  />
	<xsl:variable name = "division_title" select="division_title[text()]"  />
	<!-- set page title  -->
	<xsl:if test="lower-case($subsite_folder)=lower-case($firstdirtest)">
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
		
	 <div id="BreadcrumbList">
                    <xsl:choose>
                      <xsl:when test="(normalize-space($division_title)='' and normalize-space($dept_title)='')">
                        <ol vocab="http://schema.org/" typeof="BreadcrumbList" class="breadcrumbs">
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
                              <span property="name"><span class="fa fa-home"><span class="sr-only">Home</span></span></span>
                            </a>
                            <meta property="position" content="1" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$subsite_folder}/">
                              <span property="name">
                                <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="2" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
							  <span property="name" class="title">
                                <xsl:value-of select="$page_title" disable-output-escaping="yes" />
							  </span>
                            <meta property="position" content="3" />
                          </li>
                        </ol>
                      </xsl:when>
                      <xsl:when test="(normalize-space($division_title)!='' and normalize-space($dept_title)='')">
                        <ol vocab="http://schema.org/" typeof="BreadcrumbList" class="breadcrumbs">
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
                              <span property="name"><span class="fa fa-home"><span class="sr-only">Home</span></span></span>
                            </a>
                            <meta property="position" content="1" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$division_folder}/">
                              <span property="name">
                                <xsl:value-of select="$division_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="2" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$subsite_folder}/">
                              <span property="name">
                                <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="3" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
							  <span property="name" class="title">
                                <xsl:value-of select="$page_title" disable-output-escaping="yes" />
							  </span>
                            <meta property="position" content="4" />
                          </li>
                        </ol>
                      </xsl:when>
                      <xsl:when test="(normalize-space($division_title)='' and normalize-space($dept_title)!='')">
                        <ol vocab="http://schema.org/" typeof="BreadcrumbList" class="breadcrumbs">
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
                              <span property="name"><span class="fa fa-home"><span class="sr-only">Home</span></span></span>
                            </a>
                            <meta property="position" content="1" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$dept_folder}/">
                              <span property="name">
                                <xsl:value-of select="$dept_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="2" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$subsite_folder}/">
                              <span property="name">
                                <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="3" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
							  <span property="name" class="title">
                                <xsl:value-of select="$page_title" disable-output-escaping="yes" />
							  </span>
                            <meta property="position" content="4" />
                          </li>
                        </ol>
                      </xsl:when>
                      <xsl:otherwise>
                        <ol vocab="http://schema.org/" typeof="BreadcrumbList" class="breadcrumbs">
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
                              <span property="name"><span class="fa fa-home"><span class="sr-only">Home</span></span></span>
                            </a>
                            <meta property="position" content="1" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$division_folder}/">
                              <span property="name">
                                <xsl:value-of select="$division_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="2" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$dept_folder}/">
                              <span property="name">
                                <xsl:value-of select="$dept_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="3" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="/{$subsite_folder}/">
                              <span property="name">
                                <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                              </span>
                            </a>
                            <meta property="position" content="4" />
                          </li>
                          <li property="itemListElement" typeof="ListItem">
							  <span property="name" class="title">
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



