<?xml version="1.0" encoding="utf-8"?>
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

<!--
	New Page (Dept Inside) Updated 2025
-->

<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<!-- Imports -->
	<xsl:import href="common.xsl"/>
	
	
	<!-- Set Body Classes-->
	<xsl:param name="body-classes" select="'department inside'"/>
	
	<xsl:template name="page-content">
		<xsl:choose>
			<xsl:when test="ou:pcf-param('page-fullwidth') = 'true'">
				<main id="maincontent">
					<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />	
				</main>
			</xsl:when>
			<xsl:otherwise>
				<div class="container-xxl py-5">
					<div class="row">
						<xsl:choose>
							<xsl:when test="ou:pcf-param('hide-left-nav') = 'true' and ou:pcf-param('hide-dept-info') = 'true'">
								<!-- Main Content -->
								<main id="maincontent" class="col-12">
									<div id="skiptocontent"></div>
									<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />	
				
									<div>

										<form
											id="ContactForm"
											action="/scripts/FormToMail.aspx"
											method="post"
											name="ContactForm"
										>
											<p>
												<!-- EMAIL RECIPIENTS==YOU MUST CHANGE THESE -->
												<input
													name="_recipients"
													type="hidden"
													value="{ou:processEmails($Recipient1,$Recipient2,$Recipient3,$Recipient4,$Recipient5,$Recipient6)}"
												/>
												<!-- REQUIRED FIELDS -->
												<input
													name="_requiredFields"
													type="hidden"
													value="Name,Email,Request"
												/>
												<!-- reply to address taken from a form field (choose _replyToField or _replyTo) -->
												<input
													name="_replyToField"
													type="hidden"
													value="Email"
												/>
												<!-- EMAIL SUBJECT -->
												<input
													name="_subject"
													type="hidden"
													value="{$Subject}"
												/>
												<!-- ADD THE DATE AND TIME (OPTIONAL==CHOOSE ONLY ONE, true or false) -->
												<input
													name="_DateAndTime"
													type="hidden"
													value="true"
												/>
												<input
													name="_envars"
													type="hidden"
													value="HTTP_REFERER,HTTP_USER_AGENT,REMOTE_ADDR"
												/>
												<!-- CONFIRMATION REDIRECT -->
												<input
													name="_redirect"
													type="hidden"
													value="{$ConfirmationPage}"
												/>
											</p>
											<p>
												<label for="Name">
													<strong>* Name:</strong>
												</label><br />
												<input
													id="Name"
													name="Name"
													type="text"
													required="true"
												/>
											</p>
											<p>
												<label for="Email">
													<strong>* Email:</strong>
												</label><br />
												<input
													id="Email"
													name="Email"
													type="text"
													required="true"
												/>
											</p>
											<p>
												<label for="Phone">
													<strong>Phone:</strong>
												</label><br />
												<input
													id="Phone"
													name="Phone"
													type="text"
												/>
											</p>
											<p>
												<label for="Request">
													<strong>* Request:</strong>
												</label><br />
												<textarea
													id="Request"
													cols="40"
													rows="10"
													name="Request"
													required="true"
												></textarea>
											</p>
											<div
												class="g-recaptcha"
												data-sitekey="6LcxUk4UAAAAAMyg221MHklN6E_axt_jNmxZ69fI"
											></div>
											<br />
											<input
												id="Submit"
												type="submit"
												value="Submit"
											/>
											<label
												for="Reset"
												style="border: 0; clip: rect(0 0 0 0); height: 1px; margin: -1px; overflow: hidden; padding: 0; position: absolute; width: 1px;"
											>
												Reset
											</label>
											<input
												id="Reset"
												type="reset"
												value="Reset"
											/>
											*Required Fields
										</form>

									</div>
								</main>
							</xsl:when>
							<xsl:otherwise>
								

								<!-- Main Content -->
								<main id="maincontent" class="col-12 col-lg-8 col-xl-9">
									<div id="skiptocontent"></div>
									<xsl:apply-templates select="document/ouc:div[@label='maincontent']" />	
								</main>
								
								<!-- Sidebar -->
								<div class="col-12 col-lg-4 col-xl-3">
									<xsl:if test="lower-case(normalize-space(ou:pcf-param('hide-left-nav'))) != 'true'">
										<div class="d-none d-lg-block">
											<xsl:call-template name="sidebar-nav"/>
										</div>
									</xsl:if>
									<xsl:if test="lower-case(normalize-space(ou:pcf-param('hide-dept-info'))) != 'true'">
										<xsl:call-template name="sidebar-info"/>
									</xsl:if>
								</div>
							</xsl:otherwise>
						</xsl:choose>
					</div>
				</div>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>

	<xsl:function name="ou:processEmails">
		<xsl:param name="Recipient1"/>
		<xsl:param name="Recipient2"/>
		<xsl:param name="Recipient3"/>
		<xsl:param name="Recipient4"/>
		<xsl:param name="Recipient5"/>
		<xsl:param name="Recipient6"/>
		
		<xsl:if test="string-length($Recipient1) > 0"><xsl:value-of select="ou:parseString(substring-before($Recipient1,'@cerritos.edu'))"/></xsl:if>
		<xsl:if test="string-length($Recipient2) > 0">,<xsl:value-of select="ou:parseString(substring-before($Recipient2,'@cerritos.edu'))"/></xsl:if>
		<xsl:if test="string-length($Recipient3) > 0">,<xsl:value-of select="ou:parseString(substring-before($Recipient3,'@cerritos.edu'))"/></xsl:if>
		<xsl:if test="string-length($Recipient4) > 0">,<xsl:value-of select="ou:parseString(substring-before($Recipient4,'@cerritos.edu'))"/></xsl:if>
		<xsl:if test="string-length($Recipient5) > 0">,<xsl:value-of select="ou:parseString(substring-before($Recipient5,'@cerritos.edu'))"/></xsl:if>
		<xsl:if test="string-length($Recipient6) > 0">,<xsl:value-of select="ou:parseString(substring-before($Recipient6,'@cerritos.edu'))"/></xsl:if>

	</xsl:function>
	
	<xsl:function name="ou:parseString">
    	<xsl:param name="text"/>
		<xsl:analyze-string select="lower-case($text)" regex=".">
			<xsl:matching-substring>
				<xsl:choose>
				<xsl:when test=". = 'a'">
					<xsl:value-of select="9" />
				</xsl:when>
				<xsl:when test=". = 'b'">
					<xsl:value-of select="8" />
				</xsl:when>
				<xsl:when test=". = 'c'">
					<xsl:value-of select="7" />
				</xsl:when>
				<xsl:when test=". = 'd'">
					<xsl:value-of select="6" />
				</xsl:when>
				<xsl:when test=". = 'e'">
					<xsl:value-of select="5" />
				</xsl:when>
				<xsl:when test=". = 'f'">
					<xsl:value-of select="4" />
				</xsl:when>
				<xsl:when test=". = 'g'">
					<xsl:value-of select="3" />
				</xsl:when>
				<xsl:when test=". = 'h'">
					<xsl:value-of select="2" />
				</xsl:when>
				<xsl:when test=". = 'i'">
					<xsl:value-of select="1" />
				</xsl:when>
				<xsl:when test=". = 'j'">
					<xsl:value-of select="0" />
				</xsl:when>
				<xsl:when test=". = 'k'">
					<xsl:value-of select="'!'" />
				</xsl:when>
				<xsl:when test=". = 'l'">
					<xsl:value-of select="'`'" />
				</xsl:when>
				<xsl:when test=". = 'm'">
					<xsl:value-of select="'~'" />
				</xsl:when>
				<xsl:when test=". = 'n'">
					<xsl:value-of select="'$'" />
				</xsl:when>
				<xsl:when test=". = 'o'">
					<xsl:value-of select="':'" />
				</xsl:when>
				<xsl:when test=". = 'p'">
					<xsl:value-of select="'^'" />
				</xsl:when>
				<xsl:when test=". = 'q'">
					<xsl:value-of select="'*'" />
				</xsl:when>
				<xsl:when test=". = 'r'">
					<xsl:value-of select="'('" />
				</xsl:when>
				<xsl:when test=". = 's'">
					<xsl:value-of select="')'" />
				</xsl:when>
				<xsl:when test=". = 't'">
					<xsl:value-of select="'['" />
				</xsl:when>
				<xsl:when test=". = 'u'">
					<xsl:value-of select="']'" />
				</xsl:when>
				<xsl:when test=". = 'v'">
					<xsl:value-of select="'|'" />
				</xsl:when>
				<xsl:when test=". = 'w'">
					<xsl:value-of select="'/'" />
				</xsl:when>
				<xsl:when test=". = 'x'">
					<xsl:value-of select="'\'" />
				</xsl:when>
				<xsl:when test=". = 'y'">
					<xsl:value-of select="'-'" />
				</xsl:when>
				<xsl:when test=". = 'z'">
					<xsl:value-of select="'_'" />
				</xsl:when>
			</xsl:choose>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>

</xsl:stylesheet>