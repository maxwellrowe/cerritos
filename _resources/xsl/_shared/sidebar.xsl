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

	<!-- Sidebar -->
	 <xsl:template name="sidebar">
		 <!-- choose deptnav filename based on staging vs publish -->
		<xsl:variable name="deptnav-file" select="'deptnav.inc'"/>
		<xsl:variable name="deptnav-path" select="ou:find-up-include(ou:parent-path($ou:path), $deptnav-file)"/>
		<xsl:variable name="deptinfo-path" select="ou:find-up-include(ou:parent-path($ou:path), 'deptinfo.inc')"/>
		 
		<div id="sidebar" class="col-sm-4 col-md-3">
			<div id="skiptonavigation">
				<div id="menuLeft">
				<button type="button" class="mobile-button hidden-lg" data-toggle="collapse" data-target=".left-nav-collapse">Navigate this Section  <span class="fa fa-chevron-down" aria-hidden="true"></span>
				</button>
				<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->
				<nav id="navigation-collaspe" class="navbar-collapse left-nav-collapse collapse" aria-label="navigation-collaspe">
				<xsl:call-template name="unparsed-include-file">
				  <xsl:with-param name="path"
					select="if ($LeftNav != '') then $LeftNav else $deptnav-path"/>
				</xsl:call-template>
				</nav>
				</div>
			</div>
			<div>
				<div id="deptinfo">
					<!-- added for ticket #38482, the function is in functions-workshop.xsl. -->									
					<xsl:call-template name="unparsed-include-file">
					  <xsl:with-param name="path"
						select="if ($DeptInfo != '') then $DeptInfo else $deptinfo-path"/>
					</xsl:call-template>
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>