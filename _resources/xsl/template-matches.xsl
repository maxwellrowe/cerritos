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
	exclude-result-prefixes="xsl xs ou ouc f">
	
	<!--	** Identity template matches **
			The following templates handle all possible conditions processed with an xsl:apply-templates.
			The default behavior is to copy the content, but allows the ability to overwrite behavior with specific template matches.
			These templates should not be altered.
	-->
	
	<!-- 	The following template matches all elements, rewrites them in the current namespace, then processes any attributes and children it may have. -->
	<xsl:template match="element()">
		<xsl:element name="{name()}">
			<xsl:apply-templates select="attribute()|node()" />
		</xsl:element>
	</xsl:template>
	
	<!-- 	The following template matches all attributes and comments and copies them. No need to do anything else. -->	  
	<xsl:template match="attribute()|comment()">
		<xsl:copy />
	</xsl:template>
	
	<!-- 	The following template matches processing instructions. Default behavior is set to output PHP. 
			Because of behavior of the HTML output method, a question mark is added before the closing node. -->
	<xsl:template match="processing-instruction()">
		<xsl:processing-instruction name="php">
			<xsl:value-of select="." />
			?</xsl:processing-instruction>
	</xsl:template>
	
	<!--	** OUC specific template matches: handles elements with the ouc namespace.  These include the ouc:div and ouc:editor tags which are used for editable regions. -->
		
	<!--	The following template matches any element within the ouc namespace while not in edit mode. The template only apply-templates to its children (if any).
			The purpose of this template is to skip writing out any elements in the ouc namespace when publishing or previewing the page. Allows for cleaner, valid content.
	-->
	<xsl:template match="ouc:*[$ou:action !='edt']">
		<xsl:apply-templates />
	</xsl:template>	
	
	<!-- 	This template matches ouc:div elements, which are editable regions. 
			The template copies the node and its attributes, allowing the editable region buttons to display on the page (only in edit mode, as allowed by the template above).
			It also injects the wysiwyg-class attribute with value of the parameter $bodyClass	which allows a class to be added for dynamic third level tagging.
			The $bodyClass parameter is initialized in ou-variables.xsl
	-->
	<xsl:template match="ouc:div">
		<xsl:copy>
			<xsl:attribute name="wysiwyg-class"><xsl:value-of select="$layout-class" /></xsl:attribute>
			<xsl:apply-templates select="attribute()|node()" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="ouc:div[$ou:action = 'edt' and (child::ouc:editor/attribute::wysiwyg='asset' or child::ouc:editor/attribute::wysiwyg='gallery') and string-length(.) = 0]">
		<xsl:copy><xsl:apply-templates select="node()|attribute()" /></xsl:copy>
		<p><em>No asset is currently selected. Please use the edit button to choose an asset for this region.</em></p>
	</xsl:template>
		
	<!-- Two column - flex snippet -->
	<xsl:template match="table[@class='two-column-flex']">
		<div class="row">
			<div class="small-12 medium-6 columns">
				<xsl:apply-templates select="tbody/tr[@class='content']/td[1]" />
			</div>
			<div class="small-12 medium-6 columns">
				<xsl:apply-templates select="tbody/tr[@class='content']/td[2]" />
			</div>
		</div>			
	</xsl:template>
		
	
	<!--	LDP Image Gallery template match
			Defines the default behavior of an LDP image gallery asset (in this case, thumbnails).  This can be targeted by a javascript lightbox.
			When an LDP Image Gallery asset is dropped on a PCF, the code rendered is XML. The XML structure can be seen when previewing the asset.
	-->
	<xsl:template match="gallery">
		<div class="thumb gallery">
			<xsl:apply-templates select="images/image" />	
		</div>
	</xsl:template>

	<xsl:template match="images/image">
		<a class="th" href="{@url}" title="{title}"><img src="{thumbnail/@url}" alt="{description}" /></a>
	</xsl:template>

	<!-- Slick slide -->
	<xsl:template match="gallery[ancestor::ouc:div/attribute::ldp-type = 'slide']">
	    <link rel="stylesheet" type="text/css" href="{{f:80151088}}"/>
	    <link rel="stylesheet" type="text/css" href="{{f:80151087}}"/>
		<div class="gallery slide">
			<xsl:apply-templates select="images/image" mode="ldp-slide" />
		</div>
	    <script type="text/javascript" src="{{f:80151165}}"></script>
	    <script type="text/javascript">
	        $(document).ready(function(){
	        $('.slide').slick({
	        dots: true,
	        infinite: true,
	        speed: 300,
	        slidesToShow: 3,
	        slidesToScroll: 3,
	        responsive: [
	        {
	        breakpoint: 1024,
	        settings: {
	        slidesToShow: 3,
	        slidesToScroll: 3,
	        infinite: true,
	        dots: true
	        }
	        },
	        {
	        breakpoint: 600,
	        settings: {
	        slidesToShow: 2,
	        slidesToScroll: 2
	        }
	        },
	        {
	        breakpoint: 480,
	        settings: {
	        slidesToShow: 1,
	        slidesToScroll: 1
	        }
	        }
	        // You can unslick at a given breakpoint now by adding:
	        // settings: "unslick"
	        // instead of a settings object
	        ]
	        });
	        });
	    </script>
	</xsl:template>
	
	<xsl:template match="images/image" mode="ldp-slide">
		<div>
			<a href="{@url}" class="th"><img src="{@url}" alt="{description}" /></a>
		</div>
	</xsl:template>		

	<!-- Flex slider -->
	<xsl:template match="gallery[ancestor::ouc:div/attribute::ldp-type = 'flexslider']">
		<xsl:param name="class">flexslider</xsl:param>
		<div class="{$class} small-12 columns">
			<section class="slider">
				<ul class="slides">
					<xsl:apply-templates select="images/image" mode="flexslider" />
				</ul>
			</section>
		</div>
	    <script type="text/javascript" charset="utf-8">
	        $(window).load(function() {
	        $('.flexslider').flexslider();
	        });
	    </script>
	</xsl:template>
	
	<xsl:template match="images/image" mode="flexslider">
		<li>
		    <xsl:choose>
		        <xsl:when test="link != ''">
		            <a href="{link}"><img src="{@url}" alt="{title}" />
		            <xsl:if test="title != ''">
		                <p class="flex-caption">
		                    <xsl:value-of select="title" />
		                </p>
		            </xsl:if>
		            </a>
		        </xsl:when>
		        <xsl:otherwise>
		            <img src="{@url}" alt="{title}" />
		            <xsl:if test="title != ''">
		                <p class="flex-caption">
		                    <xsl:value-of select="title" />
		                </p>
		            </xsl:if>
		        </xsl:otherwise>
		    </xsl:choose>
		    
		    <!-- #44862 - commented out original code -->
			<!--<img src="{@url}" alt="{description}" />
			<div class="flex-caption">
				<xsl:if test="string-length(title) gt 1">
					<p class="title"><xsl:value-of select="title" /></p><br />
				</xsl:if>
				<xsl:if test="string-length(description) gt 1">
					<p class="description"><xsl:value-of select="description" /></p>								
				</xsl:if>
			</div>-->
		</li>
	</xsl:template>
		
	<!--	** Miscellaneous template matches** -->
	
	<!--	The following template matches a php node, which can be defined in assets to output server-side processes. It will display a friendly message while in staging. -->
		<xsl:template match="php">
			<xsl:choose>
				<xsl:when test="$ou:action = 'pub'">
					<xsl:processing-instruction name="php">
						<xsl:value-of select="." disable-output-escaping="yes" />
					?</xsl:processing-instruction>
				</xsl:when>
				<xsl:otherwise>
					<p>							
						Server-side code<xsl:if test="@label"> (<strong><xsl:value-of select="@label" /></strong>)</xsl:if> has been placed here. It will display when this page is published on the production server.
					</p>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:template>
		
	<!--	The following allows for a visual warning for broken dependencies tags in hyperlinks. -->
	<xsl:template match="a[contains(@href,'*** Broken')]">
		<span style="color: red;"><a href="{@href}"><xsl:value-of select="."/></a> [BROKEN LINK]</span>
	</xsl:template>
	
	<!--	The following ignores output of the pcf-stylesheet processing instruction found at the top of all PCF files. -->
	<xsl:template match="processing-instruction('pcf-stylesheet')" />
	
	<!--	Some snippets contain table transformations to achieve the proper output. Best practice is to add a verbal spacer at the end of each table to make it easier to add content after the table. -->
	<xsl:template match="h3[@class='wysiwyg-spacer']" />
		
	<!-- -->
	<xsl:template match="a[@class='iframe']">
		<iframe src="{@href}" width="100%" height="1000" frameborder="0"></iframe>
	</xsl:template>
	

