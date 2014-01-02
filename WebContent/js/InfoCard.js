
function infoCard(idName,htmlContentA,htmlContentB){
	this.idName=idName;
	this.jqueryId="#"+this.idName;
	this.ASideId;
	this.BSideId;
	this.hideButtonId;
	this.rotateButtonId;
	
	this.contentA=htmlContentA;
	this.contentB=htmlContentB;
	this.isASideShow=true;
	
	this.setContentA=function(html,isGallery){
		this.contentA=html;
		$(this.ASideId).empty();
		$(this.ASideId).append(this.contentA);
		if(isGallery){
			initAllGallery();
		};
	};
	
	this.setContentB=function(html,isGallery){
		this.contentB=html;
		$(this.BSideId).empty();
		$(this.BSideId).append(this.contentB);
		if(isGallery){
			initAllGallery();
		};
	};
	
	this.show=function(){
		$(this.jqueryId).show();
	};
	
	this.hide=function(){
		$(this.jqueryId).hide();
	};
	
	this.resetLocation=function(top,left){
		$(this.jqueryId).css("top",top);
		$(this.jqueryId).css("left",left);
	};
	
	this.showContentA=function(){
		$(this.BSideId).hide();
		$(this.ASideId).show();
		this.isASideShow=true;
	};
	
	
		
	this.showContentB=function(){
		$(this.ASideId).hide();
		$(this.BSideId).show();
		this.isASideShow=false;
	};
	
	this.init=function(top,left){
		
		$("body").append("<div class='info' id='"+this.idName+"'></div>");
		
		var thisCard=this;
		
		var aSideIdName=this.idName+"A";
		var bSideIdName=this.idName+"B";
		this.ASideId="#"+aSideIdName;
		this.BSideId="#"+bSideIdName;
		
		var hideButtonIdName=this.idName+"HideButton";
		var rotateButtonIdName=this.idName+"RotateButton";
		this.hideButtonId="#"+hideButtonIdName;
		this.rotateButtonId="#"+rotateButtonIdName;
		
		$(this.jqueryId).draggable();
		
		$(this.jqueryId).append("<div id='"+aSideIdName +"'></div>");
		$(this.jqueryId).append("<div id='"+bSideIdName+"'></div>");
		
		$(this.ASideId).append(this.contentA);
		$(this.BSideId).append(this.contentB);
		$(this.BSideId).hide();
		var buttonHtml="<button id='"+hideButtonIdName+"'>Hide</button>";
		$(this.jqueryId).append(buttonHtml);
		$(this.jqueryId).addClass("info");
		$(this.jqueryId).css("top",top);
		$(this.jqueryId).css("left",left);
		
		$(this.hideButtonId).click(function(){
			$(thisCard.jqueryId).hide();
		});
		
		
		$(this.jqueryId).dblclick(function(){
			$(thisCard.jqueryId).hide("blind",{direction:"left"},300,function(){
				if(thisCard.isASideShow){
					$(thisCard.ASideId).hide();
					$(thisCard.BSideId).show();
					thisCard.isASideShow=false;
				}else{
					$(thisCard.BSideId).hide();
					$(thisCard.ASideId).show();
					thisCard.isASideShow=true;
				}
			
			});
			
			$(thisCard.jqueryId).show("blind",{direction:"left"},300,null);
		});
	};
}

function createTitleContentA(title,address){
	return "<div><h2>"+title+"</h2><p>"+address+"</p>	<div style='position:absolute;top:20px;left:300px' id='favorite'><img src='resource/favorite.png' height='120px'/></div></div>";
}



function createBasicInfo(content){
	return "<p style='text-overflow:ellipsis;height:70px'>"+content+"</p>";
}

function createImgGallery(imgArray,mainTitle){
	var ahrefs="";
	
	for(var index in imgArray){
		if(index==0){
			ahrefs=	"<a href='"+imgArray[0].url+"' title='"+imgArray[0].title+"'><div style='background-image: url("+imgArray[0].url+");height:80px;background-position: center;'><p style='color:white;opacity:0.55;background-color: black;'>"+mainTitle+"</p></div></a>";
		}else{
			ahrefs+="<a style='display: none;' href='"+imgArray[index].url+"' title='"+imgArray[index].title+"'></a>";
		}
	}
	
	
	var html="<div><div class='popup-gallery'>"+ahrefs+"</div></div>";
	return html;
	
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

