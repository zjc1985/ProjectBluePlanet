var map = new BMap.Map("l-map");
map.enableScrollWheelZoom();
var point = new BMap.Point(121.507447,31.244375);
map.centerAndZoom(point, 15);
addContextMenu(map);

map.addControl(new BMap.NavigationControl(
		{anchor: BMAP_ANCHOR_BOTTOM_RIGHT, 
		 type: BMAP_NAVIGATION_CONTROL_ZOOM})); 

function addContextMenu(map){
	var contextMenu = new BMap.ContextMenu();
	var txtMenuItem = [ {
		text : 'add marker',
		callback : function(p) {
			addOneMark(map, p);
		}
	},
	{
		text : 'get Overlay',
		callback : function() {
			var overlays=map.getOverlays();
			var count=0;
			var countMarker=0;
			for(var i in overlays){
				if(overlays[i] instanceof MapMarker){
					count++;
				}if(overlays[i] instanceof BMap.Marker){
					countMarker++;
				}
				
			}
			alert("num of mapmarker: "+count);
			alert("num of marker: "+countMarker);
		}
	}];
	for ( var i = 0; i < txtMenuItem.length; i++) {
		contextMenu.addItem(new BMap.MenuItem(txtMenuItem[i].text,
				txtMenuItem[i].callback, 100));
		
	}
	map.addContextMenu(contextMenu);
}

function addCurveLine(map,fromPoint,toPoint){
	var points = [fromPoint,toPoint];

	var curve = new BMapLib.CurveLine(points, {strokeColor:"blue", strokeWeight:7, strokeOpacity:0.5}); //创建弧线对象
	map.addOverlay(curve);
	curve.disableEditing(); 
	return curve;
}

function drawLine(map,fromPoint,toPoint){
	var points =[fromPoint,toPoint];
	var polyline=new BMap.Polyline(points,{strokeColor:"green", strokeWeight:3, strokeOpacity:0.5});
	map.addOverlay(polyline);
	return polyline;
}

function createOneSearchMarker(p,index){
	 var myIcon = new BMap.Icon("http://api.map.baidu.com/img/markers.png", new BMap.Size(23, 25), {
		    offset: new BMap.Size(10, 25),
		    imageOffset: new BMap.Size(0, 0 - index * 25)
		  });
	var marker=new BMap.Marker(p,{icon: myIcon});
	addContextMenu2SearchMarker(map,marker);
	return marker;
}

