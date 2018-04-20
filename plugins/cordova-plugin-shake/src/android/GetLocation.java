package org.apache.cordova.shake;

import android.os.Handler;
import android.os.Message;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by shangzh on 16/5/10.
 */
public class GetLocation extends CordovaPlugin implements AMapLocationListener {

    //定位
    private AMapLocationClient locationClient = null;
    private AMapLocationClientOption locationOption = null;

    private JSONObject locStr = null;
    private CallbackContext callBack;


    @Override
    public boolean execute(String action, CordovaArgs args, final CallbackContext callbackContext) throws JSONException {

        callBack = callbackContext;
        if ("location".equals(action)) {
            this.getLocation();
        }
        return true;
    }

    public  void getLocation() {
        //定位
        locationClient = new AMapLocationClient(this.cordova.getActivity().getApplicationContext());
        locationOption = new AMapLocationClientOption();
        // 设置定位模式为高精度模式
        locationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy);
        // 设置定位监听
        locationClient.setLocationListener(this);
        locationOption.setOnceLocation(true);
        // 设置定位参数
        locationClient.setLocationOption(locationOption);
        // 启动定位
        locationClient.startLocation();

    }

    Handler mHandler = new Handler() {
        public void dispatchMessage(Message msg) {
            switch (msg.what) {
                //开始定位
                case Constants.MSG_LOCATION_START:
                    break;
                // 定位完成
                case Constants.MSG_LOCATION_FINISH:
                    AMapLocation loc = (AMapLocation) msg.obj;
                    try {
                        locStr = Constants.getLocation(loc);
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    callBack.success(locStr);
                    break;
                //停止定位
                case Constants.MSG_LOCATION_STOP:
                    break;
                default:
                    break;
            }
        };
    };

    // 定位监听
    @Override
    public void onLocationChanged(AMapLocation loc) {
        if (null != loc) {
            Message msg = mHandler.obtainMessage();
            msg.obj = loc;
            msg.what = Constants.MSG_LOCATION_FINISH;
            mHandler.sendMessage(msg);
        }
    }
}
