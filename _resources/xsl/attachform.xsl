<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<form method="post" action="/practice/form-handler.php" enctype="multipart/form-data">
			<table>   
				<xsl:for-each select="elements/element">
					<tr>         
						<xsl:if test="type='TEXT'">
							<td>                 
								<xsl:value-of select="name"/> :
							</td>     
							<td>
								<input type="text" id="{id}" name="{id}" size="40"/>
							</td>
						</xsl:if>
						<xsl:if test="type='DATE'">
							<td>
								<xsl:value-of select="name"/> :
							</td>     
							<td>
								<input type="date" id="{id}" name="{id}" size="40"/>
							</td>
						</xsl:if>
						<xsl:if test="type='FILE'">
							<td>
								<xsl:value-of select="name"/> :
							</td>     
							<td>
								<input type="file" id="{id}" name="{id}" size="40"/>
							</td>
						</xsl:if>
					</tr>
				</xsl:for-each>
			</table>
		<br>
		<input type="submit" id="btn_sub" name="btn_sub" value="Submit" />
		</br>
		</form>
	</xsl:template>
</xsl:stylesheet>
