webshim.register("usermedia-core",function(a,b,c,d){"use strict";var e=b.prefixed("srcObject",d.createElement("video")),f=function(){navigator.getUserMedia=navigator[b.prefixed("getUserMedia",navigator)]};if("srcObject"!=e){var g=!(!c.URL||!URL.createObjectURL);b.defineNodeNamesProperty(["audio","video"],"srcObject",{prop:{get:function(){return this[e]||null},set:function(b){e?a.prop(this,e,b):a.prop(this,"src",g?URL.createObjectURL(b):b)}}})}b.ready(b.modules["usermedia-shim"].loaded?"usermedia-api":"usermedia-shim",f)});