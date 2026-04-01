<%@ Page Language="VB" aspcompat="true" Debug="true" %>
<%@ Import Namespace="System.Net.Mail" %>
<!DOCTYPE html>
<script runat="server">
    REM this script is for the old version of recaptcha only 1.0
    Dim sEmails As String = String.Empty
	Dim sName As String = String.Empty
	Dim sLastName As String = String.Empty
    'Dim sName As ArrayList = Nothing
    Dim sReferer As String = String.Empty
	
	
	Dim sDecodedFirst As String = String.Empty
	Dim sDecodedLast As String = String.Empty
	

    Protected Sub Page_Load(sender As Object, e As System.EventArgs) Handles Me.Load
        Try
		
            errorlbl.Text = ""
            Dim s As String = String.Empty
			

            If Not Request.QueryString("e") Is Nothing Then
                If Request.QueryString("e").Length > 0 Then
                    sEmails = Request.QueryString("e")
                    'sEmails = Server.HtmlDecode(Request.QueryString("e"))
                    'sEmail = New ArrayList
                    'sEmail.AddRange(Request.QueryString("e").Split(","))
                End If
            Else
                s &= "* Recipient's Email is Blank"
            End If
            errorlbl.Text = s
            'Exit Sub
        Catch ex As Exception
            errorlbl.Text = ex.ToString
        End Try
		
		sName = Request.QueryString("n")
		sLastName = Request.QueryString("l")

        'Dim oEncrypter As New Aes256Base64Encrypter()
        'HttpContext.Current.Response.Write(oEncrypter.Decrypt(sEmail, "Plzk34YvW0oanZwmb9620xS"))
		
		REM temp array
                        Dim aEncodedName As String = String.Empty
                        aEncodedName = Request.QueryString("n")
                        REM decode the email addresses and add domain

                        For Each name As String In aEncodedName
                            For Each character As String In name
							
                                Select Case character
                                    Case "9"
                                        sDecodedFirst &= "a"
                                    Case "8"
                                        sDecodedFirst &= "b"
                                    Case "7"
                                        sDecodedFirst &= "c"
                                    Case "6"
                                        sDecodedFirst &= "d"
                                    Case "5"
                                        sDecodedFirst &= "e"
                                    Case "4"
                                        sDecodedFirst &= "f"
                                    Case "3"
                                        sDecodedFirst &= "g"
                                    Case "2"
                                        sDecodedFirst &= "h"
                                    Case "1"
                                        sDecodedFirst &= "i"
                                    Case "0"
                                        sDecodedFirst &= "j"
                                    Case "!"
                                        sDecodedFirst &= "k"
                                    Case "`"
                                        sDecodedFirst &= "l"
                                    Case "~"
                                        sDecodedFirst &= "m"
                                    Case "$"
                                        sDecodedFirst &= "n"
                                    Case ":"
                                        sDecodedFirst &= "o"
                                    Case "^"
                                        sDecodedFirst &= "p"
                                    Case "*"
                                        sDecodedFirst &= "q"
                                    Case "("
                                        sDecodedFirst &= "r"
                                    Case ")"
                                        sDecodedFirst &= "s"
                                    Case "["
                                        sDecodedFirst &= "t"
                                    Case "]"
                                        sDecodedFirst &= "u"
                                    Case "|"
                                        sDecodedFirst &= "v"
                                    Case "/"
                                        sDecodedFirst &= "w"
                                    Case "\"
                                        sDecodedFirst &= "x"
                                    Case "-"
                                        sDecodedFirst &= "y"
                                    Case "_"
                                        sDecodedFirst &= "z"
									Case "a"
                                        sDecodedFirst &= "("
									Case "b"
                                        sDecodedFirst &= ")"
									Case "c"
                                        sDecodedFirst &= "."
									Case "d"
                                        sDecodedFirst &= " "
									Case "e"
                                        sDecodedFirst &= "-"
									Case "f"
                                        sDecodedFirst &= "&quot;"
                                End Select
                            Next
							Next
							
						REM temp array
                        Dim aEncodedLast As String = String.Empty
                        aEncodedLast = Request.QueryString("l")
                        REM decode the email addresses and add domain

                        For Each last As String In aEncodedLast
                            For Each character As String In last
							
                                Select Case character
                                    Case "9"
                                        sDecodedLast &= "a"
                                    Case "8"
                                        sDecodedLast &= "b"
                                    Case "7"
                                        sDecodedLast &= "c"
                                    Case "6"
                                        sDecodedLast &= "d"
                                    Case "5"
                                        sDecodedLast &= "e"
                                    Case "4"
                                        sDecodedLast &= "f"
                                    Case "3"
                                        sDecodedLast &= "g"
                                    Case "2"
                                        sDecodedLast &= "h"
                                    Case "1"
                                        sDecodedLast &= "i"
                                    Case "0"
                                        sDecodedLast &= "j"
                                    Case "!"
                                        sDecodedLast &= "k"
                                    Case "`"
                                        sDecodedLast &= "l"
                                    Case "~"
                                        sDecodedLast &= "m"
                                    Case "$"
                                        sDecodedLast &= "n"
                                    Case ":"
                                        sDecodedLast &= "o"
                                    Case "^"
                                        sDecodedLast &= "p"
                                    Case "*"
                                        sDecodedLast &= "q"
                                    Case "("
                                        sDecodedLast &= "r"
                                    Case ")"
                                        sDecodedLast &= "s"
                                    Case "["
                                        sDecodedLast &= "t"
                                    Case "]"
                                        sDecodedLast &= "u"
                                    Case "|"
                                        sDecodedLast &= "v"
                                    Case "/"
                                        sDecodedLast &= "w"
                                    Case "\"
                                        sDecodedLast &= "x"
                                    Case "-"
                                        sDecodedLast &= "y"
                                    Case "_"
                                        sDecodedLast &= "z"
									Case "a"
                                        sDecodedLast &= "("
									Case "b"
                                        sDecodedLast &= ")"
									Case "c"
                                        sDecodedLast &= "."
									Case "d"
                                        sDecodedLast &= " "
									Case "e"
                                        sDecodedLast &= "-"
									Case "f"
                                        sDecodedLast &= "'"
                                End Select
                            Next
							Next
		
		End Sub

