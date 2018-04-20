package org.apache.cordova.shake.Mpa;

import android.app.ActionBar;
import android.app.Activity;
import android.app.DatePickerDialog;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.DisplayMetrics;
import android.view.View;
import android.widget.Button;
import android.widget.DatePicker;
import android.widget.FrameLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import com.amap.api.maps2d.AMap;
import com.amap.api.maps2d.CameraUpdateFactory;
import com.amap.api.maps2d.MapView;
import com.amap.api.maps2d.UiSettings;
import com.amap.api.maps2d.model.BitmapDescriptorFactory;
import com.amap.api.maps2d.model.LatLng;
import com.amap.api.maps2d.model.LatLngBounds;
import com.amap.api.maps2d.model.Marker;
import com.amap.api.maps2d.model.MarkerOptions;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.JsonArrayRequest;
import com.android.volley.toolbox.Volley;
import com.citymobi.fufu.R;
import com.citymobi.fufu.widgets.CustomDialog;

import org.json.JSONArray;
import org.json.JSONException;

import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.LinkedList;
import java.util.List;
import java.util.Locale;

public class SingCountMapActivity extends Activity implements AMap.OnMarkerClickListener {

    private AMap aMap;
    private MapView mapView;
//    private OnLocationChangedListener mListener;
//    private AMapLocationClient mlocationClient;
//    private AMapLocationClientOption mLocationOption;

    private LinkedList<SingCountModel> list;

    private Bundle saveState;

    private SimpleDateFormat fmtDate = new SimpleDateFormat("yyyy/MM/dd");

    private Calendar dateAndTime = Calendar.getInstance(Locale.CHINA);

    private Button leftBtn;

    private Button rightBtn;

    private TextView titleBtn;

    private ImageView back_btn;

    private ImageView back;  //返回按钮

    //时间
    private TextView timeView;
    //地址
    private TextView addressView;

    private FrameLayout frameLayout;

    //年
    private int year;
    //月
    private int month;
    //日
    private int day;
    //当前月份的天数
    private int monthDay;

    //当前显示时间
    private String currentTime;

    private String url;
    private String target_date;

    private Marker curten;
    private MarkerOptions markerOption;

    //记录已选择的marker
    private int selectedMark = 0;

    private LinearLayout mLoadingLayout;

