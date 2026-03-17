<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xsl xs ou ouc">
	
	<xsl:import href="functions-workshop.xsl" />
	<xsl:import href="ou-variables.xsl" />
	<xsl:import href="template-matches.xsl" />
	<xsl:import href="ou-forms.xsl" />
	<xsl:import href="accessibility-all.xsl" />

	<xsl:param name="ou:navigation" />

	<!-- removes unnecessary whitespace between elements. 	-->
	<xsl:strip-space elements="*" />
	
<xsl:output method="html" version="5.0" indent="yes" encoding="UTF-8" include-content-type="no" /> 

<xsl:template match="/">

	<xsl:variable name="Author" select="document/ouc:properties[@label='metadata']/meta[@name='author']/@content" />
	<xsl:variable name="Keywords" select="document/ouc:properties[@label='metadata']/meta[@name='keywords']/@content"/>
	<xsl:variable name="Description" select="document/ouc:properties[@label='metadata']/meta[@name='description']/@content"/>
	<xsl:variable name="Title" select="document/ouc:properties[@label='metadata']/title" />

	<html lang="en-us">
	<head>
		<!-- head include -->
		<xsl:copy-of select="ou:includeFile('/_resources/includes/head-2.inc')"/>
		
     	<!-- title -->
     	<title><xsl:value-of select="$Title" disable-output-escaping="yes" /></title>
		<meta name="author" content="{$Author}" />
        <meta name="keywords" content="{$Keywords}" />
        <meta name="description" content="{$Description}" />
		<meta name="copyright" content="Cerritos College"/>
		
		<!-- our google verification key for the home page -->
        <meta name="google-translate-customization" content="9e67fa94bbcd2e23-6eae4ca1dd0fd70d-g7bab8e9cfe5f24b7-10" />

	<!-- only used for home page -->
	<link rel="stylesheet" href="{{f:80151057}}"/>
	
	<!-- IE Conditionals from current Cerritos.edu site -->
	<!-- IE10 viewport hack for Surface/desktop Windows 8 bug -->
      <script src="{{f:80151045}}" type="text/javascript">
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

	<!-- Cerritos main google tracking code -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/google-analytics.inc')"/>
		
		<!-- Department google tracking code -->
		
</head>
	 
<body class="department inside">
	
<div class="body-wrap">
	<!-- header -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/header.inc')"/>
	
<div class="clearfix">
        <div id="sidebar" class="col-md-3">
			<div id="skiptonavigation"><xsl:copy-of select="ou:includeFile('/_resources/includes/deptnav.inc')"/></div>
			<div id="skiptocontent"><xsl:copy-of select="ou:includeFile('/_resources/includes/deptinfo.inc')"/></div>
        </div>
        <div id="maincontent" class="col-md-9">
			<div id="BreadcrumbList"> 
               <ol class="breadcrumbs" vocab="http://schema.org/" typeof="BreadcrumbList">
				   <li property="itemListElement" typeof="ListItem"><a href="{{d:9116620}}"><span property="name"><i class="fa fa-home"></i></span></a><meta property="position" content="1"/></li>
				   <li property="itemListElement" typeof="ListItem"><a href="{{d:9116620}}"><span property="name">Student Services</span></a><meta property="position" content="2"/></li>
				   <li property="itemListElement" typeof="ListItem"><a href="{{d:9116620}}"><span property="name">Counseling</span></a><meta property="position" content="3"/></li>
			   </ol>
           </div>
         <div id="contentcontainer">
                <h2>Welcome to Counseling</h2>
                <img src="http://placehold.it/1000x100" alt="Featured Image" class="featured-image" title="Featured Image"/>
                <h4>The Counseling Department is dedicated to assisting students in developing transitional skills to
                    help
                    them achieve success in their academic, career, and life goals in an inclusive environment that
                    embraces
                    the diversity of our students and community.</h4>
                <h3>Hours of Operation</h3>
                <p>The Counseling department's hours of operation are Monday through Thursday 8:00am to 7:00pm and
                    Friday
                    8:00am to 2:00pm.</p>
                <p>Counseling appointments can be made by telephone on Friday's at 8:00am by calling (562) 860-2451 Ext.
                    2231
                    or in person at the Counseling Front Desk located in the Administration Building. Appointments may
                    be
                    limited during peak registration. In order to schedule a counseling appointment you must be either a
                    continuing, transfer or re-admit student.</p>
                <p>Saturday appointments are available to student on the following dates:</p>
                <ul>
                    <li>September 10th</li>
                    <li>October 8th</li>
                    <li>December 10th</li>
                </ul>
                <p>Students interested in these appointments must call the day before (Friday) in order to book them.
                    First
                    appointment at 9am. Last appointment at 1:30pm.</p>
                <p>Stand By <a href="#">Counseling Hours</a>: Sign ups are taken ten (10) minutes prior to start time</p>
                <p>**The number of students at each session is subject to counselor availability on a day-by-day
                    basis.**</p>
                <p>During peak registration times, we strongly encourage students to arrive earlier than designated
                    sign-in
                    time.</p>
                <table class="table-schedule">
                    <tr>
                        <td>Monday</td>
                        <td>Beginning at 9:00am</td>
                    </tr>
                    <tr>
                        <td>Tuesday</td>
                        <td>Beginning at 9:00am</td>
                    </tr>
                    <tr>
                        <td>Wednesday</td>
                        <td>9:00am &amp; 4:00pm</td>
                    </tr>
                    <tr>
                        <td>Thursday</td>
                        <td>Beginning at 9:00am</td>
                    </tr>
                </table>
                <p>Stand By Counseling is for students who have quick questions regarding the current semester.
                    Questions
                    involving transcripts, financial aid educational plans, educational planning for upcoming semesters,
                    etc. will be directed to schedule a 30 minute counseling appointment.</p>
                <p>Although the counseling services are on a voluntary basis, all entering freshman, students
                    transferring
                    in from other schools, F-1 VISA students, and students on financial aid are required to meet with a
                    counselor for program planning and approval before registration.</p>
            </div>
            <div id="contentvideo">
                <a class="button">Play Video</a>
                <a class="button">Get Transcript</a>
                <img src="http://placehold.it/852x525" alt="Story Image" title="Story Image"/>
            </div>
        </div>
    </div>
</div>
<!-- footer -->
	<xsl:copy-of select="ou:includeFile('/_resources/includes/footer.inc')"/>
</body>
		</html>	 
	</xsl:template>	

</xsl:stylesheet>



