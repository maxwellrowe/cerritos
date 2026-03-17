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
	
$newTitle = explode(' ', $y->title);

if (strlen($description) > $maxChars) { $description = substr($description, 0, $maxChars) . "..."; }
	
	
	


$res .= '<div class="col-sm-6">';
	$res .= '<div class="well blue">';
	$res .= ' <div style="padding-top: 1em;"><img src="' . $image   . '" alt="' . $y->title . '" /></div>';
	//$res .= '' .  date("M", strtotime($y->pubDate)) . '.&nbsp;' .  date("j", strtotime($y->pubDate)) .',&nbsp;'.  date("Y", strtotime($y->pubDate)) .'';
	$res .= ' <h4><strong>' . $title . '</strong></h4>';
	$res .= '<p>'.  date("M", strtotime($y->pubDate)) . '.&nbsp;' .  date("j", strtotime($y->pubDate)) .',&nbsp;'.  date("Y", strtotime($y->pubDate)) .' - '. $description . '<a href="' . $y->link . '">read more about '  . $newTitle[0] .  '</a></p>' ;
	$res .= '</div>';
$res .= '</div>';



echo($res);

}

$t->sortByPubDate(SORT_DESC)->iterate('displayCalendarHomeNews');

?>
