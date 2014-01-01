
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
	
	this.setContentA=function(html){
		this.contentA=html;
		$(this.ASideId).empty();
		$(this.ASideId).append(this.contentA);
	};
	
	this.setContentB=function(html){
		this.contentB=html;
		$(this.BSideId).empty();
		$(this.BSideId).append(this.contentB);
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