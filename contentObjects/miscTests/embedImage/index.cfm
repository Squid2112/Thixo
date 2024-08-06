<cfscript>
	writeOutput('<img alt src="data:image/*;base64,' & toBase64(fileReadBinary(Application.Settings.rootPath & 'assets\img\backswing.jpg'),'utf-8') & '">');
</cfscript>

<!---
*** this is one method to output ANY binary MIME type to the browser once ***
*** we detect a media object, forgo everything else and output this way   ***
<cffile action="readbinary" file="#expandPath('/')#assets/img/thixo.png" variable="pic"/>
<cfsavecontent variable="testImage1">
	<cfcontent type="image/jpeg; charset=8859_1">
	<cfoutput>#toString(pic)#</cfoutput>
</cfsavecontent>
<cfoutput>#testImage1#</cfoutput>
--->

<!---
*** This is another way to output images, but it more limited ***
<cfset imgFile = "#expandPath('/')#assets/img/thixo.png">
<cfoutput>#uCase(listLast(imgFile,'.'))#</cfoutput>
<cfimage action="writetobrowser" source="#imgFile#" format="#uCase(listLast(imgFile,'.'))#">
--->