package org.apache.cordova.shake;

import com.amap.api.location.AMapLocation;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * Created by shangzh on 16/5/9.
 */
public class Constants {

    public static final int ERROR = 1001;// 网络异常
    public static final int ROUTE_START_SEARCH = 2000;
    public static final int ROUTE_END_SEARCH = 2001;
    public static final int ROUTE_BUS_RESULT = 2002;// 路径规划中公交模式
    public static final int ROUTE_DRIVING_RESULT = 2003;// 路径规划中驾车模式
    public static final int ROUTE_WALK_RESULT = 2004;// 路径规划中步行模式
    public static final int ROUTE_NO_RESULT = 2005;// 路径规划没有搜索到结果

    public static final int GEOCODER_RESULT = 3000;// 地理编码或者逆地理编码成功
    public static final int GEOCODER_NO_RESULT = 3001;// 地理编码或者逆地理编码没有数据

    public static final int POISEARCH = 4000;// poi搜索到结果
    public static final int POISEARCH_NO_RESULT = 4001;// poi没有搜索到结果
    public static final int POISEARCH_NEXT = 5000;// poi搜索下一页

    public static final int BUSLINE_LINE_RESULT = 6001;// 公交线路查询
    public static final int BUSLINE_id_RESULT = 6002;// 公交id查询
    public static final int BUSLINE_NO_RESULT = 6003;// 异常情况

    /**
     *  开始定位
     */
    public final static int MSG_LOCATION_START = 0;
    /**
     * 定位完成
     */
    public final static int MSG_LOCATION_FINISH = 1;
    /**
     * 停止定位
     */
    public final static int MSG_LOCATION_STOP= 2;


    /**
     * 根据定位结果返回定位信息的字符串
     * @param location
     * @return
     */
    public synchronized static String getLocationStr(AMapLocation location){
        if(null == location){
            return null;
        }
        StringBuffer sb = new StringBuffer();
        //errCode等于0代表定位成功，其他的为定位失败，具体的可以参照官网定位错误码说明
        if(location.getErrorCode() == 0){
            sb.append("定位成功" + "\n");
            sb.append("定位类型: " + location.getLocationType() + "\n");
            sb.append("经    度    : " + location.getLongitude() + "\n");
            sb.append("纬    度    : " + location.getLatitude() + "\n");
            sb.append("精    度    : " + location.getAccuracy() + "米" + "\n");
            sb.append("提供者    : " + location.getProvider() + "\n");

            if (location.getProvider().equalsIgnoreCase(
                    android.location.LocationManager.GPS_PROVIDER)) {
                // 以下信息只有提供者是GPS时才会有
                sb.append("速    度    : " + location.getSpeed() + "米/秒" + "\n");
                sb.append("角    度    : " + location.getBearing() + "\n");
                // 获取当前提供定位服务的卫星个数
                sb.append("星    数    : "
                        + location.getSatellites() + "\n");
            } else {
                // 提供者是GPS时是没有以下信息的
                sb.append("国    家    : " + location.getCountry() + "\n");
                sb.append("省            : " + location.getProvince() + "\n");
                sb.append("市            : " + location.getCity() + "\n");
                sb.append("城市编码 : " + location.getCityCode() + "\n");
                sb.append("区            : " + location.getDistrict() + "\n");
                sb.append("区域 码   : " + location.getAdCode() + "\n");
                sb.append("地    址    : " + location.getAddress() + "\n");
                sb.append("兴趣点    : " + location.getPoiName() + "\n");
            }
        } else {
            //定位失败
            sb.append("定位失败" + "\n");
            sb.append("错误码:" + location.getErrorCode() + "\n");
            sb.append("错误信息:" + location.getErrorInfo() + "\n");
            sb.append("错误描述:" + location.getLocationDetail() + "\n");
        }
        return sb.toString();
    }

    public synchronized static JSONObject getLocation(AMapLocation location) throws JSONException {
        if (null == location) {
            return null;
        }

        JSONObject jsonObject = new JSONObject();
        //errCode等于0代表定位成功，其他的为定位失败，具体的可以参照官网定位错误码说明
        if (location.getErrorCode() == 0) {
            jsonObject.put("longitude",String.valueOf(location.getLongitude()));
            jsonObject.put("latitude",String.valueOf(location.getLatitude()));
            jsonObject.put("address",location.getAddress());

        }
        return jsonObject;
    }
}
