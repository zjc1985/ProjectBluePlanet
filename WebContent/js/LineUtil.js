function ArrowLine(startPoint,endPoint,length,angleValue){
	this.startPoint=startPoint;
	this.endPoint=endPoint;
	this.length=length;
	this.angleValue=angleValue;
	
	this.line=new BMap.Polyline([ startPoint, endPoint ], {
		strokeColor : "blue",
		strokeWeight : 5,
		strokeOpacity : 0.8
	});
	
	this.arrow=new BMap.Polyline(myDrawArrowFunction(startPoint,endPoint,length,angleValue),
			{
		strokeColor : "blue",
		strokeWeight : 4,
		strokeOpacity : 0.7
	});
	
//	this.addContent=function(content){
//		this.line.addEventListener("click",function(){
//			
//			
//			
//		});
//	};
	
	this.remove=function(map){
		map.removeOverlay(this.line);
		map.removeOverlay(this.arrow);
	};
	
	this.hide=function(map){
		this.line.hide();
		this.arrow.hide();
	};
	this.show=function(map){
		this.line.show();
		this.arrow.show();
	};
	
	this.draw=function(map){
		map.addOverlay(this.line);
		map.addOverlay(this.arrow);
	};
	
	this.redraw=function(map,sPoint,ePoint){
		map.removeOverlay(this.line);
		map.removeOverlay(this.arrow);
		this.startPoint=sPoint;
		this.endPoint=ePoint;
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
	};
	
	
	
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