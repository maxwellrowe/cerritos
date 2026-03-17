<?xml version="1.0" encoding="utf-8"?>
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
]>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
xmlns="http://www.w3.org/1999/xhtml"
exclude-result-prefixes="ou xsl xs ouc">
	
	

	<!--
	*********** FULL WIDTH TEMPLATE ***********
	This will build on full with column for content and images
	-->
	<xsl:template match="table[@class='ou-one-column-full-width']">
		<xsl:apply-templates select="tbody/tr[@class='heading' and translate(normalize-space(td), '&#160;','')]" />
		<xsl:for-each select="tbody/tr[@class='content']">
			<table class="row">
				<tr>
					<xsl:element name="{$cell}">
						<xsl:attribute name="class" select="'large-12-first large-12-last small-12 large-12 columns'"/>
						<table>
							<tr>
								<xsl:element name="{$cell}">
									<xsl:apply-templates select="td/node()" />
								</xsl:element>
								<xsl:call-template name="expander"/>
							</tr>
						</table>
					</xsl:element>
				</tr>
			</table>
		</xsl:for-each>
	</xsl:template>

	<!--
	*********** 50-50 TEMPLATE ***********
	This will build two equal columns to hold images and content,
	on mobile the left column will stack above the right
	-->
    <xsl:template match="table[@class='ou-two-column-50-50']">
		<xsl:apply-templates select="tbody/tr[@class='heading' and translate(normalize-space(td), '&#160;','')]" />
		<xsl:for-each select="tbody/tr[@class='content']">
			<table class="row">
				<tr>
					<xsl:element name="{$cell}">
						<xsl:attribute name="class" select="'large-6 small-12 columns large-6-first'"/>
						<table>
							<tr>
								<xsl:element name="{$cell}">
									<xsl:apply-templates select="td[1]/node()" />
								</xsl:element>
							</tr>
						</table>
					</xsl:element>
					<xsl:element name="{$cell}">
						<xsl:attribute name="class" select="'large-6 small-12 columns large-6-last'"/>
						<table>
							<tr>
								<xsl:element name="{$cell}">
									<xsl:apply-templates select="td[2]/node()" />
								</xsl:element>
							</tr>
						</table>
					</xsl:element>
					<xsl:call-template name="expander"/>
				</tr>
			</table>
		</xsl:for-each>
	</xsl:template>

	<!--
	*********** TWO COLUMN FLEX LAYOUT TEMPLATE ***********
	This will build a two column layout, the left column is for images,
	the right column for content.  Column width will be determined by the end user in the snippet
	-->
    <xsl:template match="table[@class='ou-two-column-flex']">
		<xsl:variable name="width" select="thead/tr[@class='width']" />
		<xsl:apply-templates select="tbody/tr[@class='heading' and translate(normalize-space(td), '&#160;','')]" />
		<xsl:for-each select="tbody/tr[@class='content']">
			<table class="row">
				<tr>
					<xsl:element name="{$cell}">
						<xsl:attribute name="class" select="'small-12 large-'||$width/th[1]||' columns large-12-first'"/>
						<table>
							<tr>
								<xsl:element name="{$cell}">
									<xsl:apply-templates select="td[1]/node()" />
								</xsl:element>
							</tr>
						</table>
					</xsl:element>
					<xsl:element name="{$cell}">
						<xsl:attribute name="class" select="'small-12 large-'||$width/th[2]||' columns large-12-last'"/>
						<table>
							<tr>
								<xsl:element name="{$cell}">
									<xsl:apply-templates select="td[2]/node()" />
								</xsl:element>
							</tr>
						</table>
					</xsl:element>
					<xsl:call-template name="expander"/>
				</tr>
			</table>
		</xsl:for-each>
	</xsl:template>

	<!--
	*********** SNIPPET HEADINGS ***********
	This template match is used for snippets that have a heading row in their table
	transformations.  It will create a single, full width column with the content
	of the table cell.
	-->
	<xsl:template match="tr[@class='heading']">
		<table class="row">
			<tr>
				<xsl:element name="{$cell}">
					<xsl:attribute name="class" select="'small-12 large-12 columns large-12-first large-12-last'"/>
					<table>
						<tr>
							<xsl:element name="{$cell}">
								<xsl:apply-templates select="td/node()" />
							</xsl:element>
							<xsl:call-template name="expander"/>
						</tr>
					</table>
				</xsl:element>
			</tr>
		</table>
	</xsl:template>

	<!--
	*********** CALLOUT TEMPLATE ***********
	Formly known as panel
	This will build a panel with a background color, for highlighting content
	-->
	<xsl:template match="table[@class='ou-panel']">
		<xsl:param name="color" select="ou:textual-content(thead/tr[@class='color']/th/node())"/>
		<table class="callout">
			<tr>
				<xsl:element name="{$cell}">
					<xsl:attribute name="class" select="'callout-inner callout-'||$color"/>
					<xsl:apply-templates select="tbody/tr[@class='content']/td[1]/node()" />
				</xsl:element>
				<xsl:call-template name="expander"/>
			</tr>
		</table>
	</xsl:template>

	<!--
	*********** PANEL TWO COLUMN FLEX TEMPLATE ***********
	This will build a panel with a background color, for highlighting content.
	Additionally with the ability of a two column flex layout.
	-->
    <xsl:template match="table[@class='ou-panel-two-column-flex']">
    	<xsl:variable name="options" select="thead/tr[@class='options']" />
    	<table class="callout">
    		<tr>
    			<xsl:element name="{$cell}">
    				<xsl:attribute name="class" select="'callout-inner callout-'||$options/th[3]"/>
    				<xsl:apply-templates select="tbody/tr[@class='heading' and translate(normalize-space(td), '&#160;','')]" />
    				<xsl:for-each select="tbody/tr[@class='content']">
    					<table class="row">
    						<tr>
    							<xsl:element name="{$cell}">
    								<xsl:attribute name="class" select="'large-'||$options/th[1]||'-first large-'||$options/th[1]||' small-12 columns'"/>
    								<table>
    									<tr>
    										<xsl:element name="{$cell}">
    											<xsl:apply-templates select="td[1]/node()" />
    										</xsl:element>
    									</tr>
    								</table>
    							</xsl:element>
    							<xsl:element name="{$cell}">
    								<xsl:attribute name="class" select="'large-'||$options/th[2]||'-last large-'||$options/th[2]||' small-12 columns'"/>
    								<table>
    									<tr>
    										<xsl:element name="{$cell}">
    											<xsl:apply-templates select="td[2]/node()" />
    										</xsl:element>
    									</tr>
    								</table>
    							</xsl:element>
    							<xsl:call-template name="expander"/>
    						</tr>
    					</table>
    				</xsl:for-each>
    			</xsl:element>
    			<xsl:call-template name="expander"/>
    		</tr>
    	</table>
	</xsl:template>

	<!--
	*********** FULL_WIDTH BUTTON TEMPLATE ***********
	This will build a button that expands to its parent containers full width on all screen sizes
	-->
    <xsl:template match="table[@class='ou-button-full-width']">
    	<xsl:param name="color" select="ou:textual-content(thead/tr[@class='options']/th[@class='color'])"/>
    	<xsl:param name="size" select="ou:textual-content(thead/tr[@class='options']/th[@class='size'])"/>
    	<xsl:param name="radius" select="ou:textual-content(thead/tr[@class='options']/th[@class='radius'])"/>
    	<xsl:variable name="class">
    		<xsl:value-of select="if($color) then 'button-'||$color||' ' else ''"/>
    		<xsl:value-of select="if($size) then 'button-'||$size||' ' else ''"/>
    		<xsl:value-of select="if($radius) then 'button-'||$radius||' ' else ''"/>
    	</xsl:variable>
    	<table width="100%" class="button button-expanded {$class}">
    		<tr>
    			<td class="button-td">
    				<table width="100%">
    					<tr>
    						<td class="button-td">
    							<center class="button-full"><a href="{tbody/tr[@class='content']/td/descendant::a[1]/@href}"><xsl:value-of select="tbody/tr[@class='content']/td/descendant::a[1]/text()"/></a></center>
    						</td>
    					</tr>
    				</table>
    			</td>
    			<td class="expander"></td>
    		</tr>
    	</table>
	</xsl:template>

	<!--
	*********** CENTERED BUTTON TEMPLATE***********
	This will build a button that is centered on large screens, but on mobile
	will be full width based on the parent container
	-->
	<xsl:template match="table[@class='ou-button-centered']">
		<xsl:param name="color" select="ou:textual-content(thead/tr[@class='options']/th[@class='color'])"/>
		<xsl:param name="size" select="ou:textual-content(thead/tr[@class='options']/th[@class='size'])"/>
		<xsl:param name="radius" select="ou:textual-content(thead/tr[@class='options']/th[@class='radius'])"/>
		<xsl:variable name="class">
			<xsl:value-of select="if($color) then 'button-'||$color||' ' else ''"/>
			<xsl:value-of select="if($size) then 'button-'||$size||' ' else ''"/>
			<xsl:value-of select="if($radius) then 'button-'||$radius||' ' else ''"/>
		</xsl:variable>
		<center class="button-center">
			<table class="button float-center {$class}">
				<tr>
					<td class="button-td">
						<table>
							<tr>
								<td class="button-td">
									<xsl:call-template name="button-td">
										<xsl:with-param name="td" select="tbody/tr[@class='content']/td"></xsl:with-param>
									</xsl:call-template>
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</center>
    	
	</xsl:template>	
	
	<!--Test Left Button-->
	<xsl:template match="table[@class='ou-button-left']">
		<xsl:param name="color" select="ou:textual-content(thead/tr[@class='options']/th[@class='color'])"/>
		<xsl:param name="size" select="ou:textual-content(thead/tr[@class='options']/th[@class='size'])"/>
		<xsl:param name="radius" select="ou:textual-content(thead/tr[@class='options']/th[@class='radius'])"/>
		<xsl:variable name="class">
			<xsl:value-of select="if($color) then 'button-'||$color||' ' else ''"/>
			<xsl:value-of select="if($size) then 'button-'||$size||' ' else ''"/>
			<xsl:value-of select="if($radius) then 'button-'||$radius||' ' else ''"/>
		</xsl:variable>

		<table class="button float-left {$class}">
			<tr>
				<td class="button-td">
					<table>
						<tr>
							<td class="button-td">
								<xsl:call-template name="button-td">
									<xsl:with-param name="td" select="tbody/tr[@class='content']/td"></xsl:with-param>
								</xsl:call-template>
							</td>
						</tr>
					</table>
				</td>
			</tr>
		</table>
	
    	
	</xsl:template>	
	
	<!--
	*********** BLOCK GRID TEMPLATE TWO-UP ***********
	This will build two equal column blocks to hold images and 
	content, on mobile stacking will occur, without	media queries
	-->
    <xsl:template match="table[@class='ou-block-grid-two-up']">
		<xsl:apply-templates select="tbody/tr[@class='heading' and translate(normalize-space(td), '&#160;','')]" />
    	<table class="block-grid up-2">
    		<tr>
    			<xsl:for-each select="tbody/tr[@class='content']">
    				<xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes"> class="column first"&gt;</xsl:text>
    				<xsl:apply-templates select="td[1]/node()" />
    				<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes">&gt;&lt;</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes"> class="column column-last"&gt;</xsl:text>
    				<xsl:apply-templates select="td[2]/node()" />
    				<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
    			</xsl:for-each>
    		</tr>
    	</table>
	</xsl:template>
	
	<!--
	*********** BLOCK GRID TEMPLATE THREE-UP ***********
	This will build three equal column blocks to hold images and 
	content, on mobile stacking will occur, without	media queries
	-->
    <xsl:template match="table[@class='ou-block-grid-three-up']">
		<xsl:apply-templates select="tbody/tr[@class='heading' and translate(normalize-space(td), '&#160;','')]" />
    	<table class="block-grid up-3">
    		<tr>
    			<xsl:for-each select="tbody/tr[@class='content']">
    				<xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes"> class="column first"&gt;</xsl:text>
    				<xsl:apply-templates select="td[1]/node()" />
    				<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes">&gt;&lt;</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes"> class="column"&gt;</xsl:text>
    				<xsl:apply-templates select="td[2]/node()" />
    				<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes">&gt;&lt;</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes"> class="column column-last"&gt;</xsl:text>
    				<xsl:apply-templates select="td[3]/node()" />
    				<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
    			</xsl:for-each>
    		</tr>
    	</table>
	</xsl:template>
	
	<!--
	*********** BLOCK GRID TEMPLATE FOUR-UP ***********
	This will build four equal column blocks to hold images and 
	content, on mobile stacking will occur, without	media queries
	-->
    <xsl:template match="table[@class='ou-block-grid-four-up']">
		<xsl:apply-templates select="tbody/tr[@class='heading' and translate(normalize-space(td), '&#160;','')]" />
    	<table class="block-grid up-4">
    		<tr>
    			<xsl:for-each select="tbody/tr[@class='content']">
    				<xsl:text disable-output-escaping="yes">&lt;</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes"> class="column first"&gt;</xsl:text>
    				<xsl:apply-templates select="td[1]/node()" />
    				<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes">&gt;&lt;</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes"> class="column"&gt;</xsl:text>
    				<xsl:apply-templates select="td[2]/node()" />
    				<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes">&gt;&lt;</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes"> class="column"&gt;</xsl:text>
    				<xsl:apply-templates select="td[3]/node()" />
    				<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes">&gt;&lt;</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes"> class="column column-last"&gt;</xsl:text>
    				<xsl:apply-templates select="td[4]/node()" />
    				<xsl:text disable-output-escaping="yes">&lt;/</xsl:text><xsl:value-of select="$cell"/><xsl:text disable-output-escaping="yes">&gt;</xsl:text>
    			</xsl:for-each>
    		</tr>
    	</table>
	</xsl:template>

	<!-- Simplifies adding spaces after snippets in the WYSIWYG editor. Template does not output anything -->
	<xsl:template match="h3[@class='wysiwyg-spacer']" />

	<!-- Adds the class of "center" to a p tag that preceds an image tag with the class of center -->
	<!--<xsl:template match="p[descendant::img/attribute::class='float-center']">
		<center><xsl:apply-templates/></center>
	</xsl:template>-->
	
	<xsl:template match="p[@class='center']">
		<p class="text-center"><xsl:apply-templates /></p>
	</xsl:template>
	
	<!-- Removes any p tags surrounding img tags -->
	<xsl:template match="p[descendant::img/@class='center']">
		<xsl:apply-templates />
	</xsl:template>
	
	<!-- Applies the correct structure to center an image when the center class is applied to an img -->
	<xsl:template match="img[@class='center']">
		<xsl:param name="ogWidth" select="@width" as="xs:integer"/>
		
		<xsl:variable name="matchWidth" as="xs:integer">
			<xsl:choose>
				<xsl:when test="./ancestor::table/@class = 'ou-block-grid-four-up'"><xsl:value-of select="129"/></xsl:when>
				<xsl:when test="./ancestor::table/@class = 'ou-block-grid-three-up'"><xsl:value-of select="177"/></xsl:when>
				<xsl:when test="./ancestor::table/@class = 'ou-block-grid-two-up'"><xsl:value-of select="220"/></xsl:when>
				<xsl:when test="./ancestor::table/@class = 'ou-two-column-50-50'"><xsl:value-of select="242"/></xsl:when>
				<xsl:when test="./ancestor::table/@class = 'ou-two-column-flex'"><xsl:value-of select="242"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="548"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="width">
			<xsl:choose>
				<xsl:when test="$ogWidth lt $matchWidth">
					<xsl:value-of select="@width"/>
				</xsl:when>
				<xsl:otherwise><xsl:value-of select="$matchWidth"/></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="style">
			<xsl:choose>
				<xsl:when test="$width = $matchWidth">
					<xsl:value-of select="'width:100%'"/>
				</xsl:when>
				<xsl:otherwise></xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<center>
			<img align="{if($ou:action = 'pub') then 'center' else 'middle'}" class="float-center" width="{$width}" style="{$style}">
				<xsl:apply-templates select="@*[name() != 'align' and name() != 'class' and name() != 'height' and name() != 'width']"/>
			</img>
		</center>
	</xsl:template>

	<xsl:template match="a[ancestor::table/tbody/tr[@class='type']/td != 'grey']">
		<a>
			<xsl:copy-of select="attribute()"/>
			<xsl:attribute name="style">color:#FFFFFF;</xsl:attribute>
			<span style="color:#FFFFFF"><xsl:apply-templates /></span>
		</a>
	</xsl:template>
	
	<xsl:template name="button-td">
		<xsl:param name="td"/>
		<xsl:choose>
			<xsl:when test="$td/descendant::a">
				<a href="{$td/descendant::a[1]/@href}"><xsl:value-of select="$td/descendant::a[1]/text()"/></a>
			</xsl:when>
			<xsl:otherwise>
				<a href="#"><xsl:value-of select="$td/text()"/></a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template name="spacer">
		<xsl:param name="height" as="xs:integer"/>
		<table class="spacer float-center">
			<tbody>
				<tr>
					<td height="{$height}px" style="font-size:{$height}px;line-height:{$height}px;">
						<xsl:if test="$ou:action = 'pub'">&nbsp;</xsl:if>
					</td>
				</tr>
			</tbody>
		</table>
	</xsl:template>
	
	<xsl:template match="table[@class='ou-short-event-repeater']">
		<xsl:variable name="rss" select="tbody/tr[@class='rss']/td/node()"/>
		
		<p>
			<datarepeater type="rss" src="{$rss}">
				<br /><rssitemmonthname></rssitemmonthname> <rssitemday></rssitemday><br /><rssitemlink><rsstitle></rsstitle></rssitemlink><br />
			</datarepeater>
		</p>
	</xsl:template>

</xsl:stylesheet>
