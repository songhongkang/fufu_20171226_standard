
cordova.define('cordova-plugin-networkinfo.Network', function(require, exports, module) {
               var exec = require("cordova/exec");
               
               function Network() {};
               
               Network.prototype.wifiInfo = function (getversion,error) {
               exec(getversion, error, 'Network', 'wifiInfo', []);
               };
               
               var loc = new Network();
               module.exports = loc;
               
               });

