
cordova.define('cordova-plugin-imageupload.ImageUpload', function(require, exports, module) {
               var exec = require("cordova/exec");
               
               function ImageUpload() {};
               
               //查看相册
               ImageUpload.prototype.getAssetImage = function (getversion) {
               exec(getversion, '', 'ImageUpload', 'getAssetImage', []);
               };
               
               //查看相册
               ImageUpload.prototype.upload = function (popoverOptions,getversion) {
               exec(getversion, '', 'ImageUpload', 'upload', [popoverOptions]);
               };
               
               var loc = new ImageUpload();
               module.exports = loc;
               
               });

