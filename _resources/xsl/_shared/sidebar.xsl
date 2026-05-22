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

	<!-- Sidebar Nav -->
	<xsl:template name="sidebar-nav">
		<!-- choose deptnav filename based on staging vs publish -->
		<xsl:variable name="deptnav-file" select="'deptnav.inc'"/>
		<xsl:variable name="props-leftnav-path" select="ou:find-up-props-param(ou:parent-path($ou:path), 'props_LeftNav')"/>
		<xsl:variable name="deptnav-path" select="ou:find-up-include(ou:parent-path($ou:path), $deptnav-file)"/>
		<xsl:variable name="deptnav-include-path" select="
			if ($LeftNav != '') then $LeftNav
			else if ($props-leftnav-path != '') then $props-leftnav-path
			else $deptnav-path"/>
		
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:if test="$deptnav-include-path != ''">
					<xsl:copy-of select="ou:ssi($deptnav-include-path)" />
				</xsl:if>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="unparsed-include-file">
					<xsl:with-param name="path" select="$deptnav-include-path"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--Sidebar Nav Mobile -->
	<xsl:template name="sidebar-nav-mobile">
		<!-- choose deptnav filename based on staging vs publish -->
		<xsl:variable name="deptnav-file" select="'deptnav.inc'"/>
		<xsl:variable name="props-leftnav-path" select="ou:find-up-props-param(ou:parent-path($ou:path), 'props_LeftNav')"/>
		<xsl:variable name="deptnav-path" select="ou:find-up-include(ou:parent-path($ou:path), $deptnav-file)"/>
		<xsl:variable name="deptnav-include-path" select="
			if ($LeftNav != '') then $LeftNav
			else if ($props-leftnav-path != '') then $props-leftnav-path
			else $deptnav-path"/>

		<button 
			type="button" 
			class="d-flex align-items-center justify-content-between btn btn-warning w-100 gap-2 shadow-none rounded-0"
			data-bs-toggle="collapse"
			data-bs-target="#sidebar-nav-mobile"
			aria-expanded="false"
			aria-conrols="sidebar-nav-mobile"
		>
			<span class="d-flex align-items-center justify-content-center gap-2">
				<span class="fa-sharp fa-regular fa-bars-sort"></span>
				<span>In This Section</span>
			</span>
			<span class="fa-sharp fa-regular fa-plus" aria-hidden="true"></span>
		</button>
		
		<div
			id="sidebar-nav-mobile"
			class="collapse"
		>
			<xsl:choose>
				<xsl:when test="$ou:action = 'pub'">
					<xsl:if test="$deptnav-include-path != ''">
						<xsl:copy-of select="ou:ssi($deptnav-include-path)" />
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="unparsed-include-file">
						<xsl:with-param name="path" select="$deptnav-include-path"/>
					</xsl:call-template>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		
	</xsl:template>
	
	<!-- Sidebar Info -->
	<xsl:template name="sidebar-info">
		<xsl:variable name="props-deptinfo-path" select="ou:find-up-props-param(ou:parent-path($ou:path), 'props_DeptInfo')"/>
		<xsl:variable name="deptinfo-path" select="ou:find-up-include(ou:parent-path($ou:path), 'deptinfo.inc')"/>
		<xsl:variable name="deptinfo-include-path" select="
			if ($DeptInfo != '') then $DeptInfo
			else if ($props-deptinfo-path != '') then $props-deptinfo-path
			else $deptinfo-path"/>
		<xsl:variable name="deptinfo-prod-path" select="concat($domain, $deptinfo-include-path)"/>
		<xsl:variable name="deptinfo-raw" select="
			if (unparsed-text-available($deptinfo-prod-path) and not(contains(unparsed-text($deptinfo-prod-path), 'Page Not Found')))
			then unparsed-text($deptinfo-prod-path)
			else ''"/>
		<xsl:variable name="deptinfo-text" select="
			normalize-space(
				replace(
					replace(
						replace($deptinfo-raw, '&lt;!--.*?--&gt;', ' ', 's'),
						'&lt;[^&gt;]+&gt;',
						' ',
						's'
					),
					'&nbsp;|&#160;',
					' '
				)
			)"/>
		 
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:if test="$deptinfo-include-path != ''">
					<xsl:copy-of select="ou:ssi($deptinfo-include-path)" />
				</xsl:if>
			</xsl:when>
			<xsl:when test="$deptinfo-text != ''">
				<xsl:call-template name="unparsed-include-file">
				  <xsl:with-param name="path" select="$deptinfo-include-path"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- Sidebar Legacy - fallback for old templates -->
	<xsl:template name="sidebar">
		<div class="col-sm-4 col-md-3">
			<xsl:call-template name="sidebar-nav"/>
			<xsl:call-template name="sidebar-info"/>
		</div>
	</xsl:template>

</xsl:stylesheet>
