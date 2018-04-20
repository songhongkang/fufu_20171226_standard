//
//  ShowMapViewController.m
//  服服
//
//  Created by shangzh on 16/5/25.
//
//

#import "ShowMapViewController.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "MapModel.h"
#import "MapView.h"
#import "MJRefresh.h"
#import "Constan.h"

#import "ShowMapViewCell.h"

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ShowMapViewController () <AMapSearchDelegate,UITableViewDataSource,UITableViewDelegate,MapViewDelegate>
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic,strong) AMapPOIAroundSearchRequest *request;
@property (nonatomic,strong) UITableView *table;
//选择的地址
@property (nonatomic,copy) NSString *address;
@property (nonatomic,copy) NSString *detailAddress;
@property (nonatomic,strong) MJRefreshFooter *footer;

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) MapView *map;

//判断是否已添加选择的地址
@property (nonatomic,assign) BOOL isAddSelectAddress;

// 存放第一条附近所有的title
@property (nonatomic,strong) NSMutableArray *titleArray;

@end

@implementation ShowMapViewController

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self addRightButton];
    self.isAddSelectAddress = NO;
    self.page = 1;
    
//    NSDictionary *info = [NSBundle mainBundle].infoDictionary;
    // 取出 高德apikey
//    NSString *apikey = info[@"GDapikey"];
    
    self.map = [[MapView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300) andIsCanLocation:YES];
    self.map.zoomLevel = 15.1;
    self.map.delegate = self;
    self.map.isCanGetLocation = YES;
    self.map.isShowCallout = NO;
    
    if (self.selecteModel.latitude > 0 && self.selecteModel.longitude > 0) {
        
        [self addAnimotionWithLatitude:self.selecteModel.latitude Longitude:self.selecteModel.longitude];
        
    } else {
        self.map.isShowImage = YES;
    }
    
    [self.map.mapView setShowsUserLocation:NO];
    [self.view addSubview:self.map];
    
    //配置用户Key
//    [AMapSearchServices sharedServices].apiKey = apikey;
    
    //初始化检索对象
    self.search = [[AMapSearchAPI alloc] init];
    self.search.delegate = self;

    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, self.map.bounds.size.height, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-self.map.bounds.size.height)];
    self.table.dataSource = self;
    self.table.delegate = self;
    self.table.separatorColor = kUIColorFromRGB(0xe7e7e7);
//    [self.table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.table];
    
    if ([self.table respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.table setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.table respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.table setLayoutMargins:UIEdgeInsetsZero];
    }
    
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadMoreData方法）
    MJRefreshAutoGifFooter *footer = [MJRefreshAutoGifFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];

    // 设置文字
    [footer setTitle:@"加载中..." forState:MJRefreshStateIdle];
    [footer setTitle:@"加载中..." forState:MJRefreshStateRefreshing];
    [footer setTitle:@"没有更多数据" forState:MJRefreshStateNoMoreData];
    
    // 设置字体
    footer.stateLabel.font = [UIFont systemFontOfSize:14];
    
    // 设置颜色
    footer.stateLabel.textColor = kUIColorFromRGB(0x666666);
    self.table.mj_footer = footer;
}

- (void)addRightButton {
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
    [backBtn setTitle:@"确定" forState:UIControlStateNormal];
    [backBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(sure) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarBtn = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -12;
    self.navigationItem.rightBarButtonItems = @[negativeSpacer,leftBarBtn];
}

- (void)loadMoreData {
    self.page++;
    [self MapsearchRequestWithPage:self.page];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)MapsearchRequestWithPage:(NSInteger)page {
    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
    self.request = [[AMapPOIAroundSearchRequest alloc] init];
    self.request.location = [AMapGeoPoint locationWithLatitude:self.latitude longitude:self.longitude];
    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为：
    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
    self.request.types = @"商务住宅|政府机构及社会团体|交通设施服务";
    self.request.sortrule = 0;
    self.request.requireExtension = YES;
    self.request.offset = 20;
    self.request.radius = 500;
    self.request.page = page;
    //发起周边搜索
    [self.search AMapPOIAroundSearch: self.request];
}

//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    
    if(response.pois.count == 0)
    {
        [self.table.mj_footer endRefreshing];
        [self.table.mj_footer removeFromSuperview];
        return;
    }
    
#if 0
    for (AMapPOI *poi in response.pois) {
        
        if (![poi.name isEqualToString:self.selecteModel.title]) {
            MapModel *model = [[MapModel alloc] init];
            model.title = poi.name;
            model.longitude = poi.location.longitude;
            model.latitude = poi.location.latitude;
            model.detailAddress = [NSString stringWithFormat:@"%@%@%@%@",poi.province,poi.city,poi.district,poi.address];
            [self.dataSource addObject:model];
        } else {
            self.selecteModel.selected = YES;
            if (self.dataSource.count == 0) {
                [self.dataSource addObject:self.selecteModel];
            } else {
                [self.dataSource insertObject:self.selecteModel atIndex:0];
            }
            self.isAddSelectAddress = YES;
        }

        
    }
    
#endif

//    }

    
    for (AMapPOI *poi in response.pois)
    {
        MapModel *model = [[MapModel alloc] init];
        model.title = poi.name;
        model.longitude = poi.location.longitude;
        model.latitude = poi.location.latitude;
        model.detailAddress = [NSString stringWithFormat:@"%@%@%@%@",poi.province,poi.city,poi.district,poi.address];
        if (![poi.name isEqualToString:self.selecteModel.title])
        {
            [self.dataSource addObject:model];
        }
    }
    
    if (self.page == 1 && self.selecteModel.title.length != 0) {
        self.selecteModel.selected = YES;
        if (self.dataSource.count == 0) {
                [self.dataSource addObject:self.selecteModel];
        } else {
            [self.dataSource insertObject:self.selecteModel atIndex:0];
        }

    }
    [self.table.mj_footer endRefreshing];
    [self.table reloadData];
}

