//
//  LeafNotification.m
//  AsyncSocketDemo
//
//  Created by n on 17/1/6.
//  Copyright © 2017年 ligang. All rights reserved.
//

#import "LeafNotification.h"
#define BLog(formatString, ...) NSLog((@"%s " formatString), __PRETTY_FUNCTION__, ##__VA_ARGS__);

@implementation LeafNotification
+ (void)showInController:(UIViewController *)vc withText:(NSString *)string{
    BLog(@"%@ %@",vc,string);
}
@end
