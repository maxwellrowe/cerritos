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
	in-line accessibility errors/warnings/info
	markup only shows in edt mode
	info for h1-6
	handles .ua-comment class for pdf docs fixed
-->
	
	<!-- ################# links ################# -->
	<xsl:template match="a">	
		
		<!-- show in preview and published -->
		<xsl:if test="$ou:action !='edt'">
			<xsl:choose>
			<!-- exclude links here that contain youtube.com, etc. -->
		<xsl:when test=".[not (contains(lower-case(@href), 'youtube.com')) and not(contains(lower-case(@href),'cerritoscollege.granicus.com')) and not(contains(lower-case(@href),'textcast.peoplesupport.com')) and not(contains(lower-case(@onclick), 'youtube.com')) and not(contains(lower-case(@onclick), 'youtu.be')) and not(contains(lower-case(@href), 'youtu.be'))]">
			
				<!-- not contains youtube -->
				<xsl:choose>
					
					<!-- off campus link... if href is not in cerritos domain, then new window with accessibility warning -->
					<xsl:when test=".[(starts-with(@href, 'http')) and not(contains(@href, 'cerritos.edu'))]">
						<xsl:copy> 
							
							<xsl:attribute name="href">javascript:void(0);</xsl:attribute>
							<!-- 1/29/19 | Samuel Chavez edit: Added class attribute to assume local class names assigned to links -->
							<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
							
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
					</xsl:when>

					<!-- off campus link... if onclick is not in cerritos domain, then new window with accessibility warning -->
					<xsl:when test=".[(contains(lower-case(@onclick), 'http')) and not(contains(lower-case(@onclick), 'cerritos.edu'))]">
						<xsl:copy> 
							
							<xsl:attribute name="href">javascript:void(0);</xsl:attribute> 
							<!-- 1/29/19 | Samuel Chavez edit: Added class attribute to assume local class names assigned to links -->
							<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
							
							<xsl:attribute name="rel">external</xsl:attribute>
							<xsl:attribute name="onclick"><xsl:value-of select="@onclick"/></xsl:attribute>
							<xsl:value-of select="text()"/>
							<!-- handles linked images -->
<!--
							<xsl:if test=".//img/@src != ''">
								<xsl:copy-of select=".//img"/>
							</xsl:if>
							<xsl:if test=".//* != ''">
								<xsl:copy-of select=".//*"/>
							</xsl:if>
-->
						</xsl:copy>
					</xsl:when>
					
					
					<!-- Program Mapper URL Case (8/30/21 added by Samuel Chavez) -->
					<!-- off campus link... if href is not in cerritos domain, then new window with accessibility warning -->
					<xsl:when test=".[(starts-with(@href, 'http')) and (contains(@href, 'programmap.'))]">
						<xsl:copy> 
							<xsl:attribute name="href">javascript:void(0);</xsl:attribute>
							<!-- 1/29/19 | Samuel Chavez edit: Added class attribute to assume local class names assigned to links -->
							<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
							
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
					</xsl:when>
									
					<!-- local to web server files  -->
					<xsl:otherwise>
						<!-- file icons for local web server -->
						<xsl:choose>

							<!-- email link icon -->
							<xsl:when test=".[contains(lower-case(@href), 'mailto:')]">
								<xsl:copy> 
									<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
									<!-- 8/27/20 | Samuel Chavez edit: Added class attribute to assume local class names assigned to links -->
							<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
									<xsl:attribute name="rel">mailto</xsl:attribute>
									<xsl:value-of select="text()"/> 
									<!-- handles linked images -->
<!--
									<xsl:if test=".//img/@src != ''">
										<xsl:copy-of select=".//img"/>
									</xsl:if>
									<xsl:if test=".//* != ''">
										<xsl:copy-of select=".//*"/>
									</xsl:if>
