********************************************************************************
Copyright Since 2005 ColdBox Framework by Luis Majano and Ortus Solutions, Corp
www.coldbox.org | www.luismajano.com | www.ortussolutions.com
********************************************************************************

Author     :	Luis Majano
Description :
	This interceptor reads and stores a _deploy.tag file to check
	for new deployments. If the tag has been updated, the interceptor
	tells the framework to reinitialize itself.  This is done via date comparison.
	Once the framework starts up, it reads the date timestamp on the tag
	and saves it on memory.
	
	You can use the included ANT script to touch the file with a new
	timestamp. Then just make sure you include the file in your deploy
	
============================================================
ChangeLog
============================================================

== Version 3.0 =
# Upgraded for CF9.01 and above
# Upgraded to use applicationstop() instead.

== Version 2.0 ==
# Moved to ForgeBox

== Version 1.0 ==
# Initial Release

============================================================
Instructions:
============================================================
- Place the _deploy.tag and deploy.xml ANT task in your /config directory of your application.
- Add the Deploy interceptor declaration

interceptors = [
	{class="#pathTo#.Deploy",
	 properties={
	 	tagFile = "config/_deploy.tag",
	 	deployCommandObject = "path.to.cfcCommand", 
	 	deployCommandModel = "model via wirebox"
	 }
	}
];
============================================================
Interceptor Properties:
============================================================
- tagFile : config/_deploy.tag [required] The location of the tag.
- deployCommandObject : The class path of the deploy command object to use [optional]. 
- deployCommandModel : The name of the model object to retrieve via WireBox [optional].

This command object is a CFC that must implement an init(controller) method and an execute() method.  
This command object will be executed before the framework reinit bit is set so you can do
any kind of cleanup code or anything you like:

============================================================
Command Object Interface
============================================================
component{

	init(controller){}
	
	execute(){}

}

============================================================
Command Model Object Interface
============================================================
component{

	execute(){}

}