<!--
<table class="ou-snippet ou-title-bar">
	<caption>Title Bar</caption>
	<colgroup>
		<col class="ou-prompt" />
		<col class="ou-prompt" />
	</colgroup>
	<tbody>
		<tr class="ou-heading">
			<td class="ou-prompt">Heading</td>
			<td class="ou-value">Tool Kit</td>
		</tr>
		<tr class="ou-icon">
			<td class="ou-prompt">Icon</td>
			<td class="ou-value">fa-wrench</td>
		</tr>
	</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

<xsl:template match="table[contains(@class, 'ou-title-bar')]">
	<h3 class="title-bar">
		<span class="fa {tbody/tr[@class = 'ou-icon']/td[@class = 'ou-value']}" aria-hidden="true"></span>
		<xsl:apply-templates select="tr[@class = 'ou-heading']/node()" />
	</h3>
</xsl:template>



<!--
<table class="ou-snippet ou-announcements">
	<caption>Announcements</caption>
	<colgroup>
		<col class="ou-prompt" />
		<col class="ou-prompt" />
	</colgroup>
	<tbody>
		<tr class="ou-heading">
			<td class="ou-prompt">Heading</td>
			<td class="ou-value">Announcements</td>
		</tr>
		<tr class="ou-item">
			<td class="ou-prompt">Item</td>
			<td class="ou-value">
				<h3>Title</h3>
				<p>Text</p>
				<p><a href="">Learn more</a></p>
			</td>
		</tr>
		 <tr class="ou-item">
			<td class="ou-prompt">Item</td>
			<td class="ou-value">
				<h3>Title</h3>
				<p>Text</p>
				<p><a href="">Learn more</a></p>
			</td>
		</tr>
	</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

