var docViewer=false;

function getDocViewer() {
	if(docViewer) return(docViewer);
	docViewer = window.FlexPaperViewer_Instance.getApi();
	return(docViewer);
}

window.FlexPaperViewer = window.$f = function() {
	var config = arguments[2].config;

	window.FlexPaperViewer_Instance = flashembed(arguments[1], {
		src: arguments[0] + '.swf',
		version: [10,0],
		expressInstall: '/js/expressinstall.swf'
	},{
		SwfFile: escape(config.SwfFile),
		Scale: config.Scale, 
		ZoomTransition: config.ZoomTransition,
		ZoomTime: config.ZoomTime,
		ZoomInterval: config.ZoomInterval,
		FitPageOnLoad: config.FitPageOnLoad,
		FitWidthOnLoad: config.FitWidthOnLoad,
		PrintEnabled: config.PrintEnabled,
		FullScreenAsMaxWindow: config.FullScreenAsMaxWindow,
		ProgressiveLoading: config.ProgressiveLoading,
		MinZoomSize: config.MinZoomSize,
		MaxZoomSize: config.MaxZoomSize,
		SearchMatchAll: config.SearchMatchAll,
		SearchServiceUrl: config.SearchServiceUrl,
		InitViewMode: config.InitViewMode,
		BitmapBasedRendering: config.BitmapBasedRendering,
		StartAtPage: config.StartAtPage,
		ViewModeToolsVisible: config.ViewModeToolsVisible,
		ZoomToolsVisible: config.ZoomToolsVisible,
		NavToolsVisible: config.NavToolsVisible,
		CursorToolsVisible: config.CursorToolsVisible,
		SearchToolsVisible: config.SearchToolsVisible,
		localeChain: config.localeChain,
		key: config.key
	});
};

function onExternalLinkClicked(link) {
	window.location.href = link;
}

function onProgress(loadedBytes,totalBytes) {
}

function onDocumentLoading() {
}

function onCurrentPageChanged(pagenum) {
}

function onDocumentLoaded(totalPages) {
}

function onPageLoading(pageNumber) {
}

function onPageLoaded(pageNumber) {
}

function onDocumentLoadedError(errMessage) {
}

function onDocumentPrinted() {
}


