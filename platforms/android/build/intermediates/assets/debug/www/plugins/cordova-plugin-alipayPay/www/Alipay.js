
cordova.define('cordova-plugin-alipayPay.Alipay', function(require, exports, module) {
               var exec = require("cordova/exec");
               
               function Alipay() {};
               
               //支付宝支付
               Alipay.prototype.doPay = function (getversion,error,url,option) {

               exec(getversion, error, 'Alipay', 'doPay', [url,option]);
               };
               
               var loc = new Alipay();
               module.exports = loc;
               
               });