</script>

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <title>Cerritos College Send Email Form</title>
	
	<!-- reCAPTCHA version 2 -->
		<script src='https://www.google.com/recaptcha/api.js'></script>
		
		     <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width,user-scalable = yes,initial-scale = 1.0">
      <meta http-equiv="X-UA-Compatible" content="IE=edge">      
      <meta name="copyright" content="Cerritos College">
<link rel="alternate" type="application/rss+xml" title="Cerritos College News RSS 2.0" href="https://www.cerritos.edu/_resources/rss/newsroom.xml" />
	  <meta name="robots" content="all" />
      <link rel="shortcut icon" href="{{f:79589266}}" type="image/x-icon">
      <link rel="icon" href="{{f:79589266}}" type="image/x-icon">
	  
<link rel="stylesheet" href="{{f:79589730}}"/> <!-- /_resources/framework/bootstrap/css/bootstrap.min.css -->

		<!-- Legacy font awesome set -->
    <!--<link rel="stylesheet" href="/_resources/fonts/font-awesome-4.7.0/css/font-awesome.min.css">-->

<!-- Link to font awesome set for TikTok font -->
<!-- 	<script src="https://kit.fontawesome.com/5722ff1f59.js" crossorigin="anonymous"></script> -->

<!-- Link to latest font awesome set 5.6.3 added by Samuel for newer icon sets on the SEM division home page -->
<!--<link rel="stylesheet" href="https://use.fontawesome.com/releases/v5.6.3/css/all.css" integrity="sha384-UHRtZLI+pbxtHCWp1t77Bi1L4ZtiqrqD80Kn4Z8NTSRyMA2Fd33n5dQ8lWUE00s/" crossorigin="anonymous">-->

<link rel="stylesheet" href="{{f:79587132}}"><!-- /_resources/fonts/fontawesome-free-6.4.2-web/css/all.min.css-->

<!-- Load fonts from Google Fonts CDN -- 10/27/2023 - Open Sans and Roboto Condensed -->
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Open+Sans:ital,wght@0,400;0,600;0,700;0,800;1,400;1,600;1,700;1,800&family=Roboto+Condensed:ital,wght@0,400;0,700;1,400;1,700&display=swap" rel="stylesheet" integrity="sha384-aXy2nw69yuCU/EK3wQUs5KpkbNbiB65XesmmtQKdiXF3ZglJMLhVMxOFgu8iZfCF" crossorigin="anonymous">


