//
//  ShowMapWithCoordinatViewController.m
//  服服
//
//  Created by shangzh on 16/6/18.
//
//

#import "ShowMapWithCoordinatViewController.h"
#import "MapView.h"

@interface ShowMapWithCoordinatViewController ()

@end

@implementation ShowMapWithCoordinatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    MAPointAnnotation *mappoint = [[MAPointAnnotation alloc] init];
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(self.latitude, self.longitude);
    mappoint.title = self.address;
    mappoint.coordinate = coord;

//    MapView *map = [[MapView alloc] initWithFrame:self.view.bounds];
    MapView *map = [[MapView alloc] initWithFrame:self.view.bounds andIsCanLocation:YES];
    map.zoomLevel = 15.1;
    map.mapView.showsUserLocation = NO;
    map.isCanGetLocation = NO;
    map.isShowCallout = YES;
    map.centerCoor = coord;
    map.isCanResponser = true;

//    map.centerCoor =coord;
    [map addAnimation:mappoint];
    [map.mapView setCenterCoordinate:coord animated:YES];
//    [map setCenterLocationWithCenterCoor:coord];
    [self.view addSubview:map];

  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
