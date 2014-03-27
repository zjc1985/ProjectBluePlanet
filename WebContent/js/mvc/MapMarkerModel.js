
function MapMarkerModel(){	
	var marks=new Array();
	
	var backendManager=new BackendManager();
	
	this.getModelMarkers=function(){
		return marks;
	};
	
	this.fetchMaxIdinMarks=function(){
		marks.sort(function(mark1,mark2){
			if(mark1.id>mark2.id){
				return 1;
			}else if(mark1.id==mark2.id){
				return 0;
			}else{
				return -1;
			}
		});
		
		return marks[marks.length-1].id;
	};
	
	this.createOneMarker=function(id,content){
		var marker=new MapMarker(id);
		
		if(content!=null){
			marker.updateContent(content);
		}
		
		marks.push(marker);
		$.publish('createOneMarker',[marker]);
		
		
		
		return marker;
	};
	
	this.loadRoutine=function(routineId){
		marks=new Array();
		
		var self=this;
		
		backendManager.fetchRoutineJSONStringById(routineId,function(marksJSONString){
			if(marksJSONString!=null){
				var marksJSONArray=JSON.parse(marksJSONString);
				for(var i in marksJSONArray){
					self.createOneMarker(marksJSONArray[i].id, marksJSONArray[i]);
				}
				
				for(var i in marksJSONArray){
					var eachJSONObject=marksJSONArray[i];
					if(eachJSONObject.nextMainMarkerId!=null){
						self.addMainLine(eachJSONObject.id, eachJSONObject.nextMainMarkerId);
					}
					
					for(var j in eachJSONObject.subMarkerIds){
						self.addSubLine(eachJSONObject.id, eachJSONObject.subMarkerIds[j]);
					}
				}
			}
			alert('fetch routine success');
			console.log(marksJSONString);
			
			
		});
						
	};
	
	this.save2Backend=function(routineName){
		console.log('prepare to save routine '+routineName);
		if(marks.length==0){
			alert('no routine found. abort saving');
			return;
		}
			
		var currentUser = backendManager.getCurrentUser();
		
		if(currentUser!=null){
			var marksJSONArray=new Array();
			for(var i in marks){
				marksJSONArray.push(marks[i].toJSONObject());
			};
			
			backendManager.saveRoutine(routineName, JSON.stringify(marksJSONArray));
		}else{
			alert('no find user abort saving routine');
			return;
		}
		
	};
	
	function getOverlayById(id){
		var length=marks.length;
		for(var i=0;i<length;i++){
			if(marks[i].id==id){
				return marks[i];
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
		var length=marks.length;
		for(var i=0;i<length;i++){
			if(marks[i] instanceof MapMarker){
				if(marks[i].prevMainMarker==null&&!marks[i].isSubMarker()){
					heads.push(marks[i]);
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



function BackendManager(){
	var Routine = AV.Object.extend("Routine");
	
	var routine = null;
	var currentUser=null;
	
	
	
	AV.initialize("6pzfpf5wkg4m52owuwixt5vggrpjincr8xon3pd966fhgj3c", "4wrzupru1m4m7gpafo4llinv7iepyapnycvxygup7uiui77x");
	
	this.getCurrentUser=function(){
		currentUser = AV.User.current();
		if (currentUser) {
			console.log("welcomse session user:"+ currentUser.get('username'));
			
			return currentUser;
			
		} else {
			AV.User.logIn("yufu", "123456", {
				  success: function(user) {
					  console.log("login for user:"+ user.get('username'));
					  currentUser=user;
					  return currentUser;
				  },
				  error: function(user, error) {
					  alert("Error: " + error.code + " " + error.message);
					  alert("log failed. abort save routines");
					  return null;
				  }
			});
		}
	};
	
	this.fetchRoutineJSONStringById=function(objectId,successCallback){
		console.log('fetch routine id=:'+objectId);

		var query = new AV.Query(Routine);
		query.get(objectId, {
		  success: function(fetchedRoutine) {
			  routine=fetchedRoutine;
			  successCallback(routine.get('RoutineJSONString'));
		  },
		  error: function(object, error) {
		    alert("The object was not retrieved successfully.");
		    console.log(error);
		  }
		});
	};
	
	this.saveRoutine=function(routineName,routineJSONString){
		if(routine==null){
			routine=new Routine();
		}
		routine.set('title',routineName);
		routine.set('RoutineJSONString',routineJSONString);
		routine.set('user',this.getCurrentUser());
		routine.save(null, {
			  success: function(routineFoo) {
				  routine=routineFoo;
				  alert('save routine successful:' +routineName);
			  },
			  error:function(object,error){
				  alert('save routine failed');
				  routine=null;
			  }
			  
			});
	};
	
	//getters and setters
	
}



function MarkerContent(){
	var title="Unknown Location";
	var address="Unknown Address";
	var lat=0;
	var lng=0;
	var mycomment="...";
	var category="marker";
	var imgUrls=new Array();
	
	this.getImgUrls=function(){
		return imgUrls;
	};
	
	this.setImgUrls=function(urlArray){
		imgUrls=urlArray;
	};
	
	this.getCategory=function(){
		return category;
	};
	
	this.setCategory=function(nameFoo){
		category=nameFoo;
	};
	
	
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
		
		if(args.category!=null){
			this.content.setCategory(args.category);
		}
		
		if(args.lat!=null && args.lng!=null){
			this.content.setlatlng(args.lat,args.lng);
		}
		
		if(args.imgUrls!=null && args.imgUrls.length!=0){
			this.content.setImgUrls(args.imgUrls);
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
	
	this.toJSONObject=function(){
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
				category:this.getContent().getCategory(),
				imgUrls:this.getContent().getImgUrls(),
				nextMainMarkerId:this.connectedMainMarker==null?null:this.connectedMainMarker.id,
				subMarkerIds:subMarkerIdsArray};
		
		return object;			
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
