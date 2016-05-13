//
//  LocationViewController.m
//  Pods
//
//  Created by shuu on 16/5/12.
//
//


#import "LocationViewController.h"
#import <Masonry/Masonry.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

@interface LocationViewController () <MAMapViewDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *locationArray;
@property (nonatomic, strong) MAUserLocation *currentLocation;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) UIButton *resetButton;
//@property (nonatomic, strong) MAPointAnnotation *pointAnnotation;
@property (nonatomic, strong) UIImageView *pin;
@property (nonatomic, assign) NSInteger *selectRow;


@end

@implementation LocationViewController

# pragma mark - initialization


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"位置";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendLocation)];
    self.selectRow = 0;
    [self setupViews];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsUpdateConstraints];
}

- (void)setupViews {
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.tableView];
    [self.mapView addSubview:self.resetButton];
    [self.mapView addSubview:self.pin];

}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        UIView *superView = self.view;
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.right.left.equalTo(superView);
            make.height.mas_equalTo(superView.bounds.size.height * 0.5);
        }];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mapView.mas_bottom);
            make.right.left.bottom.equalTo(superView);
        }];
        [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mapView).with.offset(-50);
            make.right.equalTo(superView).with.offset(-30);
            make.size.mas_equalTo(CGSizeMake(40, 30));
        }];
        [self.pin mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mapView);
            make.bottom.equalTo(self.mapView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(20, 40));
        }];

    }
    [super updateViewConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mapView setZoomLevel:14.f animated:YES];
//    self.pointAnnotation.coordinate = self.mapView.centerCoordinate;
}

# pragma mark - private API

- (void)resetMap {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
}


- (void)sendLocation {
    [self resetMap];
    
    if (!self.locationArray.count) {
        return;
    }
    if (self.locationShareBlock) {
        AMapPOI *point = self.locationArray[0];
        NSString *location = point.address;
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(point.location.latitude, point.location.longitude);
        UIImage *image = [self.mapView takeSnapshotInRect:self.mapView.frame];
        self.locationShareBlock(location, coordinate, image);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (AMapPOIAroundSearchRequest *)searchWithCoordinate:(CLLocationCoordinate2D)coordinate {
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.location = [AMapGeoPoint locationWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    //    request.keywords = @"方恒";
    //    // types属性表示限定搜索POI的类别，默认为：餐饮服务|商务住宅|生活服务
    //    // POI的类型共分为20种大类别，分别为：
    //    // 汽车服务|汽车销售|汽车维修|摩托车服务|餐饮服务|购物服务|生活服务|体育休闲服务|
    //    // 医疗保健服务|住宿服务|风景名胜|商务住宅|政府机构及社会团体|科教文化服务|
    //    // 交通设施服务|金融保险服务|公司企业|道路附属设施|地名地址信息|公共设施
    //    request.types = @"餐饮服务|生活服务";
//    request.sortrule = 0;
//    request.requireExtension = YES;
    return request;
}

- (void)shockPin {
    self.pin.layer.affineTransform = CGAffineTransformMakeScale(0.1, 0.1);
    [UIView animateWithDuration:0.18
                          delay:0.05
                        options:0
                     animations:^{
                         self.pin.layer.affineTransform = CGAffineTransformMakeScale(1.1, 1.1);
                     } completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.08 animations:^{
                             self.pin.layer.affineTransform = CGAffineTransformIdentity;
                         } completion:^(BOOL finished) {
                         }];
                     }];
}

# pragma mark - AMapSearchDelegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"%@",error.localizedDescription);
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    if(response.pois.count == 0) {
        return;
    }
    
    self.locationArray = response.pois;
    [self.tableView reloadData];
}

# pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
//    self.pointAnnotation.coordinate = self.mapView.centerCoordinate;
    [self shockPin];
    [self.search AMapPOIAroundSearch:[self searchWithCoordinate:self.mapView.centerCoordinate]];

}

//- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
//    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
//        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
//        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
//        if (annotationView == nil) {
//            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
//        }
////        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
//        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
////        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
//        annotationView.pinColor = MAPinAnnotationColorRed;
//        
//        return annotationView;
//    }
//    return nil;
//}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if(updatingLocation) {
        
        self.currentLocation = userLocation;
        
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    }
}

# pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectRow = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView reloadData];
    
    AMapPOI *point = self.locationArray[indexPath.row];
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(point.location.latitude, point.location.longitude) animated:YES];
}

- (UITableViewCellAccessoryType)tableView:(UITableView*)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath*)indexPath {
    if(indexPath.row == self.selectRow) {
        return UITableViewCellAccessoryCheckmark;
    }
    return UITableViewCellAccessoryNone;
}

# pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.locationArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    cell.textLabel.text = [self.locationArray[indexPath.row] name];
    cell.detailTextLabel.text = [self.locationArray[indexPath.row] address];
    
    
    
    
    return cell;
}

# pragma mark - lazy load

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc] init];
        _mapView.delegate = self;
        _mapView.showsUserLocation = YES;
        [_mapView setUserTrackingMode:MAUserTrackingModeFollow animated:YES];
//        _mapView.showsScale = YES;  //设置成NO表示不显示比例尺；YES表示显示比例尺
//        _mapView.scaleOrigin = CGPointMake(_mapView.scaleOrigin.x, 22);
//        _mapView.showsCompass = YES; // 设置成NO表示关闭指南针；YES表示显示指南针
//        _mapView.compassOrigin = CGPointMake(_mapView.compassOrigin.x, 22); //设置指南针位置
    }
    return _mapView;
}

- (NSMutableArray *)locationArray {
    if (!_locationArray) {
        _locationArray = [NSMutableArray array];
    }
    return _locationArray;
}

- (AMapSearchAPI *)search {
    if (!_search) {
        _search = [[AMapSearchAPI alloc] init];
        _search.delegate = self;
    }
    return _search;
}

- (UIButton *)resetButton {
    if (!_resetButton) {
        _resetButton = [[UIButton alloc] init];
        _resetButton.backgroundColor = [UIColor darkGrayColor];
        [_resetButton setTitle:@"复位" forState:UIControlStateNormal];
        [_resetButton addTarget:self action:@selector(resetMap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _resetButton;
}

//- (MAPointAnnotation *)pointAnnotation {
//    if (!_pointAnnotation) {
//        _pointAnnotation = [[MAPointAnnotation alloc] init];
//        [self.mapView addAnnotation:_pointAnnotation];
//    }
//    return _pointAnnotation;
//}

- (UIImageView *)pin {
    if (!_pin) {
        _pin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LocationPoint"]];
    }
    return _pin;
}

@end
