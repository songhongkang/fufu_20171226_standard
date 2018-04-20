package org.apache.cordova.shake.Mpa;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.os.Bundle;
import android.text.Editable;
import android.text.SpannableString;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.style.ForegroundColorSpan;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MotionEvent;
import android.view.View;
import android.view.inputmethod.InputMethodManager;
import android.widget.AdapterView;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.RadioGroup;
import android.widget.TextView;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.maps2d.AMap;
import com.amap.api.maps2d.CameraUpdateFactory;
import com.amap.api.maps2d.LocationSource;
import com.amap.api.maps2d.MapView;
import com.amap.api.maps2d.UiSettings;
import com.amap.api.maps2d.model.BitmapDescriptorFactory;
import com.amap.api.maps2d.model.CameraPosition;
import com.amap.api.maps2d.model.LatLng;
import com.amap.api.maps2d.model.Marker;
import com.amap.api.maps2d.model.MarkerOptions;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.core.PoiItem;
import com.amap.api.services.geocoder.GeocodeResult;
import com.amap.api.services.geocoder.GeocodeSearch;
import com.amap.api.services.geocoder.RegeocodeQuery;
import com.amap.api.services.geocoder.RegeocodeResult;
import com.amap.api.services.poisearch.PoiResult;
import com.amap.api.services.poisearch.PoiSearch;
import com.citymobi.fufu.R;
import com.citymobi.fufu.widgets.EditTextDialog;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshListView;

import java.util.LinkedList;
import java.util.List;

