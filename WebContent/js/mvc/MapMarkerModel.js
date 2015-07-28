function ExploreMapMarkerModel(){
	extend(ExploreMapMarkerModel,MapMarkerModel,this);
	this.exploreRanges=[];
	
	var self=this;
	
	var backendManager=this.getBackendManager();
	
	this.fetchOverviewRoutinesByLatlng=function(location,successCallback){
		backendManager.fetchOverviewRoutinesByLatlng(location, function(results){
			for(var i in results){
				var routineJSON=results[i].routineJSON;
				var ovMarkersJSON=results[i].ovMarkersJSON;
				self.createModelRoutineByGivenId(routineJSON, ovMarkersJSON);
			}
			successCallback(results);
		});
	};
	
}

function MapMarkerModel() {
	//current routine model markers
	var marks = new Array();
	//current routine ov markers
	var currentOverviewMarkers = new Array();
	
	//all the user ov markers
	//isAverage
	var allOverviewMarkers = new Array();
	
	this.currentRoutineId=null;
	
	var modelRoutines=[];
	
	var self=this;

	var backendManager = new BackendManager();
	
	this.resetModels = function() {
		modelRoutines=[];
		backendManager.reset();
	};
	
	this.loadMarkersByRoutineId=function(routineId,successCallback){
		backendManager.fetchMarkersByRoutineId(routineId, function(markerContents){
			var markers=[];
			for(var i in markerContents){
				var marker= self.createOneMarker(markerContents[i].id, markerContents[i], routineId);
				markers.push(marker);
			}
			successCallback(markers);
		});
	};
	
	this.handlefetchOverviewRoutinesByUserResults=function(results){
		for(var i in results){
			var routineJSON=results[i].routineJSON;
			var ovMarkersJSON=results[i].ovMarkersJSON;
			self.createModelRoutineByGivenId(routineJSON, ovMarkersJSON);
		}
	};
	
	this.fetchAllRoutineNameAndId=function(successCallback){
		backendManager.getCurrentUser(function(currentUser){
			backendManager.fetchAllRoutineNameAndIdByUser(currentUser, function(returnValue){
				successCallback(returnValue);
			});
		});
	};
	
	this.loadAllOverviewRoutine = function(userId,successCallback) {
		allOverviewMarkers = new Array();

		backendManager.getCurrentUser(function(currentUser){
			if(userId==null){
				backendManager.fetchOverviewRoutinesByUser(currentUser, function(results){
					self.handlefetchOverviewRoutinesByUserResults(results);
					successCallback(true);
				});
			}else{
				backendManager.fetchUserByUserId(userId, function(user){
					if(user!=null){
						backendManager.fetchOverviewRoutinesByUser(user,function(results){
							
							self.handlefetchOverviewRoutinesByUserResults(results);
							if(user.id==currentUser.id){
								successCallback(true);
							}else{
								successCallback(false);
							}
						});
					}else{
						backendManager.fetchOverviewRoutinesByUser(currentUser,function(routineJSON,ovMarkersJSON){
							self.handlefetchOverviewRoutinesByUserResults(results);
							successCallback(true);
						});
					}
				});
			};
		});
	};
	
	this.sync2Cloud=function(successCallback){
		
		backendManager.getCurrentUser(function(user){
			var routineJSONs=[];
			for(var i in modelRoutines){
				routineJSONs.push(modelRoutines[i].toJSONObject());
				
				backendManager.saveOvMarkers(modelRoutines[i].toOvMarkersJSONs());
				backendManager.saveMarkers(modelRoutines[i].toMarkersJSONs());
			}
			backendManager.saveRoutines(routineJSONs,user);
			
			backendManager.sync(function(){
				successCallback();
			}); 
			
			for ( var i = 0; i < modelRoutines.length; i++) {
				if (modelRoutines[i].isDelete==true) {
					modelRoutines.splice(i, 1);
					i--;
					continue;
				}
				
				for(var j=0;j<modelRoutines[i].ovMarkers.length;j++){
					if(modelRoutines[i].ovMarkers[j].isDelete==true){
						modelRoutines[i].ovMarkers.splice(j,1);
						j--;
					}
				}
				
				for(var k=0;k<modelRoutines[i].markers.length;k++){
					if(modelRoutines[i].markers[k].isDelete==true){
						modelRoutines[i].markers.splice(k,1);
						k--;
					}
				}
			}
		});
		
	};
	
	this.getModelRoutines=function(){
		var results=[];
		for(var i in modelRoutines){
			if(!modelRoutines[i].isDelete){
				results.push(modelRoutines[i]);
			}
		}
		return results;
	};
	
	this.deleteRoutineByOverviewId = function(overviewMarkerId, successCallback) {
		var modelRoutine=self.getRoutineById(overviewMarkerId);
		modelRoutine.setDelete();
		if(self.currentRoutineId==modelRoutine.id){
			self.currentRoutineId=null;
		}
		$.publish('deleteModelRoutine', [ modelRoutine ]);
		$.publish('updateOvLines');
		$.publish('updateUI');
	};
	
	this.createModelRoutine=function(content){
		var modelRoutineId=self.genUUID();
		var marker = new ModelRoutine(modelRoutineId);
		content.iconUrl='resource/icons/overview_point.png';
		$.publish('createModelRoutine', [ marker,content ]);

		if (content != null) {
			marker.content.updateContent(content);
			marker.updateOffset(content.offsetX, content.offsetY);
		}
		modelRoutines.push(marker);
		
		var ovMarkerId=self.genUUID();
		content.iconUrl='resource/icons/ov_0.png';
		var ovMarker=self.createOverviewMarker(ovMarkerId, content, modelRoutineId);
		marker.ovMarkers.push(ovMarker);
		return modelRoutineId;
	};
	
	this.createModelRoutineByGivenId=function(routineObject,ovMarkerObjects){
		var modelRoutineId=routineObject.id;
		var marker = new ModelRoutine(modelRoutineId);
		marker.userId=routineObject.userId;
		marker.userName=routineObject.userName;
		routineObject.iconUrl='resource/icons/overview_point.png';
		$.publish('createModelRoutine', [ marker,routineObject ]);

		if (routineObject != null) {
			marker.content.updateContent(routineObject);
			marker.updateOffset(routineObject.offsetX, routineObject.offsetY);
		}
		modelRoutines.push(marker);
		
		for(var i in ovMarkerObjects){
			var ovMarkerId=ovMarkerObjects[i].id;
			var ovMarker=self.createOverviewMarker(ovMarkerId, ovMarkerObjects[i], modelRoutineId);
			marker.ovMarkers.push(ovMarker);
		}
	};
	
	this.createOverviewMarker = function(id, content,routineId) {
		var marker = new MapMarker(id);
		marker.routineId=routineId;
		marker.getContent().setCategory(6);
		$.publish('createOverViewMarker', [ marker,content ]);

		if (content != null) {
			marker.content.updateContent(content);
			marker.updateOffset(content.offsetX, content.offsetY);
		}
		return marker;
	};
	
	this.createOneMarker = function(id, content,routineId) {
		var routine=self.getRoutineById(routineId);
		if(routine==null){
			alert('no belong routine found');
			return;
		}
		
		var marker = new MapMarker(id);
		$.publish('createOneMarker', [ marker ]);

		if (content != null) {
			marker.content.updateContent(content);
			marker.updateOffset(content.offsetX, content.offsetY);
		}
		routine.addMarker(marker);
		return marker;
	};
	
	this.deleteOneMarker = function(id, needDeleteAttackedImg) {
		var modelMarker = this.getMapMarkerById(id);
		if (modelMarker != null) {

			// unconnect pre main model marker
			if (modelMarker.prevMainMarker != null) {
				modelMarker.prevMainMarker.disconnectNextMarker();
			}

			// unconnect next main model marker
			if (modelMarker.connectedMainMarker != null) {
				modelMarker.disconnectNextMarker();
			}

			// unconnect parentSubMarker
			if (modelMarker.parentSubMarker != null) {
				modelMarker.parentSubMarker
						.disconnectTreeChildMarker(modelMarker);
			}

			// unconnect all sub marker
			modelMarker.disconnectAllTreeChildMarker();

			var routine=self.getRoutineById(id);
			
			modelMarker.isDelete=true;
				
			routine.updateLocation();

			if (needDeleteAttackedImg) {
				var imgUrls = modelMarker.content.getImgUrls();
				if (imgUrls != null && imgUrls.length > 0) {
					for ( var i in imgUrls) {
						var url = imgUrls[i];
						backendManager.deleteFileByUrl(url, function() {
							console.log('success deleted img ');
						}, function() {
							console.log('fail delete img');
						});
					}
					;
				}
			}
			$.publish('deleteOneMarker', [ modelMarker ]);
		}
	};

	
	
	this.fetchUserIdByRoutineId=function(routineId,successCallBack){
		backendManager.fetchUserByRoutineId(routineId, function(user){
			if(user!=null){
				successCallBack(user.id);
			}else{
				successCallBack(null);
			}	
		});
	};
	
	this.getBackendManager=function(){
		return backendManager;
	};
	
	//one routine can have multi ovMarkers right now,they have the same title
	//and description. this method will try to filter the repeat markers
	this.fetchNonRepeatOvMarkers=function(){
		var nonRepeatOvMarker=[];
		for(var i in allOverviewMarkers){
			var routineId=allOverviewMarkers[i].routineId;
			var isExist=false;
			for(var j in nonRepeatOvMarker){
				if(routineId==nonRepeatOvMarker[j].routineId){
					isExist=true;
				}
			}
			if(!isExist){
				nonRepeatOvMarker.push(allOverviewMarkers[i]);
			}
		}
		return nonRepeatOvMarker;
	};
	
	this.copyRoutine2CurrentUser=function(ovMarkerId){
		var routineId=self.getRoutineById(ovMarkerId).id;
		backendManager.copyRoutine(routineId);
	};
	
	this.copyMarker2CurrentUser=function(markerId,toRoutineId){
		backendManager.copyMarker(markerId, toRoutineId);
	};
	
	this.isOvMarker=function(id){
		var routines=self.getModelRoutines();
		for(var i in routines){
			if(routines[i].id==id){
				return true;
			}
			
			var ovMarkers=routines[i].getOvMarkers();
			for(var j in ovMarkers){
				if(id==ovMarkers[j].id){
					return true;
				}
			}
		}
		return false;
	};
	
	this.findAverageOvMarkerByOvId=function(id){
		var ovMarker=self.getMapMarkerById(id);
		for(var i in allOverviewMarkers){
			if(ovMarker.routineId==allOverviewMarkers[i].routineId && 
					allOverviewMarkers[i].content.isAvergeOverViewMarker()){
				return allOverviewMarkers[i];
			}else{
				continue;
			}
		}
		return null;
	};

	this.getCurrentOverviewMarkers = function() {
		return currentOverviewMarkers;
	};
	
	this.setCurrenOverviewMarkersByOverviewId=function(id){
		currentOverviewMarkers=new Array();
		var routineId=this.getMapMarkerById(id).routineId;
		for(var i in allOverviewMarkers){
			if(allOverviewMarkers[i].routineId==routineId){
				currentOverviewMarkers.push(allOverviewMarkers[i]);
			}
		}
	};

	//all the markers need to show on custom style called allOverviewMarkers
	this.getAllOverviewMarkers = function() {
		var results=[];
		var routines=self.getModelRoutines();
		for(var i in routines){
				results.push(routines[i]);
				var ovMarkers=routines[i].getOvMarkers();
				for(var j in ovMarkers){
					results.push(ovMarkers[j]);
				}
		}
		return results;
	};
	
	this.getRoutineById=function(id){
		var routines=self.getModelRoutines();
		
		for(var i in routines){
			if(routines[i].id==id){
				return routines[i];
			}
			var ovMarkers=routines[i].getOvMarkers();
			for (var j in ovMarkers){
				if(ovMarkers[j].id==id){
					return routines[i];
				}
			}
			var markers=routines[i].getMarkers();
			for (var k in markers){
				if(markers[k].id==id){
					return routines[i];
				}
			}
		}
		alert('can not found routineId');
		return null;
	};

	this.genUUID = function() {
		return uuid.v4();
	};

	this.saveImage = function(imageFile, successCallback, failCallback) {
		backendManager.saveFile(imageFile, function(url) {
			successCallback(url);
		}, function(error) {
			failCallback(error);
		});
	};

	this.saveImageByBase64 = function(base64String, fileName, successCallback,
			failCallback) {
		backendManager.saveBase64File(base64String, fileName, function(url) {
			successCallback(url);
		}, function(error) {
			failCallback(error);
		});
	};

	

	this.getModelMarkers = function() {
		var results=[];
		var routines=self.getModelRoutines();
		for(var i in routines){
			var markers=routines[i].getMarkers();
			for(var j in markers){
				results.push(markers[j]);
			}
		}
		return results
	};

	this.fetchMaxIdinMarks = function() {
		marks.sort(function(mark1, mark2) {
			if (mark1.id > mark2.id) {
				return 1;
			} else if (mark1.id == mark2.id) {
				return 0;
			} else {
				return -1;
			}
		});

		return marks[marks.length - 1].id;
	};
	
	this.deleteOvMarker=function(id){
		var ovMarker=this.getMapMarkerById(id);
		if(ovMarker.content.isAvergeOverViewMarker()){
			alert("this marker can not be deleted");
			return;
		}else{
			for ( var i in allOverviewMarkers) {
				if (allOverviewMarkers[i].id == id) {
					allOverviewMarkers.splice(i, 1);
				}
			}
			
			if(currentOverviewMarkers.length!=0){
				for ( var i in currentOverviewMarkers) {
					if (currentOverviewMarkers[i].id == id) {
						currentOverviewMarkers.splice(i, 1);
					}
				}
			}
			
			$.publish('deleteOvMarker', [ id ]);
			$.publish('updateOvLines');
		}
	};

	this.isUserOwnRoutine = function(routineId, successCallback) {
		backendManager.getCurrentUser(function(currentUser){
			backendManager.isUserOwnRoutines(currentUser, routineId,
					successCallback);
		});
	};

	this.loadRoutineByOverviewMarkerId = function(overviewId, successCallback) {
		marks = new Array();

		backendManager.fetchRoutineJSONStringByOverviewMarkerId(overviewId,
				function(marksJSONString, routineName) {
					if (marksJSONString != null) {
						// parse markers
						var marksJSONArray = JSON.parse(marksJSONString);
						for ( var i in marksJSONArray) {

							self.createOneMarker(marksJSONArray[i].id,
									marksJSONArray[i]);

						}

						for ( var i in marksJSONArray) {
							var eachJSONObject = marksJSONArray[i];

							for ( var j in eachJSONObject.subMarkerIds) {
								self.addSubLine(eachJSONObject.id,
										eachJSONObject.subMarkerIds[j], 0, 0);
							}
						}

					}

					successCallback(routineName);
				});

	};

	this.loadRoutine = function(routineId, successCallback) {
		marks = new Array();

		backendManager.fetchRoutineJSONStringById(routineId, function(
				marksJSONString, title, overViewJSONString) {
			if (overViewJSONString != null) {
				// parse overview markers
				var overviewJSONArray = JSON.parse(overViewJSONString);
				for ( var i in overviewJSONArray) {
					self.createOverviewMarker(overviewJSONArray[i].id,
							overviewJSONArray[i]);
				}
			}

			if (marksJSONString != null) {
				// parse markers
				var marksJSONArray = JSON.parse(marksJSONString);
				for ( var i in marksJSONArray) {
					self.createOneMarker(marksJSONArray[i].id,
							marksJSONArray[i]);
				}

				for ( var i in marksJSONArray) {
					var eachJSONObject = marksJSONArray[i];
					for ( var j in eachJSONObject.subMarkerIds) {
						self.addSubLine(eachJSONObject.id,
								eachJSONObject.subMarkerIds[j], 0, 0);
					}
				}

			}
			console.log('model.loadRoutine:fetch routine success');
			successCallback({
				routineName : title,
			});
		});

	};

	function getOverlayById(id) {
		var length = marks.length;
		for ( var i = 0; i < length; i++) {
			if (marks[i].id == id) {
				return marks[i];
			}
		}
		return null;
	}

	this.getMapMarkerById = function(id) {
		
		var routines=self.getModelRoutines();
		for(var i in routines){
			var modelRoutine=routines[i];
			if(modelRoutine.id==id){
				return modelRoutine;
			}
			var ovMarkers=modelRoutine.getOvMarkers();
			for(var j in ovMarkers){
				if(id==ovMarkers[j].id){
					return ovMarkers[j];
				}
			}
			var markers=modelRoutine.getMarkers();
			for(var k in markers){
				if(id==markers[k].id){
					return markers[k];
				}
			}
		}
		alert('can not find model marker :' + id);
		return null;
		/*
		var marker = getOverlayById(id);
		if (marker == null) {
			var length = allOverviewMarkers.length;
			for ( var i = 0; i < length; i++) {
				if (allOverviewMarkers[i].id == id) {
					return allOverviewMarkers[i];
				}
			}
			alert('can not find model marker :' + id);
			return null;
		} else {
			return marker;
		}
		*/

	};

	this.getMarkerContentById = function(id) {
		var marker = this.getMapMarkerById(id);
		if (marker.getContent() != null) {
			return marker.getContent();
		} else {
			return null;
		}
	};

	this.addMainLine = function(fromId, toId) {
		var fromMarker = getOverlayById(fromId);
		var toMarker = getOverlayById(toId);
		fromMarker.addNextMarker(toMarker);

	};

	this.addSubLine = function(fromId, toId) {
		console.log("model.addSubLine: fromId: " + fromId + " toId " + toId);
		var fromMarker = getOverlayById(fromId);
		var toMarker = getOverlayById(toId);
		fromMarker.addTreeChildMarker(toMarker);
	};

	this.findHeadMarker = function() {
		var heads = new Array();
		var length = marks.length;
		for ( var i = 0; i < length; i++) {
			if (marks[i] instanceof MapMarker) {
				if (marks[i].prevMainMarker == null && !marks[i].isSubMarker()) {
					heads.push(marks[i]);
				}
			}
		}
		return heads;
	};

	this.belongWhichHeadIds = function(markerId) {
		var modelMarker = this.getMapMarkerById(markerId);

		if (modelMarker.prevMainMarker == null) {
			var routineIds = [];
			var headMarker = modelMarker;
			do {
				routineIds.push(headMarker.id);
				headMarker = headMarker.connectedMainMarker;
			} while (headMarker != null);
			console.log("model.belongwhichHeadIds: return " + routineIds);
			return routineIds;
		} else {
			return this.belongWhichHeadIds(modelMarker.prevMainMarker.id);
		}
	};

	this.redrawConnectedLine = function(id) {
		var marker = getOverlayById(id);
		// redraw curveLine
		if (marker.prevMainMarker != null) {
			redrawOneMarker(marker.prevMainMarker);
		}
		redrawOneMarker(marker);

		if (marker.parentSubMarker != null) {
			redrawTreeNode(marker.parentSubMarker);
		}
		redrawTreeNode(marker);
	};

	function redrawOneMarker(marker) {
		if (marker.connectedMainMarker == null) {
			return;
		} else {
			// redraw Curve Line
			if (marker.connectedMainLine != null) {
				// marker.connectedMainLine.remove(map);
				view.removeById(marker.connectedMainLine.id);
			}
			// addCurveLine(map,marker.getPosition(),marker.connectedMainMarker.getPosition());
			marker.connectedMainLine = new MainLine(view.drawMainLine(
					marker.id, marker.connectedMainMarker.id));

		}
	}

	function redrawTreeNode(marker) {
		for ( var j in marker.subMarkersArray) {
			// map.removeOverlay(marker.subMarkersArray[j].line);
			view.removeById(marker.subMarkersArray[j].line.id);
			marker.subMarkersArray[j].line = new SubLine(view.drawSubLine(
					marker.id, marker.subMarkersArray[j].entity.id));
			/*
			 * if(marker.areSubMarkersHide()){
			 * marker.subMarkersArray[j].line.hide(); }
			 */
		}
	}
}

