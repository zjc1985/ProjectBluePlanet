function BaiduMapView(oneController, oneModel) {
	var controller = oneController;
	var model = oneModel;
	var map = new BMap.Map("l-map");
	this.markerNeedMainLine = null;
	this.markerNeedSubLine = null;

	var overlays = new Array();
	// this num is used to create id for BaiduMarker
	var num = 0;

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
	}
	;

	this.removeById = function(id) {
		var overlay = getOverlayById(id);
		if (overlay instanceof ArrowLine) {
			overlay.remove(map);
		} else {
			map.removeOverlay(overlay);
		}
	};

	this.addCustomOverlay = function(p) {
		num++;
		var info1 = new infoCard('card' + num);
		var contentBegin = new MarkerContent();
		info1.initDefault('100px', '100px', contentBegin, null);

		var mySquare = new SquareOverlay(p, info1, num);

		// var mySquare=new ComplexCustomOverlay(p,'text','mouseOverText');
		// mySquare.enableDragging();
		map.addOverlay(mySquare);

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
			text : 'delete marker',
			callback : function(target) {
				// TODO
				// map.removeOverlay(marker);
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
			text : "show sub Marker",
			callback : function() {
				// marker.showSubMarkers();
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
				controller.addMarkerClickEvent(position);
			}
		}, {
			text : 'add custom overlay',
			callback : function(position) {
				controller.addCustomClickEvent(position);
			}
		}, {
			text : 'drag',
			callback : function(position) {
				$("#searchDialog").draggable();
			}
		}, {
			text : 'into Map',
			callback : function(position) {
				$("#customInfo").append("<p>add new</p>");
			}
		}, {
			text : 'out Map',
			callback : function(position) {
				$("#searchDialog").draggable();
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

function SquareOverlay(center, infoCard, id) {
	BMap.Marker.call(this, center);
	this._center = center;
	this._infoCard = infoCard;
	this.id = id;
}

SquareOverlay.prototype = new BMap.Overlay();

SquareOverlay.prototype.reInit = function() {
	console.log('======Pin=====');
	console.log('left:' + this._infoCard.getLeft());
	console.log('top:' + this._infoCard.getTop());
	var pixel = new BMap.Pixel(this._infoCard.getLeft() - 50, this._infoCard
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
	div.style.border = "1px solid #BC3B3A";
	// 可以根据参数设置元素外观
	div.style.width = 500 + "px";
	div.style.height = 300 + "px";
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

SquareOverlay.prototype.draw = function() {
	var position = this._map.pointToOverlayPixel(this._center);
	this._div.style.left = (position.x + 50) + "px";
	this._div.style.top = position.y + "px";

};
