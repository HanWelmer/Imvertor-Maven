<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    
    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"
    
    exclude-result-prefixes="#all" 
    version="2.0">
    
    <!--
        This stylesheet creates an XML modeldoc and adds BRO specific capabilities.
        
        It overrides some imported plugin functions.
    -->
    
    <xsl:import href="Imvert2modeldoc.xsl"/>
    
    
    <xsl:variable name="configuration-registration-objects-path" select="concat(imf:get-config-string('system','inp-folder-path'),'/cfg/local/registration-objects.xml')"/>
    <xsl:variable name="configuration-registration-objects-doc" select="imf:document($configuration-registration-objects-path,true())"/>
    
    <!-- overrides the default -->
    <xsl:function name="imf:initialize-modeldoc" as="item()*">
        
        <!-- the abbreviation for the registration object must be set here; this is part of the path in GIT where the catalog is uploaded -->
        <xsl:variable name="namespace" select="$imvert-document/imvert:packages/imvert:base-namespace"/>
        <xsl:variable name="abbrev" select="tokenize($namespace,'/')[last()]" as="xs:string?"/>
        <xsl:variable name="object" select="$configuration-registration-objects-doc//registratieobject[abbrev = $abbrev]"/>
        
        <!--check if known. -->
        <xsl:choose>
            <xsl:when test="empty($object)">
                <xsl:sequence select="imf:msg($imvert-document,'ERROR','The abbreviation [1] taken from [2] is not valid',($abbrev,$namespace))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:set-config-string('appinfo','registration-object-abbreviation',$abbrev)"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    <!-- 
        Verwijder het uppercase gedeelte uit de base type name. 
        Dus Splitsingstekeningreferentie APPARTEMENTSRECHTSPLITSING wordt Splitsingstekeningreferentie.
    -->
    <xsl:function name="imf:plugin-splice">
        <xsl:param name="typename"/>
        <xsl:value-of select="$typename"/>
    </xsl:function>
    
    <!-- 
        return a section name for a model passed as a package 
    -->
    <xsl:function name="imf:plugin-get-model-name">
        <xsl:param name="package" as="element()"/><!-- imvert:package or imvert:packages -->
        
        <xsl:value-of select="$package/imvert:name/@original"/>
    </xsl:function>
    
</xsl:stylesheet>