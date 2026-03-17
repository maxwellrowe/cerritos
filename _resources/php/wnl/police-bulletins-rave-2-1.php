<?php

$feed = simplexml_load_file("https://www.getrave.com/rss/cerritos/channel1");
foreach ($feed->channel->item as $item) {
	echo $item->title . '<br>';
	echo $item->description . '<br>';
	echo $item->enclosure->attributes()->url . '<br>';
	echo $item->pubDate . '<br>';
}

?>
