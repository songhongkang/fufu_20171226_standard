
cordova.define('phonegap-plugin-blueTooth.BlueTooth.js', function(require, exports, module) {
               var exec = require("cordova/exec");
               
               function BlueTooth() {};
               
               BlueTooth.prototype.bleScan = function (getversion) {
               
               exec(getversion, null, 'BlueTooth', 'bleScan', []);
               };
               
               BlueTooth.prototype.setWifiConfig = function (getversion,option) {
               
               exec(getversion, null, 'BlueTooth', 'setWifiConfig', [option]);
               };
               
               BlueTooth.prototype.cancelBleConfig = function (getversion) {
               
               exec(getversion, null, 'BlueTooth', 'cancelBleConfig', []);
               };
               
               BlueTooth.prototype.checkBluetooth = function (getversion) {
               
               exec(getversion, null, 'BlueTooth', 'checkBluetooth', []);
               };
               BlueTooth.prototype.checkOneToOneConnect = function (getversion) {
               
               exec(getversion, null, 'BlueTooth', 'checkOneToOneConnect', []);
               };
               
               BlueTooth.prototype.bleScanWithSn = function (getversion,option) {
               
               exec(getversion, null, 'BlueTooth', 'bleScanWithSn', [option]);
               };
               
               BlueTooth.prototype.deleteSnSuccess = function () {
               
               exec(null, null, 'BlueTooth', 'deleteSnSuccess', []);
               };
               
               BlueTooth.prototype.setWiredNetworkConfig = function (option) {
               
               exec(null, null, 'BlueTooth', 'setWiredNetworkConfig', [option]);
               };
               
               
               var loc = new BlueTooth();
               module.exports = loc;
               
               });

