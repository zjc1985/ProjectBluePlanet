function MapController(){
	
	
	var model=new MapMarkerModel();
	var view=new BaiduMapView(this);
	view.createView();
	
	this.searchLocation=function(key){
		view.searchLocation(key);
	};
	
	this.zoomEventHandler=function(){
		this.updateUI();
	};
	
	this.updateMarkerContentById=function(id,content){
		console.log("ready to update");
		var modelContent=model.getMarkerContentById(id);
		modelContent.update(content);
		
	};
	
	this.showInfoClickHandler=function(marker){
		var content=model.getMarkerContentById(marker.id);
		console.log(content);
		
		if(marker.infoWindow==null){			
			marker.infoWindow=view.addInfoWindow(marker, content);
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
	
	this.updateUI=function(){
		console.log('update UI trigger');
		
		//clean all lines
		view.removeAllLines();
		
		var headMarkers=model.findHeadMarker();
		
		for(var i=0;i<headMarkers.length;i++){
			var marker=headMarkers[i];		
			for(var j=0;j<marker.subMarkersArray.length;j++){
				view.drawSubLine(marker.id,marker.subMarkersArray[j].id);
			}
			
			while(marker.connectedMainMarker!=null){
				//redraw main line
				
				view.drawMainLine(marker.id, marker.connectedMainMarker.id);
				
				for(var j=0;j<marker.connectedMainMarker.subMarkersArray.length;j++){
					view.drawSubLine(marker.connectedMainMarker.id,marker.connectedMainMarker.subMarkersArray[j].id);
				}
				
				marker=marker.connectedMainMarker;
			}
			
			
		}	
	};
	
	this.markerDragendEventHandler=function(marker){
		var modelMarker=model.getMapMarkerById(marker.id);
		modelMarker.getContent().setlatlong(marker.getPosition().lat,marker.getPosition().lng);
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
	
	$.subscribe('updateUI',this.updateUI);
}