<xsl:template match="table[contains(@class, 'ou-announcements')]">
	<div class="announcements">
		<h3 class="title-bar"><span class="fa fa-bullhorn" aria-hidden="true"></span><xsl:apply-templates select="td[@class = 'ou-heading']/node()" /></h3>
		<div class="owl-carousel-announcements">

			<xsl:for-each select="tbody/tr[@class = 'ou-item']">
				<div class="item">
					<xsl:apply-templates select="td[@class = 'ou-value']/node()" />
				</div>
			</xsl:for-each>

		</div>
	</div>
</xsl:template>

<!--
<table class="ou-snippet ou-container-events">
	<caption>Events</caption>
	<colgroup>
		<col class="ou-prompt" />
		<col class="ou-prompt" />
	</colgroup>
	<tbody>
		<tr class="ou-heading">
			<td class="ou-prompt">Heading</td>
			<td class="ou-value">Events</td>
		</tr>
		 <tr class="ou-link">
			<td class="ou-prompt">link</td>
			<td class="ou-value"><a href="#">View //Calendar</a></td>
		</tr>
		<tr class="ou-events">
			<td class="ou-prompt">Events</td>
			<td class="ou-value">

			</td>
		</tr>
	</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

<xsl:template match="table[contains(@class, 'ou-container-events')]">
	<div class="events-list">
		<h3 class="title-bar">
			<span class="fa fa-calendar" aria-hidden="true"></span>
			<xsl:apply-templates select="tbody/tr[@class = 'ou-heading']/td[@class = 'ou-value']" />
			<span class="view-calendar">
				<a href="{tbody/tr[@class = 'ou-link']/td[@class = 'ou-value']//a[1]/@href}">
					<xsl:apply-templates select="tbody/tr[@class = 'ou-link']/td[@class = 'ou-value']//a[1]" mode="insert-br" />
				</a>
			</span>
		</h3>
	</div>
	<div class="events">

		<xsl:apply-templates select="tbody/tr[@class = 'ou-events']/td[@class = 'ou-value']//table[contains(@class, 'ou-event')]" />

	</div>
