//
//  LGSocketServe.h
//  AsyncSocketDemo
//
//  Created by 刘佳 on 15/4/3.
//  Copyright (c) 2015年 刘佳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "ViewController.h"

enum{
    SocketOfflineByServer,      //服务器掉线
    SocketOfflineByUser,        //用户断开
    SocketOfflineByWifiCut,     //wifi 断开
};


typedef NS_ENUM(NSUInteger, GoIMOP) {
    GoIMOP_HANDSHARE = 0,
    GoIMOP_HANDSHARE_REPLY = 1,
    GoIMOP_HEARTBEAT = 2,
    GoIMOP_HEARTBEAT_REPLY = 3,
    GoIMOP_SEND_SMS = 4,
    GoIMOP_SEND_SMS_REPLY = 5,
    GoIMOP_DISCONNECT_REPLY = 6,
    GoIMOP_AUTH = 7,
    GoIMOP_AUTH_REPLY = 8,
    GoIMOP_TEST = 254,
    GoIMOP_TEST_REPLY = 255   
};



typedef void(^myBlock)(NSString *);
@interface GoIMSocketClient : NSObject<AsyncSocketDelegate>
@property ViewController *vc;
@property (nonatomic, strong) AsyncSocket         *socket;       // socket
@property (nonatomic, retain) NSTimer             *heartTimer;   // 心跳计时器
@property (nonatomic,copy)myBlock block;
+ (GoIMSocketClient *)sharedSocketServe;

/// socket连接
- (void)startConnectSocket;

/// 用户断开socket连接
-(void)cutOffSocket;

/// 发送聊天消息
- (void)sendChatMessage:(NSString *)message toUser:(NSString *)user;

-(void)sendAuthWithToken:(NSString *)token;

@end
