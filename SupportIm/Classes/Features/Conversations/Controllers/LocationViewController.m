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
#import "SKToastUtil.h"


@interface LocationViewController () <MAMapViewDelegate, AMapSearchDelegate, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *locationArray;
@property (nonatomic, strong) AMapSearchAPI *search;
@property (nonatomic, strong) UIButton *resetButton;
//@property (nonatomic, strong) MAPointAnnotation *pointAnnotation;
@property (nonatomic, strong) UIImageView *pin;
@property (nonatomic, assign) NSInteger *selectRow;
@property (nonatomic, strong) AMapPOI *currentMapPOI;
@property (nonatomic, strong) AMapPOI *firstMapPOI;
@property (nonatomic, assign, getter = isDidReceivedCurrentLocation) BOOL didReceivedCurrentLocation;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *searchBarBlockTouchView;
@property (nonatomic, strong) UITableView *searchTipsTableView;
@property (nonatomic, strong) NSMutableArray *tipsArray;


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
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.tableView];
    [self.mapView addSubview:self.resetButton];
    [self.mapView addSubview:self.pin];
    [self.view addSubview:self.searchBarBlockTouchView];
    [self.view addSubview:self.searchTipsTableView];

}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        UIView *superView = self.view;
        [self.searchBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.left.right.equalTo(superView);
        }];
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom);
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
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        [self.pin mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mapView);
            make.bottom.equalTo(self.mapView.mas_centerY);
            make.size.mas_equalTo(CGSizeMake(20, 40));
        }];
        [self.searchBarBlockTouchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(superView);
            make.bottom.equalTo(superView);
            make.top.equalTo(self.searchBar.mas_bottom);
        }];
        [self.searchTipsTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.searchBar.mas_bottom);
            make.left.right.bottom.equalTo(superView);
        }];
    }
    [super updateViewConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mapView setZoomLevel:14.f animated:NO];

}



# pragma mark - private API

- (void)resetMap {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
}


- (void)sendLocation {
    if (!self.didReceivedCurrentLocation) {
        self.didReceivedCurrentLocation = YES;
        [self getLocationDetailWithUserLocation:self.mapView.userLocation];
    } else {
        if (self.locationShareBlock) {
            AMapPOI *point = self.currentMapPOI;
            NSString *location = [NSString stringWithFormat:@"%@", point.address];
            UIImage *image = [self.mapView takeSnapshotInRect:self.mapView.frame];
            if (!point.address) {
                [SKToastUtil toastWithText:@"您的网络不畅，请稍后再试"];
                return;
            }
            self.locationShareBlock(location, self.mapView.userLocation.location.coordinate, image);
        }

        [self.navigationController popViewControllerAnimated:YES];
        self.didReceivedCurrentLocation = NO;
    }
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
//    request.requireSubPOIs = YES;
    request.requireExtension = YES;
    return request;
}

- (AMapCloudPOILocalSearchRequest *)searchWithKeywords:(NSString *)keywords {
    AMapCloudPOILocalSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    request.tableID = @"8d226fc63316e790c759e7f5430dd6c2";//在数据管理台中取得
    request.keywords = keywords;
    request.city = self.mapView.userLocation;
 
    return request;
}

- (AMapInputTipsSearchRequest *)searchTipsWithKeywords:(NSString *)keywords {
    AMapInputTipsSearchRequest *tipsRequest = [[AMapInputTipsSearchRequest alloc] init];
    tipsRequest.keywords = keywords;
    tipsRequest.city = [self.locationArray[0] city];
    [self.search AMapInputTipsSearch:tipsRequest];
    return tipsRequest;
}

- (void)getLocationDetailWithUserLocation:(MAUserLocation *)userLocation {
    AMapPOIAroundSearchRequest *request = [self searchWithCoordinate:userLocation.location.coordinate];
    request.offset = 1;
    [self.search AMapPOIAroundSearch:[self searchWithCoordinate:self.mapView.centerCoordinate]];
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

- (void)tapGeatureHandle {
    [self setupSearchBar];
}

- (void)setupSearchBar {
    if (self.searchBarBlockTouchView.hidden) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.searchBarBlockTouchView.hidden = NO;
        [self.searchBar setShowsCancelButton:YES animated:YES];
        
    } else {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        self.searchBarBlockTouchView.hidden = YES;
        self.searchTipsTableView.hidden = YES;
        [self.searchBar resignFirstResponder];
        [self.searchBar setShowsCancelButton:NO animated:YES];
    }
}

