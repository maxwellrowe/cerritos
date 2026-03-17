<?php

if (isset($_GET['feed'])) { $feed = htmlspecialchars($_GET['feed']); }

if (isset($_GET['num_items'])) { $num_items = htmlspecialchars($_GET['num_items']); }

require_once($_SERVER['DOCUMENT_ROOT'].'/_resources/php/wnl/WNL.php');

$t = new WNL($feed);

function displayCalendarHomeNews($y){

$y = $y->original_element;

$maxChars = 300;

$res = "";
$image = $y->children("http://search.yahoo.com/mrss/")->attributes()->url;

$pubDate = strip_tags($y->pubDate);
	
$title = strip_tags($y->title);

$description = strip_tags($y->description);

if (strlen($description) > $maxChars) { $description = substr($description, 0, $maxChars) . "..."; }

$res .= '<div class="row">';

$res .= '<div class="col-sm-2">';

//$res .= ' <div>' . date("F j, Y", strtotime($y->pubDate)) . '</div>';	

	$res .= '            <span class="event-month" style="display: block;text-align: center;text-transform: uppercase;font-size: 18px;padding-top:1em;">' .  date("M", strtotime($y->pubDate)) . '</span>';
	$res .= '            <span class="event-day" style="display: block;text-align: center;font-size: 50px;font-weight: 300;">' .  date("j", strtotime($y->pubDate)) . '</span>';

$res .= '</div>';

$res .= '<div class="col-sm-10">';
	
	
	if (strlen($image) > 0){
		$res .= '<div class="col-sm-3">';
		$res .= ' <div class="image" style="padding-top: 1em;"><a href="' . $y->link . '"><img src="' . $image   . '" alt="' . $y->title . '"></a></div>';
		$res .= '</div>';		
		$res .= '<div class="col-sm-9">';
		$res .= ' <h3><strong><a href="' . $y->link . '">' . $title . '</a></strong></h3>';
		$res .= '<p>'. $description . '</p>';
	$res .= '</div>';
	}else{	
		$res .= ' <h3><strong><a href="' . $y->link . '">' . $title . '</a></strong></h3>';
		$res .= '<p>'. $description . '</p>';	
	}
$res .= '</div>';

$res .= '</div><p></p>';

echo($res);

}

$t->sortByPubDate(SORT_DESC)->iterate('displayCalendarHomeNews');

?>