#pragma mark table datasource delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 52;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    // 设置需要的偏移量,这个UIEdgeInsets左右偏移量不要太大，不然会titleLabel也会便宜的。
    UIEdgeInsets inset = UIEdgeInsetsMake(0, 0, 0, 0);
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) { // iOS8的方法
        if (indexPath.row == self.dataSource.count-1) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        } else {
            [cell setLayoutMargins:inset];
        }
    }
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        if (indexPath.row == self.dataSource.count-1) {
            [cell setSeparatorInset:UIEdgeInsetsZero];
        } else {
            [cell setSeparatorInset:inset];
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MapModel *poi = self.dataSource[indexPath.row];
    ShowMapViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shwomapviewcell"];
    if (cell == nil) {
        cell = [ShowMapViewCell Item];
    }
    cell.isSelected = poi.selected;
    cell.address = poi.title;
    cell.detailAddress = poi.detailAddress;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     MapModel *poi = self.dataSource[indexPath.row];
     poi.selected = !poi.selected;
    if (poi.selected) {
        self.address = poi.title;
        self.latitude = poi.latitude;
        self.longitude = poi.longitude;
        self.detailAddress = poi.detailAddress;
        [self addAnimotionWithLatitude:poi.latitude Longitude:poi.longitude];
        
    } else {
        self.address = nil;
    }
    
    // 把除了选中的一行，都设置成false
     for (int i = 0; i < self.dataSource.count; i++) {
        if (i != indexPath.row) {
             poi = self.dataSource[i];
            if (poi.selected) {
                poi.selected = false;
            }
        }
     }
    
    
    [self.table reloadData];
}


#pragma mark - btnClick

- (void)back {
    [self.map stop];
    self.map = nil;
    self.map.delegate = nil;
    self.search = nil;
    self.search.delegate = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sure {
    
    [self.map stop];
    self.map = nil;
    self.map.delegate = nil;
    self.search = nil;
    self.search.delegate = nil;
  
    if (self.address != nil && self.latitude > 0 && self.longitude > 0) {
//         [self.delegate selectedAdderess:self.address latitude:self.latitude longitude:self.longitude city:self.map.city];
        [self.delegate selectedAdderess:self.address latitude:self.latitude longitude:self.longitude city:self.address detailAddress:self.detailAddress];
    } else if(self.selecteModel.selected){
        [self.delegate selectedAdderess:self.selecteModel.title latitude:self.selecteModel.latitude longitude:self.selecteModel.longitude city:self.address detailAddress:self.selecteModel.detailAddress];
    } else {
        [self.delegate selectedAdderess:nil latitude:0 longitude:0 city:self.address detailAddress:nil];
    }
   
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)completedUpdateLocation:(CLLocationCoordinate2D)location {
    if (self.latitude == 0 && self.longitude == 0) {
        self.latitude = self.map.firstLocation.latitude;
        self.longitude = self.map.firstLocation.longitude;
    }

    [self MapsearchRequestWithPage:self.page];
  
}


- (void)addAnimotionWithLatitude:(CGFloat)latitude Longitude:(CGFloat)longitude {
    [self.map.mapView removeAnnotations:self.map.mapView.annotations];
    
    MAPointAnnotation *mappoint = [[MAPointAnnotation alloc] init];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(latitude, longitude);
    mappoint.coordinate = coord;
    
    [self.map.mapView setCenterCoordinate:coord animated:YES];
    
    [self.map addAnimation:mappoint];
}


#pragma mark - 界面被消失
- (void)dealloc
{
    
    
}


@end
