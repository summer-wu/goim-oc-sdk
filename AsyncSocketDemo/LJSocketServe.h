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

//const (
//       OP_HANDSHARE        = int32(0)
//       OP_HANDSHARE_REPLY  = int32(1)
//       OP_HEARTBEAT        = int32(2)
//       OP_HEARTBEAT_REPLY  = int32(3)
//       OP_SEND_SMS         = int32(4)
//       OP_SEND_SMS_REPLY   = int32(5)
//       OP_DISCONNECT_REPLY = int32(6)
//       OP_AUTH             = int32(7)
//       OP_AUTH_REPLY       = int32(8)
//       OP_TEST             = int32(254)
//       OP_TEST_REPLY       = int32(255)
//       )


typedef void(^myBlock)(NSString *);
@interface LJSocketServe : NSObject<AsyncSocketDelegate>
@property ViewController *vc;
@property (nonatomic, strong) AsyncSocket         *socket;       // socket
@property (nonatomic, retain) NSTimer             *heartTimer;   // 心跳计时器
@property (nonatomic,copy)myBlock block;
+ (LJSocketServe *)sharedSocketServe;

/// socket连接
- (void)startConnectSocket;

/// 用户断开socket连接
-(void)cutOffSocket;

/// 发送聊天消息
- (void)sendChatMessage:(NSString *)message toUser:(NSString *)user;

-(void)sendAuthWithToken:(NSString *)token;

@end
