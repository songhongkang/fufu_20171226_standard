
cordova.define('cordova-plugin-signin.AutoSignIn', function(require, exports, module) {
               var exec = require("cordova/exec");
               function AutoSignIn() {};
               AutoSignIn.prototype.call_native = function(action, args, callback){
               ret = cordova.exec(callback, null, 'AutoSignIn', action, args)
               return ret
               }
               
               // 签到
               AutoSignIn.prototype.signIn = function () {
               exec(null, null, 'AutoSignIn', 'signIn', []);
               };
               
               // 设置sn列表
               AutoSignIn.prototype.setSnList = function (opt) {
               exec(null, null, 'AutoSignIn', 'setSnList', [opt]);
               };
               
               // 设置
               AutoSignIn.prototype.loginSuccess = function () {
               exec(null, null, 'AutoSignIn', 'loginSuccess', []);
               };
               
               //初始化蓝牙
               AutoSignIn.prototype.initBlePlugin = function () {
               exec(null, null, 'AutoSignIn', 'initBlePlugin', []);
               };
               
               //暂停蓝牙打卡
               AutoSignIn.prototype.pauseSignIn = function () {
               exec(null, null, 'AutoSignIn', 'pauseSignIn', []);
               };
               //重开蓝牙打开
               AutoSignIn.prototype.reopenSignIn = function () {
               exec(null, null, 'AutoSignIn', 'reopenSignIn', []);
               };
               // 测试方法
               AutoSignIn.prototype.test = function () {
               exec(null, null, 'AutoSignIn', 'test', []);
               };
               
               if(!window.plugins){
               window.plugins = {}
               }
               
               if(!window.plugins.autoSignIn){
               window.plugins.autoSignIn = new AutoSignIn();
               }
               
               module.exports = new AutoSignIn();
               
               });
