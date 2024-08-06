<cfcomponent displayname="DatabaseObjectComponent" output="no">
 	<cfsetting showdebugoutput="no" enablecfoutputonly="no">

	<cffunction name="init" returntype="any" access="public" output="no">
		<cfargument name="DSN" type="any" required="no" default="#application.Settings.DSN.Application#">
		<cfscript>
			this.DSN = Arguments.DSN;

			return(this);
		</cfscript>
	</cffunction>

	<cffunction name="saveWebRequest" returntype="any" access="public" output="no">
		<cfscript>
			var browserMetrics = '';
			
			try {
				browserMetrics = {
					url = Arguments.url,
					browserStart = Arguments.browserStart,
					browserEnd = Arguments.browserEnd,
					serverStart = Arguments.serverStart,
					serverEnd = Arguments.serverEnd
				};
			} catch(Any E) {
				Application.mail.send(to=arrayToList(Application.Settings.emailAddresses.errors),subject='ERROR: saveWebRequest',obj=cfcatch);
			}
		</cfscript>

		<cftry>
			<cfquery datasource="WebMetrics">
				INSERT INTO browserRequests (
					URL,
					browserStart,
					browserEnd,
					browserElapsed,
					serverStart,
					serverEnd,
					serverElapsed,
					Stamp
				) VALUES (
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(left(urlDecode(browserMetrics.url),1000))#">,
					<cfqueryparam cfsqltype="cf_sql_decimal" value="#browserMetrics.browserStart#">,
					<cfqueryparam cfsqltype="cf_sql_decimal" value="#browserMetrics.browserEnd#">,
					<cfqueryparam cfsqltype="cf_sql_decimal" value="#(browserMetrics.browserEnd-browserMetrics.browserStart)#">,
					<cfqueryparam cfsqltype="cf_sql_decimal" value="#browserMetrics.serverStart#">,
					<cfqueryparam cfsqltype="cf_sql_decimal" value="#browserMetrics.serverEnd#">,
					<cfqueryparam cfsqltype="cf_sql_decimal" value="#(browserMetrics.serverEnd-browserMetrics.serverStart)#">,
					<cfqueryparam cfsqltype="cf_sql_timestamp" value="#Now()#">
				)
			</cfquery>
			<cfcatch type="any">
				<cfset Application.mail.send(to=arrayToList(Application.Settings.emailAddresses.errors),subject='ERROR: saveWebRequest/record insert',obj=cfcatch)>
			</cfcatch>
		</cftry>
	</cffunction>



	<cffunction name="getMetaTags" returntype="any" access="public" output="no">
		<cfargument name="Template" type="any" required="no" default="global">
		<cfset var result = "">

		<cftransaction isolation="read_uncommitted">
			<cfquery name="result" datasource="#this.DSN#">
				SELECT TOP (1) *
				FROM MetaTags WITH (NOLOCK)
				WHERE Template = <cfqueryparam cfsqltype="cf_sql_varchar" value="#Arguments.Template#">
			</cfquery>
		</cftransaction>

		<cfif NOT result.RecordCount>
			<cftransaction isolation="read_uncommitted">
				<cfquery name="result" datasource="#this.DSN#">
					SELECT TOP (1) *
					FROM MetaTags WITH (NOLOCK)
					WHERE Template = <cfqueryparam cfsqltype="cf_sql_varchar" value="global">
				</cfquery>
			</cftransaction>
		</cfif>

		<cfreturn result>
	</cffunction>

	<cffunction name="getPageContents" returntype="any" access="public" output="no">
		<cfargument name="ContentID" type="any" required="no">
		<cfargument name="VirtualUriId" type="any" required="no">
		<cfargument name="ViewName" type="any" required="no">
		<cfargument name="VirtualPath" type="any" required="no">
		<cfargument name="ViewTemplate" type="any" required="no">
		<cfargument name="Template" type="any" required="no">
		<cfargument name="Scope" type="any" required="no">
		<cfargument name="Area" type="any" required="no">
		<cfargument name="Position" type="any" required="no">
		<cfset var result = "">

		<cftransaction isolation="read_uncommitted">
			<cfquery name="result" datasource="#this.DSN#">
				SELECT PGC.*
				FROM PageContents AS PGC WITH (NOLOCK)
				WHERE
					1 = <cfqueryparam cfsqltype="cf_sql_integer" value="1">
					<cfif structKeyExists(Arguments,"ContentId")>AND PGC.ContentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(Arguments.ContentID)#"></cfif>
					<cfif structKeyExists(Arguments,"VirtualUriId")>AND PGC.VirtualUriId = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(Arguments.VirtualUriId)#"></cfif>
					<cfif structKeyExists(Arguments,"ViewName")>AND PGC.ViewName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Arguments.ViewName)#"></cfif>
					<cfif structKeyExists(Arguments,"VirtualPath")>AND PGC.VirtualPath = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Arguments.VirtualPath)#"></cfif>
					<cfif structKeyExists(Arguments,"ViewTemplate")>AND PGC.ViewTemplate = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Arguments.ViewTemplate)#"></cfif>
					<cfif structKeyExists(Arguments,"Template")>AND PGC.Template = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Arguments.Template)#"></cfif>
					<cfif structKeyExists(Arguments,"Scope")>AND PGC.Scope = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Arguments.Scope)#"></cfif>
					<cfif structKeyExists(Arguments,"Area")>AND PGC.Area = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Arguments.Area)#"></cfif>
					<cfif structKeyExists(Arguments,"Position")>AND PGC.Position = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(Arguments.Position)#"></cfif>
			</cfquery>
		</cftransaction>
		<cfreturn result>
	</cffunction>

	<cffunction name="OnMissingMethod" returntype="any" access="public" output="no">
		<cfargument name="MissingMethodName" type="string" required="true">
		<cfargument name="MissingMethodArguments" type="struct" required="true">
		<cfreturn "">
	</cffunction>

</cfcomponent>
