<?php
require_once($_SERVER['DOCUMENT_ROOT'].'/_resources/php/wnl/WNL.php');
$t = new WNL($feed);

function displayNews($y){
	$res = "";
	$res .= '<article>';
	if (strlen(@$y->mthumb) > 0){
		$res .= '	<figure> <a href="' . $y->link . '"> <img src="' . $y->mthumb . '" alt="' . $y->mdesc . '" /> </a> </figure>';
	}
	$res .= '	<h5 class="newsevent-date">' .  date("l, F jS, Y", strtotime($y->pubDate)) . '</h5>';
	$res .= '	<h4><a href="' . $y->link . '">' . $y->title . '</a></h4>';
	$res .= '	<p>' . $y->description . '</p>';
	$res .= '</article>';
	
  	echo($res);
}

// display the news
$t->sortByPubDate()->iterate('displayNews', $num_items);

?>