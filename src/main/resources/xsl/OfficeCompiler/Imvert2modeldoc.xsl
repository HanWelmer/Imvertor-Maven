<?xml version="1.0" encoding="UTF-8"?>
<!-- 
 * Copyright (C) 2016 Dienst voor het kadaster en de openbare registers
 * 
 * This file is part of Imvertor.
 *
 * Imvertor is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Imvertor is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Imvertor.  If not, see <http://www.gnu.org/licenses/>.
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 

    xmlns:imvert="http://www.imvertor.org/schema/system"
    xmlns:imvert-imap="http://www.imvertor.org/schema/imagemap"
    
    xmlns:ext="http://www.imvertor.org/xsl/extensions"
    xmlns:imf="http://www.imvertor.org/xsl/functions"

    exclude-result-prefixes="#all" 
    version="2.0">

    <!-- 
          Transform the embellishg file to a standard simplied documentation format, to be processed for display by separate metamodel/owner based modules.
    -->
    
    <xsl:import href="../common/Imvert-common.xsl"/>
    <xsl:import href="../common/Imvert-common-derivation.xsl"/>
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:variable name="i3n-document" select="imf:document('../../config/i3n/translate.xml')"/>
    
    <xsl:variable name="quot"><!--'--></xsl:variable>
    
    <xsl:variable name="subpath" select="imf:get-subpath(/*/imvert:project,/*/imvert:application,/*/imvert:release)"/>
    
    <xsl:variable name="create-links" select="imf:get-config-string('cli','createofficemode','click') = 'click'"/>
    
    <xsl:variable name="link-by-eaid" select="($configuration-docrules-file/link-by,'EAID')[1] eq 'EAID'"/>
    <xsl:variable name="explanation-location" select="$configuration-docrules-file/explanation-location"/>
    <xsl:variable name="append-role-name" select="imf:boolean($configuration-docrules-file/append-role-name)"/>
    
    <xsl:variable name="imagemap-path" select="imf:get-config-string('properties','WORK_BASE_IMAGEMAP_FILE')"/>
    <xsl:variable name="imagemap" select="imf:document($imagemap-path)/imvert-imap:diagrams"/>
    
    <xsl:variable name="include-incoming-associations" select="imf:boolean($configuration-docrules-file/include-incoming-associations)"/>
        
    <xsl:template match="/imvert:packages">
        <book name="{imvert:application}" subpath="{$subpath}" type="{imvert:stereotype}" id="{imvert:id}" generator-version="{$imvertor-version}" generator-date="{$generation-date}">
       
            <!-- first call a general initialization function -->
            <xsl:sequence select="imf:initialize-modeldoc()"/>
            
            <!-- then generate the contents -->
            <xsl:variable name="sections" as="element()*">
                <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
                <!-- exclude package replacements (resolved stereotype internal) -->
                <xsl:apply-templates select="imvert:package[imvert:stereotype/@id = ('stereotype-name-domain-package') and empty(imvert:package-replacement)]"/>
            </xsl:variable>
            <xsl:apply-templates select="$sections" mode="section-cleanup"/>    

        </book>
    </xsl:template>
    
    <xsl:template match="imvert:package"><!-- only domain packs -->
        <section type="DOMAIN" name="{imf:plugin-get-model-name(.)}" id="{imf:plugin-get-link-name(.,'global')}">
            
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            
            <section type="OVERVIEW-OBJECTTYPE">
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype')]"/>
            </section>
            <section type="OVERVIEW-ASSOCIATIONCLASS">
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-relatieklasse')]"/>
            </section>
            <section type="OVERVIEW-REFERENCELIST">
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]"/>
            </section>
            <section type="OVERVIEW-UNION">
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-union')]"/>
            </section>
            <section type="OVERVIEW-STRUCTUREDDATATYPE">
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]"/>
            </section>
            <section type="OVERVIEW-PRIMITIVEDATATYPE">
                <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-simpletype')]"/>
            </section>
            <section type="OVERVIEW-CODELIST">
                <content>
                    <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-codelist')]"/>
                </content>
            </section>
            <section type="OVERVIEW-ENUMERATION">
                <content>
                    <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration')]"/>
                </content>
            </section>
            <section type="DETAILS">
                <section type="DETAILS-OBJECTTYPE">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype')]" mode="detail"/>
                </section>
                <section type="DETAILS-ASSOCIATIONCLASS">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-relatieklasse')]" mode="detail"/>
                </section>
                <section type="DETAILS-REFERENCELIST">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]" mode="detail"/>
                </section>
                <section type="DETAILS-UNION">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-union')]" mode="detail"/>
                </section>
                <section type="DETAILS-STRUCTUREDDATATYPE">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]" mode="detail"/>
                </section>
                <section type="DETAILS-PRIMITIVEDATATYPE">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-simpletype')]" mode="detail"/>
                </section>
                <section type="DETAILS-CODELIST">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-codelist')]" mode="detail"/>
                </section>
                <section type="DETAILS-ENUMERATION">
                    <xsl:apply-templates select="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration')]" mode="detail"/>
                </section>
            </section>
        </section>
   
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-objecttype')]">
        <section name="{imf:get-name(.,true())}" type="OBJECTTYPE" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-OBJECTTYPE')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <!-- hier alle relaties; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:associations" mode="short"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>

    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-relatieklasse')]">
        <section name="{imf:get-name(.,true())}" type="ASSOCIATIONCLASS" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-ASSOCIATIONCLASS')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <!-- hier alle relaties; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:associations" mode="short"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
       
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-referentielijst')]">
        <section name="{imf:get-name(.,true())}" type="REFERENCELIST" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-REFERENCELIST')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <!-- hier alle type relaties -->
            <xsl:apply-templates select="." mode="type-relations"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
   
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-union')]">
        <section name="{imf:get-name(.,true())}" type="UNION" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-UNION')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <!-- hier alle type relaties -->
            <xsl:apply-templates select="." mode="type-relations"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-complextype')]">
        <section name="{imf:get-name(.,true())}" type="STRUCTUREDDATATYPE" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-STRUCTUREDDATATYPE')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="short"/>
            <!-- hier alle type relaties -->
            <xsl:apply-templates select="." mode="type-relations"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-simpletype')]">
        <section name="{imf:get-name(.,true())}" type="PRIMITIVEDATATYPE" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-PRIMITIVEDATATYPE')"/>
            </content>
            <!-- hier alle type relaties -->
            <xsl:apply-templates select="." mode="type-relations"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
  
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration','stereotype-name-codelist')]">
        <xsl:variable name="naam" select="imf:get-name(.,true())"/>
        <part>
            <item id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
                <xsl:sequence select="imf:create-idref(.,'detail')"/>
                <xsl:sequence select="imf:create-content($naam)"/>          
            </item>
            <!-- hier alle type relaties -->
            <xsl:apply-templates select="." mode="type-relations"/>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
        </part>
     </xsl:template>

    <!-- uitzondering: gegevensgroeptype wordt apart getoond. -->
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-composite')]">
        <section name="{imf:get-name(.,true())}" type="COMPOSITE" id="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <xsl:sequence select="imf:create-section-for-diagrams(.)"/>
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-GLOBAL-COMPOSITE')"/>
            </content>
            <!-- hier alle attributen; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:attributes" mode="gegevensgroeptype"/>
            <!-- hier alle relaties; als ingebedde tabel -->
            <xsl:apply-templates select="imvert:associations" mode="gegevensgroeptype"/>
        </section>
    </xsl:template>

    <xsl:template match="imvert:attributes" mode="short gegevensgroeptype">
        
        <xsl:variable name="attribute-kind" select="
            if (../imvert:stereotype/@id = ('stereotype-name-complextype')) then 'D' 
            else if (../imvert:stereotype/@id = ('stereotype-name-union')) then 'U'
            else if (../imvert:stereotype/@id = ('stereotype-name-referentielijst')) then 'R'
            else 'A'"/>
        
            <!-- (D)ata element or (U)nion element or (A)ttribute -->
        
        <xsl:variable name="r" as="element()*">
            <xsl:choose>
                <xsl:when test="imf:get-config-stereotypes('stereotype-name-association-to-composite') = '#unknown'">
                    <!-- attribuut groepen zijn als attribuut opgenomen. -->
                    <xsl:apply-templates select="imvert:attribute[not(imvert:stereotype/@id = ('stereotype-name-attributegroup'))]" mode="#current"/>
                    <!-- als de class ook gegevensgroepen heeft, die attributen hier invoegen -->
                    <xsl:for-each select="imvert:attribute[imvert:stereotype/@id = ('stereotype-name-attributegroup')]">
                        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
                        <xsl:if test="$defining-class[imvert:stereotype/@id = ('stereotype-name-composite')]">
                            <!-- eerst gegevensgroeptype info -->
                            <!--(4)-->
                            <xsl:apply-templates select="." mode="composition"/>
                            <!-- en dat de attributen daarin -->
                            <xsl:apply-templates select="$defining-class/imvert:attributes/imvert:attribute" mode="gegevensgroeptype"/>
                            <xsl:apply-templates select="$defining-class/imvert:associations/imvert:association" mode="gegevensgroeptype-as-attribute"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <!-- attribuut groepen zijn via associatie gekoppeld. -->
                    <xsl:apply-templates select="imvert:attribute" mode="#current"/>
                    <!-- als de class ook gegevensgroepen heeft, die attributen hier invoegen -->
                    <xsl:for-each select="../imvert:associations/imvert:association">
                        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
                        <xsl:if test="$defining-class[imvert:stereotype/@id = ('stereotype-name-composite')]">
                            <!-- eerst gegevensgroeptype info -->
                            <!--(4)-->
                            <xsl:apply-templates select="." mode="composition"/>
                            <!-- en dat de attributen daarin -->
                            <xsl:apply-templates select="$defining-class/imvert:attributes/imvert:attribute" mode="gegevensgroeptype"/>
                            <xsl:apply-templates select="$defining-class/imvert:associations/imvert:association" mode="gegevensgroeptype-as-attribute"/>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="exists($r)">
            <xsl:choose>
                <xsl:when test="$attribute-kind = 'A'">
                    <section type="SHORT-ATTRIBUTES">
                        <content>
                            <itemtype/>
                            <itemtype type="ATTRIBUTE-NAME"/>
                            <itemtype type="ATTRIBUTE-DEFINITION"/>
                            <itemtype type="ATTRIBUTE-FORMAT"/>
                            <itemtype type="ATTRIBUTE-CARD"/>
                            <!-- and add rows -->
                            <xsl:sequence select="$r"/>
                        </content>
                    </section>
                </xsl:when>
                <xsl:when test="$attribute-kind = 'U'">
                    <section type="SHORT-UNIONELEMENTS">
                        <content>
                            <itemtype/>
                            <itemtype type="UNIONELEMENT-NAME"/>
                            <itemtype type="UNIONELEMENT-DEFINITION"/>
                            <itemtype type="UNIONELEMENT-FORMAT"/>
                            <itemtype type="UNIONELEMENT-CARD"/>
                            <!-- and add rows -->
                            <xsl:sequence select="$r"/>
                        </content>
                    </section>
                </xsl:when>
                <xsl:when test="$attribute-kind = 'R'">
                    <section type="SHORT-REFERENCEELEMENTS">
                        <content>
                            <itemtype/>
                            <itemtype type="REFERENCEELEMENT-NAME"/>
                            <itemtype type="REFERENCEELEMENT-DEFINITION"/>
                            <itemtype type="REFERENCEELEMENT-FORMAT"/>
                            <itemtype type="REFERENCEELEMENT-CARD"/>
                            <!-- and add rows -->
                            <xsl:sequence select="$r"/>
                        </content>
                    </section>
                </xsl:when>
                <xsl:otherwise>
                    <section type="SHORT-DATAELEMENTS">
                        <content>
                            <itemtype/>
                            <itemtype type="DATAELEMENT-NAME"/>
                            <itemtype type="DATAELEMENT-DEFINITION"/>
                            <itemtype type="DATAELEMENT-FORMAT"/>
                            <itemtype type="DATAELEMENT-CARD"/>
                            <!-- and add rows -->
                            <xsl:sequence select="$r"/>
                        </content>
                    </section>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="short">
       <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
       <part>
           <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',imf:get-name(.,true())))"/> 
           <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
           <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imf:plugin-splice(imvert:baretype),false())))"/>
           <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
       </part>
    </xsl:template>

    <xsl:template match="imvert:attribute" mode="gegevensgroeptype">
       <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
       <part type="COMPOSED">
           <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',imf:get-name(.,true())))"/>
           <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
           <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imf:plugin-splice(imvert:baretype),false())))"/>
          <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
        </part>
    </xsl:template>
   
    <xsl:template match="imvert:association" mode="gegevensgroeptype-as-attribute">
       <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <part type="COMPOSED">
            <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',imf:get-name(.,true())))"/>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
            <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',imf:plugin-translate-i3n(imvert:type-name/@original,false())))"/>
           <xsl:sequence select="imf:create-element('item',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
        </part>
    </xsl:template>
    
    <xsl:template match="imvert:attribute | imvert:association" mode="composition">
        <!-- toon alsof het een attribuut is -->
        <xsl:variable name="type" select="imf:get-construct-by-id(imvert:type-id)"/>
       <part type="COMPOSER">
          <item>
              <xsl:sequence select="imf:create-element('value',imf:create-link($type,'detail',imf:get-name(.,true())))"/>
          </item>
          <item>
              <xsl:sequence select="imf:create-element('value',imf:get-formatted-tagged-value($type,'CFG-TV-DEFINITION'))"/>
          </item>
          <item>
             <!--<xsl:sequence select="imf:create-element('value',imf:plugin-translate-i3n(imvert:baretype,false()))"/>-->
              <!-- empty-->
          </item>
          <item>
             <xsl:sequence select="imf:create-element('value',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs))"/>
          </item>
       </part>
    </xsl:template>
    
    <xsl:template match="imvert:class" mode="type-relations">
        <xsl:variable name="r1" as="element()*">
            <xsl:apply-templates select="imvert:supertype" mode="short"/>
        </xsl:variable>
        <xsl:if test="exists($r1)">
            <section type="SHORT-TYPERELATIONS">
                <content approach="association">
                    <itemtype/>
                    <itemtype type="SUPERTYPE-NAME"/>
                    <itemtype type="SUPERTYPE-DEFINITION"/>
                    <xsl:sequence select="$r1"/>
                </content>
                <content approach="target">
                    <itemtype/>
                    <itemtype type="SUPERTYPE-NAME"/>
                    <itemtype type="SUPERTYPE-DEFINITION"/>
                    <xsl:sequence select="$r1"/>
                </content>
            </section>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:associations" mode="short gegevensgroeptype">
        <xsl:variable name="id" select="../imvert:id"/>
        <xsl:variable name="incoming-assocs" select="root(.)//imvert:association[imvert:type-id = $id]"/>
        <xsl:variable name="incoming-assocs-non-recursive" select="$incoming-assocs[../../imvert:id ne $id]"/>
        
        <xsl:variable name="r1" as="element()*">
            <xsl:apply-templates select="../imvert:supertype" mode="#current"/>
            <xsl:apply-templates select="imvert:association[not(imvert:stereotype/@id = ('stereotype-name-association-to-composite'))]" mode="#current"/>
            <xsl:if test="$include-incoming-associations">
                <xsl:apply-templates select="$incoming-assocs-non-recursive[not(imvert:stereotype/@id = ('stereotype-name-association-to-composite'))]" mode="#current">
                    <xsl:with-param name="incoming" select="true()"/>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="r2" as="element()*">
            <xsl:apply-templates select="../imvert:supertype" mode="#current"/>
            <xsl:apply-templates select="imvert:association[not(imvert:stereotype/@id = ('stereotype-name-association-to-composite'))]/imvert:target" mode="#current"/>
            <xsl:if test="$include-incoming-associations">
                <xsl:apply-templates select="$incoming-assocs-non-recursive[not(imvert:stereotype/@id = ('stereotype-name-association-to-composite'))]/imvert:target" mode="#current">
                    <xsl:with-param name="incoming" select="true()"/>
                </xsl:apply-templates>
            </xsl:if>
        </xsl:variable>
        <xsl:if test="exists(($r1,$r2))">
            <section type="SHORT-ASSOCIATIONS">
                <content approach="association">
                    <itemtype/>
                    <itemtype type="ASSOCIATION-NAME"/>
                    <itemtype type="ASSOCIATION-DEFINITION"/>
                    <xsl:sequence select="$r1"/>
                </content>
                <content approach="target">
                    <itemtype/>
                    <itemtype type="ROLE-NAME"/>
                    <itemtype type="ROLE-DEFINITION"/>
                    <xsl:sequence select="$r2"/>
                </content>
            </section>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="short gegevensgroeptype">
        <xsl:param name="incoming" as="xs:boolean" select="false()"/>
        
        <xsl:variable name="type" select="imf:get-construct-by-id(imvert:type-id)"/>
        <part>
            <item>
                <!--
                Voorbeeld: ZAAKTYPE [1..*] heeft relevant BESLUITTYPE [0..*]
                
                maar kan ook een rol betreffen
                -->
                <xsl:variable name="relation" select="imvert:name"/>
                <xsl:variable name="target" select="imvert:target/imvert:role"/>
                <xsl:variable name="relation-original-name" select="if (exists($relation) and exists($target)) then concat($relation/@original,': ',$target/@original) else ($relation/@original,$target/@original)"/>
                
                <xsl:sequence select="imf:create-element('item',if ($incoming) then imf:create-link(../..,'global',../../imvert:name/@original) else string(../../imvert:name/@original))"/>
                <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(imvert:min-occurs-source,imvert:max-occurs-source),']'))"/>
                <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',$relation-original-name))"/>
                <xsl:sequence select="imf:create-element('item',if ($incoming) then string(imvert:type-name/@original) else imf:create-link($type,'global',imvert:type-name/@original))"/>
                <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(imvert:min-occurs,imvert:max-occurs),']'))"/>
            </item>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
            
        </part>
    </xsl:template>
  
    <xsl:template match="imvert:association/imvert:target" mode="short gegevensgroeptype">
        <xsl:param name="incoming" as="xs:boolean" select="false()"/>
     
        <xsl:variable name="type" select="imf:get-construct-by-id(../imvert:type-id)"/>
        <part>
            <item>
                <!--
                    De weergave van de informtie mbt een target role
                -->
                <xsl:variable name="relation" select="../imvert:name"/>
                <xsl:variable name="target" select="imvert:role"/>
                <xsl:variable name="relation-original-name" select="if (exists($relation) and exists($target)) then concat($relation/@original,': ',$target/@original) else ($relation/@original,$target/@original)"/>
                
                <xsl:sequence select="imf:create-element('item',if ($incoming) then imf:create-link(../../..,'global',../../../imvert:name/@original) else string(../../../imvert:name/@original))"/>
                <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(../imvert:min-occurs-source,../imvert:max-occurs-source),']'))"/>
                <xsl:sequence select="imf:create-element('item',imf:create-link(.,'detail',$relation-original-name))"/>
                <xsl:sequence select="imf:create-element('item',if ($incoming) then string(../imvert:type-name/@original) else imf:create-link($type,'global',../imvert:type-name/@original))"/>
                <xsl:sequence select="imf:create-element('item',('[',imf:get-cardinality(../imvert:min-occurs,../imvert:max-occurs),']'))"/>
            </item>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
        </part>
    </xsl:template>
    
    <xsl:template match="imvert:supertype" mode="short gegevensgroeptype">
        <xsl:variable name="type" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <part>
            <item>
                <!--
                Voorbeeld: BENOEMD TERREIN is specialisatie van BENOEMD OBJECT
                -->
                <item>
                    <xsl:value-of select="imf:get-name(..,true())"/>
                </item>
                <item>
                    <xsl:value-of select="imf:plugin-translate-i3n('ISSPECIALISATIONOF',true())"/>
                </item>
                <xsl:sequence select="imf:create-element('item',imf:create-link($type,'global',(imvert:type-name/@original,string(imvert:conceptual-schema-type))[1]))"/>
            </item>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value($type,'CFG-TV-DEFINITION'))"/>
        </part>
    </xsl:template>
    
    <!-- Stel detailinfo samen voor een objecttype, relatieklasse, enumeratie -->
    <xsl:template match="imvert:class" mode="detail">
        <section name="{imf:get-name(.,true())}" type="{imvert:stereotype[1]}" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
           
            <xsl:variable name="associations" select="imvert:associations/imvert:association"/>
            <xsl:variable name="compositions" select="$associations[imvert:stereotype/@id = ('stereotype-name-association-to-composite')]"/>
          
            <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail"/>
            <xsl:for-each select="$compositions">
                <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
                <xsl:apply-templates select="$defining-class" mode="detail"/>
                <!--<xsl:apply-templates select="$defining-class/imvert:attributes/imvert:attribute" mode="detail"/>-->
            </xsl:for-each>
            <xsl:apply-templates select="($associations except $compositions)" mode="detail"/>       
        
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-codelist')]" mode="detail">
        <section name="{imf:get-name(.,true())}" type="DETAIL-CODELIST" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <content>
                <part>
                    <xsl:sequence select="imf:create-element('item',imf:plugin-translate-i3n('DEFINITIE',true()))"/>
                    <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
                </part>
            </content>
            <content>
                <itemtype type="CODE"/>
                <itemtype type="NAME"/>
                <itemtype type="DEFINITION"/>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail-enumeratie"/><!-- same as enumeration -->
            </content>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-enumeration')]" mode="detail">
        <section name="{imf:get-name(.,true())}" type="DETAIL-ENUMERATION" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}" uuid="{imvert:id}">
            <content>
                <part>
                    <xsl:sequence select="imf:create-element('item',imf:plugin-translate-i3n('DEFINITIE',true()))"/>
                    <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
                </part>
            </content>
            <content>
                <itemtype type="CODE"/>
                <itemtype type="NAME"/>
                <itemtype type="DEFINITION"/>
                <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail-enumeratie"/>
            </content>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:class[imvert:stereotype/@id = ('stereotype-name-composite')]" mode="detail">
        
        <section name="{imf:get-name(.,true())}" type="DETAIL-COMPOSITE" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-COMPOSITE')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
            <xsl:apply-templates select="imvert:attributes/imvert:attribute" mode="detail"/>
            <xsl:apply-templates select="imvert:associations/imvert:association" mode="detail"/>
        </section>
  
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <xsl:variable name="naam" select="imf:get-name($construct,true())"/>
        <xsl:choose>
            <xsl:when test="$defining-class/imvert:stereotype/@id = ('stereotype-name-composite')">
                <xsl:apply-templates select="$defining-class" mode="detail"/>
            </xsl:when>
            <xsl:when test="$construct/imvert:stereotype/@id = ('stereotype-name-composite')">
                <xsl:apply-templates select="." mode="detail-gegevensgroeptype"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype/@id = ('stereotype-name-referentie-element')">
                <xsl:apply-templates select="." mode="detail-referentie-element"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype/@id = ('stereotype-name-union-element')">
                <xsl:apply-templates select="." mode="detail-unionelement"/>
            </xsl:when>
            <xsl:when test="imvert:stereotype/@id = ('stereotype-name-data-element')">
                <xsl:apply-templates select="." mode="detail-dataelement"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="detail-normal"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-normal">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-afleidbaar-text" select="if (imf:boolean(imvert:is-value-derived)) then 'Ja' else 'Nee'"/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-ATTRIBUTE" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-ATTRIBUTE')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>       
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-enumeratie">
        <part>
            <xsl:sequence select="imf:create-element('item',imvert:alias)"/>
            <xsl:sequence select="imf:create-element('item',imf:get-name(.,true()))"/>
            <xsl:sequence select="imf:create-element('item',imf:get-formatted-tagged-value(.,'CFG-TV-DEFINITION'))"/>
       </part>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-gegevensgroeptype">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-identifying" select="imf:boolean(imvert:is-id)"/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-COMPOSITE-ATTRIBUTE" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <part type="COMPOSER">
                    <xsl:sequence select="imf:create-link($construct,'global', imf:get-name($construct,true()))"/>
                </part>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-COMPOSITE-ATTRIBUTE')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-referentie-element">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-identifying" select="imf:boolean(imvert:is-id)"/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-REFERENCEELEMENT" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-REFERENCEELEMENT')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
        
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-unionelement">
        <xsl:variable name="construct" select="../.."/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-UNIONELEMENT" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-UNIONELEMENT')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:attribute" mode="detail-dataelement">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="is-afleidbaar-text" select="if (imf:boolean(imvert:is-value-derived)) then 'Ja' else 'Nee'"/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-DATAELEMENT" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-DATAELEMENT')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
  
    <xsl:template match="imvert:association" mode="detail">
        <xsl:variable name="construct" select="../.."/>
        <xsl:choose>
            <xsl:when test="$construct/imvert:stereotype/@id = ('stereotype-name-composite')">
                <xsl:apply-templates select="." mode="detail-gegevensgroeptype"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="." mode="detail-normal"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="detail-normal">
     
        <section name="{imf:get-name(.,true())}" type="DETAIL-ASSOCIATION" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content approach="association">
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-ASSOCIATION')"/>
            </content>
            <content approach="target">
                <xsl:sequence select="imf:create-parts-cfg(imvert:target,'DISPLAY-DETAIL-ASSOCIATION')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(imvert:target,'CFG-TV-DESCRIPTION'))"/>
        </section>
    </xsl:template>
    
    <xsl:template match="imvert:association" mode="detail-gegevensgroeptype">
        <xsl:variable name="construct" select="../.."/>
        <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office(imvert:type-id)"/>
        <section name="{imf:get-name(.,true())}" type="DETAIL-COMPOSITE-ASSOCIATION" id="{imf:plugin-get-link-name(.,'detail')}" id-global="{imf:plugin-get-link-name(.,'global')}">
            <content>
                <?x
                <part type="COMPOSER">
                    <xsl:sequence select="imf:create-link($construct,'global', imf:get-name($construct,true()))"/>
                </part>
                ?>
                <xsl:sequence select="imf:create-parts-cfg(.,'DISPLAY-DETAIL-COMPOSITE-ASSOCIATION')"/>
            </content>
            <xsl:sequence select="imf:create-toelichting(imf:get-formatted-tagged-value(.,'CFG-TV-DESCRIPTION'))"/>
        </section>
        
    </xsl:template>
    
    <xsl:function name="imf:get-formatted-tagged-value" as="xs:string">        
        <xsl:param name="this" />
        <xsl:param name="tv-id"/>
        <xsl:variable name="tv-element" select="imf:get-most-relevant-compiled-taggedvalue-element($this,concat('##',$tv-id))"/>
        <xsl:value-of select="imf:get-clean-documentation-string(imf:get-tv-value($tv-element))"/>
    </xsl:function>
    
    <xsl:function name="imf:get-formatted-tagged-value-cfg" as="item()*">        
        <xsl:param name="level"/>
        <xsl:param name="this"/>
        <xsl:param name="tv-id"/>
        <xsl:choose>
            <xsl:when test="$level/@compile = 'full'">
                <xsl:variable name="all-tv" select="imf:get-all-compiled-tagged-values($this,false())"/>
                <xsl:variable name="vals" select="$all-tv[@id = $tv-id]"/>
                <xsl:for-each select="$vals">
                    <item type="TRACED">
                        <item type="SUPPLIER">
                            <xsl:value-of select="imf:get-subpath(@project,@application,@release)"/>
                        </item>
                        <item>
                            <xsl:value-of select="imf:get-clean-documentation-string(imf:get-tv-value(.))"/>
                        </item>
                    </item>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="tv-element" select="imf:get-most-relevant-compiled-taggedvalue-element($this,concat('##',$tv-id))"/>
                <xsl:value-of select="imf:get-clean-documentation-string(imf:get-tv-value($tv-element))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-tagged-value-unieke-aanduiding">
        <xsl:param name="this"/>
        <xsl:variable name="id-attribute" select="$this/imvert:attributes/imvert:attribute[imf:boolean(imvert:is-id)]"/>
        <xsl:sequence select="if (exists($id-attribute)) then imf:get-name($id-attribute,true()) else ''"/>
    </xsl:function>
    
   <xsl:function name="imf:create-part-2" as="element(part)*"> 
       <xsl:param name="level" as="element(level)"/>
       <xsl:param name="waarde" as="item()*"/>
     
       <xsl:variable name="doc-rule" select="$level/../.."/>
       
       <xsl:variable name="name" select="$doc-rule/name"/> 
       <xsl:variable name="doc-rule-id" select="$doc-rule/@id"/>
       
       <xsl:variable name="show" select="$level/@show"/> <!-- force, implied or none -->
       <xsl:variable name="compile" select="$level/@compile"/> <!-- single or full -->
       <xsl:variable name="format" select="$level/@format"/> <!-- plain or ? -->
       
       <xsl:variable name="exists-waarde" select="normalize-space(string-join($waarde,''))"/>
       
       <xsl:variable name="display-waarde" as="item()*">
           <xsl:choose>
               <xsl:when test="$show = 'none'">
                   <!-- skip; this is forced by the configuration -->
               </xsl:when>
               <xsl:when test="$show = 'implied' and not($exists-waarde)">
                   <!-- skip -->
               </xsl:when>
               <xsl:when test="$show = 'missing' and not($exists-waarde)">
                   <xsl:value-of select="'MISSING'"/>
               </xsl:when>
               <xsl:otherwise>
                   <xsl:sequence select="$waarde"/>
               </xsl:otherwise>
           </xsl:choose>
       </xsl:variable>
       
       <xsl:choose>
           <xsl:when test="$show = 'implied' and not($exists-waarde)">
               <!-- skip -->
           </xsl:when>
           <xsl:otherwise>
               <part type="{$doc-rule-id}">
                   <xsl:sequence select="imf:create-element('item',string($name))"/>
                   <xsl:choose>
                       <xsl:when test="$format = 'plain'">
                           <xsl:sequence select="imf:create-element('item',$display-waarde)"/>          
                       </xsl:when>
                       <xsl:otherwise>
                           <xsl:sequence select="imf:msg('FATAL','Unknown format: [1]',$format)"/>          
                       </xsl:otherwise>
                   </xsl:choose>
               </part>
           </xsl:otherwise>
       </xsl:choose>
   </xsl:function>
  
    <xsl:function name="imf:create-parts-cfg" as="element(part)*">
        <xsl:param name="this" as="element()"/>
        <xsl:param name="level" as="xs:string"/> <!-- a description of what to show, see docrules. --> 
        
        <xsl:variable name="isrole" select="exists($this/self::imvert:target)"/>
        <xsl:variable name="relation" select="if ($isrole) then $this/.. else $this"/>
        
        <xsl:for-each select="$configuration-docrules-file/doc-rule/levels/level[. = $level]">
           
            <xsl:variable name="doc-rule-id" select="../../@id"/>
           
            <xsl:choose>
                <!-- 
                    create and entry "name", "target role name" or "name: target role name" 
                -->
                <xsl:when test="$doc-rule-id = 'CFG-DOC-NORMNAAM'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-name($this,false()))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-NAAM'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-name($this,true()))"/>
                </xsl:when>
                <!-- 
                    remainder is specified on target or relation, as may be the case 
                -->
                <xsl:when test="$doc-rule-id = 'CFG-DOC-ALTERNATIEVENAAM'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-NAME'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-MNEMONIC'">
                    <xsl:sequence select="imf:create-part-2(.,string($relation/imvert:alias))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-HERKOMST'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-SOURCE'))"/> 
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-DEFINITIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DEFINITION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-HERKOMSTDEFINITIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-SOURCEOFDEFINITION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-TOELICHTING'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DESCRIPTION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-DATUMOPNAME'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DATERECORDED'))"/>
                </xsl:when>
                <?x
                <xsl:when test="$doc-rule-id = 'CFG-DOC-UNIEKEAANDUIDING'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-tagged-value-unieke-aanduiding($this))"/>
                </xsl:when>
                x?>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-POPULATIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-POPULATION'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-KWALITEITSBEGRIP'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-QUALITY'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-MOGELIJKGEENWAARDE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-VOIDABLE'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEMATERIELEHISTORIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-INDICATIONMATERIALHISTORY'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEFORMELEHISTORIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-INDICATIONFORMALHISTORY'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEINONDERZOEK'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-INDICATIEINONDERZOEK'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-AANDUIDINGSTRIJDIGHEIDNIETIGHEID'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-AANDUIDINGSTRIJDIGHEIDNIETIGHEID'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-UNITOFMEASURE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-UNITOFMEASURE'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-MINIMUMVALUE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-MINIMUMVALUE'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-MAXIMUMVALUE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-MAXIMUMVALUE'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEKARDINALITEIT'">
                    <xsl:variable name="min" select="$relation/imvert:min-occurs"/>
                    <xsl:variable name="max" select="$relation/imvert:max-occurs"/>
                    <xsl:sequence select="imf:create-part-2(.,imf:get-cardinality($min,$max))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEAUTHENTIEK'">
                    <xsl:sequence select="imf:create-part-2(.,concat(imf:get-formatted-tagged-value($this,'CFG-TV-INDICATIONAUTHENTIC'), imf:authentiek-is-derived($this)))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-REGELS'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-RULES'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-REGELS-IMBROA'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-RULES-IMBROA'))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-UNIEKEAANDUIDING'">
                    <xsl:variable name="rel-aanduiding" select="$relation/imvert:associations/imvert:association[imvert:target/imvert:stereotype/@id = ('stereotype-name-composite-id')][1]"/>
                    <xsl:variable name="con-aanduiding" select="imf:get-construct-by-id-for-office($rel-aanduiding/imvert:type-id)"/>
                    <xsl:variable name="id-aanduiding" select="imf:get-tagged-value-unieke-aanduiding($this)"/>
                    
                    <xsl:variable name="con" select="concat($relation/imvert:name/@original, ' ', $rel-aanduiding/imvert:name/@original, ' ', $con-aanduiding/imvert:name/@original)"/>
                    
                    <xsl:variable name="aanduiding">
                        <xsl:choose>
                            <xsl:when test="exists($rel-aanduiding) and exists($id-aanduiding)">
                                <xsl:value-of select="concat($id-aanduiding,', ', $con)"/>
                            </xsl:when>
                            <xsl:when test="exists($rel-aanduiding)">
                                <xsl:value-of select="$con-aanduiding/imvert:name/@original"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$id-aanduiding"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <xsl:sequence select="imf:create-part-2(.,$aanduiding)"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEABSTRACTOBJECT'">
                    <xsl:variable name="is-abstract-text" select="if (imf:boolean($relation/imvert:abstract)) then 'YES' else 'NO'"/>
                    <xsl:sequence select="imf:create-part-2(.,imf:plugin-translate-i3n($is-abstract-text,false()))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-DATALOCATIE'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-DATALOCATION'))"/>         
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-PATROON'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-PATTERN'))"/>         
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-FORMEELPATROON'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-formatted-tagged-value-cfg(.,$this,'CFG-TV-FORMALPATTERN'))"/>         
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-FORMAAT'">
                    <xsl:sequence select="imf:create-part-2(.,imf:plugin-translate-i3n($relation/imvert:baretype,false()))"/>         
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-RELATIESOORT'">
                    <xsl:sequence select="imf:create-part-2(.,imf:get-relatiesoort($relation))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-GERELATEERDOBJECTTYPE'">
                    <xsl:variable name="defining-class" select="imf:get-construct-by-id-for-office($relation/imvert:type-id)"/>          
                    <xsl:sequence select="imf:create-part-2(.,imf:create-link($defining-class,'global',$relation/imvert:type-name/@original))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-INDICATIEAFLEIDBAAR'">
                    <xsl:variable name="is-afleidbaar-text" select="if (imf:boolean($relation/imvert:is-value-derived)) then 'YES' else 'NO'"/>
                    <xsl:sequence select="imf:create-part-2(.,imf:plugin-translate-i3n($is-afleidbaar-text,false()))"/>
                </xsl:when>
                <xsl:when test="$doc-rule-id = 'CFG-DOC-TRACE'">
                    <xsl:variable name="suppliers" select="imf:get-trace-suppliers-for-construct($this,1)"/>
                    <xsl:variable name="list" as="item()*">
                        <xsl:for-each select="subsequence($suppliers,2)">
                            <item type="TRACELINK">
                                <item type="DISPLAYNAME">
                                    <xsl:value-of select="@display-name"/>
                                </item>
                                <item type="SUBPATH">
                                    <xsl:value-of select="@subpath"/>
                                </item>
                            </item>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:sequence select="imf:create-part-2(.,$list)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="imf:msg($this,'FATAL','No such document rule: [1]',$doc-rule-id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="imf:get-cardinality" as="xs:string"> 
        <xsl:param name="min"/>
        <xsl:param name="max"/>
        <xsl:choose>
            <xsl:when test="$min = $max or empty($max)">
                <xsl:value-of select="$min"/>
            </xsl:when>
            <xsl:when test="$max = 'unbounded'">
                <xsl:value-of select="concat($min, ' .. *')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat($min, ' .. ', $max)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:authentiek-is-derived">
        <xsl:param name="this"/>
        <xsl:if test="imf:get-formatted-tagged-value($this,'derived') = '1'">
            <xsl:value-of select="' (is afgeleid)'"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:create-toelichting">
        <xsl:param name="documentatie"/>
        <xsl:if test="normalize-space($documentatie) and $explanation-location = 'at-bottom'">
            <section type="EXPLANATION">
                <content>
                    <part>
                        <xsl:sequence select="imf:create-element('item',$documentatie)"/>
                    </part>
                </content>
            </section>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:get-relatiesoort">
        <xsl:param name="relatieklasse"/>
        <xsl:variable name="id" select="$relatieklasse/imvert:id"/>
        <xsl:variable name="assoc-class" select="$document-classes//imvert:association-class[imvert:type-id = $id]"/>
        <xsl:variable name="fromclass" select="$assoc-class/ancestor::imvert:class"/>
        <xsl:variable name="assoc" select="$assoc-class/.."/>
        <xsl:value-of select="concat(imf:get-name($fromclass,true()), ' ',imf:get-name($assoc,true()),' ',$assoc/imvert:type-name/@original)"/>
    </xsl:function>
    
    
    <xsl:function name="imf:create-link">
        <xsl:param name="this"/>
        <xsl:param name="type"/>
        <xsl:param name="label"/>
        <!--
            if the link is to an external type, insert catalog reference, otherwise insert a link to this documentation 
        -->
        <xsl:choose>
            <xsl:when test="exists($this/imvert:catalog) ">
                <item type="{$type}">
                    <xsl:sequence select="imf:create-external-idref($this)"/>
                    <xsl:sequence select="imf:create-external-content($label)"/>
                </item>
            </xsl:when>
            <xsl:otherwise>
                <item type="{$type}">
                    <xsl:sequence select="imf:create-idref($this,$type)"/>
                    <xsl:sequence select="imf:create-content($label)"/>
                </item>            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="imf:get-construct-by-id-for-office">
        <xsl:param name="id" as="xs:string?"/>
        <xsl:if test="exists($id)">
            <xsl:sequence select="imf:get-construct-by-id($id)"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="imf:create-element">
        <xsl:param name="name"/>
        <xsl:param name="content"/>
        <xsl:element name="{$name}">
            <xsl:sequence select="imf:create-content($content)"/>
        </xsl:element>
    </xsl:function>
    
    <xsl:function name="imf:create-content">
        <xsl:param name="content"/>
        <xsl:sequence select="if ($content instance of attribute()) then string($content) else $content"/>
    </xsl:function>
    
    <xsl:function name="imf:create-idref">
        <xsl:param name="construct"/>
        <xsl:param name="type"/><!-- global or detail -->
        <xsl:if test="$create-links and exists($construct)">
            <xsl:attribute name="idref" select="imf:plugin-get-link-name($construct,$type)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="imf:create-external-content">
        <xsl:param name="content"/>
        <xsl:sequence select="if ($content instance of attribute()) then string($content) else $content"/>
    </xsl:function>

    <xsl:function name="imf:create-external-idref">
        <xsl:param name="construct"/>
        <xsl:if test="$create-links">
            <xsl:attribute name="idref" select="imf:plugin-get-external-link-name($construct)"/>
            <xsl:attribute name="idref-type" select="'external'"/>
        </xsl:if>
    </xsl:function>
    
    <!-- =========== plugins ============= -->
    
    <!--
         return a translation of the term passed 
    -->
    <xsl:function name="imf:plugin-translate-i3n" as="xs:string?">
        <xsl:param name="key"/>
        <xsl:param name="must-be-known"/>
        <xsl:value-of select="imf:translate-i3n(upper-case($key), $language-model, if ($must-be-known) then () else $key)"/> 
    </xsl:function>
    
    <!-- 
        Verwijder het uppercase gedeelte uit de base type name. 
        Dus Splitsingstekeningreferentie APPARTEMENTSRECHTSPLITSING wordt Splitsingstekeningreferentie.
    -->
    <xsl:function name="imf:plugin-splice" as="xs:string?">
        <xsl:param name="typename"/>
        <xsl:variable name="t" select="normalize-space($typename)"/>
        <xsl:if test="$t">
            <xsl:analyze-string select="$t" regex="^(.*?)\s+?([^a-z]+)$">
                <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:value-of select="$typename"/>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:function>
    
    <!-- 
        return the link name. 
        when doc-rule: link-by is set to EAID, use the ID, else use the formal name. 
    -->
    <xsl:function name="imf:plugin-get-link-name">
        <xsl:param name="this"/>
        <xsl:param name="type"/> <!-- global or detail or graph; when graph always use the EAID -->
        <xsl:variable name="isrole" select="exists($this/self::imvert:target)"/>
        <xsl:variable name="construct" select="if ($isrole) then $this/.. else $this"/>
        <xsl:variable name="link-id" select="if ($type = 'graph' or $link-by-eaid) then $construct/imvert:id else $construct/@formal-name"/>
        <xsl:variable name="link-name" select="if ($link-id) then $link-id else generate-id($construct)"/>
        <xsl:sequence select="concat($type,'_',$link-name)"/>
    </xsl:function>
    
    <xsl:function name="imf:plugin-get-external-link-name">
        <xsl:param name="this"/>
        <xsl:value-of select="$this/imvert:catalog"/>
    </xsl:function>
    
    <!-- 
        return a section name for a model passed as a package 
    -->
    <xsl:function name="imf:plugin-get-model-name">
        <xsl:param name="construct" as="element()"/><!-- imvert:package or imvert:packages -->
        
        <xsl:value-of select="imf:get-name($construct,true())"/>
    </xsl:function>
    
    <xsl:function name="imf:initialize-modeldoc" as="item()*">
        <!-- stub: may be implemented by any modeldoc -->
    </xsl:function>
    
    <!-- geef de naam terug van de construct, en de target naam als het een associatie betreft. -->
    <xsl:function name="imf:get-name" as="xs:string?">
        <xsl:param name="this"/>
        <xsl:param name="original" as="xs:boolean"/>

        <xsl:variable name="isrole" select="exists($this/self::imvert:target)"/>
        
        <xsl:variable name="relation" select="if ($isrole) then $this/.. else $this"/>
        <xsl:variable name="target" select="if ($isrole) then $this else $this/imvert:target"/>
        
        <xsl:variable name="relation-name" select="$relation/imvert:name"/>
        <xsl:variable name="target-name" select="if (not($append-role-name)) then () else $target/imvert:role"/>
        
        <xsl:variable name="construct-name" select="if (exists($relation-name) and exists($target-name)) then concat($relation-name,': ',$target-name) else ($relation-name,$target-name)"/>
        <xsl:variable name="construct-original-name" select="if (exists($relation-name) and exists($target-name)) then concat($relation-name/@original,': ',$target-name/@original) else ($relation-name/@original,$target-name/@original)"/>
        <xsl:variable name="name">
            <xsl:choose>
                <xsl:when test="$original">
                    <xsl:value-of select="$construct-original-name"/>                
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$construct-name"/>                
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="normalize-space($name)">
                <xsl:value-of select="$name"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="imf:msg($this,'ERROR','Cannot determine the name of this construct',())"/>
            </xsl:otherwise>
        </xsl:choose>  
    </xsl:function>
    
    <xsl:function name="imf:get-tv-value">
        <xsl:param name="tv-element" as="element(tv)?"/>
        <xsl:value-of select="if (normalize-space($tv-element/@original-value)) then $tv-element/@original-value else $tv-element/@value"/>
    </xsl:function>
    
    <xsl:function name="imf:create-section-for-diagrams">
        <xsl:param name="construct"/> <!-- either the packages (=model) or a package or a class -->
        
        <xsl:variable name="insert-diagrams" select="imf:boolean(imf:get-config-string('cli','createimagemap'))"/> <!-- TODO dit moet beter, eiegnlijk een parameter in modeldoc config -->
        <xsl:variable name="diagrams-in-construct" select="$imagemap/imvert-imap:diagram[(imvert-imap:in-construct,imvert-imap:in-package)[1] = $construct/imvert:id]"/>
        <xsl:choose>
            <xsl:when test="$insert-diagrams and exists($diagrams-in-construct)">
                <section type="IMAGEMAPS" name="{imf:plugin-get-model-name($construct)}-imagemap" id="{imf:plugin-get-link-name($construct,'imagemap')}">
                    <xsl:for-each select="$diagrams-in-construct">
                        <xsl:if test="exists(imvert-imap:purpose)">
                            <section type="IMAGEMAP" name="{imvert-imap:name}" id="{imvert-imap:id}">
                                <content>
                                    <part type="CFG-DOC-NAAM">
                                        <item>
                                            <xsl:value-of select="imf:plugin-translate-i3n('DIAGRAM-NAME',true())"/>
                                        </item>
                                        <item><xsl:value-of select="imvert-imap:name"/></item>
                                    </part>
                                    <part type="CFG-DOC-DESCRIPTION">
                                        <item>
                                            <xsl:value-of select="imf:plugin-translate-i3n('DIAGRAM-DESCRIPTION',true())"/>
                                        </item>
                                        <item><xsl:value-of select="imvert-imap:documentation"/></item>
                                    </part>
                                </content>
                            </section>    
                        </xsl:if>
                    </xsl:for-each>
                </section>
            </xsl:when>
            <xsl:otherwise>
                <!-- no alternatives -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- ======== cleanup all section structure: remove empties =========== -->
    
    <xsl:template match="section" mode="section-cleanup">
        <xsl:choose>
            <xsl:when test="exists(.//item)">
                <xsl:next-match/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:comment>removed empty content</xsl:comment>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="node()|@*" mode="section-cleanup">
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="section-cleanup"/>
            <xsl:apply-templates select="node()" mode="section-cleanup"/>
        </xsl:copy>
    </xsl:template>    
    
    
</xsl:stylesheet>