<!-- Swapped for Google Fonts CDN 10/27/2023 - see above
	/_resources/fonts/Open-Sans/css/fonts.css
	/_resources/fonts/Roboto-Condensed/css/fonts.css
	<link rel="stylesheet" href="/_resources/fonts/Open-Sans/css/fonts.css">
	<link rel="stylesheet" href="/_resources/fonts/Roboto-Condensed/css/fonts.css">
-->

<!--     <link rel="stylesheet" href="/_resources/css/flexslider.min.css" type="text/css"/> -->
	<link rel="stylesheet" href="{{f:79589776}}" type="text/css"><!-- /_resources/css/flexslider.css -->
    <link rel="stylesheet" href="{{f:79589781}}?v=15"/><!-- /_resources/css/main-4.css -->
	<link rel="stylesheet" href="{{f:79589777}}"><!-- /_resources/css/owl.carousel.css-->
<link rel="stylesheet" href="{{f:79589787}}"><!-- /_resources/css/owl.theme.default.min.css -->
	<link rel="stylesheet" href="{{f:79589748}}"/><!-- /_resources/css/cerritos-legacy.css -->
	<link rel="stylesheet" href="{{f:79589753}}"/><!-- /_resources/css/aos_css_reduced_motion.css  -->
	<link rel="stylesheet" href="{{f:79589780}}"/> <!--/_resources/css/components.css  -->
	<link rel="stylesheet" href="{{f:79589769}}"/> <!--/_resources/css/modern-campus-forms.css  -->
	
	<!-- IE Conditionals from current Cerritos.edu site -->
	<!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
      <script src="{{f:79589735}}" type="text/javascript">
          //comment
        </script>
      <!-- HTML5 shim and Respond.js IE8 support of HTML5 elements and media queries -->
      <!-- [if lt IE 9]>
	  <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
	  <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
	  <![endif] -->
 	<!--[if lt IE 8]>
	<link href="/_resources/css/css2_tables_min.css" rel="stylesheet" type="text/css" media="all" />
        <![endif]-->
	<!-- End Conditionals -->
	
    <script src="{{f:79589859}}"></script>
    <script src="{{f:79589733}}"></script>
    <script src="{{f:79589855}}"></script>
	<script src="{{f:79589860}}"></script>
	<script src="{{f:79589835}}"></script>

	
<script type="text/javascript" src="//platform-api.sharethis.com/js/sharethis.js#property=58dc7d749801000011c55022&product=inline-share-buttons"></script>

</head>
<body class="department inside">

<header role="banner">

<nav id="accessibility" class="accessibility" aria-label="accessibility">
     <a href="#skiptocontent">Skip to main content</a>
</nav>
<div id="headerDiv"><nav class="navbar navbar-default">
<div class="top-bar">
<div class="container">
<ul id="nav-audience" class="nav navbar-nav audience">
<li><a href="/get-started/default.htm">Future Students</a></li>
<li><a href="{{f:79585787}}">Current Students</a></li>
<li><a href="{{f:79706343}}">Faculty &amp; Staff</a></li>
<li><a href="{{f:79709309}}">Community</a></li>
</ul>
<ul id="quick-links" class="nav navbar-nav navbar-right quick-nav">
<li class="a-z-index"><a href="{{f:79573108}}">A-Z Index</a></li>
<li class="dropdown quick-links"><a class="dropdown-toggle" role="button" href="#" aria-expanded="false" aria-haspopup="true" data-toggle="dropdown">Quick Links </a>
<ul class="dropdown-menu">
<li><a class="external" href="https://www.cerritos.edu/mycerritos/" target="_blank">MyCerritos</a></li>
<li><a class="external" href="https://www.cerritos.edu/canvas/" target="_blank">Canvas</a></li>
<li><a href="https://go.boarddocs.com/ca/cerritos/Board.nsf/Public" target="_blank">BoardDocs</a></li>
<li><a href="{{f:79573710}}">Academic Calendar</a></li>
<li><a class="external" href="https://cerritos-public.courseleaf.com/" target="_blank" rel="noopener">Catalog</a></li>
<li><a class="external" href="https://www.cerritos.edu/schedule/" target="_blank" rel="noopener">Schedule</a></li>


