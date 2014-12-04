function UploadFormView(id, inputId) {
	var idName = id;
	var jqueryId = "#" + idName;
	var inputIdName = inputId;
	var jqueryInputId = "#" + inputIdName;

	this.show = function() {
		$.magnificPopup.open({
			items : {
				src : jqueryId,
				type : 'inline'
			}
		});
	};

	this.close = function() {
		$.magnificPopup.instance.close();
	};

	this.addChangeCallBack = function(callBack) {
		$(jqueryInputId).change(function() {
			var files = this.files;
			
			
			
		});
	};
}