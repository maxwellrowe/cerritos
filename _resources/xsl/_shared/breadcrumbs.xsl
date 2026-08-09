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
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">	
	
	<!-- Decode Entities Function -->
	<xsl:function name="ou:decode-entities" as="xs:string">
	  <xsl:param name="s" as="xs:string?"/>

	  <xsl:variable name="v" select="string($s)"/>
	  <xsl:variable name="amp" select="codepoints-to-string(38)"/>  <!-- & -->
	  <xsl:variable name="semi" select="codepoints-to-string(59)"/> <!-- ; -->

	  <xsl:sequence select="
		replace(
		  replace(
			replace(
			  replace(
				replace($v,
				  concat($amp,'quot',$semi), codepoints-to-string(34)),
				  concat($amp,'apos',$semi), codepoints-to-string(39)),
				  concat($amp,'lt',$semi),   codepoints-to-string(60)),
				  concat($amp,'gt',$semi),   codepoints-to-string(62)),
				  concat($amp,'amp',$semi),  $amp)
	  "/>
	</xsl:function>

	<!-- NEW BREADCRUMBS - Fall 2025 -->
	<xsl:variable name="link-start" select="''"/>	
	<xsl:variable name="breadcrumbStart" select="$breadcrumb-start"/>
	
	<xsl:template name="breadcrumbsList">
		<xsl:param name="path" select="$dirname" /> <!-- defined in the vars xsl as $ou:dirname with a trailing '/' -->
		<xsl:param name="title" select="$page-title" /> <!-- defined in vars as the title of the current page -->
		<xsl:variable name="custom-breadcrumb-title" select="normalize-space(document/ouc:properties[@label='config']/parameter[@name='BrcPageTitle'])" />
		<xsl:variable name="show-current-crumb" select="$custom-breadcrumb-title != '' or ou:pcf-param('custom-hero') = 'enabled'" />
		
		<nav aria-label="breadcrumb" id="BreadcrumbList" class="mb-3">
			<ol vocab="http://schema.org/" typeof="BreadcrumbList" class="breadcrumbs breadcrumb">
				<!-- check for valid breadcrumbStart to prevent infinite recursion -->
				<xsl:if test="contains($dirname,$breadcrumbStart)">
					<xsl:call-template name="bc-folders">
						<xsl:with-param name="path" select="$dirname"/>
						<xsl:with-param name="show-current-crumb" select="$show-current-crumb" />
					</xsl:call-template>	
				</xsl:if>

				<!-- if the file is not the index page, display the final crumb -->
				<xsl:if test="not(contains($ou:filename,concat('default','.'))) and $show-current-crumb">
					<xsl:choose>
						<xsl:when test="$custom-breadcrumb-title != ''">
						  <li class="breadcrumb-item"><xsl:value-of select="ou:decode-entities($custom-breadcrumb-title)" /></li>
						</xsl:when>
						<xsl:otherwise>
						  <li class="breadcrumb-item"><xsl:value-of select="ou:decode-entities($page-title)" /></li>
						</xsl:otherwise>
					</xsl:choose>
					
				</xsl:if>
			</ol>
		</nav>
	</xsl:template>
	
	<xsl:template name="bc-folders">
	  <xsl:param name="path" />
	  <xsl:param name="show-current-crumb" select="true()" />

	  <xsl:variable name="this-index-path" select="concat($ou:root, $ou:site, $path, 'default.pcf')" />

	  <!-- Load the index doc for THIS folder -->
	  <xsl:variable name="index-doc" as="document-node()?"
		select="if (doc-available($this-index-path)) then doc($this-index-path) else ()" />

	  <!-- Title from THAT folder's default.pcf -->
	  <xsl:variable name="breadcrumb-title" select="
		normalize-space((
		  $index-doc/document/ouc:properties[@label='config']/parameter[@name='BrcPageTitle'],
		  $index-doc/document/ouc:properties[@label='metadata']/title
		)[normalize-space(.)][1])
	  " />

	  <xsl:if test="$path != $breadcrumbStart">
		<xsl:call-template name="bc-folders">
		  <xsl:with-param name="path" select="ou:findPrevDir($path)" />
		  <xsl:with-param name="show-current-crumb" select="$show-current-crumb" />
		</xsl:call-template>
	  </xsl:if>

	  <!-- Only output a crumb if default.pcf exists AND we got a usable title (or it's the home crumb) -->
	  <xsl:if test="$path = '/' or ($index-doc and normalize-space($breadcrumb-title) != '')">
		<xsl:choose>
		  <xsl:when test="$path = '/'">
			<li class="breadcrumb-item"><a href="/"><span class="fa fa-home"></span><span class="sr-only">Home Icon</span></a></li>
		  </xsl:when>

		  <xsl:when test="$path = $dirname and contains($ou:filename,'default.') and $show-current-crumb">
			<li class="breadcrumb-item active" aria-current="page"><xsl:value-of select="ou:decode-entities($breadcrumb-title)"/></li>
		  </xsl:when>

		  <xsl:otherwise>
			<li class="breadcrumb-item"><a href="{concat($link-start,$path)}"><xsl:value-of select="ou:decode-entities($breadcrumb-title)"/></a></li>
		  </xsl:otherwise>
		</xsl:choose>
	  </xsl:if>

	</xsl:template>
	
	
	
	
	
	
	
	<!-- LEGACY BREADCRUMBS circa pre Fall 2025 -->
    <xsl:template name="legacyBreadcrumbs">
		
        <!-- removes the / from the dirname for the if statement below -->
        <xsl:param name="firstdirtest" select="substring(concat('/',tokenize($dirname,'/')[2]),2)" />
        <xsl:param name="Title" select="document/ouc:properties[@label='metadata']/title" />
        <xsl:param name="BrcPageTitle" select="document/ouc:properties[@label='config']/parameter[@name='BrcPageTitle']/text()" />
		<xsl:variable name="show-current-crumb" select="normalize-space($BrcPageTitle) != '' or ou:pcf-param('custom-hero') = 'enabled'" />
        
        
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
                
                <nav aria-label="breadcrumb" id="BreadcrumbList" class="mb-3">
                    <xsl:choose>
                        <xsl:when test="(normalize-space($division_title)='' and normalize-space($dept_title)='')">
                            <ol vocab="http://schema.org/" typeof="BreadcrumbList" class="breadcrumbs breadcrumb">
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/" title="College Home">
                                        <span property="name"><span class="fa fa-home"><span class="sr-only">Home</span></span></span>
                                    </a>
                                    <meta property="position" content="1" />
                                </li>
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/{$subsite_folder}/default.htm">
                                        <span property="name">
                                            <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                                        </span>
                                    </a>
                                    <meta property="position" content="2" />
                                </li>
								<xsl:if test="$show-current-crumb">
									<li property="itemListElement" class="breadcrumb-item active" aria-current="page" typeof="ListItem">
										<span property="name" class="title">
											<xsl:value-of select="$page_title" disable-output-escaping="yes" />
										</span>
										<meta property="position" content="3" />
									</li>
								</xsl:if>
                            </ol>
                        </xsl:when>
                        <xsl:when test="(normalize-space($division_title)!='' and normalize-space($dept_title)='')">
                            <ol vocab="http://schema.org/" typeof="BreadcrumbList" class="breadcrumbs breadcrumb">
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/" title="College Home">
                                        <span property="name"><span class="fa fa-home"><span class="sr-only">Home</span></span></span>
                                    </a>
                                    <meta property="position" content="1" />
                                </li>
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/{$division_folder}/default.htm">
                                        <span property="name">
                                            <xsl:value-of select="$division_title" disable-output-escaping="yes" />
                                        </span>
                                    </a>
                                    <meta property="position" content="2" />
                                </li>
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/{$subsite_folder}/default.htm">
                                        <span property="name" >
                                            <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                                        </span>
                                    </a>
                                    <meta property="position" content="3" />
                                </li>
								<xsl:if test="$show-current-crumb">
									<li property="itemListElement" class="breadcrumb-item active" aria-current="page" typeof="ListItem">
										<span property="name" class="title">
											<xsl:value-of select="$page_title" disable-output-escaping="yes" />
										</span>
										<meta property="position" content="4" />
									</li>
								</xsl:if>
                            </ol>
                        </xsl:when>
                        <xsl:when test="(normalize-space($division_title)='' and normalize-space($dept_title)!='')">
                            <ol vocab="http://schema.org/" typeof="BreadcrumbList" class="breadcrumbs breadcrumb">
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/" title="College Home">
                                        <span property="name"><span class="fa fa-home"><span class="sr-only">Home</span></span></span>
                                    </a>
                                    <meta property="position" content="1" />
                                </li>
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/{$dept_folder}/default.htm">
                                        <span property="name">
                                            <xsl:value-of select="$dept_title" disable-output-escaping="yes" />
                                        </span>
                                    </a>
                                    <meta property="position" content="2" />
                                </li>
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/{$subsite_folder}/default.htm">
                                        <span property="name">
                                            <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                                        </span>
                                    </a>
                                    <meta property="position" content="3" />
                                </li>
								<xsl:if test="$show-current-crumb">
									<li property="itemListElement" class="breadcrumb-item active" aria-current="page" typeof="ListItem">
										<span property="name" class="title">
											<xsl:value-of select="$page_title" disable-output-escaping="yes" />
										</span>
										<meta property="position" content="4" />
									</li>
								</xsl:if>
                            </ol>
                        </xsl:when>
                        <xsl:otherwise>
                            <ol vocab="http://schema.org/" typeof="BreadcrumbList" class="breadcrumbs breadcrumb">
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/" title="College Home">
                                        <span property="name"><span class="fa fa-home"><span class="sr-only">Home</span></span></span>
                                    </a>
                                    <meta property="position" content="1" />
                                </li>
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/{$division_folder}/default.htm">
                                        <span property="name">
                                            <xsl:value-of select="$division_title" disable-output-escaping="yes" />
                                        </span>
                                    </a>
                                    <meta property="position" content="2" />
                                </li>
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/{$dept_folder}/default.htm">
                                        <span property="name">
                                            <xsl:value-of select="$dept_title" disable-output-escaping="yes" />
                                        </span>
                                    </a>
                                    <meta property="position" content="3" />
                                </li>
                                <li property="itemListElement" class="breadcrumb-item" typeof="ListItem">
                                    <a property="item" typeof="WebPage" href="/{$subsite_folder}/default.htm">
                                        <span property="name">
                                            <xsl:value-of select="$subsite_title" disable-output-escaping="yes" />
                                        </span>
                                    </a>
                                    <meta property="position" content="4" />
                                </li>
								<xsl:if test="$show-current-crumb">
									<li property="itemListElement" class="breadcrumb-item active"  aria-current="page" typeof="ListItem">
										<span property="name" class="title">
											<xsl:value-of select="$page_title" disable-output-escaping="yes" />
										</span>
										<meta property="position" content="5" />
									</li>
								</xsl:if>
                            </ol>
                        </xsl:otherwise>
                    </xsl:choose>
                </nav>
            </xsl:if>
        </xsl:for-each>
        
    </xsl:template>

</xsl:stylesheet>
