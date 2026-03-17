<?php
if (isset($_GET['feed'])) { $feed = htmlspecialchars($_GET['feed']); }
if (isset($_GET['num_items'])) { $num_items = htmlspecialchars($_GET['num_items']); }

require_once($_SERVER['DOCUMENT_ROOT'].'/_resources/php/wnl/WNL.php');
$t = new WNL($feed);

function displayCalendarFeed($y){
	global $count;
	$count++;
	$y = $y->original_element;
	
	$res = "";
	
	$res .= '<li><span style="font-family: arial, helvetica, sans-serif;font-weight: bold;">' .  date("n/j/Y", strtotime($y->pubDate)) . ':</span> <span style="font-family:arial, helvetica, sans-serif;"><a href="#cal-' . $count . '">' . $y->title . '</a></span></li>';

	echo($res);
}

function displayCalendarFeedFull($y){
	global $count;
	$count++;
	$y = $y->original_element;
	
	$res = "";
	
	$res .= '<hr style="background:navy;height:.2em;" size="3" color="#000099" />';
	$res .= '<a name="cal-' . $count . '"></a>';
	$res .= '<a style="float:right;" href="#_top">[top]</a>';
	$res .= '<span style="font-size:105%;font-family:tahoma;font-weight:bold;font-style:italic;">' . $y->title . '</span><br/>';
	$res .= '<span style="font-family:arial, helvetica, sans-serif;">' .  date("n/j/Y", strtotime($y->pubDate)) . ' ' .  date("g:i A", strtotime($y->startTime));
	if (strcmp($y->startTime, $y->endTime) !== 0) {
		$res .= ' - ' . date("g:i A", strtotime($y->endTime));
	}
	if ($y->locAddress2 != '') {
		$res .= ' • ' . $y->locAddress2;
	}
	$res .= '</span><br/>';
	
	$res .= '<div class="details" style="font-family: arial, helvetica, sans-serif;"><p>' . $y->description . '</p></div>';
	
// 	$contactURL = str_replace('<![CDATA[', '', $y->contactURL);
// 	$contactURL = str_replace(']]>', '', $contactURL);
// 	if (strpos($y->contactURL, '/calendar/index.php') === false) {
	if ($y->contactURL != '') {
		$res .= '<span style="font-style:italic;font-family:arial,helvetica,sans-serif;">Related link:</span> <a style="color:#009;font-family:arial,helvetica,sans-serif;" href="http://bit.ly/2ACgF8c" target="_blank"><em>' . $y->contactURL . '</em></a><br/>';
	}
	
	if ($y->contactName != '') {
		$res .= '<span style="font-family:arial,helvetica,sans-serif;">' . contactName;
		if ($y->contactEmail != '') {
			$res .= ' • <a href="mailto:' . $y->contactEmail . '">' . $y->contactEmail . '</a></span>';
		}
		if ($y->contactPhone != '') {
			$res .= ' • ' . $y->contactEmail;
		}
		$res .= '</span><br/>';
	}
	
	$res .= '<span style="font-family:arial,helvetica,sans-serif;">Cerritos College • 11110 Alondra Blvd • Norwalk  • CA 90650<br></span>';
	
// 	$res .= '<li><span style="font-family: arial, helvetica, sans-serif;font-weight: bold;">' .  date("n/j/Y", strtotime($y->pubDate)) . ':</span> <span style="font-family:arial, helvetica, sans-serif;"><a href="' . $y->link . '">' . $y->title . '</a></span></li>';

	echo($res);
}

// display the news
echo '<a name="_top"></a>';
$count = 0;
$t->sortByPubDate(SORT_ASC)->iterate('displayCalendarFeed', $num_items);
$count = 0;
$t->sortByPubDate(SORT_ASC)->iterate('displayCalendarFeedFull', $num_items);

?>