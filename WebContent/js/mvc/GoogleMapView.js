function GoogleMapView(oneController) {
	var controller = oneController;
	this.markerNeedMainLine = null;
	this.markerNeedSubLine = null;
	this.markerNeedMergeImgUrl = null;

	this.infocard = null;
	this.uploadImgForm = null;
	this.popupForm = null;
	this.currentMarkerId = -1;

	var self = this;

	var directionsDisplay = new google.maps.DirectionsRenderer();
	var directionsService = new google.maps.DirectionsService();
	var map;
	var googleOverlay;
	// var canvasProjectionOverlay = new CanvasProjectionOverlay();
	var markerCluster;

	var overlays = new Array();
	var searchMarkers = [];

	function getOverlayById(id) {
		var length = overlays.length;
		for ( var i = 0; i < length; i++) {
			if (overlays[i].id == id) {
				return overlays[i];
			}
		}
		return null;
	}

	this.hideEditMenuInContextMenu = function() {
		document.getElementById('addMarkerItem').style.display = 'none';
		document.getElementById('saveRoutineItem').style.display = 'none';
	};

	this.setMarkerAnimation = function(id, animationType) {
		googleMarker = self.getViewOverlaysById(id);
		if (googleMarker instanceof google.maps.Marker) {
			if (animationType == "BOUNCE") {
				googleMarker.setAnimation(google.maps.Animation.BOUNCE);
			} else if (animationType == "DROP") {
				googleMarker.setAnimation(google.maps.Animation.DROP);
			} else {
				googleMarker.setAnimation(null);
			}
		}
	};

	this.getViewOverlaysById = function(id) {
		return getOverlayById(id);
	};

	this.setMarkerZIndex = function(id, znumber) {
		var viewMarker = self.getViewOverlaysById(id);
		viewMarker.setZIndex(znumber);
	};

	function addMainLineContextMenu(line, idfrom) {
		// create the ContextMenuOptions object
		var contextMenuOptions = {};
		contextMenuOptions.classNames = {
			menu : 'context_menu',
			menuSeparator : 'context_menu_separator'
		};

		// create an array of ContextMenuItem objects
		var menuItems = [];
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'edit',
			id : 'lineEdieItem',
			label : 'edit line'
		}, {}, {
			className : 'context_menu_item',
			eventName : 'car',
			label : 'go with car'
		}, {
			className : 'context_menu_item',
			eventName : 'bike',
			label : 'go with bike'
		}, {
			className : 'context_menu_item',
			eventName : 'walk',
			label : 'go with walk'
		}, {
			className : 'context_menu_item',
			eventName : 'line',
			label : 'direct line'
		}

		);

		contextMenuOptions.menuItems = menuItems;

		// create the ContextMenu object
		var contextMenu = new ContextMenu(map, contextMenuOptions);

		// display the ContextMenu on a Map right click
		google.maps.event.addListener(line, 'rightclick', function(mouseEvent) {
			contextMenu.show(mouseEvent.latLng);
		});

		// listen for the ContextMenu 'menu_item_selected' event
		google.maps.event.addListener(contextMenu, 'menu_item_selected',
				function(latLng, eventName) {
					// latLng is the position of the ContextMenu
					// eventName is the eventName defined for the clicked
					// ContextMenuItem in the ContextMenuOptions
					var googlePathArray = line.getPath().getArray();
					var googleFrom = googlePathArray[0];
					var googleTo = googlePathArray[googlePathArray.length - 1];

					switch (eventName) {
					case 'edit':
						line.setEditable(true);
						break;
					case 'line':
						line.setPath([ googleFrom, googleTo ]);
						controller.lineEditEnd(line.getMainLinePath(), idfrom);
						break;
					case 'car':
						calcRoute(googleFrom, googleTo,
								google.maps.TravelMode.DRIVING, function(
										latlngArray, durationtext) {
									line.setPath(latlngArray);
									controller.lineEditEnd(line
											.getMainLinePath(), idfrom);
								});
						break;
					case 'bike':
						calcRoute(googleFrom, googleTo,
								google.maps.TravelMode.BICYCLING, function(
										latlngArray, durationtext) {
									line.setPath(latlngArray);
									controller.lineEditEnd(line
											.getMainLinePath(), idfrom);
								});
						break;
					case 'walk':
						calcRoute(googleFrom, googleTo,
								google.maps.TravelMode.WALKING, function(
										latlngArray, durationtext) {
									line.setPath(latlngArray);
									controller.lineEditEnd(line
											.getMainLinePath(), idfrom);
								});
						break;
					}
					;

				});
	}

	function addSearchMarkerContextMenu(googleMarker) {
		// create the ContextMenuOptions object
		var contextMenuOptions = {};
		contextMenuOptions.classNames = {
			menu : 'context_menu',
			menuSeparator : 'context_menu_separator'
		};

		// create an array of ContextMenuItem objects
		var menuItems = [];
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'select',
			label : 'Yes this is I want'
		});

		menuItems.push({
			className : 'context_menu_item',
			eventName : 'clearSearch',
			label : 'clear search results'
		});

		contextMenuOptions.menuItems = menuItems;

		// create the ContextMenu object
		var contextMenu = new ContextMenu(map, contextMenuOptions);

		// display the ContextMenu on a Map right click
		google.maps.event.addListener(googleMarker, 'rightclick', function(
				mouseEvent) {
			contextMenu.show(mouseEvent.latLng);
		});

		// listen for the ContextMenu 'menu_item_selected' event
		google.maps.event.addListener(contextMenu, 'menu_item_selected',
				function(latLng, eventName) {
					// latLng is the position of the ContextMenu
					// eventName is the eventName defined for the clicked
					// ContextMenuItem in the ContextMenuOptions
					switch (eventName) {
					case 'select':
						controller.addMarkerClickEvent({
							lat : latLng.lat(),
							lng : latLng.lng()
						}, {
							lat : latLng.lat(),
							lng : latLng.lng(),
							title : googleMarker.getTitle()
						});
						cleanSearchMarkers();
						break;
					case 'clearSearch':
						cleanSearchMarkers();
						break;
					}

				});
	}

	function addMarkerContextMenu(googleMarker) {
		// create the ContextMenuOptions object
		var id = googleMarker.id;
		var contextMenuOptions = {};
		contextMenuOptions.classNames = {
			menu : 'context_menu',
			menuSeparator : 'context_menu_separator'
		};

		// create an array of ContextMenuItem objects
		var menuItems = [];
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'showInfo',
			id : 'showInfoItem' + id,
			label : 'showInfo'
		});
		/*
		 * don't need mainline in current version menuItems.push({ className :
		 * 'context_menu_item', eventName : 'addMainline', id:
		 * 'addMainlineItem'+id, label : 'addMainline' });
		 */
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'addSubline',
			id : 'addSublineItem' + id,
			label : 'addSubline'
		});

		menuItems.push({
			className : 'context_menu_item',
			eventName : 'deleteself',
			id : 'deleteselfItem' + id,
			label : 'delete this marker'
		});

		menuItems.push({
			className : 'context_menu_item',
			eventName : 'mergeImgUrl',
			id : 'mergeImgUrlItem' + id,
			label : 'Merge ImgUrl To...'
		});

		contextMenuOptions.menuItems = menuItems;

		// create the ContextMenu object
		var contextMenu = new ContextMenu(map, contextMenuOptions);

		// display the ContextMenu on a Map right click
		google.maps.event.addListener(googleMarker, 'rightclick', function(
				mouseEvent) {
			contextMenu.show(mouseEvent.latLng);
		});

		// listen for the ContextMenu 'menu_item_selected' event
		google.maps.event.addListener(contextMenu, 'menu_item_selected',
				function(latLng, eventName) {
					// latLng is the position of the ContextMenu
					// eventName is the eventName defined for the clicked
					// ContextMenuItem in the ContextMenuOptions
					switch (eventName) {
					case 'showInfo':
						console.log('=========show Info========');
						var point = self.fromLatLngToPixel(googleMarker
								.getLatLng());
						console.log(point);
						console.log(googleMarker.getPosition());
						console.log(self.fromPixelToLatLng(point));
						break;
					case 'addMainline':
						controller.addMainLineClickHandler(googleMarker);
						break;
					case 'addSubline':
						controller.addSubLineClickHandler(googleMarker);
						break;
					case 'deleteself':
						controller.markerDeleteClickHandler(googleMarker);
						break;
					case 'mergeImgUrl':
						controller.mergeImgUrlClickHandler(googleMarker);
						break;
					}
				});
	}
	;

	this.initSlideMode = function() {
		// map context menu
		document.getElementById('addMarkerItem').style.display = 'none';
		document.getElementById('saveRoutineItem').style.display = 'none';
		document.getElementById('loadRoutineItem').style.display = 'none';
		document.getElementById('uploadItem').style.display = 'none';
		document.getElementById('showAllItem').style.display = 'none';

		// marker context menu
		for ( var i in overlays) {
			if (overlays[i] instanceof google.maps.Marker) {
				var id = overlays[i].id;
				overlays[i].setDraggable(false);
				if (id != null) {
					document.getElementById('showInfoItem' + id).style.display = 'none';
					// document.getElementById('addMainlineItem'+id).style.display='none';
					document.getElementById('addSublineItem' + id).style.display = 'none';
					document.getElementById('deleteselfItem' + id).style.display = 'none';
					document.getElementById('mergeImgUrlItem' + id).style.display = 'none';
				}
			}
		}

	};

	this.exitSlideMode = function() {
		// map context menu
		document.getElementById('addMarkerItem').style.display = '';
		document.getElementById('saveRoutineItem').style.display = '';
		document.getElementById('loadRoutineItem').style.display = '';
		document.getElementById('uploadItem').style.display = '';
		document.getElementById('showAllItem').style.display = '';

		// marker context menu
		for ( var i in overlays) {
			if (overlays[i] instanceof google.maps.Marker) {
				overlays[i].setDraggable(true);

				var id = overlays[i].id;

				if (id != null) {
					document.getElementById('showInfoItem' + id).style.display = '';
					// document.getElementById('addMainlineItem'+id).style.display='';
					document.getElementById('addSublineItem' + id).style.display = '';
					document.getElementById('deleteselfItem' + id).style.display = '';
					document.getElementById('mergeImgUrlItem' + id).style.display = '';
				}

			}

		}
	};

	function addContextMenu() {
		// create the ContextMenuOptions object
		var contextMenuOptions = {};
		contextMenuOptions.classNames = {
			menu : 'context_menu',
			menuSeparator : 'context_menu_separator'
		};

		// create an array of ContextMenuItem objects
		var menuItems = [];
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'addMarker',
			id : 'addMarkerItem',
			label : 'add Mark'
		});
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'saveRoutine',
			id : 'saveRoutineItem',
			label : 'save Routine'
		});
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'loadRoutine',
			id : 'loadRoutineItem',
			label : 'load Routine'
		});
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'uploadImg',
			id : 'uploadItem',
			label : 'upload image'
		});
		// a menuItem with no properties will be rendered as a separator
		menuItems.push({});
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'showAll',
			id : 'showAllItem',
			label : 'show all routines'
		});
		menuItems.push({});
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'startSlide',
			id : 'startSlideItem',
			label : 'Start slide mode'
		});
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'prevSlide',
			id : 'prevSlideItem',
			label : 'Prev slide'
		});
		menuItems.push({
			className : 'context_menu_item',
			eventName : 'exitSlide',
			id : 'exitSlideItem',
			label : 'End slide mode'
		});

		contextMenuOptions.menuItems = menuItems;

		// create the ContextMenu object
		var contextMenu = new ContextMenu(map, contextMenuOptions);

		// display the ContextMenu on a Map right click
		google.maps.event.addListener(map, 'rightclick', function(mouseEvent) {
			contextMenu.show(mouseEvent.latLng);
		});

		google.maps.event.addListener(map, 'click', function(mouseEvent) {
			controller.mapClickEventHandler();
		});

		// zoom_changed
		google.maps.event.addListener(map, 'zoom_changed', function() {
			controller.zoomEventHandler();
		});

		// listen for the ContextMenu 'menu_item_selected' event
		google.maps.event.addListener(contextMenu, 'menu_item_selected',
				function(latLng, eventName) {
					// latLng is the position of the ContextMenu
					// eventName is the eventName defined for the clicked
					// ContextMenuItem in the ContextMenuOptions
					switch (eventName) {
					case 'addMarker':
						controller.addMarkerClickEvent({
							lat : latLng.lat(),
							lng : latLng.lng()
						}, {
							lat : latLng.lat(),
							lng : latLng.lng()
						});
						break;
					case 'saveRoutine':
						controller.saveRoutine();
						break;
					case 'loadRoutine':
						controller.loadRoutines();
						break;
					case 'uploadImg':
						// do somthing upload image
						self.uploadImgForm.show();
						break;
					case 'showAll':
						controller.showAllRoutineClickHandler();
						break;
					case 'startSlide':
						controller.startSlideMode();
						break;
					case 'exitSlide':
						controller.exitSlideMode();
						break;
					case 'prevSlide':
						controller.prevSlide();
						break;
					}
				});
	}
	;

	function cleanSearchMarkers() {
		for ( var i = 0, marker; marker = searchMarkers[i]; i++) {
			marker.setMap(null);
		}

		// For each place, get the icon, place name, and location.
		searchMarkers = [];
	}
	;

	function linkSearchBox() {
		// Create the search box and link it to the UI element.
		var input = /** @type {HTMLInputElement} */
		(document.getElementById('searchKey'));
		map.controls[google.maps.ControlPosition.TOP_LEFT].push(input);

		var searchButton = document.getElementById('searchButton');
		map.controls[google.maps.ControlPosition.TOP_LEFT].push(searchButton);

		var searchBox = new google.maps.places.SearchBox(
		/** @type {HTMLInputElement} */
		(input));

		// [START region_getplaces]
		// Listen for the event fired when the user selects an item from the
		// pick list. Retrieve the matching places for that item.
		google.maps.event
				.addListener(
						searchBox,
						'places_changed',
						function() {
							var places = searchBox.getPlaces();

							cleanSearchMarkers();

							var bounds = new google.maps.LatLngBounds();
							for ( var i = 0, place; place = places[i]; i++) {
								var image = {
									url : place.icon,
								};

								// Create a marker for each place.
								var marker = new google.maps.Marker(
										{
											map : map,
											title : place.name,
											position : place.geometry.location,
											icon : 'http://www.google.com/intl/en_us/mapfiles/ms/micons/blue-dot.png'
										});

								searchMarkers.push(marker);

								addSearchMarkerContextMenu(marker);

								bounds.extend(place.geometry.location);
							}

							map.fitBounds(bounds);
						});
		// [END region_getplaces]

		// Bias the SearchBox results towards places that are within the bounds
		// of the
		// current map's viewport.
		google.maps.event.addListener(map, 'bounds_changed', function() {
			var bounds = map.getBounds();
			searchBox.setBounds(bounds);
		});
	}
	;

	this.getCenter = function() {
		return {
			lat : map.getCenter().lat(),
			lng : map.getCenter().lng()
		};
	};

	this.fitRoutineBounds = function() {
		var bounds = new google.maps.LatLngBounds();
		for ( var i = 0; i < overlays.length; i++) {
			if (overlays[i] instanceof google.maps.Marker) {
				bounds.extend(overlays[i].getPosition());
			}
		}
		map.fitBounds(bounds);
	};

	this.panByIds = function(ids) {
		var bounds = new google.maps.LatLngBounds();
		for ( var i in ids) {
			var viewMarker = self.getViewOverlaysById(ids[i]);
			if (viewMarker instanceof google.maps.Marker) {
				bounds.extend(viewMarker.getPosition());
			}
		}
		map.panTo(bounds.getCenter());
	};

	this.fitTwoPositionBounds = function(p1, p2) {
		var bounds = new google.maps.LatLngBounds();
		bounds.extend(new google.maps.LatLng(p1.lat, p1.lng));
		bounds.extend(new google.maps.LatLng(p2.lat, p2.lng));
		map.fitBounds(bounds);
		// map.setZoom(map.getZoom() - 1);
	};

	this.createView = function() {
		this.infocard = new infoCard("infoCard");

		this.infocard.initDefault('80px', '100px', {
			title : "unknownTitle"
		}, null);

		this.infocard.addEditFormOKButtonEvent(function() {
			var uContent = self.infocard.editFormClickOK();
			console.log('infocard edit form ok, content:' + uContent.iconUrl);
			controller.updateMarkerContentById(self.currentMarkerId, uContent);
		});

		this.infocard.hide();

		var mapOptions = {
			center : new google.maps.LatLng(37.3841308, -121.9801145),
			zoom : 15,
			mapTypeId : google.maps.MapTypeId.ROADMAP
		};

		map = new google.maps.Map(document.getElementById("l-map"), mapOptions);
		googleOverlay = new google.maps.OverlayView();
		googleOverlay.draw = function() {
		};
		googleOverlay.setMap(map);

		// canvasProjectionOverlay.setMap(map);
		addContextMenu();

		// init marker cluster
		markerCluster = new MarkerClusterer(map, null);
		markerCluster.setGridSize(30);

		linkSearchBox();

		// init image uploader
		this.uploadImgForm = new UploadFormView("uploadImageForm", "file",
				"progress", "loading");
		this.uploadImgForm.addChangeCallBack(function(file, lat, lon) {
			controller.uploadImgs(file, lat, lon);
		});

		this.popupForm = new PopupForm("CommentPopupForm");
		this.infocard.setPopupCommentForm(this.popupForm);
	};

	this.fromPixelToLatLng = function(point) {
		var googlePoint = new google.maps.Point(point.x, point.y);
		var googleLatLng = googleOverlay.getProjection()
				.fromContainerPixelToLatLng(googlePoint);
		return {
			lat : googleLatLng.lat(),
			lng : googleLatLng.lng()
		};
	};

	this.fromLatLngToPixel = function(position) {
		var googlePosition = new google.maps.LatLng(position.lat, position.lng);
		var googlePoint = googleOverlay.getProjection()
				.fromLatLngToContainerPixel(googlePosition);
		return {
			x : googlePoint.x,
			y : googlePoint.y
		};
	};

	this.pixelDistance = function(position1, position2) {
		var p1 = this.fromLatLngToPixel(new google.maps.LatLng(position1.lat,
				position1.lng));
		var p2 = this.fromLatLngToPixel(new google.maps.LatLng(position2.lat,
				position2.lng));
		return Math.pow(Math.pow(p1.x - p2.x, 2) + Math.pow(p1.y - p2.y, 2),
				0.5);
	};

	this.resetView = function() {
		for ( var i = 0; i < overlays.length; i++) {
			overlays[i].setMap(null);
		}
		overlays = [];
	};

	this.centerAndZoom = function(lat, lng) {
		map.panTo(new google.maps.LatLng(lat, lng));
	};

	function calcRoute(latlngsFrom, latlngsTo, googleTravelMode,
			successCallback) {
		var request = {
			origin : latlngsFrom,
			destination : latlngsTo,
			travelMode : googleTravelMode
		};
		directionsService.route(request, function(response, status) {
			if (status == google.maps.DirectionsStatus.OK) {
				// directionsDisplay.setMap(map);
				// directionsDisplay.setDirections(response);

				var dRoute = response.routes[0];

				var leg = dRoute.legs[0];

				successCallback(dRoute.overview_path, leg.duration.text);
			}
		});
	}

	this.addOneMark = function(lat, lng, num) {
		var myLatlng = new google.maps.LatLng(lat, lng);

		var viewMarker = new google.maps.Marker({
			position : myLatlng,
			map : map
		});

		// create one custom id in google mark
		viewMarker.id = num;

		viewMarker.isShow = true;

		viewMarker.setDraggable(true);

		addMarkerContextMenu(viewMarker);

		google.maps.event.addListener(viewMarker, 'click',
				function(mouseEvent) {
					controller.markerClickEventHandler(viewMarker);
				});

		google.maps.event.addListener(viewMarker, 'dragend', function(
				mouseEvent) {
			controller.markerDragendEventHandler(viewMarker.id, viewMarker
					.getPosition().lat(), viewMarker.getPosition().lng());
		});

		viewMarker.hide = function() {
			viewMarker.setVisible(false);
			viewMarker.isShow = false;
		};

		viewMarker.show = function() {
			viewMarker.setVisible(true);
			viewMarker.isShow = true;
		};

		viewMarker.getLatLng = function() {
			return {
				lat : viewMarker.getPosition().lat(),
				lng : viewMarker.getPosition().lng()
			};
		};

		overlays.push(viewMarker);
		
	};

	this.showAllMarkers = function() {
		var length = overlays.length;
		for ( var i = 0; i < length; i++) {
			if (overlays[i] instanceof google.maps.Marker) {
				overlays[i].isShow = true;
				overlays[i].show();
			}
		}
	};

	this.drawMainLine = function(idfrom, idto, num, pathArray) {
		var from = this.getViewOverlaysById(idfrom);
		var to = this.getViewOverlaysById(idto);

		var lineSymbol = {
			path : google.maps.SymbolPath.FORWARD_CLOSED_ARROW
		};

		// Create the polyline and add the symbol via the 'icons' property.

		var lineCoordinates = [ new google.maps.LatLng(
				from.getPosition().lat(), from.getPosition().lng()) ];

		if (pathArray != null) {
			for ( var i = 1; i < pathArray.length - 1; i++) {
				lineCoordinates.push(new google.maps.LatLng(pathArray[i].lat,
						pathArray[i].lng));
			}
		}

		lineCoordinates.push(new google.maps.LatLng(to.getPosition().lat(), to
				.getPosition().lng()));

		var line = new google.maps.Polyline({
			path : lineCoordinates,
			icons : [ {
				icon : lineSymbol,
				offset : '100%'
			} ],
			map : map,
			strokeColor : 'blue',
			strokeWeight : 6,
			strokeOpacity : 0.5,
			geodesic : true
		});

		// line.setEditable(true);

		line.id = num;

		line.isShowRoute = false;

		line.getMainLinePath = function() {
			var pathArray = line.getPath().getArray();
			var returnArray = new Array();

			for ( var i = 0; i < pathArray.length; i++) {
				returnArray.push({
					lat : pathArray[i].lat(),
					lng : pathArray[i].lng()
				});
			}
			return returnArray;
		};

		addMainLineContextMenu(line, idfrom);

		google.maps.event.addListener(line, 'click', function(mouseEvent) {
			console.log(line.getPath().getLength());

			var p1 = line.getMainLinePath()[0];
			var p2 = line.getMainLinePath()[line.getMainLinePath().length - 1];

			self.fitTwoPositionBounds(p1, p2);

			if (line.getEditable() == true) {
				line.setEditable(false);
				controller.lineEditEnd(line.getMainLinePath(), idfrom);
			}

			/*
			 * if (line.isShowRoute == false) { var o =
			 * line.getPath().getArray(); var latlngFrom = o[0]; var latlngTo =
			 * o[1]; calcRoute(latlngFrom,
			 * latlngTo,function(latlngArray,durationText){ new
			 * google.maps.Polyline({ path : latlngArray, map : map, strokeColor :
			 * 'black', strokeWeight : 6, strokeOpacity:0.5, geodesic : true });
			 * alert(durationText); }); } else { directionsDisplay.setMap(null); }
			 */

			line.isShowRoute = !line.isShowRoute;
		});

		overlays.push(line);

		return line;
	};

	this.drawSubLine = function(idfrom, idto, num) {
		if (this.getViewOverlaysById(idto).isShow == true) {
			var from = this.getViewOverlaysById(idfrom);
			var to = this.getViewOverlaysById(idto);

			var lineSymbol = {
				path : 'M 0,-1 0,1',
				strokeOpacity : 0.8,
				scale : 4
			};

			var lineCoordinates = [
					new google.maps.LatLng(from.getPosition().lat(), from
							.getPosition().lng()),
					new google.maps.LatLng(to.getPosition().lat(), to
							.getPosition().lng()) ];

			// Create the polyline, passing the symbol in the 'icons' property.
			// Give the line an opacity of 0.
			// Repeat the symbol at intervals of 20 pixels to create the dashed
			// effect.
			var line = new google.maps.Polyline({
				path : lineCoordinates,
				strokeOpacity : 0,
				icons : [ {
					icon : lineSymbol,
					offset : '0',
					repeat : '20px'
				} ],
				map : map,
				strokeColor : 'Green',
				strokeWeight : 1
			});

			line.id = num;
			overlays.push(line);
		}
	};

	this.removeAllLines = function() {
		for ( var i = 0; i < overlays.length; i++) {
			if (overlays[i] instanceof google.maps.Polyline) {
				overlays[i].setMap(null);
				overlays.splice(i, 1);
				i--;
			}
		}
	};

	this.removeById = function(id) {
		for ( var i = 0; i < overlays.length; i++) {
			if (overlays[i].id == id) {
				overlays[i].setMap(null);
				overlays.splice(i, 1);
				i--;
			}
		}
	};

	this.changeMarkerIcon = function(markerId, iconUrl) {
		var viewMarker = this.getViewOverlaysById(markerId);
		viewMarker.setIcon(iconUrl);
	};

	this.setMarkerDragable = function(markerId, needDragable) {
		var viewMarker = this.getViewOverlaysById(markerId);
		viewMarker.setDraggable(needDragable);
	};

	this.addInfoWindow = function(marker, content, num) {
		/*
		 * var infocard = new infoCard('card' + num);
		 * infocard.initDefault('0px', '0px', content, null);
		 * 
		 * infocard.addEditFormOKButtonEvent(function() { var uContent =
		 * infocard.editFormClickOK();
		 * controller.updateMarkerContentById(marker.id, uContent); });
		 */
		var infowindow = new google.maps.InfoWindow({
			content : content.title
		});

		infowindow.show = function() {
			console.log('infowwindow show');
			infowindow.open(map, marker);
		};

		infowindow.hide = function() {
			infowindow.close();
		};

		// infowindow.show();
		return infowindow;
	};

	this.searchLocation = function(key) {
		gaodeSearch(key);
	};

	this.clearMarkerCluster = function() {
		markerCluster.clearMarkers();
		for ( var i in overlays) {
			if (overlays[i] instanceof google.maps.Marker) {
				overlays[i].setMap(map);
			}
		}
	};

	this.AddMarkers2Cluster = function(ids) {
		var markersNeedToCluster = new Array();
		for ( var i in ids) {
			var viewMarker = self.getViewOverlaysById(ids[i]);
			markersNeedToCluster.push(viewMarker);
		}
		markerCluster.addMarkers(markersNeedToCluster);
	};

	function gaodeSearch(key) {
		var MSearch;
		AMap.service([ "AMap.PlaceSearch" ], function() {
			MSearch = new AMap.PlaceSearch({
				pageSize : 5,
				pageIndex : 1,
			});

			MSearch.search(key, function(status, result) {
				if (status === 'complete' && result.info === 'OK') {
					console.log('search key is ' + key);
					var poiArr = result.poiList.pois;

					cleanSearchMarkers();

					var bounds = new google.maps.LatLngBounds();
					for ( var i = 0, place; place = poiArr[i]; i++) {
						// Create a marker for each place.
						var location = new google.maps.LatLng(place.location
								.getLat(), place.location.getLng());

						var marker = new google.maps.Marker({
							map : map,
							title : place.name,
							position : location,
							icon : 'resource/icons/default/search_default.png'
						});

						searchMarkers.push(marker);

						addSearchMarkerContextMenu(marker);

						bounds.extend(location);
					}

					map.fitBounds(bounds);
				}
			});
		});
	}
	;
};

function CanvasProjectionOverlay() {
}
CanvasProjectionOverlay.prototype = new google.maps.OverlayView();
CanvasProjectionOverlay.prototype.constructor = CanvasProjectionOverlay;
CanvasProjectionOverlay.prototype.onAdd = function() {
};
CanvasProjectionOverlay.prototype.draw = function() {
};
CanvasProjectionOverlay.prototype.onRemove = function() {
};