package org.apache.cordova.WifiInformation;

import android.content.Context;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;

import org.json.JSONObject;

/**
 * Created by shangzh on 16/6/21.
 */
public class WifiInfomaction {

    private WifiManager mWifi;

    public WifiInfomaction(Context context) {

        mWifi = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);

        //强制开启wifi
//        if (!mWifi.isWifiEnabled()) {
//            mWifi.setWifiEnabled(true);
//        }

    }

    public JSONObject getWifiInfo() {
        WifiInfo wifiInfo = mWifi.getConnectionInfo();

        JSONObject jsonObject = new JSONObject();
        //errCode等于0代表定位成功，其他的为定位失败，具体的可以参照官网定位错误码说明
        try {
            if (wifiInfo.getSSID().length() > 0 && wifiInfo.getBSSID().length() > 0) {
                jsonObject.put("wifiName",wifiInfo.getSSID());
                jsonObject.put("mac",wifiInfo.getBSSID());
                jsonObject.put("state","1");
            } else {
                jsonObject.put("wifiName","");
                jsonObject.put("mac","");
                jsonObject.put("state","1");
            }

        }catch (Exception e){
            e.printStackTrace();
        }
        return jsonObject;
    }
}
