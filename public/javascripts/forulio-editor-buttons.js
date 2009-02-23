var ForulioEditorWrapButton = Class.create(ForulioEditorButton, 
{   
    initialize: function($super, options) {
        $super(options);
        this.tagName = options['tagName'];
    },
    processCommand:function(editor, text) { 
      text = this.wrap(text, "[" + this.tagName + "]", "[/" + this.tagName + "]");
      editor.replaceSelection(text); 
    }
});
var ForulioEditorPromptUrlButton = Class.create(ForulioEditorButton, 
{ 
	initialize: function($super, options) {
        $super(options);
        this.tagName = options['tagName'];
		    this.link = options['link'];
        this.prompt = options['prompt'];
        this.replace = options['replace'];
  },
	processCommand:function(editor, text) { 
    var url = window.prompt(this.prompt, this.link);
	  if (!url) return;
    var opts = { tagName: this.tagName, url: url};
    var endTag = "[/#{tagName}]".interpolate(opts);
	  
    if(text && this.replace) editor.replaceSelection(this.wrap(text, "[#{tagName}=#{url}]".interpolate(opts), endTag));
	  else editor.insertUnderCursor("[#{tagName}]".interpolate(opts) + url + endTag);
  }
});
var ForulioEditorPopupButton = Class.create(ForulioEditorButton, 
{
	initialize: function($super, options) {
      $super(options);
      this.mainButton = null;
	    this.currentText = null;
  },
	render:function(editor) {
		var theButton = this.createImageButton(this.image, 'standard');
		this.mainButton = theButton;
		theButton.style.width = "32px";
		
		var img = document.createElement('img');
		img.src = '/images/forulio-editor/menupop.gif';
		img.className = 'popup'
		theButton.appendChild(img);
		
		theButton.accessKey = this.access;
		theButton.title = this.title;
		editor.toolbar.appendChild(theButton);
		
		Event.observe(theButton, 'click', editor.processTag.bind(editor, this));
	},
	hidePopup:function()
	{
		this.popup.hide();
	},
	renderPopup:function(editor, container){
		
	},
	createPopup:function(editor) {
		if (!this.popup)
		{
			this.popup = $(document.createElement('div'));
			this.popup.setStyle({
				display:'none',
				position:'absolute'
			});
			this.popup.className = 'forulio-popup'
			document.body.appendChild(this.popup);	
			this.renderPopup(editor, this.popup);
			Event.observe(document, 'click', this.hidePopup.bind(this));
		}
		var pos = Position.cumulativeOffset(this.mainButton);
		var size = Element.getDimensions(this.mainButton);
		this.popup.setStyle({
				left:pos[0] + 'px',
				top:(pos[1] + size.height + 2) + "px",
				display:''
			});
	},
	processCommand:function(editor, text) { 
  		try{
  			this.currentText = text;
  			this.createPopup(editor);	
  		}catch(e) {alert(e.message);}
    }
});
var ForulioEditorColorButton = Class.create(ForulioEditorPopupButton, 
{
	renderPopup:function(editor, container){
		container.addClassName('forulio-popup-colors')
		var table = $(document.createElement('table'));
		with(table)
		{
			cellPadding = 0,
			cellSpacing = 0,
			border = 0
		}
		var colors = [
			['Black', 'Sienna', 'DarkOliveGreen', 'DarkGreen', 'DarkSlateBlue', 'Navy', 'Indigo', 'DarkSlateGray'],
			['DarkRed', 'DarkOrange', 'Olive', 'Green', 'Teal', 'Blue', 'SlateGray', 'DimGray'],
			['Red', 'SandyBrown', 'YellowGreen', 'SeaGreen', 'MediumTurquoise', 'RoyalBlue', 'Purple', 'Gray'],
			['Magenta', 'Orange', 'Yellow', 'Lime', 'Cyan', 'DeepSkyBlue', 'DarkOrchid', 'Silver'],
			['Pink', 'Wheat', 'LemonChiffon', 'PaleGreen', 'PaleTurquoise', 'LightBlue', 'Plum', 'White']
		];
		var me = this;
		colors.each(function(line){
			var tr = table.insertRow(table.rows.length);
			line.each(function(color){
				var cell = tr.insertCell(tr.cells.length);
				cell.align = "center";
				cell.innerHTML = '<div class="item" style="background-color:'+color+'"></div>';
				Event.observe(cell, 'click', me.selectColor.bind(me, editor, color));
			});
		});
		container.appendChild(table);
	},
	selectColor:function(editor, color) { 
     	var text = this.wrap(this.currentText, "[color=" + color + "]", '[/color]');
      	editor.replaceSelection(text); 
    }
});

