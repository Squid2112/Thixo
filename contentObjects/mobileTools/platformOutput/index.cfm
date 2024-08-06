<cfscript>
	writeOutput('Browser Platform: ');
	Application.System.isMobile(cgi=cgi) ? writeOutput('Mobile<br />') : writeOutput('Desktop<br />');
	dt = Application.System.getDeviceType(cgi=cgi);
	writeOutput(cgi.HTTP_USER_AGENT & '<p />');
</cfscript>