(function() {
	var IE = document.all,
		URL = 'http://www.adobe.com/go/getflashplayer',
		JQUERY = (typeof(jQuery) == 'function'),
		RE = /(\d+)[^\d]+(\d+)[^\d]*(\d*)/,
		GLOBAL_OPTS = { 
			width: '100%',
			height: '100%',		
			id: "_" + ("" + Math.random()).slice(9),

			allowfullscreen: true,
			allowscriptaccess: 'always',
			quality: 'high',

			version: [3,0],
			onFail: null,
			expressInstall: null, 
			w3c: false,
			cachebusting: false  		 		 
		};

	if(window.attachEvent) {
		window.attachEvent("onbeforeunload", function() {
			__flash_unloadHandler = function() {};
			__flash_savedUnloadHandler = function() {};
		});
	}
	
	function extend(to, from) {
		if(from) {
			for(var key in from) {
				if(from.hasOwnProperty(key)) to[key] = from[key];
			}
		} 
		return(to);
	}	

	function map(arr, func) {
		var newArr = []; 
		for(var i in arr) {
			if(arr.hasOwnProperty(i)) newArr[i] = func(arr[i]);
		}
		return(newArr);
	}

	window.flashembed = function(root, opts, conf) {
		if(typeof(root) == 'string') root = document.getElementById(root.replace('#',''));
		if(!root) return;
		root.onclick = function(){ return(false); };
		if(typeof(opts) == 'string') opts = { src: opts };
		return(new Flash(root, extend(extend({}, GLOBAL_OPTS), opts), conf));
	};

	var f = extend(window.flashembed, {
		conf: GLOBAL_OPTS,
		getVersion: function() {
			var fo, ver;
			try {
				ver = navigator.plugins["Shockwave Flash"].description.slice(16); 
			} catch(e) {
				try {
					fo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.7");
					ver = fo && fo.GetVariable("$version");
				} catch(err) {
					try {
						fo = new ActiveXObject("ShockwaveFlash.ShockwaveFlash.6");
						ver = fo && fo.GetVariable("$version");
					} catch(err2) { }
				}
			}

			ver = RE.exec(ver);
			return ver ? [ver[1], ver[3]] : [0,0];
		},

		asString: function(obj) {
			if(obj === null || obj === undefined) return(null);

			var type = typeof(obj);
			if(type == 'object' && obj.push) type = 'array';
			switch(type) {
				case 'string':
					obj = obj.replace(new RegExp('(["\\\\])', 'g'), '\\$1');
					obj = obj.replace(/^\s?(\d+\.?\d+)%/, "$1pct");
					return('"' +obj+ '"');

				case 'array':
					return('['+ map(obj, function(el) {
						return(f.asString(el));
					}).join(',') +']');
					
				case 'function':
					return('"function()"');
					
				case 'object':
					var str = [];
					for(var prop in obj) {
						if(obj.hasOwnProperty(prop)) {
							str.push('"'+prop+'":'+ f.asString(obj[prop]));
						}
					}
					return('{'+str.join(',')+'}');
			}
			return(String(obj).replace(/\s/g, " ").replace(/\'/g, "\""));
		},
		
		getHTML: function(opts, conf) {
			opts = extend({}, opts);
			var html = '<object width="' + opts.width + 
				'" height="' + opts.height + 
				'" id="' + opts.id + 
				'" name="' + opts.id + '"';

			if(opts.cachebusting) {
				opts.src += ((opts.src.indexOf("?") != -1 ? "&" : "?") + Math.random());
			}			

			if(opts.w3c || !IE) {
				html += ' data="' +opts.src+ '" type="application/x-shockwave-flash"';
			} else {
				html += ' classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"';
			}
			html += '>';
			if(opts.w3c || IE) html += '<param name="movie" value="' +opts.src+ '" />';

			opts.width = opts.height = opts.id = opts.w3c = opts.src = null;
			opts.onFail = opts.version = opts.expressInstall = null;

			for (var key in opts) {
				if (opts[key]) {
					html += '<param name="'+ key +'" value="'+ opts[key] +'" />';
				}
			}
		
			var vars = "";

			if(conf) {
				for(var k in conf) {
					if(conf[k]) {
						var val = conf[k];
						vars += k +'='+ (/function|object/.test(typeof val) ? f.asString(val) : val) + '&';
					}
				}
				vars = vars.slice(0, -1);
				html += '<param name="flashvars" value=\'' + vars + '\' />';
			}
			html += "</object>";
			return(html);
		},

		isSupported: function(ver) {
			return(VERSION[0] > ver[0] || VERSION[0] == ver[0] && VERSION[1] >= ver[1]);
		}
	});

	var VERSION = f.getVersion();

	function Flash(root, opts, conf) {
		if(f.isSupported(opts.version)) {
			root.innerHTML = f.getHTML(opts, conf);
		} else if (opts.expressInstall && f.isSupported([6, 65])) {
			root.innerHTML = f.getHTML(extend(opts, {src: opts.expressInstall}), {
				MMredirectURL: location.href,
				MMplayerType: 'PlugIn',
				MMdoctitle: document.title
			});
		} else {
			if(!root.innerHTML.replace(/\s/g, '')) {
				var pageHost = ((document.location.protocol == "https:") ? "https://" :	"http://");
				root.innerHTML = "<a href='http://www.adobe.com/go/getflashplayer'><img src='" + pageHost + "www.adobe.com/images/shared/download_buttons/get_flash_player.gif' alt='Get Adobe Flash player' /></a>";
				if(root.tagName == 'A') {
					root.onclick = function() {
						location.href = URL;
					};
				}
			}
			if(opts.onFail) {
				var ret = opts.onFail.call(this);
				if (typeof ret == 'string') { root.innerHTML = ret; }
			}
		}
		if(IE) window[opts.id] = document.getElementById(opts.id);

		extend(this, {
			getRoot: function() {
				return(root);
			},
			getOptions: function() {
				return(opts);
			},
			getConf: function() {
				return(conf);
			},
			getApi: function() {
				return(root.firstChild);
			}
		});
	}

	if(JQUERY) {
		jQuery.tools = jQuery.tools || {version: '1.2.5'};
		jQuery.tools.flashembed = { conf: GLOBAL_OPTS };
		jQuery.fn.flashembed = function(opts, conf) {
			return(this.each(function() {
				$(this).data("flashembed", flashembed(this, opts, conf));
			}));
		};
	}

})();
