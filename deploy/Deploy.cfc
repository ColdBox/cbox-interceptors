﻿<!-----------------------------------------------------------------------
********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Date        :	01/15/2008
Description :
	This interceptor reads and stores a _deploy.tag file to check
	for new deployments. If the tag has been udpated, the interceptor
	tells the framework to reinitialize itself.  This is done via date comparison.
	Once the framework starts up, it reads the datetimestamp on the tag
	and saves it on memory.
	
	You can use the included ANT script to touch the file with a new
	timestamp. Then just make sure you include the file in your deploy
	
Instructions:

- Place the _deploy.tag and deploy.xml ANT task in your /config directory of your application.
- Add the Deploy interceptor declaration

interceptors = [
	{ class="path.to.Deploy", properties={
		tagFile = "config/_deploy.tag",
		deployCommandModel = "DeployCommand"
	}}
];

Interceptor Properties:

- tagFile : config/_deploy.tag [required] The location of the tag.
- deployCommandObject : The class path of the deploy command object to use [optional]. 
- deployCommandModel: The WireBox ID or full path to a object to use as your command object

If using the deployCommandObject setting then this object is a CFC that must implement an init(controller) method
and an execute() method.  If using the deployCommandModel then it must implement a execute() method only.
  
This command object will be executed before the framework reinit bit is set so you can do
any kind of cleanup code or anything you like:

<cfcomponent name="DeployCommand" output="false">
	<cffunction name="init" access="public" returntype="any" hint="Constructor" output="false" >
		<cfargument name="controller" required="true" type="coldbox.system.web.Controller" hint="The coldbox controller">
		<cfset instance = structnew()>
		<cfset instance.controller = arguments.controller>
	</cffunction>
	
	<cffunction name="execute" access="public" returntype="void" hint="Execute Command" output="false" >
		<cfscript>
			Do your cleanup code or whatever you want here.
		</cfscript>
	</cffunction>
</cfcomponent>
	
----------------------------------------------------------------------->
<cfcomponent hint="Deployment Control Interceptor" extends="coldbox.system.Interceptor" output="false">
	

<!------------------------------------------- CONSTRUCTOR ------------------------------------------->

	<!--- Configure --->
	<cffunction name="configure" access="public" returntype="void" output="false" hint="My configuration method">
		<cfscript>
			// Private Properties
			instance.tagFilepath 		 = "";
			instance.deployCommandObject = "";
			
			// Verify the properties
			if( not propertyExists('tagFile') ){
				$throw('The tagFile property has not been defined. Please define it.','','Deploy.tagFilePropertyNotDefined');
			}
			
			// Try to locate the path
			instance.tagFilepath = locateFilePath( getProperty('tagFile') );
			
			// Validate it
			if( len(instance.tagFilepath) eq 0 ){
				$throw('Tag file not found: #getProperty('tagFile')#. Please check again.','','interceptors.Deploy.tagFileNotFound');
			}
			
			// Save TimeStamp
			setSetting("_deploytagTimestamp", fileLastModified(instance.tagFilepath) );
			
			// Check for a deploy command object
			if( propertyExists('deployCommandObject') ){
				try{
					instance.deployCommandObject = createObject("component",getProperty('deployCommandObject')).init(controller);
				}
				catch(Any e){
					$throw("Error creating command object #getProperty('deployCommandObject')#",
						   e.detail & e.message & e.stacktrace,
						   "Deploy.CommandObjectCreationException");
				}
			}
			
			// Deploy Command Model
			if( propertyExists('deployCommandModel') ){
				instance.deployCommandObject = getModel(getProperty("deployCommandModel"));
			}
		</cfscript>
	</cffunction>

<!------------------------------------------- PUBLIC ------------------------------------------->

	<!--- afterAspectsLoad --->
	<cffunction name="afterAspectsLoad" output="false" access="public" returntype="void">
		<!--- ************************************************************* --->
		<cfargument name="event">
		<cfargument name="interceptData">
		<!--- ************************************************************* --->
		<cfscript>
			if( log.canInfo() ){
				log.info("Deploy tag registered successfully.");
			}
		</cfscript>	
	</cffunction>

	<!--- postProcess --->
	<cffunction name="postProcess" output="false" access="public" returntype="void" hint="Check if a deploy has been made">
		<!--- ************************************************************* --->
		<cfargument name="event">
		<cfargument name="interceptData">
		<!--- ************************************************************* --->
		<cfset var applicationTimestamp = "">
		<cfset var fileTimestamp 		= fileLastModified(instance.tagFilepath)>
		
		<!--- Check if setting exists --->
		<cfif settingExists("_deploytagTimestamp")>
			<!--- Get setting --->
			<cfset applicationTimestamp = getSetting("_deploytagTimestamp")>
			<!--- Validate Timestamp --->
			<cfif dateCompare(fileTimestamp, applicationTimestamp) eq 1>
				<cflock scope="application" type="exclusive" timeout="25">
				<cfscript>
					//Extra if statement for concurrency
					if ( dateCompare(fileTimestamp, applicationTimestamp) eq 1 ){
						try{
							
							// cleanup command
							if( isObject(instance.deployCommandObject) ){
								instance.deployCommandObject.execute();
							}
							
							// Reload Application
							applicationStop();
							
							// Log Reloading
							if( log.canInfo() ){
								log.info("Deploy tag reloaded successfully.");
							}
						}
						catch(Any e){
							//Log Error
							log.error("Error in deploy tag: #e.message# #e.detail#",e.stackTrace);
						}
					}
				</cfscript>
				</cflock>
			</cfif>
		<cfelse>
			<cfset configure()>
		</cfif>
	</cffunction>
		 
<!------------------------------------------- PRIVATE ------------------------------------------->
	
	<!--- fileLastModified --->
	<cffunction name="fileLastModified" access="private" returntype="string" output="false" hint="Get the last modified date of a file">
		<!--- ************************************************************* --->
		<cfargument name="filename" type="string" required="yes">
		<!--- ************************************************************* --->
		<cfscript>
		var objFile =  createObject("java","java.io.File").init(JavaCast("string",arguments.filename));
		// Calculate adjustments fot timezone and daylightsavindtime
		var Offset = ((GetTimeZoneInfo().utcHourOffset)+1)*-3600;
		// Date is returned as number of seconds since 1-1-1970
		return DateAdd('s', (Round(objFile.lastModified()/1000))+Offset, CreateDateTime(1970, 1, 1, 0, 0, 0));
		</cfscript>
	</cffunction>
	
</cfcomponent>