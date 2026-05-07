/**************
Animations 
**************/

// Scroll Reveal
document.addEventListener('DOMContentLoaded', function () {
    var fadeUpElements = document.querySelectorAll('.anim-fade-up');
    var fadeInElements = document.querySelectorAll('.anim-fade-in');

    if ((!fadeUpElements.length && !fadeInElements.length) || typeof gsap === 'undefined' || typeof ScrollTrigger === 'undefined') {
        return;
    }

    gsap.registerPlugin(ScrollTrigger);

    fadeUpElements.forEach(function (element) {
        gsap.fromTo(
            element,
            {
                autoAlpha: 0,
                y: 24
            },
            {
                autoAlpha: 1,
                y: 0,
                duration: 0.7,
                ease: 'power2.out',
                scrollTrigger: {
                    trigger: element,
                    start: 'top 85%',
                    once: true
                }
            }
        );
    });

    fadeInElements.forEach(function (element) {
        gsap.fromTo(
            element,
            {
                autoAlpha: 0
            },
            {
                autoAlpha: 1,
                duration: 0.7,
                ease: 'power2.out',
                scrollTrigger: {
                    trigger: element,
                    start: 'top 85%',
                    once: true
                }
            }
        );
    });
});

// Search Panel
document.addEventListener('DOMContentLoaded', function () {
    var searchPanel = document.querySelector('#search-panel');
    var searchInput = document.querySelector('#q-panel');

    if (!searchPanel || !searchInput) {
        return;
    }

    searchPanel.addEventListener('shown.bs.collapse', function () {
        searchInput.focus();
    });
});

// Main Nav Panel
document.addEventListener('DOMContentLoaded', function () {
    var body = document.body;
    var mainNavToggle = document.querySelector('#main-nav-panel-toggle');
    var mainNavToggleLabel = mainNavToggle ? mainNavToggle.querySelector('.visually-hidden') : null;

    if (!body || !mainNavToggle) {
        return;
    }

    mainNavToggle.addEventListener('click', function () {
        var isOpen = body.classList.toggle('main-nav-panel-open');

        mainNavToggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');

        if (mainNavToggleLabel) {
            mainNavToggleLabel.textContent = isOpen ? 'Close Main Navigation Menu' : 'Open Main Navigation Menu';
        }
    });
});

// Sidebar Navigation
document.addEventListener('DOMContentLoaded', function () {
    var sidebarNavs = document.querySelectorAll('.sidebar-nav');

    if (!sidebarNavs.length) {
        return;
    }

    function normalizePath(path) {
        return path
            .replace(/\/(?:default|index)\.(?:html?|php)$/i, '/')
            .replace(/\/$/, '') || '/';
    }

    function getChildToggle(item) {
        return item.querySelector(':scope > span > a, :scope > a');
    }

    var currentPath = normalizePath(window.location.pathname);

    sidebarNavs.forEach(function (nav) {
        nav.querySelectorAll('li').forEach(function (item) {
            var childList = item.querySelector(':scope > ul');
            var childToggle = getChildToggle(item);

            if (childList && childToggle) {
                item.classList.add('has-children');
                childList.removeAttribute('style');
                childToggle.setAttribute('aria-expanded', 'false');

                childToggle.addEventListener('click', function (event) {
                    event.preventDefault();
                    event.stopPropagation();

                    var isExpanded = item.classList.toggle('is-expanded');
                    childList.removeAttribute('style');
                    childToggle.setAttribute('aria-expanded', isExpanded ? 'true' : 'false');
                });
            }
        });

        nav.querySelectorAll('a[href]').forEach(function (link) {
            var linkUrl;

            try {
                linkUrl = new URL(link.getAttribute('href'), window.location.origin);
            } catch (error) {
                return;
            }

            if (linkUrl.origin !== window.location.origin || normalizePath(linkUrl.pathname) !== currentPath) {
                return;
            }

            var currentItem = link.closest('li');

            if (!currentItem) {
                return;
            }

            currentItem.classList.add('current-page');
            link.setAttribute('aria-current', 'page');

            var parentItems = [];
            var parent = currentItem.parentElement ? currentItem.parentElement.closest('li') : null;

            while (parent) {
                parentItems.push(parent);
                parent = parent.parentElement ? parent.parentElement.closest('li') : null;
            }

            parentItems.forEach(function (parentItem) {
                var parentToggle = getChildToggle(parentItem);

                parentItem.classList.add('current-ancestor', 'is-expanded');

                if (parentToggle) {
                    parentToggle.setAttribute('aria-expanded', 'true');
                }
            });
        });
    });
});

