<div style="height:20px;"></div>
<div id="switch" class="switch"><div class="switchOff"></div></div>
<a id="viewerPlaceHolder" style="width:968px;height:650px;display:none;"></a>

<!---sixth sense: <a href="http://www.ted.com/index.php/talks/pattie_maes_demos_the_sixth_sense.html">http://www.ted.com/index.php/talks/pattie_maes_demos_the_sixth_sense.html</a>--->

<p>
	Work is shaping up nicely, "Liberty", the new advanced ColdFusion framework,<br />
	is nearing completion and is being prepared for release.
</p>

<p />
<cfscript>
	Application.Content.object(request=Request,name='mobileTools/platformOutput');
	Application.Content.object(request=Request,name='geoTools/geoInfo');

/*
	vdb = createObject('component','com.database.VisitorCRUD').init();
	meta = vdb.set(Visitor=Session.Visitor,Request=Request);
	writeDump(meta);

	q = new Query();
	q.setDatasource('thixo');
	q.setName('Visitor');
	result = q.execute(sql='SELECT * FROM VisitorDetail');

	metaInfo = result.getPrefix();
	record = result.getResult();
	writeDump(result);
	writeDump(metaInfo);
*/

// writeDump(hash('frisbee','SHA-256'));  // create password
/*
	manifest = fileRead(Application.Settings.rootPath & 'com\Manifests\VirtualMapping.manifest.json');
	mappings = Application.System.jsonDecode(manifest);
	writeDump(mappings);	

writeDump(structFindValue(mappings,'Tests'));
*/
/*
	omniture = fileRead(expandPath('/') & 'omniture.xml');
//fileWrite(expandPath('/') & 'omniture.xml',omniture);
	omniture = xmlParse(omniture);
writeOutput('[ PackageId ]');
	writeDump(xmlSearch(omniture,"/Root/Result/result/sets/xinfonSet[@nm='products']/e[*]/xinfon/Products/PROD_ID"));

writeOutput('[ Related Products ]');
	writeDump(xmlSearch(omniture,"/Root/Result/result/sets/xinfonSet[@nm='related_products']/e[*]/xinfon/Products/PROD_ID"));

writeOutput('[ Related Documents ]');
	writeDump(xmlSearch(omniture,"/Root/Result/result/sets/xinfonSet[@nm='related_documents']/e[*]/xinfon/Products/PROD_ID"));

writeOutput('[ Banners Top ]<br>');
	banners_top = xmlSearch(omniture,"/Root/Result/result/sets/valueSet[@nm='CMC_banners_top']/e/value/text()");
	for(i=1; i LTE arrayLen(banners_top); i++) writeOutput('[#i#] <xmp>' & banners_top[i].xmlValue & '</xmp>');

writeOutput('[ Banners Side ]<br>');
	banners_side = xmlSearch(omniture,"/Root/Result/result/sets/valueSet[@nm='CMC_banners_side']/e/value/text()");
	for(i=1; i LTE arrayLen(banners_side); i++) writeOutput('[#i#] <xmp>' & banners_side[i].xmlValue & '</xmp>');

writeOutput('[ Banners Bottom ]<br>');
	banners_bottom = xmlSearch(omniture,"/Root/Result/result/sets/valueSet[@nm='CMC_banners_bottom']/e/value/text()");
	for(i=1; i LTE arrayLen(banners_bottom); i++) writeOutput('[#i#] <xmp>' & banners_bottom[i].xmlValue & '</xmp>');

//omniture.find('//*').flattenCompoundCollection(omniture.get());
*/
</cfscript>