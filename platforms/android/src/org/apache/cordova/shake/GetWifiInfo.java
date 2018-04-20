package org.apache.cordova.shake;

import android.app.Activity;
import android.content.Context;
import android.net.wifi.WifiInfo;
import android.net.wifi.WifiManager;
import android.os.Bundle;

/**
 * Created by shangzh on 16/6/21.
 */
public class GetWifiInfo extends Activity {

    private WifiManager mWifi;
    private String WifiMac;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

//        setContentView(R.layout.main);

        mWifi = (WifiManager) getSystemService(Context.WIFI_SERVICE);

        if (!mWifi.isWifiEnabled()) {
            mWifi.setWifiEnabled(true);
        }

        WifiInfo wifiInfo = mWifi.getConnectionInfo();

        if ((WifiMac = wifiInfo.getMacAddress()) == null) {
            WifiMac = "No Wifi Device";
        }

        StringBuffer sb = new StringBuffer();
        sb.append("\n获取BSSID属性（所连接的WIFI设备的MAC地址）：" + wifiInfo.getBSSID());
//      sb.append("getDetailedStateOf()  获取客户端的连通性：");
        sb.append("\n\n获取SSID 是否被隐藏："+ wifiInfo.getHiddenSSID());
        sb.append("\n\n获取IP 地址：" + wifiInfo.getIpAddress());
        sb.append("\n\n获取连接的速度：" + wifiInfo.getLinkSpeed());
        sb.append("\n\n获取Mac 地址（手机本身网卡的MAC地址）：" + WifiMac);
        sb.append("\n\n获取802.11n 网络的信号：" + wifiInfo.getRssi());
        sb.append("\n\n获取SSID（所连接的WIFI的网络名称）：" + wifiInfo.getSSID());
        sb.append("\n\n获取具体客户端状态的信息：" + wifiInfo.getSupplicantState());

    }
}
