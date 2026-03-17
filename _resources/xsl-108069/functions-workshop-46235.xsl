<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY amp   "&#38;">
<!ENTITY copy   "&#169;">
<!ENTITY gt   "&#62;">
<!ENTITY hellip "&#8230;">
<!ENTITY laquo  "&#171;">
<!ENTITY lsaquo   "&#8249;">
<!ENTITY lsquo   "&#8216;">
<!ENTITY lt   "&#60;">
<!ENTITY nbsp   "&#160;">
<!ENTITY quot   "&#34;">
<!ENTITY raquo  "&#187;">
<!ENTITY rsaquo   "&#8250;">
<!ENTITY rsquo   "&#8217;">
]>
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xsl xs ou ouc">
	
	<!--	INCLUDE FILE.
			To handle include files in OU Campus, use one of the following three functions.
			These functions allow the different use cases of displaying an include file in OU Campus.
			Each prepare the passed parameters in order to use ou:include.
	-->
	<xsl:function name="ou:includeFile"><!-- one parameter: full path to file -->
		<xsl:param name="fullpath" />
		<xsl:copy-of select="ou:include($fullpath,$fullpath)" />
	</xsl:function>
	
	<xsl:function name="ou:includeFile"><!-- two parameters: directory path to file, and file name -->
		<xsl:param name="dirname" />
		<xsl:param name="filename" />
		<xsl:variable name="fullpath" select="concat($dirname,if(substring($dirname,string-length($dirname)) != '/') then '/' else '',$filename)" />	<!-- combines the two, ensuring the syntax contains the proper path syntax -->
		<xsl:copy-of select="ou:include($fullpath,$fullpath)" />
	</xsl:function>
	
	<xsl:function name="ou:includeFile"><!-- three parameters: directory path to file, file name, and unique label; used in case of need to include the same file more than once -->
		<xsl:param name="dirname" />
		<xsl:param name="filename" />
		<xsl:param name="label" />
		<xsl:variable name="fullpath" select="concat($dirname,if(substring($dirname,string-length($dirname)) != '/') then '/' else '',$filename)" />	<!-- combines the two, ensuring the syntax contains the proper path syntax -->
		<xsl:copy-of select="ou:include($fullpath,$label)" />
	</xsl:function>
	
	<!--	INCLUDE.
			Takes two parameters: a root relative path to a file and a unique label.
			These function will check the action state.
			If OU Campus is publishing the file, the function will use ou:ssi to output the proper processing instruction.
			If OU Campus is not publishing the file, the function will use the editable region tags with the path attribute to simulate an include of the file.  This will reflect the file on the staging server.
	-->	
	<xsl:function name="ou:include">
		<xsl:param name="fullpath" />
		<xsl:param name="label" />
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:copy-of select="ou:ssi($fullpath)" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment> ouc:div button-text="<xsl:value-of select="$label[3]" />" group="<xsl:value-of select="$label[2]" />" label="<xsl:value-of select="$label[1]" />" path="<xsl:value-of select="$fullpath" />" </xsl:comment>
				<xsl:comment> /ouc:div </xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
			
	<!--	SSI (Server Side Include)
			Takes one parameter: a root relative path to a file.
			Outputs the basic (PHP) server side include for a file.
			Note that this will no be able to show up on the staging server due to it being a server side process. Use includeFile to display an include on the Staging Server as well.
	-->
	<xsl:function name="ou:ssi">
		<xsl:param name="fullpath"/>
		<!--<xsl:processing-instruction name="php"> include($_SERVER['DOCUMENT_ROOT'] . "<xsl:value-of select="$fullpath" />"); ?</xsl:processing-instruction>-->
		<!-- asp.net include directive -->
		<xsl:comment> #include virtual="<xsl:value-of select="$fullpath" />" </xsl:comment>
	</xsl:function>

	<!-- 	FIND PREVIOUS DIRECTORY.
			Takes one parameter: a directory path.
			Returns the parent directory of path given, with a trailing '/'. If the path is the root, will return '/'.
			Used by breadcrumbs.xsl.
	-->
	<xsl:function name="ou:findPrevDir">
		<xsl:param name="path" />
		<xsl:variable name="tokenPath" select="tokenize(substring($path, 2), '/')[if(substring($path,string-length($path)) = '/') then position() != last() else position()]" />
		<xsl:variable name="newPath" select="concat('/', string-join(remove($tokenPath, count($tokenPath)), '/') ,'/')"/>
		<xsl:value-of select="if($newPath = '//') then '/' else $newPath" />
	</xsl:function>
	
	<!--	GET DIRECTORY TITLE.
			Takes two parameters: a root relative path and a file name (must be XML).
			Uses the document function to try and open the file, and grab the title from the XML document.
			If it fails, it will return the name of the folder.
			Used by breadcrumbs.xsl
	-->
	<xsl:function name="ou:getDirectoryTitle">
		<xsl:param name="path" />
		<xsl:param name="file" />
		<xsl:variable name="title">
			<xsl:try select="document(concat('file:',$root, $path, $file))/document/ouc:properties/title" >
				<xsl:catch />
			</xsl:try>
		</xsl:variable>
		<xsl:value-of select="if(string-length($title) > 0) then $title else tokenize($path,'/')[last() - 1]" />
	</xsl:function>
	
	<!--	MULTIEDIT BUTTON.
			Manually create multiedit button so that users can access multiedit.
			A multiedit node needs to be output during edit mode for the multiedit button to show up.
			Most of the time, data is output via an xsl:value-of, which would not output the multiedit node.
	-->		
	<xsl:function name="ou:multieditButton">
		<xsl:if test="$ou:action='edt'">
			<ouc:div label="multiedit" group="everyone" button="hide"><ouc:multiedit /></ouc:div>
		</xsl:if>
	</xsl:function>
		
	<!--	DIRECT EDIT BUTTON.
			Creates the direct edit button while mimicking its functionality on staging.
	-->
	<xsl:function name="ou:directEditButton">
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'"><xsl:comment> ouc:ob </xsl:comment><xsl:comment> /ouc:ob </xsl:comment></xsl:when>
			<xsl:otherwise>Last Update: <xsl:value-of select="ou:dateFromDateTime($ou:modified,'/')" /></xsl:otherwise>
		</xsl:choose>		
	</xsl:function>
	
	<!--	Cerritos DIRECT EDIT BUTTON -->

	<xsl:template name="CerritosDirectEditButton">
		<xsl:param name="site1" as="xs:string" />
		<xsl:param name="dirname1" as="xs:string" />
		<xsl:param name="filename1" as="xs:string" />
		<!-- removes the / from the dirname1 -->
		<xsl:variable name="dirname2" select="substring(concat('/',tokenize($dirname1,'/')[2]),2)" />
		<xsl:choose>
			<xsl:when test="string-length(normalize-space($dirname2)) = 0">
				<!-- used for the college home page template and other pages in the root -->
				Last Update: <a href="javascript:void(0);" onclick="popupWarningEdit('https://a.cms.omniupdate.com/11/?skin=cerritos&amp;account=2017&amp;site={$site1}&amp;action=de&amp;path={concat('/',ou:replaceFileExtension($filename1,'pcf'))}');"><xsl:value-of select="ou:dateFromDateTime($ou:modified,'/')" /></a>
			</xsl:when>
			<xsl:otherwise>
				Last Update: <a href="javascript:void(0);" onclick="popupWarningEdit('https://a.cms.omniupdate.com/11/?skin=cerritos&amp;account=2017&amp;site={$site1}&amp;action=de&amp;path={concat($dirname1,'/',ou:replaceFileExtension($filename1,'pcf'))}');"><xsl:value-of select="ou:dateFromDateTime($ou:modified,'/')" /></a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--	DATE FROM DATETIME
			Takes two parameters: a dateTime and a delimiter.
			Returns the dateTime with the following format: M/DD/YYYY
	-->
	<xsl:function name="ou:dateFromDateTime">
		<xsl:param name="dateTime" as="xs:dateTime" />
		<xsl:param name="delim" />
		<xsl:value-of select="string-join((xs:string(month-from-dateTime($dateTime)),xs:string(day-from-dateTime($dateTime)),xs:string(year-from-dateTime($dateTime))),$delim)" />
	</xsl:function>
	
	<!--	BINARY TO INTEGER
			Takes one parameter: a binary string.
			Returns an integer representation of the binary string.
	-->
	<xsl:function name="ou:binToInt" as="xs:integer">
		<xsl:param name="bin" />
		<xsl:variable name="int" select="if($bin[2]) then number($bin[2]) else 0" />
		<xsl:value-of select="if($bin[1]='') then $int else ou:binToInt((substring($bin[1],2), 2 * $int + number(substring($bin[1],1,1))))" />
	</xsl:function>
	
	<!--	GET ADVANCE FIELD VALUE
			Function that parses advanced field for an attribute, and returns the value. If no value is found, returns 'false'.
			Used mostly for LDP.
	-->
	<xsl:function name="ou:get-adv">
		<xsl:param name="adv"/>
		<xsl:param name="key"/>
		<xsl:value-of select="if(contains($adv,$key)) then substring-before(substring-after($adv,concat($key,'=')),';') else 'false'" />
	</xsl:function>
	
	<!-- 	REPLACE FILE EXTENSION
			Takes two parameters: a file name (with extension) and the replacement extension.
			Returns a string of the file name with the replaced extension.
	-->	
	<xsl:function name="ou:replaceFileExtension">
		<xsl:param name="file" />
		<xsl:param name="ext" />
		<xsl:variable name="tokens" select="tokenize($file,'\.')" />
		<xsl:value-of select="string-join((remove($tokens,count($tokens)),$ext),'.')" />
	</xsl:function>
	
	<!-- 
	Grab file from production on staging and output a server side include on publish 
	-->
	<xsl:template name="unparsed-include-file">
		<xsl:param name="path"/>
		<xsl:variable name="prod-path" select="concat('https://www.cerritos.edu', $path)" />
		<xsl:choose>
		    <xsl:when test="unparsed-text-available($prod-path) and not(contains(unparsed-text($prod-path), 'Page Not Found'))">
				<xsl:choose>
				    <xsl:when test="not($ou:action = 'pub')">
						<xsl:value-of select="unparsed-text($prod-path)" disable-output-escaping="yes"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="ou:ssi($path)" />
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:otherwise>
				<xsl:if test="not($ou:action = 'pub')">
					<p><xsl:value-of select="concat('File not available. Please make sure the path ( ' ,$prod-path ,' ) is correct and the file is published.')" /></p>
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
    
    
    
    <!--
		OU GET TEXTUAL CONTENT
		Use when checking for any content (prep for an "if empty" check)
		Gets string representation of any node and its subnodes, replaces &nbsp; with space, and trims all whitespace
	-->
    <xsl:function name="ou:textual-content">
        <xsl:param name="element"/>
        <xsl:value-of select="normalize-space(replace(string($element), '&nbsp;', ' '))" />
    </xsl:function>
		
</xsl:stylesheet>
