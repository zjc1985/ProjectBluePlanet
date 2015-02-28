function MarkerInfo(id){
	this.show=function(){
		$('#'+id).modal('show');
	};
	
	this.hide=function(){
		$('#'+id).modal('hide');
	}
	
	this.setTitle=function(str){
		$('#'+id).find('.markerInfoTitle').text(str);
	};
	
	this.setSubTitle=function(str){
		$('#'+id).find('.markerInfoSubTitle').text(str);
	};
	
	this.setDescription=function(str){
		$('#'+id).find('.markerInfoDescription').text(str);
	};
	
	this.setImageSlider=function(urls){
		$('#'+id).find('.carousel-indicators').empty();
		$('#'+id).find('.carousel-inner').empty();
		
		for(var i in urls){
			var indicatorsHtml;
			var imageItemHtml;
			if(i==0){
				indicatorsHtml="<li data-target='#myCarousel' data-slide-to='0' class='active'></li>";
				imageItemHtml="<div class='item active'>"+
					"<img src="+urls[i]+"></div>";
			}else{
				indicatorsHtml="<li data-target='#myCarousel' data-slide-to='"+i+"'></li>";
				imageItemHtml="<div class='item'>"+
					"<img src="+urls[i]+"></div>";
			}
			$('#'+id).find('.carousel-indicators').append(indicatorsHtml);
			$('#'+id).find('.carousel-inner').append(imageItemHtml);
		}
	};
};

function OvMarkerInfo(id){
	extend(OvMarkerInfo,MarkerInfo,this,[id]);
	this.showRoutineDetail=function(handler){
		$("#"+id).find(".showDetailBtn").click(handler);
	};
};

function MarkerEditor(id){
	
	this.confirmClick=function(handler){
		$("#"+id).find(".editConfirmBtn").click(handler);
	};
	
	this.deleteClick=function(handler){
		$("#"+id).find(".deleteBtn").click(handler);
	};
	
	this.setTitle=function(str){
		$('#'+id).find('.editTitle').val(str);	
	};
	this.getTitle=function(){
		return $('#'+id).find('.editTitle').val();
	};
	
	this.setCost=function(str){
		$('#'+id).find('.editCost').val(str);	
	};
	this.getCost=function(){
		return $('#'+id).find('.editCost').val();
	};
	
	this.setDesc=function(str){
		$('#'+id).find('.editDesc').val(str);	
	};
	this.getDesc=function(){
		return $('#'+id).find('.editDesc').val();
	};
	
	this.setUrls=function(urlArray){
		var str="";
		
		for(var i in urlArray){
			str=str+urlArray[i]+";\n";
		}
		$('#'+id).find('.editUrls').val(str);	
	};
	this.getUrls=function(){
		return $('#'+id).find('.editUrls').val().split(";");
	};
	
	this.setMaxSlideNum=function(maxNum){
		$('#'+id).find('.editSlideNum').empty();
		for(var i=1;i<maxNum+1;i++){
			$('#'+id).find('.editSlideNum').append("<option value='"+i+"'>"+i+"</option>");
		}	
	};
	
	this.getSlideNum=function(){
		return $('#'+id).find('.editSlideNum').val();
	};
	
	this.setSlideNum=function(slideNum){
		$('#'+id).find('.editSlideNum').val(slideNum);
	};
	
	this.setDropDownItems=function(items){
		$('#'+id).find('.dropdown-menu').empty();
		for(var i in items){
			var itemHtml="<li><a href='#'><img class='icon' src='"+items[i].url+"'>"+items[i].name+"</a></li>";
			$('#'+id).find('.dropdown-menu').append(itemHtml);
		}
		
		$('#'+id).find(".dropdown-menu li a").click(function(){
			  var selText = $(this).text();
			  var imgSrc=$(this).find('.icon').attr('src');
			  comboValue=selText;
			  $('#'+id).find('.selectedTxt').html(selText+' <span class="caret"></span>');
			  $('#'+id).find(".selectedImg").attr('src',imgSrc);
		});
	};
	
	this.setIconSelect=function(item){
		$('#'+id).find('.selectedTxt').html(item.name+' <span class="caret"></span>');
		$('#'+id).find(".selectedImg").attr('src',item.url);
	};
	
	this.getIconSelect=function(){
		return {url: $('#'+id).find(".selectedImg").attr('src'),
			name: $('#'+id).find('.selectedTxt').text().replace(/\s+/g,"")};
	}
};