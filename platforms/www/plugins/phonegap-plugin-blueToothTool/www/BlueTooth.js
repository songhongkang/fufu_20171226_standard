
cordova.define('phonegap-plugin-blueTooth.BlueTooth.js', function(require, exports, module) {
               var exec = require("cordova/exec");
               
               function BlueTooth() {};
               
               BlueTooth.prototype.bleScan = function (getversion,option) {
               
               exec(getversion, null, 'BlueTooth', 'bleScan', [option]);
               };
               
               BlueTooth.prototype.setWifiConfig = function (getversion,option) {
               
               exec(getversion, null, 'BlueTooth', 'setWifiConfig', [option]);
               };
               
               BlueTooth.prototype.cancelBleConfig = function (getversion,) {
               
               exec(getversion, null, 'BlueTooth', 'cancelBleConfig', []);
               };
               
               var loc = new BlueTooth();
               module.exports = loc;
               
               });

