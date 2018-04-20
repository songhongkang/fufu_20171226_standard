package org.apache.cordova.shake;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.LocationManager;
import android.os.Binder;
import android.os.Build;
import android.os.Handler;
import android.os.Message;
import android.support.v4.content.ContextCompat;
import android.util.Log;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.citymobi.fufu.R;
import com.citymobi.fufu.utils.PermissionManage;
import com.citymobi.fufu.widgets.CustomDialog;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.shake.Mpa.SearchMapActivity;
import org.apache.cordova.shake.Mpa.ShowMapWithCoordinatActivity;
import org.apache.cordova.shake.Mpa.SingCountMapActivity;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

/**
 * Created by shangzh on 16/5/10.
 */
public class GetLocation extends CordovaPlugin implements AMapLocationListener {

    //定位
    private AMapLocationClient locationClient = null;
    private AMapLocationClientOption locationOption = null;

    private JSONObject locStr = null;
    private CallbackContext locationCallBack;
    private CallbackContext callBack;
    private CallbackContext checkLocationBack;

    private String selectedTitle = "";
    private String selectedLongitude = "";
    private String selectedLatitude = "";

    private String showMapSelectedTitle = "";
    private String showMapSelectedLongitude = "";
    private String showMapSelectedLatitude = "";
    private String showMapSelectedAddressDetail = "";

    private CordovaPlugin cordovaPlugin;

    private CustomDialog myDialog;

    public static final int REQUEST_CODE_SET_LOCK_PATTERN = 10001;

    @Override
    public boolean execute(String action, CordovaArgs args, final CallbackContext callbackContext) throws JSONException {

        callBack = callbackContext;
        cordovaPlugin = this;

        checkLocationBack = callbackContext;

        if ("location".equals(action)) {
            locationCallBack = callbackContext;
            this.getLocation();
        } else if ("showMap".equals(action)) {
            Intent i = new Intent(this.cordova.getActivity(), ShowMapActivity.class);
            i.putExtra("selectedTitle", showMapSelectedTitle);
            i.putExtra("selectedLongitude", showMapSelectedLongitude);
            i.putExtra("selectedLatitude", showMapSelectedLatitude);
            i.putExtra("selectedAddressDetail", showMapSelectedAddressDetail);
            i.putExtra("searchBound", "500");

            this.cordova.startActivityForResult(this, i, 0);
        } else if ("showMapWithCoordinate".equals(action)) {

            JSONObject info = args.getJSONObject(0);
            Intent a = new Intent(this.cordova.getActivity(), ShowMapWithCoordinatActivity.class);
            a.putExtra("latitude", info.getDouble("latitude"));
            a.putExtra("longitude", info.getDouble("longitude"));
            a.putExtra("address", info.getString("address"));
            //启动activity
            this.cordova.startActivityForResult(this, a, 0);
        } else if ("searchMap".equals(action)) {
            JSONObject searinfo = args.getJSONObject(0);
            Intent search = new Intent(this.cordova.getActivity(), SearchMapActivity.class);
            if (searinfo.getString("latitude").length() > 0 && searinfo.getString("longitude").length() > 0 && searinfo.getString("anotherName").length() > 0) {
                search.putExtra("latitude", searinfo.getDouble("latitude"));
                search.putExtra("longitude", searinfo.getDouble("longitude"));
                search.putExtra("anotherName", searinfo.getString("anotherName"));

            } else {
                search.putExtra("latitude", "");
                search.putExtra("longitude", "");
                search.putExtra("anotherName", "");
            }

            this.cordova.startActivityForResult(this, search, 0);

        } else if ("singCountMap".equals(action)) {
            JSONObject info = args.getJSONObject(0);
            Intent countMap = new Intent(this.cordova.getActivity(), SingCountMapActivity.class);
            countMap.putExtra("url", info.getString("url"));
            countMap.putExtra("target_date", info.getString("target_date"));

            this.cordova.startActivityForResult(this, countMap, 0);

        } else if ("checkCanLocation".equals(action)) {
            if (rightManagement()) {
                checkLocationBack.success(1);
            } else {
                checkLocationBack.success(0);
            }
        }
        return true;
    }

