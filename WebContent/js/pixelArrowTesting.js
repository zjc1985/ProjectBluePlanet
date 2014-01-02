var map = new BMap.Map("allmap");
var point = new BMap.Point(116.404, 39.915);
map.centerAndZoom(point, 15);
map.addControl(new BMap.NavigationControl());
map.enableScrollWheelZoom();
/*
// pixel point
var x1, y1, 
	x2, y2, 
	x3, y3,
	x4,y4,
	x5,y5,
	x6,y6;
x1 =0; 
y1 = 0;
y2 = 100;
x2 = 173.205;

y3 = 173.205;
x3 = 500;

x4=-x3;
y4=y3;

x5=x3;
y5=-y3;

x6=-x3;
y6=-y3;

var p1 = map.pixelToPoint(new BMap.Pixel(x1, y1));
var p2 = map.pixelToPoint(new BMap.Pixel(x2, y2));
var p3 = map.pixelToPoint(new BMap.Pixel(x3, y3));
var p4 = map.pixelToPoint(new BMap.Pixel(x4, y4));
var p5 = map.pixelToPoint(new BMap.Pixel(x5, y5));
var p6 = map.pixelToPoint(new BMap.Pixel(x6, y6));

var polyline = new BMap.Polyline([ p1, p2 ], {
	strokeColor : "blue",
	strokeWeight : 3,
	strokeOpacity : 0.5
});
map.addOverlay(polyline);

var polyline = new BMap.Polyline([ p1, p3 ], {
	strokeColor : "blue",
	strokeWeight : 3,
	strokeOpacity : 0.5
});
map.addOverlay(polyline);
var polyline = new BMap.Polyline([ p1, p4 ], {
	strokeColor : "blue",
	strokeWeight : 3,
	strokeOpacity : 0.5
});
map.addOverlay(polyline);

var polyline = new BMap.Polyline([ p1, p5 ], {
	strokeColor : "blue",
	strokeWeight : 3,
	strokeOpacity : 0.5
});
map.addOverlay(polyline);
var polyline = new BMap.Polyline([ p1, p6 ], {
	strokeColor : "blue",
	strokeWeight : 3,
	strokeOpacity : 0.5
});
map.addOverlay(polyline);
*/
var l=20;
var t=50;
/*
myDrawArrowFunction(p1, p2, l, t);
myDrawArrowFunction(p1, p3, l, t);
myDrawArrowFunction(p1, p4, l, t);
myDrawArrowFunction(p1, p5, l, t);
myDrawArrowFunction(p1, p6, l, t);

myDrawArrowFunction(p3, p1, 20, 50);
myDrawArrowFunction(p6, p1, 20, 50);
*/

var polyline = new BMap.Polyline([                               
                                  new BMap.Point(116.405, 39.920),  
                                  new BMap.Point(116.425,39.71936),                                                       
                                ], {strokeColor:"blue", strokeWeight:3, strokeOpacity:0.5});  
//map.addOverlay(polyline);

var arrowLine = new ArrowLine(new BMap.Point(116.405, 39.920), 
		  new BMap.Point(116.425,39.93936),
		  20,
		  30);
/*
window.setInterval(function(){
	arrowLine.endPoint.lat+=0.0001;
	arrowLine.redraw();
},200);
*/
function ArrowLine(startPoint,endPoint,length,angleValue){
	this.startPoint=startPoint;
	this.endPoint=endPoint;
	this.length=length;
	this.angleValue=angleValue;
	
	this.line=new BMap.Polyline([ startPoint, endPoint ], {
		strokeColor : "blue",
		strokeWeight : 3,
		strokeOpacity : 0.5
	});
	
	this.arrow=new BMap.Polyline(myDrawArrowFunction(startPoint,endPoint,length,angleValue),
			{
		strokeColor : "blue",
		strokeWeight : 3,
		strokeOpacity : 0.5
	});
	
	this.redraw=function(){
		map.removeOverlay(this.line);
		map.removeOverlay(this.arrow);
		this.line=new BMap.Polyline([ this.startPoint, this.endPoint ], {
			strokeColor : "blue",
			strokeWeight : 3,
			strokeOpacity : 0.5
		});
		
		this.arrow=new BMap.Polyline(myDrawArrowFunction(this.startPoint,this.endPoint,length,angleValue),
				{
			strokeColor : "blue",
			strokeWeight : 3,
			strokeOpacity : 0.5
		});
		map.addOverlay(this.line);
		map.addOverlay(this.arrow);
	};
	
	map.addOverlay(this.line);
	map.addOverlay(this.arrow);
	
}

