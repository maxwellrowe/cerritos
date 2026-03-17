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
	exclude-result-prefixes="xsl xs ou ouc">
	
<!-- tb 
	sets the external link & document icons and classes in prv and pub modes
	all other markup only shows in edt mode
	adds info for h1-6
	handles .ua-comment class for pdf docs fixed
}
-->
	
	<!-- ################# links ################# -->
	<xsl:template match="a">	
		<!-- link icons -->
		<xsl:if test="$ou:action !='edt'">
		<xsl:choose>

				<!-- off campus link... if href is not in cerritos domain, then new window with accessibility warning -->
				<xsl:when test=".[(starts-with(@href, 'http')) and not(contains(@href, 'cerritos.edu'))]">
					<xsl:copy> 
						<xsl:attribute name="href">javascript:void(0);</xsl:attribute>
						<xsl:attribute name="rel">external</xsl:attribute>
						<xsl:attribute name="onclick">popupWarning_offcampus('<xsl:value-of select="@href"/>')</xsl:attribute>
						<xsl:value-of select="text()"/>
						<!-- handles linked images -->
						<xsl:if test=".//img/@src != ''">
							<xsl:copy-of select=".//img"/>
						</xsl:if>
						<xsl:if test=".//* != ''">
							<xsl:copy-of select=".//*"/>
						</xsl:if>
					</xsl:copy>
					<!-- icons handled in styles  -->
					<!--<span class="new-window"><img src="/_resources/images/common/new-win-000099-16px.svg" alt="new window" /></span>-->
				</xsl:when>
				
				<!-- off campus link... if onclick is not in cerritos domain, then new window with accessibility warning -->
				<xsl:when test=".[(contains(lower-case(@onclick), 'http')) and not(contains(lower-case(@onclick), 'cerritos.edu'))]">
					<xsl:copy> 
						<xsl:attribute name="href">javascript:void(0);</xsl:attribute> 
						<xsl:attribute name="rel">external</xsl:attribute>
						<xsl:attribute name="onclick"><xsl:value-of select="@onclick"/></xsl:attribute>
						<xsl:value-of select="text()"/>
						<!-- handles linked images -->
						<xsl:if test=".//img/@src != ''">
							<xsl:copy-of select=".//img"/>
						</xsl:if>
						<xsl:if test=".//* != ''">
							<xsl:copy-of select=".//*"/>
						</xsl:if>
					</xsl:copy>
					<!-- icons handled in styles 
					<span class="new-window"><img src="/_resources/images/common/new-win-000099-16px.svg" alt="new window" /></span>-->
				</xsl:when>
									
				<!-- local to web server files  -->
				<xsl:otherwise>
					<!-- file icons for local web server -->
					<xsl:choose>
						<!-- email link icon -->
						<xsl:when test=".[contains(lower-case(@href), 'mailto:')]">
							<xsl:copy> 
								<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute> 
								<xsl:attribute name="rel">mailto</xsl:attribute>
								<xsl:value-of select="text()"/> 
								<!-- handles linked images -->
								<xsl:if test=".//img/@src != ''">
									<xsl:copy-of select=".//img"/>
								</xsl:if>
								<xsl:if test=".//* != ''">
									<xsl:copy-of select=".//*"/>
								</xsl:if>
							</xsl:copy>
							<!-- icons handled in styles   
							<span class="mailto"><img src="/_resources/images/common/email-icon.svg" alt="email link" /></span>-->
						</xsl:when>
						<!-- pdf file icon -->
						<xsl:when test=".[contains(lower-case(@href), '.pdf')]">
							<xsl:copy> 
								<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute> 
								<xsl:attribute name="rel">PDF</xsl:attribute>
								<xsl:attribute name="target">_blank</xsl:attribute> 
								<xsl:value-of select="text()"/>
								<!-- handles linked images -->
								<xsl:if test=".//img/@src != ''">
									<xsl:copy-of select=".//img"/>
								</xsl:if>
								<xsl:if test=".//* != ''">
									<xsl:copy-of select=".//*"/>
								</xsl:if>
							</xsl:copy>
							<!--<span class="new-window"><img src="/_resources/images/common/pdficon_16x.gif" alt="PDF document" /></span>-->
						</xsl:when>
						<!-- word doc file icon -->
						<xsl:when test=".[contains(lower-case(@href), '.doc')]">
							<xsl:copy> 
								<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute> 
								<xsl:attribute name="rel">Word</xsl:attribute>
								<xsl:attribute name="target">_blank</xsl:attribute> 
								<xsl:value-of select="text()"/>
								<!-- handles linked images -->
								<xsl:if test=".//img/@src != ''">
									<xsl:copy-of select=".//img"/>
								</xsl:if>
								<xsl:if test=".//* != ''">
									<xsl:copy-of select=".//*"/>
								</xsl:if>
							</xsl:copy>
							<!--<span class="new-window"><img src="/_resources/images/common/16px-MS_word_DOC_icon.svg.png" alt="Word document" /></span>-->
						</xsl:when>
						<!-- excel file icon -->
						<xsl:when test=".[contains(lower-case(@href), '.xls')]">
							<xsl:copy> 
								<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute> 
								<xsl:attribute name="rel">Excel</xsl:attribute>
								<xsl:attribute name="target">_blank</xsl:attribute> 
								<xsl:value-of select="text()"/>
								<!-- handles linked images -->
								<xsl:if test=".//img/@src != ''">
									<xsl:copy-of select=".//img"/>
								</xsl:if>
								<xsl:if test=".//* != ''">
									<xsl:copy-of select=".//*"/>
								</xsl:if>
							</xsl:copy>
							<!--<span class="new-window"><img src="/_resources/images/common/Microsoft_Excel_2013_logo.svg.png" alt="Excel document" /></span>-->
						</xsl:when>
						<!-- pp file icon -->
						<xsl:when test=".[contains(lower-case(@href), '.ppt')]">
							<xsl:copy> 
								<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute> 
								<xsl:attribute name="rel">PowerPoint</xsl:attribute>
								<xsl:attribute name="target">_blank</xsl:attribute> 
								<xsl:value-of select="text()"/>
								<!-- handles linked images -->
								<xsl:if test=".//img/@src != ''">
									<xsl:copy-of select=".//img"/>
								</xsl:if>
								<xsl:if test=".//* != ''">
									<xsl:copy-of select=".//*"/>
								</xsl:if>
							</xsl:copy>
							<!--<span class="new-window"><img src="/_resources/images/common/Microsoft_PowerPoint_2013_logo.svg.png" alt="PowerPoint document" /></span>-->
						</xsl:when>
					</xsl:choose>
				</xsl:otherwise>


	</xsl:choose>
		</xsl:if>
		
		<!-- accessibility errors -->
		<xsl:if test="$ou:action ='edt'">
		<xsl:copy-of select="."/>
			
			<!-- linked images -->
			<xsl:if test=".//img/@src != ''">
					<!-- linked image alt text -->
			<xsl:if test=".//img[(contains(lower-case(@alt),'image') or contains(lower-case(@alt),'logo') or contains(lower-case(@alt),'picture') or contains(lower-case(@alt),'photo') or contains(lower-case(@alt),'graphic') or contains(lower-case(@alt),'photograph'))]">
				<img src="{{f:80150938}}" alt="accessibility error"      style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
				<span class="ua-error" style="display: inline; background-color:#fcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; padding: .2em;margin-left:.2em;"> 
					<a href="{{f:80275944}}" target="_blank">image error: alt text: "<xsl:value-of select=".//img/@alt" />"</a></span>
			</xsl:if>
			
			<!-- linked image alt text length -->
			<xsl:if test=".//img[(string-length(@alt) &lt; 8 or string-length(@alt) &gt; 80)]">
				<img src="{{f:80150938}}"      alt="accessibility error"      style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
				<span class="ua-error" style="display: inline; background-color:#fcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10;  padding: .2em;margin-left:.2em;"> 
					<a href="{{f:80275944}}" target="_blank">image error: alt text length "<xsl:value-of select=".//img/@alt" />"</a></span>
			</xsl:if>
			
				<!-- fixed size -->
				<xsl:if test=".//img[contains(@border,'px') or contains(@width,'px') or contains(@height,'px')]">
					<img src="{{f:80150938}}"       alt="accessibility error"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-error" style="display: inline; background-color:#fcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
						<a href="{{f:80275939}}" target="_blank">image error: fixed size "<xsl:value-of select="ou:checkImgFixedSize('border',.//img/@border)" /> <xsl:value-of select="ou:checkImgFixedSize('width',.//img/@width)" /> <xsl:value-of select="ou:checkImgFixedSize('height',.//img/@height)" />"</a></span>
				</xsl:if>
				
			<!-- info alt text  -->
				<xsl:if test=".//img[not(contains(@border,'px')) and not(contains(@width,'px')) and not(contains(@height,'px')) and (string-length(@alt) &gt; 7 and string-length(@alt) &lt; 81) and not(contains(lower-case(@alt),'image')) and not(contains(lower-case(@alt),'logo')) and not(contains(lower-case(@alt),'picture')) and not(contains(lower-case(@alt),'photo')) and not(contains(lower-case(@alt),'photograph')) and not(contains(lower-case(@alt),'graphic'))]">
					<img src="{{f:80150928}}"       alt="accessibility error"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-info" style="display: inline; background-color:#ccffcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
						image alt text: "<xsl:value-of select=".//img/@alt" />"</span>
				</xsl:if>

			<!-- end linked images -->
			</xsl:if>	

			<!-- link text 'here' -->
			<xsl:if test=".[(contains(lower-case(text()),'here') or contains(lower-case(text()),'click') 
							or (contains(lower-case(text()),'more') and string-length(text()) &lt; 8))]">
				<img src="{{f:80150938}}"      alt="accessibility error"      style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
				<span class="ua-error" style="display: inline; background-color:#fcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10;  padding: .2em;margin-left:.2em;"> 
					<a href="{{f:80275961}}" target="_blank">unclear link text: "<xsl:value-of select="text()" />"</a></span>
			</xsl:if>
			<!-- pdf file new not repaired -->
			<xsl:if test=".[(contains(lower-case(@href),'.pdf') and not(contains(lower-case(@href),'/uploads/')) and not(contains(lower-case(@href),'_ua.pdf')))]">
				<img src="{{f:80150938}}"      alt="accessibility error"      style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
				<span class="ua-error" style="display: inline; background-color:#fcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10;  padding: .2em;margin-left:.2em;"> 
					<a href="{{f:80275946}}" target="_blank">PDF document</a></span>
			</xsl:if>
			<!-- pdf file new is repaired -->
			<xsl:if test=".[(contains(lower-case(@href),'_ua.pdf') and not(contains(lower-case(@href),'/uploads/')))]">
				<img src="{{f:80150928}}"       alt="accessibility info"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-info" style="display: inline; background-color:#ccffcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
					 PDF Repaired</span>
			</xsl:if>
			<!-- pdf file old warning -->
			<xsl:if test=".[(contains(lower-case(@href),'.pdf') and contains(lower-case(@href),'/uploads/'))]">
				<img src="{{f:80150926}}"      alt="accessibility warning"      style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
				<span class="ua-warning" style="display: inline; background-color:#ffcc66; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10;  padding: .2em;margin-left:.2em;"> 
					<a href="{{f:80275946}}" target="_blank">PDF document in /uploads/ folder</a></span>
			</xsl:if>
			<!-- pdf file old is repaired -->
			<xsl:if test=".[(contains(lower-case(@href),'.pdf') and contains(lower-case(@href),'/uploads/') and (contains(lower-case(@href),'_ua.pdf')))]">
				<img src="{{f:80150928}}"       alt="accessibility info"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-info" style="display: inline; background-color:#ccffcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
					 PDF in /uploads/ folder Repaired</span>
			</xsl:if>
			<!-- ppt file warning -->
			<xsl:if test=".[(contains(lower-case(@href),'.ppt'))]">
				<img src="{{f:80150926}}"      alt="accessibility warning"      style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
				<span class="ua-warning" style="display: inline; background-color:#ffcc66; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10;  padding: .2em;margin-left:.2em;"> 
					<a href="{{f:80275946}}" target="_blank">PowerPoint document</a></span>
			</xsl:if>
			<!-- publisher file warning -->
			<xsl:if test=".[(contains(lower-case(@href),'.pub'))]">
				<img src="{{f:80150926}}"      alt="accessibility warning"      style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
				<span class="ua-warning" style="display: inline; background-color:#ffcc66; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10;  padding: .2em;margin-left:.2em;"> 
					<a href="{{f:80275946}}" target="_blank">Publisher document</a></span>
			</xsl:if>
		</xsl:if>
 </xsl:template>
	
	<!-- ################# images ################# -->
	<xsl:template match="img">	
		<!-- link icons -->
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>
		
		<!-- accessibility errors -->
		<xsl:if test="$ou:action ='edt'">
			<xsl:copy-of select="."/>
			<!-- alt text 'image of' -->
			<xsl:if test=".[(contains(lower-case(@alt),'image') or contains(lower-case(@alt),'logo') or contains(lower-case(@alt),'picture') or contains(lower-case(@alt),'photo') or contains(lower-case(@alt),'graphic') or contains(lower-case(@alt),'photograph'))]">
				<img src="{{f:80150938}}" alt="accessibility error"      style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
				<span class="ua-error" style="display: inline; background-color:#fcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; padding: .2em;margin-left:.2em;"> 
					<a href="{{f:80275944}}" target="_blank">image error: alt text, "<xsl:value-of select="@alt" />"</a></span>
			</xsl:if>
			<!-- alt text length -->
			<xsl:if test=".[(string-length(@alt) &lt; 8 or string-length(@alt) &gt; 80)]">
				<img src="{{f:80150938}}"      alt="accessibility error"      style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
				<span class="ua-error" style="display: inline; background-color:#fcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10;  padding: .2em;margin-left:.2em;"> 
					<a href="{{f:80275944}}" target="_blank">image error: alt text length "<xsl:value-of select="@alt" />"</a></span>
			</xsl:if>
				<!-- fixed size -->
				<xsl:if test="contains(@border,'px') or contains(@width,'px') or contains(@height,'px')">
					<img src="{{f:80150938}}"       alt="accessibility error"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-error" style="display: inline; background-color:#fcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
						<a href="{{f:80275939}}" target="_blank">image error: fixed size "<xsl:value-of select="ou:checkImgFixedSize('border',@border)" /> <xsl:value-of select="ou:checkImgFixedSize('width',@width)" /> <xsl:value-of select="ou:checkImgFixedSize('height',@height)" />"</a></span>
				</xsl:if>
				
			<!-- info alt text  -->
				<xsl:if test="not(contains(@border,'px')) and not(contains(@width,'px')) and not(contains(@height,'px')) and (string-length(@alt) &gt; 7 and string-length(@alt) &lt; 81) and not(contains(lower-case(@alt),'image')) and not(contains(lower-case(@alt),'logo')) and not(contains(lower-case(@alt),'picture')) and not(contains(lower-case(@alt),'photo')) and not(contains(lower-case(@alt),'photograph')) and not(contains(lower-case(@alt),'graphic'))">
					<img src="{{f:80150928}}"       alt="accessibility info"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-info" style="display: inline; background-color:#ccffcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
						image alt text: "<xsl:value-of select="@alt" />"</span>
				</xsl:if>
		</xsl:if>
		
		
 </xsl:template>
	
	<xsl:function name="ou:checkImgFixedSize">
		<xsl:param name="attribute" />
		<xsl:param name="size" />
		<xsl:if test="contains(lower-case($size),'px') and $attribute='width'">
			width=<xsl:copy-of select="$size" />
		</xsl:if>
		<xsl:if test="contains(lower-case($size),'px') and $attribute='height'">
			height=<xsl:copy-of select="$size" />
		</xsl:if>
		<xsl:if test="contains(lower-case($size),'px') and $attribute='border'">
			border=<xsl:copy-of select="$size" />
		</xsl:if>
	</xsl:function>
	
	<!-- ################# tables ################# -->
	<xsl:template match="table">	
		<!-- show table -->
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>
		
		<!-- accessibility errors -->
		<xsl:if test="$ou:action ='edt'">
			<xsl:copy-of select="."/>
				<!-- table present warning -->
				<img src="{{f:80150926}}"      alt="accessibility warning"      style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
				<span class="ua-warning" style="display: inline; background-color:#ffcc66; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10;  padding: .2em;margin-left:.2em;margin-top:.2em;"> 
					<a href="{{f:80275939}}" target="_blank">table is present</a></span>
			
				<!-- summary and caption are blank -->
				<xsl:if test="string-length(normalize-space(@summary)) = 0 and string-length(normalize-space(caption)) = 0">
					<img src="{{f:80150938}}"       alt="accessibility error"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-error" style="display: inline; background-color:#fcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;margin-top:.2em;"> 
						<a href="{{f:80275939}}" target="_blank">table error: no summary or caption</a></span>
				</xsl:if>
					<!-- summary and caption are the same -->
				<xsl:if test="(normalize-space(@summary) = normalize-space(caption)) and (string-length(normalize-space(@summary)) > 0 and string-length(normalize-space(caption)) > 0)">
					<img src="{{f:80150938}}"       alt="accessibility error"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-error" style="display: inline; background-color:#fcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;margin-top:.2em;"> 
						<a href="{{f:80275939}}" target="_blank">table error: summary = caption</a></span>
				</xsl:if>
				<!-- fixed size -->
				<xsl:if test="contains(@border,'px') or contains(@width,'px') or contains(@cellpadding,'px') or contains(@cellspacing,'px')">
					<img src="{{f:80150938}}"       alt="accessibility error"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-error" style="display: inline; background-color:#fcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;margin-top:.2em;"> 
						<a href="{{f:80275939}}" target="_blank">table error: fixed size, "<xsl:value-of select="ou:errorTableFixedSize('border',@border)" /> <xsl:value-of select="ou:errorTableFixedSize('width',@width)" /> <xsl:value-of select="ou:errorTableFixedSize('cellpadding',@cellpadding)" /> <xsl:value-of select="ou:errorTableFixedSize('cellspacing',@cellspacing)" />"</a></span>
				</xsl:if>
			
		</xsl:if>
		
 </xsl:template>

	<xsl:function name="ou:errorTableFixedSize">
		<xsl:param name="attribute" />
		<xsl:param name="size" />
		<xsl:if test="(contains(lower-case($size),'px') or contains(lower-case($size),'in')) and $attribute='width'">
			width=<xsl:copy-of select="$size" />
		</xsl:if>
		<xsl:if test="contains(lower-case($size),'px') and $attribute='cellpadding'">
			cellpadding=<xsl:copy-of select="$size" />
		</xsl:if>
		<xsl:if test="contains(lower-case($size),'px') and $attribute='cellspacing'">
			cellspacing=<xsl:copy-of select="$size" />
		</xsl:if>
		<xsl:if test="contains(lower-case($size),'px') and $attribute='border'">
			border=<xsl:copy-of select="$size" />
		</xsl:if>
	</xsl:function>
	
	<xsl:template match="h1">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>
		<!-- info -->
		<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<img src="{{f:80150928}}"       alt="accessibility info"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-info" style="display: inline; background-color:#ccffcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
						&lt;h1&gt;<xsl:value-of select="." />&lt;/h1&gt;</span>
			</xsl:if>
	</xsl:template>
	
	<xsl:template match="h2">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>
		<!-- info -->
		<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<img src="{{f:80150928}}"       alt="accessibility info"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-info" style="display: inline; background-color:#ccffcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
						&lt;h2&gt;<xsl:value-of select="." />&lt;/h2&gt;</span>
			</xsl:if>
	</xsl:template>
	
		<xsl:template match="h3">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>
		<!-- info -->
		<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<img src="{{f:80150928}}"       alt="accessibility info"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-info" style="display: inline; background-color:#ccffcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
						&lt;h3&gt;<xsl:value-of select="." />&lt;/h3&gt;</span>
			</xsl:if>
	</xsl:template>
	
		<xsl:template match="h4">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>
		<!-- info -->
		<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<img src="{{f:80150928}}"       alt="accessibility info"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-info" style="display: inline; background-color:#ccffcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
						&lt;h4&gt;<xsl:value-of select="." />&lt;/h4&gt;</span>
			</xsl:if>
	</xsl:template>
	
		<xsl:template match="h5">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>
		<!-- info -->
		<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<img src="{{f:80150928}}"       alt="accessibility info"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-info" style="display: inline; background-color:#ccffcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
						&lt;h5&gt;<xsl:value-of select="." />&lt;/h5&gt;</span>
			</xsl:if>
	</xsl:template>
	
		<xsl:template match="h6">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>
		<!-- info -->
		<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<img src="{{f:80150928}}"       alt="accessibility info"       style="background-color:#fff; border: none; margin-left:.25em;vertical-align: bottom; z-index: 10000; display: inline;"/>
					<span class="ua-info" style="display: inline; background-color:#ccffcc; color: #000; border: .1em solid #000; height: auto; width: auto; z-index: 10; margin: 0; padding: .2em;margin-left:.2em;"> 
						&lt;h6&gt;<xsl:value-of select="." />&lt;/h6&gt;</span>
			</xsl:if>
	</xsl:template>
	
	<!-- ################# comments ################# -->
	<xsl:template match="span[@class = 'ua-comment']">
		<xsl:if test="$ou:action ='edt'">
			<span class="ua-info"><xsl:value-of select="." /></span>
		</xsl:if>
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
