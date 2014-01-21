var map = new BMap.Map("l-map");
map.enableScrollWheelZoom();
var point = new BMap.Point(121.507447,31.244375);
map.centerAndZoom(point, 15);
addContextMenu(map);

map.addControl(new BMap.NavigationControl(
		{anchor: BMAP_ANCHOR_BOTTOM_RIGHT, 
		 type: BMAP_NAVIGATION_CONTROL_ZOOM})); 

var currentMarker;

var imgGalleryArray=[
        {url:'resource/img/wuzheng/wu1.png',title:'Wu Zheng'},
        {url:'http://farm9.staticflickr.com/8382/8558295631_0f56c1284f_b.jpg',title:'P2'},
        {url:'http://farm9.staticflickr.com/8383/8563475581_df05e9906d_b.jpg',title:'P3'}
                                 ];

var info1=new infoCard('card');
var contentBegin=new MarkerContent();
info1.initDefault('100px','100px',contentBegin,imgGalleryArray);


function editFormOK(){
	var updatedContent=info1.editFormClickOK();
	currentMarker.content.update(updatedContent);
}


function addSampleTrip(){
	var m1=addOneMark(map, new BMap.Point(121.32698,31.201231));
	
	map.centerAndZoom(new BMap.Point(121.32698,31.201231), 13);
	
	m1.content.title="上海虹桥火车站";
	m1.changeIcon("train");
	m1.content.imgs=[
	                 {url:'http://sh.people.com.cn/mediafile/201007/01/F2010070108502601647.jpg',title:'P2'},
	                 {url:'http://www.114piaowu.com/upload/newsimages/2013_10/20131009121228_893.jpg',title:'P3'}];
	m1.content.setMycomment("在上海火车站乘坐去桐乡的列车");                                         
	
	var m2=addOneMark(map, new BMap.Point(120.573931,30.543156));
	m2.content.title="桐乡火车站";
	m2.changeIcon("train");
	m2.content.imgs=[
	                 {url:'http://sh.sinaimg.cn/cr/2010/1018/3213231251.jpg',title:m2.content.title}
	                ];
	m2.content.setMycomment("在桐乡火车站直接坐k282的班车到乌镇汽车站"); 
	
	
	var m3=addOneMark(map, new BMap.Point(120.500623,30.737927));
	m3.content.title="桐乡乌镇汽车站";
	m3.changeIcon("bus");
	m3.content.imgs=[
	                 {url:'http://www.cnjxol.com/travel/news/content/attachement/jpg/site1/20101101/00219b4f0da20e385c330d.JPG',title:'P2'},
	                 {url:'http://www.114piaowu.com/upload/newsimages/2013_10/20131009121228_893.jpg',title:'P3'}];
	m3.content.setMycomment("再转K350才能到西栅。东西栅联票150，可是只限当天游完，一天来不及只能分开买，西栅120，东栅100。早知道东栅的小景点是打洞的，我住东栅景区内就买联票了，呜呜~~~~~~看来下次还是要相信自己的判断。西栅是全封闭的景区，里面的住宿都是由政府统一规划，无论是民宿、客栈还是会所，价格都不便宜，按照房间的条件，从300多到1000多不等，而且预算不高的民宿，提前2周都已经预定完。因为最合理的行程是买联票，第一天先游览东栅，晚上到达西栅，第二天都用来游览比东栅大3倍的西栅。然后从西栅门口，乘夜班18：00~20:00的K282直接到桐乡火车站。且还能省下140元买联票，如此西栅的房价就变成100多了。谁让小磨楚的行踪不定呢？连火车票都是最后几分钟才定好的。");
	
	var mG1=addOneMark(map, new BMap.Point(120.496458,30.753967));
	mG1.content.title="乌镇";
	mG1.changeIcon("smallcity");
	mG1.content.imgs=[
	                 {url:'resource/img/wuzheng/wu1.png',title:'P2'},
	                 {url:'http://youimg1.c-ctrip.com/target/tg/622/486/990/2057ea6153dd4e0780e81e11eed07e9c.jpg',title:'P3'}];
	mG1.content.setMycomment("在上海火车站乘坐去桐乡的列车");
	var m4=addOneMark(map, new BMap.Point(120.498325,30.754291));
	m4.content.title="西栅东大门";
	m4.changeIcon("statue");
	m4.content.imgs=[
	                 {url:'http://youimg1.c-ctrip.com/target/tg/476/125/264/19c753b9b1e14bffbd4116e61f13790f.jpg',title:'P2'},
	                 {url:'http://youimg1.c-ctrip.com/target/tg/359/567/425/91bcdb94d4734a5f985e0d8c4c767e62.jpg',title:'P3'}];
	m4.content.setMycomment("早上8点多从内环粗发，千辛万苦到达西栅，已经过中午了。景区大门口的摆渡船有点鸡肋，走走也就400~500米的路程，却要花上20~30分钟等船，可是花了这么贵的门票，不做免费船有点可惜了，所以继续等吧。。。。。。好在一进景区就是事先做好功课的“裕生餐馆”。");
	var m5=addOneMark(map, new BMap.Point(120.493284,30.754858));
	m5.content.title="裕生餐厅";
	m5.changeIcon("restaurant");
	m5.content.imgs=[
	                 {url:'http://youimg1.c-ctrip.com/target/tg/400/908/287/19ceefc0002b4af2b561a3e1dec09561.jpg',title:'P2'},
	                 {url:'http://youimg1.c-ctrip.com/target/tg/845/947/909/4684269c5a3f433eafec6fe5cb128fc6_jupiter.jpg',title:'P3'}];
	m5.content.setMycomment("裕生餐馆果然名不虚传，把点评上推荐的菜都点了一遍。手撕包菜18，是我吃过最好吃的，酸酸的很开胃。白水鱼48，蒸的火候恰到好处，嫩嫩的，可惜食材有局限，还是点鲈鱼会更好吃，价格一样滴。酱爆螺丝18，好大大一盘螺丝，哪来的酱呢，不就是酱油炒螺丝吗？只有咸味一点不好吃，还有臭的伊刚。银鱼跑蛋很失望，银鱼太小了，嫩的和蛋的口感一样，根本吃不粗来，而且很油。乌镇大羊肉88，最后才上的，中午已经卖完了，我们正赶上刚烧好的第二波。虽然贵可是很值得，真的烧得太好吃了，羊肉很酥烂，调味香喷喷的，回想起来都流口水了。定胜糕3元一块，糯糯的米糕中间夹着细腻的豆沙，是幸福的味道。");
	var m6=addOneMark(map, new BMap.Point(120.492619,30.755641));
	m6.content.title="三寸金莲展馆";
	m6.changeIcon("statue");
	m6.content.imgs=[
	                 {url:'http://dimg02.c-ctrip.com/images/tg/985/464/418/bc01def8d10d4530a1509a7f97415b63_R_800_600.jpg',title:'P2'}];
	m6.content.setMycomment("三寸金莲馆搜集了旧时民间的各种绣花鞋，展示了裹足的惨痛历史，让我不由的想起了外婆的妈妈，裹了足还走老远的路去看我外公，发现是个文书很好的白面小生，才放心的嫁外婆。李煜这个昏君，活该痛失江山！而楚这时在三寸金莲馆门口排队买油墩子，排了起码有20分钟不止。吃萝卜丝饼的人真多，3块钱一个很大，不过这种油腻的东东兔是不喜欢，小磨楚买多了，只能帮他吃掉1个，他吃2个。楚看三寸金莲馆毫无感觉，还在回味着他的油墩子，无同情心的男人哦~");
	var m7=addOneMark(map, new BMap.Point(120.49844,30.744391));
	m7.content.title="乌梅青号";
	m7.changeIcon("restaurant");
	m7.content.imgs=[
	                 {url:'http://youimg1.c-ctrip.com/target/tg/314/287/103/ae03fb97ce4249bf9b6a813557088bec.jpg',title:'P2'},
	                 {url:'http://youimg1.c-ctrip.com/target/tg/314/287/103/ae03fb97ce4249bf9b6a813557088bec.jpg',title:'P3'}];
	m7.content.setMycomment("景点看个7分，重头戏还在于吃。乌梅青号10元一杯的乌梅茶和青梅茶是鲜酿的很好喝，随心杯还能带走，买了带青梅带走20元。凉茶铺的养生茶和酸梅汁也是10元，送的杯子比乌梅店的稍差，凉茶铺只有一个阿叔在忙，排队等起来的时候，真是没底的，尤其是有人点了鲜榨果汁，我们是第二次路过才买的。可是养生茶为毛是烫的呢？在码头坐了半天才凉到能喝的地步，害我被蚊子叮了好几口。3元一块的桂花年糕很好吃，可惜没有买乌镇烧饼，很大很大一个，排队的人多。本想着第二天去东栅买来吃的，没想到再也没见到过T_T");
	var m8=addOneMark(map, new BMap.Point(120.492978,30.755502));
	m8.content.title="锦岸私房菜";
	m8.changeIcon("restaurant");
	m8.content.imgs=[
	                 {url:'http://dimg02.c-ctrip.com/images/tg/580/384/187/4f774a0d95124d709584fb1d2beaa8f5_R_800_600.jpg',title:'P2'},
	                 {url:'http://dimg02.c-ctrip.com/images/tg/580/384/187/4f774a0d95124d709584fb1d2beaa8f5_R_800_600.jpg',title:'P3'}];
	m8.content.setMycomment("晚餐想吃评价最高的锦岸私房菜可不容易。锦岸私房菜位于西栅大街的中央除了人均消费很高的包房，一楼大堂只有6桌，5点多拿到21号，当时才叫到1号，前面还有6桌也没吃多久，过桥去对面的街上逛了一圈半小时后回来才叫3号。于是兔兔楚去逛第二遍西栅大街的西半边，逛了20分钟，兔让楚打电话问问叫到几号啦？神马，竟然已经27号了，问了一下兔兔的21号也不能用了，呜呜~~~这号跳的，也太严重了。赶回去7点10分，前面还有1桌。不过锦岸私房菜8点钟厨师下班，不知道是否来得及，前面6桌都是刚进去。于是兔让小磨楚一只等，兔去童玩馆玩了，童玩馆的游乐项目很多，探险山洞里的食人花感应到人会动的，吓死兔了，兔一只玩的很开心。而楚，只要给他个手机，他是那种可以蹲点很久的动物。");
	var m9=addOneMark(map, new BMap.Point(120.501764,30.747844));
	m9.content.title="宋家客栈";
	m9.changeIcon("hotel");
	m9.content.imgs=[
	                 {url:'http://youimg1.c-ctrip.com/target/tg/276/147/852/7a6effe6cad949398a4fadd2349d096b.jpg',title:'P2'},
	                 {url:'http://youimg1.c-ctrip.com/target/tg/276/147/852/7a6effe6cad949398a4fadd2349d096b.jpg',title:'P3'}];
	m9.content.setMycomment("快吃完的时候，发消息给房东问怎么去东栅的住所。房东热情的说她开红色马6来接我们，房东是女生，和我年纪相仿。真是靠山吃山，靠水吃水，靠地吃房租啊~我们订的是雕花大床房180，屋内设施一切从简，说白了除了华丽丽的雕花床，啥都没有。房间在一楼，潮湿有股霉味儿，窗子开在卫生间，房间里有点压抑。更难以忍受的是这个隔音效果哦，对面标间里有人打呼噜都听的一清二楚，一晚上吵醒好几次。竟然还有住客3点钟叫醒房东要求提供扑克牌，房东说没有，还让房东粗去买。这么晚了上哪里去买，都关门了，房东答，纠缠了半天，把大家都吵醒了。这是什么人哦~都是订的晚了，好房间没有了，东栅也就是周六火那么一天。第二天的早餐很简单，白粥加酱菜，萝卜头、咸菜、泡菜、花生米，好在我们掏出前一天打包的羊肉和酱鸭，吃的津津有味。最有趣的是房东家养的小黑狗狗，主人给它吃我们吃剩下的骨头，它一看到楚走过去，立马叼起所有骨头藏在嘴巴里，躲起来了，等我们走远，再把骨头吐出来慢慢啃，很乖很乖的，也不叫。住在景区最大的好处，就是包包可以扔在客厅里，不用带着跑。其实起来已近中午，当然还有住客比我们起的更晚的。赶紧切入正题吧。");
	
	m1.addNextMarker(m2);
	m2.addNextMarker(m3);
	m3.addNextMarker(mG1);
	
	mG1.addTreeChildMarker(m4);
	mG1.addTreeChildMarker(m5);
	mG1.addTreeChildMarker(m6);
	mG1.addTreeChildMarker(m7);
	mG1.addTreeChildMarker(m8);
	mG1.addTreeChildMarker(m9);
	mG1.collapseSubMarkers();
	m4.setIcon(createIndexIcon(0));
	m5.setIcon(createIndexIcon(1));
	m6.setIcon(createIndexIcon(2));
	m7.setIcon(createIndexIcon(3));
	m8.setIcon(createIndexIcon(4));
	m9.setIcon(createIndexIcon(5));
	
}


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
	//var points = [fromPoint,toPoint];
	//var curve = new BMapLib.CurveLine(points, {strokeColor:"blue", strokeWeight:7, strokeOpacity:0.5}); //�������߶���
	//map.addOverlay(curve);
	//curve.disableEditing(); 
	//return curve;
	
	var arrowline=new ArrowLine(fromPoint,toPoint,30,30);
	arrowline.draw(map);
	return arrowline;
}

