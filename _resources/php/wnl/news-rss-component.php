<?php
require_once($_SERVER['DOCUMENT_ROOT'] . '/_resources/php/wnl/WNL.php');

function getNewsParam($name, $default = '') {
    $value = filter_input(INPUT_GET, $name, FILTER_UNSAFE_RAW);

    if ($value === null || $value === false || $value === '') {
        return $default;
    }

    return trim($value);
}

function getNewsIntParam($name, $default, $minimum = 1) {
    $value = filter_input(INPUT_GET, $name, FILTER_VALIDATE_INT);

    if ($value === null || $value === false) {
        return $default;
    }

    return max($minimum, (int) $value);
}

function escapeNewsHtml($value) {
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

function normalizeNewsText($value) {
    $text = html_entity_decode(strip_tags((string) $value), ENT_QUOTES | ENT_HTML5, 'UTF-8');
    $text = preg_replace('/\s+/u', ' ', $text);

    return trim((string) $text);
}

function extractNewsImageUrl($item) {
    $image = '';
    $element = isset($item->original_element) ? $item->original_element : null;

    if ($element) {
        $namespaces = $element->getNamespaces(true);
        $mediaNamespace = isset($namespaces['media']) ? $namespaces['media'] : null;
        $mediaContent = $mediaNamespace ? $element->children($mediaNamespace) : null;

        if ($mediaContent && isset($mediaContent->content)) {
            $mediaContentAttributes = $mediaContent->content->attributes();

            if ($mediaContentAttributes && isset($mediaContentAttributes['url'])) {
                $image = trim((string) $mediaContentAttributes['url']);
            }
        }
    }

    if ($image === '') {
        $thumbnail = trim((string) $item->mthumb);

        if ($thumbnail !== '') {
            $image = $thumbnail;
        }
    }

    if ($image === '') {
        $mediaUrl = trim((string) $item->murl);

        if ($mediaUrl !== '') {
            $image = $mediaUrl;
        }
    }

    if ($image !== '') {
        return trim($image);
    }

    if (preg_match('/<img[^>]+src=["\']([^"\']+)["\']/i', (string) $item->description, $matches)) {
        return trim($matches[1]);
    }

    return '';
}

function renderNewsSlide($item) {
    $title = normalizeNewsText($item->title);
    $url = trim((string) $item->link);
    $image = extractNewsImageUrl($item);
    $backgroundStyle = $image !== '' ? ' style="background-image: url(' . escapeNewsHtml($image) . ')"' : '';
    $titleMarkup = $title !== '' ? escapeNewsHtml($title) : 'Read More';

    echo '<div class="swiper-slide">';
    echo '<a class="ccn__card card h-100 border-0 shadow-sm" href="' . escapeNewsHtml($url) . '">';
    echo '<div class="ccn__image-wrap">';
    echo '<div class="ccn__image ratio ratio-4x3"' . $backgroundStyle . '></div>';
    echo '</div>';
    echo '<div class="card-body">';
    echo '<h3 class="ccn__title">' . $titleMarkup . '</h3>';
    echo '</div>';
    echo '</a>';
    echo '</div>';
}

$feed = getNewsParam('feed', '');
$numItems = getNewsIntParam('num_items', 6);
$desktopCol = getNewsIntParam('desktop_col', 2);
$tabletCol = getNewsIntParam('tablet_col', 2);
$mobileCol = getNewsIntParam('mobile_col', 1);
$newsLink = getNewsParam('news_link', '');
$newsLinkText = getNewsParam('news_link_text', '');

if ($feed === '') {
    http_response_code(400);
    echo '<p>News feed is required.</p>';
    exit;
}

$newsFeed = new WNL($feed, '/rss/channel/item', 'CategoryRssItem', 'xml');
$newsFeed->sortByPubDate();
$items = array_slice($newsFeed->items, 0, $numItems);

if (empty($items)) {
    echo '<div class="cerritos-component-news"><p>No news items found.</p></div>';
    exit;
}

echo '<div class="cerritos-component-news" data-desktop-col="' . escapeNewsHtml($desktopCol) . '" data-tablet-col="' . escapeNewsHtml($tabletCol) . '" data-mobile-col="' . escapeNewsHtml($mobileCol) . '">';
echo '<div class="ccn__swiper swiper">';
echo '<div class="swiper-wrapper">';

foreach ($items as $itemNode) {
    $item = new CategoryRssItem($itemNode);
    renderNewsSlide($item);
}

echo '</div>';
echo '</div>';
echo '<div class="ccn__footer">';
echo '<div class="ccn__slider-controls">';
echo '<button class="swiper-button-prev" type="button"><span class="visually-hidden">Previous</span></button>';
echo '<button class="swiper-button-next" type="button"><span class="visually-hidden">Next</span></button>';
echo '</div>';

if ($newsLink !== '') {
    echo '<div class="ccn__cta">';
    echo '<a href="' . escapeNewsHtml($newsLink) . '" class="btn btn-outline-primary">';
    echo escapeNewsHtml($newsLinkText !== '' ? $newsLinkText : 'More News');
    echo '</a>';
    echo '</div>';
}

echo '</div>';
echo '</div>';
