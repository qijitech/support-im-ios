//
//  BaseTableViewController.h
//  Examples
//
//  Created by shuu on 16/5/8.
//  Copyright © 2016年 奇迹空间. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) UITableViewStyle tableViewStyle;

@property (nonatomic, strong) NSMutableArray *dataSource;

- (void)loadDataSource;


@end
