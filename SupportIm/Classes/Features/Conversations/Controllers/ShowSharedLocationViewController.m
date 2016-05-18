//
//  ShowSharedLocationViewController.m
//  Pods
//
//  Created by shuu on 16/5/13.
//
//

#import "ShowSharedLocationViewController.h"
#import <Masonry/Masonry.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "XHMessage.h"

static const NSString *APIKey = @"67a6a84bac750ce757a66f4c33ecfdc4";

@interface ShowSharedLocationViewController () <MAMapViewDelegate>
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) UIButton *resetButton;
@property (nonatomic, strong) MAPointAnnotation *pointAnnotation;
@property (nonatomic, strong) UIButton *popButton;
@property (nonatomic, strong) XHMessage *message;
@property (nonatomic, strong) UILabel *locationLabel;

@end

@implementation ShowSharedLocationViewController

# pragma mark - initialization

- (instancetype)initWithMessage:(XHMessage *)message {
    if (self = [super init]) {
        // Should init MAMap in init ViewController, not here. But you can do not note ,if need
//        [MAMapServices sharedServices].apiKey = (NSString *)APIKey;
//        [AMapSearchServices sharedServices].apiKey = (NSString *)APIKey;
        self.message = message;
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:message.geolocations];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.firstLineHeadIndent = 20;
        style.lineBreakMode = NSLineBreakByTruncatingTail;
        [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
        self.locationLabel.attributedText = text;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    [self.view updateConstraintsIfNeeded];
    [self.view setNeedsUpdateConstraints];
}

- (void)setupViews {
    [self.view addSubview:self.mapView];
    [self.mapView addSubview:self.resetButton];
    [self.mapView addSubview:self.popButton];
    [self.view addSubview:self.locationLabel];
}

- (void)updateViewConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        UIView *superView = self.view;
        [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_topLayoutGuideBottom);
            make.right.left.equalTo(superView);
            make.bottom.equalTo(self.locationLabel.mas_top);
        }];

        [self.resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.mapView).with.offset(-50);
            make.right.equalTo(superView).with.offset(-30);
            make.size.mas_equalTo(CGSizeMake(40, 40));
        }];
        
        [self.popButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.top.equalTo(self.mapView).with.offset(30);
            make.left.equalTo(self.mapView).with.offset(20);
        }];
        [self.locationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(superView);
            make.height.mas_equalTo(60);
            make.bottom.equalTo(superView);
        }];
        
    }
    [super updateViewConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.mapView setZoomLevel:14.f animated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.mapView setCenterCoordinate:self.message.location.coordinate animated:NO];
    self.pointAnnotation.coordinate = self.message.location.coordinate;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


# pragma mark - private API

- (void)popLocationViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)resetMap {
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
}

# pragma mark - MAMapViewDelegate




# pragma mark - lazy load

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

- (MAPointAnnotation *)pointAnnotation {
    if (!_pointAnnotation) {
        _pointAnnotation = [[MAPointAnnotation alloc] init];
        [self.mapView addAnnotation:_pointAnnotation];
    }
    return _pointAnnotation;
}

- (UIButton *)popButton {
    if (!_popButton) {
        _popButton = [[UIButton alloc] init];
        _popButton.backgroundColor = [UIColor grayColor];
        [_popButton setBackgroundImage:[UIImage imageNamed:@"BackButtonImage"] forState:UIControlStateNormal];
        _popButton.alpha = 0.7;
        _popButton.layer.cornerRadius = 3.f;
        _popButton.layer.masksToBounds = YES;
        [_popButton addTarget:self action:@selector(popLocationViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    return _popButton;
}

- (UILabel *)locationLabel {
    if (!_locationLabel) {
        _locationLabel = [[UILabel alloc] init];
        _locationLabel.backgroundColor = [UIColor whiteColor];
        _locationLabel.font = [UIFont systemFontOfSize:18.f];
        _locationLabel.numberOfLines = 0;
    }
    return _locationLabel;
}

@end
