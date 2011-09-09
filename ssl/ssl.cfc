<!--- 
	Based on the SSL interceptor originally developed by Ernst van der Linden 
	(http://evdlinden.behindthe.net/index.cfm/2008/1/22/ColdBox-SSL-Interceptor-2--SSL-for-specific-events-only) 

	Copyright 2009 Ernst van der Linden, Paul Marcotte, Luis Majano
	
	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at
	
		http://www.apache.org/licenses/LICENSE-2.0
	
	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.	
--->
<cfcomponent output="false" extends="coldbox.system.Interceptor" hint="Checks incoming event patterns for SSL requirements or NOT.">
	
	<!--- public --->
	<cffunction name="configure" access="public" returntype="void" hint="This is the configuration method for your interceptors" output="false" >
		<cfscript>
			// check ssl enablement on by default
			if( NOT propertyExists("checkSSL") ){
				setProperty("checkSSL", true);
			}
			// check custom pattern, else use default
			if( NOT propertyExists("pattern") ){
				setProperty("pattern", ".*");
			}
			
			// set configuration time
			setProperty('ConfigurationTime', now() );
		</cfscript>
	</cffunction>
	
	<!--- preprocess --->
	<cffunction name="preProcess" hint="Invokes checkSSL when required and not framework reload." access="public" returntype="void" output="false" >
		<cfargument name="event">
		<cfargument name="interceptData">
	    <cfscript>
			if (getProperty('checkSSL') && (!event.valueExists("fwreinit"))) {
				checkSSL(event);
			}
		</cfscript>
	</cffunction>
	
	<!--- private --->
	<cffunction name="checkSSL" hint="Determines whether to redirect to https or http." access="private" returntype="void" output="false" >
	    <cfargument name="event">
	    <cfscript>
			var isSSL = event.isSSL();
			
			// check if SSL request and SSL Required
			if( !isSSL && isSSLRequired(event) ){
				setNextEvent(uri=cgi.script_name & cgi.path_info,ssl=true,statusCode=302,queryString=cgi.query_string);
			} 
			// Check if in SSL and NO SSL Required
			else if( isSSL && !isSSLRequired(event) ){
				setNextEvent(uri=cgi.script_name & cgi.path_info,ssl=false,statusCode=302,queryString=cgi.query_string);
			}
		</cfscript>
	</cffunction>

	<!--- isSSLRequired --->
	<cffunction name="isSSLRequired" hint="Returns boolean for ssl required." access="private" returntype="boolean" output="false">
		<cfargument name="event">
	    <cfscript>
			var isSSLRequired 	= false;
			var pattern 		= getProperty('pattern');
			var i 				= 0;
			var cEvent			= event.getCurrentEvent();
			
			// check in pattern list
			for(i=1; i lte listLen(pattern); i++){
				if ( reFindNoCase(listGetAt(pattern,i), cEvent) ){
					isSSLRequired = true;
					break;
				}
			}
			return isSSLRequired;
		</cfscript>
	</cffunction>
            
</cfcomponent>