# pragma mark - AMapSearchDelegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error {
    NSLog(@"%@",error.localizedDescription);
    if (error.code == 1806) {
        [SKToastUtil toastWithText:@"您的网络不畅，暂时无法得到定位数据0"];
    } else {
        [SKToastUtil toastWithText:error.localizedDescription];
    }
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response {
    
    // If network was very very bad, you can not get location with network, only send nil location detail. heheda been here.
    if (!self.firstMapPOI && response.pois.count) {
        self.firstMapPOI = response.pois.firstObject;
    }
    if (self.isDidReceivedCurrentLocation) {
        if (!response.pois.count) {
            if (!self.firstMapPOI) {
                self.firstMapPOI = [[AMapPOI alloc] init];
            }
            self.currentMapPOI = self.firstMapPOI;
        } else {
            self.currentMapPOI = response.pois[0];
        }
        [self sendLocation];
    }
    
    
    if (response.pois.count == 0) {
        return;
    }
    self.locationArray = response.pois;
    [self.tableView reloadData];
}

-(void)onInputTipsSearchDone:(AMapInputTipsSearchRequest*)request response:(AMapInputTipsSearchResponse *)response {
    if(response.tips.count == 0) {
        return;
    }
    
    self.tipsArray = response.tips;
    [self.searchTipsTableView reloadData];
    
    //通过AMapInputTipsSearchResponse对象处理搜索结果
    NSString *strCount = [NSString stringWithFormat:@"count: %d", response.count];
    NSString *strtips = @"";
    for (AMapTip *p in response.tips) {
        strtips = [NSString stringWithFormat:@"%@\nTip: %@", strtips, p.description];
    }
    NSString *result = [NSString stringWithFormat:@"%@ \n %@", strCount, strtips];
    NSLog(@"InputTips: %@", result);
}

# pragma mark - MAMapViewDelegate

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    if (!wasUserAction && self.firstMapPOI) {
        return;
    }
    
    [self shockPin];
    [self.search AMapPOIAroundSearch:[self searchWithCoordinate:self.mapView.centerCoordinate]];

}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    if(updatingLocation) {
        
        //取出当前位置的坐标
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
    }
}

# pragma mark - UISearchBarDelegate


- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self setupSearchBar];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self searchTipsWithKeywords:searchBar.text];
    self.searchTipsTableView.hidden = NO;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self setupSearchBar];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (!searchText.length) {
        self.searchTipsTableView.hidden = YES;
        return;
    }
    [self searchTipsWithKeywords:searchText];
    self.searchTipsTableView.hidden = NO;
}


# pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == self.tableView) {
        self.selectRow = indexPath.row;
        [self.tableView reloadData];
        AMapPOI *point = self.locationArray[indexPath.row];
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(point.location.latitude, point.location.longitude) animated:YES];
    } else {
        [self setupSearchBar];
        AMapTip *tip = self.tipsArray[indexPath.row];
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(tip.location.latitude, tip.location.longitude) animated:YES];
    }
}


# pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (tableView == self.tableView) {
         return self.locationArray.count;
     } else {
         return self.tipsArray.count;
     }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.tableView) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"LocationDetailCell"];
        AMapPOI *point = self.locationArray[indexPath.row];
        cell.textLabel.text = point.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@%@%@", point.province, point.city, point.district, point.address];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        if(indexPath.row == self.selectRow) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        return cell;
    } else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"SearchTipCell"];
        AMapTip *tip = self.tipsArray[indexPath.row];
        cell.textLabel.text = tip.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", tip.district];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        return cell;
    }
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
//        _mapView.distanceFilter = 1.f;
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
//        _resetButton.backgroundColor = [UIColor darkGrayColor];
//        [_resetButton setTitle:@"复位" forState:UIControlStateNormal];
        [_resetButton setBackgroundImage:[UIImage imageNamed:@"ResetMapButton"] forState:UIControlStateNormal];
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
        _pin = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PinButtonImage"]];
    }
    return _pin;
}

- (UISearchBar *)searchBar {
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc] init];
        _searchBar.placeholder = @"搜索";
        _searchBar.delegate = self;
        
    }
    return _searchBar;
}

- (UIView *)searchBarBlockTouchView {
    if (!_searchBarBlockTouchView) {
        _searchBarBlockTouchView = [[UIView alloc] init];
        _searchBarBlockTouchView.backgroundColor = [UIColor darkGrayColor];
        _searchBarBlockTouchView.alpha = 0.6;
        _searchBarBlockTouchView.hidden = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGeatureHandle)];
        [_searchBarBlockTouchView addGestureRecognizer:tap];
    }
    return _searchBarBlockTouchView;
}

- (UITableView *)searchTipsTableView {
    if (!_searchTipsTableView) {
        _searchTipsTableView = [[UITableView alloc] init];
        _searchTipsTableView.delegate = self;
        _searchTipsTableView.dataSource = self;
        _searchTipsTableView.hidden = YES;
    }
    return _searchTipsTableView;
}

- (NSMutableArray *)tipsArray {
    if (!_tipsArray) {
        _tipsArray = [NSMutableArray array];
    }
    return _tipsArray;
}

@end
