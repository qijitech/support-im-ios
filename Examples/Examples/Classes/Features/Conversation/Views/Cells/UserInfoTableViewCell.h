//
//  UserInfoTableViewCell.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInfoTableViewCell : UITableViewCell

+ (NSString *)identifier;

+ (void)registerCellToTalbeView:(UITableView *)tableView;

+ (UserInfoTableViewCell *)createOrDequeueCellByTableView:(UITableView *)tableView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIImageView *avatarImageView;


@end
