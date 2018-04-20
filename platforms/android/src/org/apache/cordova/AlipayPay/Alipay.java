package org.apache.cordova.AlipayPay;

import android.annotation.SuppressLint;
import android.os.Handler;
import android.os.Message;
import android.text.TextUtils;

import com.alipay.sdk.app.PayTask;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.citymobi.fufu.net.volley.VolleyController;
import com.citymobi.fufu.net.volley.VolleyStringRequest;
import com.socks.library.KLog;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;

/**
 * Created by ZhongQuan on 17/1/6.
 * 支付宝
 */
public class Alipay extends CordovaPlugin {
    private static final int SDK_PAY_FLAG = 1;

    private CallbackContext callBack;

    @SuppressLint("HandlerLeak")
    private Handler mHandler = new Handler() {
        @SuppressWarnings("unused")
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case SDK_PAY_FLAG: {
                    @SuppressWarnings("unchecked")
                    PayResult payResult = new PayResult((Map<String, String>) msg.obj);
                    KLog.d(payResult.toString());
                    /**
                     对于支付结果，请商户依赖服务端的异步通知结果。同步通知结果，仅作为支付结束的通知。
                     */
                    String resultInfo = payResult.getResult();// 同步返回需要验证的信息
                    String resultStatus = payResult.getResultStatus();

                    try {
                        // 判断resultStatus 为9000则代表支付成功
                        if (TextUtils.equals(resultStatus, "9000")) {

                            JSONObject resultObj = new JSONObject(resultInfo);
                            JSONObject responseObj = resultObj.getJSONObject("alipay_trade_app_pay_response");

                            JSONObject backResult = new JSONObject();
                            backResult.put("trade_no", responseObj.get("trade_no"));
                            backResult.put("status", true);
                            backResult.put("out_trade_no", responseObj.get("out_trade_no"));
                            callBack.success(backResult);
                            KLog.d("执行完毕");
                        } else {
                            callBack.error("");
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    break;
                }
                default:
                    break;
            }
        }
    };

    /**
     * action 是唯一标识符，系统可根据不同的action进行不同的操作。
     * <p>
     * 　　args是页面传入的参数，支持String， JsonArray，CordovaArgs 等三种不同的类型。
     * <p>
     * 　　callbackcontext是系统的上下文，当完成操作后调用callbackcontext.success(支持多类型参数)方法，表示插件操作已完成，并把参数返还到页面。最终返回true代表插件执行成功，false代表执行失败
     */
    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        this.callBack = callbackContext;
        if (action.equals("doPay")) {
            String url = args.get(0).toString();
            JSONObject object = args.getJSONObject(1);

            Iterator<String> keyIter = object.keys();
            String key;
            String value;
            Map<String, String> valueMap = new HashMap<String, String>();
            while (keyIter.hasNext()) {
                key = keyIter.next();
                value = object.get(key).toString();
                valueMap.put(key, value);
            }
            getOrderInfo(valueMap, url);
        }
        return true;
    }

    /**
     * 获取支付信息
     *
     * @param map
     */
    private void getOrderInfo(Map<String, String> map, String url) {
//        String url = Constants.moduleAliPay;
//        String url = "http://120.24.153.50/cb_hrms/index.cfm?event=ionicAction.ionicAction.alipayGetSign&_DEVICE_TYPE=&_NOTIFICATION_TOKEN=&_PASS_WORD=12345678&_user_name=18680391411";

        VolleyStringRequest request = new VolleyStringRequest(VolleyStringRequest.Method.POST, url, map, new Response.Listener<String>() {
            @Override
            public void onResponse(String response) {

                try {
                    JSONObject object = new JSONObject(response);
                    String orderInfo = object.getString("fufuAlipay");
                    payForAliPay(orderInfo);
                } catch (JSONException e) {
                    e.printStackTrace();
                }
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {

            }
        });
        VolleyController.getInstance(this.cordova.getActivity()).addToQueue(request);
    }

    /**
     * 支付宝支付
     *
     * @param orderInfo
     */
    private void payForAliPay(final String orderInfo) {
        Runnable payRunnable = new Runnable() {

            @Override
            public void run() {
                PayTask alipay = new PayTask(Alipay.this.cordova.getActivity());
                Map<String, String> result = alipay.payV2(orderInfo, true);

                Message msg = new Message();
                msg.what = SDK_PAY_FLAG;
                msg.obj = result;
                mHandler.sendMessage(msg);
            }
        };

        Thread payThread = new Thread(payRunnable);
        payThread.start();
    }

    /**
     * 插件初始化时执行，用于定义service名称，cordovaInterface接口，CodovaWebView视图，CordovaPreferences 属性等值
     *
     * @param cordova
     * @param webView
     */
    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
    }

}
