//
//  SingCountViewController.m
//  服服
//
//  Created by shangzh on 16/7/25.
//

#import "SingCountMapViewController.h"
#import "MapView.h"
#import "SingCountTitleView.h"
#import "CDVDateTimePickerView.h"
#import "UIView+UIViewAnimation.h"
#import "CDVShowAddressView.h"
#import "CustomAnnotationView.h"
#import "MBProgressHUD.h"
#import "CDVAlertMessageView.h"

#define KPickerHeight 200

@interface SingCountMapViewController () <CDVAlertMessageViewDelegate>

@property (nonatomic,strong) SingCountTitleView *titleView;

@property (nonatomic,strong) CDVDateTimePickerView *pickerView;

@property (nonatomic,strong) MapView *map;

@property (nonatomic,strong) NSArray *dataArr;

@property (nonatomic,strong) CDVShowAddressView *addressView;

//记录已选择的mark
@property (nonatomic,assign) NSInteger selectedMark;
@end

@implementation SingCountMapViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    //表示未选中
    self.selectedMark = -1;
    
     self.titleView = [[SingCountTitleView alloc] initWithFrame:CGRectMake(0, 0, 160, 30)];
    __weak __typeof(self) weakSelf = self;
    
    [self.titleView.titleBtn setTitle:[self.target_date stringByReplacingOccurrencesOfString:@"-" withString:@"/"] forState:UIControlStateNormal];
    
    self.titleView.changeCurrentTime = ^(NSString *type){   // 1
        if ([type isEqualToString:@"normal"]) {
            
            if (weakSelf.pickerView != nil) {
                [weakSelf.pickerView bringSubviewToFront:weakSelf.view];
                return;
            }
            
            CGRect pickRect =CGRectMake(0, weakSelf.view.bounds.size.height, weakSelf.view.bounds.size.width, KPickerHeight);
            weakSelf.pickerView = [[CDVDateTimePickerView alloc] initWithFrame:pickRect];
            NSDateFormatter *inputFormat = [[NSDateFormatter alloc] init];
            [inputFormat setDateFormat:@"yyyy-MM-dd"];
            NSDate *inputDate = [inputFormat dateFromString: [[weakSelf.titleView.titleBtn.titleLabel text] stringByReplacingOccurrencesOfString:@"/" withString:@"-"] ];
            [weakSelf.pickerView.datePicker setDate:inputDate];
            
            weakSelf.pickerView.selectedCurrentTime = ^(NSString *text){
                if (text.length > 0) {
                    [weakSelf.titleView.titleBtn setTitle:text forState:UIControlStateNormal];
                    NSString *time = [text stringByReplacingOccurrencesOfString:@"/" withString:@"-"];
                    [weakSelf loadDataWithTargetDate:time];
                }
                [weakSelf.pickerView MoveToDownWith:pickRect];
                weakSelf.pickerView = nil;
            };
            
            [weakSelf.view addSubview:weakSelf.pickerView];
            
            [weakSelf.pickerView MoveToUpWith:CGRectMake(0, weakSelf.view.bounds.size.height-KPickerHeight, weakSelf.view.bounds.size.width, KPickerHeight)];
        } else {
            
            [weakSelf loadDataWithTargetDate:[type stringByReplacingOccurrencesOfString:@"/" withString:@"-"]];
        }
    };
    self.navigationItem.titleView = self.titleView;
    
    self.map = [[MapView alloc] initWithFrame:self.view.bounds andIsCanLocation:NO];

    self.map.isShowCallout = NO;
    self.map.markCanScal = YES;
    self.map.isCanGetLocation = NO;
    self.map.isCanResponser = true;
    [self.map.mapView setShowsUserLocation:NO];
   
    [self loadDataWithTargetDate:self.target_date];
    
    [self.view addSubview:self.map];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callBack:) name:@"PosterOne" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadDataWithTargetDate:(NSString *)date {
    
    if (self.addressView != nil) {
        [self.addressView removeFromSuperview];
        self.addressView = nil;
    }
    if (self.pickerView != nil) {
        [self.pickerView removeFromSuperview];
        self.pickerView = nil;
    }
    [self.titleView changeBtnStatus:NO];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
    NSString *urlStr = [NSString stringWithFormat:@"%@&target_date=%@",self.url,date];
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    /*
     发送异步请求， 不会阻塞主线程。效率能提高。
     第一个参数：发送的什么异步请求
     第二个参数：回调在哪一个队列（一般传主队列）
     第三个参数有：block 可接受到，响应数据，响应头，以及响应状态（错误值）
     */
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        [self clearMark];
        
        [self.titleView changeBtnStatus:YES];
        
        if (connectionError) {
          
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"网络连接错误，请检查网络连接!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
          
            return ;
        }
  
        self.dataArr = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];

        if (self.dataArr.count == 0) {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            CDVAlertMessageView *message = [[CDVAlertMessageView alloc] initWithTitle:@"提示" message:@"没有打卡记录!" okButtonTitle:@"确定" textType:TextCenter delegate:self];
            [message showInView:self.view];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"没有打卡记录!" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [alert show];
            return ;
        }
       
        NSMutableArray *animaArr = [[NSMutableArray alloc] init];
        for (int i =0; i < self.dataArr.count; i++) {
            MAPointAnnotation *mappoint = [[MAPointAnnotation alloc] init];
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([self.dataArr[i][@"latitude"] doubleValue], [self.dataArr[i][@"longitude"] doubleValue]);
            mappoint.coordinate = coord;
            mappoint.title = [NSString stringWithFormat:@"%d",i];
            [animaArr addObject:mappoint];
            if (i == 1) {
                [self.map.mapView setCenterCoordinate:coord];
            }
            [self.map addAnimation:mappoint];
        }
        
        [self.map.mapView showAnnotations:animaArr animated:NO];
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.titleView changeBtnStatus:YES];
        
    }];
}

//清除地图mark
- (void)clearMark {
    NSArray *arrmaon = self.map.mapView.annotations;
    if (arrmaon.count > 0) {
        [self.map.mapView removeAnnotations:arrmaon];
    }
}

-(void)callBack:(NSNotification*)notification{
 
    NSInteger tag = [[notification object] integerValue];
    if (self.selectedMark >= 0) {
        NSArray *arrmaon = self.map.mapView.annotations ;
        for (int a = 0; a < arrmaon.count; a++) {
            CustomAnnotationView *animaView = (CustomAnnotationView *)[self.map.mapView viewForAnnotation:arrmaon[a]];
            if ([animaView.title integerValue] != tag) {
                animaView.image = [UIImage imageNamed:@"address_small"];
            }
        }
    }
    
    if (self.pickerView != nil) {
        [self.pickerView removeFromSuperview];
        self.pickerView = nil;
    }
   
    if (self.addressView == nil) {
        self.addressView = [[CDVShowAddressView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 50)];
    }
    
    self.addressView.backgroundColor = [UIColor whiteColor];
    self.addressView.time = self.dataArr[tag][@"time"];
    self.addressView.address = self.dataArr[tag][@"location"];
    [self.view addSubview:self.addressView];
    [self.addressView MoveToUpWith:CGRectMake(0, self.view.bounds.size.height-50, self.view.bounds.size.width, 50)];
    
    self.selectedMark = tag;
}

@end
