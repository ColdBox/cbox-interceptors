<!--- 
	Copyright 2009 Ernst van der Linden, Paul Marcotte
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
	
	Based on the ssl interceptor originally developed by Ernst van der Linden 
	(http://evdlinden.behindthe.net/index.cfm/2008/1/22/ColdBox-SSL-Interceptor-2--SSL-for-specific-events-only) 

	2009-03-05 - New

 --->
<cfcomponent name="ssl" output="false" extends="coldbox.system.interceptor">
	
	<!--- public --->

	<cffunction name="configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<!--- I set up myself --->
		<cfset setProperty('ConfigurationTime', now() )>
	</cffunction>
	
	<cffunction name="preEvent" hint="Invokes checkSSL when required and not framework reload." access="public" returntype="void" output="false" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
	       
		<cfscript>
			if (getProperty('checkSSL') && (!event.valueExists("fwreinit"))) {
				checkSSL(event);
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="postProcess" hint="Invokes checkSSL when required after framework reload." access="public" returntype="void" output="false" >
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
		<cfargument name="interceptData" required="true" type="struct" hint="A structure containing intercepted information. NONE BY DEFAULT HERE">
	       
		<cfscript>
			if(getProperty('checkSSL') && (event.valueExists("fwreinit"))) {
				checkSSL(event);
			}
		</cfscript>
	</cffunction>
	
	<!--- private --->
	
	<cffunction name="checkSSL" hint="Determines whether to redirect to https or http." access="private" returntype="void" output="false" >
	       <cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
	       
		<cfscript>
			if ((!isSSLRequest()) && (isSSLRequired(event))) {
				redirect(event: event, useSSL:true, addToken: getProperty('addToken'));
			} else if ((isSSLRequest()) && (!isSSLRequired(event))) {
				redirect(event: event, useSSL:false, addToken: getProperty('addToken'));
			}
		</cfscript>
	</cffunction>
	
	<cffunction name="isSSLRequest" hint="Returns boolean result whether current request is ssl." access="private" returntype="boolean">
	       
		<cfscript>
			var isSSLRequest = false;
			if (isBoolean(cgi.server_port_secure) && cgi.server_port_secure) {
				isSSLRequest = true;
			}
			return isSSLRequest;
		</cfscript>
	</cffunction>
	       
	<cffunction name="isSSLRequired" hint="Returns boolean for ssl required." access="private" returntype="boolean" output="false">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
	       
	   	<cfscript>
			var isSSLRequired = false;
			if (REFind(getProperty('pattern'),event.getCurrentEvent())) {
				isSSLRequired = true;
			}
			return isSSLRequired;
		</cfscript>
	</cffunction>
 
	<cffunction name="redirect" hint="A cflocation facade method" returntype="void" output="false" access="private">
		<cfargument name="event" required="true" type="coldbox.system.beans.requestContext">
        <cfargument name="useSSL" hint="Use https protocol?" required="yes" type="boolean" />
		<cfargument name="addToken" required="false" type="boolean" default="no">
		<cfscript>
			var url = "";
			var eventName = event.getCurrentEvent();
			url = event.buildLink(linkto: eventName, ssl: useSSL);
		</cfscript>		
		<cflocation url="#url#" addtoken="#addToken#" />
	</cffunction>
           
</cfcomponent>