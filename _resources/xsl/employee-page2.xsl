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
	<xsl:variable name="LeftNav" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='LeftNav']/text())" />
	<xsl:variable name="DeptInfo" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='DeptInfo']/text())" />
	<xsl:variable name="TrackingInclude" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='TrackingInclude']/text())" />
	<xsl:variable name="WebCss" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='WebCss']/text())" />
	<xsl:variable name="emailaccount" select="document/ouc:properties[@label='config']/parameter[@name='emailaccount']/text()" />

	<html lang="en-us">
	<head>		
		<!-- head include -->
		<xsl:copy-of select="ou:includeFile('/_resources/includes/head.inc')"/>
		
     	<!-- inserts 'cerritos college' in title if not there -->
     	 <title>Cerritos College - <xsl:value-of select="ou:EmployeePageTitle($emailaccount)" disable-output-escaping="yes" /></title>
		<meta name="author" content="{$Author}" />
        <meta name="keywords" content="{$Keywords}" />
        <meta name="description" content="{$Description}" />
		<meta name="robots" content="{$Robots}" />
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
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header.inc')"/>
		<div class="body-wrap">
<div class="clearfix">
	
	<!-- left nav -->
        <div id="sidebar" class="col-sm-4 col-md-3">
			<div id="skiptonavigation">
				<div id="menuLeft" class="nopanel">
				<button type="button" class="mobile-button hidden-lg" data-toggle="collapse" data-target=".left-nav-collapse">Navigate this Section  <span class="fa fa-chevron-down" aria-hidden="true"></span>
</button>
					<nav class="navbar-collapse left-nav-collapse collapse">
				<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
				<xsl:call-template name="unparsed-include-file">
					<xsl:with-param name="path" select="$LeftNav"/>
				</xsl:call-template>
						</nav>
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
					<h2><xsl:value-of select="ou:EmployeePageTitle($emailaccount)" disable-output-escaping="yes" /></h2>
					
					<xsl:call-template name="EmployeeListing">
						<xsl:with-param name="emailaccount" select="$emailaccount" />
					</xsl:call-template>
					
					<!-- other inside content -->
					<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />
			
				</div>
        </div>
    </div>
</div>
	
<!-- footer -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer.inc')"/>
	
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
	<script src="{{f:80151167}}"></script>