-->
								</xsl:copy>
							</xsl:when>
						
							<!-- pdf file icon -->
							<xsl:when test=".[contains(lower-case(@href), '.pdf')]">
								<xsl:copy> 
									<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute>
									<!-- 1/29/19 | Samuel Chavez edit: Added class attribute to assume local class names assigned to links -->
									<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
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
							</xsl:when>
						
							<!-- word doc file icon -->
							<xsl:when test=".[contains(lower-case(@href), '.doc')]">
								<xsl:copy> 
									<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute> 
									<!-- 7/07/21 | Samuel Chavez edit: Added class attribute to assume local class names assigned to links -->
							<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
									<xsl:attribute name="rel">Word</xsl:attribute>
									<xsl:attribute name="target">_blank</xsl:attribute> 
									<xsl:value-of select="text()"/>
									<!-- handles linked images -->
<!--
									<xsl:if test=".//img/@src != ''">
										<xsl:copy-of select=".//img"/>
									</xsl:if>
									<xsl:if test=".//* != ''">
										<xsl:copy-of select=".//*"/>
									</xsl:if>
-->
								</xsl:copy>
							</xsl:when>
						
							<!-- excel file icon -->
							<xsl:when test=".[contains(lower-case(@href), '.xls')]">
								<xsl:copy> 
									<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute> 
									<xsl:attribute name="rel">Excel</xsl:attribute>
									<xsl:attribute name="target">_blank</xsl:attribute> 
									<xsl:value-of select="text()"/>
									<!-- handles linked images -->
<!--									
									<xsl:if test=".//img/@src != ''">
										<xsl:copy-of select=".//img"/>
									</xsl:if>
									<xsl:if test=".//* != ''">
										<xsl:copy-of select=".//*"/>
									</xsl:if>
-->
								</xsl:copy>
							</xsl:when>
						
							<!-- pp file icon -->
							<xsl:when test=".[contains(lower-case(@href), '.ppt')]">
								<xsl:copy> 
									<xsl:attribute name="href"><xsl:value-of select="@href"/></xsl:attribute> 
									<xsl:attribute name="rel">PowerPoint</xsl:attribute>
									<xsl:attribute name="target">_blank</xsl:attribute> 
									<xsl:value-of select="text()"/>
									<!-- handles linked images -->
<!--								
									<xsl:if test=".//img/@src != ''">
										<xsl:copy-of select=".//img"/>
									</xsl:if>
									<xsl:if test=".//* != ''">
										<xsl:copy-of select=".//*"/>
									</xsl:if>
-->
								</xsl:copy>
							</xsl:when>
						
							<!-- just show the local link as it is  -->
							<xsl:otherwise>
								<xsl:copy-of select="."/>
							</xsl:otherwise>
						<!-- end local to web server files  -->
						</xsl:choose>
					</xsl:otherwise>
				<!-- end remote and local file icons -->
				</xsl:choose>
			<!-- end exclude links to youtube.com, etc. -->
		</xsl:when>
		
		<!-- just show excluded youtube links here as they are -->
		<xsl:otherwise>
			<xsl:copy-of select="."/>
		</xsl:otherwise>
	</xsl:choose>
		</xsl:if>
		
		<!--########## accessibility errors in edit mode ##########-->
		
		<xsl:if test="$ou:action ='edt'">
			
			<!-- choose local or off campus links -->
			<xsl:choose>
				<!-- off campus link... if href is not in cerritos domain, then new window with accessibility warning -->
				<xsl:when test=".[(starts-with(@href, 'http')) and not(contains(@href, 'cerritos.edu'))]">
					<xsl:copy> 
						
						<xsl:attribute name="href">javascript:void(0);</xsl:attribute>
						<!-- 1/29/19 | Samuel Chavez edit: Added class attribute to assume local class names assigned to links -->
						<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
						
						<xsl:attribute name="rel">external</xsl:attribute>
						<xsl:attribute name="onclick">popupWarning_offcampus('<xsl:value-of select="@href"/>')</xsl:attribute>
						<xsl:value-of select="text()"/>
						<!-- handles linked images -->
