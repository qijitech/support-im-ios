//
//  ConversationTableViewCell.m
//  Pods
//
//  Created by shuu on 16/5/5.
//
//

#import "ConversationTableViewCell.h"
#import <Masonry/Masonry.h>

static CGFloat kImageSize = 45;
static CGFloat kVerticalSpacing = 8;
static CGFloat kHorizontalSpacing = 10;
static CGFloat kTimestampeLabelWidth = 100;

static CGFloat kNameLabelHeightProportion = 3.0 / 5;
static CGFloat kNameLabelHeight;
static CGFloat kMessageLabelHeight;
static CGFloat kLittleBadgeSize = 10;

@interface ConversationTableViewCell ()
@property (nonatomic, assign) BOOL didSetupConstraints;

@end

@implementation ConversationTableViewCell

+ (ConversationTableViewCell *)dequeueOrCreateCellByTableView :(UITableView *)tableView {
    ConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ConversationTableViewCell identifier]];
    if (cell == nil) {
        cell = [[ConversationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[self class] identifier]];
    }
    return cell;
}

+ (void)registerCellToTableView: (UITableView *)tableView {
    [tableView registerClass:[ConversationTableViewCell class] forCellReuseIdentifier:[[self class] identifier]];
}

+ (NSString *)identifier {
    return NSStringFromClass([ConversationTableViewCell class]);
}

+ (CGFloat)heightOfCell {
    return kImageSize + kVerticalSpacing * 2;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupViews];
        [self updateConstraintsIfNeeded];
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        self.didSetupConstraints = YES;
        [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).with.offset(kHorizontalSpacing);
            make.centerY.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(kImageSize, kImageSize));
        }];
        [self.litteBadgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kLittleBadgeSize, kLittleBadgeSize));
//            make.left.mas_equalTo(kHorizontalSpacing + kImageSize);
//            make.top.mas_equalTo(10);
            make.centerX.equalTo(self.avatarImageView.mas_right);
            make.centerY.equalTo(self.avatarImageView.mas_top);
        }];
        [self.badgeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kLittleBadgeSize, kLittleBadgeSize));
//            make.left.mas_equalTo(kHorizontalSpacing + kImageSize);
//            make.top.mas_equalTo(10);
            make.centerX.equalTo(self.avatarImageView.mas_right);
            make.centerY.equalTo(self.avatarImageView.mas_top);
        }];

        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.avatarImageView.mas_right).with.offset(kHorizontalSpacing);
            make.right.equalTo(self.timestampLabel.mas_left).with.offset(-kHorizontalSpacing);
            make.height.mas_equalTo(kNameLabelHeight);
            make.top.equalTo(self.avatarImageView);
        }];
        [self.messageTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.bottom.equalTo(self.avatarImageView);
            make.right.equalTo(self).with.offset(-kHorizontalSpacing);
            make.height.mas_equalTo(kMessageLabelHeight);
        }];
        [self.timestampLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.messageTextLabel);
            make.width.mas_equalTo(kTimestampeLabelWidth);
            make.height.mas_equalTo(kNameLabelHeight);
            make.top.equalTo(self.avatarImageView);
        }];
    }
    [super updateConstraints];
}


- (void)setupViews {
    kNameLabelHeight = kImageSize * kNameLabelHeightProportion;
    kMessageLabelHeight = kImageSize - kNameLabelHeight;
    
    [self addSubview:self.avatarImageView];
    [self addSubview:self.timestampLabel];
    [self.avatarImageView addSubview:self.badgeView];
    [self addSubview:self.litteBadgeView];
    [self addSubview:self.nameLabel];
    [self addSubview:self.messageTextLabel];
   
    
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
//        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kHorizontalSpacing, kVerticalSpacing, kImageSize, kImageSize)];
        _avatarImageView = [[UIImageView alloc] init];
    }
    return _avatarImageView;
}

- (UILabel *)timestampLabel {
    if (_timestampLabel == nil) {
        _timestampLabel = [[UILabel alloc] init];
//        _timestampLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - kHorizontalSpacing - kTimestampeLabelWidth, CGRectGetMinY(_avatarImageView.frame), kTimestampeLabelWidth, kNameLabelHeight)];
        _timestampLabel.font = [UIFont systemFontOfSize:13];
        _timestampLabel.textAlignment = NSTextAlignmentRight;
        
        _timestampLabel.textColor = [UIColor grayColor];
    }
    return _timestampLabel;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
//        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_avatarImageView.frame) + kHorizontalSpacing, CGRectGetMinY(_avatarImageView.frame), CGRectGetMinX(_timestampLabel.frame) - kHorizontalSpacing * 3 - kImageSize, kNameLabelHeight)];
        _nameLabel.font = [UIFont systemFontOfSize:17];
    }
    return _nameLabel;
}

- (UILabel *)messageTextLabel {
    if (_messageTextLabel == nil) {
        _messageTextLabel = [[UILabel alloc] init];
//        _messageTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_nameLabel.frame), CGRectGetMaxY(_nameLabel.frame), CGRectGetWidth([UIScreen mainScreen].bounds)- 3 * kHorizontalSpacing - kImageSize, kMessageLabelHeight)];
        _messageTextLabel.backgroundColor = [UIColor clearColor];
    }
    return _messageTextLabel;
}

- (UIView *)litteBadgeView {
    if (_litteBadgeView == nil) {
        _litteBadgeView = [[UIView alloc] init];
//        _litteBadgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLittleBadgeSize, kLittleBadgeSize)];
//        _litteBadgeView.center = CGPointMake(CGRectGetMaxX(_avatarImageView.frame), CGRectGetMinY(_avatarImageView.frame));
        _litteBadgeView.backgroundColor = [UIColor redColor];
        _litteBadgeView.layer.masksToBounds = YES;
        _litteBadgeView.layer.cornerRadius = kLittleBadgeSize / 2;
        _litteBadgeView.hidden = YES;
    }
    return _litteBadgeView;
}

- (JSBadgeView *)badgeView {
    if (_badgeView == nil) {
        _badgeView = [[JSBadgeView alloc] init];
//        _badgeView = [[JSBadgeView alloc] initWithParentView:_avatarImageView alignment:JSBadgeViewAlignmentTopRight];
    }
    return _badgeView;
}

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.badgeView.badgeText = nil;
    self.litteBadgeView.hidden = YES;
    self.messageTextLabel.text = nil;
    self.timestampLabel.text = nil;
    self.nameLabel.text = nil;
}


@end
