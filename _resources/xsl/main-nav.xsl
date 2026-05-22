<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xsl xs ou ouc">
	<xsl:import href="functions-workshop.xsl" />
	<xsl:import href="ou-variables.xsl" />
	<xsl:import href="ou-forms.xsl" />
	<xsl:import href="template-matches.xsl" />
	<xsl:import href="accessibility-link-icons.xsl" />
	<xsl:import href="_shared/snippets.xsl" />
	<xsl:import href="_shared/components.xsl" />
	<xsl:param name="ou:navigation" />

	<xsl:strip-space elements="*" />
	<xsl:output omit-xml-declaration="yes" />
	
	<xsl:template match="/">
		<xsl:if test="$ou:action = 'edt' or $ou:action = 'prv'">
			<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.8/dist/css/bootstrap.min.css" />
			<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/swiper@12/swiper-bundle.min.css" />
			<link rel="stylesheet" href="/_resources/fonts/font-awesome-6-pro/css/fontawesome.min.css" />
			<link rel="stylesheet" href="/_resources/fonts/font-awesome-6-pro/css/brands.min.css" />
			<link rel="stylesheet" href="/_resources/fonts/font-awesome-6-pro/css/regular.min.css" />
			<link rel="stylesheet" href="/_resources/fonts/font-awesome-6-pro/css/solid.min.css" />
			<link rel="stylesheet" href="/_resources/fonts/font-awesome-6-pro/css/sharp-regular.min.css" />
			<link rel="stylesheet" href="/_resources/fonts/font-awesome-6-pro/css/sharp-solid.min.css" />
			<link rel="preconnect" href="https://fonts.googleapis.com" />
			<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="crossorigin" />
			<link href="https://fonts.googleapis.com/css2?family=Karla:ital,wght@0,200..800;1,200..800&amp;family=Poppins:ital,wght@0,400;0,500;0,600;0,700;0,800;0,900;1,400;1,500;1,600;1,700;1,800;1,900&amp;display=swap" rel="stylesheet" />
			<link rel="stylesheet" href="/_resources/css/flexslider.css" type="text/css" />
			<link rel="stylesheet" href="/_resources/css/legacy.css" />
			<link rel="stylesheet" href="/_resources/css/owl.carousel.css" />
			<link rel="stylesheet" href="/_resources/css/owl.theme.default.min.css" />
			<link rel="stylesheet" href="/_resources/css/components.css" />
			<link rel="stylesheet" href="/_resources/css/modern-campus-forms.css" />
			<link rel="stylesheet" href="/_resources/css/cerritos-bootstrap.css" />
			<link rel="stylesheet" href="/_resources/css/cerritos.css" />
		</xsl:if>
		<div id="main-nav" class="bg-primary">
			<xsl:apply-templates select="document/ouc:div[@label='mainnavdiv']" />
		</div>
	</xsl:template>

</xsl:stylesheet>