function myDrawArrowFunction(startPoint, endPoint, length, angleValue) {
	var d=1;
	var pixelStart = map.pointToPixel(startPoint);
	var pixelEnd = map.pointToPixel(endPoint);
	
	if(pixelEnd.y<pixelStart.y){
		d=-1;
	}
	
	var angle = angleValue / 180 * Math.PI;
	var pixelX, pixelY, pixelX1, pixelY1;

	if (pixelStart.x == pixelEnd.x) {
		pixelX = pixelStart.x + Math.sin(angle) * length;
		pixelX1 = pixelStart.x - Math.sin(angle) * length;

		if (pixelStart.y < pixelEnd.y) {
			pixelY = pixelY1 = pixelEnd.y - Math.cos(angle) * length;
		} else {
			pixelY = pixelY1 = pixelEnd.y + Math.cos(angle) * length;
		}
	} else {
		var aAngle = Math.atan((pixelEnd.x - pixelStart.x)
				/ (pixelEnd.y - pixelStart.y));
		// left
		pixelX = pixelEnd.x - d*length * Math.sin(aAngle - angle);
		pixelY = pixelEnd.y - d*length * Math.cos(aAngle - angle);

		pixelX1 = pixelEnd.x - d*length * Math.sin(aAngle + angle);
		pixelY1 = pixelEnd.y - d*length * Math.cos(aAngle + angle);

	}

	var pointArrow = map.pixelToPoint(new BMap.Pixel(pixelX, pixelY));
	var pointArrow1 = map.pixelToPoint(new BMap.Pixel(pixelX1, pixelY1));
	var points= [pointArrow, endPoint, pointArrow1];
	return points;
}

function addArrow(polyline, length, angleValue) { // 锟斤拷锟狡硷拷头锟侥猴拷锟斤拷
	var linePoint = polyline.getPath();// 锟竭碉拷锟斤拷甏�
	var arrowCount = linePoint.length;
	for ( var i = 1; i < arrowCount; i++) { // 锟节拐点处锟斤拷锟狡硷拷头
		var pixelStart = map.pointToPixel(linePoint[i - 1]);
		var pixelEnd = map.pointToPixel(linePoint[i]);
		var angle = angleValue;// 锟斤拷头锟斤拷锟斤拷锟竭的夹斤拷
		var r = length; // r/Math.sin(angle)锟斤拷锟斤拷头锟斤拷锟斤拷
		var delta = 0; // 锟斤拷锟斤拷斜锟绞ｏ拷锟斤拷直时锟斤拷斜锟斤拷
		var param = 0; // 锟斤拷锟斤拷锟洁考锟斤拷
		var pixelTemX, pixelTemY;// 锟斤拷时锟斤拷锟斤拷锟�
		var pixelX, pixelY, pixelX1, pixelY1;// 锟斤拷头锟斤拷锟斤拷锟斤拷
		if (pixelEnd.x - pixelStart.x == 0) { // 斜锟绞诧拷锟斤拷锟斤拷锟斤拷时
			pixelTemX = pixelEnd.x;
			if (pixelEnd.y > pixelStart.y) {
				pixelTemY = pixelEnd.y - r;
			} else {
				pixelTemY = pixelEnd.y + r;
			}
			// 锟斤拷知直锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟疥及锟斤拷锟斤拷一锟斤拷锟角ｏ拷锟斤拷锟斤拷锟斤拷一锟斤拷锟斤拷锟斤拷锟斤拷惴�
			pixelX = pixelTemX - r * Math.tan(angle);
			pixelX1 = pixelTemX + r * Math.tan(angle);
			pixelY = pixelY1 = pixelTemY;
		} else // 斜锟绞达拷锟斤拷时
		{
			delta = (pixelEnd.y - pixelStart.y) / (pixelEnd.x - pixelStart.x);
			param = Math.sqrt(delta * delta + 1);

			if ((pixelEnd.x - pixelStart.x) < 0) // 锟节讹拷锟斤拷锟斤拷锟斤拷锟斤拷
			{
				pixelTemX = pixelEnd.x + r / param;
				pixelTemY = pixelEnd.y + delta * r / param;
			} else// 锟斤拷一锟斤拷锟斤拷锟斤拷锟斤拷
			{
				pixelTemX = pixelEnd.x - r / param;
				pixelTemY = pixelEnd.y - delta * r / param;
			}
			// 锟斤拷知直锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟斤拷锟疥及锟斤拷锟斤拷一锟斤拷锟角ｏ拷锟斤拷锟斤拷锟斤拷一锟斤拷锟斤拷锟斤拷锟斤拷惴�
			pixelX = pixelTemX + Math.tan(angle) * r * delta / param;
			pixelY = pixelTemY - Math.tan(angle) * r / param;

			pixelX1 = pixelTemX - Math.tan(angle) * r * delta / param;
			pixelY1 = pixelTemY + Math.tan(angle) * r / param;
		}

		var pointArrow = map.pixelToPoint(new BMap.Pixel(pixelX, pixelY));
		var pointArrow1 = map.pixelToPoint(new BMap.Pixel(pixelX1, pixelY1));
		var Arrow = new BMap.Polyline(
				[ pointArrow, linePoint[i], pointArrow1 ], {
					strokeColor : "blue",
					strokeWeight : 3,
					strokeOpacity : 0.5
				});
		map.addOverlay(Arrow);
	}
}