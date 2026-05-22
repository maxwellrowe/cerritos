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

	<!-- Components
	1. Placeholder for Components with no Preview
	2. Empty Test
	3. Slider 2 Wrapper
	4. Slider 2 Slides
	5. Slider 2 Buttons
	6. Slider 2 Slide
	7. Hero
	8. Metric
	9. Testimonial Slider
	10. Events
	11. News
	-->

	<!-- Component 1: Placeholder for Components with no Preview -->
	<xsl:template match="ouc:component[@name='comp-placeholder']">
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">

			</xsl:when>
			<xsl:otherwise>
				<div class="ou-preview card p-2 alert alert-info text-center">
					<span class="h6 d-block">--- Component Placeholder ----</span>
					<xsl:copy-of select="div[@class='placeholder-content']/node()" />
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Component 2: Empty Test -->
	<xsl:template match="div[@data-ouc-test='']">
	</xsl:template>
	
	<xsl:template match="img[@data-ouc-test='']">
	</xsl:template>

	<!-- Component 3: Slider 2 Wrapper -->
	<xsl:template match="ouc:component[@name='slider-2']">
		<xsl:apply-templates />
	</xsl:template>

	<!-- Component 4: Slider 2 Slides -->
	<xsl:template match="slides">
		<xsl:for-each select="slide">
			<xsl:call-template name="slide">
				<xsl:with-param name="position" select="position()" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>

	<!-- Component 5: Slider 2 Buttons -->
	<xsl:template match="buttons">
		<xsl:choose>
			<xsl:when test=".//a[@class='dlinkPage']/@href != ''">
				<div class="buttons">
					<a class="dlinkPage" href="{.//a[@class='dlinkPage']/@href}">d</a>&nbsp;<button id="toggle-custom-2">Pause</button>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<div class="buttons">
					<button id="toggle-custom-2">Pause</button>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Component 6: Slider 2 Slide -->
	<xsl:template name="slide">
		<xsl:param name="position" />
		<div>
			<img src="{.//img/@src}" alt="{.//img/@alt}" />
			<div class="slick-caption">
				<xsl:if test=".//div[@class='mainHeadingText'] != ''">
					<div class="mainHeadingText">
						<xsl:value-of select=".//div[@class='mainHeadingText']" />
					</div>
				</xsl:if>

				<xsl:if test=".//div[@class='subHeadingText'] != ''">
					<div class="subHeadingText">
						<xsl:copy-of select=".//div[@class='subHeadingText']" />
					</div>
				</xsl:if>

				<xsl:if test=".//a[@class='button']/@href != ''">
					<a class="button" href="{.//a[@class='button']/@href}">
						<xsl:value-of select=".//a[@class='button']" />
					</a>
				</xsl:if>
			</div>
		</div>

	</xsl:template>
	
	<!-- 7. Hero -->
	<xsl:template match="ouc:component[@name='cerritos-hero']">
		<!-- Vars -->
		<xsl:variable name="type" select="div[@class='type']" />
		<xsl:variable name="media" select="div[@class='media-type']" />
		<xsl:variable name="heading" select="div[@class='heading']" />
		<xsl:variable name="subheading" select="div[@class='subheading']" />
		<xsl:variable name="preheading" select="div[@class='preheading']" />
		<xsl:variable name="asset" select="div[@class='asset']/node()" />
		<xsl:variable name="ctas-status" select="div[@class='ctas-status']" />
		<xsl:variable name="ctas-heading" select="div[@class='ctas-heading']" />
		<xsl:variable name="ctas" select="div[@class='ctas']/node()" />
		<xsl:variable name="images" select="div[@class='images']/node()" />
		<xsl:variable name="video" select="div[@class='video']" />
		<xsl:variable name="video-embed" select="div[@class='video-embed']" />
		<xsl:variable name="video-placeholder" select="div[@class='video-placeholder']" />
		<xsl:variable name="unique-id" select="generate-id()"/>
		
		<!-- Determine 1 or 2 cols -->
		<xsl:variable name="first-col">
			<xsl:choose>
				<xsl:when test="$type != 'side-by-side'">
					col-12
				</xsl:when>
				<xsl:otherwise>
					order-2 order-lg-1 col-12 col-lg-6 col-xl-5 d-flex
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<div class="cerritos-hero-component chc__{$type} chc__{$media}">
			<!-- Only if not side by side then we have position absolute element -->
			<xsl:if test="$type != 'side-by-side'">
				<xsl:choose>
					<xsl:when test="$media != 'image'">
						<xsl:choose>
							<xsl:when test="$video != ' '">
								<div class="chc__bg-video">
									<video autoplay="true" muted="true" loop="true" playsinline="true" poster="{$video-placeholder}">
										<source src="{$video}" type="video/mp4" />
									</video>
									<button class="chc__play-pause-video">
										<span class="visually-hidden">Pause Video</span>
									</button>
								</div>
							</xsl:when>
							<xsl:otherwise>
								<div class="alert alert-warning">Please add a background video.</div>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<!-- Do Image stuff here -->
						<div class="chc__bg-image-slider">
							<div class="chc__swiper swiper-image-slider swiper">
								<div class="swiper-wrapper">
									<xsl:for-each select="$images[@class='image']">
										<xsl:variable name="image" select="div[@class='image-url']" />
										<div class="swiper-slide">
											<div class="chc__image ratio ratio-4x3" style="background-image: url({$image})"></div>
										</div>
									</xsl:for-each>
								</div>
							</div>
							<div class="chc__slider-controls">
								<button class="swiper-pause-play"><span class="visually-hidden">Pause Slideshow</span></button>
								<div class="swiper-button-prev"><span class="visually-hidden">Previous</span></div>
								<div class="swiper-button-next"><span class="visually-hidden">Next</span></div>
							</div>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			<div class="container-xxl chc__content">
				<div class="row text-white gx-lg-5 h-100">
					<div class="{$first-col}">
						<div class="d-flex justify-content-between flex-column align-items-start h-100 p-4 px-lg-0 w-100">
							<div>
								<xsl:if test="$preheading != ''">
									<div class="chc__preheading">
										<xsl:value-of select="$preheading" />
									</div>
								</xsl:if>
								<h1 class="chc__heading text-white text-shadow-sm anim-fade-up"><xsl:value-of select="$heading" /></h1>
								<xsl:if test="$subheading != ''">
									<div class="chc__subheading">
										<xsl:value-of select="$subheading" />
									</div>
								</xsl:if>
								<xsl:if test="$asset != ''">
									<div class="chc__asset">
										<xsl:copy-of select="$asset" />
									</div>
								</xsl:if>
							</div>
							<div>
								<xsl:if test="$type = 'side-by-side' and $ctas-status = 'show'">
									<div class="chc__ctas py-4">
										<xsl:if test="$ctas-heading != ''">
											<div class="chc__ctas-heading h5 text-white mb-3">
												<xsl:value-of select="$ctas-heading" />
											</div>
										</xsl:if>
										<div class="d-flex flex-wrap justify-content-start align-items-start gap-2">
											<xsl:for-each select="$ctas[@class='cta']">
												<xsl:variable name="link" select="div[@class='cta-link']" />
												<xsl:variable name="text" select="div[@class='cta-text']" />
												<a 
												   href="{$link}"
												   class="btn btn-primary btn-sm"
												>
													<xsl:value-of select="$text" />
												</a>
											</xsl:for-each>
										</div>
									</div>
								</xsl:if>
							</div>
						</div>
					</div>
					
					<xsl:if test="$type = 'side-by-side'">
						<div class="order-1 order-lg-2 col-lg-6 col-xl-7 d-flex align-items-center">
							<xsl:choose>
								<xsl:when test="$media != 'image'">
									<!-- Do video stuff here - modal with play button -->
									<a href="#"  class="chc__play-video-embed d-block w-100" data-bs-toggle="modal" data-bs-target="#cch__modal-{$unique-id}">
										<div class="chc__image ratio ratio-4x3 d-flex align-items-center justify-content-center" style="background-image: url({$video-placeholder})">
											<span>
												<span class="fa-sharp fa-solid fa-play">
													<span class="visually-hidden">Play Video</span>
												</span>
											</span>
										</div>
									</a>
								</xsl:when>
								<xsl:otherwise>
									<!-- Do Image stuff here -->
									<div class="chc__swiper swiper-image-slider swiper w-100">
										<div class="swiper-wrapper">
											<xsl:for-each select="$images[@class='image']">
												<xsl:variable name="image" select="div[@class='image-url']" />
												<div class="swiper-slide">
													<div class="chc__image ratio ratio-4x3 w-100" style="background-image: url({$image})"></div>
												</div>
											</xsl:for-each>
										</div>
										<button class="swiper-pause-play"><span class="visually-hidden">Pause Slideshow</span></button>
										<div class="swiper-button-prev"><span class="visually-hidden">Previous</span></div>
										<div class="swiper-button-next"><span class="visually-hidden">Next</span></div>
									</div>
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</xsl:if>
				</div>
			</div>
			
			<xsl:if test="$type != 'side-by-side' and $ctas-status = 'show'">
				<div class="chc__full-width-ctas">
					<div class="container-xxl">
						<div class="chc__ctas p-4 px-lg-0">
							<xsl:if test="$ctas-heading != ''">
								<div class="chc__ctas-heading h5 text-white mb-3">
									<xsl:value-of select="$ctas-heading" />
								</div>
							</xsl:if>
							<div class="d-flex flex-wrap justify-content-start align-items-start gap-2">
								<xsl:for-each select="$ctas[@class='cta']">
									<xsl:variable name="link" select="div[@class='cta-link']" />
									<xsl:variable name="text" select="div[@class='cta-text']" />
									<a 
									   href="{$link}"
									   class="btn btn-primary btn-sm"
									>
										<xsl:value-of select="$text" />
									</a>
								</xsl:for-each>
							</div>
						</div>
					</div>
				</div>
			</xsl:if>
			
			<xsl:if test="$type != 'side-by-side' and $type != 'full-width'">
				<div class="text-center py-3 position-relative z-3">
					<a href="#maincontent" class="chc__scroll-to-main btn btn-circle btn-secondary btn-sm">
						<span class="visually-hidden">Jump to Main Content</span>
						<span class="fa-sharp fa-regular fa-arrow-down"></span>
					</a>
				</div>
			</xsl:if>
		</div>
		<xsl:if test="$media != 'image' and $video-embed != ' '">
			<!-- Video Embed if applicable -->
			<div id="cch__modal-{$unique-id}" class="modal fade" tabindex="-1" aria-labelledby="cch__modal-title-{$unique-id}" aria-hidden="true">
				<div class="modal-dialog modal-xl">
					<div class="modal-content">
						<div class="modal-header">
							<span id="cch__modal-title-{$unique-id}" class="visually-hidden">Hero Video</span>
							<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
						</div>
						<div class="modal-body">
							<div class="ratio ratio-16x9">
								<xsl:copy-of select="$video-embed/node()" />
							</div>
						</div>
					</div>
				</div>
			</div>
		</xsl:if>
	</xsl:template>
	
	<!-- 8. Metric -->
	<xsl:template match="ouc:component[@name='cerritos-metric']">
		<!-- Vars -->
		<xsl:variable name="metric" select="div[@class='metric']" />
		<xsl:variable name="short-desc" select="div[@class='short-desc']" />
		<xsl:variable name="second-short-desc" select="div[@class='second-short-desc']" />
		<xsl:variable name="link" select="div[@class='link']" />
		<xsl:variable name="style" select="div[@class='style']" />
		<xsl:variable name="metric-fs" select="div[@class='metric-fs']" />
		<xsl:variable name="metric-color" select="div[@class='metric-color']" />
		<xsl:variable name="short-desc-fs" select="div[@class='short-desc-fs']" />
		<xsl:variable name="short-desc-color" select="div[@class='short-desc-color']" />
		<xsl:variable name="bg-color" select="div[@class='bg-color']" />
		
		<xsl:choose>
			<xsl:when test="$link != ''">
				<a href="{$link}" class="cerritos-component-metric ccm__style-{$style} {$bg-color}">
					<div class="ccm__metric {$metric-fs} {$metric-color}">
						<xsl:value-of select="$metric" />
					</div>
					<xsl:if test="$short-desc != ''">
						<div class="ccm__short-desc {$short-desc-fs} {$short-desc-color}">
							<xsl:value-of select="$short-desc" />
						</div>
					</xsl:if>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<div class="cerritos-component-metric ccm__style-{$style} {$bg-color}">
					<div class="ccm__metric {$metric-fs} {$metric-color}">
						<xsl:value-of select="$metric" />
					</div>
					<xsl:if test="$short-desc != ''">
						<div class="ccm__short-desc {$short-desc-fs} {$short-desc-color}">
							<xsl:value-of select="$short-desc" />
							<xsl:if test="$second-short-desc != ''">
								<span class="d-block" style="font-size: 70%;">
									<xsl:value-of select="$second-short-desc" />
								</span>
							</xsl:if>
						</div>
					</xsl:if>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- 9. Testimonial Slider -->
	<xsl:template match="ouc:component[@name='cerritos-testimonial-slider']">
		<div class="cerritos-component-testimonial-slider">
			<div class="ccts__swiper-slider swiper">
				<div class="swiper-wrapper">
					<xsl:for-each select="div[@class='testimonial']">
						<xsl:variable name="image" select="div[@class='image']" />
						<xsl:variable name="name" select="div[@class='name']" />
						<xsl:variable name="title" select="div[@class='title']" />
						<xsl:variable name="heading" select="div[@class='heading']" />
						<xsl:variable name="content" select="div[@class='content']" />
						<xsl:variable name="link" select="div[@class='link']" />
						<xsl:variable name="link-text" select="div[@class='link-text']" />
						
						<div class="ccts__swiper-slide swiper-slide">
							<div class="p-2">
								<div class="ccts__top">
									<div class="ccts__image ratio ratio-4x3 rounded" style="background-image: url({$image})"></div>
									<div class="ccts__name">
										<div>
											<xsl:value-of select="$name" />
										</div>
										<xsl:if test="$title != ''">
										<div class="ccts__title">
											<xsl:value-of select="$title" />
										</div>
									</xsl:if>
									</div>

								</div>
								<div class="ccts__bottom card border-light shadow-sm bg-white">
									<div class="card-body p-4">
										<xsl:if test="$heading != ''">
											<h2 class="h5">
												<xsl:value-of select="$heading" />
											</h2>
										</xsl:if>
										<xsl:copy-of select="$content" />
										<xsl:if test="$link != ''">
											<a href="{$link}" class="btn btn-primary btn-sm mt-3">
												<xsl:choose>
													<xsl:when test="$link-text != ''">
														<xsl:value-of select="$link-text" />
													</xsl:when>
													<xsl:otherwise>
														Read More
													</xsl:otherwise>
												</xsl:choose>
											</a>
										</xsl:if>
									</div>
								</div>
							</div>
						</div>
					</xsl:for-each>
				</div>
			</div>
			<div class="ccts__slider-controls">
				<button class="swiper-pause-play"><span class="visually-hidden">Pause Slideshow</span></button>
				<div class="swiper-button-prev"><span class="visually-hidden">Previous</span></div>
				<div class="swiper-button-next"><span class="visually-hidden">Next</span></div>
			</div>
		</div>
	</xsl:template>

	<!-- 10. Events -->
	<xsl:template match="ouc:component[@name='cerritos-events']">
		<xsl:variable name="calendar-rss" select="normalize-space(div[@class='calendar-rss'])" />
		<xsl:variable name="num-items">
			<xsl:choose>
				<xsl:when test="normalize-space(div[@class='num-items']) != ''">
					<xsl:value-of select="normalize-space(div[@class='num-items'])" />
				</xsl:when>
				<xsl:otherwise>3</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="cal-link" select="normalize-space(div[@class='cal-link'])" />
		<xsl:variable name="cal-link-text" select="normalize-space(div[@class='cal-link-text'])" />
		<xsl:variable name="unique-id" select="generate-id()" />
		<xsl:variable name="encoded-feed-url" select="encode-for-uri($calendar-rss)" />

		<div class="cerritos-component-events" id="{$unique-id}">
			<div class="cerritos-component-events__results">
				<xsl:choose>
					<xsl:when test="$ou:action = 'pub'">
						<script type="text/javascript">
							$("#<xsl:value-of select="$unique-id" /> .cerritos-component-events__results").load("/_resources/php/wnl/calendar-events-component.php?feed=<xsl:value-of select="$encoded-feed-url" />&amp;num_items=<xsl:value-of select="$num-items" />");
						</script>
						<noscript>The calendar requires javascript enabled.</noscript>
					</xsl:when>
					<xsl:otherwise>
						<div class="ou-preview card p-3 alert alert-info mb-0">
							<xsl:choose>
								<xsl:when test="$calendar-rss != ''">
									Calendar events will load on publish.
								</xsl:when>
								<xsl:otherwise>
									Add a calendar RSS feed URL to preview this component on publish.
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
			<xsl:if test="$cal-link != ''">
				<div class="cerritos-component-events__footer mt-3">
					<a href="{$cal-link}" class="btn btn-primary btn-sm">
						<xsl:choose>
							<xsl:when test="$cal-link-text != ''">
								<xsl:value-of select="$cal-link-text" />
							</xsl:when>
							<xsl:otherwise>View All Events</xsl:otherwise>
						</xsl:choose>
					</a>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- 11. News -->
	<xsl:template match="ouc:component[@name='cerritos-news']">
		<xsl:variable name="news-rss" select="normalize-space(div[@class='news-rss'])" />
		<xsl:variable name="num-items">
			<xsl:choose>
				<xsl:when test="normalize-space(div[@class='num-items']) != ''">
					<xsl:value-of select="normalize-space(div[@class='num-items'])" />
				</xsl:when>
				<xsl:otherwise>6</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="news-link" select="normalize-space(div[@class='news-link'])" />
		<xsl:variable name="news-link-text" select="normalize-space(div[@class='news-link-text'])" />
		<xsl:variable name="desktop-col">
			<xsl:choose>
				<xsl:when test="normalize-space(div[@class='desktop-col']) != ''">
					<xsl:value-of select="normalize-space(div[@class='desktop-col'])" />
				</xsl:when>
				<xsl:otherwise>2</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="tablet-col">
			<xsl:choose>
				<xsl:when test="normalize-space(div[@class='tablet-col']) != ''">
					<xsl:value-of select="normalize-space(div[@class='tablet-col'])" />
				</xsl:when>
				<xsl:otherwise>2</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="mobile-col">
			<xsl:choose>
				<xsl:when test="normalize-space(div[@class='mob-cols']) != ''">
					<xsl:value-of select="normalize-space(div[@class='mob-cols'])" />
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="unique-id" select="generate-id()" />
		<xsl:variable name="encoded-feed-url" select="encode-for-uri($news-rss)" />
		<xsl:variable name="encoded-news-link" select="encode-for-uri($news-link)" />
		<xsl:variable name="encoded-news-link-text" select="encode-for-uri($news-link-text)" />

		<div class="cerritos-component-news-wrapper" id="{$unique-id}">
			<div class="cerritos-component-news-wrapper__results">
				<xsl:choose>
					<xsl:when test="$ou:action = 'pub'">
						<script type="text/javascript">
							$("#<xsl:value-of select="$unique-id" /> .cerritos-component-news-wrapper__results").load("/_resources/php/wnl/news-rss-component.php?feed=<xsl:value-of select="$encoded-feed-url" />&amp;num_items=<xsl:value-of select="$num-items" />&amp;news_link=<xsl:value-of select="$encoded-news-link" />&amp;news_link_text=<xsl:value-of select="$encoded-news-link-text" />&amp;desktop_col=<xsl:value-of select="$desktop-col" />&amp;tablet_col=<xsl:value-of select="$tablet-col" />&amp;mobile_col=<xsl:value-of select="$mobile-col" />", function() {
								if (typeof initializeCerritosNewsSliders === 'function') {
									initializeCerritosNewsSliders(document.getElementById("<xsl:value-of select="$unique-id" />"));
								}
							});
						</script>
						<noscript>The news feed requires javascript enabled.</noscript>
					</xsl:when>
					<xsl:otherwise>
						<div class="ou-preview card p-3 alert alert-info mb-0">
							<xsl:choose>
								<xsl:when test="$news-rss != ''">
									News items will load on publish.
								</xsl:when>
								<xsl:otherwise>
									Add a news RSS feed URL to preview this component on publish.
								</xsl:otherwise>
							</xsl:choose>
						</div>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>
