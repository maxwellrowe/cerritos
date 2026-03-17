<?php
if (isset($_GET['feed'])) { $feed = htmlspecialchars($_GET['feed']); }
if (isset($_GET['num_items'])) { $num_items = htmlspecialchars($_GET['num_items']); }

require_once($_SERVER['DOCUMENT_ROOT'].'/_resources/php/wnl/WNL.php');

// *** LOCAL TESTS
// require_once('./WNL.php');
// $feed = htmlspecialchars('http://ouc-dev.cerritos.edu/calendar/rss/feed.php');
// *** END LOCAL TESTS

$t = new WNL($feed);

function displayCalendarListing($y){
	// NOTE: "-8" IS PACIFIC TIME FROM GMT. REPLACE AS NEEDED.
	// $timezone = -8;
	// $timezonemod = 60 * 60 * $timezone;
	// $now = time() + $timezonemod;
	$now = time();
	$nowmonth = date("M", $now);
	$nowdate = date("j", $now);
	// echo '<textarea>' . print_r($y,1) . '</textarea>';
	$maxChars = 200;
	$res = "";
	// $newTitle = explode(' - ', $y->original_element->title);
 	$newTitle = "";
    $i = 0;
    $titleParts = explode(' - ', $y->original_element->title);
    foreach($titleParts AS $thing) {
        if($i > 1) {
            $newTitle .= " - ";
        }
        if($i) {
            $newTitle .= $thing;
        }
        $i++;
    }
  
	$thisdatetime = (int) $y->original_element->pubDateAsTime;
	$thismonth = date('M', $thisdatetime);
	$thisdate = date('j', $thisdatetime);
	$thishour = date('g', $thisdatetime);
	$thismerid = date('a', $thisdatetime);
	$thismin = date('i', $thisdatetime);

	$timeshown = ($thishour == '0' AND $thismin == '00') ? 'All day' : $thishour . ':' . $thismin . ' ' . $thismerid;

	GLOBAL $eventcount;
	if($thismonth == $nowmonth AND $thisdate == $nowdate) {
		$res .= '<div class="dailyFalcon">';
		$res .= $timeshown . ' - ';
		//$res .= '<a href="' . $y->original_element->link . '">' . $newTitle[1] . '</a>';
	    //$res .= '<a href="' . $y->original_element->link . '">' . $y->title . '</a>';
    	$res .= '<a href="' . $y->original_element->link . '">' . $newTitle  .'</a>';
		$res .= '</div>';
		//$res .= '<p></p>';
		echo $res;
		$eventcount++;
	}
}

// NOTE: "-8" IS PACIFIC TIME FROM GMT. REPLACE AS NEEDED.
//$timezone = -8;
//$timezonemod = 60 * 60 * $timezone;
//$now = time() + $timezonemod;
$now = time();
$nowwkday = date("l", $now);
$nowdate = date("j", $now);
$nowmonth = date("F", $now);
$nowyear = date("Y", $now);
$nowstr = $nowwkday . ', ' . $nowdate . ' ' . $nowmonth . ', ' . $nowyear;
echo '<h3>Today\'s Events</h3>';
echo "<p class=\"dailyFalconDate\"><span class=\"date-underline\">" . $nowstr . "</span></p>";
// display the events
$t->sortByPubDate(SORT_ASC)->iterate('displayCalendarListing', $num_items);
if(!$eventcount) {
	echo 'No events';
}

?>
