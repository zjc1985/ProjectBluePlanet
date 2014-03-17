function MapMarkerModel(){	
	var overlays=new Array();
	
	this.createOneMarker=function(id,content){
		var marker=new MapMarker(id);
		if(content!=null){
			marker.updateContent(content);
		}
		overlays.push(marker);
		return marker;
	};
	
	this.save2Backend=function(){
		for(var i in overlays){
			console.log(overlays[i].toJSONString());
		};
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
	
	this.getMapMarkerById=function(id){
		return getOverlayById(id);
	};
	
	this.getMarkerContentById=function(id){
		var marker=getOverlayById(id);
		if(marker.getContent()!=null){
			return marker.getContent();
		}else{
			return null;
		}		
	};
	
	this.addMainLine=function(fromId,toId){
		var fromMarker=getOverlayById(fromId);
		var toMarker=getOverlayById(toId);
		fromMarker.addNextMarker(toMarker);
		
	};
	
	this.addSubLine=function(fromId,toId){
		var fromMarker=getOverlayById(fromId);
		var toMarker=getOverlayById(toId);
		fromMarker.addTreeChildMarker(toMarker);
	};
	
	this.findHeadMarker=function(){
		var heads=new Array();
		var length=overlays.length;
		for(var i=0;i<length;i++){
			if(overlays[i] instanceof MapMarker){
				if(overlays[i].prevMainMarker==null&&!overlays[i].isSubMarker()){
					heads.push(overlays[i]);
				}
			}
		}
		return heads;
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
	var title="Unknown Location";
	var address="Unknown Address";
	var lat=0;
	var lng=0;
	var mycomment="...";
	
	
	
	this.getLat=function(){
		return lat;
	};
	
	this.setlatlng=function(latFoo,lngFoo){
		lat=latFoo;
		lng=lngFoo;
		$.publish('updateUI',[]);
	};
	
	this.getLng=function(){
		return lng;
	};
	

	
	this.getAddress=function(){
		return address;
	};
	
	this.setAddress=function(addressFoo){
		address=addressFoo;
	};
	
	this.getTitle=function(){
		return title;
	};
	
	this.setTitle=function(titleFoo){
		title=titleFoo;
	};
	
	this.setMycomment=function(comment){
		mycomment=comment;
	};
	
	this.getMycomment=function(needShort){
		if(needShort){
			return mycomment.substring(0,150)+'...';
		}else{
			return mycomment;
		}
	};
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
	//of MapMarker array
	this.subMarkersArray=new Array();
	this.parentSubMarker=null;
	
	this.isHideAllSubMarkers=false;
	
	this.isSubMarker=function(){
		if(this.parentSubMarker!=null){
			return true;
		}else{
			return false;
		}
	};
	
	this.updateContent=function(args){
		if(args.title!=null){
			this.content.setTitle(args.title);
		}
		
		if(args.address!=null){
			this.content.setAddress(args.address);
		}
		
		if(args.mycomment!=null){
			this.content.setMycomment(args.mycomment);
		}
		
		if(args.lat!=null && args.lng!=null){
			this.content.setlatlng(args.lat,args.lng);
		}
		
		$.publish('updateInfoWindow',[this]);
		
	};
	
	this.canAddSubMarker=function(marker){
		var result=true;
		if(marker.parentSubMarker==null && marker.connectedMainMarker==null && marker.prevMainMarker==null){
			result=true;
		}else{
			result=false;
		}

		return result;
	};
	
	//logic add
	this.addNextMarker=function(marker){
		if(!marker.isSubMarker()){
			if(this.connectedMainMarker!=null){
				this.connectedMainMarker.prevMainMarker=null;
			}
			
			this.connectedMainMarker=marker;
			marker.prevMainMarker=this;
		}
		$.publish('updateUI',[]);
	};
	
	//logic add tree node
	this.addTreeChildMarker=function(treeNodeMarker){
		if(this.canAddSubMarker(treeNodeMarker)){
			this.subMarkersArray.push(treeNodeMarker);
			treeNodeMarker.parentSubMarker=this;
		}		
		$.publish('updateUI',[]);
	};
	
	this.toJSONString=function(){
		var subMarkerIdsArray=new Array();
		for(var i in this.subMarkersArray){
			subMarkerIdsArray.push(this.subMarkersArray[i].id);
		}
		
		var object= {id:this.id,
				lat:this.getContent().getLat(),
				lng:this.getContent().getLng(),
				title:this.getContent().getTitle(),
				address:this.getContent().getAddress(),
				mycomment:this.getContent().getMycomment(false),
				nextMainMarkerId:this.connectedMainMarker==null?null:this.connectedMainMarker.id,
				subMarkerIds:subMarkerIdsArray};
		
		return JSON.stringify(object);				
	};
	
	//getters and setters
	this.getContent=function(){
		return this.content;
	};
	
}

function MainLine(id){
	this.id=id;
}

function SubLine(id){
	this.id=id;
}
