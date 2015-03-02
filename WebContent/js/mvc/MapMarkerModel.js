function MapMarkerModel() {
	var marks = new Array();
	var currentOverviewMarkers = new Array();
	var allOverviewMarkers = new Array();
	
	var self=this;

	var backendManager = new BackendManager();
	
	this.fetchUserIdByRoutineId=function(routineId,successCallBack){
		backendManager.fetchUserByRoutineId(routineId, function(user){
			if(user!=null){
				successCallBack(user.id);
			}else{
				successCallBack(null);
			}	
		});
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
	
	this.copyRoutine2CurrentUser=function(ovMarkerId,successCallback){
		var routineId=self.getMapMarkerById(ovMarkerId).routineId;
		backendManager.fetchRoutineJSONStringById(routineId, function(routineJSONString,
				title,ovJSONString){
			backendManager.saveAsNewRoutine(title, routineJSONString, ovJSONString, function(){
				successCallback();
			});
		});
	};
	
	this.isOvMarker=function(id){
		for(var i in allOverviewMarkers){
			if(allOverviewMarkers[i].id==id){
				return true;
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

	this.getAllOverviewMarkers = function() {
		return allOverviewMarkers;
	}

	this.genUUID = function() {
		return uuid.v4();
	};

	this.deleteRoutineByOverviewId = function(overviewMarkerId, successCallback) {
		backendManager.deleteRoutineByOverviewMarkerId(overviewMarkerId,
				function() {
					successCallback();
				});
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

	this.resetModels = function() {
		marks = new Array();
		currentOverviewMarkers = new Array();
		allOverviewMarkers = new Array();
	};

	this.getModelMarkers = function() {
		return marks;
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

	this.createOneMarker = function(id, content) {
		var marker = new MapMarker(id);
		$.publish('createOneMarker', [ marker ]);

		if (content != null) {
			marker.content.updateContent(content);
			marker.updateOffset(content.offsetX, content.offsetY);
		}
		marks.push(marker);
		return marker;
	};

	this.createOverviewMarker = function(id, content,routineId) {
		var marker = new MapMarker(id);
		marker.routineId=routineId;
		$.publish('createOverViewMarker', [ marker,content ]);

		if (content != null) {
			marker.content.updateContent(content);
			marker.updateOffset(content.offsetX, content.offsetY);
		}
		allOverviewMarkers.push(marker);
		return marker;
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

			for ( var i in marks) {
				if (marks[i].id == id) {
					marks.splice(i, 1);
				}
			}

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

	this.isUserOwnRoutine = function(routineId, successCallback) {
		backendManager.getCurrentUser(function(currentUser){
			backendManager.isUserOwnRoutines(currentUser, routineId,
					successCallback);
		});
	};

	this.loadAllOverviewRoutine = function(userId,successCallback) {
		allOverviewMarkers = new Array();

		backendManager.getCurrentUser(function(currentUser){
			if(userId==null){
				fetchOverviewRoutinesByUser(currentUser,function(){
					successCallback(true);
				});
			}else{
				backendManager.fetchUserByUserId(userId, function(user){
					if(user!=null){
						fetchOverviewRoutinesByUser(user,function(){
							if(user.id==currentUser.id){
								//current user own these routines
								successCallback(true);
							}else{
								successCallback(false);
							}
						});
					}else{
						fetchOverviewRoutinesByUser(currentUser,function(){
							successCallback(true);
						});
					}
				});
			};
		});
	};
	
	function fetchOverviewRoutinesByUser(user,successCallback){
		backendManager.fetchOverviewRoutinesByUser(user, function(
				overviewJSONStringArray) {
			for ( var i in overviewJSONStringArray) {
				var overviewJSONString = overviewJSONStringArray[i].overviewJSONString;
				var routineId=overviewJSONStringArray[i].routineId;
				var overviewMarkerArray = JSON.parse(overviewJSONString);
				for ( var i in overviewMarkerArray) {
					self.createOverviewMarker(overviewMarkerArray[i].id,
							overviewMarkerArray[i],routineId);
				}
			}
			successCallback();
		});
	}

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

	this.save2Backend = function(routineName, callback) {
		console.log('prepare to save routine ' + routineName);
		backendManager.getCurrentUser(function(currentUser){
			if (currentUser == null) {
				alert('no find user abort saving routine');
				return;
			}

			//save all overview markers
			var overviewMap={};
			for(var i in allOverviewMarkers){
				var ovMarker=allOverviewMarkers[i];
				if(ovMarker.routineId in overviewMap){
					overviewMap[ovMarker.routineId].push(ovMarker.toJSONObject());
				}else{
					overviewMap[ovMarker.routineId]=new Array();
					overviewMap[ovMarker.routineId].push(ovMarker.toJSONObject());
				}
			}
			
			for(var key in overviewMap){
				overviewMap[key]=JSON.stringify(overviewMap[key]);
			}
			
			backendManager.updateAllOverviews(overviewMap,function(){	
				saveCurrentRoutine(routineName,function(){
					callback();
				});
			});
		});
	};
	
	function saveCurrentRoutine(routineName,callback){
		//save Routine Markers
		// gen marksJSONArray
		var marksJSONArray = new Array();
		if(marks.length!=0){
			for ( var i in marks) {
				marksJSONArray.push(marks[i].toJSONObject());
			}

			// gen overViewMarksJSONArray
			var location = genCentreLocation();
			var overviewMarkersJSONArray = new Array();
			if (currentOverviewMarkers.length == 0) {
				var uuid = self.genUUID();
				var centreOverViewMarker = new MapMarker(uuid);
				centreOverViewMarker.content.setIsAvergeOverViewMarker(true);
				
				centreOverViewMarker.content.updateContent(location);
				overviewMarkersJSONArray.push(centreOverViewMarker.toJSONObject());
			} else {
				// find average Marker and update its lat lng
				for ( var i in currentOverviewMarkers) {
					var overviewMarker = currentOverviewMarkers[i];
					if (overviewMarker.content.isAvergeOverViewMarker()) {
						overviewMarker.content.updateContent(location);
					}
					overviewMarkersJSONArray.push(overviewMarker.toJSONObject());
				}
			}
			
			backendManager.saveRoutine(routineName, JSON.stringify(marksJSONArray),
					JSON.stringify(overviewMarkersJSONArray), location,function() {
						callback();
					});
		}else{
			callback();
		}
	}

	function genCentreLocation() {
		var numWithNoSubMarkers = 0;
		var allLat = 0.000000;
		var allLng = 0.000000;
		for ( var i = 0; i < marks.length; i++) {
			if (!marks[i].isSubMarker()) {
				allLat = allLat + marks[i].getContent().getLat();
				allLng = allLng + marks[i].getContent().getLng();
				numWithNoSubMarkers++;
			}
		}
		var averageLat = allLat / numWithNoSubMarkers;
		var averageLng = allLng / numWithNoSubMarkers;
		return {
			lat : averageLat,
			lng : averageLng
		};
	}

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

	var routine = null;
	var currentUser = null;
	var userRoutines = null;

	AV.initialize("6pzfpf5wkg4m52owuwixt5vggrpjincr8xon3pd966fhgj3c",
			"4wrzupru1m4m7gpafo4llinv7iepyapnycvxygup7uiui77x");

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

	this.fetchOverviewRoutinesByUser = function(user, successCallback) {
		var query = new AV.Query(Routine);
		query.equalTo("user", user);
		query.select('title', 'overViewJSONString');
		query
				.find({
					success : function(routines) {
						console
								.log("backendManager:fetchOverviewRoutinesByUser success");
						userRoutines = routines;
						var overviewMarkersJSONStringArray = [];
						for ( var i in routines) {
							overviewMarkersJSONStringArray.push(
										{
											routineId:routines[i].id,
											overviewJSONString:routines[i].get('overViewJSONString')
										}
									);
						}
						successCallback(overviewMarkersJSONStringArray);
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

	var title = "Unknown Location";
	var address = "Unknown Address";
	var lat = 0;
	var lng = 0;
	var mycomment = "...";
	var category = "marker";
	var imgUrls = new Array();
	var isImgPositionDecided = true;
	var slideNum = 1;

	var isAvergeOverViewMarker = false;

	var defaultImgIcon = "resource/icons/pic/pic_default.png";
	var picNoPositionIconUrl = "resource/icons/pic/pic_no_position.png";
	var iconUrl = "resource/icons/default/default_default.png";

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

	this.setCategory = function(nameFoo) {
		category = nameFoo;
	};

	this.getLat = function() {
		return lat;
	};

	this.setlatlng = function(latFoo, lngFoo) {
		lat = latFoo;
		lng = lngFoo;
		$.publish('latlngChanged', [ this ]);
		$.publish('updateUI', []);
	};

	this.getLng = function() {
		return lng;
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

	this.isSubMarker = function() {
		if (this.parentSubMarker != null) {
			return true;
		} else {
			return false;
		}
	};

	this.updateOffset = function(x, y) {
		console.log("id " + this.id + " modelMarker.updateOffset: " + x + " "
				+ y);
		this.offsetX = x;
		this.offsetY = y;
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

		var object = {
			id : this.id,
			lat : this.getContent().getLat(),
			lng : this.getContent().getLng(),
			title : this.getContent().getTitle(),
			address : this.getContent().getAddress(),
			mycomment : this.getContent().getMycomment(false),
			category : this.getContent().getCategory(),
			imgUrls : this.getContent().getImgUrls(),
			iconUrl : this.getContent().getIconUrl(),
			slideNum : this.getContent().getSlideNum(),
			nextMainMarkerId : this.connectedMainMarker == null ? null
					: this.connectedMainMarker.id,
			subMarkerIds : subMarkerIdsArray,
			mainPaths : this.mainPaths,
			offsetX : this.offsetX,
			offsetY : this.offsetY,
			isAverage : this.getContent().isAvergeOverViewMarker()
		};

		return object;
	};

	// getters and setters
	this.getContent = function() {
		return this.content;
	};

}

function MainLine(id) {
	this.id = id;
}

function SubLine(id) {
	this.id = id;
}
