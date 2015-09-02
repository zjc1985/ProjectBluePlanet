function GoogleMapView(oneController) {
	var controller = oneController;
	this.markerNeedMainLine = null;
	this.markerNeedSubLine = null;
	this.markerNeedMergeImgUrl = null;

	this.markerInfoDialog=null;
	this.ovMarkerDialog=null;
	this.markerEditDialog=null;
	this.navBar=null;
	this.uploadImgModal=null;
	this.searchPickRoutineBoard=null;
	this.createRoutineModal=null;
	this.markerPickRoutineModal=null;
	
	this.currentMarkerId = -1;

	var self = this;
	var infoWindow=null;

	//google map components
	//var directionsDisplay = new google.maps.DirectionsRenderer();
	//var directionsService = new google.maps.DirectionsService();
	// var canvasProjectionOverlay = new CanvasProjectionOverlay();
	var map;
	var googleOverlay;
	
	var markerCluster;

	var overlays = new Array();
	
	var ovLines=new Array();
	
	var searchMarkers = [];
	var currentGoogleSearchMarker=null;

	function getOverlayById(id) {
		var length = overlays.length;
		for ( var i = 0; i < length; i++) {
			if (overlays[i].id == id) {
				return overlays[i];
			}
		}
		return null;
	}
	
	function cleanSearchMarkers() {
		for ( var i = 0, marker; marker = searchMarkers[i]; i++) {
			marker.setMap(null);
		}

		searchMarkers = [];
	};
	
	this.getMap=function(){
		return map;
	};
	
	this.getInfoWindow=function(){
		if(infoWindow==null){
			infoWindow= new google.maps.InfoWindow({
			    content: ""
			});
		}
		return infoWindow;
	}
	
	this.openInfoWindow=function(id,contentString){
		this.getInfoWindow().setContent(contentString);
		this.getInfoWindow().open(map,self.getViewOverlaysById(id));
	};
	
	this.closInfoWindow=function(){
		this.getInfoWindow().close();
	};

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

	function addSearchMarkerContextMenu(googleMarker) {
		
		google.maps.event.addListener(googleMarker, 'click', function(
				mouseEvent) {
			
			currentGoogleSearchMarker=googleMarker;			
			controller.searchMarkerClick({title:googleMarker.getTitle()});
		});
	}
	
	this.linkAutoComplete=function(){
		var input = document.getElementById('searchValue');
		var autocomplete = new google.maps.places.Autocomplete(input);
		autocomplete.bindTo('bounds', map);
		
		searchMarker = new google.maps.Marker({
		    map: map,
		    anchorPoint: new google.maps.Point(0, -29)
		});
		
		google.maps.event.addListener(autocomplete, 'place_changed', function() {
			var place = autocomplete.getPlace();
			
			if (!place.geometry) {
			      return;
			}
			
			if (place.geometry.viewport) {
			      map.fitBounds(place.geometry.viewport);
			} else {
			      map.setCenter(place.geometry.location);
			      map.setZoom(17);  // Why 17? Because it looks good.
			}
			
			cleanSearchMarkers();

			var image = {
				    url: 'resource/icons/search_default.png',
				    // This marker is 20 pixels wide by 32 pixels high.
				    size: new google.maps.Size(65, 65),
				    // The origin for this image is (0, 0).
				    origin: new google.maps.Point(0, 0),
				    // The anchor for this image is the base of the flagpole at (0, 32).
				    anchor: new google.maps.Point(20, 58)
			};
			
			var marker = new google.maps.Marker({
				map : map,
				title : place.name,
				position : place.geometry.location,
				icon : image
			});
			
			searchMarkers.push(marker);
				
			addSearchMarkerContextMenu(marker);
			
		});
	}

	this.getCenter = function() {
		var wapped=new google.maps.LatLng(map.getCenter().lat(), map.getCenter().lng());
		
		return {
			lat : wapped.lat(),
			lng : wapped.lng()
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
	
	this.fitBoundsByIds=function(ids){
		if(ids.length>0){
			var bounds = new google.maps.LatLngBounds();
			for ( var i in ids) {
				var overlay=self.getViewOverlaysById(ids[i]);	
				if (overlay instanceof google.maps.Marker) {
					bounds.extend(overlay.getPosition());
				}
			}
			map.fitBounds(bounds);
		}
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
		this.createRoutineModal=new createRoutineModal('createNewRoutineModal');
		this.createRoutineModal.confirmClick(function(){
			controller.newRoutineBtnClick({
				lat:self.getCenter().lat,
				lng:self.getCenter().lng,
				title:self.createRoutineModal.getTitle(),
				mycomment:self.createRoutineModal.getDesc()
			});
		});
		
		this.markerPickRoutineModal=new PickRoutineModal('markerPickRoutineModal');
		this.markerPickRoutineModal.confirmClick(function(){	
			var markerId=self.currentMarkerId;
			var routineId=self.markerPickRoutineModal.getRoutineNameSelect().value;
			controller.copyMarker(markerId,routineId);
		});
		
		this.searchPickRoutineBoard=new PickRoutineModal('pickRoutineModal');
		this.searchPickRoutineBoard.confirmClick(function(){
			var routineId=self.searchPickRoutineBoard.getRoutineNameSelect().value;
			var description=self.searchPickRoutineBoard.getDesc();
			if(routineId==''){
				alert('please select your routine');
			}
			
			if(routineId!='default'){
				controller.showRoutineDetail(routineId);
				controller.addMarkerClickEvent({
					lat : currentGoogleSearchMarker.getPosition().lat(),
					lng : currentGoogleSearchMarker.getPosition().lng()
				}, {
					lat : currentGoogleSearchMarker.getPosition().lat(),
					lng : currentGoogleSearchMarker.getPosition().lng(),
					title : currentGoogleSearchMarker.getTitle(),
					mycomment : description
				});
				cleanSearchMarkers();
				self.searchMarkerModal.hide();
			}else{
				alert('please select your routine');
			}
			
		});
		
		this.searchMarkerModal=new SearchMarkerInfo('SearchMarkerInfoModel');
		this.searchMarkerModal.clearSearchResultsBtnClick(function(){
			cleanSearchMarkers();
		});
		
		this.searchMarkerModal.copyMarkerBtnClick(function(){
			controller.searchCopyMarkerBtnClick();
		});
		
		this.uploadImgModal = new UploadImageModal('uploadImageModal');
		this.uploadImgModal.addChangeCallBack(function(imageBase64String, lat, lon,fileName) {
			controller.uploadImgs(imageBase64String, lat, lon,fileName);
		});
		
		this.navBar=new NavBar('myNavBar');
		this.navBar.toCustomStyleClick(function(){
			controller.toCustomStyleBtnClick();
		});
		this.navBar.saveLinkClick(function(){
			controller.sync();
		});
		this.navBar.startSlideClick(function(){
			controller.startSlideMode();
		});
		this.navBar.prevSlideClick(function(){
			controller.prevSlide();
		});
		this.navBar.endSlideClick(function(){
			controller.exitSlideMode();
		});
		this.navBar.createMarkerClick(function(){
			controller.addMarkerClickEvent(self.getCenter(),{});
		});
		this.navBar.createMarkerWithImageClick(function(){
			self.uploadImgModal.show();
		});
			
		this.markerInfoDialog=new MarkerInfo('MarkerInfoModel');
		this.markerInfoDialog.copyBtnClick(function(){
			controller.markerCopyBtnClick();
		});
		
		this.ovMarkerDialog=new OvMarkerInfo('ovMarkerInfoModel');
		this.ovMarkerDialog.showRoutineDetail(function(){
			controller.showRoutineDetail(self.currentMarkerId);
		});
		this.ovMarkerDialog.copyRoutineBtnClick(function(){
			controller.copyRoutine(self.currentMarkerId);
		});
		
		this.markerEditDialog=new MarkerEditor('EditMarker');
		this.markerEditDialog.confirmClick(function(){
			controller.editFormConfirmClick(self.currentMarkerId);
		});
		this.markerEditDialog.deleteClick(function(){
			controller.editFormDeleteClick(self.currentMarkerId);
		});
		

		var mapOptions = {
			center : new google.maps.LatLng(37.3841308, -121.9801145),
			disableDoubleClickZoom : true,
			zoom : 5,
			minZoom : 5,
			maxZoom : 18,
			mapTypeId : google.maps.MapTypeId.ROADMAP
		};

		map = new google.maps.Map(document.getElementById("l-map"), mapOptions);
		googleOverlay = new google.maps.OverlayView();
		googleOverlay.draw = function() {
		};
		googleOverlay.setMap(map);

		google.maps.event.addListener(map, 'click', function(mouseEvent) {
			controller.mapClickEventHandler();
		});

		// zoom_changed
		google.maps.event.addListener(map, 'zoom_changed', function() {
			controller.zoomEventHandler();
		});

		// init marker cluster
		var mcOption=mcOptions = {styles: [{
			height: 53,
			url: "resource/icons/cluster/m1.png",
			width: 53
			},
			{
			height: 56,
			url: "resource/icons/cluster/m2.png",
			width: 56
			},
			{
			height: 66,
			url: "resource/icons/cluster/m3.png",
			width: 66}
		]};
		
		markerCluster = new MarkerClusterer(map,null,mcOption);
		markerCluster.setGridSize(30);
		

		this.linkAutoComplete();
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
		
		google.maps.event.addListener(viewMarker, 'mouseover', function(
				mouseEvent) {
			controller.markerMouseOver(viewMarker.id);
		});
		
		google.maps.event.addListener(viewMarker, 'mouseout', function(
				mouseEvent) {
			controller.markerMouseOut(viewMarker.id);
		});

		google.maps.event.addListener(viewMarker, 'click',function(mouseEvent) {
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
	
	
	this.addOverviewMarker=function(lat, lng, num,options){
		var myLatlng = new google.maps.LatLng(lat, lng);

		var viewMarker = new google.maps.Marker({
			position : myLatlng,
			map : map
		});

		// create one custom id in google mark
		viewMarker.id = num;

		viewMarker.isShow = true;
		if(options==null||options.needDrag==null||options.needDrag==false){
			viewMarker.setDraggable(false);
		}else{
			viewMarker.setDraggable(true);
		}
		
		google.maps.event.addListener(viewMarker, 'mouseover', function(
				mouseEvent) {
			controller.markerMouseOver(viewMarker.id);
		});
		
		google.maps.event.addListener(viewMarker, 'mouseout', function(
				mouseEvent) {
			controller.markerMouseOut(viewMarker.id);
		});

		google.maps.event.addListener(viewMarker, 'click',
				function(mouseEvent) {
					controller.overviewMarkerClickEventHandler(viewMarker.id);
				});

		google.maps.event.addListener(viewMarker, 'dragend', function(
				mouseEvent) {
			controller.viewMarkerDragendEventHandler(viewMarker.id, viewMarker
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

			line.isShowRoute = !line.isShowRoute;
		});

		overlays.push(line);

		return line;
	};
	
	this.drawOvLine=function(fromPosition,toPosition){
			var lineCoordinates = [
					new google.maps.LatLng(fromPosition.lat, fromPosition.lng),
					new google.maps.LatLng(toPosition.lat, toPosition.lng) ];

			// Create the polyline, passing the symbol in the 'icons' property.
			// Give the line an opacity of 0.
			// Repeat the symbol at intervals of 20 pixels to create the dashed
			// effect.
			var line = new google.maps.Polyline({
				path : lineCoordinates,
				map : map,
				strokeOpacity : 0.4,
				strokeColor : 'black',
				strokeWeight : 0.7
			});
			ovLines.push(line);
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
	
	this.removeAllOvLines=function(){
		for ( var i = 0; i < ovLines.length; i++) {
			ovLines[i].setMap(null);
		}
		ovLines=new Array();
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
		
		var image = {
			    url: iconUrl,
			    // This marker is 20 pixels wide by 32 pixels high.
			    size: new google.maps.Size(65, 65),
			    // The origin for this image is (0, 0).
			    origin: new google.maps.Point(0, 0),
			    // The anchor for this image is the base of the flagpole at (0, 32).
			    anchor: new google.maps.Point(20, 58)
		};
		
		viewMarker.setIcon(image);
	};

	this.setMarkerDragable = function(markerId, needDragable) {
		var viewMarker = this.getViewOverlaysById(markerId);
		viewMarker.setDraggable(needDragable);
	};

	this.addInfoWindow = function(marker, content, num) {
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
		//gaodeSearch(key);
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
	
	this.getZoom=function(){
		return map.getZoom();
	};
	
	this.setMapStyle2Default=function(){
		console.log('view.setMapStyle2Default');
		var defaultStyle=[];
		map.setOptions({styles: defaultStyle});
	};
	
	this.setMapStyle2Custom=function(){
		console.log('view.setMapStyle2Custom');
		var customStyle=[
		           {
		        	    "featureType": "road",
		        	    "stylers": [
		        	      { "visibility": "off" }
		        	    ]
		        	  },{
		        	    "featureType": "water",
		        	    "stylers": [
		        	      { "color": "#73ABAD" }
		        	    ]
		        	  },{
		        	    "featureType": "administrative.locality",
		        	    "stylers": [
		        	      { "visibility": "simplified" }
		        	    ]
		        	  },{
		        	    "featureType": "landscape.natural",
		        	    "elementType": "geometry.fill",
		        	    "stylers": [
		        	      { "color": "#F0EDDF" }
		        	    ]
		        	  },{
		        	    "featureType": "administrative",
		        	    "elementType": "labels.text.fill",
		        	    "stylers": [
		        	      { "color": "#698DB7" }
		        	    ]
		        	  }
		        	];
		map.setOptions({styles: customStyle});
	};
	
	this.isInCustomZoom=function(){
		var zoomlevel=self.getZoom();
		if(zoomlevel==5 || zoomlevel==6 || zoomlevel==7){
			return true;
		}else{
			return false;
		}
	};
	
	this.setMapZoom=function(zoomLevel){
		map.setZoom(zoomLevel);
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
							icon : 'resource/icons/search_default.png'
						});

						
						searchMarkers.push(marker);
						
						addSearchMarkerContextMenu(marker);

						bounds.extend(location);
					}

					map.fitBounds(bounds);
				}
			});
		});
	};
};