function BackendManager() {
	var Routine = AV.Object.extend("Routine");
	var OvMarker= AV.Object.extend("OvMarker");
	var AVMarker= AV.Object.extend("Marker");

	//current Routine
	var routine = null;
	
	//current User
	var currentUser = null;
	
	// current Routine Markers
	var avMarkers=[];
	
	//all user routines
	var userRoutines = null;
	
	var avObjects=[];
	
	function iconNameToUrl(iconName){
		var strArray=iconName.trim().split("/");
		if(strArray.length>2){
			return "resource/icons/"+strArray.pop();
		}else{
			return "resource/icons/"+iconName.trim();
		}
	}

	AV.initialize("6pzfpf5wkg4m52owuwixt5vggrpjincr8xon3pd966fhgj3c",
			"4wrzupru1m4m7gpafo4llinv7iepyapnycvxygup7uiui77x");

	function fetchOvMarkersByRoutineId(avRoutine){
		var promise=new AV.Promise();
		var query=new AV.Query(OvMarker);
		query.equalTo("routineId",avRoutine.get("uuid"));
		query.find().then(function(avOvMarkers){
			promise.resolve(avRoutine,avOvMarkers);
		});
		return promise;
	};
	
	function fetchOvMarkersInRoutineIds(avRoutines){
		var promise=new AV.Promise();
		var query=new AV.Query(OvMarker);
		var routineIds=[];
		for(var i in avRoutines){
			routineIds.push(avRoutines[i].get("uuid"));
		}
		query.containedIn("routineId",routineIds);
		query.find().then(function(avOvMarkers){
			var results=[];
			for(var i in avRoutines){
				results.push({
					avRoutine:avRoutines[i],
					avOvMarkers:findOvMarkersByRoutineId(avOvMarkers,avRoutines[i].get("uuid"))
				});
			}
			
			promise.resolve(results);
		});
		return promise;
	};
	
	function findOvMarkersByRoutineId(ovMarkers,routineId){
		var results=[];
		for(var i in ovMarkers){
			if(ovMarkers[i].get("routineId")==routineId){
				results.push(ovMarkers[i]);
			}
		}
		return results;
	}
	
	function getAVObjectByUUID(uuid){
		for(var i in avObjects){
			if(uuid==avObjects[i].get('uuid')){
				return avObjects[i];
			}
		}
		return null;
	};
	
	function getAvMarkerByUUID(uuid){
		for(var i in avMarkers){
			if(uuid==avMarkers[i].get('uuid')){
				return avMarkers[i];
			}
		}
		return null;
	};
	
	this.reset=function(){
		avObjects=[];
	};
	
	this.saveMarkers=function(jsons){
		for(var i in jsons){
			
			var markerJSON=jsons[i];
			
			var avMarker=getAVObjectByUUID(markerJSON.uuid);
			if(avMarker!==null && markerJSON.needDelete){
				avMarker.needDelete=true;
				continue;
			}
			
			if(avMarker==null && markerJSON.needDelete){
				continue;
			}
			
			if(avMarker==null){
				avMarker=new AVMarker();
				avObjects.push(avMarker);
			}
			avMarker.set('uuid',markerJSON.uuid);
			var point = new AV.GeoPoint({latitude: markerJSON.lat, longitude: markerJSON.lng});
			avMarker.set('location',point);
			avMarker.set('title',markerJSON.title);
			avMarker.set('address',markerJSON.address);
			avMarker.set('mycomment',markerJSON.mycomment);
			avMarker.set('category',markerJSON.category);
			avMarker.set('imgUrls',JSON.stringify(markerJSON.imgUrls));
			avMarker.set('iconUrl',markerJSON.iconUrl);
			avMarker.set('slideNum',markerJSON.slideNum);
			avMarker.set('subMarkerIds',JSON.stringify(markerJSON.subMarkerIds));
			avMarker.set('offsetX',markerJSON.offsetX);
			avMarker.set('offsetY',markerJSON.offsetY);
			avMarker.set('routineId',markerJSON.routineId);
		}
	};
	
	this.saveOvMarkers=function(jsons){
		for(var i in jsons){
			
			var markerJSON=jsons[i];
			
			var avMarker=getAVObjectByUUID(markerJSON.uuid);
			if(avMarker!==null && markerJSON.needDelete){
				avMarker.needDelete=true;
				continue;
			}
			
			if(avMarker==null && markerJSON.needDelete){
				continue;
			}
			
			if(avMarker==null){
				avMarker=new OvMarker();
				avObjects.push(avMarker);
			}
			avMarker.set('uuid',markerJSON.uuid);
			var point = new AV.GeoPoint({latitude: markerJSON.lat, longitude: markerJSON.lng});
			avMarker.set('location',point);
			avMarker.set('title',markerJSON.title);
			avMarker.set('address',markerJSON.address);
			avMarker.set('mycomment',markerJSON.mycomment);
			avMarker.set('category',markerJSON.category);
			avMarker.set('imgUrls',JSON.stringify(markerJSON.imgUrls));
			avMarker.set('iconUrl',markerJSON.iconUrl);
			avMarker.set('slideNum',markerJSON.slideNum);
			avMarker.set('subMarkerIds',JSON.stringify(markerJSON.subMarkerIds));
			avMarker.set('offsetX',markerJSON.offsetX);
			avMarker.set('offsetY',markerJSON.offsetY);
			avMarker.set('routineId',markerJSON.routineId);
		}
	};
	
	this.saveRoutines=function(routineJSONs,user){
		for(var i in routineJSONs){
			
			var routineJSON=routineJSONs[i];
			
			var avRoutine=getAVObjectByUUID(routineJSON.uuid);
			if(avRoutine!==null && routineJSON.needDelete){
				avRoutine.needDelete=true;
				continue;
			}
			
			if(avRoutine==null && routineJSON.needDelete){
				continue;
			}
			
			if(avRoutine==null){
				avRoutine=new Routine();
				avObjects.push(avRoutine);
			}
			avRoutine.set('user',user);
			avRoutine.set('uuid',routineJSON.uuid);
			avRoutine.set('title',routineJSON.title);
			avRoutine.set('description',routineJSON.mycomment);
			var point = new AV.GeoPoint({latitude: routineJSON.lat, longitude: routineJSON.lng});
			avRoutine.set('location',point);
		}
	};
	
	this.sync=function(successCallback){
		//delete
		var avObjectsNeed2Delete=[];
		for ( var i = 0; i < avObjects.length; i++) {
			if (avObjects[i].needDelete==true) {
				avObjectsNeed2Delete.push(avObjects[i]);
				avObjects.splice(i, 1);
				i--;
			}
		}
		
		for(var i in avObjectsNeed2Delete){
			avObjectsNeed2Delete[i].destroy();
		}
		
		//save new or update
		AV.Object.saveAll(avObjects).then(function(){
			alert('sync success');
			successCallback();
		},function(error){
			alert(error.message);
		});
	};
	
	function gcjLocation(avLocation){
		var lat=avLocation.toJSON().latitude;
		var lng=avLocation.toJSON().longitude;
		var gcj=wgs2gcj(lat,lng);
		return gcj;
	}
	
	this.fetchMarkersByRoutineId=function(routineId,successCallback){
		var query=new AV.Query(AVMarker);
		query.equalTo("routineId",routineId);
		query.find().then(function(avMarkers){
			var markersJSON=[];
			for(var i in avMarkers){
				var avMarker=avMarkers[i];
				avObjects.push(avMarker);
				var markerContent={
					id: avMarker.get('uuid'),
					title:avMarker.get('title'),
					mycomment:avMarker.get('mycomment'),
					iconUrl:iconNameToUrl(avMarker.get('iconUrl')),
					lat:gcjLocation(avMarker.get('location')).lat,
					lng:gcjLocation(avMarker.get('location')).lng,
					slideNum:avMarker.get('slideNum'),
					imgUrls:JSON.parse(avMarker.get('imgUrls')),
					category:avMarker.get('category')
				};
				markersJSON.push(markerContent);
			}
			successCallback(markersJSON);
		});
	};
	
	this.fetchOverviewRoutinesByLatlng=function(location, successCallback){
		var locationPoint=new AV.GeoPoint({latitude: location.lat, longitude: location.lng});
		var query=new AV.Query(Routine);
		query.include("user");
		query.near('location',locationPoint);
		query.limit(10);
		query.find({
			success : function(avRoutines) {
				fetchOvMarkersInRoutineIds(avRoutines).then(function(results){
					var returnValue=[];
					
					for(var i in results){
						var routine=results[i].avRoutine;
						var user=routine.get("user");
						var ovMarkers=results[i].avOvMarkers;
						avObjects.push(routine);
						
						var routineLat=gcjLocation(routine.get('location')).lat;
						var routineLng=gcjLocation(routine.get('location')).lng;
						
						var routineJSON={
								userId:user.id,
								userName:user.get('username'),
								id:routine.get('uuid'),
								title:routine.get('title'),
								mycomment:routine.get('description'),
								category:routine.get('category'),
								lat:routineLat,
								lng:routineLng
						};
						
						var ovMarkersJSON=[];
						for(var i in ovMarkers){
							avObjects.push(ovMarkers[i]);
							ovMarkersJSON.push({
								id:ovMarkers[i].get('uuid'),
								title: ovMarkers[i].get('title'),
								mycomment:ovMarkers[i].get('mycomment'),
								iconUrl:iconNameToUrl(ovMarkers[i].get('iconUrl')),
								offsetX:ovMarkers[i].get('offsetX'),
								offsetY:ovMarkers[i].get('offsetY'),
								category:ovMarkers[i].get('category'),
								lat:ovMarkers[i].get('location')==null?routineLat:gcjLocation(ovMarkers[i].get('location')).lat,
								lng:ovMarkers[i].get('location')==null?routineLng:gcjLocation(ovMarkers[i].get('location')).lng
							});
						}
						returnValue.push({
							routineJSON:routineJSON,
							ovMarkersJSON:ovMarkersJSON
						});
						//successCallback(routineJSON,ovMarkersJSON);
					}
					successCallback(returnValue);
				});
				
			}
		});
	};
	
	this.fetchAllRoutineNameAndIdByUser=function(user,successCallback){
		var query = new AV.Query(Routine);
		query.equalTo("user", user);
		query.find().then(function(avRoutines){
			var returnValue=[];
			for(var i in avRoutines){
				returnValue.push({
					routineId:avRoutines[i].get('uuid'),
					routineName:avRoutines[i].get('title')
				});
			}
			successCallback(returnValue);
		});
	};
	
	this.fetchOverviewRoutinesByUser = function(user, successCallback) {
		var query = new AV.Query(Routine);
		query.equalTo("user", user);
		query.find().then(function(avRoutines){
			fetchOvMarkersInRoutineIds(avRoutines).then(function(results){
				var returnValue=[];
				
				for(var i in results){
					var routine=results[i].avRoutine;
					var ovMarkers=results[i].avOvMarkers;
					avObjects.push(routine);
					
					var routineLat=gcjLocation(routine.get('location')).lat;
					var routineLng=gcjLocation(routine.get('location')).lng;
					
					var routineJSON={
							userId:user.id,
							userName:user.get('username'),
							id:routine.get('uuid'),
							title:routine.get('title'),
							mycomment:routine.get('description'),
							lat:routineLat,
							lng:routineLng
					};
					
					var ovMarkersJSON=[];
					for(var i in ovMarkers){
						avObjects.push(ovMarkers[i]);
						ovMarkersJSON.push({
							id:ovMarkers[i].get('uuid'),
							title: ovMarkers[i].get('title'),
							mycomment:ovMarkers[i].get('mycomment'),
							iconUrl:iconNameToUrl(ovMarkers[i].get('iconUrl')),
							offsetX:ovMarkers[i].get('offsetX'),
							offsetY:ovMarkers[i].get('offsetY'),
							lat:ovMarkers[i].get('location')==null?routineLat:gcjLocation(ovMarkers[i].get('location')).lat,
							lng:ovMarkers[i].get('location')==null?routineLng:gcjLocation(ovMarkers[i].get('location')).lng
						});
					}
					returnValue.push({
						routineJSON:routineJSON,
						ovMarkersJSON:ovMarkersJSON
					});
					//successCallback(routineJSON,ovMarkersJSON);
				}
				successCallback(returnValue);
			});
		});
	};
	
	this.copyRoutine=function(routineId){
		var newRoutineId=uuid.v4();
		this.getCurrentUser(function(user){
			if(user.get("username")=="guest"){
				alert("please login first");
				return;
			}
			
			var routineQuery = new AV.Query(Routine);
			routineQuery.equalTo("uuid",routineId);
			routineQuery.first().then(function(routine){
				if(routine!=null){
					var copyRoutine=routine.clone();
					copyRoutine.set('uuid',newRoutineId);
					copyRoutine.set('user',user);
					copyRoutine.save();
				}
			});
			
			var ovMarkerQuery=new AV.Query(OvMarker);
			ovMarkerQuery.equalTo("routineId",routineId);
			ovMarkerQuery.find().then(function(ovMarkers){
				var copyMarkers=[];
				for(var i in ovMarkers){
					var copyMarker=ovMarkers[i].clone();
					copyMarker.set("uuid",uuid.v4());
					copyMarker.set("routineId",newRoutineId);
					copyMarkers.push(copyMarker);
					
				}
				AV.Object.saveAll(copyMarkers);
			});
			
			var markerQuery=new AV.Query(AVMarker);
			markerQuery.equalTo("routineId",routineId);
			markerQuery.find().then(function(ovMarkers){
				var copyMarkers=[];
				for(var i in ovMarkers){
					var copyMarker=ovMarkers[i].clone();
					copyMarker.set("uuid",uuid.v4());
					copyMarker.set("routineId",newRoutineId);
					copyMarkers.push(copyMarker);
					
				}
				AV.Object.saveAll(copyMarkers);
			});	
		});
	};
	
	this.copyMarker=function(markerId,toRoutineId){
		var query=new AV.Query(AVMarker);
		query.equalTo("uuid",markerId);
		query.first().then(function(marker){
			var copyMarker=marker.clone();
			copyMarker.set("uuid",uuid.v4());
			copyMarker.set("routineId",toRoutineId);
			copyMarker.save();
		});
	};
	
	this.sayHello=function(){
		AV.Cloud.run('hello', {}, {
			success: function(result) {
			    alert(result);
			},
			error: function(error) {
				alert(error);
			}
		});
	};
	
	this.cloudFetchMarkersByRoutineId=function(routineId){
		AV.Cloud.run('hello', {routineId:routineId}, {
			success: function(result) {
			    console.log(result);
			},
			error: function(error) {
				alert(error);
			}
		});
	};
	
	//------------------------------------------------------------
	this.saveCurrentRoutineMarkers=function(markers,ovMarkers){
		
		
		var avMarkersNeed2Save=[];
		for(var i in markers){
			var marker=markers[i];
			var avMarker=getAvMarkerByUUID(marker.uuid);
			if(avMarker==null){
				avMarker=new AVMarker();
				avMarker.set('uuid',marker.uuid);
			}
			
			var point = new AV.GeoPoint({latitude: marker.lat, longitude: marker.lng});
			avMarker.set('location',point);
			avMarker.set('title',marker.title);
			avMarker.set('address',marker.address);
			avMarker.set('mycomment',marker.mycomment);
			avMarker.set('category',marker.category);
			avMarker.set('imgUrls',JSON.stringify(marker.imgUrls));
			avMarker.set('iconUrl',marker.iconUrl);
			avMarker.set('slideNum',marker.slideNum);
			avMarker.set('subMarkerIds',JSON.stringify(marker.subMarkerIds));
			avMarker.set('offsetX',marker.offsetX);
			avMarker.set('offsetY',marker.offsetY);
			avMarker.set('isOvMarker',false);		
		}
	};
	
	this.login = function(userName, pwd, successCallback) {
		AV.User.logIn(userName, pwd, {
			success : function(user) {
				successCallback(user);
			},
			error : function(user, error) {
				alert('login failed');
			}
		});
	};

	this.getCurrentUser = function(successCallback) {
		currentUser = AV.User.current();
		if (currentUser) {
			console.log("welcomse session user:" + currentUser.get('username'));

			successCallback(currentUser);

		} else {
			AV.User.logIn("guest", "guest", {
				success : function(user) {
					console.log("login for user:" + user.get('username'));
					currentUser = user;
					successCallback(user);
				},
				error : function(user, error) {
					alert("Error: " + error.code + " " + error.message);
					alert("log failed. abort save routines");
					successCallback(null);
				}
			});
		}
	};

	this.fetchRoutinesByUser = function(user, successCallback) {
		var query = new AV.Query(Routine);
		query.equalTo("user", user);
		query.find({
			success : function(routines) {
				console.log("backendManager:fetch routine success");
				successCallback(routines);
			}
		});
	};
	
	this.fetchUserByUserId=function(userId,successCallback){
		console.log('bM.fetchUserByUserId: userId:'+ userId);
		var query = new AV.Query(AV.User);
		query.get(userId,{
		  success: function(user) {
			  console.log('bM.fetchUserByUserId: found user, user name'+ user.get('username'));
			  successCallback(user);
		  }
		});
	};

	
	


	this.deleteRoutineByOverviewMarkerId = function(overviewMarkerId,
			successCallback) {
		for ( var i in userRoutines) {
			var overviewJSONString = userRoutines[i].get('overViewJSONString');
			if (overviewJSONString.indexOf(overviewMarkerId) != -1) {
				userRoutines[i].destroy({
					success : function() {
						successCallback();
					}
				});
			}
		}
	};

	this.fetchRoutineJSONStringByOverviewMarkerId = function(overviewMarkerId,
			successCallback) {
		if (userRoutines == null) {
			return successCallback(null);
		} else {
			for ( var i in userRoutines) {
				var overviewJSONString = userRoutines[i]
						.get('overViewJSONString');
				if (overviewJSONString.indexOf(overviewMarkerId) != -1) {
					routine = userRoutines[i];
					var result = userRoutines[i].get('RoutineJSONString');
					var routineName = userRoutines[i].get('title');
					if (result != null) {
						return successCallback(result, routineName);
					} else {
						userRoutines[i].fetch().then(function(result) {
							var r = result.get('RoutineJSONString');
							successCallback(r, routineName);
						});
					}
				} else {
					continue;
				}
			}
		}
	};
	
	this.fetchUserByRoutineId=function(routineId,successCallback){
		var query = new AV.Query(Routine);
		query.get(routineId, {
			success : function(fetchedRoutine) {
				routine = fetchedRoutine;
				successCallback(routine.get('user'));
			},
			error : function(object, error) {
				alert("The object was not retrieved successfully.");
				console.log(error);
			}
		});
	};

	this.isUserOwnRoutines = function(user, routineId, successCallback) {
		var query = new AV.Query(Routine);
		query.equalTo("user", user);
		query
				.get(
						routineId,
						{
							success : function() {
								console
										.log('BackManager.isUserOwnRoutines: user own this routine');
								successCallback(true);
							},
							error : function(object, error) {
								console
										.log('BackManager.isUserOwnRoutines: user not own this routine');
								successCallback(false);
							}
						});
	};

	this.fetchRoutineJSONStringById = function(objectId, successCallback) {
		console
				.log('BackendManager.FetchRoutineJSONStringById-fetch routine id=:'
						+ objectId);

		var query = new AV.Query(Routine);
		query.get(objectId, {
			success : function(fetchedRoutine) {
				routine = fetchedRoutine;
				successCallback(routine.get('RoutineJSONString'), routine
						.get('title'), routine.get('overViewJSONString'));
			},
			error : function(object, error) {
				alert("The object was not retrieved successfully.");
				console.log(error);
			}
		});
	};
	
	this.updateAllOverviews=function(ovMarkerJSONMap,successCallback){
		for(var key in ovMarkerJSONMap){
			var routineId=key;
			if(routineId!=null){
				for(var j in userRoutines){
					if(userRoutines[j].id==routineId){
						userRoutines[j].set("overViewJSONString",ovMarkerJSONMap[key]);
					}
				}
			}
		}
		
		AV.Object.saveAll(userRoutines, {
			    success: function(list) {
			      console.log("update all overviews success");
			      successCallback();
			    },
			    error: function(error) {
			      console.log("error happenned when update all overview"+error);
			    },
		 });
	};
	
	this.saveAsNewRoutine=function(routineName,routineJSONString,
			overViewJSONString,callback){
		var routine = new Routine();
		
		this.getCurrentUser(function(currentUser){
			if(currentUser.get('username')!='guest'){
				routine.set('title', routineName);
				routine.set('RoutineJSONString', routineJSONString);
				routine.set('user',currentUser );
				routine.set('overViewJSONString', overViewJSONString);
				routine.save(null, {
					success : function(routineFoo) {
						callback();
					},
					error : function(object, error) {
						alert('save routine failed');
						routine = null;
					}

				});
			}else{
				alert('Guest can not save routine. Please login first.');
			}
			
		});
	};

	this.saveRoutine = function(routineName, routineJSONString,
			overViewJSONString, location,callback) {
		if (routine == null) {
			routine = new Routine();
		}
		
		this.getCurrentUser(function(currentUser){
			if(currentUser.get('username')!='guest'){
				routine.set('title', routineName);
				routine.set('RoutineJSONString', routineJSONString);
				routine.set('user',currentUser );
				routine.set('overViewJSONString', overViewJSONString);
				var point = new AV.GeoPoint({latitude: location.lat, longitude: location.lng});
				routine.set('location',point);
				routine.save(null, {
					success : function(routineFoo) {
						routine = routineFoo;
						callback();
					},
					error : function(object, error) {
						alert('save routine failed');
						routine = null;
					}

				});
			}else{
				alert('Guest can not save routine. Please login first.');
			}
			
		});
	};

	this.saveFile = function(file, successCallBack, failCallback) {

		var name = file.name;
		var avFile = new AV.File(name, file);
		avFile.save().then(function() {
			successCallBack(avFile.url());
		}, function(error) {
			failCallback(error);
		});
	};

	this.saveBase64File = function(base64String, fileName, successCallBack,
			failCallback) {
		var avFile = new AV.File(fileName, {
			base64 : base64String
		});
		avFile.save().then(function() {
			successCallBack(avFile.url());
		}, function(error) {
			failCallback(error);
		});
	};

	this.deleteFileByUrl = function(url, successCallBack, failCallback) {
		console.log('BManager.deleteFileByUrl:' + url);
		var query = new AV.Query(AV.Object.extend("_File"));
		query.equalTo("url", url);
		query.find({
			success : function(results) {
				if (results.length > 0) {
					console.log('find url:' + url);

					var file = results[0];
					file.destroy({
						success : function(file) {
							successCallBack();
						},
						error : function(error) {
							console.log("Error: " + error.code + " "
									+ error.message);
							failCallback();
						}
					});

				} else {
					console.log('url ' + url + ' not found');
				}
			},
			error : function(error) {
				console.log("Error: " + error.code + " " + error.message);
				failCallback();
			}
		});
	};

	// getters and setters

}

