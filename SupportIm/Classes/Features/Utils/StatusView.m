//
//  StatusView.m
//  Pods
//
//  Created by shuu on 16/5/8.
//
//

#import "StatusView.h"

static CGFloat kStatusImageViewHeight = 20;
static CGFloat kHorizontalSpacing = 15;
static CGFloat kHorizontalLittleSpacing = 5;

@interface StatusView ()

@property (nonatomic, strong) UIImageView *statusImageView;

@property (nonatomic, strong) UILabel *statusLabel;

@end


@implementation StatusView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    self.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:1];
    [self addSubview:self.statusImageView];
    [self addSubview:self.statusLabel];
}

#pragma mark - Propertys

- (UIImageView *)statusImageView {
    if (_statusImageView == nil) {
        _statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kHorizontalSpacing, (kStatusViewHight - kStatusImageViewHeight) / 2, kStatusImageViewHeight, kStatusImageViewHeight)];
        _statusImageView.image = [UIImage imageNamed:@"messageSendFail"];
    }
    return _statusImageView;
}

- (UILabel *)statusLabel {
    if (_statusLabel == nil) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_statusImageView.frame) + kHorizontalLittleSpacing, 0, self.frame.size.width - CGRectGetMaxX(_statusImageView.frame) - kHorizontalSpacing - kHorizontalLittleSpacing, kStatusViewHight)];
        _statusLabel.font = [UIFont systemFontOfSize:15.0];
        _statusLabel.textColor = [UIColor grayColor];
        _statusLabel.text = @"会话断开，请检查网络";
    }
    return _statusLabel;
}


@end
