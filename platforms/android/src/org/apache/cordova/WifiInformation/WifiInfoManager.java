package org.apache.cordova.WifiInformation;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONException;

/**
 * Created by shangzh on 16/6/22.
 */
public class WifiInfoManager extends CordovaPlugin {

    @Override
    public boolean execute(String action, CordovaArgs args, final CallbackContext callbackContext) throws JSONException {
        WifiInfomaction wifi = new WifiInfomaction(this.cordova.getActivity().getApplicationContext());
        callbackContext.success(wifi.getWifiInfo());
        return true;
    }

}