function drawLine(map,fromPoint,toPoint){
	var points =[fromPoint,toPoint];
	var polyline=new BMap.Polyline(points,{strokeColor:"green", 
				strokeStyle:"dashed",
				strokeWeight:3, 
				strokeOpacity:0.5});
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

function createIndexIcon(index){
	var myIcon = new BMap.Icon("http://api.map.baidu.com/img/markers.png", new BMap.Size(23, 25), {
		anchor: new BMap.Size(10, 25),
	    imageOffset: new BMap.Size(0, 0 - index * 25),
	    infoWindowAnchor:new BMap.Size(10,0)
	  });
	return myIcon;
}

function findIconByName(name){
	var path="resource/markers/";
	path=path+name+".png";
	var myIcon = new BMap.Icon(path, new BMap.Size(32, 37), {
		anchor: new BMap.Size(16, 37),
		infoWindowAnchor:new BMap.Size(16,0),
	  });
	return myIcon;
}

//�����Ϣ����
function addInfoWindow(marker,poi,index){
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

function addOneMark(map, p) {
	var marker = new MapMarker(p);
	marker.enableDragging();
	marker.addEventListener("click", function() {
		currentMarker=marker;
		
		if(marker.hasTreeChildMarker()){
			
			if(marker.areSubMarkersHide()){
				//hide all ovellays on map
				hideAllTrip(marker);
				
				//show this marker and its tree nodes
				marker.showSubMarkers();
			}else{
				//show all ovellays on map
				showAllTrip(marker);
				//hide all tree nodes belong to this map
				marker.collapseSubMarkers();
			}
		}
		
		info1.setDefaultContent(marker.content);
		
		if(marker.content.imgs!=null){
			info1.setDefaultImgs(marker.content.imgs);
		}		
		//add MainLine if clicked
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
		
		//add sub line if clicked
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
	return marker;
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
	var marker=addOneMark(map,bmarker.getPosition());
	marker.content.title=bmarker.getTitle();
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
	this.title="Unknown Location";
	this.category="default";
	this.likeNum=236;
	this.address="Unknown Address";
	var mycomment="";
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

function hideAllTrip(oneMarker){
	var marker=oneMarker;
	while(marker.connectedMainMarker!=null){
		marker.connectedMainLine.hide();
		marker=marker.connectedMainMarker;
		marker.hide();
	}
	
	marker=oneMarker;
	while(marker.prevMainMarker!=null){
		marker=marker.prevMainMarker;
		marker.hide();
		marker.connectedMainLine.hide();
	}
}

function showAllTrip(oneMarker){
	var marker=oneMarker;
	while(marker.connectedMainMarker!=null){
		marker.connectedMainLine.show();
		marker=marker.connectedMainMarker;
		marker.show();	
	}
	
	marker=oneMarker;
	while(marker.prevMainMarker!=null){
		marker=marker.prevMainMarker;
		marker.show();
		marker.connectedMainLine.show();
	}
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

MapMarker.prototype.changeIcon=function(name){
	this.content.category=name;
	if(this.content.getIcon()!=null){
		this.setIcon(this.content.getIcon());
	}
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

MapMarker.prototype.hasTreeChildMarker=function(){
	if(this.subMarkersArray==null||this.subMarkersArray.length==0){
		return false;
	}else{
		return true;
	}
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
		if(marker.connectedMainLine!=null){
			marker.connectedMainLine.remove(map);
		}
		marker.connectedMainLine=addCurveLine(map,marker.getPosition(),marker.connectedMainMarker.getPosition());
	}
}

function searchLocation(){
	removeAllSearchResults(map);
	
	var searchKey=document.getElementById("searchKey").value;
	
	var searchOptions={
			onSearchComplete: function(results){
			    // �ж�״̬�Ƿ���ȷ
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
	
	var local = new BMap.LocalSearch("ȫ��", searchOptions);
	local.search(searchKey);
}