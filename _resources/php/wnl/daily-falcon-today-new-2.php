<?php
date_default_timezone_set('America/Los_Angeles');

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

if (isset($_GET['feed'])) { $feed = $_GET['feed']; }

if (isset($_GET['num_items'])) { $num_items = htmlspecialchars($_GET['num_items']); }

require_once('WNL.php');

$xpath = "/rss/channel/item[cal:tags/cal:tag='Daily Falcon']";

//Create feed.
$t = new WNL($feed, $xpath, "OmniCalendarRssItem", "xml");

$date_full;
$date_full = date("l, d F, Y");

function displayCalendarListing($y){
	$y = $y->original_element;

    $ns = $y->getNamespaces(TRUE);

    //Get today's date 
    $today_date;
    $today_date = date("Y-m-d");

    //Get the start date
    $date = $y->children($ns['cal'])->start;
    //Convert to proper format
    $start_date = dateConv($date, "Y-m-d");

    //Get the end date
    $end = $y->children($ns['cal'])->end;
    //Convert to proper format
    $end_date = dateConv($end, "Y-m-d");

    if($start_date == $today_date || ($today_date >= $start_date && $today_date <= $end_date)) {
        $res = '';
	
        $start = $y->children($ns['cal'])->start;

        $link = $y->link;
        $title = $y->title;
        $end = $y->children($ns['cal'])->end;   
        $start = "";
        
        if (strlen($date) == 10){
            $start = 'All Day';
        } elseif($start != $end) {
            $start = dateConv($date, "g:i a");
        }

        $res .= '<div class="dailyFalcon">'.$start.' - <a href="'.$link.'">'.$title.'</a></div>';

        echo($res);
    } 
}

// display the events
//echo '<div id="DFEventsDiv">';
echo '<h3>Today\'s Events</h3>';
echo '<p class="dailyFalconDate"><span class="date-underline">'.$date_full.'</span></p>';

//$t->sortByPubDate(SORT_ASC)->iterate('displayCalendarListing', $num_items);
$t->iterate('displayCalendarListing', $num_items);

//echo '</div>';

function dateConv($datestamp, $opt){    
    $cnvtDate = date("c", strtotime($datestamp));
    $newDate = date($opt, strtotime($cnvtDate));   
    return $newDate;
}

?>