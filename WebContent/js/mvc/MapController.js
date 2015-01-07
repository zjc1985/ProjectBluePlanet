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
	
	var isSlideMode=false;
	var currentSlideNum=1;
	
	var isUserOwnThisRoutine=false;
	
	var MAX_ZINDEX=200;
	
	var routineName="Default Routine";
	
	this.uploadImgs=function(imageBase64String,lat,lng,fileName){
		model.saveImageByBase64(imageBase64String,fileName,function(url){
			view.uploadImgForm.completeFileNum++;
			view.uploadImgForm.updateProgress();
			
			var hasPositionInImg=true;
			
			if(lat==null||lng==null){
				hasPositionInImg=false;
				lat=view.getCenter().lat;
				lng=view.getCenter().lng;
			}
			
			var id=self.addMarkerClickEvent({lat:lat,lng:lng}, {imgUrls:[url],title:file.name});
			var content=model.getMarkerContentById(id);
			content.setImgPositionDecided(hasPositionInImg);
			
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
	
	this.startSlideMode=function(){
		isSlideMode=true;
		currentSlideNum=1;
		
		view.infocard.hideEditButton();
		
		view.removeAllLines();
		
		view.initSlideMode();
		
		view.clearMarkerCluster();
		
		for(var i in model.getModelMarkers()){
			var viewMarker=view.getViewOverlaysById(model.getModelMarkers()[i].id);
			viewMarker.hide();
		}
	};
	
	this.exitSlideMode=function(){	
		if(isUserOwnThisRoutine){
			isSlideMode=false;
			view.infocard.showEditButton();
			view.removeAllLines();
			view.exitSlideMode();
			for(var i in model.getModelMarkers()){
				var viewMarker=view.getViewOverlaysById(model.getModelMarkers()[i].id);
				if(model.getModelMarkers()[i].isSubMarker()){
					viewMarker.hide();
				}else{
					viewMarker.show();
				}
			}
			
			refreshCluster();
		}	
	};
	
	this.prevSlide=function(){
		if(isSlideMode){
			//hide current slide num and prev slide num
			for(var i in model.getModelMarkers()){
				var modelMarker=model.getModelMarkers()[i];
				if(modelMarker.content.getSlideNum()==currentSlideNum-1 || modelMarker.content.getSlideNum()==currentSlideNum-2){
					var viewMarker=view.getViewOverlaysById(modelMarker.id);
					viewMarker.hide();
				}
			}
			
			if(currentSlideNum<=model.getModelMarkers().length){
				currentSlideNum--;
				currentSlideNum--;
				
				refreshClusterAccording2SlideNum(currentSlideNum);
			}
			
		}
		
	};
	
	function refreshClusterAccording2SlideNum(slideNum){
		var markerIdsNeed2Cluster=[];
		
		for(var i in model.getModelMarkers()){
			var modelMarker=model.getModelMarkers()[i];
			if(modelMarker.content.getSlideNum()<currentSlideNum-1 && (!modelMarker.isSubMarker())){
				markerIdsNeed2Cluster.push(modelMarker.id);
			}
		}
		
		if(markerIdsNeed2Cluster.length>0){
			view.clearMarkerCluster();
			view.AddMarkers2Cluster(markerIdsNeed2Cluster);
		}
	}
	
	this.mapClickEventHandler=function(){
		if(isSlideMode){
			if(currentSlideNum>model.getModelMarkers().length){
				return;
			}
			
			var markerIdsNeed2Show=[];
			
			for(var i in model.getModelMarkers()){
				var modelMarker=model.getModelMarkers()[i];
				if(modelMarker.content.getSlideNum()==currentSlideNum && (!modelMarker.isSubMarker())){
					markerIdsNeed2Show.push(modelMarker.id);
				}
			}
			
			currentSlideNum++;
			
			if(markerIdsNeed2Show.length>0){
				view.panByIds(markerIdsNeed2Show);
				
				refreshClusterAccording2SlideNum(currentSlideNum-1);
				
				var startMillionSeconds=700;
				
				setTimeout(function(){ 
					for(var i in markerIdsNeed2Show){
						var id=markerIdsNeed2Show[i];
						view.setMarkerZIndex(id, currentSlideNum);
						view.getViewOverlaysById(id).show();
						view.setMarkerAnimation(id, "DROP");
					}
				}, startMillionSeconds);	
				
				
				setTimeout(function(){ 
					for(var i in markerIdsNeed2Show){
						var id=markerIdsNeed2Show[i];
						view.setMarkerAnimation(id, "BOUNCE");
					}
				}, startMillionSeconds+650);
				
				setTimeout(function(){ 
					for(var i in markerIdsNeed2Show){
						var id=markerIdsNeed2Show[i];
						view.setMarkerAnimation(id, null);
					}
				}, startMillionSeconds+2900);
				
				
			}else{
				this.mapClickEventHandler();
			}
			
			
		}
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
				modelMarker.content.updateContent(newlatlng);
			}
		}
		
		console.log('current zoom level '+view.getZoom());
	};
	
	this.updateMarkerContentById=function(id,content){
		var mapMarker=model.getMapMarkerById(id);
		mapMarker.content.updateContent(content);
		if(content.slideNum!=null && mapMarker.subMarkersArray.length>0){
			for(var i in mapMarker.subMarkersArray){
				mapMarker.subMarkersArray[i].content.updateContent({slideNum:content.slideNum});
			}
		}
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
		view.infocard.setMaxSlideNum(model.getModelMarkers().length);
		
		view.infocard.setDefaultContent({title:content.getTitle(),
											iconUrl:content.getIconUrl(),
											address:content.getAddress(),
											category:content.getCategory(),
											mycomment:content.getMycomment(true),
											slideNum:content.getSlideNum(),
											fullcomment:content.getMycomment(false)});
		
		view.infocard.setDefaultImgs(content.getImgUrls());
		
		
		
		if(content.getImgUrls().length!=0){			
			view.infocard.showContentB();
		}else{
			view.infocard.showContentA();
		}
		
		//Don't need show infoWindow right now
		/*
		if(viewMarker.infoWindow==null){			
			viewMarker.infoWindow=view.addInfoWindow(viewMarker, {title:content.getTitle(),},num++);
			
		}else{
			viewMarker.infoWindow.show();
		};
		*/
		
	};
	
	function changeSubMarkerShowStatus(parentMarkerId){
		var modelMarker=model.getMapMarkerById(parentMarkerId);
		
		if(modelMarker.subMarkersArray.length!=0){
			var isShow=false;
			for(var i in modelMarker.subMarkersArray){
				var subViewMarker=view.getViewOverlaysById(modelMarker.subMarkersArray[i].id);
				if(subViewMarker.isShow==null || subViewMarker.isShow==false){
					view.setMarkerZIndex(subViewMarker.id, MAX_ZINDEX);
					subViewMarker.show();
					view.setMarkerAnimation(modelMarker.subMarkersArray[i].id, "BOUNCE");
					isShow=true;
				}else{				
					subViewMarker.hide();
				}
				
				if(isShow){
					setTimeout(function(){ 
						for(var i in modelMarker.subMarkersArray){
							view.setMarkerAnimation(modelMarker.subMarkersArray[i].id, null);
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
		
		if(view.markerNeedMergeImgUrl!=null){
			if(view.markerNeedMergeImgUrl.id!=viewMarker.id){
				var fromContent=model.getMarkerContentById(view.markerNeedMergeImgUrl.id);
				var urls=fromContent.getImgUrls();
				var toContent=model.getMarkerContentById(viewMarker.id);				
				for(var i in urls){
					toContent.addImgUrl(urls[i]);
				}
			}
			
			view.markerNeedMergeImgUrl=null;
			return;
		}
		
		if(view.markerNeedMainLine!=null){
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
		
		//set max zindex
		view.setMarkerZIndex(viewMarker.id, MAX_ZINDEX);
		
		//view.centerAndZoom(modelMarker.content.getLat(), modelMarker.content.getLng());
		
		$.publish('updateUI',[]);
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
	
	this.markerDragendEventHandler=function(id,lat,lng){
		var modelMarker=model.getMapMarkerById(id);
		//update lat lng
		modelMarker.content.updateContent({lat:lat,lng:lng});
		
		if(!modelMarker.content.isImgPositionDecided()){
			modelMarker.content.setImgPositionDecided(true);
		}
		
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
				modelMarker.subMarkersArray[i].content.updateContent(newPosition);
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
		var id=model.createOneMarker(num,content).id;
		console.log('creating markder id:'+ id);
		return id;
	};
	
	this.markerDeleteClickHandler=function(viewMarker){
		model.deleteOneMarker(viewMarker.id,true);
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
	
	this.mergeImgUrlClickHandler=function(marker){
		view.markerNeedMergeImgUrl=marker;
		alert("please click another marker which you want to merge to");
	};
	
	function refreshCluster(){
		//add cluster logic
		
		var ids=new Array();
		for(var i in model.getModelMarkers()){
			var modelMarker=model.getModelMarkers()[i];
			if(!modelMarker.isSubMarker()){
				ids.push(modelMarker.id);
			}
		}
		
		view.clearMarkerCluster();
		view.AddMarkers2Cluster(ids);
		
	}
	
	this.loadRoutines=function(){
		if(QueryString.routineId!=null){
			//todo: clean all existOverlay in view
			model.resetModels();
			view.resetView();
			
			//todo: resetId
									
			model.loadRoutine(QueryString.routineId,function(arg){
				//hide all subMarkers
				for(var i in model.getModelMarkers()){
					changeSubMarkerShowStatus(model.getModelMarkers()[i].id);
				}
				
				routineName=arg.routineName;
				num=arg.maxId+1;
				view.fitRoutineBounds();
				
				console.log('current num in controller:'+num);
				
				self.zoomEventHandler();
				
				refreshCluster();
				
				model.isUserOwnRoutine(QueryString.routineId, function(isUserOwn){
					isUserOwnThisRoutine=isUserOwn;
					if(!isUserOwn){
						console.log('start slide mode');
						self.startSlideMode();
					}else{

					}
				});
			});
		}
	};
	
	this.saveRoutine=function(){
		if(routineName!="Default Routine"){
			model.save2Backend(routineName);
		}else{
			var name=prompt("routine name?",routineName); 
			if (name!=null && name!="") 
			{
				model.save2Backend(name);
			}else{
				alert('please input your routine name to save');
			}
		}	
	};
	
	this.testFeature=function(viewMarker){
		
	};
	
	
	//broad cast receivers
	this.iconUrlUpdatedHandler=function(){
		return function(_,markerContent){
			console.log("controller.iconUrlUpdatedHandler:"+markerContent.getIconUrl());
			view.changeMarkerIcon(markerContent.id, markerContent.getIconUrl());
		};
	};
	
	this.deleteViewMarker=function(){
		return function(_,modelMarker){
			view.removeById(modelMarker.id);
			view.infocard.hide();
			$.publish('updateUI',[]);
		};
	};
	
	this.latlngChangedHandler=function(){
		return function(_,content){
			console.log('controller.updateUIMarker');
			var viewMarker=view.getViewOverlaysById(content.id);
			if(viewMarker!=null){
				var position=new google.maps.LatLng(content.getLat(),
						content.getLng());
				viewMarker.setPosition(position);
			}
		};
	};
	
	this.createViewMarker=function(){
		return function(_,modelMarker){
			view.addOneMark(modelMarker.content.getLat(),
							modelMarker.content.getLng(), modelMarker.id);
			view.changeMarkerIcon(modelMarker.id, modelMarker.content.getIconUrl());
			num++;
		};
	};
	
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
	
	this.updateMarkerInfoWindow=function(){
		return function(_,content){
			
			
			var viewMarker=view.getViewOverlaysById(content.id);
			var contentModel=content;
			console.log('update marker info window. markerId: '+content.id);
			console.log('title: '+contentModel.getTitle());
			
			if(viewMarker!=null){								
				view.infocard.setDefaultContent({title:contentModel.getTitle(),
													address:contentModel.getAddress(),
													slideNum:contentModel.getSlideNum(),
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
	
	$.subscribe('deleteOneMarker',this.deleteViewMarker());
	$.subscribe('createOneMarker',this.createViewMarker());
	$.subscribe('updateUI',this.updateUIRoute());
	$.subscribe('updateInfoWindow',this.updateMarkerInfoWindow());
	$.subscribe('latlngChanged',this.latlngChangedHandler());
	$.subscribe('iconUrlUpdated',this.iconUrlUpdatedHandler());
}