// Global Header
document.addEventListener('DOMContentLoaded', function () {
    var header = document.querySelector('header#global-header');

    if (!header || typeof gsap === 'undefined' || typeof ScrollTrigger === 'undefined') {
        return;
    }

    gsap.registerPlugin(ScrollTrigger);

    gsap.to(header, {
        '--header-parallax-y': '80px',
        ease: 'none',
        scrollTrigger: {
            trigger: header,
            start: 'top top',
            end: 'bottom top',
            scrub: true
        }
    });
});

// Anchor Scroll
document.addEventListener('DOMContentLoaded', function () {
    if (
        typeof gsap === 'undefined' ||
        typeof ScrollToPlugin === 'undefined' ||
        typeof ScrollTrigger === 'undefined'
    ) {
        return;
    }

    gsap.registerPlugin(ScrollTrigger, ScrollToPlugin);

    function getScrollOffset() {
        var header = document.querySelector('header#global-header');

        if (!header) {
            return 100;
        }

        return Math.max(Math.round(header.getBoundingClientRect().height) + 24, 100);
    }

    document.querySelectorAll('a[href^="#"]').forEach(function (link) {
        link.addEventListener('click', function (event) {
            var hash = link.getAttribute('href');
            var target;
            var targetId;

            if (!hash || hash === '#') {
                return;
            }

            targetId = hash.slice(1);

            if (!targetId) {
                return;
            }

            target = document.getElementById(targetId);

            if (!target) {
                try {
                    target = document.querySelector(hash);
                } catch (error) {
                    return;
                }
            }

            if (!target) {
                return;
            }

            event.preventDefault();
            document.documentElement.style.scrollBehavior = 'auto';

            gsap.to(window, {
                duration: 0.8,
                ease: 'power2.out',
                scrollTo: {
                    y: target,
                    offsetY: getScrollOffset()
                },
                onComplete: function () {
                    if (window.location.hash !== hash) {
                        history.pushState(null, '', hash);
                    }

                    if (!target.hasAttribute('tabindex')) {
                        target.setAttribute('tabindex', '-1');
                    }

                    target.focus({
                        preventScroll: true
                    });

                    ScrollTrigger.refresh();
                }
            });
        });
    });
});

// Bootstrap Modals
document.addEventListener('DOMContentLoaded', function () {
    var modals = document.querySelectorAll('.modal');

    if (!modals.length || !document.body) {
        return;
    }

    modals.forEach(function (modal) {
        if (modal.parentElement !== document.body) {
            document.body.appendChild(modal);
        }
    });
});

// Bootstrap Modal YouTube Video Handling
document.addEventListener('DOMContentLoaded', function () {
    var modals = document.querySelectorAll('.modal');

    if (!modals.length) {
        return;
    }

    function isYouTubeEmbed(src) {
        return /(?:youtube\.com\/embed\/|youtube-nocookie\.com\/embed\/|youtu\.be\/)/i.test(src || '');
    }

    function withAutoplay(src) {
        var url;

        try {
            url = new URL(src, window.location.origin);
        } catch (error) {
            return src;
        }

        url.searchParams.set('autoplay', '1');
        url.searchParams.set('mute', '0');

        return url.toString();
    }

    modals.forEach(function (modal) {
        modal.addEventListener('shown.bs.modal', function () {
            modal.querySelectorAll('iframe[src]').forEach(function (iframe) {
                var originalSrc = iframe.getAttribute('data-modal-video-src') || iframe.getAttribute('src');

                if (!isYouTubeEmbed(originalSrc)) {
                    return;
                }

                iframe.setAttribute('data-modal-video-src', originalSrc);
                iframe.setAttribute('src', withAutoplay(originalSrc));
            });
        });

        modal.addEventListener('hide.bs.modal', function () {
            modal.querySelectorAll('iframe[data-modal-video-src]').forEach(function (iframe) {
                iframe.setAttribute('src', iframe.getAttribute('data-modal-video-src'));
            });
        });
    });
});

