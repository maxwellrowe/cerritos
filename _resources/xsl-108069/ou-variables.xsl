<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xsl xs ou">

	<!-- OU Variables: System defined variables. -->
	
	<!-- Page specific OU Variables -->
	<xsl:param name="ou:action"/>	<!-- Returns the action state of the page. Values are either pub,prv,edt, or cmp for Publish, Preview, Edit Mode, or Compare respectively. -->
	<xsl:param name="ou:root"/>		<!-- Returns the path from the root of staging to the account. Example of usage includes building a path to open a file on the staging server using either doc() or document() functions. -->
	<xsl:param name="ou:site"/>		<!-- Returns the site name defined during site set up. This corresponds to the value seen in the site drop down at the upper right corner of OU Campus. -->
	<xsl:param name="ou:path"/>		<!-- Returns the production path of the file, including file name and extension. Example: /path/to/filename.html -->
	<xsl:param name="ou:dirname"/>	<!-- Returns the root relative path of the directory. Does not include a trailing / -->
	<xsl:param name="ou:filename"/>	<!-- Returns the production file name, including the extension defined in the PCF-stylesheet in the pcf. Example filename.html -->
	<xsl:param name="ou:created" as="xs:dateTime"/>		<!-- Returns a dateTime of when the page was created. -->
	<xsl:param name="ou:modified" as="xs:dateTime"/>	<!-- Returns a dateTime of when the page was last modified (saved). -->
	<xsl:param name="ou:feed"/>		<!-- Returns the Feed option in a page's access settings. -->
	
	<!-- Site specific OU Variables -->
	<xsl:param name="ou:httproot"/>	<!-- Returns the httproot value defined in the site settings for the current site. Example: /public_html -->
	<xsl:param name="ou:ftproot"/>	<!-- Returns the ftproot value defined in the site settings for the current site. -->
	<xsl:param name="ou:ftphome"/>	<!-- Returns the ftphome value defined in the site settings for the current site. -->
	<xsl:param name="ou:ftpdir"/>	<!-- Returns the ftpdir value defined in the site settings for the current site. -->
	
	<!-- User specific OU Variables -->
	<xsl:param name="ou:username"/>	<!-- Returns the username of the user acount accessing the page in OU Campus. -->
	<xsl:param name="ou:lastname"/>	<!-- Returns the last name of the user account (if any provided) accessing the page in OU Campus. -->
	<xsl:param name="ou:firstname"/><!-- Returns the first name of the user account (if any provided) accessing the page in OU Campus. -->
	<xsl:param name="ou:email"/>	<!-- Returns the email of the user account (if any provided) accessing the page in OU Campus. -->
	
	
	<!-- Implementation Specific Variables -->
	<xsl:param name="ou:personalization" />
	<xsl:param name="layout-class" />	<!-- Parameter that is used to inject a class for dynamic 3rd level tagging.  All parameters must be defined if used in a template. Therefore this is defined here with no default value. -->
		
	<!-- The following are commonly used string concatenations using OU Variables -->
	<xsl:param name="dirname" select="if(string-length($ou:dirname) = 1) then $ou:dirname else concat($ou:dirname,'/')" />	<!-- Returns a root relative path to the current directory. Includes a trailing slash. -->
	<xsl:param name="firstdir" select="concat('/',tokenize($dirname,'/')[2])" /> <!-- Returns the first directory from the current directory path. -->
	<xsl:param name="seconddir" select="concat('/',tokenize($dirname,'/')[3])" /> <!-- Returns the second directory from the current directory path. -->
	<xsl:param name="domain" select="substring($ou:httproot,1,string-length($ou:httproot)-1)" />	<!-- Retuns the httproot without the trailing slash. This makes it easier to work with other path variables. -->
	<xsl:param name="root" select="concat($ou:root,$ou:site)"/>	<!-- Returns the full path from the root of the server to the site. -->
		
	
</xsl:stylesheet>
