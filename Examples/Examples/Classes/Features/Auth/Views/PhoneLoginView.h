//
//  PhoneLoginView.h
//  SupportIm
//
//  Created by shuu on 16/4/24.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PhoneLoginNextStepButtonPressedBlock)();
typedef void(^PhoneLoginSelectCellBlock)(NSIndexPath *indexPath);

@interface PhoneLoginView : UIView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) PhoneLoginNextStepButtonPressedBlock nextStepButtonPressedBlock;
@property (nonatomic, copy) PhoneLoginSelectCellBlock selectCellBlock;

@end