// Swiper Image Slider
document.addEventListener('DOMContentLoaded', function () {
    var sliders = document.querySelectorAll('.swiper-image-slider.swiper');

    if (!sliders.length || typeof Swiper === 'undefined') {
        return;
    }

    sliders.forEach(function (slider) {
        var sliderScope = slider.closest('.cerritos-hero-component') ||
            slider.closest('.chc__bg-image-slider') ||
            slider.closest('.swiper-image-slider') ||
            slider.parentElement ||
            slider;
        var slides = slider.querySelectorAll('.swiper-slide');
        var slideCount = slides.length;
        var prevButton = sliderScope.querySelector('.swiper-button-prev');
        var nextButton = sliderScope.querySelector('.swiper-button-next');
        var pausePlayButton = sliderScope.querySelector('.swiper-pause-play');
        var pausePlayLabel = pausePlayButton ? pausePlayButton.querySelector('.visually-hidden') : null;
        var hasMultipleSlides = slideCount > 1;

        if (pausePlayButton) {
            pausePlayButton.setAttribute('type', 'button');
        }

        if (!hasMultipleSlides) {
            if (prevButton) {
                prevButton.hidden = true;
            }

            if (nextButton) {
                nextButton.hidden = true;
            }

            if (pausePlayButton) {
                pausePlayButton.hidden = true;
            }
        }

        var swiper = new Swiper(slider, {
            slidesPerView: 1,
            effect: 'fade',
            fadeEffect: {
                crossFade: true
            },
            loop: hasMultipleSlides,
            autoplay: hasMultipleSlides ? {
                delay: 4000,
                disableOnInteraction: false
            } : false,
            navigation: hasMultipleSlides && prevButton && nextButton ? {
                prevEl: prevButton,
                nextEl: nextButton,
                addIcons: false
            } : undefined
        });

        if (!hasMultipleSlides || !pausePlayButton) {
            return;
        }

        function updatePausePlayButton(isPaused) {
            pausePlayButton.classList.toggle('is-paused', isPaused);
            pausePlayButton.setAttribute('aria-pressed', isPaused ? 'true' : 'false');

            if (pausePlayLabel) {
                pausePlayLabel.textContent = isPaused ? 'Play Slideshow' : 'Pause Slideshow';
            }
        }

        updatePausePlayButton(false);

        pausePlayButton.addEventListener('click', function () {
            var isPaused = pausePlayButton.classList.contains('is-paused');

            if (isPaused) {
                swiper.autoplay.start();
                updatePausePlayButton(false);
            } else {
                swiper.autoplay.stop();
                updatePausePlayButton(true);
            }
        });
    });
});

