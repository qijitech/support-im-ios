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
        [self.badgeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(kLittleBadgeSize, kLittleBadgeSize));
            make.centerY.mas_equalTo(self.avatarImageView.mas_top);
            make.centerX.mas_equalTo(self.avatarImageView.mas_right);
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
    [self addSubview:self.badgeLabel];
    [self addSubview:self.nameLabel];
    [self addSubview:self.messageTextLabel];
    [self addSubview:self.timestampLabel];
//    [self addSubview:self.badgeView];
}

- (UIImageView *)avatarImageView {
    if (_avatarImageView == nil) {
        _avatarImageView = [[UIImageView alloc] init];
    }
    return _avatarImageView;
}

//- (UIView *)litteBadgeView {
//    if (_litteBadgeView == nil) {
//        _litteBadgeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kLittleBadgeSize, kLittleBadgeSize)];
//        _litteBadgeView.backgroundColor = [UIColor redColor];
//        _litteBadgeView.layer.masksToBounds = YES;
//        _litteBadgeView.layer.cornerRadius = kLittleBadgeSize / 2;
//        _litteBadgeView.center = CGPointMake(CGRectGetMaxX(_avatarImageView.frame), CGRectGetMinY(_avatarImageView.frame));
//        _litteBadgeView.hidden = YES;
//    }
//    return _litteBadgeView;
//}

- (UILabel *)timestampLabel {
    if (_timestampLabel == nil) {
        _timestampLabel = [[UILabel alloc] init];
        _timestampLabel.font = [UIFont systemFontOfSize:13];
        _timestampLabel.textAlignment = NSTextAlignmentRight;
        _timestampLabel.textColor = [UIColor grayColor];
    }
    return _timestampLabel;
}

- (UILabel *)nameLabel {
    if (_nameLabel == nil) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:17];
    }
    return _nameLabel;
}

- (UILabel *)messageTextLabel {
    if (_messageTextLabel == nil) {
        _messageTextLabel = [[UILabel alloc] init];
        _messageTextLabel.backgroundColor = [UIColor clearColor];
    }
    return _messageTextLabel;
}

- (UILabel *)badgeLabel {
    if (_badgeLabel == nil) {
        _badgeLabel = [[UILabel alloc] init];
        _badgeLabel.backgroundColor = [UIColor redColor];
        _badgeLabel.layer.masksToBounds = YES;
        _badgeLabel.layer.cornerRadius = kLittleBadgeSize / 2;
    }
    return _badgeLabel;
}

- (void)awakeFromNib {
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.badgeLabel.text = nil;
    self.badgeLabel.hidden = YES;
//    self.litteBadgeView.hidden = YES;
    self.messageTextLabel.text = nil;
    self.timestampLabel.text = nil;
    self.nameLabel.text = nil;
}


@end
