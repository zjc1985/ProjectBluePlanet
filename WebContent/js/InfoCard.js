
function infoCard(id){
	var idName=id;
	var jqueryId="#"+idName;
	var ASideId='';
	var BSideId='';
	var hideButtonId='';
	var rotateButtonId;
	
	var titleId='';
	var categoryId='';
	var addressId='';
	var mycommentId='';
	var iconUrlId='';
	
	var editFormIdName=idName+'EditForm';
	var editFormTitleIdName=editFormIdName+'Title';
	var editFormCategoryIdName=editFormIdName+'Category';
	var editFormAddresIdName=editFormIdName+'Address';
	var editFormMycommentIdName=editFormIdName+'Mycomment';
	var editFormIconUrlIdName=editFormIdName+'IconUrl';
	
	var isASideShow=true;
	
	this.editFormOK=function(){
		this.setDefaultContent({
			title:$('#'+editFormTitleIdName).val(),
			category:$('#'+editFormCategoryIdName).val(),
			address:$('#'+editFormAddresIdName).val(),
			mycomment:$('#'+editFormMycommentIdName).val(),
			categoryIconUrl:$('#'+editFormIconUrlIdName).val()
		});
	};
	
	this.setDefaultContent=function(content){
		if(content.title!=''){
			$(titleId).empty();
			$(titleId).html(content.title);
		}
		
		if(content.category!=''){
			$(categoryId).empty();
			$(categoryId).html(content.category);
		}
		
		if(content.address!=''){
			$(addressId).empty();
			$(addressId).html(content.address);
		}
		
		if(content.mycomment!=''){
			$(mycommentId).empty();
			$(mycommentId).html(content.mycomment);
		}
		
		if(content.categoryIconUrl!=''){
			$(iconUrlId).empty();
			$(iconUrlId).attr("src",content.categoryIconUrl);
		}
	};
	
	this.setContentA=function(html,isGallery){
		this.contentA=html;
		$(ASideId).empty();
		$(ASideId).append(this.contentA);
		if(isGallery){
			initAllGallery();
		};
	};
	
	this.setContentB=function(html,isGallery){
		this.contentB=html;
		$(BSideId).empty();
		$(BSideId).append(this.contentB);
		if(isGallery){
			initAllGallery();
		};
	};
	
	this.show=function(){
		$(jqueryId).show();
	};
	
	this.hide=function(){
		$(jqueryId).hide();
	};
	
	this.resetLocation=function(top,left){
		$(jqueryId).css("top",top);
		$(jqueryId).css("left",left);
	};
	
	this.getWidth=function(){
		var s= $(jqueryId).css("width");
		//will return "440px", need to cut 'px'
		return parseInt(s);
	};
	
	this.getHeight=function(){
		var s= $(jqueryId).css("height");
		//will return "440px", need to cut 'px'
		return parseInt(s);
	};
	
	this.showContentA=function(){
		$(BSideId).hide();
		$(ASideId).show();
		isASideShow=true;
	};
	
	
		
	this.showContentB=function(){
		$(ASideId).hide();
		$(BSideId).show();
		isASideShow=false;
	};
	
	this.initDefault=function(top,left,content,imgArray){
		init(top,left);
		$(ASideId).append(createDefaultInfoHtml(content));
		$(BSideId).append(createDefaultGallery(imgArray));
		initAllGallery();
		initPopupEditForm();
	};
	
	this.initCustom=function(top,left,contentAHtml,contentBHtml){
		init(top, left);
		$(ASideId).append(contentAHtml);
		$(BSideId).append(contentBHtml);
		initAllGallery();
	};
	
	
	
	//private method
	function rotate(){
		$(jqueryId).hide("blind",{direction:"left"},300,function(){
			if(isASideShow){
				$(ASideId).hide();
				$(BSideId).show();
				isASideShow=false;
			}else{
				$(BSideId).hide();
				$(ASideId).show();
				isASideShow=true;
			}
		
		});
		
		$(jqueryId).show("blind",{direction:"left"},300,null);
	};
	
	function init(top,left){
		
		$("body").append("<div class='info' id='"+idName+"'></div>");
		$('body').append(createEditForm());
		var aSideIdName=idName+"A";
		var bSideIdName=idName+"B";
		ASideId="#"+aSideIdName;
		BSideId="#"+bSideIdName;
		
		var hideButtonIdName=idName+"HideButton";
		var rotateButtonIdName=idName+"RotateButton";
		hideButtonId="#"+hideButtonIdName;
		rotateButtonId="#"+rotateButtonIdName;
		
		$(jqueryId).draggable();
		
		$(jqueryId).append("<div id='"+aSideIdName +"'></div>");
		$(jqueryId).append("<div id='"+bSideIdName+"'></div>");
		
		
		$(BSideId).hide();
		var buttonHtml="<div style='height:20px;background-color:rgb(245,245,245);border-top-style:solid;border-width:1px;border-color:rgb(230,230,230)'>" +
				"<p class='serif' style='margin:3px 0px 0px 0px;font-size:12px;float:right'><a id='"+hideButtonIdName+"' href='#'>CLOSE X</a></p>" +
				"<p class='serif' style='margin:3px 5px 0px 0px;font-size:12px;float:left'><a id='"+rotateButtonIdName+"' href='#'>ROTATE</a></p>" +
				"<p class='serif' style='margin:3px 0px 0px 0px;font-size:12px;'><a class='popup-with-form' href='#"+editFormIdName+"'>EDIT</a></p>" +
				"</div>";
		$(jqueryId).append(buttonHtml);
		$(jqueryId).addClass("info");
		$(jqueryId).css("top",top);
		$(jqueryId).css("left",left);
		
		$(hideButtonId).click(function(){
			$(jqueryId).hide();
		});
		
		
		$(rotateButtonId).click(function(){
			rotate();
		});
	}
	
	function initPopupEditForm(){
		$('.popup-with-form').magnificPopup({
			type: 'inline',
			preloader: false,
			focus: '#name',

			// When elemened is focused, some mobile browsers in some cases zoom in
			// It looks not nice, so we disable it:
			callbacks: {
				beforeOpen: function() {
					if($(window).width() < 700) {
						this.st.focus = false;
					} else {
						this.st.focus = '#name';
					}
				}
			}
		});
	}
	
	function initAllGallery(){
		$('.popup-gallery').magnificPopup({
			delegate: 'a',
			type: 'image',
			tLoading: 'Loading image #%curr%...',
			//mainClass: 'mfp-img-mobile',
			gallery: {
				enabled: true,
				navigateByImgClick: true,
				preload: [0,1] // Will preload 0 - before current, and 1 after the current image
			},
			image: {
				tError: '<a href="%url%">The image #%curr%</a> could not be loaded.',
				titleSrc: function(item) {
					return item.el.attr('title');
				}
			}
		});
	}
	
	//args:
	//imgArray[0].url
	//imgArray[0].title
	function createDefaultGallery(imgArray){
		var ahrefs="";
		
		for(var index in imgArray){
			if(index==0){
				ahrefs=	"<a href='"+imgArray[0].url+"' title='"+imgArray[0].title+"'><div style='margin:10px;background-image: url("+imgArray[0].url+");height:300px;background-position: center;'></div></a>";
			}else{
				ahrefs+="<a style='display: none;' href='"+imgArray[index].url+"' title='"+imgArray[index].title+"'></a>";
			}
		}
		
		
		var html="<div><div class='popup-gallery'>"+ahrefs+"</div></div>";
		return html;
		
	}
	
	//title
	//category
	//address
	//mycomment
	//categoryIconUrl
	function createDefaultInfoHtml(content){
		var titleIdName=idName+'Title';
		titleId='#'+titleIdName;
		
		var categoryIdName=idName+'Category';
		categoryId='#'+categoryIdName;
		
		var addressIdName=idName+'Address';
		addressId='#'+addressIdName;
		
		var mycommentIdName=idName+'Mycomment';
		mycommentId='#'+mycommentIdName;
		
		var categoryIconUrlIdName=idName+'CategoryIconUrl';
		iconUrlId='#'+categoryIconUrlIdName;
		
		if(content.title==null){
			content.title='Unknow Location';
		}
		
		if(content.category==null){
			content.category='Unknow Category';
		}
		
		if(content.address==null){
			content.address='Unknow Address';
		}
		
		if(content.mycomment==null){
			content.mycomment='No comment';
		}
		
		if(content.categoryIconUrl==null){
			content.categoryIconUrl='resource/markers/default.png';
		}
		
		var html="<div style='background-color:rgb(245,245,245);border-bottom-style:solid;border-width:1px;border-color:rgb(230,230,230)'>"+
			"<div style='float:left;width:50px;height:50px;'><img id='"+categoryIconUrlIdName+"'src='"+content.categoryIconUrl+"'></div>"+
			"<p id='"+titleIdName+"' class='serif' style='margin:0px;color:#4577D4;'>"+content.title+"</p>"+
			"<p id='"+categoryIdName+"' class='serif' style='margin:0px;font-size:11px;'>"+content.category+"</p>"+
			"<p id='"+addressIdName+"' class='serif' style='margin:0px;font-size:11px;'>"+content.address+"</p>"+
		"</div>"+
		"<div style='width:330px;height:130px;overflow: hidden;text-overflow: ellipsis;white-space: normal;'>"+
			"<p id='"+mycommentIdName+"' class='serif' style='margin:5px;font-size:14px;'>"+content.mycomment+"</p>"+
			"<a href='#' class='serif' style='float:right;margin:0px;font-size:8px;color:#4577D4;'>show detail</a>"+
		"</div>";
		
		return html;
	}
	
	function createEditForm(){
		
		
		var html="<div id='"+editFormIdName+"' class='white-popup mfp-hide'>"+
					"<fieldset style='border:0;'>"+
						"<p>Edit Basic Info</p>"+
						"<ol>"+
			"<li><label for='title'>Title:</label>"+
			"<input id='"+editFormTitleIdName+"' name='title' type='text' placeholder='Name'>"+
			"</li>"+
			
			"<li><label for='category'>Category:</label>"+
				"<input id='"+editFormCategoryIdName+"' type='text' placeholder='Name'></li>"+
			
			"<li>"+
				"<label for='address'>Address:</label>"+
				"<input id='"+editFormAddresIdName+"' type='text' placeholder='Name'>"+
			"</li>"+
			
			"<li>"+
				"<label for='iconUrl'>IconUrl:</label>"+
				"<input id='"+editFormIconUrlIdName+"' type='text' placeholder='Name'>"+
			"</li>"+
			
			"<li>"+
				"<label for='mycomment'>My Comment:</label><br>"+
				"<textarea id='"+editFormMycommentIdName+"' style='margin: 2px; width: 509px; height: 183px;'></textarea>"+
			"</li>"+
		"</ol>"+
		"<input type='button' value='OK' onclick='editFormOK()' style='height:30px'/>"+
"</fieldset></div>";
		return html;
	}
	
}

