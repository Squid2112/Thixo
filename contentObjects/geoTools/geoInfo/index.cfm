<cfscript>
	geoCRUD = createObject('component','com.System.GeoInfoObject').init('Global');
	test = geoCRUD.getByIp(ip='75.145.55.90',getALL=false);
	test2 = geoCRUD.getByZipcode(zipcode=test.zipcode[1],getAll=true);
	//writeDump(test);
	//writeDump(test2);
	
	if(test.recordCount) {
		writeOutput('City: ' & test.city[1] & '<br />');
		writeOutput('State: ' & test.state[1] & '<br />');
		writeOutput('Area Code: ' & test.areaCode[1] & '<br />');
		writeOutput('Zip Code: ' & test.zipCode[1] & '<br />');
		writeOutput('County: ' & test2.countyName[1] & '<br />');
		writeOutput('Time Zone: ' & test2.timeZone[1] & '<br />');
		writeOutput('City Latitude: ' & test2.city_Latitude[1] & '<br />');
		writeOutput('City Longitude: ' & test2.city_Longitude[1] & '<br />');
		writeOutput('Googlemap: <a href="http://maps.google.com/?ll=' & test2.city_Latitude[1] & ',' & test2.city_Longitude[1] & '&spn=0.461877,1.028595&z=13" target="_blank">City Level</a><br />');
		writeOutput('State Latitude: ' & test2.state_Latitude[1] & '<br />');
		writeOutput('State Longitude: ' & test2.state_Longitude[1] & '<br />');
		writeOutput('Googlemap: <a href="http://maps.google.com/?ll=' & test2.state_Latitude[1] & ',' & test2.state_Longitude[1] & '&spn=0.461877,1.028595&z=7" target="_blank">State Level</a><br />');
	}

/*
	writeOutput('Browser Platform: ');
	Application.System.isMobile(cgi=cgi) ? writeOutput('Mobile<br />') : writeOutput('Desktop<br />');
	dt = Application.System.getDeviceType(cgi=cgi);
	writeOutput(cgi.HTTP_USER_AGENT & '<p />');
*/

</cfscript>