<!--
						<xsl:if test=".//img/@src != ''">
							<xsl:copy-of select=".//img"/>
						</xsl:if>
						<xsl:if test=".//* != ''">
							<xsl:copy-of select=".//*"/>
						</xsl:if>
-->
					</xsl:copy>
				</xsl:when>

				<!-- off campus link... if onclick is not in cerritos domain, then new window with accessibility warning -->
				<xsl:when test=".[(contains(lower-case(@onclick), 'http')) and not(contains(lower-case(@onclick), 'cerritos.edu'))]">
					<xsl:copy> 
						
						<xsl:attribute name="href">javascript:void(0);</xsl:attribute>
						<!-- 1/29/19 | Samuel Chavez edit: Added class attribute to assume local class names assigned to links -->
						<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
						
						<xsl:attribute name="rel">external</xsl:attribute>
						<xsl:attribute name="onclick"><xsl:value-of select="@onclick"/></xsl:attribute>
						<xsl:value-of select="text()"/>
						<!-- handles linked images -->
<!--						
						<xsl:if test=".//img/@src != ''">
							<xsl:copy-of select=".//img"/>
						</xsl:if>
						<xsl:if test=".//* != ''">
							<xsl:copy-of select=".//*"/>
						</xsl:if>
-->
					</xsl:copy>
				</xsl:when>

				
				<xsl:otherwise>
					<xsl:copy-of select="."/>
				</xsl:otherwise>
			</xsl:choose>
			
			<!--########## linked images ##########-->
			
			<!-- images alt logo -->
<!--
			<xsl:if test=".//img/@src != ''">
-->
					<!-- linked image alt text -->
<!--
			<xsl:if test=".//img[(contains(lower-case(@alt),'image') or contains(lower-case(@alt),'logo') or contains(lower-case(@alt),'picture') or contains(lower-case(@alt),'photo') or contains(lower-case(@alt),'graphic') or contains(lower-case(@alt),'photograph'))]">
				<span class="ua-error-icon"/>
				<span class="ua-error">
					<a href="/public-relations/web-administrator/web-handbook/accessibility/alt-text-descriptions.htm" target="_blank">image error: alt text: "<xsl:value-of select=".//img/@alt" />"</a></span>
			</xsl:if>
-->
			
			<!-- linked image alt text length -->
<!--
			<xsl:if test=".//img[(string-length(@alt) &gt; 80)]">
				<span class="ua-error-icon"/>
				<span class="ua-error">
					<a href="/public-relations/web-administrator/web-handbook/accessibility/alt-text-descriptions.htm" target="_blank">image error: alt text length "<xsl:value-of select=".//img/@alt" />"</a></span>
			</xsl:if>
-->
			
				<!-- fixed size -->
