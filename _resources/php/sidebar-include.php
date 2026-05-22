<?php
$path = isset($cerritos_include_path) ? (string) $cerritos_include_path : '';
$type = isset($cerritos_include_type) ? (string) $cerritos_include_type : '';
$variant = isset($cerritos_include_variant) ? (string) $cerritos_include_variant : 'default';

$allowedTypes = ['sidebar-nav', 'sidebar-info'];
$allowedVariants = ['default', 'desktop', 'mobile'];

if ($path === '' || !in_array($type, $allowedTypes, true) || !in_array($variant, $allowedVariants, true)) {
    return;
}

if ($path[0] !== '/' || strpos($path, '..') !== false) {
    return;
}

$fullPath = $_SERVER['DOCUMENT_ROOT'] . $path;

if (!is_file($fullPath)) {
    return;
}

ob_start();
include $fullPath;
$markup = (string) ob_get_clean();

$normalized = preg_replace('/<!--.*?-->/s', ' ', $markup);
$normalized = preg_replace('/&nbsp;|&#160;/i', ' ', (string) $normalized);
$normalized = trim(strip_tags((string) $normalized));

if ($normalized === '') {
    return;
}

if ($type === 'sidebar-nav' && $variant === 'desktop') {
    echo '<div class="card shadow-sm"><nav class="sidebar-nav">';
    echo $markup;
    echo '</nav></div>';
    return;
}

if ($type === 'sidebar-nav' && $variant === 'mobile') {
    echo '<nav class="sidebar-nav">';
    echo $markup;
    echo '</nav>';
    return;
}

if ($type === 'sidebar-info') {
    echo '<div id="deptinfo" class="card shadow-sm mt-4 px-3 py-1">';
    echo $markup;
    echo '</div>';
}
