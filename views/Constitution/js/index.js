$(document).ready(function() {
	var fp = new FlexPaperViewer(	
		'/assets/swf/FlexPaperViewer',
		'viewerPlaceHolder', {
			config: {
				SwfFile: escape('/assets/pdf/swfs/US-Constitution.swf'),
				Scale:0.6, 
				ZoomTransition:'easeOut',
				ZoomTime:0.5,
				ZoomInterval:0.2,
				FitPageOnLoad:true,
				FitWidthOnLoad:false,
				PrintEnabled:true,
				FullScreenAsMaxWindow:false,
				ProgressiveLoading:true,
				MinZoomSize:0.2,
				MaxZoomSize:5,
				SearchMatchAll:false,
				InitViewMode:'TwoPage',	// or Portrait
				ViewModeToolsVisible:true,
				ZoomToolsVisible:true,
				NavToolsVisible:true,
				CursorToolsVisible:true,
				SearchToolsVisible:true,
				localeChain:'en_US'
			}
		}
	);
});