<li><a class="external" href="https://www.bkstr.com/cerritosstore/home/en" target="_blank">Bookstore</a></li>
<li><a class="external" href="/library/" target="_blank">Library &amp; Chat</a></li>
<li class="divider" role="separator"></li>

<li><a href="{{d:9094300}}"><span class="fa fa-phone" aria-hidden="true"><span class="sr-only">Directory</span></span> Faculty &amp; Staff Directory</a></li>
<li><a href="{{f:79573109}}"><span class="fa fa-sitemap" aria-hidden="true"><span class="sr-only">Sitemap</span></span> Programs and Services Directory</a></li>
<li><a href="https://cerritos.onbio-key.com/"><span class="fas fa-sign-in-alt" aria-hidden="true"><span class="sr-only">Cerritos Portal</span></span> Cerritos Portal</a></li>
<li><a href="{{d:9085619}}"><span class="fa fa-calendar" aria-hidden="true"><span class="sr-only">Calendar</span></span> Calendar</a></li>
<li><a href="{{d:9083962}}"><span class="fa fa-map" aria-hidden="true"><span class="sr-only">Map</span></span> Campus Map</a></li>
<li><a href="/parking/"><span class="fas fa-parking" aria-hidden="true"><span class="sr-only">Parking</span></span> Parking</a></li>
<li><a href="{{d:9084173}}"><span class="fas fa-taxi" aria-hidden="true"><span class="sr-only">Safety</span></span> Campus Safety</a></li>
</ul>
</li>
<li id="button-apply"><a class="apply-now" href="https://www.cerritos.edu/apply" target="_blank">Apply Now</a></li>
<li id="button-give"><a href="http://cerritoscf.org/" target="_blank" class="give"><!--<span class="fa fa-gift" aria-hidden="true"><span class="sr-only">Give</span></span>-->Give</a></li>
<li id="button-map"><a class="campus-map" href="{{f:79573107}}">Campus Maps</a></li>
</ul>
</div>
</div>
<div class="container">
<div class="navbar-header">
<h1>Cerritos College<a class="navbar-brand logo" href="{{d:9078688}}"><img title="Cerritos College, Norwalk California" src="{{f:79589637}}" alt="Cerritos College, Norwalk California" /></a></h1>
<ul class="mobile mobile-quicklinks">
<li><a href="{{f:79573108}}"> <span class="big">A-Z</span> <span class="small">Index</span> </a></li>
					
<li><a title="Directory" href="{{d:9094300}}"><span class="fa fa-phone" aria-hidden="true"><span class="sr-only">Directory</span></span></a></li>


<li><a title="Calendar" href="{{f:79584134}}"><span class="fa fa-calendar" aria-hidden="true"><span class="sr-only">Calendar</span></span></a></li>

<li class="dropdown search"><a class="dropdown-toggle" role="button" href="#" aria-expanded="false" aria-haspopup="true" data-toggle="dropdown"><span class="fa fa-search" aria-hidden="true"></span><span class="sr-only">Search</span></a>



<ul class="dropdown-menu">

<li><!--<form id="searchForm" method="get" action="/campus-guide/search.htm" class="navbar-form navbar-left">
                                <div class="form-group">
                                    <input class="form-control" placeholder="Search" name="q" id="q" aria-lable="search" type="text">
                                </div>
                            </form>--> <!--Mobile Search--> <!--
							<script>


  (function() {

    var cx = '008525147052714186440:tkcmuqghz4s';
    var gcse = document.createElement('script');
    gcse.type = 'text/javascript';
    gcse.async = true;
    gcse.src = 'https://cse.google.com/cse.js?cx=' + cx;
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(gcse, s);
  })();
							

