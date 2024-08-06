component displayname='CoreSystemDatabaseObjectComponent' hint='Core System Database Component' output='false' {

	public any function init(string dsn=Application.Settings.DSN.System) output='false' {
		this.DSN = Arguments.dsn;
		this.URIs = this.getAllVirtualUris();

		return(this);
	}

	public struct function getVirtualUri(required string uri) output='false' {
		if(isStruct(this.URIs)) {
			var q = new Query(dbtype='query',srcTable=this.URIs.results);
			Arguments.uri = trim(reReplace(Arguments.uri,'-|_',' ','ALL'));
			var qResult = q.execute(sql="SELECT * FROM srcTable WHERE URI='#Arguments.uri#'");
		} else {
			var q = new Query(dataSource=this.DSN,cachedWithin=createTimeSpan(0,0,30,0));
			q.addParam(name='URI',value=trim(reReplace(Arguments.uri,'-|_',' ','ALL')),cfSqlType='VARCHAR');
			q.addParam(name='Active',value=1,cfSqlType='BIT');

			transaction isolation='read_uncommitted' {
				var qResult = q.execute(sql='
					SELECT
						VU.VirtualUriId,
						VU.URI,
						VU.URL,
						VU.Framework,
						VU.FrameworkIsDynamic,
						VU.ViewName,
						VU.ViewTemplate,
						VU.ChildViewName,
						VU.ChildViewTemplate,
						VU.MappedAsset,
						VU.AssetMapping,
						VU.IsConical,
						VU.DoRedirect,
						VU.IsDefault,
						VU.Active,
						VU.Description,
						CT.ContentType,
						RT.RedirectType,
						RT.RedirectCode 
					FROM VirtualUris AS VU WITH (NOLOCK) 
						LEFT OUTER JOIN ContentTypes AS CT WITH (NOLOCK) ON CT.ContentTypeId = VU.ContentTypeId 
						LEFT OUTER JOIN RedirectTypes AS RT WITH (NOLOCK) ON RT.RedirectTypeId = VU.RedirectTypeId 
					WHERE 
						VU.URI = :URI 
						AND VU.Active = :Active
				');
			}
		}

		var result = { results=qResult.getResult(), metaInfo=qResult.getPrefix() };
		return(result);
	}

	public struct function getAllVirtualUris() output='false' {
		var q = new Query(dataSource=this.DSN);
		q.addParam(name='Active',value=1,cfSqlType='BIT');

		transaction isolation='read_uncommitted' {
			var qResult = q.execute(sql='
				SELECT
					VU.VirtualUriId,
					VU.URI,
					VU.URL,
					VU.Framework,
					VU.FrameworkIsDynamic,
					VU.ViewName,
					VU.ViewTemplate,
					VU.ChildViewName,
					VU.ChildViewTemplate,
					VU.MappedAsset,
					VU.AssetMapping,
					VU.IsConical,
					VU.DoRedirect,
					VU.IsDefault,
					VU.Active,
					VU.Description,
					CT.ContentType,
					RT.RedirectType,
					RT.RedirectCode 
				FROM VirtualUris AS VU WITH (NOLOCK) 
					LEFT OUTER JOIN ContentTypes AS CT WITH (NOLOCK) ON CT.ContentTypeId = VU.ContentTypeId 
					LEFT OUTER JOIN RedirectTypes AS RT WITH (NOLOCK) ON RT.RedirectTypeId = VU.RedirectTypeId 
				WHERE VU.Active = :Active
			');
		}

		var result = { results=qResult.getResult(), metaInfo=qResult.getPrefix() };
		return(result);
	}

	public void function onMissingMethod(string methodName, any methodArguments) output='false' {
		if(Application.Settings.isMailAvailable) Application.Mail.send(to=Application.Settings.emailLists.Errors,subject='[#Application.Settings.serverId#] Missing Method Error',msg='There was a Missing Method error [#cgi.SERVER_NAME#]',obj=Arguments);
		return;
	}

}