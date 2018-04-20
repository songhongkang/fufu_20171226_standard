
cordova.define('phonegap-plugin-barcodescanner.CustomerScanner', function(require, exports, module) {
               var exec = require("cordova/exec");
               
               function CustomerScanner() {};
               
               CustomerScanner.prototype.scan = function (getversion,option) {
               
               exec(getversion, null, 'CustomerScanner', 'scan', [option]);
               };
               
               CustomerScanner.prototype.close = function () {
               
               exec(null, null, 'CustomerScanner', 'close', []);
               };
               
               CustomerScanner.prototype.test = function () {
               
               exec(null, null, 'CustomerScanner', 'test', []);
               };
               
               CustomerScanner.prototype.blueToothScan = function (getversion) {
               
               exec(getversion, null, 'CustomerScanner', 'blueToothScan', []);
               };
               
               var loc = new CustomerScanner();
               module.exports = loc;
               
               });