</script>
<gcse:searchbox-only resultsUrl="/campus-guide/search.htm"></gcse:searchbox-only>
-->
<div class="w-form form-wrapper"><form id="searchbox-mobile" action="{{f:79573736}}" method="get" name="cse"><input type="hidden" value="your-008525147052714186440:tkcmuqghz4s" name="cx" /> <input type="hidden" value="utf-8" name="ie" /> <input type="hidden" value="en" name="hl" /> <label for="q-mobile">Search:&nbsp;</label><input id="q-mobile" type="text" name="q" /> <input type="submit" value="Go" name="sa" /></form></div>
</li>
</ul>
</li>
<li><a href="https://www-cerritos-edu.translate.goog/?_x_tr_sl=auto&_x_tr_tl=en&_x_tr_hl=en&_x_tr_pto=wapp"><span class="fa-solid fa-language"><span class="sr-only">Translate</span></span></a></li>	
</ul>

<ul class="mobile mobile-quicklinks dropdown">
<li class="dropdown quick-links"><a class="dropdown-toggle" role="button" href="#" aria-expanded="false" aria-haspopup="true" data-toggle="dropdown">Quick Links </a>
<ul class="dropdown-menu">
<li><a class="external" href="https://www.cerritos.edu/mycerritos" target="_blank">MyCerritos</a></li>
<li><a class="external" href="https://www.cerritos.edu/canvas/" target="_blank">Canvas</a></li>
<li><a href="https://go.boarddocs.com/ca/cerritos/Board.nsf/Public" target="_blank">BoardDocs</a></li>
<li><a href="{{f:79573710}}">Academic Calendar</a></li>
<li><a class="external" href="https://cerritos-public.courseleaf.com/" target="_blank" rel="noopener">Catalog</a></li>
<li><a class="external" href="https://www.cerritos.edu/schedule/" target="_blank" rel="noopener">Schedule</a></li>
<li><a class="external" href="https://www.bkstr.com/cerritosstore/home/en" target="_blank">Bookstore</a></li>
<li><a class="external" href="/library/" target="_blank">Library &amp; Chat</a></li>
<li class="divider" role="separator"></li>
<li><a href="{{d:9094300}}"><span class="fa fa-phone" aria-hidden="true"><span class="sr-only">Directory</span></span> Faculty &amp; Staff Directory</a></li>
<li><a href="{{f:79573109}}"><span class="fa fa-sitemap" aria-hidden="true"><span class="sr-only">Sitemap</span></span> Programs and Services Directory</a></li>
<li><a href="https://cerritos.onbio-key.com/"><span class="fas fa-sign-in-alt" aria-hidden="true"><span class="sr-only">Cerritos Portal</span></span> Cerritos Portal</a></li>
<li><a href="{{d:9085619}}"><span class="fa fa-calendar" aria-hidden="true"><span class="sr-only">Calendar</span></span> Calendar</a></li>
<li><a href="{{d:9083962}}"><span class="fa fa-map" aria-hidden="true"><span class="sr-only">Map</span></span> Campus Map</a></li>
<li><a href="/parking/"><span class="fas fa-parking" aria-hidden="true"><span class="sr-only">Parking</span></span> Parking</a></li>
<li><a href="{{d:9084173}}"><span class="fas fa-taxi" aria-hidden="true"><span class="sr-only">Safety</span></span> Campus Safety</a></li>
</ul>
</li>
</ul>
<a class="navbar-toggle" role="button" href="#siteNavigation" data-target="#siteNavigation">
<div class="bars">&nbsp;</div>
<div class="text">Menu</div>
</a></div>
<div id="siteNavigation" class="siteNavigation"><a class="menuClose visible-md visible-sm visible-xs" href="#"><span class="sr-only">Close</span></a>
<ul class="nav navbar-nav main-nav">
<li id="button-apply-2" class="hidden-lg"><a class="apply-now" href="https://www.cerritos.edu/apply" target="_blank">Apply Now</a></li>
<li class="hidden-lg"><a class="apply-now" href="http://cerritoscf.org/" target="_blank">Make a Gift</a></li>
<li><a href="{{f:79722412}}">About</a></li>
<li><a href="{{f:79708725}}">Admissions</a></li>
<li><a href="{{f:79503072}}">Financial Aid</a></li>
<li><a href="{{f:79583424}}">Academics</a></li>
<li><a href="{{f:79572843}}">Services &amp; Support </a></li>
<!--<li><a href="/caring-campus/default.htm"><span class="fa fa-heart" aria-hidden="true"></span> We Care</a></li>-->
<!--<li><a href="/student-life/student-life.htm">Student Life</a></li>
<li><a href="/services/default.htm">Services &amp; Support </a></li>-->
<li class="hidden-lg audience-mobile"><a href="/get-started/default.htm">Future Students</a></li>
<li class="hidden-lg audience-mobile"><a href="{{f:79585787}}">Current Students</a></li>
<li class="hidden-lg audience-mobile"><a href="{{f:79706343}}">Faculty &amp; Staff</a></li>
<li class="hidden-lg audience-mobile"><a href="{{f:79709309}}">Community</a></li>
<li class="dropdown search"><a class="dropdown-toggle" role="button" href="#" aria-expanded="false" aria-haspopup="true" data-toggle="dropdown"> <span class="fa fa-search" aria-hidden="true"><span class="sr-only">Search</span></span></a>
<ul class="dropdown-menu">
<li><!--<form id="searchForm-2" method="get" action="/campus-guide/search.htm" class="navbar-form navbar-left">
                                <div class="form-group">
                                    <input name="q-2" id="q-2" class="form-control" placeholder="Search" aria-lable="search" type="text">
                                </div>
                            </form>
