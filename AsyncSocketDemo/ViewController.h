//
//  ViewController.h
//  AsyncSocketDemo
//
//  Created by 刘佳 on 15/4/3.
//  Copyright (c) 2015年 刘佳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (void)logChatMessage:(NSString *)chatMessage;//记录聊天信息
- (void)logMeta:(NSString *)meta;//记录meta数据。如认证数据、连接数据
@end

