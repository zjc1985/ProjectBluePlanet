function UploadFormView(popupId, inputId,progressId,loadingId) {
	var idName = popupId;
	var jqueryId = "#" + idName;
	var inputIdName = inputId;
	var jqueryInputId = "#" + inputIdName;
	var jqueryProgressId="#"+progressId;
	var jqueryLoadingId="#"+loadingId;
	
	this.fileNum=0;
	this.completeFileNum=0;
	
	this.progressSlice=0;
	this.currentProgress=0;
	
	var self=this;
	
	this.UIUploading=function(){
		$(jqueryLoadingId).show();
	};
	
	this.UIFinishUpload=function(){
		$(jqueryLoadingId).hide();
	};
	
	this.show = function() {
		$.magnificPopup.open({
			items : {
				src : jqueryId,
				type : 'inline'
			}
		});
		self.UIFinishUpload();
	};
	
	this.updateProgress=function(){
		self.currentProgress=self.currentProgress+self.progressSlice;
		$(jqueryProgressId).text(self.currentProgress+'%');
	};

	this.close = function() {
		$.magnificPopup.instance.close();
	};

	this.addChangeCallBack = function(callBack,allCompleteCallBack) {
		$(jqueryInputId).change(function() {
			var files = this.files;
			self.currentProgress=0;
			self.progressSlice=100 / files.length / 2;
			
			self.fileNum=files.length;
			self.completeFileNum=0;
			self.UIUploading();
			
			for(var i=0;i<files.length;i++){
				var file = files[i];
				$.fileExifLoadEnd(file,function(exifObject,imgFile){
					self.updateProgress();
					var lat = exifObject.GPSLatitude;
					var lon = exifObject.GPSLongitude;
					if (lat != null && lon != null) {
						//Convert coordinates to WGS84 decimal
						var latRef = exifObject.GPSLatitudeRef || "N";
						var lonRef = exifObject.GPSLongitudeRef || "W";
						lat = (lat[0] + lat[1] / 60 + lat[2] / 3600)
								* (latRef == "N" ? 1 : -1);
						lon = (lon[0] + lon[1] / 60 + lon[2] / 3600)
								* (lonRef == "W" ? -1 : 1);
					}
					callBack(imgFile,lat,lon);
				});
				
			}	
		});
	};
	
}