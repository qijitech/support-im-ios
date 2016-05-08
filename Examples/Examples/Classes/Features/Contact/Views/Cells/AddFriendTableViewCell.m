//
//  AddFriendTableViewCell.m
//  Examples
//
//  Created by shuu on 16/5/9.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "AddFriendTableViewCell.h"

@interface AddFriendTableViewCell ()
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation AddFriendTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    
}

- (void)setupViews {
    [self addSubview:self.avatarImageView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.actionButton];
    
    [self updateConstraintsIfNeeded];
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.centerY.equalTo(self);
            make.left.equalTo(self).with.offset(20);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.height.mas_equalTo(20);
            make.left.equalTo(self.avatarImageView.mas_right).with.offset(20);
            make.right.equalTo(self.actionButton.mas_left).with.offset(-20);
        }];
        
        [self.actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(60, 20));
            make.right.equalTo(self).with.offset(-40);
            make.centerY.equalTo(self);
        }];
        
    }
    [super updateConstraints];
}

# pragma mark - lazyload

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.layer.cornerRadius = 5.f;
        _avatarImageView.layer.masksToBounds = YES;
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
    }
    return _nameLabel;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        _actionButton = [[UIButton alloc] init];
        _actionButton.backgroundColor = [UIColor lightGrayColor];
        _actionButton.layer.cornerRadius = 5.f;
        _actionButton.layer.masksToBounds = YES;
    }
    return _actionButton;
}


@end
