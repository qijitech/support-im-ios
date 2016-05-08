//
//  PhoneVerifyCodeView.h
//  SupportIm
//
//  Created by shuu on 16/4/25.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PhoneVerifyCodeNextStepButtonPressedBlock)();
typedef void(^PhoneVerifyCodeSelectCellBlock)(NSIndexPath *indexPath);
typedef void(^PhoneVerifyCodeGetCodeButtonPressedBlock)(UIButton *button);

@interface PhoneVerifyCodeView : UIView
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, copy) PhoneVerifyCodeNextStepButtonPressedBlock nextStepButtonPressedBlock;
@property (nonatomic, copy) PhoneVerifyCodeSelectCellBlock selectCellBlock;
@property (nonatomic, copy) PhoneVerifyCodeGetCodeButtonPressedBlock getCodeButtonPressedBlock;

@end