var ForulioEditorInsertVideoButton = Class.create(ForulioEditorPopupButton, 
{
	renderPopup:function(editor, container){
		container.addClassName('forulio-popup-video')
		var table = $(document.createElement('table'));
		with(table)
		{
			cellPadding = 0,
			cellSpacing = 0,
			border = 0
		}
		var services = [ {name:'youtube', url:'http://www.youtube.com/watch?v=<video id>'}, {name:'vimeo', url:'http://www.vimeo.com/<video id>'} ];
		var me = this;
		services.each(function(serv){
			var tr = table.insertRow(table.rows.length);
			var cell = tr.insertCell(tr.cells.length);
			cell.align = "center";
      cell.innerHTML = '<div class="item"><img src="/images/forulio-editor/'+serv.name+'.gif"/><span>'+serv.name+'</span></div>';
			Event.observe(cell, 'click', me.insertVideo.bind(me, editor, serv));
		});
		container.appendChild(table);
	},
	insertVideo:function(editor, service) { 
      var v_url = window.prompt('Video url:', service.url);
      if (!v_url)return;
      var text = "[video=" + service.name + "]" + v_url + '[/video]';
      editor.insertUnderCursor(text);
  }
});

var ForulioEditorFontSizeButton = Class.create(ForulioEditorPopupButton, 
{
	renderPopup:function(editor, container){
		container.addClassName('forulio-popup-font-size')
		var table = $(document.createElement('table'));
		with(table)
		{
			cellPadding = 0,
			cellSpacing = 0,
			border = 0
		}
		var sizes = [
      [0.7, 'Small'], [1, 'Normal'], [1.5, 'Big'], [2, 'Very big']];
		var me = this;
		sizes.each(function(opts){
			var tr = table.insertRow(table.rows.length);
			var cell = tr.insertCell(tr.cells.length);
			cell.align = "left";
      cell.innerHTML = ('<div class="item"><span style="font-size: #{size}em">#{name}</span></div>'.interpolate({size:opts[0], name:opts[1]}));
      Event.observe(cell, 'click', me.fontSelected.bind(me, editor, opts[0]));
		});
		container.appendChild(table);
  },
    fontSelected:function(editor, size) {
	    var text = this.currentText;
	    if (text) editor.replaceSelection(this.wrap(text, "[size=" + size + "]", "[/size]"));
		  else editor.insertUnderCursor("[size=" + size + "]" + text + "[/size]");
   }
});
var ForulioEditorSmileButton = Class.create(ForulioEditorPopupButton, 
{
	renderPopup:function(editor, container){
		container.addClassName('forulio-popup-smilies')
		var table = $(document.createElement('table'));
		with(table)
		{
			cellPadding = 0,
			cellSpacing = 0,
			border = 0
		}
		var smiles = [[["O:-)", "aa.gif"], [":-)", "ab.gif"], [":-(", "ac.gif"], [";-)", "ad.gif"], [":-P", "ae.gif"], ["8-)", "af.gif"], [":-D", "ag.gif"]], [[":-[", "ah.gif"], ["=-O", "ai.gif"], [":-*", "aj.gif"], [":'(", "ak.gif"], [":-X", "al.gif"], ["&gt;:o", "am.gif"], [":-|", "an.gif"]], [[":-/", "ao.gif"], ["*JOKINGLY*", "ap.gif"], ["]:-&gt;", "aq.gif"], ["[:-}", "ar.gif"], ["*KISSED*", "as.gif"], [":-!", "at.gif"], ["*TIRED*", "au.gif"]], [["*STOP*", "av.gif"], ["*KISSING*", "aw.gif"], ["@}-&gt;--", "ax.gif"], ["*THUMBS UP*", "ay.gif"], ["*DRINK*", "az.gif"], ["*IN LOVE*", "ba.gif"], ["*HELP*", "bc.gif"]], [["\\m/", "bd.gif"], ["%)", "be.gif"], ["*OK*", "bf.gif"], ["*WASSUP*", "bg.gif"], ["*SORRY*", "bh.gif"], ["*BRAVO*", "bi.gif"], ["*LOL*", "bj.gif"]], [["*PARDON*", "bk.gif"], ["*NO*", "bl.gif"], ["*CRAZY*", "bm.gif"], ["*DONT_KNOW*", "bn.gif"], ["*DANCE*", "bo.gif"], ["*YAHOO*", "bp.gif"], ["*FRIENDS*", "bq.gif"]]];
    
		var me = this;
		smiles.each(function(line){
			var tr = table.insertRow(table.rows.length);
			line.each(function(entry){
				var smile = {code:entry[0], image: entry[1]};
        var cell = tr.insertCell(tr.cells.length);
				cell.align = "center";
        
        cell.innerHTML = '<div class="item" style="background-image:url(/images/smilies/'+smile.image+')"></div>';
				Event.observe(cell, 'click', me.selectSmile.bind(me, editor, smile));
			});
		});
		container.appendChild(table);
	},
	selectSmile:function(editor, smile) { editor.insertUnderCursor(smile.code); }
});