function MarkerContent(id) {
	this.id = id;

	var title = "One Marker";
	var address = "Unknown Address";
	var lat = 0;
	var lng = 0;
	var mycomment = "";
	var category = 2;
	var imgUrls = new Array();
	var isImgPositionDecided = true;
	var slideNum = 1;

	var isAvergeOverViewMarker = false;

	var defaultImgIcon = "resource/icons/event_2.png";
	var picNoPositionIconUrl = "resource/icons/pic_no_position.png";
	var iconUrl = "resource/icons/default_default.png";
	
	this.isAvergeOverViewMarker = function() {
		return isAvergeOverViewMarker;
	};

	this.setIsAvergeOverViewMarker = function(isAverage) {
		isAvergeOverViewMarker = isAverage;
	};

	this.getSlideNum = function() {
		return slideNum;
	};
	this.setSlideNum = function(num) {
		slideNum = num;
	};

	this.setImgPositionDecided = function(arg) {
		isImgPositionDecided = arg;
		if (isImgPositionDecided) {
			this.setIconUrl(defaultImgIcon);
		} else {
			this.setIconUrl(picNoPositionIconUrl);
		}
	};

	this.isImgPositionDecided = function() {
		return isImgPositionDecided;
	};

	this.updateContent = function(args) {
		if (args.slideNum != null) {
			this.setSlideNum(args.slideNum);
		}

		if (args.title != null) {
			this.setTitle(args.title);
		}

		if (args.address != null) {
			this.setAddress(args.address);
		}

		if (args.mycomment != null) {
			this.setMycomment(args.mycomment);
		}

		if (args.category != null) {
			this.setCategory(args.category);
		}

		if (args.lat != null && args.lng != null) {
			this.setlatlng(args.lat, args.lng);

		}

		if (args.imgUrls != null && args.imgUrls.length != 0) {
			this.setImgUrls(args.imgUrls);
		}

		if (args.iconUrl != null) {
			this.setIconUrl(args.iconUrl);
		}

		if (args.isAverage != null) {
			this.setIsAvergeOverViewMarker(args.isAverage);
		}
	};

	this.addImgUrl = function(url) {
		imgUrls.push(url);
	};

	this.getIconUrl = function() {
		return iconUrl;
	};

	this.setIconUrl = function(arg) {
		iconUrl = arg;
		$.publish("iconUrlUpdated", [ this ]);
	};

	this.getImgUrls = function() {
		return imgUrls;
	};

	this.setImgUrls = function(urlArray) {
		imgUrls=[];
		for(var i in urlArray){
			if(urlArray[i].replace(/\s+/g,"")!=''){
				imgUrls.push(urlArray[i]);
			}
		}
	};

	this.getCategory = function() {
		return category;
	};
	
	this.getCategoryName=function(){
		var name="sight"
		 switch(this.getCategory())
		  {
		  	case 1:
		  		name="arrival & leave";
				break;
		  	case 2:
		  		name="sight";
				break;
		  	case 3:
		  		name="hotel";
				break;
		  	case 4:
		  		name="food";
				break;
		  	case 5:
		  		name="info";
				break;
		  	case 6:
		  		name="overview";
				break;
		  	default:
		  		name="sight";
		  	}
		return name;
	};

	this.setCategory = function(nameFoo) {
		category = nameFoo;
	};

	this.setlatlng = function(latFoo, lngFoo) {
		//var wgs=gcj2wgs(latFoo,lngFoo);
		
		//lat = wgs.lat;
		//lng = wgs.lng;
		
		lat=latFoo;
		lng=lngFoo;
		
		$.publish('latlngChanged', [ this ]);
		$.publish('updateUI', []);
	};

	this.getLng = function() {
		//var gcj=wgs2gcj(lat,lng);
		//return gcj.lng;
		return lng;
	};
	
	this.getLat = function() {
		//var gcj=wgs2gcj(lat,lng);
		//return gcj.lat;
		return lat;
	};

	this.getAddress = function() {
		return address;
	};

	this.setAddress = function(addressFoo) {
		address = addressFoo;
	};

	this.getTitle = function() {
		return title;
	};

	this.setTitle = function(titleFoo) {
		title = titleFoo;
	};

	this.setMycomment = function(comment) {
		mycomment = comment;
	};

	this.getMycomment = function(needShort) {
		return mycomment;
	};
}