--> <!--
							<script>
  function() {
    var cx = '008525147052714186440:tkcmuqghz4s';
    var gcse = document.createElement('script');
    gcse.type = 'text/javascript';
    gcse.async = true;
    gcse.src = 'https://cse.google.com/cse.js?cx=' + cx;
    var s = document.getElementsByTagName('script')[0];
    s.parentNode.insertBefore(gcse, s);
  }();
</script>
<gcse:searchbox-only resultsUrl="/campus-guide/search.htm"></gcse:searchbox-only>
-->
<div class="w-form form-wrapper"><form id="searchbox-desktop" action="{{f:79573736}}" method="get" name="cse"><input type="hidden" value="your-008525147052714186440:tkcmuqghz4s" name="cx" /> <input type="hidden" value="utf-8" name="ie" /> <input type="hidden" value="en" name="hl" /> <label for="q-desktop">Search Site:&nbsp;</label><input id="q-desktop" type="text" name="q" /> <input type="submit" value="Go" name="sa" /></form></div>
</li>
</ul>
</li>

<li>
<div id="google_translate_element"></div>
<script type="text/javascript">// <![CDATA[
function googleTranslateElementInit() {
                    new google.translate.TranslateElement({pageLanguage: 'en', layout: google.translate.TranslateElement.InlineLayout.VERTICAL, autoDisplay: false}, 'google_translate_element');
	
var $googleDiv = $("#google_translate_element .skiptranslate");
var $googleDivChild = $("#google_translate_element .skiptranslate div");
$googleDivChild.next().remove();

$googleDiv.contents().filter(function(){
return this.nodeType === 3 && $.trim(this.nodeValue) !== '';
}).remove();
	
	
                }
// ]]></script>
<noscript>Your browser does not support JavaScript!</noscript>
<script type="text/javascript" src="https://translate.google.com/translate_a/element.js?cb=googleTranslateElementInit"></script>
<noscript>Your browser does not support JavaScript!</noscript>
</li>


</ul>
</div>
</div>
</nav></div>

</header>

<div class="body-wrap">
                    <div class="clearfix">
                        
                        <!-- left nav -->
                       <div id="sidebar" class="col-sm-4 col-md-3">
                            <div id="skiptonavigation">
                                <div id="menuLeft" class="nopanel">
								<nav id="navigation-collaspe" class="navbar-collapse left-nav-collapse collapse" aria-label="navigation-collaspe">
								<div class="tabH4_Main">General Information</div>
