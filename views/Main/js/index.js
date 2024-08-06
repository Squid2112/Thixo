$(document).ready(function() {
	Shadowbox.init({
		handleOversize: "drag",
		modal: true
	});

	$('#switch').click(function() {
		if($(this).children().attr('class') === 'switchOff') {
			$(this).children().removeClass('switchOff');
			$(this).children().addClass('switchOn');
/*
			Shadowbox.open({
				content:    '<div id="welcome-msg">Welcome to my website!</div>',
        player:     "html",
        title:      "Welcome",
        height:     350,
        width:      350
			});
*/
			$('#viewerPlaceHolder').css('display','block');
		} else {
			$(this).children().removeClass('switchOn');
			$(this).children().addClass('switchOff');
			$('#viewerPlaceHolder').css('display','none');
		}
	});

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