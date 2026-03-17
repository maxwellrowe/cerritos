<?php
// PHP 7.0-safe; no mbstring needed; minimal dependencies
header('Content-Type: application/json; charset=utf-8');

// --- TEMP: uncomment while debugging ---
// ini_set('display_errors', '1');
// error_reporting(E_ALL);

function encodeLikeXsl($s) {
    // Lowercase ASCII only (your mapping only targets a-z plus some symbols)
    $s = strtolower($s);
    static $map = [
        'a'=>'9','b'=>'8','c'=>'7','d'=>'6','e'=>'5','f'=>'4','g'=>'3','h'=>'2','i'=>'1','j'=>'0',
        'k'=>'!','l'=>'`','m'=>'~','n'=>'$','o'=>':','p'=>'^','q'=>'*','r'=>'(','s'=>')','t'=>'[',
        'u'=>']','v'=>'|','w'=>'/','x'=>'\\','y'=>'-','z'=>'_',
        '('=>'a',')'=>'b','.'=>'c',' '=>'d','-'=>'e',"'"=>'f'
    ];
    $out = '';
    $len = strlen($s);
    for ($i=0; $i<$len; $i++) {
        $ch = $s[$i];
        $out .= isset($map[$ch]) ? $map[$ch] : $ch;
    }
    return $out;
}

function buildEmailUrl($email, $firstname, $lastname, $formUrl) {
    $email = trim($email);
    if ($email === '') return null;

    // only addresses at cerritos.edu; skip noreply@
    if (!preg_match('/^([^@]+)@cerritos\.edu$/i', $email, $m)) return null;
    $local = $m[1];
    if (strtolower($local) === 'noreply') return null;

    $pairs = [
        'e' => encodeLikeXsl($local),
        'n' => encodeLikeXsl($firstname),
        'l' => encodeLikeXsl($lastname),
    ];
    $qs = [];
    foreach ($pairs as $k => $v) $qs[] = $k.'='.rawurlencode($v);
    return $formUrl . '?' . implode('&', $qs);
}

try {
    // 1) Resolve ?xml (site-relative)
    if (empty($_GET['xml']) || $_GET['xml'][0] !== '/') {
        throw new Exception('Missing or invalid xml parameter (use ?xml=/path/to/employees.xml)');
    }
    $urlPath = parse_url($_GET['xml'], PHP_URL_PATH);
    if (!$urlPath || $urlPath[0] !== '/') throw new Exception('xml must be a site-relative path');

    $docRoot = rtrim(isset($_SERVER['DOCUMENT_ROOT']) ? $_SERVER['DOCUMENT_ROOT'] : '', DIRECTORY_SEPARATOR);
    $candidate = $docRoot . str_replace('/', DIRECTORY_SEPARATOR, $urlPath);
    $real = realpath($candidate);
    if ($real === false || !is_file($real)) throw new Exception('XML file not found');

    // Limit to this folder
    $allowedBase = realpath($docRoot . '/_resources/directory');
    if ($allowedBase === false || strpos($real, $allowedBase) !== 0) throw new Exception('Access denied for this path');

    // 2) Optional custom form URL param (relative only)
    $formUrl = isset($_GET['formtomailurl']) ? $_GET['formtomailurl'] : '/scripts/employeesmailform-2.aspx';
    $formPath = parse_url($formUrl, PHP_URL_PATH);
    if (!$formPath || $formPath[0] !== '/') throw new Exception('formtomailurl must be a relative path starting with "/"');
    $formUrl = $formPath;

    // 3) Load XML
    libxml_use_internal_errors(true);
    $xml = simplexml_load_file($real);
    if ($xml === false) throw new Exception('Invalid XML');

    // Support roots <employeeslist> or <employeelist> or flat list
    if (isset($xml->employee)) {
        $list = $xml->employee;
    } elseif (isset($xml->employeeslist->employee)) {
        $list = $xml->employeeslist->employee;
    } elseif (isset($xml->employeelist->employee)) {
        $list = $xml->employeelist->employee;
    } else {
        $list = [];
    }
	
	// Optional filters
    $divdeptFilter = isset($_GET['divdept']) ? trim($_GET['divdept']) : '';

    $out = [];
    foreach ($list as $e) {
        $lastname   = trim((string)$e->lastname);
        $firstname  = trim((string)$e->firstname);
        $middlename = trim((string)$e->middlename);
        $name       = trim((string)$e->name);
		$extension  = trim((string)$e->EXTENSION);
        $phone      = trim((string)$e->phone);
        $divdept    = trim((string)$e->divdept);
        $jobtitle   = trim((string)$e->jobtitle);
        $emailaddr  = trim((string)$e->emailaddr);
        $urladdr    = trim((string)$e->urladdr);

        // --- new filter ---
        if ($divdeptFilter !== '' && strcasecmp($divdept, $divdeptFilter) !== 0) {
            continue; // skip if doesn't match
        }

        $email_url  = buildEmailUrl($emailaddr, $firstname, $lastname, $formUrl);

        $out[] = [
            'lastname'   => $lastname,
            'firstname'  => $firstname,
            'middlename' => $middlename,
            'name'       => $name,
            'phone'      => $phone,
			'extension'  => $extension,
            'divdept'    => $divdept,
            'jobtitle'   => $jobtitle,
			'emailaddr'	 => $emailaddr,
            'urladdr'    => $urladdr,
            'email_url'  => $email_url,
        ];
    }
	
	// Sort by lastname
	usort($out, function ($a, $b) {
        return strcasecmp($a['lastname'], $b['lastname']);
    });

    header('Cache-Control: max-age=300, public');
    echo json_encode(['employees' => $out]);
} catch (Exception $e) {
    http_response_code(400);
    echo json_encode(['error' => $e->getMessage()]);
}