<ul id="Accordion" class="pageletLinks">
<li><a href="{{f:79573107}}">Campus Guide Home</a></li>
<li><a href="{{f:79725502}}">Directions to Campus</a></li>
<li><a class="external" href="http://www.lbtransit.com/Services/" target="_blank">Public Transportation</a></li>
<li><a href="{{d:9085715}}">Employment</a></li>
<li><a href="https://www.cerritos.edu/facts">Facts at a Glance</a></li>
<li><a href="{{d:9094987}}">President's Office</a></li>
<li><a href="{{f:79573737}}">Mission Statement</a></li>
<li><a href="{{f:79722446}}">Accredited Status</a></li>
<li><span><a href="#">Calendars</a></span>
<ul>
<li><a href="{{f:79573710}}">Academic Calendar</a></li>
<li><a href="{{f:79584134}}">Campus Calendar</a></li>
<li><a href="{{f:79717098}}">Daily Falcon</a></li>
<li><a class="external" href="http://www.cerritosfalcons.com/" target="_blank">Athletics Calendar</a></li>
</ul>
</li>
<li><span><a href="#">Directories</a></span>
<ul>
<li><a href="{{f:79573106}}">California Community Colleges</a></li>
</ul>
</li>
<li><span><a href="#">For Students</a></span>
<ul>
<li><a class="external" href="https://portal.cerritos.edu/" target="_blank">MyCerritos</a></li>
<li><a class="external" href="https://www.cerritos.edu/bookstore" target="_blank">Cerritos College Bookstore</a></li>
<li><a class="external" href="https://www.cerritos.edu/talon-marks" target="_blank">Talon Marks Newspaper</a></li>
<li><a href="{{d:9092929}}">Online Classes</a></li>
<li><a href="{{d:9093788}}">Student Activities</a></li>
<li><a href="{{f:79585787}}">More student links...</a></li>
</ul>
</li>
<li><a href="{{f:79573719}}">Photo Galleries</a></li>
</ul>
</nav>
</div>
</div>
                            </div>
                            <div>
							
							<!-- main content -->
                        <div id="maincontent" class="col-sm-8 col-md-9" role="main">
                            <div id="skiptocontent"></div>
                            
                            <!-- breadcrumbs -->
                            
                            
                            <!-- inside page with one edit region -->
                            <div id="contentcontainer">
                                <!-- heading -->
                                <h2>Email  <%=sDecodedFirst%> <%=sDecodedLast%></h2>
                                
                              </div>
                            
						
						
						
						
						
				
				<!--<div style="margin:0 10%;">-->
        
        <form id="ContactForm" action="{{f:79558013}}" method="post" name="ContactForm">
<p><!-- EMAIL RECIPIENTS==YOU MUST CHANGE THESE -->
    <input name="_recipients" type="hidden" value="<%=sEmails%>" /> 
    <!-- REQUIRED FIELDS -->
    <input name="_requiredFields" type="hidden" value="Subject,Name,Email,Request" /> 
    <!-- reply to address taken from a form field (choose _replyToField or _replyTo) -->
    <input name="_replyToField" type="hidden" value="Email" /> 
    <!-- EMAIL SUBJECT -->
    <input name="_subject" type="hidden" value="Employee Directory Contact" /> 
    <!-- ADD THE DATE AND TIME (OPTIONAL==CHOOSE ONLY ONE, true or false) -->
    <input name="_DateAndTime" type="hidden" value="true" /> 
    <input name="_envars" type="hidden" value="HTTP_REFERER" />  
    <!-- CONFIRMATION REDIRECT --> 
    <input name="_redirect" type="hidden" value="/campus-guide/confirmation.htm" /></p>
	
	<p><span class="hp1a1l1o1n0d9r0a6b5l0" style="display:none;margin-left:-1000px;">
		<label for="_hp1a1l1o1n0d9r0a6b5l0-f" class="hp1a1l1o1n0d9r0a6b5l0" aria-hidden="true">If you see this don't fill out this input box.</label>
		<input id="_hp1a1l1o1n0d9r0a6b5l0-f" name="_hp1a1l1o1n0d9r0a6b5l0-f" type="text" />
	</span></p>
	
<p><label for="Subject"><strong>* Subject:</strong></label><br /><input id="Subject" name="Subject" type="text" /></p>
<p><label for="Name"><strong>* Name:</strong></label><br /><input id="Name" name="Name" type="text" /></p>
<p><label for="Email"><strong>* Email:</strong></label><br /><input id="Email" name="Email" type="text" /></p>
<p><label for="Phone"><strong>Phone:</strong></label><br /><input id="Phone" name="Phone" type="text" /></p>
<p><label for="Request"><strong>* Request:</strong></label><br /><textarea id="Request" cols="40" rows="4" name="Request"></textarea></p>

<div class="g-recaptcha" data-sitekey="6LcxUk4UAAAAAMyg221MHklN6E_axt_jNmxZ69fI"></div>

