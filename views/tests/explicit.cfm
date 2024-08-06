<cfscript>
		searchTerm = listLast(reReplace(Arguments.vInfo.VirtualPath, '-|_', ' ', 'ALL'), '/');
		vResult = Arguments.vInfo;
		q = new Query();
		result = '';
		qResult = '';
		metaInfo = '';
		
		q.setDatasource(this.DSN);
		q.addParam(name='URI',value=searchTerm,cfsqltype='VARCHAR');
		q.addParam(name='Active',value=1,cfsqltype='BIT');
		qResult = q.execute(sql=
			'SELECT' &
				'VU.VirtualUriId,' &
				'VU.URI,' &
				'VU.URL,' &
				'VU.Framework,' &
				'VU.FrameworkIsDynamic,' &
				'VU.ViewName,' &
				'VU.ViewTemplate,' &
				'VU.ChildViewName,' &
				'VU.ChildViewTemplate,' &
				'VU.MappedAsset,' &
				'VU.AssetMapping,' &
				'VU.IsConical,' &
				'VU.DoRedirect,' &
				'VU.IsDefault,' &
				'VU.Active,' &
				'VU.Description,' &
				'CT.ContentType,' &
				'RT.RedirectType,' &
				'RT.RedirectCode' &
			'FROM VirtualUris AS VU' &
				'LEFT OUTER JOIN ContentTypes AS CT ON CT.ContentTypeId = VU.ContentTypeId' &
				'LEFT OUTER JOIN RedirectTypes AS RT ON RT.RedirectTypeId = VU.RedirectTypeId' &
			'WHERE' &
				'VU.URI = :URI' &
				'AND VU.Active :Active'
		);

		result = qResult.getResult();
		metaInfo = qResult.getPrefix();

		if(!metaInfo.recordCount) return(Arguments.vInfo);

		vResult = {
			VirtualURIid = result.VirtualURIid[1],
			URI = result.URI[1],
			URL = result.URL[1],
			ContentType = result.ContentType[1],
			RedirectType = result.RedirectType[1],
			RedirectCode = result.RedirectCode[1],
			Framework = result.Framework[1],
			FrameworkIsDynamic = result.FrameworkIsDynamic[1],
			ViewName = result.ViewName[1],
			ViewTemplate = result.ViewTemplate[1],
			ChildViewName = result.ChildViewName[1],
			ChildViewTemplate = result.ChildViewTemplate[1],
			MappedAsset = result.MappedAsset[1],
			AssetMapping = result.AssetMapping[1],
			IsConical = result.IsConical[1],
			DoRedirect = result.DoRedirect[1],
			IsDefault = result.IsDefault[1],
			Active = result.Active[1],
			Description = result.Description[1],
			RecordCount = result.recordCount
		};

</cfscript>