</body>
		</html>	 
	</xsl:template>	
	
	<!-- Breadcrumbs template -->
	<xsl:template name="BreadcrumbsList">
		
	<!-- removes the / from the dirname for the if statement below -->
	<xsl:param name="firstdirtest" select="substring(concat('/',tokenize($dirname,'/')[2]),2)" />
	<xsl:param name="Title" select="document/ouc:properties[@label='metadata']/title" />
	<xsl:param name="BrcPageTitle" select="document/ouc:properties[@label='config']/parameter[@name='BrcPageTitle']/text()" />
	<xsl:param name="emailaccount" select="document/ouc:properties[@label='config']/parameter[@name='emailaccount']/text()" />
		
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
		<xsl:value-of select="ou:EmployeePageTitle($emailaccount)" />
	</xsl:variable> 
		
	 <div id="BreadcrumbList">
                    <xsl:choose>
                      <xsl:when test="(normalize-space($division_title)='' and normalize-space($dept_title)='')">
                        <ol vocab="http://schema.org/" typeof="BreadcrumbList" class="breadcrumbs">
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
	
	<xsl:template name="EmployeeListing">
		<xsl:param name = "emailaccount" />
		
		<div id="employee">
			
		<!-- Previous setup. Comment out due to XSLT Processor Upgrade to Saxon 11.3 5/19/22 https://support.moderncampus.com/troubleshooting/saxon-upgrade.html -->
					<!-- <xsl:for-each select="document(concat('file:', $ou:root, $ou:site, '/_resources/xml/employees.xml'))/employeeslist/employee">  -->

		<!-- New set up due to XSLT Processor Upgrade to Saxon 11.3 5/19/22 https://support.moderncampus.com/troubleshooting/saxon-upgrade.html -->
		<!-- This creates a variable named bc-list that holds the data from the referenced file if it is available -->
		<!-- The contents of the external XML are stored here so that there is only one network request -->
		<xsl:variable name="Employee_File">
			<xsl:if test="doc-available(concat('file:', $ou:root, $ou:site, '/_resources/xml/employees.xml'))">
				<xsl:copy-of select="doc(concat('file:', $ou:root, $ou:site, '/_resources/xml/employees.xml'))"/>
			</xsl:if>
		</xsl:variable>
				
				<xsl:for-each select="$Employee_File/employeeslist/employee" >
		<!-- End new setup -->
			
		  <xsl:variable name = "firstname" select="firstname[text()]" />
          <xsl:variable name = "lastname" select="lastname[text()]" />
		  <xsl:variable name = "middlename" select="middlename[text()]" />
			<xsl:variable name = "jobtitle" select="jobtitle[text()]" />
			<xsl:variable name = "divdept" select="divdept[text()]" />
          <xsl:variable name = "phone" select="phone[text()]" />
		  <xsl:variable name = "emailaddr" select="emailaddr[text()]" />
		  <xsl:variable name = "urladdr" select="urladdr[text()]" />
		<xsl:variable name = "imgurl" select="imgurl[text()]" />
          <xsl:if test="$emailaddr = $emailaccount">
						<xsl:choose>
							<xsl:when test="string-length($imgurl) > 0">
								<img src="$imgurl" alt="{$firstname} {$middlename} {$lastname}" />
							</xsl:when>
							<xsl:otherwise>
								<img src="{{f:80150934}}" alt="placeholder" />
							</xsl:otherwise>
						</xsl:choose>
					<xsl:if test="$jobtitle != ''"><p><xsl:value-of select="$jobtitle" /></p></xsl:if>
					<xsl:if test="$divdept != ''"><p><xsl:value-of select="$divdept" /></p></xsl:if>
					<xsl:if test="$phone != ''"><p>Ext. <xsl:value-of select="$phone" /></p></xsl:if>
					<xsl:if test="$emailaddr != ''"><p>Email <a href="/scripts/employeesmailform-1.aspx?e={ou:parseString(substring-before($emailaddr,'@cerritos.edu'))}">
					<xsl:value-of select="$firstname"/>&#160;<xsl:value-of select="$middlename" />&nbsp;<xsl:value-of select="$lastname"/> 
					</a></p>
				  </xsl:if>
				  <xsl:if test="$urladdr != ''"><p>Website <a href="{$urladdr}" target="_blank"><xsl:value-of select="$urladdr"/></a></p></xsl:if>
			  <p><span class="tenpt">(<a href="javascript:history.go(-1);">Back to Directory</a>)</span></p>
          </xsl:if>
        </xsl:for-each>
	</div>
		
		
</xsl:template>
	
	<xsl:function name="ou:EmployeePageTitle">
		<xsl:param name = "emailaccount" />

        
			
		<!-- Previous setup. Comment out due to XSLT Processor Upgrade to Saxon 11.3 5/19/22 https://support.moderncampus.com/troubleshooting/saxon-upgrade.html -->
					<!-- <xsl:for-each select="document(concat('file:', $ou:root, $ou:site, '/_resources/xml/employees.xml'))/employeeslist/employee"> -->

		<!-- New set up due to XSLT Processor Upgrade to Saxon 11.3 5/19/22 https://support.moderncampus.com/troubleshooting/saxon-upgrade.html -->
		<!-- This creates a variable named bc-list that holds the data from the referenced file if it is available -->
		<!-- The contents of the external XML are stored here so that there is only one network request -->
		<xsl:variable name="Employee_File">
			<xsl:if test="doc-available(concat('file:', $ou:root, $ou:site, '/_resources/xml/employees.xml'))">
				<xsl:copy-of select="doc(concat('file:', $ou:root, $ou:site, '/_resources/xml/employees.xml'))"/>
			</xsl:if>
		</xsl:variable>
				
				<xsl:for-each select="$Employee_File/employeeslist/employee" >
		<!-- End new setup -->

		  <xsl:variable name = "firstname" select="firstname[text()]" />
          <xsl:variable name = "lastname" select="lastname[text()]" />
		  <xsl:variable name = "middlename" select="middlename[text()]" />
		  <xsl:variable name = "emailaddr" select="emailaddr[text()]" />

          <xsl:if test="$emailaddr = $emailaccount">
				<xsl:value-of select="$firstname" /><xsl:if test="$middlename != ''">&nbsp;<xsl:value-of select="$middlename" /></xsl:if>&nbsp;<xsl:value-of select="$lastname" />	
          </xsl:if>

        </xsl:for-each>

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



