<?php
date_default_timezone_set('America/Los_Angeles');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

require_once($_SERVER['DOCUMENT_ROOT'] . '/_resources/php/wnl/WNL.php');

function getCalendarParam($name, $default = '') {
    $value = filter_input(INPUT_GET, $name, FILTER_UNSAFE_RAW);

    if ($value === null || $value === false || $value === '') {
        return $default;
    }

    return trim($value);
}

function getCalendarIntParam($name, $default, $minimum = 1) {
    $value = filter_input(INPUT_GET, $name, FILTER_VALIDATE_INT);

    if ($value === null || $value === false) {
        return $default;
    }

    return max($minimum, (int) $value);
}

function getCalendarBoolParam($name, $default = false) {
    $value = filter_input(INPUT_GET, $name, FILTER_VALIDATE_BOOLEAN, FILTER_NULL_ON_FAILURE);

    if ($value === null) {
        return $default;
    }

    return (bool) $value;
}

function getCalendarCsvParam($name) {
    $value = getCalendarParam($name, '');

    if ($value === '') {
        return array();
    }

    $items = array_map('trim', explode(',', $value));

    return array_values(array_filter($items, static function ($item) {
        return $item !== '';
    }));
}

function escapeHtml($value) {
    return htmlspecialchars((string) $value, ENT_QUOTES, 'UTF-8');
}

function normalizeCalendarText($value) {
    $text = html_entity_decode(strip_tags((string) $value), ENT_QUOTES | ENT_HTML5, 'UTF-8');
    $text = preg_replace('/\s+/u', ' ', $text);

    return trim((string) $text);
}

function truncateCalendarText($value, $maxLength) {
    if ($maxLength <= 0) {
        return $value;
    }

    if (function_exists('mb_strlen') && function_exists('mb_substr')) {
        if (mb_strlen($value) <= $maxLength) {
            return $value;
        }

        return rtrim(mb_substr($value, 0, $maxLength)) . '...';
    }

    if (strlen($value) <= $maxLength) {
        return $value;
    }

    return rtrim(substr($value, 0, $maxLength)) . '...';
}

function buildXPathLiteral($value) {
    if (strpos($value, "'") === false) {
        return "'" . $value . "'";
    }

    if (strpos($value, '"') === false) {
        return '"' . $value . '"';
    }

    $parts = explode("'", $value);
    $literals = array();

    foreach ($parts as $index => $part) {
        if ($part !== '') {
            $literals[] = "'" . $part . "'";
        }

        if ($index < count($parts) - 1) {
            $literals[] = "\"'\"";
        }
    }

    return 'concat(' . implode(', ', $literals) . ')';
}

function buildCalendarXPath($tags) {
    if (empty($tags)) {
        return '/rss/channel/item';
    }

    $conditions = array_map(static function ($tag) {
        return 'cal:tags/cal:tag=' . buildXPathLiteral($tag);
    }, $tags);

    return '/rss/channel/item[' . implode(' or ', $conditions) . ']';
}

function isAllDayEvent($startValue) {
    return strpos((string) $startValue, 'T') === false;
}

function isUpcomingEvent($startValue, $endValue) {
    $now = time();
    $startTimestamp = strtotime((string) $startValue);
    $endTimestamp = strtotime((string) $endValue);

    if (isAllDayEvent($startValue)) {
        $today = date('Y-m-d');
        $endDate = $endValue !== '' ? date('Y-m-d', $endTimestamp) : date('Y-m-d', $startTimestamp);

        return $endDate >= $today;
    }

    if ($endTimestamp !== false && $endTimestamp > 0) {
        return $endTimestamp >= $now;
    }

    return $startTimestamp !== false && $startTimestamp >= $now;
}

function formatEventDateLabel($startValue, $endValue) {
    $startTimestamp = strtotime((string) $startValue);
    $endTimestamp = strtotime((string) $endValue);

    if ($startTimestamp === false) {
        return '';
    }

    if (isAllDayEvent($startValue)) {
        if (
            $endTimestamp !== false &&
            $endTimestamp > 0 &&
            date('Y-m-d', $endTimestamp) !== date('Y-m-d', $startTimestamp)
        ) {
            return date('F j, Y', $startTimestamp) . ' - ' . date('F j, Y', $endTimestamp);
        }

        return date('F j, Y', $startTimestamp);
    }

    if (
        $endTimestamp !== false &&
        $endTimestamp > 0 &&
        date('Y-m-d', $endTimestamp) !== date('Y-m-d', $startTimestamp)
    ) {
        return date('F j, Y g:i A', $startTimestamp) . ' - ' . date('F j, Y g:i A', $endTimestamp);
    }

    return date('F j, Y', $startTimestamp);
}

function formatEventTimeLabel($startValue, $endValue) {
    if (isAllDayEvent($startValue)) {
        return 'All day';
    }

    $startTimestamp = strtotime((string) $startValue);
    $endTimestamp = strtotime((string) $endValue);

    if ($startTimestamp === false) {
        return '';
    }

    if (
        $endTimestamp !== false &&
        $endTimestamp > 0 &&
        date('Y-m-d', $endTimestamp) === date('Y-m-d', $startTimestamp) &&
        date('g:i A', $endTimestamp) !== date('g:i A', $startTimestamp)
    ) {
        return date('g:i A', $startTimestamp) . ' - ' . date('g:i A', $endTimestamp);
    }

    return date('g:i A', $startTimestamp);
}