// Testimonial Slider
document.addEventListener('DOMContentLoaded', function () {
    var sliders = document.querySelectorAll('.cerritos-component-testimonial-slider');

    if (!sliders.length || typeof Swiper === 'undefined') {
        return;
    }

    sliders.forEach(function (slider) {
        var swiperElement = slider.querySelector('.ccts__swiper-slider.swiper');
        var slides = swiperElement ? swiperElement.querySelectorAll('.swiper-slide') : [];
        var slideCount = slides.length;
        var prevButton = slider.querySelector('.swiper-button-prev');
        var nextButton = slider.querySelector('.swiper-button-next');
        var pausePlayButton = slider.querySelector('.swiper-pause-play');
        var pausePlayLabel = pausePlayButton ? pausePlayButton.querySelector('.visually-hidden') : null;
        var hasMultipleSlides = slideCount > 1;
        var isManuallyPaused = false;
        var swiper;

        if (!swiperElement) {
            return;
        }

        if (pausePlayButton) {
            pausePlayButton.setAttribute('type', 'button');
        }

        if (!hasMultipleSlides) {
            if (prevButton) {
                prevButton.hidden = true;
            }

            if (nextButton) {
                nextButton.hidden = true;
            }

            if (pausePlayButton) {
                pausePlayButton.hidden = true;
            }
        }

        swiper = new Swiper(swiperElement, {
            slidesPerView: 1,
            loop: hasMultipleSlides,
            autoplay: hasMultipleSlides ? {
                delay: 4000,
                disableOnInteraction: false
            } : false,
            navigation: hasMultipleSlides && prevButton && nextButton ? {
                prevEl: prevButton,
                nextEl: nextButton,
                addIcons: false
            } : undefined
        });

        if (!hasMultipleSlides || !pausePlayButton) {
            return;
        }

        function updatePausePlayButton(isPaused) {
            pausePlayButton.classList.toggle('is-paused', isPaused);
            pausePlayButton.setAttribute('aria-pressed', isPaused ? 'true' : 'false');

            if (pausePlayLabel) {
                pausePlayLabel.textContent = isPaused ? 'Play Slideshow' : 'Pause Slideshow';
            }
        }

        updatePausePlayButton(false);

        pausePlayButton.addEventListener('click', function () {
            isManuallyPaused = !isManuallyPaused;

            if (isManuallyPaused) {
                swiper.autoplay.stop();
                updatePausePlayButton(true);
            } else {
                swiper.autoplay.start();
                updatePausePlayButton(false);
            }
        });
    });
});

// Image Slider
document.addEventListener('DOMContentLoaded', function () {
    var sliders = document.querySelectorAll('.cerritos-component-image-slider');

    if (!sliders.length || typeof Swiper === 'undefined') {
        return;
    }

    sliders.forEach(function (slider) {
        var swiperElement = slider.querySelector('.cerritos-swiper-offcanvas.swiper, .cerritos-swiper-single.swiper');
        var slides = swiperElement ? swiperElement.querySelectorAll('.swiper-slide') : [];
        var slideCount = slides.length;
        var prevButton = slider.querySelector('.swiper-button-prev');
        var nextButton = slider.querySelector('.swiper-button-next');
        var pausePlayButton = slider.querySelector('.swiper-pause-play');
        var pausePlayLabel = pausePlayButton ? pausePlayButton.querySelector('.visually-hidden') : null;
        var hasMultipleSlides = slideCount > 1;
        var isOffcanvasSlider = swiperElement ? swiperElement.classList.contains('cerritos-swiper-offcanvas') : false;
        var swiper;
        var resizeObserver;

        if (!swiperElement) {
            return;
        }

        function updateOffcanvasSlideWidth() {
            if (!isOffcanvasSlider) {
                return;
            }

            swiperElement.style.setProperty('--cerritos-swiper-base-width', slider.clientWidth + 'px');

            if (swiper) {
                swiper.update();
            }
        }

        if (pausePlayButton) {
            pausePlayButton.setAttribute('type', 'button');
        }

        if (!hasMultipleSlides) {
            if (prevButton) {
                prevButton.hidden = true;
            }

            if (nextButton) {
                nextButton.hidden = true;
            }

            if (pausePlayButton) {
                pausePlayButton.hidden = true;
            }
        }

        swiper = new Swiper(swiperElement, {
            slidesPerView: isOffcanvasSlider ? 'auto' : 1,
            spaceBetween: isOffcanvasSlider ? 16 : 0,
            loop: hasMultipleSlides,
            autoplay: hasMultipleSlides ? {
                delay: 4000,
                disableOnInteraction: false
            } : false,
            navigation: hasMultipleSlides && prevButton && nextButton ? {
                prevEl: prevButton,
                nextEl: nextButton,
                addIcons: false
            } : undefined
        });

        updateOffcanvasSlideWidth();

        if (isOffcanvasSlider) {
            if (typeof ResizeObserver !== 'undefined') {
                resizeObserver = new ResizeObserver(function () {
                    updateOffcanvasSlideWidth();
                });
                resizeObserver.observe(slider);
            } else {
                window.addEventListener('resize', updateOffcanvasSlideWidth);
            }
        }

        if (!hasMultipleSlides || !pausePlayButton) {
            return;
        }

        function updatePausePlayButton(isPaused) {
            pausePlayButton.classList.toggle('is-paused', isPaused);
            pausePlayButton.setAttribute('aria-pressed', isPaused ? 'true' : 'false');

            if (pausePlayLabel) {
                pausePlayLabel.textContent = isPaused ? 'Play Slideshow' : 'Pause Slideshow';
            }
        }

        updatePausePlayButton(false);

        pausePlayButton.addEventListener('click', function () {
            var isPaused = pausePlayButton.classList.contains('is-paused');

            if (isPaused) {
                swiper.autoplay.start();
                updatePausePlayButton(false);
            } else {
                swiper.autoplay.stop();
                updatePausePlayButton(true);
            }
        });
    });
});