<!--
				<xsl:if test=".//img[contains(@border,'px') or contains(@width,'px') or contains(@height,'px')]">
					<span class="ua-error-icon"/>
					<span class="ua-error">
						<a href="/public-relations/web-administrator/web-handbook/accessibility/tables.htm" target="_blank">image error: fixed size "<xsl:value-of select="ou:checkImgFixedSize('border',.//img/@border)" /> <xsl:value-of select="ou:checkImgFixedSize('width',.//img/@width)" /> <xsl:value-of select="ou:checkImgFixedSize('height',.//img/@height)" />"</a></span>
				</xsl:if>
-->
				
			<!-- info alt text  -->
<!--
				<xsl:if test=".//img[not(contains(@border,'px')) and not(contains(@width,'px')) and not(contains(@height,'px')) and (string-length(@alt) &gt; 7 and string-length(@alt) &lt; 81) and not(contains(lower-case(@alt),'image')) and not(contains(lower-case(@alt),'logo')) and not(contains(lower-case(@alt),'picture')) and not(contains(lower-case(@alt),'photo')) and not(contains(lower-case(@alt),'photograph')) and not(contains(lower-case(@alt),'graphic'))]">
					<span class="ua-info-icon"/>
					<span class="ua-info"> 
						image alt text: "<xsl:value-of select=".//img/@alt" />"</span>
				</xsl:if>
-->

			<!-- end linked images -->
<!--
			</xsl:if>	
-->

			<!--########## links ##########-->
			
			<!-- link text 'here' -->
			<xsl:if test=".[(contains(lower-case(text()),'here') or contains(lower-case(text()),'click') 
							or (contains(lower-case(text()),'more')))]">
				<span class="ua-error-icon"/>
				<span class="ua-error"> 
					<a href="{{f:80275961}}" target="_blank">unclear link text: "<xsl:value-of select="text()" />"</a></span>
			</xsl:if>
			
			<!-- pdf file new not repaired -->
			<xsl:if test=".[(contains(lower-case(@href),'.pdf') and not(contains(lower-case(@href),'/uploads/')) and not(contains(lower-case(@href),'_ua.pdf')))]">
				<span class="ua-error-icon"/>
				<span class="ua-error">
					<a href="{{f:80275946}}" target="_blank">PDF document</a></span>
			</xsl:if>
			
			<!-- pdf file new is repaired -->
			<xsl:if test=".[(contains(lower-case(@href),'_ua.pdf') and not(contains(lower-case(@href),'/uploads/')))]">
				<span class="ua-info-icon"/>
					<span class="ua-info"> 
					 PDF Repaired</span>
			</xsl:if>
			
			<!-- pdf file old warning -->
			<xsl:if test=".[(contains(lower-case(@href),'.pdf') and contains(lower-case(@href),'/uploads/'))]">
				<span class="ua-warning-icon"/>
				<span class="ua-warning"> 
					<a href="{{f:80275946}}" target="_blank">PDF document in /uploads/ folder</a></span>
			</xsl:if>
			
			<!-- pdf file old is repaired -->
			<xsl:if test=".[(contains(lower-case(@href),'.pdf') and contains(lower-case(@href),'/uploads/') and (contains(lower-case(@href),'_ua.pdf')))]">
				<span class="ua-info-icon"/>
					<span class="ua-info"> 
					 PDF in /uploads/ folder Repaired</span>
			</xsl:if>
			
			<!-- ppt file warning -->
			<xsl:if test=".[(contains(lower-case(@href),'.ppt'))]">
				<span class="ua-warning-icon"/>
				<span class="ua-warning"> 
					<a href="{{f:80275946}}" target="_blank">PowerPoint document</a></span>
			</xsl:if>
			
			<!-- publisher file warning -->
			<xsl:if test=".[(contains(lower-case(@href),'.pub'))]">
				<span class="ua-warning-icon"/>
				<span class="ua-warning"> 
					<a href="{{f:80275946}}" target="_blank">Publisher document</a></span>
			</xsl:if>
		</xsl:if>
 </xsl:template>
	
	<!-- ################# images ################# -->
	
	<xsl:template match="img">	
		
		<!-- removes image height and width and adds photo class in all modes -->

			<img>
<!--
			<xsl:attribute name="class">
				<xsl:value-of select="'photo'"/>
			</xsl:attribute>
-->
			<xsl:attribute name="class">
				<xsl:value-of select="@class"/>
			</xsl:attribute>

			<xsl:attribute name="src">
				<xsl:copy-of select="@src"/>
			</xsl:attribute>

			<xsl:attribute name="alt">
				<xsl:copy-of select="@alt"/>
			</xsl:attribute>
				
			<xsl:attribute name="style">
				<xsl:copy-of select="@style"/>
			</xsl:attribute>
<!--
			<xsl:attribute name="title">
				<xsl:copy-of select="@title"/>
			</xsl:attribute>
			<xsl:attribute name="longdesc">
				<xsl:copy-of select="@longdesc"/>
			</xsl:attribute>
