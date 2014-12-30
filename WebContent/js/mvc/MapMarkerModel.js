function MapMarkerModel() {
	var marks = new Array();

	var backendManager = new BackendManager();

	this.saveImage = function(imageFile, successCallback, failCallback) {
		backendManager.saveFile(imageFile, function(url) {
			successCallback(url);
		}, function(error) {
			failCallback(error);
		});
	};

	this.resetModels = function() {
		marks = new Array();
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
		var currentUser = backendManager.getCurrentUser();

		backendManager.isUserOwnRoutines(currentUser, routineId,
				successCallback);
	};

	this.loadRoutine = function(routineId, successCallback) {
		marks = new Array();

		var self = this;

		backendManager.fetchRoutineJSONStringById(routineId, function(
				marksJSONString, title) {
			var maxId = 0;
			if (marksJSONString != null) {
				var marksJSONArray = JSON.parse(marksJSONString);
				for ( var i in marksJSONArray) {
					if (marksJSONArray[i].id > maxId) {
						maxId = marksJSONArray[i].id;
					}
					self.createOneMarker(marksJSONArray[i].id,
							marksJSONArray[i]);
				}

				for ( var i in marksJSONArray) {
					var eachJSONObject = marksJSONArray[i];
					/*
					 * if (eachJSONObject.nextMainMarkerId != null) {
					 * self.addMainLine(eachJSONObject.id,
					 * eachJSONObject.nextMainMarkerId); }
					 */

					for ( var j in eachJSONObject.subMarkerIds) {
						self.addSubLine(eachJSONObject.id,
								eachJSONObject.subMarkerIds[j], 0, 0);
					}
				}

			}
			console.log('model.loadRoutine:fetch routine success');
			successCallback({
				routineName : title,
				maxId : maxId
			});
		});

	};

	this.save2Backend = function(routineName) {
		console.log('prepare to save routine ' + routineName);
		if (marks.length == 0) {
			alert('no routine found. abort saving');
			return;
		}

		var currentUser = backendManager.getCurrentUser();

		if (currentUser != null) {
			var marksJSONArray = new Array();
			for ( var i in marks) {
				marksJSONArray.push(marks[i].toJSONObject());
			}
			;

			backendManager.saveRoutine(routineName, JSON
					.stringify(marksJSONArray));
		} else {
			alert('no find user abort saving routine');
			return;
		}

	};

	function getOverlayById(id) {
		var length = marks.length;
		for ( var i = 0; i < length; i++) {
			if (marks[i].id == id) {
				return marks[i];
			}
		}
		alert('can not find model marker :' + id);
		return null;
	}

	this.getMapMarkerById = function(id) {
		return getOverlayById(id);
	};

	this.getMarkerContentById = function(id) {
		var marker = getOverlayById(id);
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

	this.getCurrentUser = function() {
		currentUser = AV.User.current();
		if (currentUser) {
			console.log("welcomse session user:" + currentUser.get('username'));

			return currentUser;

		} else {
			AV.User.logIn("guest", "guest", {
				success : function(user) {
					console.log("login for user:" + user.get('username'));
					currentUser = user;
					return currentUser;
				},
				error : function(user, error) {
					alert("Error: " + error.code + " " + error.message);
					alert("log failed. abort save routines");
					return null;
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
						.get('title'));
			},
			error : function(object, error) {
				alert("The object was not retrieved successfully.");
				console.log(error);
			}
		});
	};

	this.saveRoutine = function(routineName, routineJSONString) {
		if (routine == null) {
			routine = new Routine();
		}
		routine.set('title', routineName);
		routine.set('RoutineJSONString', routineJSONString);
		routine.set('user', this.getCurrentUser());
		routine.save(null, {
			success : function(routineFoo) {
				routine = routineFoo;
				alert('save routine successful:' + routineName);
			},
			error : function(object, error) {
				alert('save routine failed');
				routine = null;
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
	this.id=id;
	
	var title = "Unknown Location";
	var address = "Unknown Address";
	var lat = 0;
	var lng = 0;
	var mycomment = "...";
	var category = "marker";
	var imgUrls = new Array();
	var isImgPositionDecided=true;
	var slideNum=1;
	
	var defaultImgIcon="resource/icons/pic/pic_default.png";
	var picNoPositionIconUrl="resource/icons/pic/pic_no_position.png";
	var iconUrl = "resource/icons/default/default_default.png";

	this.getSlideNum=function(){
		return slideNum;
	};
	this.setSlideNum=function(num){
		slideNum=num;
	};
	
	this.setImgPositionDecided=function(arg){
		isImgPositionDecided=arg;
		if(isImgPositionDecided){
			this.setIconUrl(defaultImgIcon);
		}else{
			this.setIconUrl(picNoPositionIconUrl);
		}
	};
	
	this.isImgPositionDecided=function(){
		return isImgPositionDecided;
	};
	
	
	this.updateContent = function(args) {
		if(args.slideNum!=null){
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

		/*
		if (args.mainPaths != null) {
			this.mainPaths = args.mainPaths;
		}
		*/

		$.publish('updateInfoWindow', [ this ]);

	};
	
	this.addImgUrl=function(url){
		imgUrls.push(url);
		$.publish('updateInfoWindow', [ this ]);
	};

	this.getIconUrl = function() {
		return iconUrl;
	};

	this.setIconUrl = function(arg) {
		iconUrl = arg;
		$.publish("iconUrlUpdated",[this]);
	};

	this.getImgUrls = function() {
		return imgUrls;
	};

	this.setImgUrls = function(urlArray) {
		imgUrls = urlArray;
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
		if (needShort) {
			return mycomment.substring(0, 150) + '...';
		} else {
			return mycomment;
		}
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
			slideNum: this.getContent().getSlideNum(),
			nextMainMarkerId : this.connectedMainMarker == null ? null
					: this.connectedMainMarker.id,
			subMarkerIds : subMarkerIdsArray,
			mainPaths : this.mainPaths,
			offsetX : this.offsetX,
			offsetY : this.offsetY
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
