//
//  MainAccountView.h
//  SupportIm
//
//  Created by shuu on 16/5/1.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MainAccountViewCellSelectBlock)(NSIndexPath *indexPath);

@interface MainAccountView : UITableView

@property (nonatomic, strong) MainAccountViewCellSelectBlock mainAccountViewCellSelectBlock;


@end
