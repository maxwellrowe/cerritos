<?php
if (isset($_GET['feed'])) { $feed = htmlspecialchars($_GET['feed']); }
if (isset($_GET['num_items'])) { $num_items = htmlspecialchars($_GET['num_items']); }

require_once($_SERVER['DOCUMENT_ROOT'].'/_resources/php/wnl/WNL.php');
$t = new WNL($feed);

function displayCalendarHomeNews($y){
	$y = $y->original_element;
	$maxChars = 200;
	
	$res = "";
	
  $title = strip_tags($y->title);
	$description = strip_tags($y->description);
  //$image = strip_tags($y->image);
  $image = $y->children("http://search.yahoo.com/mrss/")->attributes()->url;
	if (strlen($description) > $maxChars) { $description = substr($description, 0, $maxChars) . "..."; }
  	
	$newTitle = explode(' - ', $y->title);
	
  
  
 
	$res .= '<div class="col-md-4">';  
  
 
  
	//if (strlen($y->image) > 0){
		//$res .= '    <div class="image"><a href="' . $y->link . '"><img src="' . $y->image . '" alt="' . $y->title . '"></a></div>';
	//}
  
  if (strlen($image) > 0){

$res .= ' <div class="image"><a href="' . $y->link . '"><img src="' . $image   . '" alt="' . $y->title . '"></a></div>';

}
  
//	$res .= '    <h4><a href="' . $y->link . '">' . $newTitle[1] . '</a></h4>';
// 	$res .= '    <p>' .  date("F j, Y", strtotime($y->pubDate)) . ' ' . $description . '</p><p>
// 		</p>';

$res .= '        <div class="event-text">';

    $res .= '    <h4><a href="' . $y->link . '">' . $title . '</a></h4><p>
		</p>';
	//$res .= '    <p>' .  date("F j, Y", strtotime($y->pubDate)) . ' - ' . $description . '</p><p>
	$res .= '    <p>' . $description . '</p><p>
	
		</p>';
    
	$res .= '</div>';
  
  $res .= '</div>';

	echo($res);
}

// display the news
echo '<h3>News</h3><a class="button pull-right" href="/newsroom/">More Campus News</a>';
$t->sortByPubDate(SORT_DESC)->iterate('displayCalendarHomeNews', $num_items);

?>