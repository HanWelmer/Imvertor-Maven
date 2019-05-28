<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <xsl:import href="common/Imvert2modeldoc-html-respec.xsl"/>
    
    
    <xsl:function name="imf:insert-chapter-intro" as="item()*">
        <xsl:param name="chapter" as="element(chapter)"/>
        <p>
            <b>Dit is de introductietekst voor dit onderdeel. Hier zou je bijv. kunnen opnemen: "Deze tekst is normatief".</b>
        </p>
        <p>
            <xsl:value-of select="imf:get-config-string('appinfo','release-name')"/> imvertor <xsl:value-of select="$chapter/../@generator-version"/>
        </p>
    </xsl:function>
    
</xsl:stylesheet>