function ModelRoutine(id){
	extend(ModelRoutine,MapMarker,this,[id]);
	
	this.ovMarkers=[];
	this.markers=[];
	
	this.getContent().setCategory(6);
	
	this.isLoadMarkers=false;
	
	this.userId=null;
	this.userName=null;
	
	this.addMarker=function(marker){
		this.markers.push(marker);
		this.updateLocation();
	};
	
	this.updateLocation=function(){
		var latArray=[];
		var lngArray=[];
		
		var marks=this.getMarkers();
		for ( var i = 0; i < marks.length; i++) {
			if (!marks[i].isSubMarker()) {
				latArray.push( marks[i].getContent().getLat());
				lngArray.push( marks[i].getContent().getLng());
			}
		}
		
		var averageLat=refineAverage(latArray);
		var averageLng=refineAverage(lngArray);
		
		this.getContent().updateContent({lat:averageLat,lng:averageLng});
	};
	
	function refineAverage(nums){
		var refineArray=[];
		var e=average(nums);
		var d=sDeviation(nums);
		for(var i in nums){
			if(Math.abs((nums[i])-e)<=d){
				refineArray.push(nums[i]);
			}
		}
		
		return average(refineArray);
	}
	
	
	function average(nums){
		var result=0;
		var length=nums.length;
		var sum=0.000000;
		if(length!=0){
			for(var i in nums){
				sum=sum+nums[i];
			}
			result=sum/length;
		}
		return result;
	}
	
	function sDeviation(nums){
		if(nums.length==0){
			return 0;
		}	
		var e=average(nums);
		var sum=0;
		for(var i in nums){
			sum=sum+(nums[i]-e)*(nums[i]-e);
		}
		return Math.sqrt(sum/nums.length); 	
	}
	
	this.setDelete=function(){
		this.isDelete=true;
		
		var ovMarkers=this.getOvMarkers();
		for(var i in ovMarkers){
			ovMarkers[i].isDelete=true;
		}
		var markers=this.getMarkers();
		for(var j in markers){
			markers[j].isDelete=true;
		}
	};
	
	this.toOvMarkersJSONs=function(){
		var results=[];
		for(var i in this.ovMarkers){
			var object=this.ovMarkers[i].toJSONObject();
			object.routineId=this.id;
			results.push(object);
		}
		return results;
	};
	
	this.toMarkersJSONs=function(){
		var results=[];
		for(var i in this.markers){
			var object=this.markers[i].toJSONObject();
			object.routineId=this.id;
			results.push(object);
		}
		return results;
	};
	
	this.getOvMarkers=function(){
		var results=[];
		for(var i in this.ovMarkers){
			if(!this.ovMarkers[i].isDelete){
				results.push(this.ovMarkers[i]);
			}
		}
		return results;
	};
	
	this.getMarkers=function(){
		var results=[];
		for(var i in this.markers){
			if(!this.markers[i].isDelete){
				results.push(this.markers[i]);
			}
		}
		return results;
	};
}

