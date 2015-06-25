<!-----------------------------------------------------------------------
Author 	 :	Luis Majano
Date     :	11/21/2009
Description : 			
 Gives you ability to host the same app on multiple domains using ses

Modified: Yuliang Ruan
Date:	6/25/2015
Description:
	use the original SES base URL as template and only replace the domain name section.   
	preserve whatever pathing, custom index.cfm landing page pattern name is used.  as well as http vs https
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
			var origBase=arguments.event.getSESbaseURL();
			//this splits URL into multiple sections.  we want to replace the domain name middle section.  preserving everything else
			var splitted=ListToArray(origBase,"/",1);
			splitted[3]=cgi.http_host;
			var newBase=ArrayToList(splitted,"/");
			arguments.event.setSESBaseURL(newBase);
		
		</cfscript>
	</cffunction>

<!------------------------------------------- PRIVATE ------------------------------------------->	 	


</cfcomponent>
