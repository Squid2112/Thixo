component displayname='CoreSystemObjectComponent' hint='Core System Object Component' output='false' {

	public any function init(string dsn=Application.Settings.DSN.System) output='false' {
		var manifest = '';
		var item = '';

		this.Wrappers = createObject('component','com.System.WrappersComponent').init();

		this.DSN = Arguments.DSN;
		this.dsnValid = this.dsnExists(this.DSN);

		this.Objects = {
			Application = arrayNew(1),
			Session = arrayNew(1),
			Request = arrayNew(1)
		};

		this.coreFramework = {
			Start = { content = '', cache = true },
			End = { content = '', cache = true }
		};

		this.baseFramework = {
			Start = { content = '', cache = true },
			End = { content = '', cache = true }
		};

		this.virtualMappings = arrayNew(1);
		if(fileExists(Application.Settings.rootPath & 'com\Manifests\VirtualMappings.manifest.json')) {
			manifest = fileRead(Application.Settings.rootPath & 'com\Manifests\VirtualMappings.manifest.json');
			this.virtualMappings = duplicate(this.jsonDecode(manifest));
			if(!isArray(this.virtualMappings)) this.virtualMappings = arrayNew(1);
		}

		this.coreJS = arrayNew(1);
		if(fileExists(Application.Settings.rootPath & 'com\Manifests\Core.JavaScripts.manifest.json')) {
			manifest = fileRead(Application.Settings.rootPath & 'com\Manifests\Core.JavaScripts.manifest.json');
			this.coreJS = duplicate(this.jsonDecode(manifest));
			if(!isArray(this.coreJS)) this.coreJS = arrayNew(1);
		}

		this.coreCSS = arrayNew(1);
		if(fileExists(Application.Settings.rootPath & 'com\Manifests\Core.Styles.manifest.json')) {
			manifest = fileRead(Application.Settings.rootPath & 'com\Manifests\Core.Styles.manifest.json');
			this.coreCSS = duplicate(this.jsonDecode(manifest));
			if(!isArray(this.coreCSS)) this.coreCSS = arrayNew(1);
		}

		if(fileExists(Application.Settings.rootPath & 'com\Manifests\Application.manifest.json')) {
			manifest = fileRead(Application.Settings.rootPath & 'com\Manifests\Application.manifest.json');
			this.Objects.Application = duplicate(this.jsonDecode(manifest));
			if(!isArray(this.Objects.Application)) this.Objects.Application = arrayNew(1);
		}

		if(fileExists(Application.Settings.rootPath & 'com\Manifests\Session.manifest.json')) {
			manifest = fileRead(Application.Settings.rootPath & 'com\Manifests\Session.manifest.json');
			this.Objects.Session = duplicate(this.jsonDecode(manifest));
			if(!isArray(this.Objects.Session)) this.Objects.Session = arrayNew(1);
		}

		if(fileExists(Application.Settings.rootPath & 'com\Manifests\Request.manifest.json')) {
			manifest = fileRead(Application.Settings.rootPath & 'com\Manifests\Request.manifest.json');
			this.Objects.Request = duplicate(this.jsonDecode(manifest));
			if(!isArray(this.Objects.Request)) this.Objects.Request = arrayNew(1);
		}

		this.coreFrameworks = structNew();
		if(fileExists(Application.Settings.rootPath & 'com\Manifests\Core.Frameworks.manifest.json')) {
			manifest = fileRead(Application.Settings.rootPath & 'com\Manifests\Core.Frameworks.manifest.json');
			this.coreFrameworks = duplicate(this.jsonDecode(manifest));
			if(!structKeyExists(this,'coreFrameworks')) this.coreFrameworks = structNew();
		}
		for(item IN this.coreFrameworks) {
			this.coreFrameworks[item].coreFramework = { start = '', end = '' };
			this.coreFrameworks[item].baseFramework = { start = '', end = '' };
		}

		if(fileExists(Application.Settings.rootPath & 'com\Manifests\mobileIdentifiers.manifest.json')) {
			manifest = fileRead(Application.Settings.rootPath & 'com\Manifests\mobileIdentifiers.manifest.json');
			Application.Settings.mobileIdentifiers = duplicate(this.jsonDecode(manifest));
			Application.Settings.mobileFullCheck = arrayToList(Application.Settings.mobileIdentifiers.fullCheck,'|');
			Application.Settings.mobileFourCheck = arrayToList(Application.Settings.mobileIdentifiers.fourCheck,'|');
		}

		return(this);
	}

	public array function parseConicals(required string rootDomain, required string requestHost) output='false' {
		return(listToArray(replaceNoCase(Arguments.requestHost,Arguments.rootDomain,'','ALL'),'.',false));
	}

	public string function parse404(required any request, required any url, required string queryString) output='false' {
		var fullPath = '/' & listFirst(listRest(listRest(Arguments.queryString, '//'), '/'), '?');
		var tParam = '';
		var item = '';
		var tmp = '';
		var virt = '';
		var virtS = 0;
		var virtW = 0;
		var virtRest = '';

/*
		tmp = replaceNoCase(fullPath,'-Where-','|');
		virt = replaceNoCase(fullPath,'-Sort-By-','@');
		virtW = find('|',tmp);
		virtS = find('@',virt);
		if(virtW && virtS) {
			if(virtW < virtS) {
				fullPath = listFirst(tmp,'|');
				virtRest = listRest(tmp,'|');
			} else {
				fullPath = listFirst(virt,'@');
				virtRest = listRest(virt,'@');
			}
		} else {
			if(virtW) {
				fullPath = listFirst(tmp,'|');
				virtRest = listRest(tmp,'|');
			} else if(virtS) {
				fullPath = listFirst(virt,'@');
				virtRest = listRest(virt,'@');
			}
		}

		arrayAppend(Arguments.Request.vArray,trim(replace(fullPath,'/','')));

		if(trim(virtRest) != '') {
			if(virtS) {
				if(virtW) {
					virtRest = replaceNoCase(virtRest,'-Sort-By-','@');
					arrayAppend(Arguments.Request.vArray,listFirst(virtRest,'@'));
					arrayAppend(Arguments.Request.vArray,'@' & listRest(virtRest,'@'));
				} else {
					arrayAppend(Arguments.Request.vArray,'@' & virtRest);
				}
			} else if(virtW) {
				arrayAppend(Arguments.Request.vArray,virtRest);
			}
		}
*/

		fullPath = urlDecode(fullPath);
		Arguments.Request.queryString = Arguments.queryString;
		Arguments.Request.vArray = listToArray(fullPath,'/',false); //arrayNew(1);
		Arguments.Request.vPath = '/';
		Arguments.Request.URLparams = '';
		Arguments.Request.fileName = '';

		if(find('404;', Arguments.queryString)) {
			if(find('.',right(listLast(fullPath,'/'),4))) Arguments.Request.fileName = listLast(fullPath,'/');
			if(arrayLen(Arguments.Request.vArray)) {
				Arguments.Request.vPath = '/' & Arguments.Request.vArray[1];
			} else {
				Arguments.Request.vPath = fullPath;
			}
			tParam = listFirst(listRest(Arguments.queryString, '?'), '&');
			structInsert(url, listFirst(tParam, '='), listRest(tParam, '='), true);

			for(item in Arguments.url) {
				if(left(item, 4) == '404;') {
					structDelete(Arguments.url, item, false);
					break;
				}
			}
		}
		return(this.flattenURL(Arguments.url));
	}

	public struct function virtualResolver(required string vPath) output='false' {
		var qVU = '';
		var	vInfo = {
			Active = false,
			contentType = 'cfm',
			doRedirect = false,
			isConical = false,
			isDefault = false,
			mapAsset = '',
			recordCount = 0,
			reDirectType = '',
			URI = 'Main',
			URL = '',
			viewName = 'Main',
			viewTemplate = 'index.cfm',
			virtualPath = '/',
			virtualUriId = 0
		};

		if(structKeyExists(Application,'Database')) {
			qVU = Application.Database.getVirtualUri(listLast(Arguments.vPath,'/'));
			if(qVU.metaInfo.RecordCount) {
				vInfo = {
					recordCount = qVU.metaInfo.RecordCount,
					URI = qVU.result.URI[1],
					URL = qVU.result.ULR[1],
					ContentType = qVU.result.ContentType[1],
					RedirectType = qVU.result.RedirectType[1],
					Framework = qVU.result.Framework[1],
					FrameworkIsDynamic = qVU.result.FrameworkIsDynamic[1],
					ViewName = qVU.result.ViewName[1],
					ViewTemplate = qVU.result.ViewTemplate[1],
					ChildViewName = qVU.result.ChildViewName[1],
					ChildViewTemplate = qVU.result.ChildViewTemplate[1],
					MappedAsset = qVU.result.MappedAsset[1],
					AssetMapping = qVU.result.AssetMapping[1],
					IsConical = qVU.result.IsConical[1],
					DoRedirect = qVU.result.DoRedirect[1],
					IsDefault = qVU.result.IsDefault[1],
					Description = qVU.result.Description[1],
					Active = qVU.result.Active[1]
				};
			}
		}

		if(!vInfo.recordCount) {
			if(fileExists(expandPath('/views' & Arguments.vPath) & "\index.cfm")) {
				vInfo = {
					Active = true,
					contentType = 'cfm',
					doRedirect = false,
					isConical = false,
					isDefault = false,
					mapAsset = '',
					recordCount = 0,
					reDirectType = '',
					URI = Arguments.vPath,
					URL = '',
					viewName = listLast(Arguments.vPath,'/'),
					viewTemplate = 'index.cfm',
					virtualPath = Arguments.vPath,
					virtualUriId = 0
				};
			} else {
				if(fileExists(expandPath('/') & 'Views' & cgi.SCRIPT_NAME)) {
					vInfo = {
						Active = true,
						contentType = listLast(cgi.SCRIPT_NAME,'.'),
						doRedirect = false,
						isConical = false,
						isDefault = false,
						mapAsset = '',
						recordCount = 1,
						reDirectType = '',
						URI = replace(cgi.SCRIPT_NAME,listLast(cgi.SCRIPT_NAME,'/'),''),
						URL = '',
						viewName = replace(cgi.SCRIPT_NAME,listLast(cgi.SCRIPT_NAME,'/'),''),
						viewTemplate = listLast(cgi.SCRIPT_NAME,'/'),
						virtualPath = replace(cgi.SCRIPT_NAME,listLast(cgi.SCRIPT_NAME,'/'),''),
						virtualUriId = 0
					};
					if(len(vInfo.viewName) > 2) {
						vInfo.viewName = mid(vInfo.viewName,2,len(vInfo.viewName)-2);
						vInfo.virtualPath = left(vInfo.virtualPath,len(vInfo.virtualPath)-2);
					}
				}
			}
		}
		return(vInfo);
	}

	public void function parseSearchUrl(required any Request, required any Visitor) output='false' {
		var i = 0;
		var uri = '';
		var options = '';
		var sOptions = '';
		var sets = '';
		var tmp = '';
		var sortOptions = { sortBy='Relevance', perPage=9, onPage=1 };

		if(arrayLen(Arguments.Request.vArray) < 2) return;

		if(find('@',Arguments.Request.vArray[2])) {
			sOptions = replace(Arguments.Request.vArray[2],'@','');
			sOptions = replaceNoCase(sOptions,'-With-','|','ALL');
			sOptions = replaceNoCase(sOptions,'-Page-','|','ALL');		
		} else {
			options = replace(Arguments.Request.vArray[2],';','.','ALL');
			options = replaceNoCase(options,'-Where-','|','ALL');
			options = replaceNoCAse(options,'-Is-',':','ALL');
			options = replaceNoCase(options,'-To-',':','ALL');
		}

		if((arrayLen(Arguments.Request.vArray) > 2) && find('@',Arguments.Request.vArray[3])){
			sOptions = replace(Arguments.Request.vArray[3],'@','');
			sOptions = replaceNoCase(sOptions,'-With-','|','ALL');
			sOptions = replaceNoCase(sOptions,'-Page-','|','ALL');		
		}

		sets = listToArray(options,'|',false);
		for(i=1; i <= arrayLen(sets); i++) {
			tmp = sets[i];
			sets[i] = structNew();
			sets[i].original = tmp;
			sets[i].refinement = replace(listFirst(sets[i].original,':'),'-',' ','ALL');
			sets[i].value = replace(listRest(sets[i].original,':'),'-',' ','ALL');
			if(this.isTrueNumeric(replace(replace(sets[i].value,':','','ALL'),' ','','ALL'))) sets[i].value = replace(replace(sets[i].value,' ','.','ALL'),':','-','ALL');
		}

		if(listLen(sOptions,'|')) {
			sortOptions.sortBy = listFirst(sOptions,'|');
			sortOptions.perPage = val(listGetAt(sOptions,2,'|'));
			sortOptions.onPage = val(listLast(sOptions,'|'));
		}

		Arguments.Request.urlOptions = duplicate(sortOptions);
		Arguments.Request.urlSets = duplicate(sets);
//		Arguments.Visitor.Search.setSearchFromUrl(vSearchUrl=duplicate(sets),vSortOptions=duplicate(sortOptions));
	}

	public string function flattenUrl(required any url) output='false' {
		var result = '';
		var item = '';

		if(structCount(Arguments.url)) {
			for(item IN Arguments.url) if(trim(item) > '') result = result & trim(item) & '=' & trim(Arguments.url[item]) & '&';
			if(result > '') result = left(result, len(result) - 1);
		}
		return(result);
	}

	public void function processUrlSwitchs(required struct Session, required struct Url) output='false' {
		if(!structCount(Arguments.Url)) return;

		if(structKeyExists(Arguments.Url,'clearCache') && (Application.Settings.isDevEnvironment || (structKeyExists(Arguments.Url,'auth') && (hash(Arguments.Url.auth,'SHA-256') == Application.Settings.Authorizations.cache)))) {
			directoryDelete('/inram/*',true);
			this.fillCache();
		}

		if(structKeyExists(Arguments.Url,'Debug') && (Application.Settings.isDevEnvironment || (structKeyExists(Arguments.Url,'auth') && (hash(Arguments.Url.auth,'SHA-256') == Application.Settings.Authorizations.debug)))) Arguments.Session.Visitor.Debug = (Arguments.Url.debug == 'on') ? true : false;
		if(structKeyExists(Arguments.Url,'Cache') && (Application.Settings.isDevEnvironment || (structKeyExists(Arguments.Url,'auth') && (hash(Arguments.Url.auth,'SHA-256') == Application.Settings.Authorizations.cache)))) Application.Settings.cache = (Arguments.Url.cache == 'on') ? true : false;
		if(structKeyExists(Arguments.Url,'combineAll') && (Application.Settings.isDevEnvironment || (structKeyExists(Arguments.Url,'auth') && (hash(Arguments.Url.auth,'SHA-256') == Application.Settings.Authorizations.combine)))) {
			Application.Settings.combineJs = (Arguments.Url.combineAll == 'on') ? true : false;
			Application.Settings.combineCss = (Arguments.Url.combineAll == 'on') ? true : false;
		}
		if(structKeyExists(Arguments.Url,'combineJs') && (Application.Settings.isDevEnvironment || (structKeyExists(Arguments.Url,'auth') && (hash(Arguments.Url.auth,'SHA-256') == Application.Settings.Authorizations.combine)))) Application.Settings.combineJs = (Arguments.Url.combineJs == 'on') ? true : false;
		if(structKeyExists(Arguments.Url,'combineCss') && (Application.Settings.isDevEnvironment || (structKeyExists(Arguments.Url,'auth') && (hash(Arguments.Url.auth,'SHA-256') == Application.Settings.Authorizations.combine)))) Application.Settings.combineCss = (Arguments.Url.combineCss == 'on') ? true : false;
		if(structKeyExists(Arguments.Url,'compressAll') && (Application.Settings.isDevEnvironment || (structKeyExists(Arguments.Url,'auth') && (hash(Arguments.Url.auth,'SHA-256') == Application.Settings.Authorizations.compress)))) {
			Application.Settings.combineJs = (Arguments.Url.compressAll == 'on') ? true : false;
			Application.Settings.combineCss = (Arguments.Url.compressAll == 'on') ? true : false;
		}
		if(structKeyExists(Arguments.Url,'compressJs') && (Application.Settings.isDevEnvironment || (structKeyExists(Arguments.Url,'auth') && (hash(Arguments.Url.auth,'SHA-256') == Application.Settings.Authorizations.compress)))) Application.Settings.compressJs = (Arguments.Url.compressJs == 'on') ? true : false;
		if(structKeyExists(Arguments.Url,'compressCss') && (Application.Settings.isDevEnvironment || (structKeyExists(Arguments.Url,'auth') && (hash(Arguments.Url.auth,'SHA-256') == Application.Settings.Authorizations.compress)))) Application.Settings.compressCss = (Arguments.Url.compressCss == 'on') ? true : false;
		if(structKeyExists(Arguments.Url,'pageCompress') && (Application.Settings.isDevEnvironment || (structKeyExists(Arguments.Url,'auth') && (hash(Arguments.Url.auth,'SHA-256') == Application.Settings.Authorizations.compress)))) Application.Settings.pageCompress = (Arguments.Url.pageCompress == 'on') ? true : false;
		if(structKeyExists(Arguments.Url,'gZip') && (Application.Settings.isDevEnvironment || (structKeyExists(Arguments.Url,'auth') && (hash(Arguments.Url.auth,'SHA-256') == Application.Settings.Authorizations.gZip)))) Application.Settings.gZip = (Arguments.Url.gZip == 'on') ? true : false;
	}

	public void function writeBaseDocument(required any Request, required struct virtualInfo) output='true' {
		var s = createObject('java','java.lang.StringBuffer').init('');
		var viewTemplateName = listFirst(Arguments.virtualInfo.viewTemplate,'.');
		var i = 0;

		if(Application.Settings.cache && this.coreFramework.Start.cache) {
			writeOutput(this.coreFramework.Start.content);
		} else {
			if(fileExists(Application.Settings.rootPath & 'com\Framework\coreFrameworkStart.cfm')) this.Wrappers.include('/com/Framework/coreFrameworkStart.cfm');
		}

		s.append('<title>');
/*
		if(structKeyExists(Arguments.Request.pageData,'Title')) {
			s.append(this.proccessDirectives(Arguments.Request.pageData['Title'][1].Contents));
			s.append(' | ');
		}
*/
		s.append(Application.Settings.rootDomain);
		s.append('</title>');
		s.append('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
//			s.append(this.proccessDirectives(this.getMetaTags(Arguments.virtualInfo.viewTemplate)));
		s.append('<meta name="HOME_URL" content="http://#Application.Settings.defaultConical#.#Application.Settings.rootDomain#/" />');
		s.append('<meta name="LANGUAGE" content="ENGLISH" />');
		s.append('<meta name="MSSmartTagsPreventParsing" content="TRUE" />');
		s.append('<meta name="DOC-TYPE" content="PUBLIC" />');
		s.append('<meta name="DOC-CLASS" content="COMPLETED" />');
		s.append('<meta name="DOC-RIGHTS" content="PUBLIC DOMAIN" />');

/***  NEED to modify the JS && CSS manifest mechanism so that it loads a -min version if available ***
		if(fileExists(Application.Settings.rootPath & 'css/global.min.css')) {
			this.css('/css/global.min.css');
		} else if(fileExists(Application.Settings.rootPath & 'css/global.css')) {
			this.css('/css/global.css');
		}
*/

		for(i=1; i <= arrayLen(this.coreCSS); i++) s.append('<link rel="stylesheet" type="text/css" href="' & this.coreCSS[i].file & '" />');
		for(i=1; i <= arrayLen(this.coreJS); i++) s.append('<script type="text/javascript" src="' & this.coreJS[i].file & '"></script>');
		s.append('</head>');
		writeOutput(s.toString());

		if(Application.Settings.cache && this.baseFramework.Start.cache) {
			writeOutput(this.baseFramework.Start.content);
		} else {
			if(fileExists(Application.Settings.rootPath & 'com\Framework\baseFrameworkStart.cfm')) this.Wrappers.include('/com/Framework/baseFrameworkStart.cfm');
		}

		this.Wrappers.headers(name="Cache-Control", value="post-check=#getHttpTimeString(dateAdd('n', (Application.Settings.sessionTimeoutMinutes * 60), Now()))#,pre-check=#getHttpTimeString(dateAdd('n', (Application.Settings.sessionTimeoutMinutes * 120), Now()))#,max-age=#getHttpTimeString(DateAdd('d', 3, Now()))#");
		this.Wrappers.headers(name="Expires", value="#getHttpTimeString(dateAdd('d', 3, Now()))#");
	}

	public void function closePageContents(required struct Request) output='true' {
		if(!structKeyExists(Arguments.Request,'virtualInfo')) return;

		var i = 0;
		var buffer = createObject('java','java.lang.StringBuffer').init('');
		var viewTemplateName = listFirst(Arguments.Request.virtualInfo.viewTemplate,'.');
		var filename = '';
		var content = '';

		if(fileExists(Application.Settings.rootPath & "views/" & Arguments.Request.virtualInfo.viewName & '/css/' & viewTemplateName & '-min.css')) {
			content = fileRead(Application.Settings.rootPath & "views/" & Arguments.Request.virtualInfo.viewName & '/css/' & viewTemplateName & '-min.css');
			if(Application.Settings.compressCss) content = cssCompressor(content);
			if(len(content)) this.Wrappers.htmlHead(text='<style type="text/css">' & content & '</style>');			
		} else if(fileExists(Application.Settings.rootPath & 'views/' & Arguments.Request.virtualInfo.viewName & '/css/' & viewTemplateName & '.css')) {
			content = fileRead(Application.Settings.rootPath & "views/" & Arguments.Request.virtualInfo.viewName & '/css/' & viewTemplateName & '.css');
			if(Application.Settings.compressCss) content = cssCompressor(content);
			if(len(content)) this.Wrappers.htmlHead(text='<style type="text/css">' & content & '</style>');
		}

		if(fileExists(Application.Settings.rootPath & 'views/' & Arguments.Request.virtualInfo.viewName & '/js/' & viewTemplateName & '-min.js')) {
			content = fileRead(Application.Settings.rootPath & 'views/' & Arguments.Request.virtualInfo.viewName & '/js/' & viewTemplateName & '-min.js');
			if(Application.Settings.compressJs) content = this.jsCompressor(content);
			if(len(content)) this.Wrappers.htmlHead(text='<script type="text/javascript">' & content & '</script>');
		} else if(fileExists(Application.Settings.rootPath & 'views/' & Arguments.Request.virtualInfo.viewName & '/js/' & viewTemplateName & '.js')) {
			content = fileRead(Application.Settings.rootPath & 'views/' & Arguments.Request.virtualInfo.viewName & '/js/' & viewTemplateName & '.js');
			if(Application.Settings.compressJs) content = this.jsCompressor(content);
			if(len(content)) this.Wrappers.htmlHead(text='<script type="text/javascript">' & content & '</script>');
		}

		if(Application.Settings.cache && this.baseFramework.End.cache) {
			writeOutput(this.baseFramework.End.content);
		} else {
			if(fileExists(Application.Settings.rootPath & 'com\Framework\baseFrameworkEnd.cfm')) this.Wrappers.include('/com/Framework/baseFrameworkEnd.cfm');
		}
		if(Application.Settings.cache && this.coreFramework.End.cache) {
			writeOutput(this.coreFramework.End.content);
		} else {
			if(fileExists(Application.Settings.rootPath & 'com\Framework\coreFrameworkEnd.cfm')) this.Wrappers.include('/com/Framework/coreFrameworkEnd.cfm');
		}

		while(!Arguments.Request.cssQueue.empty()) {
			filename = Arguments.Request.cssQueue.pop();
			if(fileExists(Application.Settings.rootPath & filename)) {
				content = fileRead(Application.Settings.rootPath & filename);
				if(Application.Settings.compressCss) content = this.cssCompressor(content);
				if(len(content)) this.Wrappers.htmlHead(text='<style type="text/css">' & content & '</style>');
			}
		}
		while(!Arguments.Request.jsQueue.empty()) {
			filename = Arguments.Request.jsQueue.pop();
			if(fileExists(Application.Settings.rootPath & filename)) {
				content = fileRead(Application.Settings.rootPath & filename);
				if(Application.Settings.compressJs) content = this.jsCompressor(content);
				if(len(content)) this.Wrappers.htmlHead(text='<script type="text/javascript">' & content & '</script>');
			}
		}

		this.Wrappers.headers(name="Cache-Control", value="post-check=#(Application.Settings.sessionTimeoutSeconds)#,pre-check=#(Application.Settings.sessionTimeoutSeconds)#,max-age=#(Application.Settings.sessionTimeoutSeconds)#");
		this.Wrappers.headers(name="Expires", value="#getHttpTimeString(dateAdd('n', Application.Settings.sessionTimeoutMinutes, Now()))#");
	}

	public void function processView(required struct virtualInfo) output='true' {
		var debug = { };
		try {
			this.Wrappers.include('/views/' & Arguments.virtualInfo.viewName & '/' & Arguments.virtualInfo.viewTemplate);
		} catch(Any e) {
			debug = {
				exception = e,
				virtualInfo = Arguments.virtualInfo
			};
			Application.Mail.send(to=Application.Settings.emailLists.Errors,subject='[#cgi.SERVER_NAME#] Application Error in the #this.Name# Application',msg='There was an Application error in the #this.Name# Application at #cgi.SERVER_NAME#',obj=debug);
		}
	}

	public void function loadFrameworkObjects(required string scope) output='false' {
		var i = 0;
		var ptrScope = '';
		var tmpFile = '';
		
		switch(lCase(Arguments.scope)) {
			case 'application' : ptrScope = Application;
				break;
			case 'session' : ptrScope = Session;
				break;
			case 'request' : ptrScope = Request;
				break;
			default : return;
		}

		if(lcase(Arguments.scope) == 'application') {
			for(i=1; i <= arrayLen(this.Objects[Arguments.scope]); i++) {
				if(this.Objects[Arguments.scope][i].init) {
					ptrScope[this.Objects[Arguments.scope][i].name] = createObject(this.Objects[Arguments.scope][i].type,this.Objects[Arguments.scope][i].class).init();
				} else {
					ptrScope[this.Objects[Arguments.scope][i].name] = createObject(this.Objects[Arguments.scope][i].type,this.Objects[Arguments.scope][i].class);
				}
			}
		} else {
			if(!directoryExists('ram:///' & Arguments.scope)) directoryCreate('ram:///' & Arguments.scope);
			for(i=1; i <= arrayLen(this.Objects[Arguments.scope]); i++) {
				if(!fileExists('ram:///' & Arguments.scope & '/' & listLast(this.Objects[Arguments.scope][i].class,'.') & '.cfc')) {
					tmpFile = fileRead(Application.Settings.rootPath & replace(this.Objects[Arguments.scope][i].class,'.','\','ALL') & '.cfc');
					fileWrite('ram:///' & Arguments.scope & '/' & listLast(this.Objects[Arguments.scope][i].class,'.') & '.cfc',tmpFile);
				}
				if(this.Objects[Arguments.scope][i].init) {
					ptrScope[this.Objects[Arguments.scope][i].name] = createObject(this.Objects[Arguments.scope][i].type,'inram.' & Arguments.scope & listLast(this.Objects[Arguments.scope][i].class,'.')).init();
				} else {
					ptrScope[this.Objects[Arguments.scope][i].name] = createObject(this.Objects[Arguments.scope][i].type,'inram.' & Arguments.scope & listLast(this.Objects[Arguments.scope][i].class,'.'));
				}
			}
		}
	}

	public void function redirectToConical(required any Request, required any CGI, string conical='www') output='false' {
		var urlParms = (trim(Arguments.Request.URLparams) != '') ? '?' & Arguments.Request.URLparams : '';
		var nCons = listLen(Arguments.cgi.SERVER_NAME,'.');
		location(Arguments.Request.Protocol & '://' & Arguments.conical & '.' & listGetAt(Arguments.cgi.SERVER_NAME,nCons-1,'.') & '.' & listLast(Arguments.cgi.SERVER_NAME,'.') & Arguments.Request.vPath & ((findNoCase('index.cfm', Arguments.cgi.SCRIPT_NAME)) ? '' : Arguments.cgi.SCRIPT_NAME) & urlParms, false, '302');
	}

	public string function getRequestProtocol(required string HTTPS, required struct requestData) output='false' {
		if(structKeyExists(Arguments.requestData.headers,'SSL')) {
			return((Arguments.requestData.headers['SSL'] == 1) ? 'https' : 'http');
		} else {
			return((Arguments.HTTPS == 'on') ? 'https' : 'http');
		}
	}

	public string function getSslProtocol(required any CGI) output='false' {
		var result = getHttpRequestData().headers;

		if(structKeyExists(result, 'SSL')) return((result.SSL == 1) ? 'https' : 'http');
		if(structKeyExists(Arguments.CGI, 'HTTPS')) return((cgi.HTTPS == 'on') ? 'https' : 'http');
		return('http');
	}

	public void function showDebug() output='false' {
		writeOutput('<hr width="100%">');
		if(structKeyExists(Request, 'endTime')) writeOutput('Elapsed Time: ' & (Request.endTime - Request.startTime) & 'ms.');
		this.dumpScope('Application');
		this.dumpScope('Session');
		this.dumpScope('Request');
		this.dumpScope('URL');
		this.dumpScope('Cookie');
		this.dumpScope('Variables');
		this.dumpScope('CGI');
	}

	public void function dumpScope(required string Scope) output='false' {
		var s = createObject('java','java.lang.StringBuffer').init('');
		
		s.append('<table border=0 cellspacing=0 cellpadding=2 style="margin-bottom:4px;border:1px solid ##C0C0C0; color:##000000;">');
		s.append('<tr style="cursor:pointer; background-color:##D0D0D0;"');
		s.append(" onclick=""(document.getElementById('scope_" & Arguments.Scope & "').style.display=='')?document.getElementById('scope_" & Arguments.Scope & "').style.display='none':document.getElementById('scope_" & Arguments.Scope & "').style.display='';""");
		s.append(" onmouseover=""this.style.backgroundColor='##FFFFFF';""");
		s.append(" onmouseout=""this.style.backgroundColor='##D0D0D0';""><td style=""font-family:Arial;font-size:11px;font-weight:bold;padding-left:5px;padding-right:5px;"">" & Arguments.Scope & "</td></tr></table>");
		s.append('<table border=0 id="scope_' & Arguments.Scope & '" style="display:none; color:##000000;"><tr><td>');
		writeOutput(s.toString());
		writeDump(getPageContext().SymTab_findBuiltinScope(Arguments.Scope));
		writeOutput("</td></tr></table>");
	}

	public any function cfmFileRead(required string filename) output='false' {
		return(this.Wrappers.cfmFileRead(argumentCollection));
	}

	public boolean function loadIntoRam(required string filePath) output='false' {
		var tmpFile = '';
		var errorLog = '';

		if(fileExists(Arguments.filePath)) {
			try {
				tmpFile = fileRead(Arguments.filePath);
				fileWrite('ram:///' & listLast(Arguments.filePath,'/'),tmpFile);
			} catch(Any E) {
				errorMsg = dateFormat(now(),'mm/dd/yy') & '@' & timeFormat(now(),'hh:mm:tt') & ': Error: loading file into RAM [' & Arguments.filePath & ']';
				if(Application.Settings.isMailAvailable) Application.Mail.send(to=Application.Settings.emailLists.Errors,subject='Error: loading file into RAM',msg=errorMsg,obj=E);
				if(Application.Settings.useLogFile) {
					errorLog = fileOpen(Application.Settings.rootPath & 'frameworkError.log','write');
					fileWriteLine(errorLog,errorMsg);
					fileClose(errorLog);
				}
			}
			return(true);
		}
		return(false);
	}

	public void function css(required struct Request, required string filename) output='false' {
		if(!structKeyExists(Arguments.Request,'cssQueue') || (Arguments.Request.cssQueue.indexOf(Arguments.filename) != -1)) return;
		Arguments.Request.cssQueue.push(Arguments.filename);
	}

	public void function js(required struct Request, required string filename, string params) output='false' {
		if(!structKeyExists(Arguments.Request,'jsQueue') || (Arguments.Request.jsQueue.indexOf(Arguments.filename) != -1)) return;
		Arguments.Request.jsQueue.push(Arguments.filename);
	}

	public void function cleanPageContents(required struct Request) output='true' {
		if(!structKeyExists(Arguments.Request,'context')) return;
		var pageContent = Arguments.Request.context.getOut().getString();

		Arguments.Request.context.getOut().clear();
		getPageContext().getOut().clear();
		pageContent = reReplace(pageContent,'>[[:space:]]{2,}<','><','ALL');  // strip whitespace between tags
		pageContent = reReplace(pageContent,'^[!NOCOMP!][\n\r\f]+^[!NOCOMP!]',' ','ALL');  // condense excessive new lines into one new line
		pageContent = replaceNoCase(pageContent,'!NOCOMP!','','ALL');		// remove the !NOCOMP! (no compress) marker
		pageContent = reReplace(pageContent,'\t+','','ALL');  // condense excessive tabs into a single space
		Arguments.Request.context.getOut().write(pageContent);
	}

// *** need to resolve how to actually gZip and send back to browser *** //
	public void function gZipPageContents(required struct request) output='true' {
		if(!structKeyExists(Arguments.request,'context')) return;
		var pageContent = Arguments.request.context.getOut().getString();

//		var requestData = getHttpRequestData();
//		if(!findNoCase('gzip',requestData.headers['Accept-Encoding'])) return;
//		this.Wrappers.headers(name='Content-Encoding',value='gzip');

		this.Wrappers.headers(name='Content-Length',value=len(Arguments.request.context.getOut().getString()));
	}

	public string function jsCompressor(required string jscode) output='false' {
		Arguments.jscode = reReplace(Arguments.jscode,'/\*',chr(172),'all');
		Arguments.jscode = reReplace(Arguments.jscode,'\*/',chr(172),'all');
		Arguments.jscode = reReplace(Arguments.jscode,'#chr(172)#[^#chr(172)#]*#chr(172)#','','all');
		Arguments.jscode = reReplace(Arguments.jscode,'[^:]\/\/[^#chr(13)##chr(10)#]*','','all'); // remove single line comments
		Arguments.jscode = reReplace(Arguments.jscode,'[\s]*([\=|\{|\}|\(|\)|\;|[|\]|\+|\-|\n|\r]+)[\s]*','\1','all');
		Arguments.jscode = reReplace(Arguments.jscode,'[\r\n\f]*','','all');
		return(Arguments.jscode);
	}

	public string function cssCompressor(required string sInput) output='false' {
		Arguments.sInput = reReplace(Arguments.sInput,'[[:space:]]{2,}',' ','all');
		Arguments.sInput = reReplace(Arguments.sInput,'/\*[^\*]+\*/',' ','all');
		Arguments.sInput = reReplace(Arguments.sInput,'[ ]*([:{};,])[ ]*','\1','all');
		return(Arguments.sInput);
	}

	public void function fillCache() output='false' {
		if(fileExists(Application.Settings.rootPath & 'com\Framework\coreFrameworkStart.cfm')) this.coreFramework.Start.content = this.Wrappers.cfmFileRead('/com/Framework/coreFrameworkStart.cfm');
		if(fileExists(Application.Settings.rootPath & 'com\Framework\coreFrameworkEnd.cfm')) this.coreFramework.End.content = this.Wrappers.cfmFileRead('/com/Framework/coreFrameworkEnd.cfm');
		if(fileExists(Application.Settings.rootPath & 'com\Framework\baseFrameworkStart.cfm')) this.baseFramework.Start.content = this.Wrappers.cfmFileRead('/com/Framework/baseFrameworkStart.cfm');
		if(fileExists(Application.Settings.rootPath & 'com\Framework\baseFrameworkEnd.cfm')) this.baseFramework.End.content = this.Wrappers.cfmFileRead('/com/Framework/baseFrameworkEnd.cfm');
	}

	public void function include(required string template) output='true' {
		this.Wrappers.include(argumentCollection=Arguments);
	}

	public void function headers(required string name, required string value) output='true' {
		this.Wrappers.headers(argumentCollection=Arguments);
	}

	public void function htmlHead(required string text) output='true' {
		this.Wrappers.htmlHead(argumentCollection=Arguments);
	}

	public void function setCookie(required any CGI, required string name, required string value) output='true' {
		this.Wrappers.setCookie(argumentCollection=Arguments);
	}

	public void function deleteCookie(required any CGI, required string cookie, required string name) output='true' {
		this.Wrappers.deleteCookie(argumentCollection=Arguments);
	}

	public any function jsonDecode(required string data) output='false' {
		var ar = arrayNew(1);
		var st = structNew();
		var dataType = '';
		var inQuotes = false;
		var startPos = 1;
		var nestingLevel = 0;
		var dataSize = 0;
		var skipIncrement = false;
		var i = 1;
		var j = 0;
		var loopVar = 0;
		var char = '';
		var dataStr = '';
		var structVal = '';
		var structKey = '';
		var colonPos = '';
		var qRows = 0;
		var qCol = '';
		var qData = '';
		var curCharIndex = '';
		var curChar = '';
		var unescapeVals = '\\,\",\/,\b,\t,\n,\f,\r';
		var unescapeToVals = '\,",/,#chr(8)#,#Chr(9)#,#Chr(10)#,#Chr(12)#,#Chr(13)#';
		var unescapeVals2 = '\,",/,b,t,n,f,r';
		var unescapetoVals2 = '\,",/,#chr(8)#,#chr(9)#,#chr(10)#,#chr(12)#,#chr(13)#';
		var dJSONString = '';
		var _data = trim(Arguments.data);

		if(isNumeric(_data)) return(_data);
		if(_data == 'null')	return('');
		if(listFindNoCase('true,false', _data)) return(_data);
		if((_data == "''") || (_data == '""')) return('');

		if((reFind('^"[^\\"]*(?:\\.[^\\"]*)*"$', _data) == 1) || (reFind("^'[^\\']*(?:\\.[^\\']*)*'$", _data) == 1)) {
			_data = mid(_data, 2, Len(_data)-2);
			if(find('\b', _data) || find('\t', _data) || find('\n', _data) || find('\f', _data) || find('\r', _data)) {
				curCharIndex = 0;
				curChar = '';
				dJSONString = createObject('java', 'java.lang.StringBuffer').init('');
				for(loopVar=1; loopVar <= 100000; loopVar++) {
					curCharIndex++;
					if(curCharIndex > len(_data)) {
						loopVar = 100001;
						break;
					} else {
						curChar = mid(_data, curCharIndex, 1);
						if(curChar == '\') {
							curCharIndex++;
							curChar = mid(_data, curCharIndex,1);
							pos = listFind(unescapeVals2, curChar);
							if(pos) {
								dJSONString.append(listGetAt(unescapetoVals2, pos));
							} else {
								dJSONString.append('\' & curChar);
							}
						}
						dJSONString.append(curChar);
					}
				}
				return(dJSONString.toString());
			}
			return(replaceList(_data, unescapeVals, unescapeToVals));
		}

		if(((left(_data, 1) == '[') && (right(_data, 1) == ']')) || ((left(_data, 1) == '{') && (right(_data, 1) == '}'))) {
			if((left(_data, 1) == '[') && (right(_data, 1) == ']')) {
				dataType = 'array';
			} else if(reFindNoCase('^\{"recordcount":[0-9]+,"columnlist":"[^"]+","data":\{("[^"]+":\[[^]]*\],?)+\}\}$', _data, 0) == 1) {
				dataType = 'query';
			} else {
				dataType = 'struct';
			}
			_data = trim(mid(_data, 2, len(_data)-2));
			if(len(_data) == 0) {
				if(dataType == 'array') return(ar);
				return(st);
			}
			dataSize = len(_data) + 1;
			for(; i <= dataSize; ) {
				skipIncrement = false;
				char = mid(_data, i, 1);
				if(char == '"') {
					inQuotes = (!inQuotes);
				} else if((char == '\') && inQuotes) {
					i = i + 2;
					skipIncrement = true;
				} else if(((char == ',') && (!inQuotes) && (nestingLevel == 0)) || (i == (len(_data)+1))) {
					dataStr = mid(_data, startPos, i-startPos);
					if(dataType == 'array') {
						arrayAppend(ar, jsondecode(dataStr));
					} else if((dataType == 'struct') || (dataType == 'query')) {
						dataStr = mid(_data, startPos, i-startPos);
						colonPos = find('":', dataStr);
						if(colonPos) {
							colonPos++;    
						} else {
							colonPos = find(':', dataStr);    
						}
						structKey = trim(mid(dataStr, 1, colonPos-1));
						if((left(structKey, 1) == "'") || (left(structKey, 1) == '"')) structKey = mid(structKey, 2, len(structKey)-2);
						structVal = mid(dataStr, colonPos+1, len(dataStr)-colonPos);
						if(dataType == 'struct') structInsert(st, structKey, jsondecode(structVal));
						if(structKey == 'recordcount') {
							qRows = jsondecode(structVal);
						} else if(structKey == 'columnlist') {
							st = queryNew(jsondecode(structVal));
							if(qRows) queryAddRow(st, qRows);
						} else if(structKey == 'data') {
							qData = jsondecode(structVal);
							ar = structKeyArray(qData);
							for(j=1; j <= arrayLen(ar); j++) {
								for(qRows=1; qRows <= st.recordCount; j++) {
									qCol = ar[j];
									querySetCell(st, qCol, qData[qCol][qRows], qRows);
								}
							}
						}
					}
					startPos = i + 1;
				} else if(('{[' CONTAINS char) && (!inQuotes)) {
					nestingLevel++;
				} else if((']}' CONTAINS char) && (!inQuotes)) {
					nestingLevel--;
				}
				if(!skipIncrement) i++;
			}
			if(dataType == 'array') return(ar);
			return(st);
		}
	}

	public string function toHexTrig(required string inData) output='false' {
		var result = '';
		var i = 0;
		var char36 = '';

		for(i=1; i <= len(inData); i++) {
			char36 = formatBaseN(Asc(mid(inData,i,1)),36);
			if(len(char36) < 2) char36 = '0' & char36;
			result = result & char36;
		}
		return(result);
	}

	public string function fromHexTrig(required string inData) output='false' {
		var result = '';
		var i = 0;
		var char36 = '';
		var nchar = '';

		for(i=1; i < len(inData); i+=2) {
			char36 = mid(inData,i,2);
			nchar = Chr(inputBaseN(char36,36));
			result = result & nchar;
		}
		return(result);
	}

	public boolean function dsnExists(required string dsn) output='false' {
		return(this.Wrappers.dsnExists(argumentCollection=Arguments));
	}

	public boolean function isTrueNumeric(required string str) {
		return(reFind("[^0-9]", str) == 0);
	}

	public boolean function isMobile(required struct cgi) output='false' {
		var result = reFindNoCase(Application.Settings.mobileFullCheck,Arguments.CGI.HTTP_USER_AGENT);
		if(!result) result = reFindNoCase(Application.Settings.mobileFourCheck,left(Arguments.CGI.HTTP_USER_AGENT,4));
		return(result);
	}

	public struct function getDeviceType(required struct cgi) output='false' {
		var result = { mobile=false, device='desktop' };
		var fIdx = reFindNoCase(Application.Settings.mobileFullCheck,Arguments.CGI.HTTP_USER_AGENT);
		if(!fIdx) fIdx = reFindNoCase(Application.Settings.mobileFourCheck,left(Arguments.CGI.HTTP_USER_AGENT,4));
		if(fIdx) result = { mobile=true, device=Arguments.CGI.HTTP_USER_AGENT };
		return(result);
	}

	public void function onMissingMethod(string methodName, any methodArguments) output='false' {
		if(Application.Settings.isMailAvailable) Application.Mail.send(to=Application.Settings.emailLists.Errors,subject='[#Application.Settings.serverId#] Missing Method Error',msg='There was a Missing Method error [#cgi.SERVER_NAME#]',obj=Arguments);
		return;
	}

}