    public void getLocation() {
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
                    locationCallBack.success(locStr);
                    Log.e("location", locStr.toString());
                    break;
                //停止定位
                case Constants.MSG_LOCATION_STOP:
                    break;
                default:
                    break;
            }
        }

        ;
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

    //从地图接收选择的地址
    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent intent) {
        // 根据resultCode判断处理结果
        if (resultCode == Activity.RESULT_OK) {
            JSONObject jsonObject = new JSONObject();
            //errCode等于0代表定位成功，其他的为定位失败，具体的可以参照官网定位错误码说明
            try {
                if (intent.getStringExtra("type").equals("showmap")) {
                    showMapSelectedLongitude = intent.getStringExtra("longitude");
                    showMapSelectedLatitude = intent.getStringExtra("latitude");
                    showMapSelectedTitle = intent.getStringExtra("selectedTitle");
                    showMapSelectedAddressDetail = intent.getStringExtra("selectedAddressDetail");
                    String city = intent.getStringExtra("city");

                    jsonObject.put("longitude", showMapSelectedLongitude);
                    jsonObject.put("latitude", showMapSelectedLatitude);
                    jsonObject.put("address", showMapSelectedTitle);
                    jsonObject.put("city", city);
                    jsonObject.put("detailAddress", showMapSelectedAddressDetail);

                } else {

                    selectedLongitude = intent.getStringExtra("longitude");
                    selectedLatitude = intent.getStringExtra("latitude");

                    jsonObject.put("longitude", selectedLongitude);
                    jsonObject.put("latitude", selectedLatitude);
                    jsonObject.put("address", intent.getStringExtra("address"));
                    jsonObject.put("anotherName", intent.getStringExtra("anotherName"));

                }

            } catch (Exception e) {
                e.printStackTrace();
            }
            callBack.success(jsonObject);
        }
    }

    private boolean rightManagement() {

        boolean falg = false;
        if (Build.VERSION.SDK_INT >= 23) {
            if (ContextCompat.checkSelfPermission(this.cordova.getActivity(),
                    android.Manifest.permission.ACCESS_COARSE_LOCATION)
                    != PackageManager.PERMISSION_GRANTED) {
                PermissionManage.openPermissionHint(cordovaPlugin, R.string.dialog_title_gps, R.string.allow_gps_permission_please);

                falg = false;
            } else {
                falg = true;
            }
        } else {
            Object object = this.cordova.getActivity().getSystemService(Context.APP_OPS_SERVICE);
            if (object != null) {
                Class c = object.getClass();
                try {
                    Class[] cArg = new Class[3];
                    cArg[0] = int.class;
                    cArg[1] = int.class;
                    cArg[2] = String.class;
                    Method lMethod = c.getDeclaredMethod("checkOp", cArg);
                    int result = (Integer) lMethod.invoke(object, 1, Binder.getCallingUid(), this.cordova.getActivity().getPackageName());
                    if (result == 0) {
                        falg = true;
                        return falg;
                    } else {
                        PermissionManage.openAppSettingHint(cordovaPlugin, R.string.dialog_hint, R.string.allow_gps_permission_please);

                        falg = false;
                    }
                } catch (NoSuchMethodException e) {
                    e.printStackTrace();
                } catch (IllegalAccessException e) {
                    e.printStackTrace();
                } catch (IllegalArgumentException e) {
                    e.printStackTrace();
                } catch (InvocationTargetException e) {
                    e.printStackTrace();
                }
            } else {
                LocationManager locationManager = (LocationManager) this.cordova.getActivity().getSystemService(Context.LOCATION_SERVICE);
                // 通过GPS卫星定位
                boolean gps = locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER);
                if (gps) {
                    falg = true;
                } else {
                    PermissionManage.openAppSettingHint(cordovaPlugin, R.string.dialog_hint, R.string.open_gps_please);

                    falg = false;
                }
            }
        }
        return falg;
    }

}
