//
//  BaseMutipleSectionViewController.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "BaseMutipleSectionViewController.h"
#import "JSBadgeView.h"
#import <Masonry/Masonry.h>

#define RGBCOLOR(r, g, b) [UIColor colorWithRed : (r) / 255.0 green : (g) / 255.0 blue : (b) / 255.0 alpha : 1]


@interface BaseMutipleSectionViewController ()

@end

@implementation BaseMutipleSectionViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.tableViewStyle = UITableViewStyleGrouped;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray *)self.dataSource[section]).count;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    UITableViewCellStyle currentStyle;
    
    NSDictionary *sectionDictionary = self.dataSource[section][row];
    NSString *subtitle = [sectionDictionary valueForKey:kMutipleSectionSubtitleKey];
    NSString *detail = sectionDictionary[kMutipleSectionDetailKey];
    
    if (detail) {
        currentStyle = UITableViewCellStyleValue1;
    } else if (subtitle) {
        currentStyle = UITableViewCellStyleSubtitle;
    } else {
        currentStyle = UITableViewCellStyleDefault;
    }
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:currentStyle reuseIdentifier:cellIdentifier];
    }
    
    NSString *title = [sectionDictionary valueForKey:kMutipleSectionTitleKey];
    UIImage *image = [sectionDictionary valueForKey:kMutipleSectionImageKey];
    NSInteger badge = [[sectionDictionary valueForKey:kMutipleSectionBadgeKey] intValue];
    
    if (title) {
        cell.textLabel.text = title;
    }
    
    if (subtitle) {
        cell.detailTextLabel.text = subtitle;
    }
    
    if (detail) {
        cell.detailTextLabel.text = detail;
    }
    
    if (image) {
        cell.imageView.image = image;
    }
    
    NSUInteger badgeViewTag = 120;
    
    JSBadgeView *badgeView = (JSBadgeView *)[cell viewWithTag:badgeViewTag];
    if (badge > 0) {
        if (badgeView == nil) {
            badgeView = [[JSBadgeView alloc] initWithParentView:cell.textLabel alignment:JSBadgeViewAlignmentCenterRight];
            badgeView.tag = badgeViewTag;
        }
        badgeView.badgeText = [NSString stringWithFormat:@"%ld", badge];
    } else {
        if (badgeView) {
            [badgeView removeFromSuperview];
        }
    }
    
    if (sectionDictionary[kMutipleSectionSelectorKey]) {
        if (title == @"开始聊天" || title == @"添加好友") {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
//            cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
//            cell.indentationWidth = -10000.f;
//            cell.indentationLevel = 1;
            cell.textLabel.text = nil;
//            UIView *backgroudView = [[UIView alloc] init];
//            backgroudView.backgroundColor = [UIColor colorWithRed: 240.0/255 green: 240.0/255 blue: 240.0/255 alpha: 1.0];
//
//            [cell addSubview:backgroudView];
//            [backgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.edges.equalTo(cell);
//            }];
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:title forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.backgroundColor = [UIColor colorWithRed:203.f/255.f green:0.f/255.f blue:41.f/255.f alpha:1.f];
            button.layer.cornerRadius = 3.f;
            button.layer.masksToBounds = YES;
            [cell addSubview:button];
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.equalTo(cell);
                make.left.equalTo(cell).with.offset(30);
                make.right.equalTo(cell).with.offset(-30);
            }];
            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    BOOL logout = [[sectionDictionary valueForKey:kMutipleSectionLogoutKey] boolValue];
    if (logout) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.backgroundColor = RGBCOLOR(238, 78, 75);
    }
    else {
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor blackColor];
    }
    
    id discloure = sectionDictionary[kMutipleSectionDiscloureKey];
    if (discloure) {
        BOOL discloureValue = [discloure boolValue];
        if (discloureValue) {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSDictionary *sectionDictionary = self.dataSource[section][row];
    if (sectionDictionary[kMutipleSectionSelectorKey]) {
        NSString *title = [sectionDictionary valueForKey:kMutipleSectionTitleKey];
        if (title == @"开始聊天" || title == @"添加好友") {
            cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);
            cell.indentationWidth = -10000.f;
            cell.indentationLevel = 1;
//            cell.backgroundColor = [UIColor colorWithRed: 240.0/255 green: 240.0/255 blue: 240.0/255 alpha: 1.0];
            cell.backgroundColor = nil;
////            cell.backgroundColor = [UIColor colorWithRed:0.937255 green:0.937255 blue:0.956863 alpha:1];
//
//            cell.textLabel.text = nil;
////            UIView *backgroudView = [[UIView alloc] init];
////            backgroudView.backgroundColor = [UIColor colorWithRed: 240.0/255 green: 240.0/255 blue: 240.0/255 alpha: 1.0];
////            [cell addSubview:backgroudView];
////            [backgroudView mas_makeConstraints:^(MASConstraintMaker *make) {
////                make.edges.equalTo(cell);
////            }];
//            UIButton *button = [[UIButton alloc] init];
//            [button setTitle:title forState:UIControlStateNormal];
//            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//            button.backgroundColor = [UIColor colorWithRed:203.f/255.f green:0.f/255.f blue:41.f/255.f alpha:1.f];
//            button.layer.cornerRadius = 3.f;
//            button.layer.masksToBounds = YES;
//            [cell addSubview:button];
//            [button mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.top.bottom.equalTo(cell);
//                make.left.equalTo(cell).with.offset(30);
//                make.right.equalTo(cell).with.offset(-30);
//            }];
//            [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];

        }
    }
}

- (void)buttonPressed:(UIButton *)button {
    if (button.currentTitle == @"开始聊天") {
        [self performSelector:NSSelectorFromString(NSStringFromSelector(@selector(goChat))) withObject:nil afterDelay:0];
    } else if (button.currentTitle == @"添加好友") {
        [self performSelector:NSSelectorFromString(NSStringFromSelector(@selector(tryCreateAddRequest))) withObject:nil afterDelay:0];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 14;
            break;
            
        default:
            return 4;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *sectionDictionary = self.dataSource[indexPath.section][indexPath.row];
    UIImage *image = [sectionDictionary objectForKey:kMutipleSectionImageKey];
    if (image != nil) {
        CGFloat verticalSpacing = image.size.height / 2;
        return MAX(image.size.height + verticalSpacing, 44);
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *sectionDictionary = self.dataSource[indexPath.section][indexPath.row];
    
    NSString *title = [sectionDictionary valueForKey:kMutipleSectionTitleKey];
    if (title == @"开始聊天" || title == @"添加好友") {
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *selectorName = sectionDictionary[kMutipleSectionSelectorKey];
    if (selectorName) {
        [self performSelector:NSSelectorFromString(selectorName) withObject:nil afterDelay:0];
    }
}

@end
