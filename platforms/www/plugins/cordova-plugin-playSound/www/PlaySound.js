
cordova.define('cordova-plugin-playSound.PlaySound', function(require, exports, module) {
               var exec = require("cordova/exec");
               
               function PlaySound() {};
               
               PlaySound.prototype.play = function (getversion,option) {
               
               exec(getversion, null, 'PlaySound', 'play', [option]);
               };

               
               var loc = new PlaySound();
               module.exports = loc;
               
               });