</xsl:template>

<xsl:template match="a/text()" mode="insert-br">
	<xsl:analyze-string select="." regex="{' '}">
		<xsl:matching-substring>
			<xsl:element name="br" />
		</xsl:matching-substring>
		<xsl:non-matching-substring>
			<xsl:value-of select="."/>
		</xsl:non-matching-substring>
	</xsl:analyze-string>
</xsl:template>

<!--
<table class="ou-snippet ou-accordion"><caption>Accordion</caption><colgroup> <col class="ou-prompt" /> <col class="ou-prompt" /> </colgroup>
<tbody>
	<tr class="ou-prompt">
		<td class="ou-prompt" style="width: 20%;">Title</td>
		<td class="ou-prompt">Content</td>
	</tr>
	<tr class="ou-panel">
		<td class="ou-title ou-value" style="width: 20%;">Title</td>
		<td class="ou-content ou-value">
			<p>Text</p>
			<p>Text</p>
		</td>
	</tr>
	<tr class="ou-panel">
		<td class="ou-title ou-value" style="width: 20%;">Title</td>
		<td class="ou-content ou-value">
			<p>Text</p>
			<p>Text</p>
			<p>Text</p>
		</td>
	</tr>
</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

 <!-- ========== ACCORDION ========== -->	
    <xsl:template match="table[contains(@class, 'ou-accordion')]">
        <!--Changed to accoridon code for ticket 182239 -->
		<xsl:variable name="accordion-id" select="'accordion-' || generate-id()"/>
		<div id="{$accordion-id}" class="panel-group">
			<xsl:for-each select="tbody/tr[@class = 'ou-panel']">
				<xsl:variable name="item-id" select="'item-' || generate-id()"/>
				<div class="panel panel-default card">
						<div id="{$item-id}-headingOne" class="panel-heading">

							<h3 class="panel-title"><button class="btn btn-link accordion-trigger collapsed" role="button" data-toggle="collapse" data-target="#{$item-id}-collapseOne" aria-expanded="false" aria-controls="{$item-id}-collapseOne" style="font-size:20px; font-weight:800;"><xsl:apply-templates select="td[contains(@class, 'ou-title')]/node()"/></button></h3>
					</div>												

						<div id="{$item-id}-collapseOne" class=" panel-collapse collapse" aria-labelledby="{$item-id}-headingOne" data-parent="#{$accordion-id}">
							<div class="panel-body">
								<xsl:apply-templates select="td[contains(@class, 'ou-content')]/node()" />
							</div>
					</div>
				</div>

			</xsl:for-each>
		</div>
    </xsl:template>
    <!-- ========== END ACCORDION ========== -->



<!--
<table class="ou-snippet ou-content-feature-box-icon-title-text">
	<caption>Content Boxes</caption>
	<colgroup>
		<col class="ou-prompt" />
		<col class="ou-prompt" />
	</colgroup>
	<tbody>
		<tr class="ou-prompt">
			<td class="ou-prompt">Icon Class</td>
			<td class="ou-prompt">Link</td>
			<td class="ou-prompt">Content</td>
		</tr>
		<tr class="ou-box">
			<td class="ou-icon-class ou-value">fa-globe</td>
			<td class="ou-icon-link ou-value"><a href="#">Web Portal</a></td>
			<td class="ou-content ou-value"><p>The WebPortal serves admission, enrollment, and registration needs across campus.</p></td>
		</tr>
		<tr class="ou-box">
			<td class="ou-icon-class ou-value">fa-gear</td>
			<td class="ou-icon-link ou-value"><a href="#">Title</a></td>
			<td class="ou-content ou-value"><p>Text</p></td>
		</tr>
		<tr class="ou-box">
			<td class="ou-icon-class ou-value">fa-users</td>
			<td class="ou-icon-link ou-value"><a href="#">Training</a></td>
			<td class="ou-content ou-value"> <p>Find training that’s right for you.</p></td>
		</tr>
	</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