var ForulioEditorResizeEditorButton = Class.create(ForulioEditorButton, 
{   
	render:function(editor) {
		var buttons_div = document.createElement('div');
		buttons_div.className = 'resize_buttons'
		
		var b_up = this.createImageButton('resize_up.gif', 'standard resize');
		var b_down = this.createImageButton('resize_down.gif', 'standard resize');
		
		buttons_div.appendChild(b_up);
		buttons_div.appendChild(document.createElement('br'));
		buttons_div.appendChild(b_down);
		
		editor.toolbar.insertBefore(buttons_div, editor.toolbar.childNodes[0]);
		Event.observe(b_up, 'click', this.doResize.bind(this, editor, -2));
		Event.observe(b_down, 'click', this.doResize.bind(this, editor, 2));
	},
	doResize:function(editor, increase, event){
		var rows = editor.canvas.rows + increase;
		if (rows > 4 && rows < 100) editor.canvas.rows = rows; 
		Event.stop(event);
	}
});


ForulioEditorConfig.appendButtons(ForulioEditorWrapButton, [
  {image:'bold.png', access:'b', title:'Bold', tagName:'b'},
  {image:'italic.png', access:'i', title:'Italic', tagName:'i'},
  {image:'underline.png', access:'u', title:'Underline', tagName:'u'},
  {image:'strikethrough.png', access:'d', title:'Delete', tagName:'del'},
  {image:'code.gif', access:'', title:'Code', tagName:'code'}
]);
ForulioEditorConfig.appendButtons(ForulioEditorPromptUrlButton, [
  {image:'createlink.gif', access:'', title:'url', tagName:'url', link:'http://', prompt:'Select link url:', replace:true},
  {image:'insertimage.gif', access:'', title:'Insert Image', tagName:'img', link:'http://',prompt:'Image url:', replace:false}
]);
ForulioEditorConfig.appendButtons(ForulioEditorInsertVideoButton, [ {image:'video.gif', access:'', title:'Insert Video'}]);
ForulioEditorConfig.appendButtons(ForulioEditorColorButton, [ {image:'color.gif', access:'', title:'Color'}]);
ForulioEditorConfig.appendButtons(ForulioEditorFontSizeButton,    [ {image:'size.gif', access:'', title:'Font Size'}]);
ForulioEditorConfig.appendButtons(ForulioEditorSmileButton, [ {image:'smile.gif', access:'', title:'Smilies'}]);
ForulioEditorConfig.appendButtons(ForulioEditorResizeEditorButton, [ {image:'color.gif', access:'', title:'Smilies'}]);