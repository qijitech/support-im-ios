//
//  LocationViewController.h
//  Pods
//
//  Created by shuu on 16/5/12.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


typedef void (^LocationShareBlock)(NSString *location, CLLocationCoordinate2D coordinate, UIImage *image);

@interface LocationViewController : UIViewController
@property (nonatomic, copy) LocationShareBlock locationShareBlock;


@end
