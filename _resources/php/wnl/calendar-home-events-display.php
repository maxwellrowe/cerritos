<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

//if (isset($_GET['feed'])) { $feed = htmlspecialchars($_GET['feed']); }
if (isset($_GET['feed'])) { $feed = $_GET['feed']; }

if (isset($_GET['num_items'])) { $num_items = htmlspecialchars($_GET['num_items']); }

require_once($_SERVER['DOCUMENT_ROOT'].'/_resources/php/wnl/WNL.php');

$t = new WNL($feed, "/rss/channel/item[cal:tags/cal:tag='Homepage']", "OmniCalendarRssItem", "xml");

function displayCalendarListing($y){
	$y = $y->original_element;

    $ns = $y->getNamespaces(TRUE);

	$maxChars = 200;
	
	$res = "";
	
	$description = strip_tags($y->description);
	if (strlen($description) > $maxChars) { $description = substr($description, 0, $maxChars) . "..."; }
	
	//$newTitle = explode(' - ', $y->title);
	$newTitle = $y->title;
	
	
    //Update NS and locationName key for newer Omni Calendar
    //$location = $item->children($ns['cal'])->location;
    //$link = $item->link;
    //$title = $item->title;
    //$date = $y->children($ns['cal'])->start;
	//$end = $item->children($ns['cal'])->end;
    $start = $y->children($ns['cal'])->start;

	$res .= '<div class="col-md-4">';
	$res .= '    <div class="event postcard-left" style="clear: both;display: table;margin-bottom: 15px;position: relative;">';
	$res .= '        <div class="event-date" style="padding: 10px;/*! color: #fff; */line-height: 34px;width: 80px;display: table-cell;position: relative;">';
	$res .= '            <span class="event-month" style="display: block;text-align: center;text-transform: uppercase;font-size: 18px;">' .  date("M", strtotime($start)) . '</span>';
	$res .= '            <span class="event-day" style="display: block;text-align: center;font-size: 50px;font-weight: 300;">' .  date("j", strtotime($start)) . '</span>';
	$res .= '        </div>';
	$res .= '        <div class="event-text" style="color: #555555;font-size: 16px;line-height: 20px;position: relative;/*! top: -10px; */vertical-align: bottom;">';
	$res .= '    		<h4><a href="' . $y->link . '">' . $newTitle . '</a></h4>';
	$res .= '            <p>' . $description . '</p>';
	$res .= '        </div>';
	$res .= '    </div>';
	$res .= '</div>';

	echo($res);
}

// display the events
//echo '<a class="button pull-right" href="http://www.cerritos.edu/calendar/">More Campus Events</a><h3>Events</h3>';
echo '<h3>EVENTS</h3><div><a class="button pull-right" href="/campus-guide/academic-calendar.htm">Academic Calendar/Schedule</a> <a class="button pull-right" href="https://www.cerritos.edu/calendar/">More Campus Events</a></div>';
//$t->sortByPubDate(SORT_ASC)->iterate('displayCalendarListing', $num_items);
$t->iterate('displayCalendarListing', $num_items);

?>