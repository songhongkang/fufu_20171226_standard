cordova.define('cordova-plugin-localStorage.NativeDataStorage', function(require, exports, module) {
               var exec = require("cordova/exec");
               
               function NativeDataStorage() {};
               
               NativeDataStorage.prototype.getLocalStorageVal = function (getversion) {
               exec(getversion, null, 'NativeDataStorage', 'getLocalStorageVal', []);
               };
               
               NativeDataStorage.prototype.setLocalStorageVal = function (key, value) {
               exec(null, null, 'NativeDataStorage', 'setLocalStorageVal', [key, value]);
               };

               var loc = new NativeDataStorage();
               module.exports = loc;
               
               });
