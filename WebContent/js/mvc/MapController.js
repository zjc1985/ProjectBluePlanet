var QueryString = function () {
	  // This function is anonymous, is executed immediately and 
	  // the return value is assigned to QueryString!
	  var query_string = {};
	  var query = window.location.search.substring(1);
	  var vars = query.split("&");
	  for (var i=0;i<vars.length;i++) {
	    var pair = vars[i].split("=");
	    	// If first entry with this name
	    if (typeof query_string[pair[0]] === "undefined") {
	      query_string[pair[0]] = pair[1];
	    	// If second entry with this name
	    } else if (typeof query_string[pair[0]] === "string") {
	      var arr = [ query_string[pair[0]], pair[1] ];
	      query_string[pair[0]] = arr;
	    	// If third or later entry with this name
	    } else {
	      query_string[pair[0]].push(pair[1]);
	    }
	  } 
	    return query_string;
	} ();

function MapController(){	
	var model=new MapMarkerModel();
	var view=new GoogleMapView(this);
	view.createView();
	var self=this;
	// this num is used to create id for BaiduMarker
	var num = 1;
	
	this.searchLocation=function(key){
		view.searchLocation(key);
	};
	
	this.zoomEventHandler=function(){
		$.publish('updateUI',[]);
	};
	
	this.updateMarkerContentById=function(id,content){
		var mapMarker=model.getMapMarkerById(id);
		mapMarker.updateContent(content);
	};
		
	this.showInfoClickHandler=function(viewMarker){
		var content=model.getMarkerContentById(viewMarker.id);
		console.log(content.getTitle());
		
		if(viewMarker.infoWindow==null){			
			viewMarker.infoWindow=view.addInfoWindow(viewMarker, {title:content.getTitle(),
														address:content.getAddress(),
														category:content.getCategory(),
														comment:content.getMycomment(false)}
												,num++);
			
			viewMarker.infoWindow.setDefaultImgs(content.getImgUrls());
		}else{
			viewMarker.infoWindow.show();
		};
	};
	
	function changeSubMarkerShowStatusOrShowInfoWindow(parentMarkerId){
		var modelMarker=model.getMapMarkerById(parentMarkerId);
		
		if(modelMarker.subMarkersArray.length!=0){
			for(var i in modelMarker.subMarkersArray){
				var subViewMarker=view.getViewOverlaysById(modelMarker.subMarkersArray[i].id);
				if(subViewMarker.isShow==false){
					subViewMarker.show();
				}else{
					subViewMarker.hide();
				}
				subViewMarker.isShow=!subViewMarker.isShow;	
				changeSubMarkerShowStatusOrShowInfoWindow(modelMarker.subMarkersArray[i].id);
			}
		}else{
			return;
		}
		
		
	}
	
	this.markerClickEventHandler=function(viewMarker){
		if(view.markerNeedMainLine!==null){
			model.addMainLine(view.markerNeedMainLine.id, viewMarker.id);
			view.markerNeedMainLine=null;
			return;
		}
		
		if(view.markerNeedSubLine!=null){
			model.addSubLine(view.markerNeedSubLine.id,viewMarker.id);
			view.markerNeedSubLine=null;
			return;
		}
		
		//show or hide subMarkers if has
		if(model.getMapMarkerById(viewMarker.id).subMarkersArray.length!=0){
			changeSubMarkerShowStatusOrShowInfoWindow(viewMarker.id);
		}else{
			this.showInfoClickHandler(viewMarker);
		}
		
		
		$.publish('updateUI',[]);
		
		
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
												  category:contentModel.getCategory(),
												fullcomment:contentModel.getMycomment(false)});
					
					viewMarker.infoWindow.setDefaultImgs(contentModel.getImgUrls());
				}
				
				view.changeMarkerIcon(senderMarker.id, contentModel.getCategory());
			}
		};
	};
	
	
	
	
	function drawSubLine(markerId){
		var markerModel=model.getMapMarkerById(markerId);
		if(markerModel.subMarkersArray.length!=0){
			for(var i=0 in markerModel.subMarkersArray){
				
				view.drawSubLine(markerId, markerModel.subMarkersArray[i].id);
				drawSubLine(markerModel.subMarkersArray[i].id);
			}
		}else{
			return;
		}
	}
	
	this.updateUIRoute=function(){
		return function(_){
			console.log('update UI trigger');
			
			//clean all lines
			view.removeAllLines();
			
			var headMarkers=model.findHeadMarker();
			
			for(var i=0;i<headMarkers.length;i++){
				var marker=headMarkers[i];		
				
				drawSubLine(marker.id);
				
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
		modelMarker.getContent().setlatlng(marker.getPosition().lat,marker.getPosition().lng);
	};
	
	this.addMarkerClickEvent=function(position,content){
		content.lat=position.lat;
		content.lng=position.lng;
		console.log('creating markder id:'+ model.createOneMarker(num,content).id);
	};
	
	this.markerDeleteClickHandler=function(viewMarker){
		model.deleteOneMarker(viewMarker.id);
	};
	
	this.createViewMarker=function(){
		return function(_,modelMarker){
			view.addOneMark(modelMarker.content.getLat(),
							modelMarker.content.getLng(), modelMarker.id);
			view.changeMarkerIcon(modelMarker.id, modelMarker.content.getCategory());
			num++;
		};
	};
	
	this.deleteViewMarker=function(){
		return function(_,modelMarker){
			view.removeById(modelMarker.id);
			$.publish('updateUI',[]);
		};
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
	
	this.loadRoutines=function(){
		if(QueryString.routineId!=null){
			//todo: clean all existOverlay in view
			model.resetModels();
			view.resetView();
			
			//todo: resetId
									
			model.loadRoutine(QueryString.routineId,function(){
				var headModelMark=model.findHeadMarker()[0];
				view.centerAndZoom(headModelMark.content.getLat(), 
						(headModelMark.content.getLng()));
			});
			
		}
	};
	
	this.saveRoutine=function(routineName){
		model.save2Backend(routineName);
	};
	
	this.testFeature=function(){
		view.getDistance(model.findHeadMarker()[0].id, model.findHeadMarker()[0].connectedMainMarker.id);
	};
	
	$.subscribe('deleteOneMarker',this.deleteViewMarker());
	$.subscribe('createOneMarker',this.createViewMarker());
	$.subscribe('updateUI',this.updateUIRoute());
	$.subscribe('updateInfoWindow',this.updateMarkerInfoWindow());
}