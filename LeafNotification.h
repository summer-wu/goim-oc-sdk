//
//  LeafNotification.h
//  AsyncSocketDemo
//
//  Created by n on 17/1/6.
//  Copyright © 2017年 ligang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LeafNotification : NSNotification
+(void)showInController:(UIViewController *)vc withText:(NSString *)string;

@end
