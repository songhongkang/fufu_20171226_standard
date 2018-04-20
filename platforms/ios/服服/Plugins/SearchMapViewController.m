//
//  SearchMapViewController.m
//  服服
//
//  Created by shangzh on 16/6/15.
//

#import <MAMapKit/MAMapKit.h>
#import "SearchMapViewController.h"
#import "MapView.h"
#import <AMapSearchKit/AMapSearchKit.h>
#import "MJRefresh.h"
#import "MapModel.h"
#import "CustomerImageView.h"
#import "MTSearchBar.h"
#import "AddressViewCell.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CDVAlertEditView.h"
#import "Constan.h"


#define screenWidth [UIScreen mainScreen].bounds.size.width
#define screenHeight [UIScreen mainScreen].bounds.size.height

#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SearchMapViewController ()<UISearchBarDelegate,AMapSearchDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,CDVAlertEditViewDelegate>

@property (nonatomic,strong) MapView *mapView;

@property (nonatomic,strong) UISearchBar *customSearchBar;

@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic, strong) AMapSearchAPI *search;

@property (nonatomic,strong) AMapPOIKeywordsSearchRequest *request;

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) UITableView *table;

@property (nonatomic,strong) CustomerImageView *custView;

@property (nonatomic,strong) UIView *searchView;

@property (nonatomic,strong) UIButton *cancelBtn;

@property (nonatomic,strong) MTSearchBar *searchBar;

@property (nonatomic,assign) bool isClear;

@property (nonatomic,strong) UIButton *setAddress;

//搜索后选中的地址
@property (nonatomic,strong) MapModel *selectedModel;

//要使用的地址
@property (nonatomic,strong) MapModel *resultModel;

@property (nonatomic,strong) UIImageView *imageView;

@property (nonatomic,copy) NSString *keyword;

@property (nonatomic,strong) UIImageView *corImageView;



// 气泡的label


@end

@implementation SearchMapViewController

- (NSMutableArray *)dataSource {
    if (_dataSource == nil) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mapView = [[MapView alloc] initWithFrame:CGRectMake(0, 30, screenWidth, screenHeight) andIsCanLocation:YES];
    self.mapView.zoomLevel = 13.1;
//    self.mapView.searchMapSelectModel = self.oldAddress;
    
    if (self.oldAddress.anotherName == nil || self.oldAddress.anotherName.length == 0 ) {
        self.oldAddress.anotherName = @"定位中";
        self.mapView.isShowLocation = YES;
    } else {
        self.mapView.isShowLocation = NO;
    }

    self.mapView.centerCoor = CLLocationCoordinate2DMake(self.oldAddress.latitude, self.oldAddress.longitude);
//    [self.mapView.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.oldAddress.latitude, self.oldAddress.longitude) animated:YES];
    [self.mapView.mapView setShowsUserLocation:NO];
    self.mapView.isCanGetLocation = YES;
    [self.view addSubview:self.mapView];
    
    CGSize size = [self boundingRectWithSize:CGSizeMake(screenWidth, 30) text:self.oldAddress.anotherName];
    
    if (size.width > screenWidth-40) {
        self.custView = [[CustomerImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth-40, 35)];
    } else {
        self.custView = [[CustomerImageView alloc] initWithFrame:CGRectMake(0, 0, size.width+25, 35)];
    }
    
    self.custView.addressTitle = self.oldAddress.anotherName;
    self.custView.center = CGPointMake(self.mapView.center.x, self.mapView.center.y-42);
    
    [self.mapView addSubview:self.custView];
    
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"address_small"]];
    self.imageView.center = CGPointMake(self.custView.center.x, self.custView.center.y+32);
    [self.mapView addSubview:self.imageView];
    
    self.corImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"searchmap_arrow"]];
    self.corImageView.center = CGPointMake(self.custView.center.x, self.custView.center.y+20.5);
    [self.mapView addSubview:self.corImageView];
    
    [self addSearchBar];
    
    self.resultModel = [[MapModel alloc] init];
    
    if (self.oldAddress.latitude != 0) {
        self.resultModel = self.oldAddress;
        self.mapView.searchMapSelectModel = self.oldAddress;
    }
    
    //添加经纬度改变的监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocationInfo:) name:@"changeLocation" object:nil];
    
    _setAddress = [[UIButton alloc] initWithFrame:CGRectMake(0, screenHeight - 80, screenWidth, 50)];
    [_setAddress setTitle:@"使用当前地址" forState:UIControlStateNormal];
    [_setAddress setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [_setAddress.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [_setAddress setBackgroundColor:[UIColor whiteColor]];
    [_setAddress addTarget:self action:@selector(getLocationAddress) forControlEvents:UIControlEventTouchUpInside];
    [self.mapView addSubview:_setAddress];
    
}

- (void)addSearchBar {
    _searchView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, screenWidth, 50)];
    _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth-56, 10, 40, 30)];
    [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [_cancelBtn.titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    _cancelBtn.hidden = YES;
    [_cancelBtn addTarget:self action:@selector(clearSearch) forControlEvents:UIControlEventTouchUpInside];
    [_searchView addSubview:_cancelBtn];
    
    _searchBar = [[MTSearchBar alloc] initWithFrame:CGRectMake(12, 10, screenWidth-24, 30)];
    _searchBar.delegate = self;
    
    // 每次textFiled 有字符串录入，触发textFieldDidChange方法
    [_searchBar addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [_searchView addSubview:_searchBar];
    
    [self.mapView addSubview:_searchView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [ super viewWillDisappear:YES];
    [self.mapView stop];
}

#pragma mark searBar移动

- (void)searchBarMoveToTop {
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.navigationController.view setFrame:CGRectMake(0, -40, screenWidth, screenHeight+40)];
        [_searchView setFrame:CGRectMake(0, 30, screenWidth, 50)];
        _searchView.backgroundColor = kUIColorFromRGB(0x6ab9fe);
        [_searchBar setFrame:CGRectMake(12, 10, screenWidth-68, 30)];
        
        [_cancelBtn setFrame:CGRectMake(screenWidth - 48, 10, 40, 30)];
        _cancelBtn.hidden = NO;
        
        [self.setAddress setFrame:CGRectMake(0, screenHeight+40, screenWidth, 50)];
        
        self.navigationItem.titleView.hidden = YES;
        for (UIBarButtonItem *item in self.navigationItem.leftBarButtonItems) {
            UIView *view = item.customView;
            view.hidden = YES;
        }
    }];
}

