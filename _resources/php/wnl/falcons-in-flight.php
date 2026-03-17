<?php

if (isset($_GET['feed'])) { $feed = htmlspecialchars($_GET['feed']); }

if (isset($_GET['num_items'])) { $num_items = htmlspecialchars($_GET['num_items']); }

require_once($_SERVER['DOCUMENT_ROOT'].'/_resources/php/wnl/WNL.php');

$t = new WNL($feed);

function displayCalendarHomeNews($y){

$y = $y->original_element;

$maxChars = 600;

$res = "";
$image = $y->children("http://search.yahoo.com/mrss/")->attributes()->url;

$title = strip_tags($y->title);

$description = strip_tags($y->description);
	
//$media_title = $y->children('media', "http://search.yahoo.com/mrss/")->$media->content->title;
	
$media = $y->children('media', 'http://search.yahoo.com/mrss/');
    if(isset($media->content)) {
        $media_title_2 = (string) $media->content->title;
    }
	

if (strlen($description) > $maxChars) { $description = substr($description, 0, $maxChars) . "..."; }

$res .= '<div class="row">';

$res .= '<div class="col-sm-4">';

if (strlen($image) > 0){

$res .= ' <div class="image"><a href="' . $y->link . '"><img src="' . $image   . '" alt="' . $y->title . '"></a></div>';

}

$res .= '</div>';

$res .= '<div class="col-sm-8">';

$res .= ' <p><strong><a href="' . $y->link . '">' . $title . '</a></strong><br/>';

//$res .= ' ' . date("F j, Y", strtotime($y->pubDate)) . ' - ' . $description . '</p>';
$res .= ''. $description . '..</p><p><a class="button" href="' . $y->link . '">read more about ' . $media_title_2 .'</a></p>';

$res .= '</div>';

$res .= '</div><p></p>';

echo($res);

}

$t->sortByPubDate(SORT_DESC)->iterate('displayCalendarHomeNews');

?>
