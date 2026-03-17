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
	<xsl:variable name="LeftNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='LeftNav']/text())" />
	<xsl:variable name="DeptInfo" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='DeptInfo']/text())" />
	<xsl:variable name="DeptTopPanel" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='DeptTopPanel']/text())" />
	<xsl:variable name="TrackingInclude" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='TrackingInclude']/text())" />
	<xsl:variable name="Layout" select="document/ouc:properties[@label='config']/parameter[@name='Layout']/option[@selected='true']/@value" />
	<xsl:variable name="PageType" select="document/ouc:properties[@label='config']/parameter[@name='PageType']/option[@selected='true']/@value" />


	<html lang="en-us">
	<head>
		<!-- head include -->
		<xsl:copy-of select="ou:includeFile('/_resources/includes/head-2.inc')"/>
		
     	<!-- title. inserts 'cerritos college' if not there -->
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
		<meta name="copyright" content="Cerritos College"/>
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

	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics.inc')"/>
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
		
</head>


<body class="{ou:GetBodyClass($PageType)}">
	
<div class="body-wrap">
	<!-- header -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header.inc')"/>
	<!-- dept top panel -->
	<xsl:if test="$PageType='depthome'">
		<div id="top-panel">
			<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
			<xsl:call-template name="unparsed-include-file">
				<xsl:with-param name="path" select="$DeptTopPanel"/>
			</xsl:call-template>
		</div>
	</xsl:if>
		
<div class="clearfix">
	<!-- choose layout -->
	<xsl:choose>
	<!-- two column - left nav + main -->
	<xsl:when test="$Layout='left-main'">
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
        <div id="maincontent" class="col-md-9">
			<!-- breadcrumbs -->
               <xsl:call-template name="BreadcrumbsList"/>
            <div id="contentcontainer">
				<!-- heading -->
                <h2><xsl:value-of select="document/ouc:properties[@label='metadata']/title" disable-output-escaping="yes" /></h2>
				<!-- slider -->
				<xsl:apply-templates select="document/ouc:div[@label='deptslider']" />
                <!-- intro -->
                <h4><xsl:apply-templates select="document/ouc:div[@label='deptintro']" /></h4>
                <h3>Hours of Operation</h3>
				<!-- hours -->
				<xsl:apply-templates select="document/ouc:div[@label='depthours']" />
            </div>
            <div id="contentvideo">
				<!-- video -->
				<xsl:apply-templates select="document/ouc:div[@label='contentvideo']" />
            </div>
        </div>
	</xsl:when>
	<!-- full width - main only -->
	<xsl:otherwise>
        <div id="maincontent" class="col-md-12">
			<!-- breadcrumbs -->
               <xsl:call-template name="BreadcrumbsList"/>
            <div id="contentcontainer">
				<!-- heading -->
                <h2><xsl:value-of select="document/ouc:properties[@label='metadata']/title" disable-output-escaping="yes" /></h2>
				<!-- slider -->
				<xsl:apply-templates select="document/ouc:div[@label='deptslider']" />
                <!-- intro -->
                <h4><xsl:apply-templates select="document/ouc:div[@label='deptintro']" /></h4>
                <h3>Hours of Operation</h3>
				<!-- hours -->
				<xsl:apply-templates select="document/ouc:div[@label='depthours']" />
            </div>
            <div id="contentvideo">
				<!-- video -->
				<xsl:apply-templates select="document/ouc:div[@label='contentvideo']" />
            </div>
        </div>
	</xsl:otherwise>	
	</xsl:choose>
    </div>
</div>

<!-- footer -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer.inc')"/>
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
	<!--<xsl:for-each select="document(concat('file:', $ou:root, $ou:site,'/',$firstdirtest, '/_includes/assets/breadcrumbs-list.xml'))/breadcrumbslist/breadcrumbs"> -->

	<xsl:variable name="subsite_folder" select="subsite_folder[text()]"/>
	<xsl:variable name = "subsite_title" select="subsite_title[text()]" />
	<xsl:variable name = "dept_folder" select="dept_folder[text()]"  />
	<xsl:variable name = "dept_title" select="dept_title[text()]"  />
	<xsl:variable name = "division_folder" select="division_folder[text()]"  />
	<xsl:variable name = "division_title" select="division_title[text()]"  />
<!-- test for page name -->
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
	
	<xsl:function name="ou:GetBodyClass">
		<xsl:param name="PageType"/>
		<xsl:choose>
			<xsl:when test="$PageType='depthome'">
				department
			</xsl:when>
			<xsl:otherwise>
				department inside
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<xsl:function name="ou:GetStyle">
		<xsl:param name="PageType"/>
		<xsl:choose>
			<xsl:when test="$PageType='depthome'">
				department
			</xsl:when>
			<xsl:otherwise>
				department inside
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
</xsl:stylesheet>



