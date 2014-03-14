function MapController(){	
	var model=new MapMarkerModel();
	var view=new BaiduMapView(this);
	view.createView();
	
	this.searchLocation=function(key){
		view.searchLocation(key);
	};
	
	this.zoomEventHandler=function(){
		this.updateUIRoute();
	};
	
	this.updateMarkerContentById=function(id,content){
		var mapMarker=model.getMapMarkerById(id);
		mapMarker.updateContent(content);
	};
		
	this.showInfoClickHandler=function(marker){
		var content=model.getMarkerContentById(marker.id);
		console.log(content.getTitle());
		
		if(marker.infoWindow==null){			
			marker.infoWindow=view.addInfoWindow(marker, {title:content.getTitle(),
														address:content.getAddress(),
														comment:content.getMycomment(false)});
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
	
	this.updateMarkerInfoWindow=function(){
		return function(_,senderMarker){
			
			
			var viewMarker=view.getViewOverlaysById(senderMarker.id);
			var contentModel=senderMarker.getContent();
			console.log('update marker info window. markerId: '+senderMarker.id);
			console.log('title: '+contentModel.getTitle());
			
			if(viewMarker!=null){				
				if(viewMarker.infoWindow!=null){					
					viewMarker.infoWindow.setContent({title:contentModel.getTitle(),
													address:contentModel.getAddress(),
												  mycomment:contentModel.getMycomment(true),
												fullcomment:contentModel.getMycomment(false)});
				}
			}
		};
	};
	
	this.updateUIRoute=function(){
		return function(_){
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
	
	$.subscribe('updateUI',this.updateUIRoute());
	$.subscribe('updateInfoWindow',this.updateMarkerInfoWindow());
}