function createTitleContentA(title,address){
	return "<div><h4>"+title+"</h4><p>"+address+"</p><div style='position:absolute;top:20px;left:300px' id='favorite'><img src='resource/favorite.png' height='120px'/></div></div>";
}


function createBasicInfo(content){
	return "<p style='overflow: auto;text-overflow:ellipsis;height:70px'>"+content+"</p>";
}

function createImgGallery(imgArray){
	var ahrefs="";
	
	for(var index in imgArray){
		if(index==0){
			ahrefs=	"<a href='"+imgArray[0].url+"' title='"+imgArray[0].title+"'><div style='margin:10px;background-image: url("+imgArray[0].url+");height:300px;background-position: center;'></div></a>";
		}else{
			ahrefs+="<a style='display: none;' href='"+imgArray[index].url+"' title='"+imgArray[index].title+"'></a>";
		}
	}
	
	
	var html="<div><div class='popup-gallery'>"+ahrefs+"</div></div>";
	return html;
	
}

function createPOICardHtml(title,category,address,mycomment,categoryIconUrl){
	var html="<div style='background-color:rgb(245,245,245);border-bottom-style:solid;border-width:1px;border-color:rgb(230,230,230)'>"+
		"<div id='icon' style='float:left;width:50px;height:50px;'><img class='iconUrl' src='"+categoryIconUrl+"'></div>"+
		"<p class='serif cardTitle' style='margin:0px;color:#4577D4;'>"+title+"</p>"+
		"<p class='serif cardCategory' style='margin:0px;font-size:11px;'>"+category+"</p>"+
		"<p class='serif cardAddress' style='margin:0px;font-size:11px;'>"+address+"</p>"+
	"</div>"+
	"<div style='width:330px;height:130px;overflow: hidden;text-overflow: ellipsis;white-space: normal;'>"+
		"<p class='serif cardComment' style='margin:5px;font-size:14px;'>"+mycomment+"</p>"+
		"<a href='#' class='serif' style='float:right;margin:0px;font-size:8px;color:#4577D4;'>show detail</a>"+
	"</div>";
	
	return html;
}



