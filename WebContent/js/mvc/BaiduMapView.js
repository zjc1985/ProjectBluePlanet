function BaiduMapView(oneController) {
	var controller = oneController;
	var map = new BMap.Map("l-map");
	this.markerNeedMainLine = null;
	this.markerNeedSubLine = null;

	var overlays = new Array();
	// this num is used to create id for BaiduMarker
	var num = 0;
	
	function createOneSearchMarker(p,index){
		 var myIcon = new BMap.Icon("http://api.map.baidu.com/img/markers.png", new BMap.Size(23, 25), {
			    offset: new BMap.Size(10, 25),
			    imageOffset: new BMap.Size(0, 0 - index * 25)
			  });
		var marker=new BMap.Marker(p,{icon: myIcon});
		addContextMenu2SearchMarker(map,marker);
		return marker;
	}
	
	function addContextMenu2SearchMarker(map,marker){
		var contextMenu = new BMap.ContextMenu();
		var txtMenuItem = [ {
			text : 'Yes, this is the place I want',
			callback : function(target) {
				removeAllSearchResults();
				var content=new Object();
				content.title=marker.title;
				content.address=marker.address;
				controller.addMarkerClickEvent(marker.getPosition(),content);
			}
		} ];
		for ( var i = 0; i < txtMenuItem.length; i++) {
			contextMenu.addItem(new BMap.MenuItem(txtMenuItem[i].text,
					txtMenuItem[i].callback, 100));
			
		}
		marker.addContextMenu(contextMenu);
	}
	
	function removeAllSearchResults(){
		var length=map.getOverlays().length;
		var resultArray=map.getOverlays();
		for(var i=0;i<length;i++){
			var overlay=resultArray.pop();
			if(overlay instanceof BMap.Marker && !(overlay instanceof BaiduMarker)){
				map.removeOverlay(overlay);
			}
		}

	}
	
	function addSearchInfoWindow(marker,poi,index){
	    var maxLen = 10;
	    if(poi.type == BMAP_POI_TYPE_NORMAL){
	        name = "��ַ��  ";
	    }else if(poi.type == BMAP_POI_TYPE_BUSSTOP){
	        name = "������  ";
	    }else if(poi.type == BMAP_POI_TYPE_SUBSTOP){
	        name = "����  ";
	    }
	    // infowindow�ı���
	    var infoWindowTitle = '<div style="font-weight:bold;color:#CE5521;font-size:14px">'+poi.title+'</div>';
	    // infowindow����ʾ��Ϣ
	    var infoWindowHtml = [];
	    infoWindowHtml.push('<table cellspacing="0" style="table-layout:fixed;width:100%;font:12px arial,simsun,sans-serif"><tbody>');
	    infoWindowHtml.push('<tr>');
	    //infoWindowHtml.push('<td style="vertical-align:top;line-height:16px;width:38px;white-space:nowrap;word-break:keep-all">' + name + '</td>');
	    infoWindowHtml.push('<td style="vertical-align:top;line-height:16px">' + poi.address + ' </td>');
	    infoWindowHtml.push('</tr>');
	    infoWindowHtml.push('</tbody></table>');
	    var infoWindow = new BMap.InfoWindow(infoWindowHtml.join(""),{title:infoWindowTitle,width:200}); 
	    var openInfoWinFun = function(){
	        marker.openInfoWindow(infoWindow);
	        for(var cnt = 0; cnt < maxLen; cnt++){
	            if(!document.getElementById("list" + cnt)){continue;}
	            if(cnt == index){
	                document.getElementById("list" + cnt).style.backgroundColor = "#f0f0f0";
	            }else{
	                document.getElementById("list" + cnt).style.backgroundColor = "#fff";
	            }
	        }
	    };
	    marker.addEventListener("click", openInfoWinFun);
	    return openInfoWinFun;
	}
	
	this.searchLocation=function(key){
		removeAllSearchResults(map);
		
		var searchKey=key;
		
		var searchOptions={
				onSearchComplete: function(results){
				    if (local.getStatus() == BMAP_STATUS_SUCCESS){
				    	
				    	for (var i = 0; i < results.getCurrentNumPois(); i ++){
				    		var searchMarker=createOneSearchMarker(results.getPoi(i).point,i);
				    		searchMarker.setTitle(results.getPoi(i).title);
				    		searchMarker.title=results.getPoi(i).title;
				    		searchMarker.setLabel(results.getPoi(i).address);
				    		searchMarker.address=results.getPoi(i).address;
				    		addSearchInfoWindow(searchMarker,results.getPoi(i),i);
				    		map.addOverlay(searchMarker);
				    	}
				    	
				    }
				    
				    map.centerAndZoom(results.getPoi(0).point,15);
				}
		};
		
		var local = new BMap.LocalSearch(map, searchOptions);
		local.search(searchKey);
	};

	this.createView = function() {
		map.enableScrollWheelZoom();
		var point = new BMap.Point(121.507447, 31.244375);
		map.centerAndZoom(point, 15);

		map.addControl(new BMap.NavigationControl({
			anchor : BMAP_ANCHOR_BOTTOM_RIGHT,
			type : BMAP_NAVIGATION_CONTROL_ZOOM
		}));

		addContextMenu();

		map.addEventListener("zoomend", function() {
			controller.zoomEventHandler();
		});
	};

	this.drawSubLine = function(idFrom, idTo) {
		num++;
		var points = [ getOverlayById(idFrom).getPosition(),
				getOverlayById(idTo).getPosition() ];
		var polyline = new BMap.Polyline(points, {
			strokeColor : "green",
			strokeStyle : "dashed",
			strokeWeight : 3,
			strokeOpacity : 0.5
		});
		polyline.id = num;
		map.addOverlay(polyline);
		overlays.push(polyline);
		return polyline.id;
	};

	this.drawMainLine = function(idFrom, idTo) {
		num++;
		var sideLength;
		if (map.getZoom() < 15) {
			sideLength = 15;
		} else {
			sideLength = 30;
		}

		var arrowline = new ArrowLine(getOverlayById(idFrom).getPosition(),
				getOverlayById(idTo).getPosition(), sideLength, 30, num++);
		arrowline.draw(map);
		overlays.push(arrowline);
		return arrowline.id;
	};

	function getOverlayById(id) {
		var length = overlays.length;
		for ( var i = 0; i < length; i++) {
			if (overlays[i].id == id) {
				return overlays[i];
			}
		}
		return null;
	};
	
	this.getViewOverlaysById=function(id){
		return getOverlayById(id);
	};

	this.removeById = function(id) {
		var overlay = getOverlayById(id);
		if (overlay instanceof ArrowLine) {
			overlay.remove(map);
		} else {
			map.removeOverlay(overlay);
		}
	};
	
	this.removeAllLines=function(){
		for(var i=0;i<overlays.length;i++){
			if(overlays[i] instanceof ArrowLine){
				overlays[i].remove(map);
			}else if(overlays[i] instanceof BMap.Polyline){
				map.removeOverlay(overlays[i]);
			}
		}
	};

	this.addInfoWindow = function(marker,content) {
		num++;

		var mySquare = new SquareOverlay(marker.getPosition(), content, num);
		
		mySquare._infoCard.addEditFormOKButtonEvent(function(){
			console.log('edit ok click');
			var content= mySquare._infoCard.editFormClickOK();
			controller.updateMarkerContentById(marker.id,content);
		});
		
		map.addOverlay(mySquare);
		return mySquare;
	};

	this.addOneMark = function(p) {
		num++;
		var marker = new BaiduMarker(p, num);
		marker.enableDragging();

		marker.addEventListener("click", function() {
			controller.markerClickEventHandler(marker);
		});

		marker.addEventListener("dragend", function() {
			controller.markerDragendEventHandler(marker);
		});

		map.addOverlay(marker);

		addMarkerContextMenu(marker);

		overlays.push(marker);

		return marker;
	};

	function addMarkerContextMenu(marker) {
		var contextMenu = new BMap.ContextMenu();
		var txtMenuItem = [ {
			text : 'show info',
			callback : function() {
				controller.showInfoClickHandler(marker);
			}
		}, {
			text : 'add main line',
			callback : function() {
				controller.addMainLineClickHandler(marker);
			}
		}, {
			text : "add sub line",
			callback : function() {
				// marker.needSubLine=true;
				// alert("please click another marker to add sub line");
				controller.addSubLineClickHandler(marker);
			}
		}, {
			text : "collapse sub Marker",
			callback : function() {
				// marker.collapseSubMarkers();
			}
		}, {
			text : "testing Feature",
			callback : function() {
				controller.testingFeature();
			}
		} ];
		for ( var i = 0; i < txtMenuItem.length; i++) {
			contextMenu.addItem(new BMap.MenuItem(txtMenuItem[i].text,
					txtMenuItem[i].callback, 100));

		}
		marker.addContextMenu(contextMenu);
	}

	function addContextMenu() {
		var contextMenu = new BMap.ContextMenu();
		var txtMenuItem = [ {
			text : 'add marker',
			callback : function(position) {
				controller.addMarkerClickEvent(position,{lat:position.lat,
															lng:position.lng});
			}
		}, {
			text : 'test function',
			callback : function(position) {
				
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

function BaiduMarker(point, id) {
	BMap.Marker.call(this, point);
	this.id = id;
}

BaiduMarker.prototype = new BMap.Marker();



function SquareOverlay(center, content, id) {
	BMap.Marker.call(this, center);
	this._center = center;
	this._infoCard = new infoCard('card' + id);
	this._infoCard.initDefault('0px', '0px', content, null);
	this.id = id;
}

SquareOverlay.prototype = new BMap.Overlay();

SquareOverlay.prototype.reInit = function() {
	console.log('======Pin=====');
	console.log('left:' + this._infoCard.getLeft());
	console.log('top:' + this._infoCard.getTop());
	var pixel = new BMap.Pixel(this._infoCard.getLeft(), this._infoCard
			.getTop());
	this._div.appendChild(this._infoCard.toJSObject());

	this._center = this._map.pixelToPoint(pixel);
	this.draw();
};

SquareOverlay.prototype.initialize = function(mp) {
	
	this._map = mp;

	var thisObject = this;

	this._infoCard.addPinButtonEvent(function() {
		thisObject.reInit();
	});

	this._infoCard.addUnpinButtonEvent(function() {
		var p = thisObject._map.pointToPixel(thisObject._center);
		thisObject._infoCard.unpin(p.x, p.y);
	});

	var div = document.createElement("div");
	div.id = 'SquareOverlay' + this.id;
	div.style.position = "absolute";
	// div.style.backgroundColor = "#EE5D5B";
	//div.style.border = "1px solid #BC3B3A";
	// 可以根据参数设置元素外观
	//div.style.width = 500 + "px";
	//div.style.height = 300 + "px";
	div.style.background = this._color;

	div.appendChild(this._infoCard.toJSObject());

	// 将div添加到覆盖物容器中
	mp.getPanes().labelPane.appendChild(div);


	// 保存div实例
	this._div = div;
	// 需要将div元素作为方法的返回值，当调用该覆盖物的show、
	// hide方法，或者对覆盖物进行移除时，API都将操作此元素。
	return div;
};

SquareOverlay.prototype.setContent=function(content){
	this._infoCard.setDefaultContent(content);
};

SquareOverlay.prototype.show=function(){
	this._infoCard.show();
};

SquareOverlay.prototype.hide=function(){
	this._infoCard.hide();
};

SquareOverlay.prototype.draw = function() {
	var position = this._map.pointToOverlayPixel(this._center);
	this._div.style.left = position.x + "px";
	this._div.style.top = position.y + "px";

};
