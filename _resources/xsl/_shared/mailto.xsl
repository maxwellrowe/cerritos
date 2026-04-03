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

	<!-- Match Mailto Links and Encode-->
	<xsl:function name="ou:encode-like-xsl" as="xs:string">
		<xsl:param name="s" as="xs:string?"/>

		<xsl:sequence select="
			string-join(
				for $cp in string-to-codepoints(lower-case(string($s)))
				return
					if (codepoints-to-string($cp)='a') then '9'
					else if (codepoints-to-string($cp)='b') then '8'
					else if (codepoints-to-string($cp)='c') then '7'
					else if (codepoints-to-string($cp)='d') then '6'
					else if (codepoints-to-string($cp)='e') then '5'
					else if (codepoints-to-string($cp)='f') then '4'
					else if (codepoints-to-string($cp)='g') then '3'
					else if (codepoints-to-string($cp)='h') then '2'
					else if (codepoints-to-string($cp)='i') then '1'
					else if (codepoints-to-string($cp)='j') then '0'
					else if (codepoints-to-string($cp)='k') then '!'
					else if (codepoints-to-string($cp)='l') then '`'
					else if (codepoints-to-string($cp)='m') then '~'
					else if (codepoints-to-string($cp)='n') then '$'
					else if (codepoints-to-string($cp)='o') then ':'
					else if (codepoints-to-string($cp)='p') then '^'
					else if (codepoints-to-string($cp)='q') then '*'
					else if (codepoints-to-string($cp)='r') then '('
					else if (codepoints-to-string($cp)='s') then ')'
					else if (codepoints-to-string($cp)='t') then '['
					else if (codepoints-to-string($cp)='u') then ']'
					else if (codepoints-to-string($cp)='v') then '|'
					else if (codepoints-to-string($cp)='w') then '/'
					else if (codepoints-to-string($cp)='x') then '\'
					else if (codepoints-to-string($cp)='y') then '-'
					else if (codepoints-to-string($cp)='z') then '_'
					else if (codepoints-to-string($cp)='(') then 'a'
					else if (codepoints-to-string($cp)=')') then 'b'
					else if (codepoints-to-string($cp)='.') then 'c'
					else if (codepoints-to-string($cp)=' ') then 'd'
					else if (codepoints-to-string($cp)='-') then 'e'
					else if (codepoints-to-string($cp)=&quot;'&quot;) then 'f'
					else codepoints-to-string($cp),
				''
			)
		"/>
	</xsl:function>
	
	<xsl:template
	match="*[local-name() = 'a']
		[starts-with(lower-case(normalize-space(string(@href))), 'mailto:')]
		[contains(lower-case(normalize-space(string(@href))), '@cerritos.edu')]"
	priority="10"
	mode="#all">

		<xsl:variable name="email-full" select="substring-after(string(@href), 'mailto:')"/>
		<xsl:variable name="email-no-query" select="replace($email-full, '\?.*$', '')"/>
		<xsl:variable name="user" select="substring-before($email-no-query, '@')"/>
		<xsl:variable name="domain" select="substring-after($email-no-query, '@')"/>
		<xsl:variable name="domain-1" select="substring-before($domain, '.')"/>
		<xsl:variable name="domain-2" select="substring-after($domain, '.')"/>
		<xsl:variable name="orig-class" select="normalize-space(string(@class))"/>

		<span class="email-secure">
			<a href="#"
			   class="{normalize-space(concat('email-secure-link ', $orig-class))}"
			   data-u="{ou:encode-like-xsl($user)}"
			   data-d1="{ou:encode-like-xsl($domain-1)}"
			   data-d2="{ou:encode-like-xsl($domain-2)}">

				<xsl:copy-of select="@*[local-name() != 'href' and local-name() != 'class']"/>

				<xsl:if test="not(@aria-label)">
					<xsl:attribute name="aria-label">Send email</xsl:attribute>
				</xsl:if>

				<xsl:choose>
					<xsl:when test="node()">
						<xsl:apply-templates select="node()" mode="#current"/>
					</xsl:when>
					<xsl:otherwise>Email</xsl:otherwise>
				</xsl:choose>
			</a>

			<xsl:if test="$orig-class = ''">
				<button type="button"
						class="email-secure-copy"
						data-u="{ou:encode-like-xsl($user)}"
						data-d1="{ou:encode-like-xsl($domain-1)}"
						data-d2="{ou:encode-like-xsl($domain-2)}"
						aria-label="Copy email address">
					<span aria-hidden="true" class="fa-regular fa-copy"></span>
					<span class="sr-only">Copy Email Address</span>
				</button>
			</xsl:if>
		</span>
	</xsl:template>	

</xsl:stylesheet>
