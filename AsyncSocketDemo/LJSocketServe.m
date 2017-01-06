//
//  LGSocketServe.m
//  AsyncSocketDemo
//
//  Created by 刘佳 on 15/4/3.
//  Copyright (c) 2015年 刘佳. All rights reserved.
//

#import "LJSocketServe.h"
#import "BruteForceCoding.h"

//自己设定
#define HOST @"10.0.1.15"
#define PORT 8080

//设置连接超时
#define TIME_OUT 20

//设置读取超时 -1 表示不会使用超时
#define READ_TIME_OUT -1

//设置写入超时 -1 表示不会使用超时
#define WRITE_TIME_OUT -1

//每次最多读取多少
#define MAX_BUFFER 1024

@interface LJSocketServe ()

@property (nonatomic,strong)NSData *data;

@end

@implementation LJSocketServe


static LJSocketServe *socketServe = nil;

#pragma mark public static methods


+ (LJSocketServe *)sharedSocketServe {
    @synchronized(self) {
        if(socketServe == nil) {
            socketServe = [[[self class] alloc] init];
        }
    }
    return socketServe;
}


+(id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (socketServe == nil)
        {
            socketServe = [super allocWithZone:zone];
            return socketServe;
        }
    }
    return nil;
}

#define BLog(formatString, ...) NSLog((@"%s " formatString), __PRETTY_FUNCTION__, ##__VA_ARGS__);

- (void)startConnectSocket
{
    self.socket = [[AsyncSocket alloc] initWithDelegate:self];
    [self.socket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
    BOOL alreadyConnected = [self.socket isConnected];
    BLog(@"alreadyConnected:%d",alreadyConnected);
    if (!alreadyConnected)//未连接的话进行连接
    {
        NSError *error = nil;
        [self.socket connectToHost:HOST onPort:PORT withTimeout:TIME_OUT error:&error];
    }
}


-(void)cutOffSocket
{
    self.socket.userData = SocketOfflineByUser;
    [self.socket disconnect];
    [self.heartTimer invalidate];
}


- (NSData *)jsonDataWithChatMessage:(NSString *)message toUser:(NSString *)user{
    NSAssert(message, @"should not be nil");
    NSAssert(user, @"should not be nil");
    NSDictionary *d = @{@"user_name":user,
                        @"content":message};
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:d
                                                       options:0
                                                         error:&error];
    if (error) {
        [self.vc logMeta:@"转换成jsonData失败"];
    }
    return jsonData;
}

- (void)sendChatMessage:(NSString *)message toUser:(NSString *)user
{
    //向服务器发送数据
    NSData *msgData = [self jsonDataWithChatMessage:message toUser:user];
    Byte *msgByte = (Byte *)[msgData bytes];
    unsigned long packLength = msgData.length + 16;

    Byte baotou[16] ;
    BruteForceCoding *brute = [[BruteForceCoding alloc]init];
    //移位
    //package length
    int offset = [brute encodeIntBigEndian:baotou val:packLength offset:0 size:4];

    //header length
    offset = [brute encodeIntBigEndian:baotou val:16 offset:offset size:2];

    //ver
    offset = [brute encodeIntBigEndian:baotou val:2 offset:offset size:2];

    //operation
    offset = [brute encodeIntBigEndian:baotou val:4/*OP_SEND_SMS*/ offset:offset size:4];

    //Sequence Id
    offset = [brute encodeIntBigEndian:baotou val:3 offset:offset size:4];
    //移位后结果转化成NSData发送到服务器进行认证
    NSInteger baotouLength = sizeof(baotou);
    NSInteger msgLength = [msgData length];
    Byte *resultByte = [brute addByte1:baotou andLength:baotouLength andByte2:msgByte andLength:msgLength];
    NSData *data = [NSData dataWithBytes:resultByte length:baotouLength + msgLength];
    [self.socket writeData:data withTimeout:TIME_OUT tag:101];
    [self.vc logMeta:@"SMS包已发离本机，服务器尚未收到"];
}

