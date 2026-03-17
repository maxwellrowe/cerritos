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
 
  
	$res .= '<ul class="js_cal">';
	$res .= '<li class="date"><h4><span>' .  date("F j, Y", strtotime($y->pubDate)) .  '</h4></span></li>';
	$res .= '<li><a href="' . $y->link . '">' . $newTitle[1] . '</a></li>';
	$res .= '<li>' . $description . '</li>';
	$res .= '</ul>';
  
  
  
   /*$res .= '            <hr/>';*/

	echo($res);
}

// display the events
$t->sortByPubDate(SORT_ASC)->iterate('displayCalendarListing', $num_items);

?>