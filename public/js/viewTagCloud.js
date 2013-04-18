// Reference: http://www.goat1000.com/tagcanvas-options.php
// http://palagpat-coding.blogspot.com/2009/06/simple-tag-cloud-generator-in.html

var heightToWorkWith = document.height - document.getElementById('navbar').clientHeight - 30;
var canvas = document.getElementById('myCanvas');
canvas.height = heightToWorkWith;
canvas.width = document.width;

/*tags = {
	"JavaScript":17,
	"Conferences":2,
	".NET":1,
	"GeoWeb":7,
	"Site news":3,
	"snippets":5,
	"Dojo":16
};*/

function init_tagCloud(parentId) {
	var parentDiv = document.getElementById(parentId);
	if (parentDiv) {
		var cloud = makeCloud(tags,0,.5,3,' ',true);
		parentDiv.appendChild(cloud);
	}
}

window.onload = function() {
	try {
		init_tagCloud('tagList');
		TagCanvas.weight = true;
		TagCanvas.Start('myCanvas', 'tagList', {
			textColour: '#fff',
			outlineColour: '#007399',
			reverse: true,
			depth: 0.8,
			maxSpeed: 0.05
		});
	} catch(e) {
		document.getElementById('myCanvasContainer').style.display = 'none';
	}
};