function MapMarker(id) {
	this.id = id;
	this.content = new MarkerContent(id);

	this.needMainLine = false;
	this.needSubLine = false;
	// next Marker and curveLine
	this.connectedMainMarker = null;
	this.connectedMainLine = null;

	// main path
	this.mainPaths = new Array();

	// pre Marker and curveLine
	this.prevMainMarker = null;

	// of MapMarker array
	this.subMarkersArray = new Array();
	this.parentSubMarker = null;

	this.isHideAllSubMarkers = false;

	// if this marker is a submarker,
	// then it has a relative value of pixel x and y cordinates compared to its
	// parent marker
	this.offsetX = 0;
	this.offsetY = 0;

	this.isDelete=false;
	
	this.isSubMarker = function() {
		if (this.parentSubMarker != null) {
			return true;
		} else {
			return false;
		}
	};

	this.updateOffset = function(x, y) {
		if(x!=null && y!=null){
			this.offsetX = x;
			this.offsetY = y;
		}
	};

	this.canAddSubMarker = function(marker) {
		var result = true;
		if (marker.parentSubMarker == null
				&& marker.connectedMainMarker == null
				&& marker.prevMainMarker == null && !this.isSubMarker()) {
			result = true;
		} else {
			result = false;
		}

		return result;
	};

	// logic add
	this.addNextMarker = function(marker) {
		if (!marker.isSubMarker()) {
			if (this.connectedMainMarker != null) {
				this.connectedMainMarker.prevMainMarker = null;
			}

			this.connectedMainMarker = marker;
			marker.prevMainMarker = this;
			$.publish('updateUI', []);
		}
	};

	// logic delete
	this.disconnectNextMarker = function() {
		if (this.connectedMainMarker != null) {
			this.connectedMainMarker.prevMainMarker = null;
			this.connectedMainMarker = null;
		}
	};

	// logic add tree node
	this.addTreeChildMarker = function(treeNodeMarker) {
		if (this.canAddSubMarker(treeNodeMarker)) {
			this.subMarkersArray.push(treeNodeMarker);
			treeNodeMarker.parentSubMarker = this;
			$.publish('updateUI', []);
		}
	};

	// logic delete tree node
	this.disconnectTreeChildMarker = function(mark) {
		if (this.subMarkersArray.length != 0) {
			for ( var i in this.subMarkersArray) {
				if (this.subMarkersArray[i].id == mark.id) {
					this.subMarkersArray[i].parentSubMarker = null;
					this.subMarkersArray.splice(i, 1);
				}
			}
			console.log(this.subMarkersArray);
		}
	};

	this.disconnectAllTreeChildMarker = function() {
		if (this.subMarkersArray.length != 0) {
			for ( var i in this.subMarkersArray) {
				this.subMarkersArray[i].parentSubMarker = null;
			}
			this.subMarkersArray = new Array();
		}
	};

	this.toJSONObject = function() {
		var subMarkerIdsArray = new Array();
		for ( var i in this.subMarkersArray) {
			subMarkerIdsArray.push(this.subMarkersArray[i].id);
		}

		var wgs=gcj2wgs(this.getContent().getLat(),this.getContent().getLng());
		
		
		var object = {
			uuid : this.id,
			lat : wgs.lat,
			lng : wgs.lng,
			title : this.getContent().getTitle(),
			address : this.getContent().getAddress(),
			mycomment : this.getContent().getMycomment(false),
			category : this.getContent().getCategory(),
			imgUrls : this.getContent().getImgUrls(),
			iconUrl : this.extractIconNameFromIconUrl(),
			slideNum : this.getContent().getSlideNum(),
			nextMainMarkerId : this.connectedMainMarker == null ? null
					: this.connectedMainMarker.id,
			subMarkerIds : subMarkerIdsArray,
			mainPaths : this.mainPaths,
			offsetX : this.offsetX,
			offsetY : this.offsetY,
			needDelete : this.isDelete,
			isAverage : this.getContent().isAvergeOverViewMarker()
		};

		return object;
	};
	
	this.extractIconNameFromIconUrl=function(){
		var trimUrl=this.getContent().getIconUrl().trim();
		var strArray=trimUrl.split("/");
		var result=strArray.pop();
		if(result==null || result.trim()==""){
			result="default_default.png";
		}
		return result;
	};

	// getters and setters
	this.getContent = function() {
		return this.content;
	};

}

function ExploreRange(zoomLevel,location){
	this.zoomLevel=zoomLevel;
	this.location=location;
	this.cachedRoutineResults=[];
}

function MainLine(id) {
	this.id = id;
}

function SubLine(id) {
	this.id = id;
}
