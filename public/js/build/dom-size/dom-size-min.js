/* YUI 3.9.1 (build 5852) Copyright 2013 Yahoo! Inc. http://yuilibrary.com/license/ */
YUI.add("dom-size",function(a){a.mix(a.DOM,{setWidth:function(c,b){a.DOM._setSize(c,"width",b);},setHeight:function(c,b){a.DOM._setSize(c,"height",b);},_setSize:function(c,e,d){d=(d>0)?d:0;var b=0;c.style[e]=d+"px";b=(e==="height")?c.offsetHeight:c.offsetWidth;if(b>d){d=d-(b-d);if(d<0){d=0;}c.style[e]=d+"px";}}});},"3.9.1",{requires:["dom-core"]});