function ExploreGoogleMapView(oneController){
	extend(ExploreGoogleMapView,GoogleMapView,this,[oneController]);
	
	var self=this;
	
	var centerMarker;
	
	this.createSearchView=function(){
		self.createView();
		
		google.maps.event.addListener(this.getMap(), 'center_changed', function() {
			self.refreshCenterMarker();
		});
		
		google.maps.event.addListener(this.getMap(), 'dragend', function() {
			centerMarker.setVisible(false);
			controller.dragendEventHandler();
		});
	};
	
	this.linkAutoComplete=function(){
		var input = document.getElementById('searchValue');
		var autocomplete = new google.maps.places.Autocomplete(input);
		autocomplete.bindTo('bounds', self.getMap());
		
		searchMarker = new google.maps.Marker({
		    map: self.getMap(),
		    anchorPoint: new google.maps.Point(0, -29)
		});
		
		google.maps.event.addListener(autocomplete, 'place_changed', function() {
			var place = autocomplete.getPlace();
			
			if (!place.geometry) {
			      return;
			}
			
			if (place.geometry.viewport) {
				self.getMap().fitBounds(place.geometry.viewport);
			} else {
				self.getMap().setCenter(place.geometry.location);
				self.getMap().setZoom(17);  // Why 17? Because it looks good.
			}
			
			controller.dragendEventHandler();
		});
	}
	
	this.refreshCenterMarker=function(){
		if(centerMarker==null){
			centerMarker=new google.maps.Marker({
				position : this.getMap().getCenter(),
				map : this.getMap(),
				icon : 'resource/icons/center_default.png'
			});
		}else{
			centerMarker.setVisible(true);
			centerMarker.setPosition(this.getMap().getCenter());
		}
	};
	
	this.computeDistanceBetween=function(from,to){
		var googleFrom=new google.maps.LatLng(from.lat,from.lng);
		var googleTo=new google.maps.LatLng(to.lat,to.lng);
		return google.maps.geometry.spherical.computeDistanceBetween(googleFrom,
				googleTo);
	};
	
	this.drawCircle=function(location,radius,color){
		var latlng=new google.maps.LatLng(location.lat,location.lng);
		var circle=new google.maps.Circle({
			center:latlng,
			fillColor:color,
			radius:radius,
			map:self.getMap()
		});
		
	};
};