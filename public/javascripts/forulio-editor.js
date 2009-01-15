// Define Button Object
var ForulioEditorButton = Class.create();
ForulioEditorButton.prototype = {
	initialize: function(options){
		if (!options) 
			options = {};
		
		this.image = options['image'];
		this.access = options['access'];
		this.title = options['title'];
		this.separator = false;
		this.standard = true;
	},
	wrap:function(text, startWrap, endWrap)
	{
		if (text.startsWith(' ')) startWrap = ' ' + startWrap;
		if (text.endsWith(' ')) endWrap = endWrap + ' ';
		return startWrap + text.replace(/^\s+|\s+$/ig, "") + endWrap;
	},
	createImageButton:function(image, className){
		var theButton = document.createElement("button");
		theButton.className = className;
		var img = document.createElement('img');
		img.src = '/images/forulio-editor/' + image;
		theButton.appendChild(img);
		return theButton;
	},
	render:function(editor) {
		var theButton = this.createImageButton(this.image, 'standard');
		theButton.accessKey = this.access;
		theButton.title = this.title;
		
		editor.toolbar.appendChild(theButton);
		Event.observe(theButton, 'click', editor.processTag.bind(editor, this));
	},
	processCommand: function(editor, text){
		editor.replaceSelection(text);
	}
}
var ForulioEditorButtonSeparator = Class.create();
ForulioEditorButtonSeparator.prototype.initialize = function() { this.separator = true;}

var ForulioEditorConfig = {
	buttons:[],
	appendButtons:function(buttonType, buttons) {
		buttons.each(this.append.bind(this, buttonType));
	},
	append:function(buttonType, button){
		this.buttons.push(new buttonType(button));
	}
};
var ForulioEditor = Class.create();
ForulioEditor.prototype = {
	// class methods
	// create the toolbar (edToolbar)
	initialize: function(canvas){
		var toolbar = document.getElementById(canvas + "_toolbar");
		this.canvas = document.getElementById(canvas);
		this.canvas.parentNode.insertBefore(toolbar, this.canvas);
		this.toolbar = toolbar;
		
		var edButtons = ForulioEditorConfig.buttons;
		
		for (var i = 0; i < edButtons.length; i++) {
			if (edButtons[i].separator) {
				var theButton = document.createElement('span');
				theButton.className = 'ed_sep';
				toolbar.appendChild(thisButton);
			}
			else if(edButtons[i].render) {
				Object.clone(edButtons[i]).render(this);
			}
		}
		var fcs = function () {try{document.getElementById(canvas).focus();}catch(e){}};
		setTimeout(fcs, 1000);
	},
	processTag: function(button, event){
		Event.stop(event);
		var myField = this.canvas;
		myField.focus();
		
		var context = {
			selectedText: ''
		};
		// grab the text that's going to be manipulated, by browser
		if (document.selection) //IE
		{
			context.range = document.selection.createRange();
			context.selectedText = context.range.text;
		}
		else 
			if (myField.selectionStart || myField.selectionStart == '0') // MOZ/FF/NS/S support
			{
				// figure out cursor and selection positions
				context.startPos = myField.selectionStart;
				context.endPos = myField.selectionEnd;
				context.scrollTop = myField.scrollTop;
				if (context.startPos != context.endPos) 
					context.selectedText = myField.value.substring(context.startPos, context.endPos);
			}
		this.context = context;
		button.processCommand(this, context.selectedText);
	},
	replaceSelection: function(text){
		var myField = this.canvas;
		var context = this.context;
		// set the appropriate DOM value with the final text
		if (!Prototype.Browser.IE) {
			var cursorPos = context.startPos + text.length;
			myField.value = myField.value.substr(0, context.startPos) + text + myField.value.substr(context.endPos);
			myField.selectionStart = cursorPos;
			myField.selectionEnd = cursorPos;
			myField.scrollTop = context.scrollTop;
		}
		else {
			context.range.text = text;
		}
		myField.focus();
	},
	appendText:function(text) {
		var myField = this.canvas;
		var context = this.context;
		// set the appropriate DOM value with the final text
		if (!Prototype.Browser.IE) {
			myField.value = myField.value + text;
			myField.selectionStart = myField.value.length;
			myField.selectionEnd = myField.value.length;
			myField.scrollTop = context.scrollTop;
		}
		else {
			document.selection.empty();
			myField.value = myField.value + text;
		}
		myField.focus();
	},
	insertUnderCursor:function(text) {
		var myField = this.canvas;
		var context = this.context;
		// set the appropriate DOM value with the final text
		if (!Prototype.Browser.IE) {
			var cursorPos = context.endPos + text.length;
			myField.value = myField.value.substr(0, context.endPos) + text + myField.value.substr(context.endPos);
			myField.selectionStart = cursorPos;
			myField.selectionEnd = cursorPos;
			myField.scrollTop = context.scrollTop;
		}
		else {
			context.range.text = context.selectedText + text;
			document.selection.empty();
		}
		myField.focus();
	}
};