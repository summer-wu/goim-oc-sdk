//
//  ViewController.m
//  AsyncSocketDemo
//
//  Created by 刘佳 on 15/4/3.
//  Copyright (c) 2015年 刘佳. All rights reserved.
//

#import "ViewController.h"
#import "LJSocketServe.h"

#define kSocketServe [LJSocketServe sharedSocketServe]
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *tv0;//聊天文字
@property (weak, nonatomic) IBOutlet UITextView *tv1;//meta信息
@property (weak, nonatomic) IBOutlet UITextField *authTf;
@property (weak, nonatomic) IBOutlet UITextField *msgTf;
@property (weak, nonatomic) IBOutlet UITextField *toUserTf;

@end

@implementation ViewController

- (void)viewDidLoad {
    self.tv0.layer.borderWidth = 1;
    self.tv1.layer.borderWidth = 1;

    [super viewDidLoad];
    kSocketServe.vc = self;
    [kSocketServe cutOffSocket];
    kSocketServe.socket.userData = SocketOfflineByServer;
}

- (IBAction)connectClicked:(id)sender {
    [self logMeta:@"点击了 连接服务器 按钮"];
    [kSocketServe startConnectSocket];

}

- (IBAction)authClicked:(id)sender {
    NSString *authToken = self.authTf.text;//如果输入了就用输入的，没有就用placeholder
    if (0 == authToken.length) {
        authToken = self.authTf.placeholder;
    }
    NSString *meta = [NSString stringWithFormat:@"点击了 认证 按钮，用于认证的字符串是:%@",authToken]; [self logMeta:meta];
    [kSocketServe sendAuthWithToken:authToken];
}

- (IBAction)cleanTVs:(id)sender {
    self.tv0.text = @"";
    self.tv1.text = @"";
}

- (IBAction)disconnectClicked:(id)sender {
    [kSocketServe cutOffSocket];
}

#define kTipAlert(_S_, ...)     [[[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:(_S_), ##__VA_ARGS__] delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil] show]

- (IBAction)sendClicked:(id)sender {
    NSString *txt = self.msgTf.text;
    if (0 == txt.length) {
        txt = self.msgTf.placeholder;
    }

    NSString *toUser = self.toUserTf.text;
    if (0 == toUser.length) {
        toUser = self.toUserTf.placeholder;
    }

    NSString *meta = [NSString stringWithFormat:@"点击了 发送 按钮，要发送的字符串是:%@",txt]; [self logMeta:meta];
    NSString *chat = [NSString stringWithFormat:@"我说:%@",txt]; [self logChatMessage:chat];
    [kSocketServe sendChatMessage:txt toUser:toUser];
    self.msgTf.text = @"";
}


- (void)logChatMessage:(NSString *)chatMessage{
    NSString *s = [NSString stringWithFormat:@"%@ %@\n%@",[self dateStr],chatMessage,self.tv0.text];
    self.tv0.text = s;
}

- (void)logMeta:(NSString *)meta{
    NSString *s = [NSString stringWithFormat:@"%@ %@\n%@",[self dateStr],meta,self.tv1.text];
    self.tv1.text = s;
}

- (NSString *)dateStr{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init ];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString * dateStr = [dateFormatter stringFromDate:[NSDate date]];
    return dateStr;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
