<?php
date_default_timezone_set('America/Los_Angeles');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if (isset($_GET['feed'])) { $feed = $_GET['feed']; }
if (isset($_GET['num_items'])) { $num_items = htmlspecialchars($_GET['num_items']); }

require_once('WNL.php');

$xpath = "/rss/channel/item[cal:tags/cal:tag='Daily Falcon']";

// Create feed.
$t = new WNL($feed, $xpath, "OmniCalendarRssItem", "xml");

$date_full = date("l, d F, Y");

$allDayEvents = [];
$timeEvents = [];

function collectCalendarEvents($y){
    global $allDayEvents, $timeEvents;
    $y = $y->original_element;
    $ns = $y->getNamespaces(TRUE);

    // Get today's date
    $today_date = date("Y-m-d");

    // Get the start date
    $date = $y->children($ns['cal'])->start;
    $start_date = dateConv($date, "Y-m-d");

    // Get the end date
    $end = $y->children($ns['cal'])->end;
    $end_date = dateConv($end, "Y-m-d");

    if($start_date == $today_date || ($today_date >= $start_date && $today_date <= $end_date)) {
        $res = '';

        $link = $y->link;
        $title = $y->title;

        if (strlen($date) == 10) {
            $start = 'All Day';
            $allDayEvents[] = '<div class="dailyFalcon">'.$start.' - <a href="'.$link.'">'.$title.'</a></div>';
        } else {
            $start = dateConv($date, "g:i a");
            $timeEvents[] = '<div class="dailyFalcon">'.$start.' - <a href="'.$link.'">'.$title.'</a></div>';
        }
    }
	
	// Sort the $timeEvents array by $start
    usort($timeEvents, function($a, $b) {
        preg_match('/(\d+:\d+\s[APap][Mm])/', $a, $matchesA);
        preg_match('/(\d+:\d+\s[APap][Mm])/', $b, $matchesB);
        $timeA = strtotime($matchesA[0]);
        $timeB = strtotime($matchesB[0]);
        return $timeA - $timeB;
    });
	
}




function dateConv($datestamp, $opt){    
    $cnvtDate = date("c", strtotime($datestamp));
    $newDate = date($opt, strtotime($cnvtDate));   
    return $newDate;
}

$t->iterate('collectCalendarEvents', $num_items);

echo '<div id="DFEventsDiv">';
echo '<h3>Today\'s Events</h3>';
echo '<p class="dailyFalconDate"><span class="date-underline">'.$date_full.'</span></p>';

// Display "all day" events first
foreach ($allDayEvents as $event) {
    echo $event;
}

// Display time-specific events second
foreach ($timeEvents as $event) {
    echo $event;
}

echo '</div>';
?>