-->
			</img>

		<!-- image accessibility errors -->

		<xsl:if test="$ou:action ='edt'">
	
			<!-- alt text 'image of' -->

			<xsl:if test=".[(contains(lower-case(@alt),'image') or contains(lower-case(@alt),'logo') or contains(lower-case(@alt),'picture') or contains(lower-case(@alt),'photo') or contains(lower-case(@alt),'graphic') or contains(lower-case(@alt),'photograph'))]">
				<span class="ua-error-icon"/>
				<span class="ua-error"> 
					<a href="{{f:80275944}}" target="_blank">image error: alt text, "<xsl:value-of select="@alt" />"</a></span>
			</xsl:if>
			
			<!-- alt text length -->

			<xsl:if test=".[(string-length(@alt) &gt; 80)]">
				<span class="ua-error-icon"/>
				<span class="ua-error"> 
					<a href="{{f:80275944}}" target="_blank">image error: alt text length "<xsl:value-of select="@alt" />"</a></span>
			</xsl:if>
		
				<!-- fixed size -->
<!--	
				<xsl:if test="contains(@border,'px') or contains(@width,'px') or contains(@height,'px')">
					<span class="ua-error-icon"/>
					<span class="ua-error">
						<a href="/public-relations/web-administrator/web-handbook/accessibility/tables.htm" target="_blank">image error: fixed size "<xsl:value-of select="ou:checkImgFixedSize('border',@border)" /> <xsl:value-of select="ou:checkImgFixedSize('width',@width)" /> <xsl:value-of select="ou:checkImgFixedSize('height',@height)" />"</a></span>
				</xsl:if>
-->				
			<!-- info alt text  -->
	
				<xsl:if test="not(contains(@border,'px')) and not(contains(@width,'px')) and not(contains(@height,'px')) and (string-length(@alt) &lt; 81) and not(contains(lower-case(@alt),'image')) and not(contains(lower-case(@alt),'logo')) and not(contains(lower-case(@alt),'picture')) and not(contains(lower-case(@alt),'photo')) and not(contains(lower-case(@alt),'photograph')) and not(contains(lower-case(@alt),'graphic'))">
					<span class="ua-info-icon"/>
					<span class="ua-info"> 
						image alt text: "<xsl:value-of select="@alt" />"</span>
				</xsl:if>
		</xsl:if>

		
 </xsl:template>

<!--
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
-->
	