// Hero Background Video
document.addEventListener('DOMContentLoaded', function () {
    var heroVideos = document.querySelectorAll('.cerritos-hero-component.chc__video .chc__bg-video');

    if (!heroVideos.length) {
        return;
    }

    heroVideos.forEach(function (videoWrapper) {
        var video = videoWrapper.querySelector('video');
        var pausePlayButton = videoWrapper.querySelector('.chc__play-pause-video');
        var pausePlayLabel = pausePlayButton ? pausePlayButton.querySelector('.visually-hidden') : null;

        if (!video || !pausePlayButton) {
            return;
        }

        pausePlayButton.setAttribute('type', 'button');

        function updatePausePlayButton(isPaused) {
            pausePlayButton.classList.toggle('is-paused', isPaused);
            pausePlayButton.setAttribute('aria-pressed', isPaused ? 'true' : 'false');

            if (pausePlayLabel) {
                pausePlayLabel.textContent = isPaused ? 'Play Video' : 'Pause Video';
            }
        }

        updatePausePlayButton(video.paused);

        pausePlayButton.addEventListener('click', function () {
            if (video.paused) {
                var playPromise = video.play();

                if (playPromise && typeof playPromise.catch === 'function') {
                    playPromise.catch(function () {
                        updatePausePlayButton(true);
                    });
                }
            } else {
                video.pause();
            }
        });

        video.addEventListener('play', function () {
            updatePausePlayButton(false);
        });

        video.addEventListener('pause', function () {
            updatePausePlayButton(true);
        });
    });
});

// Image Pin Section
document.addEventListener('DOMContentLoaded', function () {
    var pinSections = document.querySelectorAll('.image-pin-section');

    if (!pinSections.length) {
        return;
    }
});

// Match Height Rows
document.addEventListener('DOMContentLoaded', function () {
    if (typeof window.jQuery === 'undefined' || typeof window.jQuery.fn.matchHeight !== 'function') {
        return;
    }

    var $ = window.jQuery;
    var $items = $('.match-height-row');

    if (!$items.length) {
        return;
    }

    function applyMatchHeight() {
        $items.matchHeight({
            byRow: true
        });
    }

    applyMatchHeight();
    $(window).on('load resize orientationchange', applyMatchHeight);
    $('.accordion-collapse, .collapse').on('shown.bs.collapse', applyMatchHeight);
});

// Sticky Media
document.addEventListener('DOMContentLoaded', function () {
    var stickyMediaItems = document.querySelectorAll('.sticky-media-parent, .sticky-media-wrap');

    if (!stickyMediaItems.length) {
        return;
    }

    stickyMediaItems.forEach(function (item) {
        var wrapper = item.parentElement;
        var column = wrapper ? wrapper.parentElement : null;
        var stickyClass = item.classList.contains('sticky-media-parent') ? 'sticky-media-parent' : 'sticky-media-wrap';

        if (!wrapper || !column) {
            return;
        }

        if (
            wrapper.tagName === 'DIV' &&
            column.matches &&
            column.matches('[class*="col-"]') &&
            !wrapper.classList.contains(stickyClass)
        ) {
            wrapper.classList.add(stickyClass);
            item.classList.remove(stickyClass);
        }
    });
});
