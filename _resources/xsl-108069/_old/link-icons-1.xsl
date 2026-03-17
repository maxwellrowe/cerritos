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
	
<!-- 
	sets the external link & document icons and classes in prv and pub modes
	all other markup only shows in edt mode
	adds info for h1-6
	handles .ua-comment class for pdf docs repaired
}
-->
	
	<!-- link icons -->
	<xsl:template match="a">	
		<xsl:choose>
			<!-- exclude links here that contain youtube.com, etc. -->
		<xsl:when test=".[not (contains(lower-case(@href), 'youtube.com')) and not(contains(lower-case(@href),'cerritoscollege.granicus.com')) and not(contains(lower-case(@href),'textcast.peoplesupport.com')) and not(contains(lower-case(@onclick), 'youtube.com')) and not(contains(lower-case(@onclick), 'youtu.be')) and not(contains(lower-case(@href), 'youtu.be'))]">
				<!-- now process these links -->
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
					<!-- icons handled in styles  
					<span class="new-window"><img src="/_resources/images/common/new-win-000099-16px.svg" alt="new window" /></span>-->
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
						
						<!-- just show the link as it is  -->
						<xsl:otherwise>
							<xsl:copy-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
					<!-- end file icons -->
				</xsl:otherwise>
				</xsl:choose>
		</xsl:when>
			
		<!-- just show excluded links here as they are -->
		<xsl:otherwise>
			<xsl:copy-of select="."/>
		</xsl:otherwise>
	</xsl:choose>

 </xsl:template>
	
</xsl:stylesheet>
