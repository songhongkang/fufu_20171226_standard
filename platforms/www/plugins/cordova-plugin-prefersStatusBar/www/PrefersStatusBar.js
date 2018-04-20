
cordova.define('cordova-plugin-prefersStatusBar.PrefersStatusBar', function(require, exports, module) {
               var exec = require("cordova/exec");
               
               function PrefersStatusBar() {};
               
               //
               PrefersStatusBar.prototype.setstatusBarStyle = function (option) {
               
               exec(null, null, 'PrefersStatusBar', 'setstatusBarStyle', [option]);
               };
               
               
               PrefersStatusBar.prototype.testFromNativetoH5 = function (option) {
               
               exec(null, null, 'PrefersStatusBar', 'testFromNativetoH5', [option]);
               };
               
               PrefersStatusBar.prototype.popNative = function (option) {
               
               exec(null, null, 'PrefersStatusBar', 'popNative', [option]);
               };
               
               var loc = new PrefersStatusBar();
               module.exports = loc;
               
               });

