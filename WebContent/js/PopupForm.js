function PopupForm(id){
	this.idName=id;
	this.jqueryId="#"+this.idName;
	
	var self=this;
	
	this.setContent=function(content){
		$(this.jqueryId).empty();
		$(this.jqueryId).html(content);
	};
	
	this.show=function(){
		//open popup form
		$.magnificPopup.open({
			items : {
				src : self.jqueryId,
				type : 'inline'
			}
		});
	};
	
	this.close = function() {
		$.magnificPopup.instance.close();
	};
}