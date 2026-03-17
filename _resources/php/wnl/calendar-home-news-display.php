<?php
if (isset($_GET['feed'])) { $feed = htmlspecialchars($_GET['feed']); }
if (isset($_GET['num_items'])) { $num_items = htmlspecialchars($_GET['num_items']); }

require_once($_SERVER['DOCUMENT_ROOT'].'/_resources/php/wnl/WNL.php');
$t = new WNL($feed);

function displayCalendarHomeNews($y){
	$y = $y->original_element;
	$maxChars = 200;
	
	$res = "";
	
	$description = strip_tags($y->description);
	if (strlen($description) > $maxChars) { $description = substr($description, 0, $maxChars) . "..."; }
	
	$newTitle = explode(' - ', $y->title);

	$res .= '<div class="col-md-4">';
	if (strlen($y->image) > 0){
		$res .= '    <div class="image"><a href="' . $y->link . '"><img src="' . $y->image . '" alt="' . $y->title . '"></a></div>';
	}
	$res .= '    <h4><a href="' . $y->link . '">' . $newTitle[1] . '</a></h4>';
// 	$res .= '    <p>' .  date("F j, Y", strtotime($y->pubDate)) . ' ' . $description . '</p><p>
// 		</p>';
	$res .= '    <p>' . $description . '</p><p>
		</p>';
	$res .= '</div>';

	echo($res);
}

// display the news
echo '<h3>News</h3><a class="button pull-right" href="/events">More Campus News</a>';
$t->sortByPubDate(SORT_ASC)->iterate('displayCalendarHomeNews', $num_items);

?>