- (void)searchBarMoveRecover {
    
    [self.setAddress setFrame:CGRectMake(0, screenHeight-80, screenWidth, 50)];
    [UIView animateWithDuration:0.5 animations:^{
        
        [self.navigationController.view setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        self.navigationItem.titleView.hidden = NO;
        for (UIBarButtonItem *item in self.navigationItem.leftBarButtonItems) {
            UIView *view = item.customView;
            view.hidden = NO;
        }
        //移动后将table置为空
        [self.table removeFromSuperview];
        self.table = nil;
        [_searchView setFrame:CGRectMake(0, 30, screenWidth, 50)];
        [_searchBar setFrame:CGRectMake(12, 10, screenWidth-24, 30)];
        _searchView.backgroundColor = [UIColor clearColor];
        _cancelBtn.hidden = YES;
        //        [self.mapView setFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        
        _searchBar.text = @"";
    }];
    
}

- (void)clearSearch {
    self.page = 0;
    [self searchBarMoveRecover];
    [self.searchBar resignFirstResponder];
    self.searchBar.text = @"";
    
}

#pragma mark TextfiledDelegate

-(void)textFieldDidChange :(UITextField *)theTextField{
    NSLog( @"text changed: %@", theTextField.text);
    
    self.page = 0;
    self.keyword = theTextField.text;
    
//    if (self.dataSource != nil) {
//        [self.dataSource removeAllObjects];
//    }
    
    NSDictionary *info = [NSBundle mainBundle].infoDictionary;
    // 取出 高德apikey
    NSString *apikey = info[@"GDapikey"];
    //配置用户Key
    //初始化检索对象
    //    [AMapSearchServices sharedServices].apiKey = apikey;
    
    if (self.search == nil) {
        self.search = [[AMapSearchAPI alloc] init];
    }
    self.search.delegate = self;
    //       [self MapsearchRequestWithPage:self.page keyWord:searchText];
    [self loadMoreData];
    
    if (self.table == nil) {
        self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 104, screenWidth, screenHeight-64)];
        
        self.table.separatorColor = kUIColorFromRGB(0xe7e7e7);
        
        self.table.dataSource = self;
        self.table.delegate = self;
        [self.view addSubview:self.table];
    }
    
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
    footer.stateLabel.font = [UIFont systemFontOfSize:17];
    
    // 设置颜色
    footer.stateLabel.textColor = [UIColor blackColor];
    self.table.mj_footer = footer;
    