    private float density;
    private CustomDialog mDialog;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_sing_count_map);

        ActionBar bar = getActionBar();
        bar.hide();

        back = (ImageView) findViewById(R.id.back_btn);
        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                close();
            }
        });

        mLoadingLayout = (LinearLayout) findViewById(R.id.fullscreen_loading_indicator);
        mLoadingLayout.setVisibility(View.VISIBLE);

        Intent intent = getIntent();
        //getXxxExtra方法获取Intent传递过来的数据
        url = intent.getStringExtra("url");
        target_date = intent.getStringExtra("target_date");

        //获取地图控件引用
        mapView = (MapView) findViewById(R.id.singmap);

        init();
        saveState = savedInstanceState;

        leftBtn = (Button) findViewById(R.id.left_btn);
        rightBtn = (Button) findViewById(R.id.right_btn);
        titleBtn = (TextView) findViewById(R.id.title_btn);

        //time
        timeView = (TextView) findViewById(R.id.timeView);
        addressView = (TextView) findViewById(R.id.addressView);
        frameLayout = (FrameLayout) findViewById(R.id.toolbar);

        titleBtn.setText(target_date.replace("-", "/"));
        titleBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (frameLayout.getVisibility() == View.VISIBLE) {
                    frameLayout.setVisibility(View.INVISIBLE);
                }

                currentTime = titleBtn.getText().toString();
                year = Integer.parseInt(currentTime.substring(0, 4));
                month = Integer.parseInt(currentTime.substring(5, 7));
                day = Integer.parseInt(currentTime.substring(8, 10));

                dateAndTime.set(Calendar.YEAR, year);
                dateAndTime.set(Calendar.MONTH, month - 1);
                dateAndTime.set(Calendar.DAY_OF_MONTH, day);

                DatePickerDialog dateDlg = new DatePickerDialog(SingCountMapActivity.this,
                        d,
                        dateAndTime.get(Calendar.YEAR),
                        dateAndTime.get(Calendar.MONTH),
                        dateAndTime.get(Calendar.DAY_OF_MONTH));
                dateDlg.show();
            }
        });

        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);
        density = dm.density;

        titleBtn.setTextSize(14);

        leftBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mLoadingLayout.getVisibility() == View.VISIBLE) {
                    return;
                } else {
                    mLoadingLayout.setVisibility(View.VISIBLE);
                }

                getCurrentTime();

                if (day - 1 > 0) {
                    day -= 1;
                    if (day - 1 >= 9) {
                        if (month >= 10) {
                            titleBtn.setText(year + "/" + month + "/" + day);
                        } else {
                            titleBtn.setText(year + "/0" + month + "/" + day);
                        }
                    } else {
                        if (month >= 10) {
                            titleBtn.setText(year + "/" + month + "/0" + day);
                        } else {
                            titleBtn.setText(year + "/0" + month + "/0" + day);
                        }
                    }
                } else {
                    month -= 1;
                    if (month < 1) {
                        year -= 1;
                        month = 12;
                    }
                    getMonthDay();
                    day = monthDay;
                    if (month >= 10) {
                        titleBtn.setText(year + "/" + month + "/" + day);
                    } else {
                        titleBtn.setText(year + "/0" + month + "/" + day);
                    }
                }

                target_date = titleBtn.getText().toString().replace("/", "-");
                lodaDataWithTime(target_date);
            }
        });

        rightBtn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (mLoadingLayout.getVisibility() == View.VISIBLE) {
                    return;
                } else {
                    mLoadingLayout.setVisibility(View.VISIBLE);
                }

                getCurrentTime();

                if (day + 1 <= monthDay) {
                    day = day + 1;
                    checkDay(day, month);
                } else {

                    if (month + 1 <= 12) {
                        month = month + 1;
                        if (month < 10) {
                            titleBtn.setText(year + "/0" + month + "/0" + 1);
                        } else {
                            titleBtn.setText(year + "/" + month + "/0" + 1);
                        }
                    } else {
                        year += 1;
                        month = 1;
                        day = 1;
                        checkDay(day, month);
                    }
                }

                target_date = titleBtn.getText().toString().replace("/", "-");
                lodaDataWithTime(target_date);
            }
        });

        getCurrentTime();
        mapView.onCreate(saveState);
        lodaDataWithTime(target_date);
    }

    /**
     * 请求数据
     *
     * @param time
     */
    private void lodaDataWithTime(String time) {
        mLoadingLayout.setVisibility(View.VISIBLE);

        RequestQueue requestQueue = Volley.newRequestQueue(getApplicationContext());
        String LOGIN_URL = url + "&target_date=" + time;
        list = new LinkedList<SingCountModel>();
        JsonArrayRequest jsonObjectRequest = new JsonArrayRequest(Request.Method.GET, LOGIN_URL, (String) null, new Response.Listener<JSONArray>() {
            @Override
            public void onResponse(JSONArray jsonObject) {
                try {
                    if (list.size() > 0) {
                        list.clear();
                    }
                    aMap.clear();

                    int count = jsonObject.length();

                    if (count > 0) {

                        for (int i = 0; i < count; i++) {

                            SingCountModel model = new SingCountModel();
                            model.latitude = jsonObject.getJSONObject(i).getString("latitude");
                            model.longitude = jsonObject.getJSONObject(i).getString("longitude");
                            model.time = jsonObject.getJSONObject(i).getString("time");
                            model.addressTitle = jsonObject.getJSONObject(i).getString("location");

                            if (!TextUtils.isEmpty(model.latitude) && !TextUtils.isEmpty(model.longitude)) {
                                list.add(model);
                                if (i == 0) {
                                    LatLng marker1 = new LatLng(Double.valueOf(model.latitude), Double.valueOf(model.longitude));
                                    aMap.moveCamera(CameraUpdateFactory.changeLatLng(marker1));
                                }
                                addMark(i, Double.valueOf(model.latitude), Double.valueOf(model.longitude));
                            }
                        }

//                        LatLngBounds bounds = new LatLngBounds.Builder()
//                                .include(new LatLng(Double.valueOf(list.get(0).latitude),Double.valueOf(list.get(0).longitude))).include(new LatLng(Double.valueOf(list.get(1).latitude),Double.valueOf(list.get(1).longitude))).build();
                        LatLngBounds.Builder builder = new LatLngBounds.Builder();

                        for (int b = 0; b < list.size(); b++) {
                            SingCountModel model = list.get(b);
                            builder.include(new LatLng(Double.valueOf(model.latitude), Double.valueOf(model.longitude)));
                        }

                        LatLngBounds bounds = builder.build();
                        // 移动地图，所有marker自适应显示。LatLngBounds与地图边缘10像素的填充区域
                        aMap.moveCamera(CameraUpdateFactory.newLatLngBounds(bounds, 10));
                    } else {
                        mDialog = CustomDialog.getCustomDialog(SingCountMapActivity.this);
                        mDialog.setInfo(R.string.dialog_hint, R.string.no_signin_record);
                        mDialog.setConfirmText(R.string.confirm);
                        mDialog.setListenerYes(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                mDialog.hideDialog();
                            }
                        });
                        mDialog.showDialog();
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                    mLoadingLayout.setVisibility(View.INVISIBLE);
                }
                mLoadingLayout.setVisibility(View.INVISIBLE);
            }
        }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError volleyError) {
                mLoadingLayout.setVisibility(View.INVISIBLE);
            }
        });
        requestQueue.add(jsonObjectRequest);
    }

    //判断月份和日期是否小于10
    private void checkDay(int day, int month) {
        if (month < 10) {
            if (day < 10) {
                titleBtn.setText(year + "/0" + month + "/0" + day);
            } else {
                titleBtn.setText(year + "/0" + month + "/" + day);
            }
        } else {
            if (day < 10) {
                titleBtn.setText(year + "/" + month + "/0" + day);
            } else {
                titleBtn.setText(year + "/" + month + "/" + day);
            }
        }

    }

    private void getCurrentTime() {
        currentTime = titleBtn.getText().toString();
        year = Integer.parseInt(currentTime.substring(0, 4));
        month = Integer.parseInt(currentTime.substring(5, 7));
        day = Integer.parseInt(currentTime.substring(8, 10));

        getMonthDay();
    }

    private void getMonthDay() {

        switch (month) {
            case 2:
                if (year % 4 == 0) {
                    monthDay = 29;
                } else {
                    monthDay = 28;
                }
                break;
            case 4:
                monthDay = 30;
                break;
            case 6:
                monthDay = 30;
                break;
            case 9:
                monthDay = 30;
                break;
            case 11:
                monthDay = 30;
                break;
            default:
                monthDay = 31;
                break;
        }

    }

    /**
     * 初始化AMap对象
     */
    private void init() {
        if (aMap == null) {
            aMap = mapView.getMap();

            UiSettings uiSettings = aMap.getUiSettings();
            uiSettings.setZoomControlsEnabled(false);

            setUpMap();
        }
    }

    /**
     * 设置一些amap的属性
     */
    private void setUpMap() {
        aMap.setOnMarkerClickListener(this);
    }

    @Override
    protected void onStart() {
        super.onStart();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //在activity执行onDestroy时执行mMapView.onDestroy()，实现地图生命周期管理
        mapView.onDestroy();
        if (mDialog != null) {
            mDialog.hideDialog();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        //在activity执行onResume时执行mMapView.onResume ()，实现地图生命周期管理
        mapView.onResume();
    }

    @Override
    protected void onPause() {
        super.onPause();
        //在activity执行onPause时执行mMapView.onPause ()，实现地图生命周期管理
        mapView.onPause();
//        deactivate();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        //在activity执行onSaveInstanceState时执行mMapView.onSaveInstanceState (outState)，实现地图生命周期管理
        mapView.onSaveInstanceState(outState);
    }

    //添加mark
    private void addMark(int i, double latitude, double longitude) {
        LatLng latLng = new LatLng(Double.valueOf(latitude), Double.valueOf(longitude));

        markerOption = new MarkerOptions();
        markerOption.period(i + 1);

        markerOption.position(latLng);

        markerOption.draggable(true);

        markerOption.icon(BitmapDescriptorFactory.fromResource(R.drawable.address_small));

        curten = aMap.addMarker(markerOption);
        curten.showInfoWindow();

    }

    //当点击DatePickerDialog控件的设置按钮时，调用该方法
    DatePickerDialog.OnDateSetListener d = new DatePickerDialog.OnDateSetListener() {
        @Override
        public void onDateSet(DatePicker view, int year, int monthOfYear,
                              int dayOfMonth) {
            //修改日历控件的年，月，日
            //这里的year,monthOfYear,dayOfMonth的值与DatePickerDialog控件设置的最新值一致
            dateAndTime.set(Calendar.YEAR, year);
            dateAndTime.set(Calendar.MONTH, monthOfYear);
            dateAndTime.set(Calendar.DAY_OF_MONTH, dayOfMonth);
            //将页面TextView的显示更新为最新时间
            upDateTime();

            if (mLoadingLayout.getVisibility() == View.VISIBLE) {
                return;
            } else {
                mLoadingLayout.setVisibility(View.VISIBLE);
            }
        }
    };

    private void upDateTime() {
        titleBtn.setText(fmtDate.format(dateAndTime.getTime()));
        target_date = titleBtn.getText().toString().replace("/", "-");
        lodaDataWithTime(target_date);
    }

    @Override
    public boolean onMarkerClick(Marker marker) {
        int i = marker.getPeriod();

        if (frameLayout.getVisibility() == View.INVISIBLE) {
            frameLayout.setVisibility(View.VISIBLE);
        }
        SingCountModel model = list.get(i - 1);

        timeView.setText(model.time);
        addressView.setText(model.addressTitle);

        List<Marker> mars = aMap.getMapScreenMarkers();
        for (Marker mr : mars) {
            mr.setIcon(BitmapDescriptorFactory.fromResource(R.drawable.address_small));
        }

        selectedMark = i;

        marker.setIcon(BitmapDescriptorFactory.fromResource(R.drawable.address));

        return false;
    }

    private void close() {
        if (mLoadingLayout.getVisibility() != View.VISIBLE) {
            this.finish();
        }
    }


}
