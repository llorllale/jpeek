<?xml version="1.0"?>
<!--
The MIT License (MIT)

Copyright (c) 2017-2018 Yegor Bugayenko

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:math="http://www.w3.org/2005/xpath-functions/math" version="3.0">
  <xsl:template match="skeleton">
    <metric>
      <xsl:apply-templates select="@*"/>
      <title>LCSM</title>
      <description>
        <xsl:text>
          
        </xsl:text>
      </description>
      <xsl:apply-templates select="node()"/>
    </metric>
  </xsl:template>
  <xsl:template match="class">
    <xsl:variable name="M" select="methods/method"/>
    <xsl:variable name="corpus">
      <xsl:for-each select="$M">
        <document>
          <xsl:for-each select="ops/op">
            <word>
              <xsl:value-of select="."/>
            </word>
          </xsl:for-each>
        </document>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="terms" select="distinct-values($corpus//word)"/>
    <!--
    @todo #16:30min rank lowering
    -->
    <xsl:variable name="X">
      <xsl:for-each select="$corpus/document">
        <xsl:variable name="doc" select="."/>
        <document>
          <xsl:for-each select="$terms">
            <xsl:variable name="term" select="."/>
            <xsl:variable name="tf" select="1 + math:log10(count($doc/word[. = $term]))"/>
            <xsl:variable name="idf" select="math:log10(1 + (count($corpus/document) div count($doc/word[. = $term])))"/>
            <xsl:variable name="tf-idf" select="$td * $idf"/>
            <term>
              <xsl:value-of select="$tf-idf"/>
            </term>
          </xsl:for-each>
        </document>
      </xsl:for-each>
    </xsl:variable>
    <xsl:copy>
      <xsl:attribute name="value">
        <xsl:choose>
          <xsl:when test="$nonempty &gt; $empty">
            <xsl:text>0</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$empty - $nonempty"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="@*"/>
      <vars>
        <var id="methods">
          <xsl:value-of select="count($methods)"/>
        </var>
        <var id="pairs">
          <xsl:value-of select="count($pairs/pair)"/>
        </var>
        <var id="empty">
          <xsl:value-of select="$empty"/>
        </var>
        <var id="nonempty">
          <xsl:value-of select="$nonempty"/>
        </var>
      </vars>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