//添加信息窗口
function addInfoWindow(marker,poi,index){
    var maxLen = 10;
    if(poi.type == BMAP_POI_TYPE_NORMAL){
        name = "地址：  ";
    }else if(poi.type == BMAP_POI_TYPE_BUSSTOP){
        name = "公交：  ";
    }else if(poi.type == BMAP_POI_TYPE_SUBSTOP){
        name = "地铁：  ";
    }
    // infowindow的标题
    var infoWindowTitle = '<div style="font-weight:bold;color:#CE5521;font-size:14px">'+poi.title+'</div>';
    // infowindow的显示信息
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

function addOneMark(map, p) {
	var marker = new MapMarker(p);
	marker.enableDragging();
	marker.addEventListener("click", function() {
		
		
		var sContent = '<img src="./resource/SampleInfo.jpg" />';
			
			
		sContent+="<br/>"+"lat:" + marker.getPosition().lat + " lng:"
			+ marker.getPosition().lng;
		var infoWindow = new BMap.InfoWindow(sContent);
		marker.openInfoWindow(infoWindow);
		
		//add curveline if clicked
		var clickedMarker=null;
		for(var i in map.getOverlays()){
			if(map.getOverlays()[i] instanceof MapMarker && map.getOverlays()[i].needMainLine==true){
				clickedMarker=map.getOverlays()[i];
				break;
			}
		}
		
		if(clickedMarker!=null){	
			clickedMarker.addNextMarker(marker);
			
			clickedMarker.needMainLine=false;
		}
		
		//add line if clicked
		var fromMarker=null;
		for(var i in map.getOverlays()){
			if(map.getOverlays()[i] instanceof MapMarker && map.getOverlays()[i].needSubLine==true){
				fromMarker=map.getOverlays()[i];
				break;
			}
		}
		if(fromMarker!=null){
			fromMarker.addTreeChildMarker(marker);
			fromMarker.needSubLine=false;
		}
	});
	
	marker.addEventListener("dragend", function(){
		marker.redrawConnectedLines();
	});
	
	addContextMenu2Marker(map,marker);
	map.addOverlay(marker);
}



function addContextMenu2Marker(map,marker){
	var contextMenu = new BMap.ContextMenu();
	var txtMenuItem = [ {
		text : 'delete marker',
		callback : function(target) {
			//TODO
			map.removeOverlay(marker);
		}
	} ,
	{
		text : 'add main line',
		callback : function() {
			marker.needMainLine=true;
			alert("please click another marker to add main line");
		}
	} ,
	{
		text:"add sub line",
		callback:function(){
			marker.needSubLine=true;
			alert("please click another marker to add sub line");
		}
	},
	{
		text:"collapse sub Marker",
		callback:function(){
			marker.collapseSubMarkers();
		}
	},
	{
		text:"show sub Marker",
		callback:function(){
			marker.showSubMarkers();
		}
	}];
	for ( var i = 0; i < txtMenuItem.length; i++) {
		contextMenu.addItem(new BMap.MenuItem(txtMenuItem[i].text,
				txtMenuItem[i].callback, 100));
		
	}
	marker.addContextMenu(contextMenu);
}

function addContextMenu2SearchMarker(map,marker){
	var contextMenu = new BMap.ContextMenu();
	var txtMenuItem = [ {
		text : 'Yes, this is the place I want',
		callback : function(target) {
			removeAllSearchResults(map);
			changeSelectedSearchResult2MapMarker(map,marker);
		}
	} ];
	for ( var i = 0; i < txtMenuItem.length; i++) {
		contextMenu.addItem(new BMap.MenuItem(txtMenuItem[i].text,
				txtMenuItem[i].callback, 100));
		
	}
	marker.addContextMenu(contextMenu);
}

function changeSelectedSearchResult2MapMarker(map,bmarker){
	addOneMark(map,bmarker.getPosition());
}

function removeAllSearchResults(map){
	var length=map.getOverlays().length;
	var resultArray=map.getOverlays();
	for(var i=0;i<length;i++){
		var overlay=resultArray.pop();
		if(overlay instanceof BMap.Marker && !(overlay instanceof MapMarker)){
			map.removeOverlay(overlay);
		}
	}

}


function Node(){
	this.entity=null;
	this.line=null;
}

function MarkerContent(){
	this.title="Default Title";
	this.category="food";
	this.likeNum=236;
	this.address="Default Address";
	this.textContent="Default content";
}

function MapMarker(point) {
	BMap.Marker.call(this, point);
	
	this.content=new MarkerContent();
	
	this.needMainLine = false;
	this.needSubLine=false;
	//next Marker and curveLine
	this.connectedMainMarker=null;
	this.connectedMainLine=null;
	
	//pre Marker and curveLine
	this.prevMainMarker=null;
	//node type array
	this.subMarkersArray=new Array();
	this.parentSubMarker=null;
	
	this.isHideAllSubMarkers=false;
}
MapMarker.prototype = new BMap.Marker();

MapMarker.prototype.areSubMarkersHide=function(){
	return this.isHideAllSubMarkers;
};

MapMarker.prototype.collapseSubMarkers=function(){
	this.isHideAllSubMarkers=true;
	for(var i in this.subMarkersArray){
		if(this.subMarkersArray==null||this.subMarkersArray.length==0){
			continue;
		}
		
		//hide marker
		if(this.subMarkersArray[i].entity!=null){
			this.subMarkersArray[i].entity.hide();
		}
		//hide line
		if(this.subMarkersArray[i].line!=null){
			this.subMarkersArray[i].line.hide();
		}
		//hide sub sub markers if it sub marker has
		this.subMarkersArray[i].entity.collapseSubMarkers();
	}
	
};

MapMarker.prototype.showSubMarkers=function(){
	this.isHideAllSubMarkers=false;
	for(var i in this.subMarkersArray){
		if(this.subMarkersArray==null||this.subMarkersArray.length==0){
			continue;
		}
		
		//hide marker
		if(this.subMarkersArray[i].entity!=null){
			this.subMarkersArray[i].entity.show();
		}
		//hide line
		if(this.subMarkersArray[i].line!=null){
			this.subMarkersArray[i].line.show();
		}
		//hide sub sub markers if it sub marker has
		this.subMarkersArray[i].entity.showSubMarkers();
	}
	
};

MapMarker.prototype.redrawConnectedLines=function(){
	//redraw curveLine
	if(this.prevMainMarker!=null){
		redrawOneMarker(this.prevMainMarker,map);
	}
	redrawOneMarker(this,map);
	
	//redraw line
	if(this.parentSubMarker!=null){	
		redrawTreeNode(this.parentSubMarker,map);
	}
	redrawTreeNode(this,map);
};

MapMarker.prototype.addTreeChildMarker=function(marker){
	var node=new Node();
	node.entity=marker;
	node.line=drawLine(map,this.getPosition(),marker.getPosition());
	this.subMarkersArray.push(node);
	marker.parentSubMarker=this;
};
//logic add and redraw
MapMarker.prototype.addNextMarker=function(marker){
	if(this.connectedMainMarker!=null){
		this.connectedMainMarker.prevMainMarker=null;
	}
	
	this.connectedMainMarker=marker;
	marker.prevMainMarker=this;
	
	redrawOneMarker(this,map);
};

function redrawTreeNode(marker,map){
	for (var j in marker.subMarkersArray){
		map.removeOverlay(marker.subMarkersArray[j].line);
		marker.subMarkersArray[j].line=drawLine(map,marker.getPosition(),
				marker.subMarkersArray[j].entity.getPosition());
		if(marker.areSubMarkersHide()){
			marker.subMarkersArray[j].line.hide();
		}
	}
}

function redrawOneMarker(marker,map){
	if(marker.connectedMainMarker==null){
		return;
	}else{
		//redraw Curve Line
		map.removeOverlay(marker.connectedMainLine);
		marker.connectedMainLine=addCurveLine(map,marker.getPosition(),marker.connectedMainMarker.getPosition());
	}
}

function searchLocation(){
	removeAllSearchResults(map);
	
	var searchKey=document.getElementById("searchKey").value;
	
	var searchOptions={
			onSearchComplete: function(results){
			    // 判断状态是否正确
			    if (local.getStatus() == BMAP_STATUS_SUCCESS){
			    	var s = [];
			    	for (var i = 0; i < results.getCurrentNumPois(); i ++){
			    		
			    		s.push(results.getPoi(i).title + ", " + results.getPoi(i).address);
			    		var searchMarker=createOneSearchMarker(results.getPoi(i).point,i);
			    		searchMarker.setTitle(results.getPoi(i).title);
			    		addInfoWindow(searchMarker,results.getPoi(i),i);
			    		map.addOverlay(searchMarker);
			    	}
			    	document.getElementById("r-result").innerHTML = s.join("<br/>");
			    }
			    
			    map.centerAndZoom(results.getPoi(0).point,15);
			}
	};
	
	var local = new BMap.LocalSearch("全国", searchOptions);
	local.search(searchKey);
}