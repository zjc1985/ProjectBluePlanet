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
	var self=this;
	view.createView();
	// this num is used to create id for BaiduMarker
	var num = 1;
	
	this.uploadImgs=function(file,lat,lng){
		model.saveImage(file, function(url){
			view.uploadImgForm.completeFileNum++;
			view.uploadImgForm.updateProgress();
			
			if(lat==null||lng==null){
				lat=view.getCenter().lat;
				lng=view.getCenter().lng;
			}
			
			self.addMarkerClickEvent({lat:lat,lng:lng}, {imgUrls:[url],title:file.name});
			if(view.uploadImgForm.completeFileNum==view.uploadImgForm.fileNum){
				alert("all save complete");
				view.uploadImgForm.UIFinishUpload();
				view.uploadImgForm.close();
				view.fitRoutineBounds();			
			}
		},function(error){
			view.uploadImgForm.completeFileNum++;
			view.uploadImgForm.updateProgress();
			alert("one save failed"+error);
		});
	};
	
	this.searchLocation=function(key){
		view.searchLocation(key);
	};
	
	this.zoomEventHandler=function(){
		//update all subMarker lat lng according to offsets with its parent marker
		for(var i in model.getModelMarkers()){
			var modelMarker=model.getModelMarkers()[i];
			if(modelMarker.isSubMarker()){
				var parentViewMarker=view.getViewOverlaysById(modelMarker.parentSubMarker.id);
				var parentPoint=view.fromLatLngToPixel(parentViewMarker.getLatLng());
				var newPoint=parentPoint;
				newPoint.x=newPoint.x+modelMarker.offsetX;
				newPoint.y=newPoint.y+modelMarker.offsetY;
				var newlatlng=view.fromPixelToLatLng(newPoint);
				console.log("calculate newlatlng "+newlatlng);
				modelMarker.updateContent(newlatlng);
			}
		}
		
		//hide all subMarkers
		//...
	};
	
	this.updateMarkerContentById=function(id,content){
		var mapMarker=model.getMapMarkerById(id);
		view.changeMarkerIcon(id, content.iconUrl);
		mapMarker.updateContent(content);
	};
	
	this.showAllRoutineClickHandler=function(){
		view.showAllMarkers();
		$.publish('updateUI',[]);
	};
		
	this.showInfoClickHandler=function(viewMarker){
		var content=model.getMarkerContentById(viewMarker.id);
		console.log("controller.showInfoClickHandler: "+content.getTitle()+
				content.getAddress()+
				content.getCategory()+
				content.getMycomment(false));
		
		view.infocard.setDefaultContent({title:content.getTitle(),
														address:content.getAddress(),
														category:content.getCategory(),
														mycomment:content.getMycomment(true),
														fullcomment:content.getMycomment(false)});
		
		view.infocard.setDefaultImgs(content.getImgUrls());
		if(content.getImgUrls().length!=0){			
			view.infocard.showContentB();
		}else{
			view.infocard.showContentA();
		}
		
		
		
		if(viewMarker.infoWindow==null){			
			viewMarker.infoWindow=view.addInfoWindow(viewMarker, {title:content.getTitle(),},num++);
			
		}else{
			viewMarker.infoWindow.show();
		};
		
	};
	
	function changeSubMarkerShowStatus(parentMarkerId){
		var modelMarker=model.getMapMarkerById(parentMarkerId);
		
		if(modelMarker.subMarkersArray.length!=0){
			var isShow=false;
			for(var i in modelMarker.subMarkersArray){
				var subViewMarker=view.getViewOverlaysById(modelMarker.subMarkersArray[i].id);
				if(subViewMarker.isShow==null || subViewMarker.isShow==false){
					subViewMarker.isShow=true;
					subViewMarker.show();
					subViewMarker.setAnimation(google.maps.Animation.BOUNCE);
					isShow=true;
				}else{				
					subViewMarker.isShow=false;
					subViewMarker.hide();
				}
				
				if(isShow){
					setTimeout(function(){ 
						for(var i in modelMarker.subMarkersArray){
							view.getViewOverlaysById(modelMarker.subMarkersArray[i].id).setAnimation(null);
						}
					}, 750);
				}
			}	
		}else{
			return;
		}	
	}
	
	this.lineEditEnd=function(pathArray,fromMarkerId){
		console.log('line editend, line node num: '+ pathArray.length);
		console.log('from marker id:'+fromMarkerId);
		var modelMarker=model.getMapMarkerById(fromMarkerId);
		modelMarker.mainPaths=pathArray;
	};
	
	function changeMainMarkerShowStatus(idsNeed2ShowArray){
		console.log("controller.changeMainMarkerShowStatus");
		for(var i=0;i<idsNeed2ShowArray.length;i++){
			if(idsNeed2ShowArray[i]!=0){
				view.getViewOverlaysById(idsNeed2ShowArray[i]).isShow=true;
				view.getViewOverlaysById(idsNeed2ShowArray[i]).show();
				if(view.getViewOverlaysById(idsNeed2ShowArray[i]).infoWindow!=null){
					view.getViewOverlaysById(idsNeed2ShowArray[i]).infoWindow.show();
				}
				
				console.log("controller.changeMainMarkerShowStatus: set"+idsNeed2ShowArray[i]+" show status to true");
			}
		}
	};
	
	this.markerClickEventHandler=function(viewMarker){
		view.infocard.show();
		
		view.currentMarkerId=viewMarker.id;
		
		if(view.markerNeedMainLine!==null){
			model.addMainLine(view.markerNeedMainLine.id, viewMarker.id);
			view.markerNeedMainLine=null;
			return;
		}
		
		if(view.markerNeedSubLine!=null){
			var fromPoint=view.fromLatLngToPixel(view.markerNeedSubLine.getLatLng());
			var toPoint=view.fromLatLngToPixel(viewMarker.getLatLng());
			var offsetX=toPoint.x-fromPoint.x;
			var offsetY=toPoint.y-fromPoint.y;
			
			model.getMapMarkerById(viewMarker.id).updateOffset(offsetX,offsetY);
			
			model.addSubLine(view.markerNeedSubLine.id,viewMarker.id);
			view.markerNeedSubLine=null;
			return;
		}
		
		//center click marker	
		var modelMarker=model.getMapMarkerById(viewMarker.id);
		
		if(modelMarker.connectedMainMarker!=null){
			view.fitTwoPositionBounds({lat:modelMarker.content.getLat(),lng:modelMarker.content.getLng()}, 
					{lat:modelMarker.connectedMainMarker.content.getLat(),lng:modelMarker.connectedMainMarker.content.getLng()});
		}
		
		
		/*
		if(!modelMarker.isSubMarker()){
		//show current marker, next marker, preMarker and its mainline, others are hide
			var nextMarkerId=modelMarker.connectedMainMarker==null?0:modelMarker.connectedMainMarker.id;
			var preMarkerId=modelMarker.prevMainMarker==null?0:modelMarker.prevMainMarker.id;
			
			view.showAllMarkers();
			
			var belongRoutineMarkerIds=model.belongWhichHeadIds(modelMarker.id);
			
			for(var i=0;i<belongRoutineMarkerIds.length;i++){
				changeSubMarkerShowStatus(belongRoutineMarkerIds[i],false);
				view.getViewOverlaysById(belongRoutineMarkerIds[i]).isShow=false;
				view.getViewOverlaysById(belongRoutineMarkerIds[i]).hide();
				if(view.getViewOverlaysById(belongRoutineMarkerIds[i]).infoWindow!=null){
					view.getViewOverlaysById(belongRoutineMarkerIds[i]).infoWindow.hide();
				}
			}
			
			changeMainMarkerShowStatus([viewMarker.id,nextMarkerId,preMarkerId]);
		}
		*/
		
		//show or hide subMarkers if has
		if(model.getMapMarkerById(viewMarker.id).subMarkersArray.length!=0){
			changeSubMarkerShowStatus(viewMarker.id);
		}
		this.showInfoClickHandler(viewMarker);
		
		
		//view.centerAndZoom(modelMarker.content.getLat(), modelMarker.content.getLng());
		
		$.publish('updateUI',[]);
	};
	
	this.updateMarkerInfoWindow=function(){
		return function(_,senderMarker){
			
			
			var viewMarker=view.getViewOverlaysById(senderMarker.id);
			var contentModel=senderMarker.getContent();
			console.log('update marker info window. markerId: '+senderMarker.id);
			console.log('title: '+contentModel.getTitle());
			
			if(viewMarker!=null){								
				view.infocard.setDefaultContent({title:contentModel.getTitle(),
													address:contentModel.getAddress(),
												  mycomment:contentModel.getMycomment(true),
												  category:contentModel.getCategory(),
												fullcomment:contentModel.getMycomment(false)});
					
				view.infocard.setDefaultImgs(contentModel.getImgUrls());
				
				if(viewMarker.infoWindow!=null){
					viewMarker.infoWindow.setContent(contentModel.getTitle());
				}
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
			console.log('controller.updateUIRoute');
			
			//clean all lines
			view.removeAllLines();
			
			var headMarkers=model.findHeadMarker();
			
			for(var i=0;i<headMarkers.length;i++){
				var marker=headMarkers[i];		
				
				drawSubLine(marker.id);
				
				while(marker.connectedMainMarker!=null){
					//redraw main line
					if(view.getViewOverlaysById(marker.connectedMainMarker.id).isShow==true){
						view.drawMainLine(marker.id, marker.connectedMainMarker.id,0,marker.mainPaths.length==0?null:marker.mainPaths);
					}
					
					for(var j=0;j<marker.connectedMainMarker.subMarkersArray.length;j++){
						view.drawSubLine(marker.connectedMainMarker.id,marker.connectedMainMarker.subMarkersArray[j].id);
					}
					
					marker=marker.connectedMainMarker;
				}	
			}	
		};
		
		
	};
	
	this.markerDragendEventHandler=function(id,lat,lng){
		var modelMarker=model.getMapMarkerById(id);
		//update lat lng
		modelMarker.updateContent({lat:lat,lng:lng});
		
		
		if(modelMarker.isSubMarker()){
			//update offset if it is a submarker
			var result=calculateOffset(modelMarker.parentSubMarker.id,id);
			modelMarker.updateOffset(result.offsetX,result.offsetY);
						
		}else if(modelMarker.subMarkersArray.length>0){
			// if it is a parent marker,move its subMarker to the new position
			var point=view.fromLatLngToPixel({lat:lat,lng:lng});
			for ( var i in modelMarker.subMarkersArray) {
				var newPoint=new google.maps.Point(point.x,point.y);
				newPoint.x=newPoint.x+modelMarker.subMarkersArray[i].offsetX;
				newPoint.y=newPoint.y+modelMarker.subMarkersArray[i].offsetY;
				var newPosition=view.fromPixelToLatLng(newPoint);
				modelMarker.subMarkersArray[i].updateContent(newPosition);
			}
		}
	};
	
	function calculateOffset(fromMarkerId,toMarkerId){
		var result=new Object();
		var parent=view.getViewOverlaysById(fromMarkerId);
		var sub=view.getViewOverlaysById(toMarkerId);
		var parentPoint=view.fromLatLngToPixel(parent.getLatLng());
		var subPoint=view.fromLatLngToPixel(sub.getLatLng());
		result.offsetX=subPoint.x-parentPoint.x;
		result.offsetY=subPoint.y-parentPoint.y;
		return result;
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
			view.changeMarkerIcon(modelMarker.id, modelMarker.content.getIconUrl());
			num++;
		};
	};
	
	this.updateUIMarker=function(){
		return function(_,modelMarker){
			console.log('controller.updateUIMarker');
			var viewMarker=view.getViewOverlaysById(modelMarker.id);
			if(viewMarker!=null){
				var position=new google.maps.LatLng(modelMarker.getContent().getLat(),
						modelMarker.getContent().getLng());
				viewMarker.setPosition(position);
			}
		};
	};
	
	this.deleteViewMarker=function(){
		return function(_,modelMarker){
			view.removeById(modelMarker.id);
			view.infocard.hide();
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
									
			model.loadRoutine(QueryString.routineId,function(arg){
				/*
				var headModelMark=model.findHeadMarker()[0];
				view.centerAndZoom(headModelMark.content.getLat(), 
						(headModelMark.content.getLng()));
				*/
				//hide all subMarkers
				for(var i in model.getModelMarkers()){
					changeSubMarkerShowStatus(model.getModelMarkers()[i].id);
				}
				
				view.routineName=arg.routineName;
				num=arg.maxId+1;
				view.fitRoutineBounds();
				
				
				
				console.log('current num in controller:'+num);
				
				model.isUserOwnRoutine(QueryString.routineId, function(isUserOwn){
					if(!isUserOwn){
						console.log('try to hide contextMenu');
						view.hideEditMenuInContextMenu();
					}
				});
			});
		}
	};
	
	this.saveRoutine=function(){
		var name=prompt("routine name?",self.routineName); 
		if (name!=null && name!="") 
		{
			model.save2Backend(name);
		}else{
			alert('please input your routine name to save');
		}
	};
	
	this.testFeature=function(viewMarker){
		
	};
	
	$.subscribe('deleteOneMarker',this.deleteViewMarker());
	$.subscribe('createOneMarker',this.createViewMarker());
	$.subscribe('updateUI',this.updateUIRoute());
	$.subscribe('updateInfoWindow',this.updateMarkerInfoWindow());
	$.subscribe('updateUIMarker',this.updateUIMarker());
}