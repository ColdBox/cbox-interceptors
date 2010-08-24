Authors: Ernst van der Linden, Paul Marcotte

Date	2009-03-05

Based on the ssl interceptor originally developed by Ernst van der Linden 
(http://evdlinden.behindthe.net/index.cfm/2008/1/22/ColdBox-SSL-Interceptor-2--SSL-for-specific-events-only) 

This version of the ssl interceptor uses regular expressions for event pattern matches
and will preserve SES urls by leveraging event.buildLink().  Some small changes to the
configuration setup are required.  See notes below.

Configuration:

Add the following interceptor configuration to you coldbox config.

	<Interceptor class="interceptors.ssl">
	  	<Property name="checkSSL">true</Property>
	    <Property name="pattern">.*</Property> <!-- secure all -->
		<Property name="addToken">false</Property>
	</Interceptor>

Properties:

	checkSSL (boolean) - check the current request is https.

	pattern (regex) - a regex pattern for events that must use ssl
	examples:  .*  - all events
				^admin - all events beginning with "admin"
	addToken (boolean) - use addToken with cflocation