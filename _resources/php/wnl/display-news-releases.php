<?php

if (isset($_GET['feed'])) { $feed = htmlspecialchars($_GET['feed']); }

if (isset($_GET['num_items'])) { $num_items = htmlspecialchars($_GET['num_items']); }

require_once($_SERVER['DOCUMENT_ROOT'].'/_resources/php/wnl/WNL.php');

$t = new WNL($feed);

function displayCalendarHomeNews($y){

$y = $y->original_element;

$maxChars = 80;

$res = "";
//$image = $y->children("http://search.yahoo.com/mrss/")->attributes()->url;


$title = strip_tags($y->title);
	
$year = date("Y", strtotime($y->pubDate));
$month = date("M", strtotime($y->pubDate));
$cur_m = $_GET['cur_month'];
$cur_y = $_GET['cur_year'];
//$now = time();	
//$nowMonth = date("M", $now); 
//$nowYear = date("Y", $now);


//$description = strip_tags($y->description);
//if (strlen($description) > $maxChars) { $description = substr($description, 0, $maxChars) . "..."; }

if (strlen($title) > $maxChars) { $title = substr($title, 0, $maxChars) . "..."; }
if ($month == $cur_m AND $year == $cur_y){
$res .= '<div class="row">';

//$res .= '<div class="col-sm-4">';

//if (strlen($image) > 0){

//$res .= ' <div class="image"><a href="' . $y->link . '"><img src="' . $image   . '" alt="' . $y->title . '"></a></div>';

//}

//$res .= '</div>';
	


$res .= '<div class="col-sm-12">';
	
$res .= '<ul>';	
	
	
	
$res .= ' <li>' . date("m/d", strtotime($y->pubDate)) . ' - <a href="' . $y->link . '">' . $title . '</a>';
		
	

$res .= '</li></ul>';
	
	
$res .= '</div>';

$res .= '</div>';	
	


echo($res);

}
	
	}

$t->sortByPubDate(SORT_DESC)->iterate('displayCalendarHomeNews');

?>
