//
//  BaseMutipleSectionViewController.m
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "BaseMutipleSectionViewController.h"
#import "JSBadgeView.h"

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
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *sectionDictionary = self.dataSource[indexPath.section][indexPath.row];
    NSString *selectorName = sectionDictionary[kMutipleSectionSelectorKey];
    if (selectorName) {
        [self performSelector:NSSelectorFromString(selectorName) withObject:nil afterDelay:0];
    }
}

@end