<br /> 
            <input id="Submit" type="submit" value="Submit" /> <label for="Reset" style="border: 0;clip: rect(0 0 0 0);height: 1px;margin: -1px;overflow: hidden;padding: 0;position: absolute;width: 1px;">Reset</label><input id="Reset" type="reset" value="Reset" /> *Required Fields</form>
           <p><asp:Label ID="errorlbl" runat="server"  ForeColor="Brown" ></asp:Label></p>        
        
    <!--</div>-->


    </div></div></div></div>
	
	
	<div role="contentinfo">
	
	
	<div id="social-wrap">
<div id="social" class="clearfix">
<div class="col-md-6">
<h3>Stay Connected</h3>
</div>
<div class="col-md-6">
<div class="social-buttons">
<section class="mobile-row"><a class="social inverse" href="https://www.facebook.com/cerritoscollege/" target="_blank"><span class="fa fa-facebook"><span class="sr-only">Facebook</span></span></a> <a class="social inverse" href="https://www.instagram.com/cerritoscollege/" target="_blank"><span class="fa fa-instagram"><span class="sr-only">Instagram</span></span></a> <a class="social inverse" href="https://twitter.com/cerritoscollege" target="_blank"><span class="fa fa-twitter"><span class="sr-only">Twitter</span></span></a> <a class="social inverse" href="https://www.youtube.com/channel/UCmQYFzgOkYGPAAfHuNe7mOg" target="_blank"><span class="fa fa-youtube-play"><span class="sr-only">YouTube</span></span></a></section>
</div>
<!--<div class="click-throughs">
            <a class="button inverse" href="http://social.pomona.edu" rel="external" target="_blank">Visit Our Social Media Hub</a>
			        </div>--></div>
</div>
</div>
<div id="footer-wrap">
<div id="footer" class="clearfix">
<div class="col-xs-5 col-sm-4 col-md-5 info">
<div class="col-md-5"><a title="Cerritos College" href="{{d:9078688}}"><img class="footer-logo" src="{{f:79589606}}" alt="Cerritos College" /></a></div>
<div class="col-md-7">
<p>11110 Alondra Blvd.<br /> Norwalk, California 90650<br /> [<a href="/map">Campus map</a>]</p>
<p>Phone: <a href="tel:+15628602451">(562) 860-2451</a><br /> Emergency: <a href="tel:+15624023674">(562) 402-3674</a><br /><br /> <a href="{{d:9084173}}">Campus Police </a></p>
</div>
</div>
<div class="col-xs-7 col-sm-8 col-md-7">
<div class="col-sm-6 col-md-8">
<h4>Resources</h4>
<div class="col-md-6"><a href="{{d:9093422}}">Catalog &amp; Schedule</a> <a class="inverse" href="https://ep-secure.cerritos.edu/psp/por91prd/EMPLOYEE/EMPL/h/?tab=PAPP_GUEST" target="_blank" rel="external">MyCerritos</a> <a class="inverse" href="https://cerritos.instructure.com/login/canvas" target="_blank" rel="external">Canvas</a> <a class="inverse" href="https://cerritos.campuslabs.com/engage/" target="_blank">FalconSync</a> <a href="{{d:9097021}}">Disabled Students </a></div>
<div class="col-md-6"><a href="{{f:79573108}}">A-Z Index</a> <a href="{{d:9085693}}">News</a> <a href="{{f:79584134}}">Events</a> <a href="{{d:9094300}}">Directory</a> <a href="http://cerritoscf.org/" target="_blank">Give to Cerritos College</a></div>
</div>
<div class="col-sm-6 col-md-4">
<h4>Get Started</h4>
<a href="https://www.cerritos.edu/apply" target="_blank">Apply Now!</a> <!--<a href="/school-relations/programs-and-services/campus-tours.htm">Visit Campus</a> <a href="*** Broken Link ***">Request Info</a>--> <br /> 
<a class="button" href="https://go.boarddocs.com/ca/cerritos/Board.nsf/Public">Board Agenda</a></div>
</div>
</div>
</div>
<button class="back-to-top" title="Back to Top"><img title="Back to Top" src="{{f:79589608}}" alt="Back to Top" /></button>
	</div>
	
	
	                            


</body>
</html>