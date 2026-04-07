<?php

function preview_fail(int $status, string $message): void
{
    http_response_code($status);
    header('Content-Type: text/plain; charset=UTF-8');
    echo $message;
    exit;
}

function list_fixture_files(string $fixturesDir): array
{
    $results = [];

    if (!is_dir($fixturesDir)) {
        return $results;
    }

    $iterator = new RecursiveIteratorIterator(
        new RecursiveDirectoryIterator($fixturesDir, FilesystemIterator::SKIP_DOTS)
    );

    foreach ($iterator as $file) {
        if (!$file->isFile()) {
            continue;
        }

        $extension = strtolower($file->getExtension());
        if (!in_array($extension, ['html', 'htm'], true)) {
            continue;
        }

        $relativePath = str_replace($fixturesDir . DIRECTORY_SEPARATOR, '', $file->getPathname());
        $relativePath = str_replace(DIRECTORY_SEPARATOR, '/', $relativePath);
        $results[] = $relativePath;
    }

    sort($results);

    return $results;
}

function inject_preview_banner(string $html, string $fixtureName): string
{
    $bannerCss = <<<CSS
<style id="preview-banner-styles">
    .preview-banner {
        position: sticky;
        top: 0;
        z-index: 9999;
        display: flex;
        gap: 12px;
        align-items: center;
        justify-content: space-between;
        padding: 12px 16px;
        background: #083b6d;
        color: #ffffff;
        font: 14px/1.4 Arial, sans-serif;
        box-shadow: 0 2px 12px rgba(0, 0, 0, 0.18);
    }

    .preview-banner strong {
        font-weight: 700;
    }

    .preview-banner a {
        color: #ffffff;
        text-decoration: underline;
    }
</style>
CSS;

    $bannerHtml = '<div class="preview-banner">'
        . '<div><strong>Local Preview</strong> Rendering fixture: '
        . htmlspecialchars($fixtureName, ENT_QUOTES, 'UTF-8')
        . '</div>'
        . '<div><a href="?">Change fixture</a></div>'
        . '</div>';

    if (stripos($html, '</head>') !== false) {
        $html = preg_replace('/<\/head>/i', $bannerCss . "\n</head>", $html, 1);
    } else {
        $html = $bannerCss . "\n" . $html;
    }

    if (stripos($html, '<body') !== false) {
        $html = preg_replace('/(<body\b[^>]*>)/i', '$1' . "\n" . $bannerHtml, $html, 1);
    } else {
        $html = $bannerHtml . "\n" . $html;
    }

    return $html;
}

function rewrite_fixture_html(string $html, string $repoRoot): string
{
    $replacements = [
        'href="/_resources/' => 'href="../_resources/',
        "href='/_resources/" => "href='../_resources/",
        'src="/_resources/' => 'src="../_resources/',
        "src='/_resources/" => "src='../_resources/",
        'url(/_resources/' => 'url(../_resources/',
        "url('/_resources/" => "url('../_resources/",
        'url("/_resources/' => 'url("../_resources/',
        'href="/scripts/' => 'href="../scripts/',
        "href='/scripts/" => "href='../scripts/",
        'src="/scripts/' => 'src="../scripts/',
        "src='/scripts/" => "src='../scripts/",
    ];

    $html = strtr($html, $replacements);

    $html = preg_replace('/\{\{[^\}]+\}\}/', '', $html);

    $repoRoot = rtrim(str_replace(DIRECTORY_SEPARATOR, '/', $repoRoot), '/');

    $html = preg_replace_callback(
        '/\b(?:href|src)=("|\')(\/[^"\']+)\\1/i',
        static function (array $matches) use ($repoRoot): string {
            $quote = $matches[1];
            $path = $matches[2];

            if (strpos($path, '/_resources/') === 0) {
                return substr($matches[0], 0, strpos($matches[0], '=')) . '=' . $quote . '../' . ltrim($path, '/') . $quote;
            }

            if (strpos($path, '/scripts/') === 0) {
                return substr($matches[0], 0, strpos($matches[0], '=')) . '=' . $quote . '../' . ltrim($path, '/') . $quote;
            }

            if (preg_match('#^/(?:https?:|mailto:|tel:|#)#i', $path)) {
                return $matches[0];
            }

            return $matches[0];
        },
        $html
    );

    return $html;
}

$repoRoot = realpath(__DIR__ . '/..');
$fixturesDir = $repoRoot . '/fixtures';
$fixtures = list_fixture_files($fixturesDir);

if (!$fixtures) {
    preview_fail(500, 'No fixture HTML files were found in /fixtures.');
}

$selected = isset($_GET['fixture']) ? trim((string) $_GET['fixture']) : $fixtures[0];
$selected = ltrim(str_replace('\\', '/', $selected), '/');

if (!in_array($selected, $fixtures, true)) {
    preview_fail(404, 'Fixture not found: ' . $selected);
}

$fixturePath = $fixturesDir . '/' . $selected;
$html = file_get_contents($fixturePath);

if ($html === false) {
    preview_fail(500, 'Could not read fixture: ' . $selected);
}

$mode = isset($_GET['mode']) ? (string) $_GET['mode'] : 'preview';

if ($mode !== 'raw') {
    $html = rewrite_fixture_html($html, $repoRoot);
    $html = inject_preview_banner($html, $selected);
}

header('Content-Type: text/html; charset=UTF-8');
echo $html;
