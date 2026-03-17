<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="ou xsl ouc">
	
	
	<xsl:import href="common-config.xsl"/>	
	
	<xsl:strip-space elements="*" />
	
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="yes" />	

<!--All variables are set in the common-config.xsl-->	
	
	<xsl:template match="/document">
		<xsl:choose>
			<xsl:when test="$ou:action != 'pub'">
				<xsl:call-template name="config-preview"/><!--Preview setup in common-config.xsl-->
			</xsl:when>
			<xsl:otherwise>
			
/**********************************************
* 			   		Theme 4		       	  *
**********************************************/

/* Typography */

h1 {font-size: 36px;}
h2 {font-size: 32px;}
h3 {font-size: 28px;}
h4 {font-size: 24px;}
h5 {font-size: 20px;}
h6 {font-size: 18px;}

a {
	/*color: <xsl:value-of select="$color-4"/>;*/ 
	text-decoration: none;
}

a:hover { 
	/*color: <xsl:value-of select="$color-4-dark"/>!important;*/
}

a:active { 
	color: <xsl:value-of select="$color-4"/>!important;
}

a:visited { 
	/*color: <xsl:value-of select="$color-4"/>!important;
	color: #fefefe;*/
}

h1 a, 
h2 a, 
h3 a, 
h4 a, 
h5 a, 
h6 a {
	color: <xsl:value-of select="$color-4"/>;
}

h1 a:active, 
h2 a:active,  
h3 a:active, 
h4 a:active, 
h5 a:active, 
h6 a:active { 
	color: <xsl:value-of select="$color-4"/>!important; 
} 

h1 a:visited, 
h2 a:visited,  
h3 a:visited, 
h4 a:visited, 
h5 a:visited, 
h6 a:visited { 
	color: <xsl:value-of select="$color-4"/>!important; 
} 


.header {
	background: <xsl:value-of select="$color-4-header-color"/> !important;
}

.footer {
	background: <xsl:value-of select="$color-4-footer-background"/> !important;
	background-color: <xsl:value-of select="$color-4-footer-background"/> !important;
}

.footer-container {
	background: <xsl:value-of select="$color-4-footer-background"/> !important;
}
			
.footer a {
	color:<xsl:value-of select="$color-4-footer-link"/>;	
}

.footer-container a:active,
.footer-container a:visited,
.footer-container a:hover {
	color:<xsl:value-of select="$color-4-footer-link-hover"/>!important;
	text-decoration:none;
}

.footer-container p {
	color:<xsl:value-of select="$color-4-footer-text"/>;
}

.footer th.expander,
.footer td.expander {
	color: <xsl:value-of select="$color-4-footer-text"/>;
}

.disclaimer {
	background: <xsl:value-of select="$color-4-disclaimer-background"/>;
}

/*Button Colors */
table.button-theme table td {
	background: <xsl:value-of select="$color-4"/>;
	border: 1px solid <xsl:value-of select="$color-4-dark"/>; /*make a darker shade*/
	color: #ffffff;
}

table.button-theme:hover table td,
table.button-theme:visited table td,
table.button-theme:active table td {
	background: <xsl:value-of select="$color-4-dark"/>!important;
}

.callout-theme {
	background: <xsl:value-of select="$color-4"/>;
	border: 1px solid <xsl:value-of select="$color-4-dark"/>;
	padding: 10px !important;
	color:#ffffff;
}
.callout-theme h1,
.callout-theme h2,
.callout-theme h3,
.callout-theme h4,
.callout-theme h5,
.callout-theme h6,
.callout-theme p,
.callout-theme p a{
	color:#ffffff;
}

/* Added in OU Classes */
h1, h2, h3, h4, h5, h6,
.theme-color-highlight {
	color:<xsl:value-of select="$color-4"/>;
}
.black {
	color:#3D3D3B;
}
.date {
	color:<xsl:value-of select="$color-4"/>;
	font-size:18px;
	text-align:right;
}

			</xsl:otherwise>
			
		</xsl:choose>
	</xsl:template>		

</xsl:stylesheet>
