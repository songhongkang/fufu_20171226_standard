package org.apache.cordova.shake;

import android.app.ActionBar;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ImageView;
import android.widget.ListView;
import android.widget.TextView;

import com.amap.api.location.AMapLocation;
import com.amap.api.location.AMapLocationClient;
import com.amap.api.location.AMapLocationClientOption;
import com.amap.api.location.AMapLocationListener;
import com.amap.api.maps2d.AMap;
import com.amap.api.maps2d.CameraUpdateFactory;
import com.amap.api.maps2d.LocationSource;
import com.amap.api.maps2d.MapView;
import com.amap.api.maps2d.model.BitmapDescriptorFactory;
import com.amap.api.maps2d.model.LatLng;
import com.amap.api.maps2d.model.Marker;
import com.amap.api.maps2d.model.MarkerOptions;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.core.PoiItem;
import com.amap.api.services.poisearch.PoiResult;
import com.amap.api.services.poisearch.PoiSearch;
//import com.citymobi.fufu.R;
import com.citymobi.fufu.R;
import com.handmark.pulltorefresh.library.PullToRefreshBase;
import com.handmark.pulltorefresh.library.PullToRefreshListView;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class ShowMapActivity extends Activity implements LocationSource, AMapLocationListener, PoiSearch.OnPoiSearchListener, AdapterView.OnItemClickListener {

    private AMap aMap;
    private MapView mapView;
    private OnLocationChangedListener mListener;
    private AMapLocationClient mlocationClient;
    private AMapLocationClientOption mLocationOption;

    private AMapLocation location;

    private PullToRefreshListView mPullRefreshListView;

    private AddressAdapter mAdapter = null;
    private List<Address> mData = null;
    private Context mContext = null;

    private PoiSearch.Query query;
    private PoiSearch poiSearch;

    private Bundle saveState;
    //当前完整地址
    private String addressTitle;

    //搜索半径
    private int searchBound;

    private int count;
    private int page;

    //已选择的地址名称（不包含省市）
    private Address selectedAddress;
    //省市区
    private String city;

    private TextView loadTextView;

    //刷新不插入数据
    private Boolean isFlash = false;

    private Marker curten;
    private MarkerOptions markerOption;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_show_map);

        selectedAddress = new Address();
        Intent intent = getIntent();
        //getXxxExtra方法获取Intent传递过来的数据
        String search = intent.getStringExtra("searchBound");

        if (!intent.getStringExtra("selectedTitle").isEmpty()) {
            selectedAddress.addressTitle = intent.getStringExtra("selectedTitle");
        } else {
            selectedAddress.addressTitle = "";
        }

        if (!intent.getStringExtra("selectedLatitude").isEmpty()) {
            selectedAddress.latitude = intent.getStringExtra("selectedLatitude");
            selectedAddress.longitude = intent.getStringExtra("selectedLongitude");
        } else {
            selectedAddress.latitude = "";
            selectedAddress.longitude = "";
        }

        if (!TextUtils.isEmpty(intent.getStringExtra("selectedAddressDetail"))) {
            selectedAddress.addressDetail = intent.getStringExtra("selectedAddressDetail");
        } else {
            selectedAddress.addressDetail = "";
        }

        if (search == null || search.length() == 0) {
            searchBound = 500;
        } else {
            searchBound = Integer.parseInt(search);
        }

        ActionBar bar = getActionBar();
        bar.hide();

        ImageView back = (ImageView) findViewById(R.id.left_btn);
        back.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                close();
            }
        });

        TextView selected = (TextView) findViewById(R.id.right_text);
        selected.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                backResult();
            }
        });

        mData = new LinkedList<Address>();
        //获取地图控件引用

        mapView = (MapView) findViewById(R.id.map);

        init();
        saveState = savedInstanceState;
        query = new PoiSearch.Query("", "商务住宅|政府机构及社会团体|交通设施服务", "");
        mContext = ShowMapActivity.this;
        bindViews();

        mAdapter = new AddressAdapter((LinkedList<Address>) mData, mContext, getResources());
        mPullRefreshListView.setAdapter(mAdapter);
    }

    private void bindViews() {
        // 得到控件
        mPullRefreshListView = (PullToRefreshListView) findViewById(R.id.pull_refresh_list);
        mPullRefreshListView.setMode(PullToRefreshBase.Mode.PULL_FROM_END);

        loadTextView = (TextView) findViewById(R.id.loading);

        mPullRefreshListView.setOnRefreshListener(new PullToRefreshBase.OnRefreshListener2<ListView>() {
            @Override
            public void onPullDownToRefresh(PullToRefreshBase<ListView> refreshView) {

            }

            @Override
            public void onPullUpToRefresh(PullToRefreshBase<ListView> refreshView) {
                //这里写上拉加载更多的任务
                page++;
                poiSearchData(page, location);
//                mAdapter.notifyDataSetChanged();
                // Call onRefreshComplete when the list has been refreshed
//                mPullRefreshListView.onRefreshComplete();
                isFlash = true;
            }
        });
        mPullRefreshListView.setOnItemClickListener(this);
    }

    @Override
    public void onPoiSearched(PoiResult poiResult, int i) {

        if (poiResult.getPois().size() == 0) {
            mPullRefreshListView.onRefreshComplete();
            mPullRefreshListView.setMode(PullToRefreshBase.Mode.DISABLED);
            return;
        }

        ArrayList<PoiItem> poiItems = poiResult.getPois();

        if (!selectedAddress.addressTitle.isEmpty() && !isFlash) {
            Address newAddress = new Address();
            newAddress.selected = true;
            newAddress.addressTitle = selectedAddress.addressTitle;
            newAddress.latitude = selectedAddress.latitude;
            newAddress.longitude = selectedAddress.longitude;
            newAddress.addressDetail = selectedAddress.addressDetail;
            mData.add(newAddress);
        }

        count = poiResult.getPois().size();

        for (PoiItem poiItem : poiItems) {
            if (!poiItem.getTitle().equals(selectedAddress.addressTitle)) {
                Address address = new Address();
                address.setAddressTitle(poiItem.getTitle());
                address.setSelected(false);
                address.setLatitude(String.valueOf(poiItem.getLatLonPoint().getLatitude()));
                address.setLongitude(String.valueOf(poiItem.getLatLonPoint().getLongitude()));
                address.setAddressDetail(poiItem.getProvinceName() + poiItem.getCityName() + poiItem.getAdName() + poiItem.getSnippet());
                mData.add(address);
            }
        }

//        for (int a = 0; a < count; a++) {
//            if (!poiResult.getPois().get(a).getTitle().equals(selectedAddress.addressTitle)) {
//                Address address = new Address();
//                address.setAddressTitle(poiResult.getPois().get(a).getTitle());
//                address.setSelected(false);
//                address.setLatitude(String.valueOf(poiResult.getPois().get(a).getLatLonPoint().getLatitude()));
//                address.setLongitude(String.valueOf(poiResult.getPois().get(a).getLatLonPoint().getLongitude()));
//                mData.add(address);
//            }
//        }

        loadTextView.setText("");
//        loadTextView.setVisibility(1);
//        mPullRefreshListView.setAdapter(mAdapter);
        mAdapter.notifyDataSetChanged();
        mPullRefreshListView.onRefreshComplete();
    }

    @Override
    public void onPoiItemSearched(PoiItem poiItem, int i) {

    }

    /**
     * 初始化AMap对象
     */
    private void init() {
        if (aMap == null) {
            aMap = mapView.getMap();
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

                if (selectedAddress.latitude.length() > 0 && selectedAddress.longitude.length() > 0) {
                    addMark(Double.valueOf(selectedAddress.latitude), Double.valueOf(selectedAddress.longitude));
                } else {
                    addMark(amapLocation.getLatitude(), amapLocation.getLongitude());
                }

                location = amapLocation;

                city = amapLocation.getProvince() + amapLocation.getCity() + amapLocation.getDistrict() + amapLocation.getStreet();

                page = 0;
                poiSearchData(page, location);
                mlocationClient.stopLocation();
            } else {
                String errText = "定位失败," + amapLocation.getErrorCode() + ": " + amapLocation.getErrorInfo();
                Log.e("AmapErr", errText);
            }
        }
    }

    /**
     * 检索周边POI
     *
     * @param pageNum
     * @param amapLocation
     */
    private void poiSearchData(int pageNum, AMapLocation amapLocation) {
        query.setPageSize(20);// 设置每页最多返回多少条poiitem
        query.setPageNum(pageNum);//设置查询页码
        if (poiSearch == null) {
            poiSearch = new PoiSearch(this, query);//初始化poiSearch对象
            poiSearch.setBound(new PoiSearch.SearchBound(new LatLonPoint(amapLocation.getLatitude(),
                    amapLocation.getLongitude()), searchBound));//设置周边搜索的中心点以及区域
            poiSearch.setOnPoiSearchListener(this);//设置数据返回的监听器
        }
        poiSearch.searchPOIAsyn();

    }

    /**
     * 激活定位
     */
    @Override
    public void activate(OnLocationChangedListener listener) {
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

    @Override
    public void onItemClick(AdapterView<?> adapterView, View view, int i, long l) {
        List<Address> alist = new LinkedList<Address>();
        alist.addAll(mData);

        Address address = alist.get(i - 1);

        if (address.selected) {
            address.selected = false;
            view.setBackgroundColor(0xffffff);
            selectedAddress.latitude = "";
            selectedAddress.longitude = "";
            selectedAddress.addressTitle = "";
            selectedAddress.addressDetail = "";

        } else {
            address.selected = true;
            view.setBackgroundColor(0xf6f6f6);

            selectedAddress.latitude = address.getLatitude();
            selectedAddress.longitude = address.getLongitude();
            selectedAddress.addressTitle = address.getAddressTitle();
            selectedAddress.addressDetail = address.getAddressDetail();

            aMap.clear();
            addMark(Double.valueOf(address.getLatitude()), Double.valueOf(address.getLongitude()));
        }
        for (int a = 0; a < alist.size(); a++) {
            Address ad = alist.get(a);
            if (a != (i - 1)) {
                if (ad.selected) {
                    alist.get(a).selected = false;
                }
            }
        }
        mAdapter.notifyDataSetChanged();
        mAdapter.upDateItemView(view, i - 1);
    }

    private void close() {
        this.finish();
    }

    private void backResult() {
        //返回addressTitle
        //通过setResult绑定返回值
        Intent intent = new Intent();
        intent.putExtra("type", "showmap");
        intent.putExtra("city", city);
        intent.putExtra("latitude", selectedAddress.latitude);
        intent.putExtra("longitude", selectedAddress.longitude);
        intent.putExtra("selectedTitle", selectedAddress.addressTitle);
        intent.putExtra("selectedAddressDetail", selectedAddress.addressDetail);
        setResult(RESULT_OK, intent);
        //关闭该activity，把返回值传回到cordovaPlugin插件
        this.finish();
    }


    //添加mark
    private void addMark(double latitude, double longitude) {
        LatLng latLng = new LatLng(Double.valueOf(latitude), Double.valueOf(longitude));

        markerOption = new MarkerOptions();
        markerOption.position(latLng);
        markerOption.draggable(true);

        //获取屏幕宽高
//        DisplayMetrics dm = new DisplayMetrics();
//        getWindowManager().getDefaultDisplay().getMetrics(dm);
//        screenWidth = dm.widthPixels;
//        screenHeight = dm.heightPixels;

        markerOption.icon(BitmapDescriptorFactory.fromResource(R.drawable.address));
        curten = aMap.addMarker(markerOption);
//        curten.setPositionByPixels(screenWidth/2+8,screenHeight/2-66);
        curten.showInfoWindow();

        aMap.moveCamera(CameraUpdateFactory.changeLatLng(latLng));
        aMap.moveCamera(CameraUpdateFactory.zoomTo(18));

    }
}
