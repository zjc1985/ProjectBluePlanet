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

function extend(b, a, t, p) {
	b.prototype = a;
	a.apply(t, p);
}
	


function MapController(){	
	var self=this;
	var model=new MapMarkerModel();
	var view= new GoogleMapView(self);
	
	//used for slide
	var isSlideMode=false;
	
	//slide sequence
	var currentSlideNum=1;
	
	var isInCustomZoom=false;
	
	var isUserOwnThisRoutine=false;
	
	var MAX_ZINDEX=200;
	
	this.isInCustomStyle=function(){
		return isInCustomZoom;
	};
	
	this.isUserOwn=function(){
		return isUserOwnThisRoutine;
	};
	
	this.getModel=function(){
		return model;
	};
	
	this.setModel=function(oneModel){
		model=oneModel;
	};
	
	this.getView=function(){
		return view;
	};
	
	this.setView=function(oneView){
		view=oneView;
	};
	
	this.init=function(){
		model=new MapMarkerModel();
		view=new GoogleMapView(this);
		view.createView();
		self.change2CustomStyle();
	};
	
	this.deleteOvMarker=function(id){
		model.deleteOvMarker(id);
	};
	
	this.markerMouseOver=function(id){
		
	};
	
	this.markerMouseOut=function(id){
		
	};
	
	this.toCustomStyleBtnClick=function(){
		self.change2CustomStyle();
		if(model.currentRoutineId!=null){
			var currentRoutine=model.getRoutineById(model.currentRoutineId);
			view.panByIds([currentRoutine.id]);
		}
	};
	
	this.searchCopyMarkerBtnClick=function(){
		var items=[];
		var routines=model.getModelRoutines();
		for(var i in routines){
			items.push({
				value:routines[i].id,
				name: routines[i].getContent().getTitle()
			});
		}
		view.searchPickRoutineBoard.setDropDownItems(items);
		view.searchPickRoutineBoard.show();
	};
	
	this.editFormDeleteClick=function(id){
		if(model.isOvMarker(id)){
			self.deleteRoutine(id);
			view.ovMarkerDialog.hide();
		}else{
			var r=confirm("Do you want to delete attached img?");
			model.deleteOneMarker(id,r);
			view.markerInfoDialog.hide();
		}
	};
	
	this.copyRoutine=function(ovMarkerId){
		if(isUserOwnThisRoutine){
			alert('you have this routine already');
		}else{
			model.copyRoutine2CurrentUser(ovMarkerId,function(){
				var r=confirm("Copy Complete. Do u want to see your own map?");
				if(r==true){
					window.location.href = 'MapMarkerMVC.html';
				}else{
					return;
				}
			});
		}
	};
	
	this.newRoutineBtnClick=function(content){
		var routineId=model.createModelRoutine(content);
		self.showRoutineDetail(routineId);
		alert('routine created. now you can add this marker now~');
	};
	
	this.addOvMarker=function(content,belongId){
		var id=model.genUUID();
		var ovMarker=model.getMapMarkerById(belongId);
		var routineId=ovMarker.routineId;
		
		//make content the same with one overviewMarker
		content.isAverage=false;
		content.title=ovMarker.content.getTitle();
		content.mycomment=ovMarker.content.getMycomment(false);
		model.createOverviewMarker(id, content, routineId);
	};
	
	this.deleteRoutine=function(overviewMarkerId){
		var r=confirm("Are you sure you want to delete this routine?");
		if (r==true){
			model.deleteRoutineByOverviewId(overviewMarkerId, function(){
				alert("delete routine success");
			});
		}
		else{
		  return;
		}
	};
	
	this.showRoutineDetail=function(overviewMarkerId){
		view.navBar.showCreateMarkerBtn();
		view.navBar.showCreateMarkerWithImageBtn();
		view.navBar.hideCreateRoutineBtn();
		view.navBar.showSlideDropDown();
		view.setMapStyle2Default();
		isInCustomZoom=false;
		//clean last routine markers
		if(model.currentRoutineId!=null){
			var lastMarkers=model.getRoutineById(model.currentRoutineId).getMarkers();
			for(var i in lastMarkers){
				view.removeById(lastMarkers[i].id);
			}
		}
		
		//set current routine
		var routine=model.getRoutineById(overviewMarkerId);
		model.currentRoutineId=routine.id;
		
		//show current routine markers, hide ovMarkers and change map style
		var ids=[];
		if(routine.isLoadMarkers){
			var markers=routine.getMarkers();
			
			for(var i in markers){
				var modelMarker=markers[i];
				ids.push(modelMarker.id);
				view.addOneMark(modelMarker.content.getLat(),
						modelMarker.content.getLng(), modelMarker.id);
				view.changeMarkerIcon(modelMarker.id, modelMarker.content.getIconUrl());
				view.setMarkerAnimation(modelMarker.id, "DROP");
			}
			view.fitBoundsByIds(ids);
			if(!isUserOwnThisRoutine){
				this.disableEditFunction();
			}
		}else{
			model.loadMarkersByRoutineId(routine.id,function(loadMarkers){
				for(var i in loadMarkers){
					ids.push(loadMarkers[i].id);
				}
				view.fitBoundsByIds(ids);
				if(!isUserOwnThisRoutine){
					self.disableEditFunction();
				}
			});
			routine.isLoadMarkers=true;
		}
		
		view.removeAllOvLines();
		
		refreshCluster();
		
		
		
		var overviewModelMarkers=model.getAllOverviewMarkers();
		for(var i in overviewModelMarkers){
			var viewMarker=view.getViewOverlaysById(overviewModelMarkers[i].id);
			viewMarker.hide();
		}
		
		
		
		/*
		for(var i in model.getModelMarkers()){
			view.removeById(model.getModelMarkers()[i].id);
		}
		
		model.setCurrenOverviewMarkersByOverviewId(overviewMarkerId);
		
		model.loadRoutineByOverviewMarkerId(overviewMarkerId, function(title){
			routineName=title;
			var ids=[];
			for(var i in model.getModelMarkers()){
				var id=model.getModelMarkers()[i].id;
				changeSubMarkerShowStatus(id);
				ids.push(id);
			}
			
			view.fitBoundsByIds(ids);
			
			if(view.isInCustomZoom()){
				view.setMapZoom(8);
			}
			
			if(!isUserOwnThisRoutine){
				setTimeout(function(){
					disableEditFunction();
				},500);
			}
		});
		*/
	};
	
	this.uploadImgs=function(imageBase64String,lat,lng,fileName){
		model.saveImageByBase64(imageBase64String,fileName,function(url){
			view.uploadImgModal.completeFileNum++;
			view.uploadImgModal.updateProgress();
			
			var hasPositionInImg=true;
			
			if(lat==null||lng==null){
				hasPositionInImg=false;
				lat=view.getCenter().lat;
				lng=view.getCenter().lng;
			}
			
			var id=self.addMarkerClickEvent({lat:lat,lng:lng}, {imgUrls:[url],title:file.name});
			var content=model.getMarkerContentById(id);
			content.setImgPositionDecided(hasPositionInImg);
			
			if(view.uploadImgModal.completeFileNum==view.uploadImgModal.fileNum){
				alert("all save complete");
				view.uploadImgModal.UIFinishUpload();
				view.uploadImgModal.close();
				view.fitBoundsByIds([id]);		
			}
		},function(error){
			view.uploadImgModal.completeFileNum++;
			view.uploadImgModal.updateProgress();
			alert("one save failed"+error);
		});
	};
	
	this.searchLocation=function(key){
		view.searchLocation(key);
	};
	
	this.disableEditFunction=function(){
		//hide Edit Function
		view.navBar.disableEditFunction();
		view.markerInfoDialog.disableEditFunction();
		view.ovMarkerDialog.disableEditFunction();
		
		if(model.currentRoutineId!=null){
			var routine=model.getRoutineById(model.currentRoutineId);
			var markers=routine.getMarkers();
			for(var i in markers){
				var id=markers[i].id;
				view.setMarkerDragable(id, false);
			}
		}
		
		for(var i in model.getAllOverviewMarkers()){
			var id=model.getAllOverviewMarkers()[i].id;
			view.setMarkerDragable(id, false);
		}
	};
	
	this.startSlideMode=function(){
		if(model.currentRoutineId==null){
			alert('Please show one routine first');
			return;
		}
		
		isSlideMode=true;
		currentSlideNum=1;
		
		view.removeAllLines();
		
		this.disableEditFunction();
		
		view.clearMarkerCluster();
		
		var routine=model.getRoutineById(model.currentRoutineId);
		var markers=routine.getMarkers();
		for(var i in markers){
			var viewMarker=view.getViewOverlaysById(markers[i].id);
			viewMarker.hide();
		}
	};
	
	this.exitSlideMode=function(){	
		if(isUserOwnThisRoutine){
			isSlideMode=false;

			view.removeAllLines();
			
			view.navBar.enableEditFunction();
			
			view.markerInfoDialog.enableEditFunction();
			
			view.ovMarkerDialog.enableEditFunction();
			
			var routine=model.getRoutineById(model.currentRoutineId);
			var markers=routine.getMarkers();
			
			for(var i in markers){
				var id=markers[i].id;
				view.setMarkerDragable(id, true);
			}
			
			for(var i in model.getAllOverviewMarkers()){
				var id=model.getAllOverviewMarkers()[i].id;
				view.setMarkerDragable(id, true);
			}
			
			for(var i in markers){
				var viewMarker=view.getViewOverlaysById(markers[i].id);
				if(markers[i].isSubMarker()){
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
			var markers=model.getRoutineById(model.currentRoutineId).getMarkers();
			
			for(var i in markers){
				var modelMarker=markers[i];
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
		if(isSlideMode && !isInCustomZoom){
			var markers=model.getRoutineById(model.currentRoutineId).getMarkers();
			
			if(currentSlideNum>markers.length){
				return;
			}
			
			var markerIdsNeed2Show=[];
			
			for(var i in markers){
				var modelMarker=markers[i];
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
	
	this.change2CustomStyle=function(){
		isInCustomZoom=true;
		
		$.publish('updateOvLines');
			
		view.clearMarkerCluster();
			
		view.setMapStyle2Custom();
			
		var overviewModelMarkers=model.getAllOverviewMarkers();
		for(var i in overviewModelMarkers){
			var viewMarker=view.getViewOverlaysById(overviewModelMarkers[i].id);
			viewMarker.show();
		}
		
		if(model.currentRoutineId!=null){
			var modelMarkers=model.getRoutineById(model.currentRoutineId).getMarkers();
			for(var i in modelMarkers){
				var viewMarker=view.getViewOverlaysById(modelMarkers[i].id);
				viewMarker.hide();
			}
		}
		
		view.navBar.hideCreateMarkerBtn();
		view.navBar.hideCreateMarkerWithImageBtn();
		view.navBar.hideSlideDropDown();
		view.navBar.showCreateRoutineBtn();
		self.zoomEventHandler();
	};
	
	function adjustLocationByOffset(idParent,idSub){
		var parentViewMarker=view.getViewOverlaysById(idParent);
		var parentPoint=view.fromLatLngToPixel(parentViewMarker.getLatLng());
		var newPoint=parentPoint;
		var modelMarker=model.getMapMarkerById(idSub);
		newPoint.x=newPoint.x+modelMarker.offsetX;
		newPoint.y=newPoint.y+modelMarker.offsetY;
		var newlatlng=view.fromPixelToLatLng(newPoint);
		console.log("calculate newlatlng "+newlatlng);
		modelMarker.getContent().updateContent(newlatlng);
	}
	
	this.zoomEventHandler=function(){
		console.log("current zoom:"+view.getZoom());
		
		if(isInCustomZoom){
			//update ovMarker offset
			var routines=model.getModelRoutines();
			for(var i in routines){
				var eachRoutine=routines[i];
				var ovMarkers=eachRoutine.getOvMarkers();
				for(var i in ovMarkers){
					adjustLocationByOffset(eachRoutine.id,ovMarkers[i].id);
				}
			}
			$.publish("updateOvLines");
		}else{
			//update all subMarker lat lng according to offsets with its parent marker
			for(var i in model.getModelMarkers()){
				var modelMarker=model.getModelMarkers()[i];
				if(modelMarker.isSubMarker()){				
					adjustLocationByOffset(modelMarker.parentSubMarker.id,
							modelMarker.id);
				}
			}
		}
				
		/*
		if(view.isInCustomZoom()){
			if(!isInCustomZoom){
				$.publish('updateOvLines');
				
				view.clearMarkerCluster();
				
				view.setMapStyle2Custom();
				
				var overviewModelMarkers=model.getAllOverviewMarkers();
				for(var i in overviewModelMarkers){
					var viewMarker=view.getViewOverlaysById(overviewModelMarkers[i].id);
					viewMarker.show();
				}
				
				var modelMarkers=model.getModelMarkers();
				for(var i in modelMarkers){
					var viewMarker=view.getViewOverlaysById(modelMarkers[i].id);
					viewMarker.hide();
				}
			}
			isInCustomZoom=true;
		}else{
			if(isInCustomZoom){
				view.removeAllOvLines();
				
				refreshCluster();
				
				view.setMapStyle2Default();
				
				var overviewModelMarkers=model.getAllOverviewMarkers();
				for(var i in overviewModelMarkers){
					var viewMarker=view.getViewOverlaysById(overviewModelMarkers[i].id);
					viewMarker.hide();
				}
				
				var modelMarkers=model.getModelMarkers();
				for(var i in modelMarkers){
					if(!modelMarkers[i].isSubMarker()){
						var viewMarker=view.getViewOverlaysById(modelMarkers[i].id);
						viewMarker.show();
					}
				}
			}
			isInCustomZoom=false;
		}
		*/
	};
	
	this.editFormConfirmClick=function(id){
		//setting dialog
		var dialog;
		if(model.isOvMarker(id)){
			dialog=view.ovMarkerDialog;
		}else{
			dialog=view.markerInfoDialog;
		}
		
		dialog.setTitle(view.markerEditDialog.getTitle());
		dialog.setSubTitle('slideNum'+view.markerEditDialog.getSlideNum());
		dialog.setDescription(view.markerEditDialog.getDesc());
		dialog.setImageSlider(view.markerEditDialog.getUrls());
		
		var content={
			title:view.markerEditDialog.getTitle(),
			slideNum:parseInt(view.markerEditDialog.getSlideNum()),
			mycomment:view.markerEditDialog.getDesc(),
			imgUrls:view.markerEditDialog.getUrls(),
			iconUrl:view.markerEditDialog.getIconSelect().url
		};
		
		//setting content
		var mapMarker=model.getMapMarkerById(id);
		if(model.isOvMarker(id)){
			var routine=model.getRoutineById(id);
			var contentNeedSync={title:content.title,
					mycomment:content.mycomment};
			
			routine.getContent().updateContent(contentNeedSync);
			var ovMarkers=routine.getOvMarkers();
			for(var i in ovMarkers){
				ovMarkers[i].getContent().updateContent(content);
			}
		}else{
			mapMarker.content.updateContent(content);
			if(content.slideNum!=null && mapMarker.subMarkersArray.length>0){
				for(var i in mapMarker.subMarkersArray){
					mapMarker.subMarkersArray[i].content.updateContent({slideNum:content.slideNum});
				}
			}
		}
	};
	
	this.showAllRoutineClickHandler=function(){
		view.showAllMarkers();
		$.publish('updateUI',[]);
	};
		
	this.showInfoClickHandler=function(markerId){
		
		var marker=model.getMapMarkerById(markerId);
		var content=marker.getContent();
		
		var dialog;
		if(model.isOvMarker(markerId)){
			dialog=view.ovMarkerDialog;
			var routineMarker=model.getRoutineById(markerId);
			dialog.setUser(routineMarker.userId, routineMarker.userName);
		}else{
			dialog=view.markerInfoDialog;
			dialog.setSubTitle(content.getSlideNum());
		}
		
		dialog.setTitle(content.getTitle());
		dialog.setDescription(content.getMycomment(true));
		dialog.setImageSlider(content.getImgUrls());
		
		dialog.show();
		
		view.markerEditDialog.setTitle(content.getTitle());
		if(model.isOvMarker(markerId)){
			view.markerEditDialog.setMaxSlideNum(1);
		}else{
			var routine=model.getRoutineById(markerId);
			view.markerEditDialog.setMaxSlideNum(routine.getMarkers().length);
		}
		view.markerEditDialog.setSlideNum(content.getSlideNum());
		view.markerEditDialog.setDesc(content.getMycomment(true));
		view.markerEditDialog.setUrls(content.getImgUrls());
		
		var items=[];
		if(isInCustomZoom){
			items.push({url:"resource/icons/overview/overview_bear.png",name:"bear"});
			items.push({url:"resource/icons/overview/overview_photo.png",name:"photo"});
			items.push({url:"resource/icons/overview/overview_eiffel.png",name:"eiffel"});
			items.push({url:"resource/icons/overview/overview_sun.png",name:"sun"});
		}else{
			items.push({url:"resource/icons/default/default_default.png",name:"default"});
			items.push({url:"resource/icons/default/center_default.png",name:"point"});
			items.push({url:"resource/icons/sight/sight_default.png",name:"sight default"});
			items.push({url:"resource/icons/sight/sight_star.png",name:"sight star"});
			items.push({url:"resource/icons/event/event_default.png",name:"event default"});	
		}
			
		view.markerEditDialog.setDropDownItems(items);
		view.markerEditDialog.setIconSelect({url:content.getIconUrl(),name:"current Icon"});
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
	
	this.overviewMarkerClickEventHandler=function(id,animationTime){
		view.currentMarkerId=id;
		this.showInfoClickHandler(id);
		
		//animated ovmarkers with same routineId
		var routineId=model.getMapMarkerById(id).routineId;
		
		if(routineId==null){
			return;
		}
		
		var ovMarkers=model.getMapMarkerById(routineId).ovMarkers;
		
		var idsNeed2Bounce=[];
		for(var i in ovMarkers){
			idsNeed2Bounce.push(ovMarkers[i].id);
			view.setMarkerAnimation(ovMarkers[i].id, "BOUNCE");
		}
		
		if(animationTime==null){
			animationTime=650*3;
		}
		setTimeout(function(){ 
			for(var i in idsNeed2Bounce){
				var id=idsNeed2Bounce[i];
				view.setMarkerAnimation(id, null);
			}
		}, animationTime);
		
	};
	
	this.markerClickEventHandler=function(viewMarker){
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
		
		//show or hide subMarkers if has
		if(model.getMapMarkerById(viewMarker.id).subMarkersArray.length!=0){
			changeSubMarkerShowStatus(viewMarker.id);
		}
		
		this.showInfoClickHandler(viewMarker.id);
		
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
	
	//overview marker drag event
	this.viewMarkerDragendEventHandler=function(id,lat,lng){
		var ovMarker=model.getMapMarkerById(id);
		
		//update offset
		var routine=model.getRoutineById(id);
		var offsetResult=calculateOffset(routine.id,id);
		ovMarker.updateOffset(offsetResult.offsetX,offsetResult.offsetY);		
		ovMarker.getContent().updateContent({lat:lat,lng:lng});
		$.publish('updateOvLines');
	};
	
	//markers drag event
	this.markerDragendEventHandler=function(id,lat,lng){
		var modelMarker=model.getMapMarkerById(id);
		//update lat lng
		modelMarker.content.updateContent({lat:lat,lng:lng});
		
		//gen centre location of the routine
		var routine=model.getRoutineById(id);
		routine.updateLocation();
		
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
		var uuid=model.genUUID();
		
		var routineId=model.currentRoutineId;
		if(routineId==null){
			alert('please select routine first');
			return;
		}
		
		var id=model.createOneMarker(uuid,content,routineId).id;
		console.log('creating markder id:'+ id);
		return id;
	};
	
	this.markerDeleteClickHandler=function(viewMarker){
		var r=confirm("Do you want to delete attached img?");
		model.deleteOneMarker(viewMarker.id,r);
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
		if(model.currentRoutineId!=null){
			var markers=model.getRoutineById(model.currentRoutineId).getMarkers();
			
			for(var i in markers){
				var modelMarker=markers[i];
				if(!modelMarker.isSubMarker()){
					ids.push(modelMarker.id);
				}
			}
		}
		
		view.clearMarkerCluster();
		view.AddMarkers2Cluster(ids);
		
	}
	
	function loadAllOvMarkersByUserId(userId){
		//todo: resetId
		model.loadAllOverviewRoutine(userId,function(isUserOwnRoutine){
			isUserOwnThisRoutine=isUserOwnRoutine;
			console.log('isUserOwnRoutine:'+isUserOwnThisRoutine);
			
			if(!isUserOwnThisRoutine){
				setTimeout(function(){
					self.disableEditFunction();
				},100);
			}
			
			self.zoomEventHandler();	
		});
	}
	
	this.loadRoutines=function(){
		//todo: clean all existOverlay in view
		model.resetModels();
		view.resetView();
		
		loadAllOvMarkersByUserId(QueryString.userId);
		/*
		if(QueryString.routineId!=null){
			model.fetchUserIdByRoutineId(QueryString.routineId, function(userId){
				model.loadAllOverviewRoutine(userId,function(isUserOwnRoutine){
					for(var i in model.getAllOverviewMarkers()){
						if(model.getAllOverviewMarkers()[i].routineId==QueryString.routineId){
							var id = model.getAllOverviewMarkers()[i].id;
							view.fitBoundsByIds([id]);
							self.overviewMarkerClickEventHandler(id, 10000);
							break;
						}
					}
					
					view.setMapZoom(5);
					
					self.zoomEventHandler();
					
					console.log('isUserOwnThisRoutine: '+isUserOwnRoutine);
					
					isUserOwnThisRoutine=isUserOwnRoutine;
								
					if(!isUserOwnThisRoutine){
						setTimeout(function(){
							disableEditFunction();
						},100);
					}
				});
			});
		}else{
			loadAllOvMarkersByUserId(QueryString.userId);
		}
		*/
	};
	
	this.sync=function(){
		model.sync2Cloud(function(){
			self.change2CustomStyle();
			self.loadRoutines();
		});
	};
	
	this.searchMarkerClick=function(SearchMarkerinfo){
		view.searchMarkerModal.setTitle(SearchMarkerinfo.title);
		view.searchMarkerModal.setSubTitle('');
		view.searchMarkerModal.show();
		
		var ovMarkers=model.fetchNonRepeatOvMarkers();
		var routineNames=[];
		for(var i in ovMarkers){
			routineNames.push({name:ovMarkers[i].content.getTitle(),value:ovMarkers[i].id});
		}
		
		view.searchPickRoutineBoard.setDropDownItems(routineNames);
		if(model.getCurrentOverviewMarkers().length>0){
			var title=model.getCurrentOverviewMarkers()[0].content.getTitle();
			view.searchPickRoutineBoard.setRoutineNameSelect({name:title,value:model.getCurrentOverviewMarkers()[0].routineId});
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
			//view.infocard.hide();
			$.publish('updateUI',[]);
		};
	};
	
	this.deleteViewOvMarker=function(){
		return function(_,id){
			view.removeById(id);
			//view.infocard.hide();
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
			if(!isInCustomZoom){
				view.addOneMark(modelMarker.content.getLat(),
						modelMarker.content.getLng(), modelMarker.id);
				view.changeMarkerIcon(modelMarker.id, modelMarker.content.getIconUrl());
				view.setMarkerAnimation(modelMarker.id, "DROP");
			}
		};
	};
	
	this.createOverviewMarker=function(){
		return function(_,modelMarker,content){
			var options={};
			options.needDrag=true;
			
			view.addOverviewMarker(modelMarker.content.getLat(),
							modelMarker.content.getLng(), modelMarker.id,options);
			if(content.isAverage){
				view.setMarkerZIndex(modelMarker.id, 0);
			}
			
			view.changeMarkerIcon(modelMarker.id, modelMarker.content.getIconUrl());
		};
	};
	
	this.createModelRoutine=function(){
		return function(_,modelMarker,content){
			var options={};
			options.needDrag=false;
			
			view.addOverviewMarker(modelMarker.content.getLat(),
							modelMarker.content.getLng(), modelMarker.id,options);
			view.setMarkerZIndex(modelMarker.id, 0);
			
			view.changeMarkerIcon(modelMarker.id, modelMarker.content.getIconUrl());
			
		};
	};
	
	this.deleteModelRoutine=function(){
		return function(_,modelRoutine){
			var ovMarkers=modelRoutine.ovMarkers;
			var markers=modelRoutine.markers;
			view.removeById(modelRoutine.id);
			for(var i in ovMarkers){
				view.removeById(ovMarkers[i].id);
			}
			for(var j in markers){
				view.removeById(markers[i].id);
			}
			
		};
	};
	
	this.updateOvLines=function(){
		return function(_){
			if(isInCustomZoom){
				view.removeAllOvLines();
				var modelRoutines=model.getModelRoutines();
				for(var i in modelRoutines){
					var modelRoutine=modelRoutines[i];
					var ovMarkers=modelRoutine.getOvMarkers();
					if(ovMarkers.length>0){
						var from={lat:modelRoutine.getContent().getLat(),
								lng:modelRoutine.getContent().getLng()};
						for(var j in ovMarkers){
							var ovMarker=ovMarkers[j];
							var to={lat:ovMarker.getContent().getLat(),
									lng:ovMarker.getContent().getLng()};
							view.drawOvLine(from, to);
						}
					}
				}
			}else{
				view.removeAllOvLines();
			}
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
			
		};
	};
	
	$.subscribe('deleteOvMarker',this.deleteViewOvMarker());
	$.subscribe('deleteOneMarker',this.deleteViewMarker());
	$.subscribe('createOneMarker',this.createViewMarker());
	$.subscribe('createOverViewMarker',this.createOverviewMarker());
	$.subscribe('createModelRoutine',this.createModelRoutine());
	$.subscribe('deleteModelRoutine',this.deleteModelRoutine());
	$.subscribe('updateOvLines',this.updateOvLines());
	$.subscribe('updateUI',this.updateUIRoute());
	$.subscribe('updateInfoWindow',this.updateMarkerInfoWindow());
	$.subscribe('latlngChanged',this.latlngChangedHandler());
	$.subscribe('iconUrlUpdated',this.iconUrlUpdatedHandler());
}

function ExploreMapController(){
	extend(ExploreMapController,MapController,this);
	
	var view;
	var model;
	
	var zoom5ExploreRange=400000;
	var zoom6ExploreRange=250000;
	var zoom7ExploreRange=120000;
	
	var self=this;
	
	this.init=function(){
		model=new ExploreMapMarkerModel();
		view=new ExploreGoogleMapView(this);
		this.setModel(model);
		this.setView(view);
		//view.createView();
		view.createSearchView();
		this.change2CustomStyle();
		this.disableEditFunction();
	};
	
	this.dragendEventHandler=function(){
		if(!this.isInCustomStyle()){
			console.log('not in custom zoom level return');
			return;
		}
		var zoomLevel=view.getZoom();
		var center=view.getCenter();
		
		var exploreRange=findMinDistanceExploreRange(zoomLevel,center);
		if(exploreRange==null){
			model.resetModels();
			view.resetView();
			//drawCenterCircle(zoomLevel,center);
			//add ovMarkers to new ExploreRange;
			model.fetchOverviewRoutinesByLatlng(center, function(results){
				var newExploreRange=new ExploreRange(zoomLevel,center);
				newExploreRange.cachedRoutineResults=results;
				model.exploreRanges.push(newExploreRange);
				self.disableEditFunction();
				self.zoomEventHandler();
			});	
			console.log('new explore range added');
		}else{
			console.log('find cached explore range');
			model.handlefetchOverviewRoutinesByUserResults(exploreRange.results);
			self.disableEditFunction();
			self.zoomEventHandler();
		}
	};
	
	function findMinDistanceExploreRange(currentZoomLevel,centerLocation){
		var minDistance=900000;
		var result=null;
		
		if(currentZoomLevel==5){
			minDistance=zoom5ExploreRange;
		}else if(currentZoomLevel==6){
			minDistance=zoom6ExploreRange;
		}else if(currentZoomLevel==7){
			minDistance=zoom7ExploreRange;
		}else{
			minDistance=zoom7ExploreRange;
		}
		
		for(var i in model.exploreRanges){
			var exploreRange=model.exploreRanges[i];
			if(exploreRange.zoomLevel==currentZoomLevel){
				var distance=view.computeDistanceBetween(centerLocation, exploreRange.location);
				if(distance<minDistance){
					minDistance=distance;
					result=exploreRange;
				}
			}
		}
		
		return result;
	}
	
	function drawCenterCircle(zoomLevel,center){
		var radius;
		var color;
		if(zoomLevel==5){
			radius=zoom5ExploreRange;
			color='blue';
		}else if(zoomLevel==6){
			radius=zoom6ExploreRange;
			color='green';
		}else if(zoomLevel==7){
			radius=zoom7ExploreRange;
			color='red';
		}else{
			radius=zoom7ExploreRange;
			color='red';
		}
		view.drawCircle(center, radius, color);
	}
}