<xsl:template match="table[contains(@class, 'ou-content-feature-box-icon-title-text')]">
	<div class="row flex">

		<xsl:for-each select="tbody/tr[@class = 'ou-box']">

			<div class="col-md-4">
				<div class="feature-box">
					<span class="fa {td[contains(@class,'ou-icon-class')]}" aria-hidden="true"></span>
					<div class="title"><xsl:apply-templates select="td[contains(@class,'ou-icon-link')]/a" /></div>
					<xsl:apply-templates select="td[contains(@class,'ou-content')]/node()" />
				</div>
			</div>

		</xsl:for-each>

	</div><xsl:comment>End Row</xsl:comment>
</xsl:template>



<!--
<table class="ou-snippet ou-light-blue-well">
<caption>Light Blue Well</caption><colgroup> <col class="ou-prompt" /></colgroup>
<tbody>
	<tr class="ou-prompt">
		<td class="ou-prompt">Content</td>
	</tr>
	<tr class="ou-content">
		<td class="ou-text ou-value">
				<p>text</p>
		</td>
	</tr>
</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

<xsl:template match="table[contains(@class, 'ou-light-blue-well')]">
		<div class="well blue">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-text')]/node()" />
		</div>
</xsl:template>

<!--
<table class="ou-snippet ou-dark-blue-well">
<caption>Dark Blue Well</caption><colgroup> <col class="ou-prompt" /></colgroup>
<tbody>
	<tr class="ou-prompt">
		<td class="ou-prompt">Content</td>
	</tr>
	<tr class="ou-content">
		<td class="ou-text ou-value">
				<p>text</p>
		</td>
	</tr>
</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

<xsl:template match="table[contains(@class, 'ou-dark-blue-well')]">
		<div class="well">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-text')]/node()" />
		</div>
</xsl:template>
	
	<!--
<table class="ou-snippet ou-dark-blue-heading">
<caption>Dark Blue Heading</caption><colgroup> <col class="ou-prompt" /></colgroup>
<tbody>
	<tr class="ou-prompt">
		<td class="ou-prompt">Content</td>
	</tr>
	<tr class="ou-content">
		<td class="ou-text ou-value">
				<p>text</p>
		</td>
	</tr>
</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

<xsl:template match="table[contains(@class, 'ou-dark-blue-heading')]">
		<div class="block">
                  <h3><span>
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-text')]/node()" />
					  </span>
			</h3>
		</div>
</xsl:template>


<!--
<table class="ou-snippet ou-2-column-layout">
<caption>2 Column Layout</caption><colgroup> <col class="ou-prompt" /> <col class="ou-prompt" /> </colgroup>
<tbody>
	<tr class="ou-prompt">
		<td class="ou-prompt">Column 1</td>
		<td class="ou-prompt">Column 2</td>
	</tr>
	<tr class="ou-content">
		<td class="ou-column-1 ou-value">
				<p>text</p>
		</td>
		<td class="ou-column-2 ou-value">
			 	<p>text</p>
		</td>
	</tr>
</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

<xsl:template match="table[contains(@class, 'ou-2-column-layout')]">
	<div class="row">
		<div class="col-md-6">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-1')]/node()" />
		</div>
		<div class="col-md-6">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-2')]/node()" />
		</div>
	</div>
</xsl:template>
	
	
	<xsl:template match="table[contains(@class, 'ou-2-column-8-4-layout')]">
	<div class="row">
		<div class="col-md-8">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-1')]/node()" />
		</div>
		<div class="col-md-4">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-2')]/node()" />
		</div>
	</div>
</xsl:template>
	
	<xsl:template match="table[contains(@class, 'ou-2-column-8-4-layout-reverse-mobile')]">
	<div class="row">
		<div class="col-md-4 col-md-push-8">
					<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-1')]/node()" />
				</div>
				<div class="col-md-8 col-md-pull-4">
					<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-2')]/node()" />
				</div>
	</div>
</xsl:template>
	
	<xsl:template match="table[contains(@class, 'ou-2-column-3-9-layout')]">
	<div class="row">
		<div class="col-md-2">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-1')]/node()" />
		</div>
		<div class="col-md-10">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-2')]/node()" />
		</div>
	</div>
</xsl:template>

