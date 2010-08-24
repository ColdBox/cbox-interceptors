/**
* @Author Aaron Greenlee | www.aarongreenlee.com
* @Date 2009-12-29
* @hint Interceptor which creates a setting of reserved routes. Useful when building applications that use routes like facebook.com/aarongreenlee
**/

/*
Added ReservedRoutes interceptor which is useful for extracting a list of reserved strings which appear in the first position of routes.
Example: www.facebook.com/about
In the above example 'about' would become a reserved word which you can compare. So, new users to facebook.com could not choose a username of 'about'.
*/

component extends="coldbox.system.Interceptor" output="false"{

	variables.instance.reserved = 'handler,action,view,viewNoLayout,constraints,pattern,regexpattern,matchVariables,packageresolverexempt,patternParams,valuePairTranslation';
	variables.instance.SESKey = 'cboxinterceptor_interceptor-ses';

	void function configure() output=false{

		// Allow a configuration property to change the name of the SES key in the ColdBox OCM
		if ( propertyExists('key') )
			variables.instance.SESKey = getProperty('key');

		if ( propertyExists('custom') )
			variables.instance.reserved = variables.instance.reserved & "," & getProperty('custom');
	}

	void function afterAspectsLoad(event,interceptData) output=false{
		var rc = event.getCollection();
		var LOCAL = structNew();

		if ( NOT getColdBoxOCM().lookup(variables.instance.SESKey) )
			$throw(message='SES Interceptor Not Cached',detail='The ReserveRoutes interceptor must be called after the SES Interceptor.',type='interceptors.ReserveRoutes');

		LOCAL.SES = getColdBoxOCM().get(variables.instance.SESKey);

		extractReservedStrings(LOCAL.SES);
	}

	/* PRIVATE */

	private void function extractReservedStrings (required SES) {
		var LOCAL 				= structNew();
		var reserved 			= variables.instance.reserved;
		var activeRoute 		= {};
		var pattern 			= '';
		var patternToReserve 	= '';
		var i					= 0;
		var routes				= arguments.SES.getRoutes();
		var SlashPos			= 0;

		// Loop over routes
		for (i=1; i LTE arrayLen(routes); i = i + 1) {
			activeRoute = routes[i];

			if ( structKeyExists(activeRoute, 'pattern') ) {
				pattern = activeRoute.pattern;

				if ( left(pattern, 1) NEQ ':' ) {
					patternToReserve = '';

					SlashPos = FindOneOf('/', pattern);
					if (NOT SlashPos)
						/* No slash delim found, save entire string */
						patternToReserve = pattern;
					else
						/* Save first index in string */
						patternToReserve = ListGetAt(pattern, 1, '/');

					// Append to our reserved list only if an exact value does not exist
					if ( NOT listContainsNoCase(reserved, patternToReserve, ',') )
						reserved = listAppend(reserved, patternToReserve, ',');
				}
			}
		}
		// Persist in the ColdBox Settings Struct
		setSetting('ReservedRoutes', reserved);
	}
}