public class SearchMapActivity extends Activity implements LocationSource, AMapLocationListener,
        PoiSearch.OnPoiSearchListener,
        AdapterView.OnItemClickListener, AMap.InfoWindowAdapter, GeocodeSearch.OnGeocodeSearchListener {

    private AMap aMap;
    private MapView mapView;
    private OnLocationChangedListener mListener;
    private AMapLocationClient mlocationClient;
    private AMapLocationClientOption mLocationOption;

    private Bundle saveState;
    private Context mContext = null;

    private SearchMapListAdapter mAdapter = null;
    private LinkedList<SearchAddress> mData = null;
    private PullToRefreshListView mPullRefreshListView;

    private PoiResult poiResult; // poi返回的结果
    private int currentPage = 0;// 当前页面，从0开始计数
    private PoiSearch.Query query;// Poi查询条件类
    private PoiSearch poiSearch;// POI搜索

    private CustomerView view;

    private TextView cancel; //取消按钮
    private ImageView clearImg; //取消图片
    private ImageView back;  //返回按钮
    private TextView checkAddress; //使用当前地址

    private SearchAddress selecedAddress;  //搜索后选择的地点

    private CustomerSearchBar searchBar;

    private Marker curten;
    private MarkerOptions markerOption;

    private RadioGroup radioOption;

    //逆地下编码
    private GeocodeSearch geocoderSearch;

    private Boolean isMoveUp; //是否可以上移 true 可以

    private int count;//搜索的记录总数

    private String searchTitle;

    private LatLng curLat;  //要进行逆地理解析的经纬度

    private float density;

    private int screenWidth;

    private int screenHeight;

    //判断是否是在移动地图
    private Boolean isMove = true;

    private boolean isRefresh;  //判断是下拉加载还是搜索加载 true 搜索

    private String oldAnotherName = null; // 前端传过来的地址
    private double oldLatitude = 0.0;  //前端传过来的经纬度
    private double oldLongitude = 0.0; //前端传过来的经纬度

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_search_map);

        ActionBar bar = getActionBar();
        bar.hide();
        isMoveUp = true;
        selecedAddress = new SearchAddress();

        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);
        density = dm.density;

        back = (ImageView) findViewById(R.id.left_btn);
        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                close();
            }
        });

        //隐藏确定按钮
        final TextView selected = (TextView) findViewById(R.id.right_text);
        selected.setVisibility(View.INVISIBLE);

        //获取地图控件引用
        mapView = (MapView) findViewById(R.id.map);

        init();
        saveState = savedInstanceState;


        mContext = SearchMapActivity.this;

        mData = new LinkedList<SearchAddress>();

        mPullRefreshListView = (PullToRefreshListView) findViewById(R.id.pull_refresh_list);
        mPullRefreshListView.setMode(PullToRefreshBase.Mode.PULL_FROM_END);
        mPullRefreshListView.setVisibility(View.INVISIBLE);

        view = (CustomerView) findViewById(R.id.loadView);
        checkAddress = (TextView) findViewById(R.id.checkAddress);
        //使用当前地址
        checkAddress.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // 弹出提示框
                EditTextDialog.getEditTextDialog(mContext)
                        .setTitle(getResources().getString(R.string.set_signin_address_name))
                        .setMessage(TextUtils.isEmpty(selecedAddress.addressTitle) ? "" : selecedAddress.addressTitle)
                        .setConfirmListener(new View.OnClickListener() {
                            @Override
                            public void onClick(View v) {
                                selecedAddress.anotherName = ((EditText) v).getText().toString().trim();
                                backResult();
                            }
                        })
                        .show();

            }
        });

        searchBar = (CustomerSearchBar) findViewById(R.id.et_search);

        //取消
        cancel = (TextView) findViewById(R.id.cancel);
        cancel.setVisibility(View.INVISIBLE);
        cancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                clearImg.setVisibility(View.INVISIBLE);
                cancel.setVisibility(View.INVISIBLE);
                back.setVisibility(View.VISIBLE);
                mPullRefreshListView.setVisibility(View.INVISIBLE);
                searchBar.setText("");
                searchBar.moveToDown(density);
                isMoveUp = true; //可以上移
                InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                imm.hideSoftInputFromWindow(v.getWindowToken(), 0);

            }
        });

        //取消图片事件
        clearImg = (ImageView) findViewById(R.id.clearImg);
        clearImg.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                searchBar.setText("");

            }
        });

        searchBar.setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View v, MotionEvent event) {
                if (event.getAction() == MotionEvent.ACTION_DOWN) {
                    if (isMoveUp) {
                        searchBar.moveToUp(cancel, density);
                        isMoveUp = false;
                    }

                    back.setVisibility(View.INVISIBLE);
//                    cancel.setVisibility(View.VISIBLE);
                }
                return false;
            }
        });

        searchBar.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (s.length() > 0) {
                    clearImg.setVisibility(View.VISIBLE);
                } else {
                    clearImg.setVisibility(View.INVISIBLE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }

        });
        searchBar.setOnEditorActionListener(new TextView.OnEditorActionListener() {
            @Override
            public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {

                if (actionId == 0) {

                    if (v.getText().length() > 0) {

                        isRefresh = true;
                        InputMethodManager imm = (InputMethodManager) getSystemService(Context.INPUT_METHOD_SERVICE);
                        imm.hideSoftInputFromWindow(v.getWindowToken(), 0);
                        v.clearFocus();

                        if (view.getVisibility() != View.VISIBLE) {

                            view.setVisibility(View.VISIBLE);
                        }
                        if (checkAddress.getVisibility() == View.VISIBLE) {
                            checkAddress.setVisibility(View.INVISIBLE);
                        }
                        searchTitle = v.getText().toString();
                        if (mData.size() > 0) {
                            for (int k = mData.size() - 1; k >= 0; k--) {
                                mData.remove(k);
                            }
                        }

                        startSearch(searchTitle);

                    } else {
                        clearImg.setVisibility(View.VISIBLE);
                    }

                }
                return false;
            }
        });

        geocoderSearch = new GeocodeSearch(this);
        geocoderSearch.setOnGeocodeSearchListener(this);

        mAdapter = new SearchMapListAdapter((LinkedList<SearchAddress>) mData, mContext, getResources());
        mPullRefreshListView.setAdapter(mAdapter);
        mPullRefreshListView.setOnRefreshListener(new PullToRefreshBase.OnRefreshListener2<ListView>() {
            @Override
            public void onPullDownToRefresh(PullToRefreshBase<ListView> refreshView) {

            }

            @Override
            public void onPullUpToRefresh(PullToRefreshBase<ListView> refreshView) {
                //这里写上拉加载更多的任务
                isRefresh = false;
                currentPage++;
                startSearch(searchTitle);
            }
        });

        mPullRefreshListView.setOnItemClickListener(this);
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

    @Override
    protected void onStart() {
        super.onStart();
    }

    /**
     * 设置一些amap的属性
     */
    private void setUpMap() {
        aMap.setLocationSource(this);// 设置定位监听
        aMap.getUiSettings().setMyLocationButtonEnabled(true);// 设置默认定位按钮是否显示
        aMap.setMyLocationEnabled(true);// 设置为true表示显示定位层并可触发定位，false表示隐藏定位层并不可触发定位，默认是false
        aMap.setInfoWindowAdapter(this);
        // aMap.setMyLocationType()

        aMap.setOnMapTouchListener(new AMap.OnMapTouchListener() {
            @Override
            public void onTouch(MotionEvent motionEvent) {
                aMap.setOnCameraChangeListener(new AMap.OnCameraChangeListener() {
                    @Override
                    public void onCameraChange(CameraPosition cameraPosition) {

                    }

                    @Override
                    public void onCameraChangeFinish(CameraPosition cameraPosition) {

                        LatLonPoint latLonPoint = new LatLonPoint(cameraPosition.target.latitude, cameraPosition.target.longitude);
                        curLat = new LatLng(cameraPosition.target.latitude, cameraPosition.target.longitude);
                        selecedAddress.latitude = String.valueOf(cameraPosition.target.latitude);
                        selecedAddress.longitude = String.valueOf(cameraPosition.target.longitude);
                        getAddress(latLonPoint);
                    }
                });
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        //在activity执行onDestroy时执行mMapView.onDestroy()，实现地图生命周期管理
        mapView.onDestroy();
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
        deactivate();
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        //在activity执行onSaveInstanceState时执行mMapView.onSaveInstanceState (outState)，实现地图生命周期管理
        mapView.onSaveInstanceState(outState);
    }

    //添加mark
    private void addMark(String addressTitle, double latitude, double longitude) {
        LatLng latLng = new LatLng(Double.valueOf(latitude), Double.valueOf(longitude));

        markerOption = new MarkerOptions();
        markerOption.position(latLng);

        markerOption.title(addressTitle);
        markerOption.draggable(true);

        //获取屏幕宽高
        DisplayMetrics dm = new DisplayMetrics();
        getWindowManager().getDefaultDisplay().getMetrics(dm);
        screenWidth = dm.widthPixels;
        screenHeight = dm.heightPixels;

        markerOption.icon(BitmapDescriptorFactory.fromResource(R.drawable.address));
        curten = aMap.addMarker(markerOption);
        curten.setPositionByPixels(screenWidth / 2 + 8, screenHeight / 2 - 66);
        curten.showInfoWindow();

        aMap.moveCamera(CameraUpdateFactory.changeLatLng(latLng));
        aMap.moveCamera(CameraUpdateFactory.zoomTo(18));

        selecedAddress.addressTitle = addressTitle;
        selecedAddress.latitude = String.valueOf(latitude);
        selecedAddress.longitude = String.valueOf(longitude);

    }

    /**
     * 定位成功后回调函数
     */
    @Override
    public void onLocationChanged(AMapLocation amapLocation) {
        if (mListener != null && amapLocation != null) {
            if (amapLocation != null
                    && amapLocation.getErrorCode() == 0) {

                //在activity执行onCreate时执行mMapView.onCreate(savedInstanceState)，实现地图生命周期管理
                mapView.onCreate(saveState);

                //获取前端传值
                Intent intent = getIntent();
                //getXxxExtra方法获取Intent传递过来的数据
                if (intent.getStringExtra("anotherName") != null && intent.getStringExtra("anotherName").length() > 0) {
                    oldAnotherName = intent.getStringExtra("anotherName");
                    oldLatitude = intent.getDoubleExtra("latitude", 0.0);
                    oldLongitude = intent.getDoubleExtra("longitude", 0.0);
                    addMark(oldAnotherName, oldLatitude, oldLongitude);
                } else {
                    addMark(amapLocation.getAddress().replace(amapLocation.getProvince(), "").replace(amapLocation.getCity(), "").replace(amapLocation.getDistrict(), ""), amapLocation.getLatitude(), amapLocation.getLongitude());
                }
                mlocationClient.stopLocation();
                mlocationClient.onDestroy();
                mlocationClient = null;

            } else {
                String errText = "定位失败," + amapLocation.getErrorCode() + ": " + amapLocation.getErrorInfo();
                Log.e("AmapErr", errText);
            }

        }
    }

    /**
     * 激活定位
     */
    @Override
    public void activate(LocationSource.OnLocationChangedListener listener) {
        mListener = listener;
        if (mlocationClient == null) {
            mlocationClient = new AMapLocationClient(this);
            mLocationOption = new AMapLocationClientOption();
            //设置定位监听
            mlocationClient.setLocationListener(this);
            //设置为高精度定位模式
            mLocationOption.setLocationMode(AMapLocationClientOption.AMapLocationMode.Hight_Accuracy);
            //设置定位参数
            mlocationClient.setLocationOption(mLocationOption);
            // 此方法为每隔固定时间会发起一次定位请求，为了减少电量消耗或网络流量消耗，
            // 注意设置合适的定位时间的间隔（最小间隔支持为2000ms），并且在合适时间调用stopLocation()方法来取消定位请求
            // 在定位结束后，在合适的生命周期调用onDestroy()方法
            // 在单次定位情况下，定位无论成功与否，都无需调用stopLocation()方法移除请求，定位sdk内部会移除
            mlocationClient.startLocation();
        }
    }

    /**
     * 停止定位
     */
    @Override
    public void deactivate() {
        mListener = null;
        if (mlocationClient != null) {
            mlocationClient.stopLocation();
            mlocationClient.onDestroy();
        }
        mlocationClient = null;
    }

    private void close() {
        this.finish();
    }

    private void backResult() {
        //返回addressTitle
        //通过setResult绑定返回值
        Intent intent = new Intent();
        intent.putExtra("type", "searchmap");
        intent.putExtra("address", selecedAddress.addressTitle);
        intent.putExtra("latitude", selecedAddress.latitude);
        intent.putExtra("longitude", selecedAddress.longitude);
        intent.putExtra("anotherName", selecedAddress.anotherName);
        setResult(RESULT_OK, intent);
        //关闭该activity，把返回值传回到cordovaPlugin插件
        this.finish();
    }

    //搜索方法
    public void startSearch(String arg) {

        if (isRefresh) {
            view.setVisibility(View.VISIBLE);
            view.setBackgroundColor(Color.RED);
            mPullRefreshListView.setMode(PullToRefreshBase.Mode.PULL_FROM_END);
            currentPage = 0;
            query = new PoiSearch.Query(arg, "商务住宅|政府机构及社会团体|交通设施服务", "");
        } else {
            if (query == null) {
                query = new PoiSearch.Query(arg, "商务住宅|政府机构及社会团体|交通设施服务", "");
            }
        }

        query.setPageSize(20);// 设置每页最多返回多少条poiitem
        query.setPageNum(currentPage);//设置查询页码
        query.setCityLimit(true);

        if (isRefresh || poiSearch == null) {
            poiSearch = new PoiSearch(mContext, query);//初始化poiSearch对象
        } else {
            if (poiSearch == null) {
                poiSearch = new PoiSearch(mContext, query);//初始化poiSearch对象
            }
        }

        poiSearch.setOnPoiSearchListener(this);//设置回调数据的监听器
        poiSearch.searchPOIAsyn();//开始搜索

    }

    @Override
    public void onPoiSearched(PoiResult result, int rCode) {

        if (rCode == 1000) {

            if (result.getPois().size() == 0) {
                mPullRefreshListView.onRefreshComplete();
                mPullRefreshListView.setMode(PullToRefreshBase.Mode.DISABLED);
                return;
            }

            if (result != null && result.getQuery() != null) {// 搜索poi的结果

                view.setVisibility(View.INVISIBLE);
                mPullRefreshListView.setBackgroundColor(Color.WHITE);
                mPullRefreshListView.setVisibility(View.VISIBLE);
                checkAddress.setVisibility(View.INVISIBLE);

                if (result.getPois().size() > 0) {// 是否是同一条

                    List<PoiItem> poiItems = result.getPois();// 取得第一页的poiitem数据，页数从数字0开始

                    if (poiItems != null && poiItems.size() > 0) {
                        for (PoiItem p : poiItems) {
                            SearchAddress address = new SearchAddress();
                            address.addressTitle = p.getTitle();
                            address.descrip = p.getSnippet();
                            address.latitude = String.valueOf(p.getLatLonPoint().getLatitude());
                            address.longitude = String.valueOf(p.getLatLonPoint().getLongitude());
                            mData.add(address);
                        }
                    }
                }
            }
        }

        mPullRefreshListView.setAdapter(mAdapter);
        mPullRefreshListView.onRefreshComplete();

    }

    @Override
    public void onPoiItemSearched(PoiItem poiItem, int i) {

    }

    @Override
    public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
        isMoveUp = true;  //设置为可以上移
        isMove = false;
        selecedAddress = mData.get(position - 1);
        LatLng latLng = new LatLng(Double.parseDouble(selecedAddress.latitude), Double.parseDouble(selecedAddress.longitude));
        aMap.moveCamera(CameraUpdateFactory.changeLatLng(latLng));
        aMap.moveCamera(CameraUpdateFactory.zoomTo(18));
        if (null != curten) {
            curten.setPosition(latLng);
            curten.setTitle(selecedAddress.addressTitle);
            curten.setPositionByPixels(screenWidth / 2 + 8, screenHeight / 2 - 110);
            curten.showInfoWindow();
        }
        removeAll();

    }

    //只显示地图，隐藏其它
    public void removeAll() {
        mPullRefreshListView.setVisibility(View.INVISIBLE);
        view.setVisibility(View.INVISIBLE);
        cancel.setVisibility(View.INVISIBLE);
        searchBar.setText("");
        searchBar.moveToDown(density);
        back.setVisibility(View.VISIBLE);
        checkAddress.setVisibility(View.VISIBLE);
    }


    /**
     * 监听自定义infowindow窗口的infocontents事件回调
     */
    @Override
    public View getInfoContents(Marker marker) {
        View infoContent = getLayoutInflater().inflate(
                R.layout.custom_info_contents, null);
        render(marker, infoContent);
        return infoContent;
    }

    /**
     * 监听自定义infowindow窗口的infowindow事件回调
     */
    @Override
    public View getInfoWindow(Marker marker) {
        View infoWindow = getLayoutInflater().inflate(
                R.layout.custom_info_window, null);

        render(marker, infoWindow);
        return infoWindow;
    }


    /**
     * 自定义infowinfow窗口
     */
    public void render(Marker marker, View view) {
        String title = marker.getTitle();
        TextView titleUi = ((TextView) view.findViewById(R.id.title));
        if (title != null) {
            SpannableString titleText = new SpannableString(title);
            titleText.setSpan(new ForegroundColorSpan(Color.BLACK), 0,
                    titleText.length(), 0);
            titleUi.setTextSize(15);
            titleUi.setText(titleText);
        } else {
            titleUi.setText("");
        }
    }

    //逆地理编码解析
    @Override
    public void onRegeocodeSearched(RegeocodeResult result, int rCode) {
        if (rCode == 1000) {
            if (isMove) {
                if (result != null && result.getRegeocodeAddress() != null
                        && result.getRegeocodeAddress().getFormatAddress() != null) {
                    curten.setTitle(result.getRegeocodeAddress().getFormatAddress().replace(result.getRegeocodeAddress().getProvince(), "").replace(result.getRegeocodeAddress().getCity(), "").replace(result.getRegeocodeAddress().getDistrict(), ""));
                    curten.showInfoWindow();
                    selecedAddress.setAddressTitle(result.getRegeocodeAddress().getFormatAddress());

                }
            }
            isMove = true;
        }
    }

    @Override
    public void onGeocodeSearched(GeocodeResult geocodeResult, int i) {

    }

    /**
     * 响应逆地理编码
     */
    public void getAddress(final LatLonPoint latLonPoint) {
        RegeocodeQuery query = new RegeocodeQuery(latLonPoint, 1,
                GeocodeSearch.AMAP);// 第一个参数表示一个Latlng，第二参数表示范围多少米，第三个参数表示是火系坐标系还是GPS原生坐标系
        geocoderSearch.getFromLocationAsyn(query);// 设置同步逆地理编码请求
    }

}
