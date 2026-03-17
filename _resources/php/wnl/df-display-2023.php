<?php

$url = "https://api.calendar.moderncampus.net/pubcalendar/e64d6183-6cc7-4dc1-9852-476756deeff5/rss?category=b89b0f05-11df-4726-9b11-c2af2bee3027&category=4f6c4099-c913-4cde-ba8c-7cfad5784baf&url=https://www.cerritos.edu/practice/calendar-test.htm&hash=true";

$i=0;
 $invalidurl = false;

 if(@simplexml_load_file($url)){
//   $feeds = simplexml_load_file($url);
	$feed = file_get_contents($url);
	$feed = str_replace("<cal:start>", "<calstart>", $feed);
	$feed = str_replace("</cal:start>", "</calstart>", $feed);
	$feed = str_replace("<cal:tags>", "<caltags>", $feed);
	$feed = str_replace("</cal:tags>", "</caltags>", $feed);
	$feed = str_replace("<cal:tag>", "<caltag>", $feed);
	$feed = str_replace("</cal:tag>", "</caltag>", $feed);
	$feeds = simplexml_load_string($feed);

 }else{
  $invalidurl = true;
  echo "<h2>Invalid RSS feed URL.</h2>";
 }

$dateToday = date("l, F d, Y");
echo "<h3>" . $dateToday . "</h3>";

 if(!empty($feeds)){
	 
echo "<ul>";
	 
  foreach ($feeds->channel->item as $item) {

   $title = $item->title;
   $link = $item->link;
   //$description = $item->description;
   $postDate = $item->{'calstart'};
   $pubDate = date('D, d M Y',strtotime($postDate));
   $currDate = date('D, d M Y');
	  $dfTag = $item->{'caltags'}->{'caltag'};

   if($dfTag=="Daily Falcon" and $pubDate==$currDate){
	   
   	$rss=$title;
   	$newPostDate =  explode("T", $postDate);
	
	$pubDate = $item->pubDate;
	$pubDate = strftime("%Y-%m-%d %H:%M:%S", strtotime($postDate));
	$newPubDate = explode(" ", $pubDate);   
	$dateShown = date('g:i a', strtotime($newPubDate[1]));
	   
	if(!empty($newPostDate[1])){
		
		echo "<li>".$dateShown." - <a href='".$link."'>".$rss."</a></li>";
		
	} else {
	
		echo "<li>All Day - <a href='".$link."'>".$rss."</a></li>";
		
	}
   $i++;
	   
   }	

  } 
echo "</ul>";

 }

?>
