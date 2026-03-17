<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   "&#160;">
<!ENTITY lsaquo   "&#8249;">
<!ENTITY rsaquo   "&#8250;">
<!ENTITY laquo  "&#171;">
<!ENTITY raquo  "&#187;">
<!ENTITY copy   "&#169;">
]>
<xsl:stylesheet version="3.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:ou="http://omniupdate.com/XSL/Variables"
    xmlns:ouc="http://omniupdate.com/XSL/Variables"
    exclude-result-prefixes="xsl xs ou ouc">
    
    <xsl:import href="_shared/variables.xsl" />
    <xsl:import href="_shared/functions.xsl" />
    
    <xsl:import href="template-matches.xsl" />
    <xsl:import href="functions-workshop.xsl" />
    <xsl:import href="ou-variables.xsl" />
    <xsl:import href="accessibility-link-icons.xsl" />
    
    <xsl:import href="_shared/galleries.xsl" />
	<xsl:import href="_shared/galleries-fade.xsl" />
    <xsl:import href="_shared/forms.xsl" />
    
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
        
        <html lang="en-us">
            <head>				
                <!-- head include -->
                <xsl:copy-of select="ou:includeFile('/_resources/includes/head-6.inc')"/>
                
                <!-- inserts 'cerritos college' in title if not there -->
                <title>
                    <xsl:choose>
                        <xsl:when test="contains(lower-case($Title), 'cerritos college') = true ">
							<xsl:value-of select="normalize-space($Title)" disable-output-escaping="yes" />
						</xsl:when>
                        <xsl:otherwise>
							<xsl:value-of select="normalize-space($Title)" disable-output-escaping="yes" /> - Cerritos College
						</xsl:otherwise>
                    </xsl:choose>
                </title>
                <meta name="author" content="{$Author}" />
                <meta name="keywords" content="{$Keywords}" />
                <meta name="description" content="{$Description}" />
				<meta name="robots" content="{$Robots}" />
                <meta name="copyright" content="Cerritos College"/>
				<meta property="og:site_name" content="Cerritos College" />
				<meta property="og:title" content="{$Title}" />
				<meta property="og:description" content="{$Description}" />
				<meta property="og:type" content="website" />
				<meta property="og:url" content="https://www.cerritos.edu/" />
				<meta property="og:image" content="https://www.cerritos.edu/_resources/images/common/cerritos-college-logo.svg" />
				<link rel="canonical" href="{concat($domain,$ou:dirname,'/',$ou:filename)}" />
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
                
                <xsl:call-template name="gallery-headcode">
                    <xsl:with-param name="domain" />
                </xsl:call-template>
                
                <xsl:call-template name="form-headcode" />
				
				<!-- reCAPTCHA version 2 -->
		<script src='https://www.google.com/recaptcha/api.js'></script>
				<xsl:if test="$ou:action = 'pub'">
					<xsl:processing-instruction name="php">
						if (file_exists($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.css.html')) {
						include($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.css.html');
						}
						?</xsl:processing-instruction>
				</xsl:if>
				
				<link rel="stylesheet" href="{{f:80147702}}" type="text/css" />
     			 <link rel="stylesheet" href="{{f:80147701}}" type="text/css" />
            </head>
            
            <body class="department inside">                
                <!--######## Global Safety Alert ######## -->
                <!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
                <xsl:call-template name="unparsed-include-file">
                    <xsl:with-param name="path" select="'/_resources/includes/global-safety-alert.inc'"/>
                </xsl:call-template>
				
				<!-- 8/31/21 Samuel Chavez: Add secondary alert for extra messages beyond COVID stand-in message -->
			<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="'/_resources/includes/global-safety-alert-2.inc'"/>
			</xsl:call-template>
                
                
                <!-- header -->
                <xsl:copy-of select="ou:includeFile('/_resources/includes/header-3.inc')"/>
                <div class="body-wrap">
                    <div class="clearfix">
                        <!-- main content -->
                        <div id="maincontent" class="col-12">
                            <div id="skiptocontent"></div>
                            
                            <!-- breadcrumbs -->
                           <!--<xsl:call-template name="BreadcrumbsList"/>-->
                            
                            <!-- inside page with one edit region -->
							<!--
                            <div id="contentcontainer">
                                <h2><xsl:value-of select="$Title" disable-output-escaping="yes" /></h2>
                            </div>	
-->
                        </div>
                    </div>
                </div>
				
				<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />	
                
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
				<noscript>Your browser does not support JavaScript!</noscript>
                <script src="{{f:80151167}}"></script>
                <noscript>Your browser does not support JavaScript!</noscript>
                <xsl:call-template name="gallery-footcode">
                    <xsl:with-param name="domain" />
                </xsl:call-template>
                
                <xsl:call-template name="form-footcode" />
				
				<xsl:if test="$ou:action = 'pub'">
					<xsl:processing-instruction name="php">
						if (file_exists($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.alerts.html')) {
						include($_SERVER['DOCUMENT_ROOT'] . '/ou-alerts/alerts-config.alerts.html');
						}
						?</xsl:processing-instruction>
				</xsl:if>
            </body>
        </html>	 
    </xsl:template>	

    <!--<xsl:template match="ouform">
        <p>A Form was inserted here.</p>
    </xsl:template>-->
    
    <!-- Breadcrumbs template -->
    <xsl:template name="BreadcrumbsList">
        
        <!-- removes the / from the dirname for the if statement below -->
        <xsl:param name="firstdirtest" select="substring(concat('/',tokenize($dirname,'/')[2]),2)" />
        <xsl:param name="Title" select="document/ouc:properties[@label='metadata']/title" />
        <xsl:param name="BrcPageTitle" select="document/ouc:properties[@label='config']/parameter[@name='BrcPageTitle']/text()" />
        
        
		<!-- Previous setup. Comment out due to XSLT Processor Upgrade to Saxon 11.3 5/19/22 https://support.moderncampus.com/troubleshooting/saxon-upgrade.html -->
		<!-- <xsl:for-each select="document(concat('file:', $ou:root, $ou:site, '/_resources/xml/breadcrumbs-list.xml'))/breadcrumbslist/breadcrumbs"> -->

		<!-- New set up due to XSLT Processor Upgrade to Saxon 11.3 5/19/22 https://support.moderncampus.com/troubleshooting/saxon-upgrade.html -->
		<!-- This creates a variable named bc-list that holds the data from the referenced file if it is available -->
		<!-- The contents of the external XML are stored here so that there is only one network request -->
		<xsl:variable name="bc-list">
			<xsl:if test="doc-available(concat('file:', $ou:root, $ou:site, '/_resources/xml/breadcrumbs-list.xml'))">
				<xsl:copy-of select="doc(concat('file:', $ou:root, $ou:site, '/_resources/xml/breadcrumbs-list.xml'))"/>
			</xsl:if>
		</xsl:variable>
				
				<xsl:for-each select="$bc-list/breadcrumbslist/breadcrumbs" >
		<!-- End new setup -->
            
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
                                    <a property="item" typeof="WebPage" href="/{$subsite_folder}">
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
                                    <a property="item" typeof="WebPage" href="/{$subsite_folder}">
                                        <span property="name" >
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
                                    <a property="item" typeof="WebPage" href="/{$subsite_folder}">
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
                                    <a property="item" typeof="WebPage" href="/{$subsite_folder}">
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
    
</xsl:stylesheet>



