function MapMarkerModel(){
	var view;
	var overlays=new Array();
	
	this.setView=function(argView){
		view=argView;
	};
	
	this.createOneMarker=function(id,content){
		var marker=new MapMarker(id);
		if(content!=null){
			marker.content.update(content);
		}
		overlays.push(marker);
		return marker;
	};
	
	
	
	function getOverlayById(id){
		var length=overlays.length;
		for(var i=0;i<length;i++){
			if(overlays[i].id==id){
				return overlays[i];
			}
		}
		return null;
	}
	
	this.getMarkerContentById=function(id){
		var marker=getOverlayById(id);
		if(marker.content!=null){
			return marker.content;
		}else{
			return null;
		}		
	};
	
	this.addMainLine=function(fromId,toId){
		var fromMarker=getOverlayById(fromId);
		var toMarker=getOverlayById(toId);
		fromMarker.addNextMarker(toMarker);
		redrawOneMarker(fromMarker);
	};
	
	this.addSubLine=function(fromId,toId){
		var fromMarker=getOverlayById(fromId);
		var toMarker=getOverlayById(toId);
		
		var node=new Node();
		node.entity=toMarker;
		node.line=new SubLine(view.drawSubLine(fromId,toId));
		fromMarker.addTreeChildMarker(node);
	};
	
	this.findHeadMarker=function(){
		var headIds=new Array();
		var length=overlays.length;
		for(var i=0;i<length;i++){
			if(overlays[i] instanceof MapMarker){
				if(overlays[i].prevMainMarker==null&&overlays[i].connectedMainMarker!=null){
					headIds.push(overlays[i].id);
				}
			}
		}
		return headIds;
	};
	
	this.redrawConnectedLine=function(id){
		var marker=getOverlayById(id);
		//redraw curveLine
		if(marker.prevMainMarker!=null){
			redrawOneMarker(marker.prevMainMarker);
		}
		redrawOneMarker(marker);
		
		if(marker.parentSubMarker!=null){
			redrawTreeNode(marker.parentSubMarker);
		}
		redrawTreeNode(marker);
	};
	
	function redrawOneMarker(marker){
		if(marker.connectedMainMarker==null){
			return;
		}else{
			//redraw Curve Line
			if(marker.connectedMainLine!=null){
				//marker.connectedMainLine.remove(map);
				view.removeById(marker.connectedMainLine.id);
			}
			//addCurveLine(map,marker.getPosition(),marker.connectedMainMarker.getPosition());
			marker.connectedMainLine=new MainLine(view.drawMainLine(marker.id,marker.connectedMainMarker.id));
			
		}
	}
	
	function redrawTreeNode(marker){
		for (var j in marker.subMarkersArray){
			//map.removeOverlay(marker.subMarkersArray[j].line);
			view.removeById(marker.subMarkersArray[j].line.id);
			marker.subMarkersArray[j].line=new SubLine(view.drawSubLine(marker.id,marker.subMarkersArray[j].entity.id));
			/*
			if(marker.areSubMarkersHide()){
				marker.subMarkersArray[j].line.hide();
			}
			*/
		}
	}
	
}

function MarkerContent(){
	this.title="Unknown Location";
	this.category="default";
	this.likeNum=236;
	this.address="Unknown Address";
	var mycomment="...";
	this.imgs=null;
	
	this.update=function(uc){
		this.title=uc.title;
		this.category=uc.category;
		this.address=uc.address;
		mycomment=uc.getMycomment(false);
	};
	
	this.setMycomment=function(comment){
		mycomment=comment;
	};
	
	this.getMycomment=function(needShort){
		if(needShort){
			return mycomment.substring(0,130)+'...';
		}else{
			return mycomment;
		}
	};
	
	this.getIconPath=function(){
		return "resource/markers/"+this.category+".png";
	};
	
	this.getIcon=function(){
		if(this.getIconPath()==null){
			return null;
		}
		
		var myIcon = new BMap.Icon(this.getIconPath(), new BMap.Size(32, 37), {
		anchor: new BMap.Size(16, 37),
		infoWindowAnchor:new BMap.Size(16,0),
		});
		return myIcon;
	};
}

function MainLine(id){
	this.id=id;
}

function SubLine(id){
	this.id=id;
}

function Node(){
	this.entity=null;
	this.line=null;
}

function MapMarker(id) {
	this.id=id;
	
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
	
	//logic add
	this.addNextMarker=function(marker){
		if(this.connectedMainMarker!=null){
			this.connectedMainMarker.prevMainMarker=null;
		}
		
		this.connectedMainMarker=marker;
		marker.prevMainMarker=this;
	};
	
	//logic add tree node
	this.addTreeChildMarker=function(treeNodeMarker){
		this.subMarkersArray.push(treeNodeMarker);
		treeNodeMarker.entity.parentSubMarker=this;
	};
}

this.areSubMarkersHide=function(){
	return this.isHideAllSubMarkers;
};

this.changeIcon=function(name){
	this.content.category=name;
	if(this.content.getIcon()!=null){
		this.setIcon(this.content.getIcon());
	}
};

this.collapseSubMarkers=function(){
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

this.showSubMarkers=function(){
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

this.redrawConnectedLines=function(){
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

this.addTreeChildMarker=function(marker){
	var node=new Node();
	node.entity=marker;
	node.line=drawLine(map,this.getPosition(),marker.getPosition());
	this.subMarkersArray.push(node);
	marker.parentSubMarker=this;
};

this.hasTreeChildMarker=function(){
	if(this.subMarkersArray==null||this.subMarkersArray.length==0){
		return false;
	}else{
		return true;
	}
};

