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

	<xsl:variable name="Author" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='author']/@content)" />
	<xsl:variable name="Keywords" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='keywords']/@content)"/>
	<xsl:variable name="Description" select="normalize-space(document/ouc:properties[@label='metadata']/meta[@name='description']/@content)"/>
	<xsl:variable name="Title" select="normalize-space(document/ouc:properties[@label='metadata']/title)" />
	<xsl:variable name="LeftNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='LeftNav']/text())" />
	<xsl:variable name="DeptInfo" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='DeptInfo']/text())" />
	<xsl:variable name="DeptTopPanel" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='DeptTopPanel']/text())" />
	<xsl:variable name="TrackingInclude" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='TrackingInclude']/text())" />
	<xsl:variable name="Layout" select="document/ouc:properties[@label='config']/parameter[@name='Layout']/option[@selected='true']/@value" />
	<xsl:variable name="PageType" select="document/ouc:properties[@label='config']/parameter[@name='PageType']/option[@selected='true']/@value" />
	<xsl:variable name="WebCss" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='WebCss']/text())" />
	
	<!-- changes class in body element based on page type -->
	<xsl:variable name="BodyClass">
		<xsl:choose>
			<xsl:when test="$PageType='depthome'">
				department
			</xsl:when>
			<xsl:otherwise>
				department inside
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- not needed? changes class in h2 heading based on page type, department home with no class or dept inside page whcih requires 2.5em top margin deptHeading-->
	<xsl:variable name="HeadingClass">
		<xsl:choose>
			<xsl:when test="$PageType='deptinside' and $Layout='main'">
			</xsl:when>
			<xsl:otherwise>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<!-- changes class in maincontent container div based on layout, either col-md-9 or col-md-12 -->
	<xsl:variable name="MaincontentClass">
		<xsl:choose>
			<xsl:when test="$Layout='left-main'">
				col-md-9
			</xsl:when>
			<xsl:otherwise>
				col-md-12
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<html lang="en-us">
	<head>
		<!-- head include -->
		<xsl:copy-of select="ou:includeFile('/_resources/includes/head-2.inc')"/>
		
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
	
	<!-- special tracking code if any for this page -->
	<xsl:if test="string-length($TrackingInclude) > 0 ">  		  
		<!--<xsl:copy-of select="ou:includeFile($TrackingInclude)"/>-->
		<xsl:call-template name="unparsed-include-file">
			<xsl:with-param name="path" select="ou:includeFile($TrackingInclude)"/>
		</xsl:call-template>
	</xsl:if>
</head>

<body class="{normalize-space($BodyClass)}">
	
	<!--######## Global Safety Alert ######## -->
	<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
			<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="'/_resources/includes/global-safety-alert.inc'"/>
			</xsl:call-template>
	
<div class="body-wrap">
	<!-- header -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header-3.inc')"/>
	<!-- dept top panel -->
	<xsl:if test="$PageType='depthome'">
		<!-- <div id="top-panel">
			added for ticket #38482, the function is in functions-workshop.xsl. -->
			<!--<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="$DeptTopPanel"/>
			</xsl:call-template>
			
		</div>-->
		
	<!--<div id="top-panel">
    <div class="top-panel-content">-->
		<!-- dept home top panel edit region -->
		<xsl:apply-templates select="document/ouc:div[@label='depttoppanel']" />
   <!-- </div></div>
-->
	</xsl:if>
		
<div class="clearfix">
	
	<!-- if two column layout with left nav + main -->
	<xsl:if test="$Layout='left-main'">
        <div id="sidebar" class="col-md-3">
			<div id="skiptonavigation"><div id="menuLeft">
				<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
				<xsl:call-template name="unparsed-include-file">
					<xsl:with-param name="path" select="$LeftNav"/>
				</xsl:call-template>
			</div></div>
			<div id="skiptocontent">
				<div id="deptinfo">
					<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
					<xsl:call-template name="unparsed-include-file">
						<xsl:with-param name="path" select="$DeptInfo"/>
					</xsl:call-template>
    			</div>
			</div>
        </div>
	</xsl:if>
	
	<!-- main content 2 column or full width is handled by class below -->
        <div id="maincontent" class="{normalize-space($MaincontentClass)}">
			<div id="skiptocontent"></div>
			
			<!-- breadcrumbs -->
               <xsl:call-template name="BreadcrumbsList"/>
			
			<!-- choose dept home with 5 edit regions or inside with 2 edit regions -->
			<xsl:choose>
				<xsl:when test="$PageType='depthome'">
					<div id="contentcontainer">
						<!-- heading -->
						<h2><xsl:value-of select="$Title" disable-output-escaping="yes" /></h2>
						
						<!-- dept statement -->
						<div class="department-statement">
						<h4><xsl:apply-templates select="document/ouc:div[@label='deptstatement']" /></h4>
						</div>
						
						<!-- dept home links -->
						<xsl:apply-templates select="document/ouc:div[@label='depthomelinks']" />
						
						<!-- dept slider -->
						<xsl:apply-templates select="document/ouc:div[@label='deptslider']" />
						<br clear="all" />
							
						<!-- hours of operation -->
						<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
					</div>
					<div id="contentvideo">
							<!-- dept video -->
						<xsl:apply-templates select="document/ouc:div[@label='deptvideo']" />
            		</div>
				</xsl:when>
				
				<!-- inside page with one edit region -->
				<xsl:otherwise>
					<div id="contentcontainer">
						<!-- heading -->
						<h2><xsl:value-of select="$Title" disable-output-escaping="yes" /></h2>
						
						<!-- dept statement -->
						<!--<div class="department-statement">
						<xsl:apply-templates select="document/ouc:div[@label='deptstatement']" />
						</div>-->
						
						<!-- other inside content -->
						<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
					</div>
				</xsl:otherwise>
			</xsl:choose>
        </div>
    </div>
</div>
<script src="{{f:80151171}}"></script>
	
<!-- footer -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer-2.inc')"/>
	
<!-- last update link -->	
	<div id="lastUpdate">Last Update: <a href="javascript:void(0);" onclick="popupWarningEdit('http://oucampus.cerritos.edu/10?skin=oucampus&amp;account=2017&amp;site=www-cerritos-edu&amp;action=de&amp;path={concat($ou:dirname,'/',ou:replaceFileExtension($ou:filename,'pcf'))}');"><xsl:value-of select="ou:dateFromDateTime($ou:modified,'/')" /></a></div>
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
                        <ol vocab="http://schema.org/" typeof="BreadcrumbList">
                          <li property="itemListElement" typeof="ListItem">
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
                              <span property="name"><i class="fa fa-home"></i></span>
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
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
                              <span property="name"><i class="fa fa-home"></i></span>
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
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
                              <span property="name"><i class="fa fa-home"></i></span>
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
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
                              <span property="name"><i class="fa fa-home"></i></span>
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