<!--
<table class="ou-snippet ou-3-column-layout">
<caption>3 Column Layout</caption><colgroup> <col class="ou-prompt" /> <col class="ou-prompt" /> </colgroup>
<tbody>
	<tr class="ou-prompt">
		<td class="ou-prompt">Column 1</td>
		<td class="ou-prompt">Column 2</td>
		<td class="ou-prompt">Column 3</td>
	</tr>
	<tr class="ou-content">
		<td class="ou-column-1 ou-value">
				<p>text</p>
		</td>
		<td class="ou-column-2 ou-value">
			 	<p>text</p>
		</td>
		<td class="ou-column-3 ou-value">
			 	<p>text</p>
		</td>
	</tr>
</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

<xsl:template match="table[contains(@class, 'ou-3-column-layout')]">
	<div class="row">
		<div class="col-md-4">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-1')]/node()" />
		</div>
		<div class="col-md-4">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-2')]/node()" />
		</div>
		<div class="col-md-4">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-3')]/node()" />
		</div>
	</div>
</xsl:template>
	
	
	<xsl:template match="table[contains(@class, 'ou-3-column-layout-wide-center')]">
	<div class="row">
		<div class="col-md-2">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-1')]/node()" />
		</div>
		<div class="col-md-8">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-2')]/node()" />
		</div>
		<div class="col-md-2">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-3')]/node()" />
		</div>
	</div>
</xsl:template>

<!--
<table class="ou-snippet ou-4-column-layout">
<caption>4 Column Layout</caption><colgroup> <col class="ou-prompt" /> <col class="ou-prompt" /> </colgroup>
<tbody>
	<tr class="ou-prompt">
		<td class="ou-prompt">Column 1</td>
		<td class="ou-prompt">Column 2</td>
		<td class="ou-prompt">Column 3</td>
		<td class="ou-prompt">Column 4</td>
	</tr>
	<tr class="ou-content">
		<td class="ou-column-1 ou-value">
				<p>text</p>
		</td>
		<td class="ou-column-2 ou-value">
			 	<p>text</p>
		</td>
		<td class="ou-column-3 ou-value">
			 	<p>text</p>
		</td>
		<td class="ou-column-4 ou-value">
			 	<p>text</p>
		</td>
	</tr>
</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

<xsl:template match="table[contains(@class, 'ou-4-column-layout')]">
	<div class="row">
		<div class="col-md-3">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-1')]/node()" />
		</div>
		<div class="col-md-3">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-2')]/node()" />
		</div>
		<div class="col-md-3">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-3')]/node()" />
		</div>
		<div class="col-md-3">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-4')]/node()" />
		</div>
	</div>
</xsl:template>

<!--
<table class="ou-snippet ou-6-column-layout">
<caption>6 Column Layout</caption><colgroup> <col class="ou-prompt" /> <col class="ou-prompt" /> </colgroup>
<tbody>
	<tr class="ou-prompt">
		<td class="ou-prompt">Column 1</td>
		<td class="ou-prompt">Column 2</td>
		<td class="ou-prompt">Column 3</td>
		<td class="ou-prompt">Column 4</td>
		<td class="ou-prompt">Column 5</td>
		<td class="ou-prompt">Column 6</td>
	</tr>
	<tr class="ou-content">
		<td class="ou-column-1 ou-value">
				<p>text</p>
		</td>
		<td class="ou-column-2 ou-value">
			 	<p>text</p>
		</td>
		<td class="ou-column-3 ou-value">
			 	<p>text</p>
		</td>
		<td class="ou-column-4 ou-value">
			 <p>text</p>
		</td>
		<td class="ou-column-5 ou-value">
			 	<p>text</p>
		</td>
		<td class="ou-column-6 ou-value">
			 <p>text</p>
		</td>
	</tr>
</tbody>
</table>
<h4 class="wysiwyg-spacer"><small class="label label-warning"><i class="glyphicon glyphicon-pencil">&nbsp;</i> Press Enter to add more content</small></h4>
-->

