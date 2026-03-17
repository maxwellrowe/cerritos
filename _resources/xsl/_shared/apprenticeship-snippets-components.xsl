<?xml version="1.0" encoding="UTF-8"?>
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

<!--
	Updated by Mackey - 2025
	
	Snippets & Components XSL

	0. Empty Test	
	1. Hero Component
	2. Container
	3. Multi Column Snippet
	4. Photo Grid CTA
	5. Custom Heading
	6. Rounded Background
	7. Video Lightbox
	8. Full Width Split CTA
	9. List Group
	10. Testimonial Carousel
	
-->

<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xs ou fn ouc">
	
	<!-- 0. Empty Test - if add data attribute data-ouc-test to a component div and it's empty return nothing -->
	<xsl:template match="div[@data-ouc-test='']">
	</xsl:template>
	
	<xsl:template match="span[@data-ouc-test='']">
	</xsl:template>
	
	<!-- 1. Hero Component -->
	<xsl:template match="ouc:component[@name='cerritos-hero-component']">
		<xsl:variable name="heading" select="div[@class='heading']" />
		<xsl:variable name="subheading" select="div[@class='subheading']" />
		<xsl:variable name="image" select="div[@class='image']" />
		<xsl:variable name="video" select="div[@class='video']" />
		
		<div class="cerritos-hero-component" style="background-image: url({$image});">
			<xsl:if test="$video != ''">
				<div class="chc-video">
					<video id="chc-video" autoplay="autoplay" loop="loop" muted="muted" playsinline="playsinline">
					  <source src="{$video}" type="video/mp4" />
					</video>
					<button id="chc-play-pause" class="chc-play-pause">
						<span class="fa fa-play"></span>
						<span class="fa fa-pause"></span>
						<span class="sr-only">Play/ Pause Video</span>
					</button>
				</div>
			</xsl:if>
			<div class="chc-content">
				<h2><xsl:value-of select="$heading" /></h2>
				<xsl:if test="$subheading != ''">
					<p class="chc-subheading">
						<xsl:value-of select="$subheading" />
					</p>
				</xsl:if>
			</div>
		</div>
	</xsl:template>
	
	<!-- 2. Container -->
	<xsl:template match="table[contains(@class, 'ou-container')]">
		<xsl:variable name="bg" select="replace(normalize-space(tbody/tr/td[@class='ou-container-bg']),'&nbsp;','')" />
		<div class="cerritos-full-width" style="background: {$bg};">
			<div class="container">
				<xsl:apply-templates select="tbody/tr/td[@class='ou-container-content']" />
			</div>
		</div>
	</xsl:template>
	
	<!-- 3. Multi Column Snippet -->
	<xsl:template match="table[contains(@class, 'ou-multi-column')]">
		<div class="row">
			<xsl:for-each select="tbody/tr">
				<div class="{lower-case(replace(td[@class='class'],'&nbsp;',''))}">
					<xsl:apply-templates select="td[@class='content']/node()" />
				</div>
			</xsl:for-each>
			<div class="clearfix"></div>
		</div>
	</xsl:template>
	
	<!-- 3. Accordion -->
	<xsl:template match="table[contains(@class, 'ou-apprenticeship-accordion')]">
		<xsl:variable name="accordion-id" select="'accordion-' || generate-id()"/>
		<div id="{$accordion-id}" class="panel-group">
			<xsl:for-each select="tbody/tr[@class = 'ou-panel']">
				<xsl:variable name="item-id" select="'item-' || generate-id()"/>
				<xsl:variable name="open" select="td[contains(@class, 'ou-open')]/node()" />
				<div class="panel panel-default card">
					<div id="{$item-id}-headingOne" class="panel-heading">
						<h2 class="panel-title">
							<xsl:choose>
								<xsl:when test="$open = 'true'">
									<button class="btn btn-link accordion-trigger collapsed" role="button" data-toggle="collapse" data-target="#{$item-id}-collapseOne" aria-expanded="true" aria-controls="{$item-id}-collapseOne"><xsl:apply-templates select="td[contains(@class, 'ou-title')]/node()"/></button>
								</xsl:when>
								<xsl:otherwise>
									<button class="btn btn-link accordion-trigger collapsed" role="button" data-toggle="collapse" data-target="#{$item-id}-collapseOne" aria-expanded="false" aria-controls="{$item-id}-collapseOne"><xsl:apply-templates select="td[contains(@class, 'ou-title')]/node()"/></button>
								</xsl:otherwise>
							</xsl:choose>
						</h2>
					</div>
					<xsl:choose>
						<xsl:when test="$open = 'true'">
							<div id="{$item-id}-collapseOne" class=" panel-collapse collapse in" aria-labelledby="{$item-id}-headingOne" data-parent="#{$accordion-id}">
								<div class="panel-body">
									<xsl:apply-templates select="td[contains(@class, 'ou-content')]/node()" />
								</div>
							</div>
						</xsl:when>
						<xsl:otherwise>
							<div id="{$item-id}-collapseOne" class=" panel-collapse collapse" aria-labelledby="{$item-id}-headingOne" data-parent="#{$accordion-id}">
								<div class="panel-body">
									<xsl:apply-templates select="td[contains(@class, 'ou-content')]/node()" />
								</div>
							</div>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:for-each>
		</div>
    </xsl:template>
	
	<!-- 4. Photo Grid CTA -->
	<xsl:template match="ouc:component[@name='cerritos-photo-grid-cta']">
		<xsl:variable name="text" select="div[@class='text']" />
		<xsl:variable name="url" select="div[@class='url']" />
		<xsl:variable name="image_1" select="div[@class='image_1']" />
		<xsl:variable name="image_2" select="div[@class='image_2']" />
		<xsl:variable name="image_3" select="div[@class='image_3']" />
		<xsl:variable name="image_4" select="div[@class='image_4']" />
		<xsl:variable name="image_5" select="div[@class='image_5']" />
		<xsl:variable name="image_6" select="div[@class='image_6']" />
		
		<div class="cerritos-photo-grid-component">
			<div class="cpgc-col-1">
				<xsl:choose>
					<xsl:when test="$image_1 != ''">
						<div class="cpgc-image-1" style="background-image: url({$image_1});"></div>
					</xsl:when>
					<xsl:otherwise>
						<div class="cpgc-image-1" style="background-image: url('/_resources/images/photo-grid-cta/photo-grid-1.jpg');"></div>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$image_2 != ''">
						<div class="cpgc-image-2" style="background-image: url({$image_2});"></div>
					</xsl:when>
					<xsl:otherwise>
						<div class="cpgc-image-2" style="background-image: url('/_resources/images/photo-grid-cta/photo-grid-2.jpg');"></div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="cpgc-col-2">
				<xsl:choose>
					<xsl:when test="$image_3 != ''">
						<div class="cpgc-image-3" style="background-image: url({$image_3});"></div>
					</xsl:when>
					<xsl:otherwise>
						<div class="cpgc-image-3" style="background-image: url('/_resources/images/photo-grid-cta/photo-grid-3.jpg');"></div>
					</xsl:otherwise>
				</xsl:choose>
				<a href="{$url}">
					<div class="cpgc-link-wrapper">
						<span><xsl:value-of select="$text" /></span>
						<span class="fa fa-arrow-right"></span>
					</div>
				</a>
				<xsl:choose>
					<xsl:when test="$image_4 != ''">
						<div class="cpgc-image-4" style="background-image: url({$image_4});"></div>
					</xsl:when>
					<xsl:otherwise>
						<div class="cpgc-image-4" style="background-image: url('/_resources/images/photo-grid-cta/photo-grid-4.jpg');"></div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<div class="cpgc-col-3">
				<xsl:choose>
					<xsl:when test="$image_5 != ''">
						<div class="cpgc-image-5" style="background-image: url({$image_5});"></div>
					</xsl:when>
					<xsl:otherwise>
						<div class="cpgc-image-5" style="background-image: url('/_resources/images/photo-grid-cta/photo-grid-5.jpg');"></div>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:choose>
					<xsl:when test="$image_6 != ''">
						<div class="cpgc-image-6" style="background-image: url({$image_6});"></div>
					</xsl:when>
					<xsl:otherwise>
						<div class="cpgc-image-6" style="background-image: url('/_resources/images/photo-grid-cta/photo-grid-6.jpg');"></div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
		
	</xsl:template>
	
	<!-- 5. Custom Heading -->
	<xsl:template match="ouc:component[@name='cerritos-custom-heading-component']">
		<xsl:variable name="heading" select=".//div[@class='heading']" />
		<xsl:variable name="color" select=".//div[@class='color']" />
		<xsl:variable name="heading-tag" select=".//div[@class='heading-tag']" />
		<xsl:variable name="size" select=".//div[@class='size']" />
		<xsl:variable name="weight" select=".//div[@class='weight']" />
		<xsl:variable name="text-transform" select=".//div[@class='text-transform']" />
		<xsl:variable name="margin" select=".//div[@class='margin']" />
		<xsl:variable name="spacing" select=".//div[@class='spacing']" />
		<xsl:variable name="font-family" select=".//div[@class='font-family']" />
		<xsl:choose>
			<xsl:when test="$heading-tag = 'h2'">
				<h2 style="font-size: {$size}; font-family: {$font-family}; letter-spacing: {$spacing}; font-weight: {$weight}; color: {$color}; margin: {$margin}; text-transform: {$text-transform};"><xsl:value-of select="$heading" /></h2>
			</xsl:when>
			<xsl:when test="$heading-tag = 'h3'">
				<h3 style="font-size: {$size}; font-family: {$font-family}; letter-spacing: {$spacing}; font-weight: {$weight}; color: {$color}; margin: {$margin}; text-transform: {$text-transform};"><xsl:value-of select="$heading" /></h3>
			</xsl:when>
			<xsl:when test="$heading-tag = 'h4'">
				<h4 style="font-size: {$size}; font-family: {$font-family}; letter-spacing: {$spacing}; font-weight: {$weight}; color: {$color}; margin: {$margin}; text-transform: {$text-transform};"><xsl:value-of select="$heading" /></h4>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	<!-- 6. Rounded Background -->
	<xsl:template match="table[contains(@class, 'ou-rounded-background')]">
		<xsl:variable name="bg" select="replace(normalize-space(tbody/tr/td[@class='ou-rounded-bg']),'&nbsp;','')" />
		<xsl:variable name="custom-class" select="replace(normalize-space(tbody/tr/td[@class='ou-class']),'&nbsp;','')" />
		<div class="cerritos-rounded-bg {$custom-class}" style="background: {$bg};">
			<div>
				<xsl:apply-templates select="tbody/tr/td[@class='ou-container-content']" />
			</div>
		</div>
	</xsl:template>
	
	<!-- 7. Video Lightbox -->
	<xsl:template match="ouc:component[@name='cerritos-video-lightbox']">
		<xsl:variable name="embed" select=".//div[@class='embed']" />
		<xsl:variable name="image" select=".//div[@class='image']" />
		<xsl:variable name="title" select=".//div[@class='title']" />
		<xsl:variable name="alt" select=".//div[@class='alt']" />
		<xsl:variable name="unique-id" select="generate-id(.)" />
		<a href="#" class="cerritos-video-lightbox-component-cover" data-toggle="modal" data-target="#video-lightbox-{$unique-id}">
			<img src="{$image}" alt="{$alt}" class="img-responsive cerritos-rounded-image" />
			<span class="sr-only">Open <xsl:value-of select="$alt" /> Video in a Popup</span>
		</a>
		<div id="video-lightbox-{$unique-id}" class="modal fade cerritos-video-lightbox-component-modal" tabindex="-1" role="dialog">
			<div class="modal-dialog modal-lg">
				<div class="modal-content">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-hidden="true"><span class="fa fa-close"></span><span class="sr-only">Close</span></button>
						<xsl:if test="$title != ''">
							<h2 class="h4 modal-title"><xsl:value-of select="$title" /></h2>
						</xsl:if>
					</div>
					<div class="modal-body">
						<div class="embed-responsive embed-responsive-16by9">
							<xsl:copy-of select="$embed" />
						</div>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>
	
	<!-- 8. Full Width Split CTA -->
	<xsl:template match="ouc:component[@name='cerritos-full-width-split-cta']">
		<xsl:variable name="embed" select=".//div[@class='embed']" />
		<xsl:variable name="show-video" select=".//div[@class='show-video']" />
		<xsl:variable name="image" select=".//div[@class='image']" />
		<xsl:variable name="heading" select=".//div[@class='heading']" />
		<xsl:variable name="preheading" select=".//div[@class='preheading']" />
		<xsl:variable name="subheading" select=".//div[@class='subheading']" />
		<xsl:variable name="button-text" select=".//div[@class='button-text']" />
		<xsl:variable name="button-url" select=".//div[@class='button-url']" />
		<xsl:variable name="margin" select=".//div[@class='margin']" />
		<xsl:variable name="align" select=".//div[@class='align']" />
		<xsl:variable name="unique-id" select="generate-id(.)" />
		
		<div class="cerritos-full-width-split-cta-component cfwscc-align-{$align}" style="margin: {$margin};">
			<div class="cfwscc-cta">
				<xsl:if test="$preheading != ''">
					<div class="cfwscc-pre-heading">
						<xsl:value-of select="$preheading" />
					</div>
				</xsl:if>
				<h2 class="cfwscc-heading">
					<xsl:value-of select="$heading" />
				</h2>
				<xsl:if test="$subheading != ''">
					<div class="cfwscc-sub-heading">
						<xsl:value-of select="$subheading" />
					</div>
				</xsl:if>
				<xsl:if test="$button-url != ''">
					<a href="{$button-url}" class="cfwscc-button"><xsl:value-of select="$button-text" /> <span class="fa fa-arrow-right"></span></a>
				</xsl:if>
			</div>
			<xsl:choose>
				<xsl:when test="$show-video = 'yes'">
					<a href="#" class="cfwscc-media cerritos-video-lightbox-component-cover"  style="background-image: url({$image});" data-toggle="modal" data-target="#video-lightbox-{$unique-id}">
						<span class="sr-only">Open <xsl:value-of select="$heading" /> Video in a Popup</span>
					</a>
				</xsl:when>
				<xsl:otherwise>
					<div class="cfwscc-media" style="background-image: url({$image});"></div>
				</xsl:otherwise>
			</xsl:choose>
		</div>
		<xsl:if test="$show-video = 'yes'">
			<div id="video-lightbox-{$unique-id}" class="modal fade cerritos-video-lightbox-component-modal" tabindex="-1" role="dialog">
				<div class="modal-dialog modal-lg">
					<div class="modal-content">
						<div class="modal-header">
							<button type="button" class="close" data-dismiss="modal" aria-hidden="true"><span class="fa fa-close"></span><span class="sr-only">Close</span></button>
						</div>
						<div class="modal-body">
							<div class="embed-responsive embed-responsive-16by9">
								<xsl:copy-of select="$embed" />
							</div>
						</div>
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- 9 . List Group Image - only the image portion of the component -->
	<xsl:template match="ouc:component[@name='cerritos-list-group-image']">
		<xsl:variable name="image" select=".//div[@class='image']" />
		<xsl:variable name="alt" select=".//div[@class='alt']" />
		<xsl:if test="$image != ''">
			<div class="clg-image">
				<img src="{$image}" alt="{$alt}" />
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- 10. Testimonial Carousel -->
	<xsl:template match="ouc:component[@name='cerritos-testimonial-carousel']">
		<div class="cerritos-testimonial-carousel-component swiper">
			<xsl:attribute name="class">
				<xsl:text>cerritos-testimonial-carousel-component swiper</xsl:text>
				<xsl:if test="$ou:action != 'pub'">
					<xsl:text> autoplay-disabled</xsl:text>
				</xsl:if>
			</xsl:attribute>
			<div class="swiper-wrapper">
				<xsl:for-each select="div/ul[@class='slider-item']">
					<xsl:variable name="image" select="li[@class='image']" />
					<xsl:variable name="title" select="li[@class='title']" />
					<xsl:variable name="testimonial" select="li[@class='testimonial']" />
					<xsl:variable name="name" select="li[@class='name']" />
					
					<div class="swiper-slide">
						<div class="swiper-slide-content">
							<div class="ctcc-item">
								<xsl:if test="$image != ''">
									<div class="ctcc-image">
										<img src="{$image}" alt="{$name}" />
									</div>
								</xsl:if>
								<div class="ctcc-testimonial">
									<div class="ctcc-testimonial-copy">
										&quot;<xsl:value-of select="$testimonial" />&quot;
									</div>
									<div class="ctcc-name">
										<xsl:value-of select="$name" />
									</div>
									<div class="ctcc-title">
										<xsl:value-of select="$title" />
									</div>
								</div>
							</div>
						</div>
					</div>
				</xsl:for-each>
			</div>
			<div class="swiper-pagination"></div>
			<button class="ctcc-pause" aria-label="Pause autoplay">
				<span class="fa fa-pause"></span>
			</button>
		</div>
	</xsl:template>
	
</xsl:stylesheet>