//    [self.searchBar resignFirstResponder];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self clearSearch];
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self searchBarMoveToTop];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
#if 0
    self.page = 0;
    self.keyword = textField.text;
    
    if (self.dataSource != nil) {
        [self.dataSource removeAllObjects];
    }
    
    NSDictionary *info = [NSBundle mainBundle].infoDictionary;
    // 取出 高德apikey
    NSString *apikey = info[@"GDapikey"];
    //配置用户Key
    //初始化检索对象
    //    [AMapSearchServices sharedServices].apiKey = apikey;

    if (self.search == nil) {
        self.search = [[AMapSearchAPI alloc] init];
    }
    self.search.delegate = self;
    //       [self MapsearchRequestWithPage:self.page keyWord:searchText];
    [self loadMoreData];
    
    if (self.table == nil) {
        self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 104, screenWidth, screenHeight-64)];
        
        self.table.separatorColor = kUIColorFromRGB(0xe7e7e7);
        
        self.table.dataSource = self;
        self.table.delegate = self;
        [self.view addSubview:self.table];
    }
    
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
    footer.stateLabel.font = [UIFont systemFontOfSize:17];
    
    // 设置颜色
    footer.stateLabel.textColor = [UIColor blackColor];
    self.table.mj_footer = footer;
    
    [self.searchBar resignFirstResponder];
    
#endif

    [self.searchBar resignFirstResponder];
    return YES;
}

#pragma mark map search delegate
- (void)loadMoreData {
    self.page++;
    //构造AMapPOIAroundSearchRequest对象，设置周边请求参数
    self.request = [[AMapPOIKeywordsSearchRequest alloc] init];
    self.request.keywords = self.keyword;
    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    // POI的类型共分为20种大类别，分别为：
    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
    self.request.types = @"商务住宅|政府机构及社会团体|交通设施服务";
    self.request.sortrule = 0;
    self.request.requireExtension = YES;
    self.request.offset = 20;
    self.request.cityLimit = YES;
    self.request.page = self.page;
    //发起周边搜索
    [self.search AMapPOIKeywordsSearch: self.request];
}

//实现POI搜索对应的回调函数
- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (self.dataSource != nil &&
        self.page == 1) {
        [self.dataSource removeAllObjects];
    }
    if(response.pois.count == 0)
    {
        [self.table.mj_footer endRefreshing];
        [self.table.mj_footer removeFromSuperview];
//        return;
    }
    for (AMapPOI *poi in response.pois) {
        MapModel *model = [[MapModel alloc] init];
        model.searchAddress = poi.address;
        model.title = poi.name;
        model.longitude = poi.location.longitude;
        model.latitude = poi.location.latitude;
        [self.dataSource addObject:model];
    }
    
    [self.table.mj_footer endRefreshing];
    [self.table reloadData];
}

#pragma mark tabelview delegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath

{
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
    MapModel *map = self.dataSource[indexPath.row];
    AddressViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addresscell"];
    
    if (cell == nil) {
        cell = [AddressViewCell Item];
    }
    cell.model = map;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MapModel *model = self.dataSource[indexPath.row];
    
    CLLocationCoordinate2D corrd = CLLocationCoordinate2DMake(model.latitude, model.longitude);
    
    [self searchBarMoveRecover];
    
    [self.mapView.mapView setCenterCoordinate:corrd animated:YES];
    
    
//   self.custView.addressTitle =    [NSString stringWithFormat:@"%@(%@)",model.title,model.searchAddress];

    
    
#if 0
//    self.custView.addressTitle = model.title;

    // 改变custView的宽高 以下修改
    CGSize size = [self boundingRectWithSize:CGSizeMake(screenWidth, 30) text:[NSString stringWithFormat:@"%@(%@)",model.title,model.searchAddress]];
    
    if (size.width < screenWidth - 40) {
        [self.custView setFrame:CGRectMake((screenWidth - size.width-20)/2, self.mapView.center.y-64, size.width+20 +5, self.custView.frame.size.height)];
//        [self.custView.titleLabel setFrame:CGRectMake(10, 7.5, size.width+2 +5, 20)];
        self.custView.titleLabel.frame = CGRectMake(0, 0, self.custView.bounds.size.width, self.custView.frame.size.height);

    } else {
        [self.custView setFrame:CGRectMake(10, self.custView.frame.origin.y, screenWidth-20, self.custView.frame.size.height)];
//        [self.custView.titleLabel setFrame:CGRectMake(10, 7.5, screenWidth-40, 20)];
        self.custView.titleLabel.frame = CGRectMake(0, 0, self.custView.bounds.size.width, self.custView.frame.size.height);
    }
    [self.corImageView setCenter:CGPointMake(self.custView.center.x, self.custView.center.y+20.5)];
    [self.imageView setFrame:CGRectMake(self.custView.center.x-14, self.custView.center.y+20, 28, 28)];
    // 以上修改时间 7.18
#endif
    
    
    
    [self.table removeFromSuperview];
    self.table = nil;
    
    self.selectedModel = model;
    self.resultModel = model;
//    [self updateLocationInfo:nil];
    //shk添加
    [self.searchBar resignFirstResponder];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

#pragma mark NSNotification
-(void)updateLocationInfo:(NSNotification *)notification{
    NSDictionary *userInfo=notification.userInfo;
    NSString *address = nil;
    
    if (self.selectedModel.searchAddress != nil) {
        address = [NSString stringWithFormat:@"%@(%@)",self.selectedModel.title,self.selectedModel.searchAddress];
        self.resultModel.title = address;
        self.resultModel.latitude = self.selectedModel.latitude;
        self.resultModel.longitude = self.selectedModel.longitude;
    } else {
        address =userInfo[@"address"];
        self.resultModel.title = address;
        self.resultModel.latitude = [userInfo[@"latitude"] floatValue];
        self.resultModel.longitude = [userInfo[@"longitude"] floatValue];
    }
    self.custView.addressTitle = address;
    CGSize size = [self boundingRectWithSize:CGSizeMake(screenWidth, 30) text:address];
    
    if (size.width < screenWidth - 40) {
        [self.custView setFrame:CGRectMake((screenWidth - size.width-20)/2, self.mapView.center.y-64, size.width+20 +5, self.custView.frame.size.height)];
//        [self.custView.titleLabel setFrame:CGRectMake(10, 7.5, size.width+2 +5, 20)];
        self.custView.titleLabel.frame = CGRectMake(0, 0, self.custView.bounds.size.width, self.custView.frame.size.height);

    } else {
        [self.custView setFrame:CGRectMake(10, self.custView.frame.origin.y, screenWidth-20, self.custView.frame.size.height)];
//        [self.custView.titleLabel setFrame:CGRectMake(10, 7.5, screenWidth-40, 20)];
        self.custView.titleLabel.frame = CGRectMake(0, 0, self.custView.bounds.size.width, self.custView.frame.size.height);
    }
    [self.corImageView setCenter:CGPointMake(self.custView.center.x, self.custView.center.y+20.5)];
    [self.imageView setFrame:CGRectMake(self.custView.center.x-14, self.custView.center.y+20, 28, 28)];
    //防止搜索后在移动地址不改，对selectModel重置
    self.selectedModel = nil;
}

-(void)dealloc{
    //移除监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGSize)boundingRectWithSize:(CGSize)size text:(NSString *)text
{
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:16]};
    CGSize retSize = [text boundingRectWithSize:size
                                        options:\
                      NSStringDrawingTruncatesLastVisibleLine |
                      NSStringDrawingUsesLineFragmentOrigin |
                      NSStringDrawingUsesFontLeading
                                     attributes:attribute
                                        context:nil].size;
    return retSize;
}

- (void)getLocationAddress {
    NSString *editTitle = @"";
    if (self.selectedModel.title != nil) {
        editTitle = self.selectedModel.title;
    } else {
        if (self.resultModel.title == nil || self.resultModel.title.length == 0) {
            self.resultModel.title = self.oldAddress.anotherName;
        }
        editTitle = self.resultModel.title;
    }
    
    CDVAlertEditView *alert = [[CDVAlertEditView alloc] initWithTitle:@"当前地址标识" txtFiedl:editTitle okButtonTitle:@"确定" cancelButtonTItle:@"取消" delegate:self];
    [alert showInView:self.view];
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"当前地址标识" message:@"" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//    alert.delegate = self;
//    alert.alertViewStyle=UIAlertViewStylePlainTextInput;
//    
//    [alert show];
    
}

- (void)popUpView:(CDVAlertEditView *)view accepted:(BOOL)accept inputText:(NSString *)text {
    [view removeFromSuperview];
    if (accept) {
        self.resultModel.anotherName = text;
        if (self.resultModel.title == nil || self.resultModel.title.length == 0) {
            self.resultModel.title = self.oldAddress.anotherName;
        }
        [_delegate selectedAddress:self.resultModel];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self.mapView stop];
        self.mapView = nil;
    }
}

#pragma mark UIAlert Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        UITextField *textView = [alertView textFieldAtIndex:0];
        self.resultModel.anotherName = textView.text;
        if (self.resultModel.title == nil || self.resultModel.title.length == 0) {
            self.resultModel.title = self.oldAddress.anotherName;
        }

        [_delegate selectedAddress:self.resultModel];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        [self.mapView stop];
        self.mapView = nil;
    }
}

- (void)willPresentAlertView:(UIAlertView *)alertView {
    UITextField *textView = [alertView textFieldAtIndex:0];
    if (self.selectedModel.title != nil) {
        textView.text = self.selectedModel.title;
    } else {
        if (self.resultModel.title == nil || self.resultModel.title.length == 0) {
            self.resultModel.title = self.oldAddress.anotherName;
        }
        textView.text = self.resultModel.title;
    }
   
}

@end