<xsl:template match="table[contains(@class, 'ou-6-column-layout')]">
	<div class="row">
		<div class="col-md-2">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-1')]/node()" />
		</div>
		<div class="col-md-2">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-2')]/node()" />
		</div>
		<div class="col-md-2">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-3')]/node()" />
		</div>
		<div class="col-md-2">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-4')]/node()" />
		</div>
		<div class="col-md-2">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-5')]/node()" />
		</div>
		<div class="col-md-2">
			<xsl:apply-templates select="tbody/tr[@class = 'ou-content']/td[contains(@class, 'ou-column-6')]/node()" />
		</div>
	</div>
</xsl:template>
	
<!--
<table id="ou-snippet" class="ou-tabs">
	<caption>Tabs<br/><p>The first tab will default to open.</p></caption>
	<thead>
		<tr>
			<th class="ou-help" style="width:25%;">Title</th>
			<th class="ou-help">Content</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td class="title">Sample Title 1</td>
			<td class="content"><p>One Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Curabitur blandit tempus porttitor.</p></td>
		</tr>
		<tr>
			<td class="title">Sample Title 2</td>
			<td class="content"><p>Two Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Curabitur blandit tempus porttitor.</p></td>
		</tr>
		<tr>
			<td class="title">Sample Title 3</td>
			<td class="content"><p>Three Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Curabitur blandit tempus porttitor.</p></td>
		</tr>
		<tr>
			<td class="title">Sample Title 4</td>
			<td class="content"><p>Four Vivamus sagittis lacus vel augue laoreet rutrum faucibus dolor auctor. Duis mollis, est non commodo luctus, nisi erat porttitor ligula, eget lacinia odio sem nec elit. Curabitur blandit tempus porttitor.</p></td>
		</tr>
	</tbody>
</table>
<h4 class="wysiwyg-spacer">Press Enter to add more content</h4>
-->
<xsl:template match="table[@class='ou-tabs']">
	<xsl:variable name="unique" select="generate-id(.)" />
	<ul class="nav nav-tabs margin-top-40"  role="tablist">
		<xsl:for-each select="tbody/tr">
			<xsl:variable name="title" select="td[@class='title']" />
		<li role="presentation" class="{if (position()=1) then ' active' else ''}">
			<a href="#tab{concat(position(),'-',$unique)}" aria-controls="tab{concat(position(),'-',$unique)}" role="tab" data-toggle="tab" aria-expanded="{if (position()=1) then 'true' else 'false'}"><xsl:value-of select="$title" /></a>
		</li>
		</xsl:for-each>
	</ul>
	<div class="tab-content">
		<xsl:for-each select="tbody/tr">
			<xsl:variable name="title" select="td[@class='title']" />
		<div class="tab-pane{if (position()=1) then ' active' else ''}" id="{concat('tab',position(),'-',$unique)}" role="tabpanel">
			<xsl:apply-templates select="td[@class='content']/node()" />
		</div>
		</xsl:for-each>
	</div>
