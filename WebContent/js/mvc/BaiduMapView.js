function BaiduMapView(oneController,oneModel){
	var controller=oneController;
	var model=oneModel;
	var map=new BMap.Map("l-map");
	this.markerNeedMainLine=null;
	this.markerNeedSubLine=null;
	
	var overlays=new Array();
	//this num is used to create id for BaiduMarker
	var num=0; 
	
	this.createView=function(){
		map.enableScrollWheelZoom();
		var point = new BMap.Point(121.507447,31.244375);
		map.centerAndZoom(point, 15);

		map.addControl(new BMap.NavigationControl(
				{anchor: BMAP_ANCHOR_BOTTOM_RIGHT, 
				 type: BMAP_NAVIGATION_CONTROL_ZOOM}));
		
		addContextMenu();
		
		map.addEventListener("zoomend",function(){
			controller.zoomEventHandler();
		});
	};
	
	this.drawSubLine=function(idFrom,idTo){
		num++;
		var points =[getOverlayById(idFrom).getPosition(),
		             getOverlayById(idTo).getPosition()];
		var polyline=new BMap.Polyline(points,{strokeColor:"green", 
					strokeStyle:"dashed",
					strokeWeight:3, 
					strokeOpacity:0.5});
		polyline.id=num;
		map.addOverlay(polyline);
		overlays.push(polyline);
		return polyline.id;
	};
	
	this.drawMainLine=function(idFrom,idTo){
		num++;
		var sideLength;
		if(map.getZoom()<15){
			sideLength=15;
		}else{
			sideLength=30;
		}
		
		
		var arrowline=new ArrowLine(getOverlayById(idFrom).getPosition(),getOverlayById(idTo).getPosition(),sideLength,30,num++);
		arrowline.draw(map);
		overlays.push(arrowline);
		return arrowline.id;
	};
	
	function getOverlayById(id){
		var length=overlays.length;
		for(var i=0;i<length;i++){
			if(overlays[i].id==id){
				return overlays[i];
			}
		}
		return null;
	};
	
	this.removeById=function(id){
		var overlay=getOverlayById(id);
		if(overlay instanceof ArrowLine){
			overlay.remove(map);
		}else{
			map.removeOverlay(overlay);
		}
	};
	
	this.addOneMark=function(p){
		num++;
		var marker = new BaiduMarker(p,num);
		marker.enableDragging();
		
		marker.addEventListener("click", function(){
			controller.markerClickEventHandler(marker);
		});
		
		marker.addEventListener("dragend",function(){
			controller.markerDragendEventHandler(marker);
		});
		
		map.addOverlay(marker);
		
		addMarkerContextMenu(marker);
		
		overlays.push(marker);
		
		return marker;
	};
	
	function addMarkerContextMenu(marker){
		var contextMenu = new BMap.ContextMenu();
		var txtMenuItem = [ {
			text : 'delete marker',
			callback : function(target) {
				//TODO
				//map.removeOverlay(marker);
			}
		} ,
		{
			text : 'add main line',
			callback : function() {
				controller.addMainLineClickHandler(marker);
			}
		} ,
		{
			text:"add sub line",
			callback:function(){
				//marker.needSubLine=true;
				//alert("please click another marker to add sub line");
				controller.addSubLineClickHandler(marker);
			}
		},
		{
			text:"collapse sub Marker",
			callback:function(){
				//marker.collapseSubMarkers();
			}
		},
		{
			text:"show sub Marker",
			callback:function(){
				//marker.showSubMarkers();
			}
		}];
		for ( var i = 0; i < txtMenuItem.length; i++) {
			contextMenu.addItem(new BMap.MenuItem(txtMenuItem[i].text,
					txtMenuItem[i].callback, 100));
			
		}
		marker.addContextMenu(contextMenu);
	}
	
	function addContextMenu(){
		var contextMenu = new BMap.ContextMenu();
		var txtMenuItem = [{
			text : 'add marker',
			callback : function(position) {
				controller.addMarkerClickEvent(position);
			}
		}
		];
		for ( var i = 0; i < txtMenuItem.length; i++) {
			contextMenu.addItem(new BMap.MenuItem(txtMenuItem[i].text,
					txtMenuItem[i].callback, 100));
			
		}
		map.addContextMenu(contextMenu);
	}
	
	
}



function BaiduMarker(point,id) {
	BMap.Marker.call(this, point);
	this.id=id;
}
BaiduMarker.prototype = new BMap.Marker();

