<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	11/21/2009
Description : 			
 Gives you ability to host the same app on multiple domains using ses
		
----------------------------------------------------------------------->
<cfcomponent hint="Gives you ability to host the same app on multiple domains using ses" 
			 extends="coldbox.system.Interceptor" 
			 output="false">
  
<!------------------------------------------- PUBLIC ------------------------------------------->	 	

	<cffunction name="preProcess" access="public" returntype="void" hint="Executes before any event execution occurs" output="false" >
		<cfargument name="event">
		<cfargument name="interceptData">
		<cfscript>
		
			// set the base URL according to domain or whatever strategy you like.
			arguments.event.setSESBaseURL("http://" & cgi.http_host & "/index.cfm");
		
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->	 	


</cfcomponent>