</xsl:template>
    
    
    <!-- displays boxes for the calendar content as originally presented in /campus-guide/academic-calendar.pcf -->
    <xsl:template match="table[@class='ou-calendar-boxes']">
        <div class="ac_container">
            <xsl:for-each select="tbody/tr">
                <div class="ac_box"><xsl:value-of select="td[1]" /><xsl:if test="ou:textual-content(td[2]) != ''"><br /><xsl:value-of select="td[2]" /></xsl:if><xsl:if test="ou:textual-content(td[3]) != ''"> -<br /><xsl:value-of select="td[3]" /></xsl:if></div>
            </xsl:for-each>
        </div>
        <p class="clear">&nbsp;</p>
    </xsl:template>

    <!-- outputs the calendar listing -->
    <xsl:template match="ou-calendar">
        <ul id="calendarEvents">
            <xsl:choose>
                <xsl:when test="$ou:action = 'pub'">
                    <script>
                        $("#calendarEvents").load("/_resources/php/wnl/calendar-feed-display.php?feed=<xsl:value-of select="@feed" />&amp;num_items=<xsl:value-of select="@num_items" />");
                    </script><noscript>The calendar requires javascript enabled.</noscript>
                </xsl:when>
                <xsl:otherwise>
                    <div class="col-md-12">
                        <div class="event postcard-left" style="clear: both;display: table;margin-bottom: 15px;position: relative;">
                            <div class="event-text" style="color: #555555;font-size: 16px;line-height: 20px;position: relative;/*! top: -10px; */vertical-align: bottom;">
                                <h4>
                                    Calendar items will be displayed on publish.
                                </h4>
                            </div>
                        </div>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </ul>
    </xsl:template>
	
	<!-- Match for Emergency Alerts archive div message -->
	<xsl:template match="element()[@id='oualerts-archived']" mode="#all">
		<xsl:choose>
			<xsl:when test="$ou:action != 'pub'">
				<div style="padding: 15px; background-color: #FFC5C0; color: #333;">
					<p>Please be aware that the Archived Alert Listing will appear on production in this location. Please be careful to not remove the HTML div from the editable region when editing this page. The div is: &lt;div id="oualerts-archived"&gt;&lt;/div&gt;</p>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:element name="{name()}">
					<xsl:apply-templates select="attribute()" mode="#current"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Match mailto: links that match @cerritos and encode-->
	<!-- Encode using your existing mapping -->
	<xsl:function name="f:encode-like-xsl" as="xs:string">
		<xsl:param name="s" as="xs:string?"/>

		<xsl:sequence select="
		string-join(
			for $cp in string-to-codepoints(lower-case(string($s)))
			let $ch := codepoints-to-string($cp)
			return
			if ($ch='a') then '9'
			else if ($ch='b') then '8'
			else if ($ch='c') then '7'
			else if ($ch='d') then '6'
			else if ($ch='e') then '5'
			else if ($ch='f') then '4'
			else if ($ch='g') then '3'
			else if ($ch='h') then '2'
			else if ($ch='i') then '1'
			else if ($ch='j') then '0'
			else if ($ch='k') then '!'
			else if ($ch='l') then '`'
			else if ($ch='m') then '~'
			else if ($ch='n') then '$'
			else if ($ch='o') then ':'
			else if ($ch='p') then '^'
			else if ($ch='q') then '*'
			else if ($ch='r') then '('
			else if ($ch='s') then ')'
			else if ($ch='t') then '['
			else if ($ch='u') then ']'
			else if ($ch='v') then '|'
			else if ($ch='w') then '/'
			else if ($ch='x') then '\'
			else if ($ch='y') then '-'
			else if ($ch='z') then '_'
			else if ($ch='(') then 'a'
			else if ($ch=')') then 'b'
			else if ($ch='.') then 'c'
			else if ($ch=' ') then 'd'
			else if ($ch='-') then 'e'
			else if ($ch=&quot;'&quot;) then 'f'
			else $ch,
			''
		)
		"/>
	</xsl:function>

	<!-- Rewrite only cerritos.edu mailto links -->
	<xsl:template match="a[starts-with(lower-case(@href), 'mailto:')][contains(lower-case(@href), '@cerritos.edu')]">
		<xsl:variable name="email-full" select="substring-after(@href, 'mailto:')"/>
		<xsl:variable name="email-no-query" select="replace($email-full, '\?.*$', '')"/>
		<xsl:variable name="user" select="substring-before($email-no-query, '@')"/>
		<xsl:variable name="domain" select="substring-after($email-no-query, '@')"/>
		<xsl:variable name="domain-1" select="substring-before($domain, '.')"/>
		<xsl:variable name="domain-2" select="substring-after($domain, '.')"/>

		<span class="email-secure">
		<a href="#"
			class="email-secure-link"
			data-u="{f:encode-like-xsl($user)}"
			data-d1="{f:encode-like-xsl($domain-1)}"
			data-d2="{f:encode-like-xsl($domain-2)}"
			aria-label="Send email">
			<xsl:choose>
			<xsl:when test="normalize-space(.) != ''">
				<xsl:apply-templates/>
			</xsl:when>
			<xsl:otherwise>Email</xsl:otherwise>
			</xsl:choose>
		</a>
		<button type="button"
				class="email-secure-copy"
				data-u="{f:encode-like-xsl($user)}"
				data-d1="{f:encode-like-xsl($domain-1)}"
				data-d2="{f:encode-like-xsl($domain-2)}"
				aria-label="Copy email address">
			<span aria-hidden="true" class="fa-regular fa-copy"></span>
			<span class="sr-only">Copy Email Address</span>
		</button>
		</span>
	</xsl:template>

</xsl:stylesheet>
