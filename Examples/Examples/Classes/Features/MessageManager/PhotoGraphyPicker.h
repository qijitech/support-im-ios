//
//  PhotoGraphyPicker.h
//  SupportIm
//
//  Created by shuu on 16/5/1.
//  Copyright © 2016年 qijitech. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DidFinishTakeMediaCompledBlock)(UIImage *image, NSDictionary *editingInfo);
typedef void (^DidFinishTakeImageBlock)(UIImage *image);

@interface PhotoGraphyPicker : NSObject

- (void)showOnPickerViewControllerSourceType:(UIImagePickerControllerSourceType)sourceType onViewController:(UIViewController *)viewController allowsEditing:(BOOL)allowsEditing compled:(DidFinishTakeMediaCompledBlock)compled;

- (void)showOnPickerViewControllerSourceType:(UIImagePickerControllerSourceType)sourceType OnViewController:(UIViewController *)viewController completion:(DidFinishTakeImageBlock)completion;

@end