<!-- ################# tables ################# -->

	<!--<xsl:template match="table">	-->

		
		<!-- transform tables for all modes -->

	<!--	<table>
			<xsl:attribute name="class">
				<xsl:value-of select="'table-rs'"/>
			</xsl:attribute>
			<xsl:copy-of select="node()"/>
		</table>-->

		
		<!-- accessibility errors -->

		<!--<xsl:if test="$ou:action ='edt'">-->

				<!-- table present warning -->

				<!--<span class="ua-warning-icon"/>
				<span class="ua-warning"> 
					<a href="/public-relations/web-administrator/web-handbook/accessibility/tables.htm" target="_blank">table is present</a></span>-->

			<!-- caption -->

			<!--<xsl:choose>
				<xsl:when test="./caption[string-length(normalize-space(text())) = 0]">
					<span class="ua-error-icon"/>
					<span class="ua-error"> 
						<a href="/public-relations/web-administrator/web-handbook/accessibility/tables.htm" target="_blank">table error: no caption</a></span>
				</xsl:when>
				<xsl:otherwise>
					<span class="ua-info-icon"/>
					<span class="ua-info"> 
						table caption: "<xsl:value-of select="./caption/text()" />"</span>
				</xsl:otherwise>
			</xsl:choose>-->

			<!-- table header cells -->

			<!--<xsl:choose>
				<xsl:when test=".//th[string-length(normalize-space(text())) = 0]">
					<span class="ua-error-icon"/>
					<span class="ua-error"> 
						<a href="/public-relations/web-administrator/web-handbook/accessibility/tables.htm" target="_blank">table error: no table headers</a></span>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="headers" select=".//th/text()"></xsl:variable>
					<span class="ua-info-icon"/>
					<span class="ua-info"> 
						table headers: "<xsl:value-of select="$headers"/>"</span>
				</xsl:otherwise>
			</xsl:choose>-->

				<!-- fixed size -->

				<!--<xsl:if test="contains(@border,'px') or contains(@width,'px') or contains(@cellpadding,'px') or contains(@cellspacing,'px')">
					<span class="ua-error-icon"/>
					<span class="ua-error"> 
						<a href="/public-relations/web-administrator/web-handbook/accessibility/tables.htm" target="_blank">table error: fixed size, "<xsl:value-of select="ou:errorTableFixedSize('border',@border)" /> <xsl:value-of select="ou:errorTableFixedSize('width',@width)" /> <xsl:value-of select="ou:errorTableFixedSize('cellpadding',@cellpadding)" /> <xsl:value-of select="ou:errorTableFixedSize('cellspacing',@cellspacing)" />"</a></span>
				</xsl:if>
			
		</xsl:if>

 </xsl:template>-->

	


	<!--<xsl:function name="ou:errorTableFixedSize">
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
	</xsl:function>	-->


		
	<!-- ################# headings h1-6 ################# -->
	
	<!--<xsl:template match="h1">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>-->
		<!-- info -->
		<!--<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<span class="ua-info-icon"/>
					<span class="ua-info"> 
						&lt;h1&gt;<xsl:value-of select="." />&lt;/h1&gt;</span>
			</xsl:if>
	</xsl:template>-->
	
	<!--<xsl:template match="h2">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>-->
		<!-- info -->
		<!--<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<span class="ua-info-icon"/>
					<span class="ua-info"> 
						&lt;h2&gt;<xsl:value-of select="." />&lt;/h2&gt;</span>
			</xsl:if>
	</xsl:template>-->
	
		<!--<xsl:template match="h3">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>-->
		<!-- info -->
		<!--<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<span class="ua-info-icon"/>
					<span class="ua-info">&lt;h3&gt;<xsl:value-of select="." />&lt;/h3&gt;</span>
			</xsl:if>
	</xsl:template>-->
	
		<!--<xsl:template match="h4">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>-->
		<!-- info -->
		<!--<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<span class="ua-info-icon"/>
					<span class="ua-info"> 
						&lt;h4&gt;<xsl:value-of select="." />&lt;/h4&gt;</span>
			</xsl:if>
	</xsl:template>-->
	
		<!--<xsl:template match="h5">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>-->
		<!-- info -->
		<!--<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<span class="ua-info-icon"/>
					<span class="ua-info"> 
						&lt;h5&gt;<xsl:value-of select="." />&lt;/h5&gt;</span>
			</xsl:if>
	</xsl:template>-->
	
		<!--<xsl:template match="h6">
		<xsl:if test="$ou:action !='edt'">
			<xsl:copy-of select="."/>
		</xsl:if>-->
		<!-- info -->
		<!--<xsl:if test="$ou:action ='edt'">
				<xsl:copy-of select="."/>
					<span class="ua-info-icon"/>
					<span class="ua-info"> 
						&lt;h6&gt;<xsl:value-of select="." />&lt;/h6&gt;</span>
			</xsl:if>
	</xsl:template>-->
	
	<!-- ################# comments ################# -->

	<xsl:template match="span[@class = 'ua-comment']">
		<xsl:if test="$ou:action ='edt'">
			<span class="ua-info-icon"/><span class="ua-info"><xsl:value-of select="." /></span>
		</xsl:if>
  	</xsl:template>


	<!--
<xsl:template match="node()|@*">
  <xsl:copy>
   <xsl:apply-templates select="node()|@*"/>
  </xsl:copy>
 </xsl:template>-->
	

	

</xsl:stylesheet>
