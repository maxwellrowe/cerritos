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
	<xsl:param name="ou:navigation" />

	<xsl:strip-space elements="*" />
	<xsl:output omit-xml-declaration="yes" />

	<xsl:template name="render-alert">
		<xsl:param name="alert-id" as="xs:string" />
		<xsl:param name="variant-class" as="xs:string" />
		<xsl:param name="bootstrap-class" as="xs:string" />
		<xsl:param name="icon-class" as="xs:string" />
		<xsl:param name="live-region" as="xs:string" />
		<xsl:param name="title-text" as="xs:string" />
		<xsl:param name="content-label" as="xs:string" />

		<div id="{$alert-id}" class="{$variant-class} alert {$bootstrap-class} alert-dismissible fade show rounded-0 border-0 w-100 mb-0 py-3 px-4 z-3" role="alert" aria-live="{$live-region}" aria-atomic="true">
			<div class="container-xxl">
				<div class="d-flex align-items-center gap-3">
					<div class="flex-shrink-0" aria-hidden="true">
						<span class="fa {$icon-class} fs-3"></span>
					</div>
					<div class="e-body flex-grow-1" aria-label="{$content-label}">
						<span class="visually-hidden">
							<xsl:value-of select="$title-text" />
						</span>
						<xsl:apply-templates select="document/ouc:div[@label='alertsdiv-2']" />
					</div>
					<button type="button" class="close-icon close-icon-2 btn-close ms-auto flex-shrink-0" aria-label="Dismiss alert"></button>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='alertsdiv-2']/option[@selected='true' and @value='info-white']">
				<xsl:call-template name="render-alert">
					<xsl:with-param name="alert-id" select="'emergencyNotice-2'" />
					<xsl:with-param name="variant-class" select="'WhiteInfo'" />
					<xsl:with-param name="bootstrap-class" select="'alert-light text-dark'" />
					<xsl:with-param name="icon-class" select="'fa-info-circle'" />
					<xsl:with-param name="live-region" select="'polite'" />
					<xsl:with-param name="title-text" select="'Information alert'" />
					<xsl:with-param name="content-label" select="'Information alert content'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='alertsdiv-2']/option[@selected='true' and @value='info-blue']">
				<xsl:call-template name="render-alert">
					<xsl:with-param name="alert-id" select="'emergencyNotice-2'" />
					<xsl:with-param name="variant-class" select="'BlueInfo'" />
					<xsl:with-param name="bootstrap-class" select="'alert-info text-dark'" />
					<xsl:with-param name="icon-class" select="'fa-info-circle'" />
					<xsl:with-param name="live-region" select="'polite'" />
					<xsl:with-param name="title-text" select="'Information alert'" />
					<xsl:with-param name="content-label" select="'Information alert content'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='alertsdiv-2']/option[@selected='true' and @value='info-green']">
				<xsl:call-template name="render-alert">
					<xsl:with-param name="alert-id" select="'emergencyNotice-2'" />
					<xsl:with-param name="variant-class" select="'GreenInfo'" />
					<xsl:with-param name="bootstrap-class" select="'alert-success text-dark'" />
					<xsl:with-param name="icon-class" select="'fa-info-circle'" />
					<xsl:with-param name="live-region" select="'polite'" />
					<xsl:with-param name="title-text" select="'Information alert'" />
					<xsl:with-param name="content-label" select="'Information alert content'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='alertsdiv-2']/option[@selected='true' and @value='warning']">
				<xsl:call-template name="render-alert">
					<xsl:with-param name="alert-id" select="'emergencyNotice-2'" />
					<xsl:with-param name="variant-class" select="'YellowWarning'" />
					<xsl:with-param name="bootstrap-class" select="'alert-warning text-dark'" />
					<xsl:with-param name="icon-class" select="'fa-warning'" />
					<xsl:with-param name="live-region" select="'assertive'" />
					<xsl:with-param name="title-text" select="'Warning alert'" />
					<xsl:with-param name="content-label" select="'Warning alert content'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="document/ouc:properties[@label='config']/parameter[@name='alertsdiv-2']/option[@selected='true' and @value = 'emergency']">
				<xsl:call-template name="render-alert">
					<xsl:with-param name="alert-id" select="'emergencyNotice-2'" />
					<xsl:with-param name="variant-class" select="'RedAlert'" />
					<xsl:with-param name="bootstrap-class" select="'alert-danger text-dark'" />
					<xsl:with-param name="icon-class" select="'fa-exclamation-triangle'" />
					<xsl:with-param name="live-region" select="'assertive'" />
					<xsl:with-param name="title-text" select="'Emergency alert'" />
					<xsl:with-param name="content-label" select="'Emergency alert content'" />
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise />
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