//发送认证消息
-(void)sendAuthWithToken:(NSString *)token{
    NSString *msg = token;
    NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    Byte *msgByte = (Byte *)[msgData bytes];
    unsigned long packLength = msg.length + 16;

    Byte baotou[16] ;
    BruteForceCoding *brute = [[BruteForceCoding alloc]init];
    //移位
    //package length
    int offset = [brute encodeIntBigEndian:baotou val:packLength offset:0 size:4];

    //header length
    offset = [brute encodeIntBigEndian:baotou val:16 offset:offset size:2];

    //ver
    offset = [brute encodeIntBigEndian:baotou val:2 offset:offset size:2];

    //operation
    offset = [brute encodeIntBigEndian:baotou val:7 offset:offset size:4];

    //Sequence Id
    offset = [brute encodeIntBigEndian:baotou val:2 offset:offset size:4];
    //移位后结果转化成NSData发送到服务器进行认证
    NSInteger baotouLength = sizeof(baotou);
    NSInteger msgLength = [msgData length];
    Byte *resultByte = [brute addByte1:baotou andLength:baotouLength andByte2:msgByte andLength:msgLength];
    NSData *data = [NSData dataWithBytes:resultByte length:baotouLength + msgLength];
    [self.socket writeData:data withTimeout:TIME_OUT tag:101];
    [self.vc logMeta:@"authWrite认证包已发离本机，服务器尚未收到"];
}

//发送心跳
-(void)heartBeatWrite{
    NSString *msg = @"";
    NSData *msgData = [msg dataUsingEncoding:NSUTF8StringEncoding];
    Byte *msgByte = (Byte *)[msgData bytes];
    unsigned long packLength = msgData.length + 16;
    
    Byte baotou[16] ;
    BruteForceCoding *brute = [[BruteForceCoding alloc]init];
    //移位
    //package length
    int offset = [brute encodeIntBigEndian:baotou val:packLength offset:0 size:4];
    
    //header length
    offset = [brute encodeIntBigEndian:baotou val:16 offset:offset size:2];
    
    //ver
    offset = [brute encodeIntBigEndian:baotou val:1 offset:offset size:2];
    
    //operation
    offset = [brute encodeIntBigEndian:baotou val:2/*OP_HEARTBEAT*/ offset:offset size:4];
    
    //Sequence Id
    offset = [brute encodeIntBigEndian:baotou val:1 offset:offset size:4];
    //移位后结果转化成NSData发送到服务器进行认证
    NSInteger baotouLength = sizeof(baotou);
    NSInteger msgLength = [msgData length];
    Byte *resultByte = [brute addByte1:baotou andLength:baotouLength andByte2:msgByte andLength:msgLength];
    NSData *data = [NSData dataWithBytes:resultByte length:baotouLength + msgLength];
    [self.socket writeData:data withTimeout:TIME_OUT tag:101];
    [self.vc logMeta:@"心跳包已发离本机，服务器尚未收到"];
    NSLog(@"-----------------------【heartBeatWrite Done】");
}


#pragma mark - Delegate

- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSString *meta = [NSString stringWithFormat:@"onSocketDidDisconnect，reason:%@",[LJSocketServe stringFromOfflineBy:sock.userData]];[self.vc logMeta:meta];

    [NSThread sleepForTimeInterval:2];

    NSLog(@"----------------【onSocketDidDisconnect】 %ld",sock.userData);
    
    if (sock.userData == SocketOfflineByServer) {
        // 服务器掉线，重连
        [self startConnectSocket];
    }
    else if (sock.userData == SocketOfflineByUser) {
        
        // 如果由用户断开，不进行重连
        return;
    }else if (sock.userData == SocketOfflineByWifiCut) {
        
        // wifi断开，两秒发送一次请求
        [self startConnectSocket];
    }
    
}

+ (NSString *)stringFromOfflineBy:(long)offlineBy{
    if (offlineBy == SocketOfflineByServer) {
        return @"byServer";
    } else if (offlineBy == SocketOfflineByUser){
        return @"byUser";
    } else if (offlineBy == SocketOfflineByWifiCut){
        return @"byWifiCut";
    }
    return @"未知OfflineBy";
}

- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"-------------willDisconnectWithError");
    NSString *meta = [NSString stringWithFormat:@"willDisconnectWithError"];[self.vc logMeta:meta];

    NSData * unreadData = [sock unreadData]; // ** This gets the current buffer
    meta = [NSString stringWithFormat:@"未读数据长度 %ld",unreadData.length];[self.vc logMeta:meta];
    if(unreadData.length > 0) {
        [self onSocket:sock didReadData:unreadData withTag:0]; // ** Return as much data that could be collected
    } else {
        meta = [NSString stringWithFormat:@"willDisconnectWithError %ld   err = %@",sock.userData,[err description]];[self.vc logMeta:meta];
        NSLog(@" willDisconnectWithError %ld   err = %@",sock.userData,[err description]);
        if (err.code == 57) {
            self.socket.userData = SocketOfflineByWifiCut;
        }
    }
    
}



- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"-------------------didAcceptNewSocket");
    NSString *meta = [NSString stringWithFormat:@"didAcceptNewSocket"];
    [self.vc logMeta:meta];

}


- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    //这是异步返回的连接成功，
    NSLog(@"-------------【didConnectToHost %@:%d】",host,port);
    NSString *meta = [NSString stringWithFormat:@"didConnectToHost %@:%d",host,port];[self.vc logMeta:meta];
}


//接受消息成功之后回调
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSLog(@"-------------【didReadData】");
    NSString *meta = [NSString stringWithFormat:@"didReadData,dataLength:%ld,tag:%ld",data.length,tag];[self.vc logMeta:meta];

    //服务端返回消息数据量比较大时，可能分多次返回。所以在读取消息的时候，设置MAX_BUFFER表示每次最多读取多少，当data.length < MAX_BUFFER我们认为有可能是接受完一个完整的消息，然后才解析
    if( data.length < MAX_BUFFER )
    {
        
        //从服务器发送的数据中减去前16字节的格式协议
        NSInteger dataLength = data.length;
        Byte *inBuffer = malloc(MAX_BUFFER);
        inBuffer = (Byte *)[data bytes];
        BruteForceCoding *brute = [[BruteForceCoding alloc]init];
        Byte *resultByte = [brute tail:inBuffer anddataLengthLength:dataLength andHeaderLength:16];
        
        //解析指令，不同指令执行不同的操作
        NSInteger operation = [brute decodeIntBigEndian:inBuffer offset:8 size:4];
        if (3 == operation/*OP_HEARTBEAT_REPLY*/) {
            [self.vc logMeta:@"did receive OP_HEARTBEAT_REPLY 收到心跳包回复"];
        } else if (8 == operation/*OP_AUTH_REPLY*/) {
            [self.vc logMeta:@"did receive OP_AUTH_REPLY 认证成功。立即开始发心跳包，并每5秒再发一个"];
            //通过定时器不断发送消息，来检测长连接
            self.heartTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(heartBeatWrite) userInfo:nil repeats:YES];
            [self.heartTimer fire];
        } else if (5 == operation/*OP_SEND_SMS_REPLY*/) {
            //解析出body内容
            NSData *data = [NSData dataWithBytes:resultByte length:dataLength - 16];
            NSString *meta = [NSString stringWithFormat:@"did receive OP_SEND_SMS_REPLY，长度为%ld(0表示发送成功，大于0是别人给我发)",data.length]; [self.vc logMeta:meta];
            if (data.length > 0){
                NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                [self.vc logChatMessage:string];
                BLog(@"%@",string);
            }
        }
    }

    [self.socket readDataWithTimeout:READ_TIME_OUT buffer:nil bufferOffset:0 maxLength:MAX_BUFFER tag:0];
    
}


//发送消息成功之后回调
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    NSLog(@"-------------【didWriteDataWithTag:%ld",tag);
    NSString *meta = [NSString stringWithFormat:@"didWriteDataWithTag:%ld",tag];[self.vc logMeta:meta];
    //读取消息
    [self.socket readDataWithTimeout:-1 buffer:nil bufferOffset:0 maxLength:MAX_BUFFER tag:0];
}





@end
