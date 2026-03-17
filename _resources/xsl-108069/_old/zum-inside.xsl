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
	<xsl:variable name="LeftNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='LeftNav']/text())" />

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
		  
        <xsl:comment> cerritos legacy CSS </xsl:comment>
		<link href="{{f:80151058}}" rel="stylesheet" type="text/css" media="all" /><xsl:text>&#xA;</xsl:text>
        <xsl:comment> editor styles </xsl:comment>
        <link href="{{f:80151080}}" rel="stylesheet" type="text/css" media="all" />
       	<xsl:comment> 2017 styles </xsl:comment>
        <link href="/_resources/css/2017.css" rel="stylesheet" type="text/css" media="all" />

		<script type="text/javascript" src="{{f:80151144}}"></script>
		<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>

	<!-- google tracking code -->
		 <xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics.inc')"/>
    
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

      </head>
		 <body>
		 	<!-- global header -->
		 	<xsl:copy-of select="ou:includeFile('/_resources/includes/header.inc')"/>

			<!-- Cerritos Breadcrumbs -->
			 <xsl:call-template name="CerritosBreadcrumbs"/>
			 
			 <!-- include left nav -->
					<xsl:if test="string-length($LeftNav) > 0 and $LeftNav!=''"> 
						<div id="leftnav">
		<!--									<ouc:div>
<xsl:choose>
<xsl:when test="($ou:action='edt')">
<xsl:comment> com.omniupdate.div label="LeftNav" button-text="Left Menu" button="702" group="Everyone" toolbar="Menu" path="<xsl:value-of select="$LeftNav"/>" 

</xsl:comment>
</xsl:when>
<xsl:otherwise>
<xsl:copy-of select="ou:includeFile($LeftNav)"/>						
</xsl:otherwise>
</xsl:choose>
</ouc:div> 		-->

						<!-- ###################################################################### -->
						

						<!-- added for ticket #38482, used function from file that does the same as above logic. -->
						<xsl:call-template name="unparsed-include-file">
							<xsl:with-param name="path" select="$LeftNav"/>
						</xsl:call-template>

						<!-- ###################################################################### -->
						</div>
					</xsl:if>
			 
			<!-- main content -->
			 <div id="content">
			<xsl:comment> main content  </xsl:comment>
			<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
			 </div>
			<!--##### global footer #####-->
			<xsl:copy-of select="ou:includeFile('/_resources/includes/footer.inc')"/>
		
		  </body>
		</html>	 
	</xsl:template>	
			
	<!--################## templates ################# -->
	
	<xsl:template name="CerritosBreadcrumbs">
		
	<!-- removes the / from the dirname for the if statement below -->
	<xsl:param name="firstdirtest" select="substring(concat('/',tokenize($dirname,'/')[2]),2)" />
	<xsl:param name="Title" select="document/ouc:properties[@label='metadata']/title" />
	<xsl:param name="BrcPageTitle" select="document/ouc:properties[@label='config']/parameter[@name='BrcPageTitle']/text()" />
		
	<xsl:for-each select="document(concat('file:', $ou:root, $ou:site, '/_resources/xml/breadcrumbs-list.xml'))/breadcrumbslist/breadcrumbs">
	<!--<xsl:for-each select="document(concat('file:', $ou:root, $ou:site,'/',$firstdirtest, '/_includes/assets/breadcrumbs-list.xml'))/breadcrumbslist/breadcrumbs"> -->

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
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
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
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
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
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
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
                            <a property="item" typeof="WebPage" href="{{d:9116620}}">
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

</xsl:stylesheet>



