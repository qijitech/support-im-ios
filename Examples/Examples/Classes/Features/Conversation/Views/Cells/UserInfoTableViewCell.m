//
//  UserInfoTableViewCell.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "UserInfoTableViewCell.h"

@interface UserInfoTableViewCell ()
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation UserInfoTableViewCell

+ (NSString *)identifier {
    return NSStringFromClass([UserInfoTableViewCell class]);
}

+ (void)registerCellToTalbeView:(UITableView *)tableView {
//    UINib *nib = [UINib nibWithNibName:NSStringFromClass([UserInfoTableViewCell class]) bundle:nil];
//    [tableView registerNib:nib forCellReuseIdentifier:[UserInfoTableViewCell identifier]];
    [tableView registerClass:[UserInfoTableViewCell class] forCellReuseIdentifier:[UserInfoTableViewCell identifier]];
}

+ (UserInfoTableViewCell *)createOrDequeueCellByTableView:(UITableView *)tableView {
    UserInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[UserInfoTableViewCell identifier]];
    if (cell == nil) {
        cell = [[UserInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[UserInfoTableViewCell identifier]];
        if (cell == nil) {
            [UserInfoTableViewCell registerCellToTalbeView:tableView];
            return [self createOrDequeueCellByTableView:tableView];
        }
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
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
            make.right.equalTo(self).with.offset(-20);
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

@end