function formatEventBadgeMonth($startValue) {
    $startTimestamp = strtotime((string) $startValue);

    if ($startTimestamp === false) {
        return '';
    }

    return strtoupper(date('M', $startTimestamp));
}

function formatEventBadgeDay($startValue) {
    $startTimestamp = strtotime((string) $startValue);

    if ($startTimestamp === false) {
        return '';
    }

    return date('j', $startTimestamp);
}

function renderCalendarEvent($item, $descriptionLength) {
    $element = $item->original_element;
    $namespaces = $element->getNamespaces(true);
    $calendarNamespace = isset($namespaces['cal']) ? $namespaces['cal'] : null;
    $calendarData = $calendarNamespace ? $element->children($calendarNamespace) : null;
    $startValue = $calendarData ? trim((string) $calendarData->start) : '';
    $endValue = $calendarData ? trim((string) $calendarData->end) : '';
    $title = trim((string) $element->title);
    $url = trim((string) $element->link);
    $description = truncateCalendarText(normalizeCalendarText($element->description), $descriptionLength);
    $dateLabel = formatEventDateLabel($startValue, $endValue);
    $timeLabel = formatEventTimeLabel($startValue, $endValue);
    $dateTimeValue = $startValue !== '' ? $startValue : $endValue;
    $badgeMonth = formatEventBadgeMonth($startValue !== '' ? $startValue : $endValue);
    $badgeDay = formatEventBadgeDay($startValue !== '' ? $startValue : $endValue);

    echo '<article class="cerritos-calendar-events__item">';

    if ($url !== '') {
        echo '<a class="cerritos-calendar-events__item-link" href="' . escapeHtml($url) . '">';
    } else {
        echo '<div class="cerritos-calendar-events__item-link">';
    }

    echo '<div class="cerritos-calendar-events__date-badge" aria-hidden="true">';
    echo '<span class="cerritos-calendar-events__date-month">' . escapeHtml($badgeMonth) . '</span>';
    echo '<span class="cerritos-calendar-events__date-day">' . escapeHtml($badgeDay) . '</span>';
    echo '</div>';
    echo '<div class="cerritos-calendar-events__body">';

    echo '<h3 class="cerritos-calendar-events__title">';
    echo escapeHtml($title);
    echo '</h3>';

    if ($description !== '') {
        echo '<p class="cerritos-calendar-events__description">' . escapeHtml($description) . '</p>';
    }

    if ($dateLabel !== '' || $timeLabel !== '') {
        echo '<p class="cerritos-calendar-events__meta">';
        echo '<time class="cerritos-calendar-events__datetime" datetime="' . escapeHtml($dateTimeValue) . '">';
        echo escapeHtml($dateLabel);

        if ($timeLabel !== '') {
            echo ' <span class="cerritos-calendar-events__time">' . escapeHtml($timeLabel) . '</span>';
        }

        echo '</time>';
        echo '</p>';
    }

    echo '</div>';

    if ($url !== '') {
        echo '</a>';
    } else {
        echo '</div>';
    }

    echo '</article>';
}

$feed = getCalendarParam('feed', '');
$numItems = getCalendarIntParam('num_items', 3);
$descriptionLength = getCalendarIntParam('description_length', 160, 0);
$tags = getCalendarCsvParam('tag');
$categories = getCalendarCsvParam('categories');
$showPast = getCalendarBoolParam('show_past', false);

if ($feed === '') {
    http_response_code(400);
    echo '<p>Calendar feed is required.</p>';
    exit;
}

$xpath = buildCalendarXPath($tags);
$calendarFeed = new WNL($feed, $xpath, 'OmniCalendarRssItem', 'xml');

if (!empty($categories)) {
    $calendarFeed->categoryFilter($categories);
}

$items = $calendarFeed->items;
$filteredItems = array();

foreach ($items as $item) {
    $wrappedItem = new OmniCalendarRssItem($item);
    $element = $wrappedItem->original_element;
    $namespaces = $element->getNamespaces(true);
    $calendarNamespace = isset($namespaces['cal']) ? $namespaces['cal'] : null;
    $calendarData = $calendarNamespace ? $element->children($calendarNamespace) : null;
    $startValue = $calendarData ? trim((string) $calendarData->start) : '';
    $endValue = $calendarData ? trim((string) $calendarData->end) : '';

    if (!$showPast && !isUpcomingEvent($startValue, $endValue)) {
        continue;
    }

    $filteredItems[] = $wrappedItem;
}

if (empty($filteredItems)) {
    echo '<div class="cerritos-calendar-events"><p>No upcoming events found.</p></div>';
    exit;
}

$filteredItems = array_slice($filteredItems, 0, $numItems);

echo '<div class="cerritos-calendar-events">';

foreach ($filteredItems as $item) {
    renderCalendarEvent($item, $descriptionLength);
}

echo '</div>';
