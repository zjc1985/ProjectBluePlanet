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
	
	this.uploadImgs=function(files){
		alert(files.length);
		view.uploadImgForm.close();
	};
	
	this.searchLocation=function(key){
		view.searchLocation(key);
	};
	
	this.zoomEventHandler=function(){
		$.publish('updateUI',[]);
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
		if(content.getImgUrls().length!=0){
			view.infocard.setDefaultImgs(content.getImgUrls());
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
	
	function changeSubMarkerShowStatus(parentMarkerId,needShow){
		var modelMarker=model.getMapMarkerById(parentMarkerId);
		
		if(modelMarker.subMarkersArray.length!=0){
			for(var i in modelMarker.subMarkersArray){
				var subViewMarker=view.getViewOverlaysById(modelMarker.subMarkersArray[i].id);
				if(needShow){
					subViewMarker.isShow=true;
					subViewMarker.show();
				}else{
					subViewMarker.isShow=false;
					subViewMarker.hide();
				}	
				changeSubMarkerShowStatus(modelMarker.subMarkersArray[i].id,needShow);
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
		
		//show or hide subMarkers if has
		if(model.getMapMarkerById(viewMarker.id).subMarkersArray.length!=0){
			changeSubMarkerShowStatus(viewMarker.id,true);
		}else{
			this.showInfoClickHandler(viewMarker);
		}
		
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
			console.log('update UI trigger');
			
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
		modelMarker.getContent().setlatlng(lat,lng);
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
									
			model.loadRoutine(QueryString.routineId,function(arg){
				/*
				var headModelMark=model.findHeadMarker()[0];
				view.centerAndZoom(headModelMark.content.getLat(), 
						(headModelMark.content.getLng()));
				*/
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
}