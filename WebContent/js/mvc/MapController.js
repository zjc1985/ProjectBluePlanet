function MapController(){
	var model=new MapMarkerModel();
	var view=new BaiduMapView(this,model);
	view.createView();
	model.setView(view);
	
	this.searchLocation=function(key){
		view.searchLocation(key);
	};
	
	this.zoomEventHandler=function(){
		var headIds=model.findHeadMarker();
		if(headIds.length!=0){
			for(var i=0;i<headIds.length;i++){
				model.redrawConnectedLine(headIds[i]);
			}
		};
	};
	
	this.showInfoClickHandler=function(marker){
		if(marker.infoWindow==null){
			var content=model.getMarkerContentById(marker.id);
			marker.infoWindow=view.addInfoWindow(marker.getPosition(), content);
		}else{
			marker.infoWindow.show();
		};
	};
	
	this.markerClickEventHandler=function(marker){
		
		if(view.markerNeedMainLine!==null){
			model.addMainLine(view.markerNeedMainLine.id, marker.id);
			view.markerNeedMainLine=null;
		}
		
		if(view.markerNeedSubLine!=null){
			model.addSubLine(view.markerNeedSubLine.id,marker.id);
			view.markerNeedSubLine=null;
		}
	};
	
	this.markerDragendEventHandler=function(marker){
		model.redrawConnectedLine(marker.id);
	};
	
	this.addMarkerClickEvent=function(position,content){
		var id=view.addOneMark(position).id;
		model.createOneMarker(id,content);
		
	};
	
	this.addCustomClickEvent=function(position){
		view.addCustomOverlay(position);
	};
	
	this.addMainLineClickHandler=function(marker){
		view.markerNeedMainLine=marker;
		alert("please click another marker to add main line");
	};
	
	this.addSubLineClickHandler=function(marker){
		view.markerNeedSubLine=marker;
		alert("please click another marker to add sub line");
	};
	
}