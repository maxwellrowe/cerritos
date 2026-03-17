<?php
if (isset($_GET['feed'])) { $feed = htmlspecialchars($_GET['feed']); }
if (isset($_GET['num_items'])) { $num_items = htmlspecialchars($_GET['num_items']); }

require_once($_SERVER['DOCUMENT_ROOT'].'/_resources/php/wnl/WNL.php');
$t = new WNL($feed);

function displayCalendarListing($y){
	$y = $y->original_element;
	$maxChars = 200;
	
	$res = "";
	
	//$description = strip_tags($y->description);
  $description = $y->description;
	if (strlen($description) > $maxChars) { $description = substr($description, 0, $maxChars) . "..."; }
	
	$newTitle = explode(' - ', $y->title);
  $locAddress2 = strip_tags($y->locAddress2);
  $startTime1 = strip_tags($y->startTime);
  $startTime2 = ltrim($startTime1, '0');
  $endTime1 = strip_tags($y->endTime);
  $endTime2 = ltrim($endTime1, '0');
  
  
  
  $res .= '<div class="row">';
  
  $res .= '<div class="col-sm-2">';

	//$res .= '<div class="col-md-12" style="background-color: yellow;">';
	//$res .= '    <div class="event postcard-left" style="clear: both;display: table;margin-bottom: 15px;position: relative;background-color:red;">';
	//$res .= '        <div class="event-date" style="padding: 10px;/*! color: #fff; */line-height: 34px;width: 80px;display: table-cell;position: relative;">';
  	$res .= '            <span class="event-month" style="display: block;text-align: center;text-transform: uppercase;font-size: 18px;padding:.3em 0; background-color: #ffbe00; ">' .  date("M", strtotime($y->pubDate)) . '</span>';
	$res .= '            <span class="event-day" style="display: block;text-align: center;font-size: 50px;font-weight: 300; background-color: #eeeeee;">' .  date("j", strtotime($y->pubDate)) . '</span>';
	$res .= '        </div>';
  
  $res .= '<div class="col-sm-10">';
  
	//$res .= '        <div>';
	$res .= '    		<h3><a href="' . $y->link . '">' . $newTitle[1] . '</a></h3>';
	$res .= '            <p>' . $description . '</p>';
  $res .= '            <p>' . $startTime2 . ' - ' . $endTime2 . '</p>';
  $res .= '            <p>' . $locAddress2 . '</p>';
	//$res .= '        </div>';
	$res .= '    </div>';
 
	$res .= '</div>';
   $res .= '            <hr/>';

	echo($res);
}

// display the events
//echo '<a class="button pull-right" href="http://www.cerritos.edu/calendar/">More Campus Events</a><h3>Events</h3>';
//echo '<div class="pull-right"><a class="button" href="/campus-guide/academic-calendar.htm">Important Dates</a> <a class="button" href="https://www.cerritos.edu/calendar/">More Campus Events</a></div>';
$t->sortByPubDate(SORT_ASC)->iterate('displayCalendarListing', $num_items);

?>