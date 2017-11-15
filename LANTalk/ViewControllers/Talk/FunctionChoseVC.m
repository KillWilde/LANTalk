//
//  FunctionChoseVC.m
//  LANTalk
//
//  Created by SaturdayNight on 26/07/2017.
//  Copyright © 2017 SaturdayNight. All rights reserved.
//

#import "FunctionChoseVC.h"
#import "CommunicationVC.h"
#import "CommunicateManager.h"
#import "ShowAlertController.h"
#import "NetworkManager.h"

@interface FunctionChoseVC () <UITextFieldDelegate>

@property (nonatomic,strong) UITextField *txServerIP;
@property (nonatomic,strong) UITextField *txDestIP;
@property (nonatomic,strong) UIButton *btnServer;
@property (nonatomic,strong) UIButton *btnClient;
@property (nonatomic,strong) UIButton *btnTalk;

@property (nonatomic,strong) UITextView *txvContent;

@end

@implementation FunctionChoseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.txvContent];
    [self.view addSubview:self.txServerIP];
    [self.view addSubview:self.txDestIP];
    [self.view addSubview:self.btnServer];
    [self.view addSubview:self.btnClient];
    [self.view addSubview:self.btnTalk];
    
    NSString *ip = [NetworkManager getIpAddresses];
    if (ip && ip.length > 0) {
        self.txServerIP.text = ip;
    }
    else
    {
        [ShowAlertController showAlertInVC:self message:@"请检查是否连接路由器。。。" title:@"获取IP失败"];
    }
}

#pragma mark - EventResponse
-(void)btnServerClicked:(UIButton *)sender
{
    if (self.txServerIP.text.length <= 0) {
        [ShowAlertController showAlertInVC:self message:@"服务器IP不能为空！" title:@"开启服务器失败"];
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [CommunicateManager shareInstance].CommunicateManagerInfoCallBack = ^(NSString *info){
        weakSelf.txvContent.text = [weakSelf.txvContent.text stringByAppendingFormat:@"%@\n",info];
        
        [weakSelf.txvContent scrollRangeToVisible:NSMakeRange(weakSelf.txvContent.text.length - 1, 1)];
    };
    
    [CommunicateManager shareInstance].serverIP = self.txServerIP.text;
    [[CommunicateManager shareInstance] socketServerPrepare];
}

-(void)btnClientClicked:(UIButton *)sender
{
    if (self.txServerIP.text.length <= 0) {
        [ShowAlertController showAlertInVC:self message:@"服务器IP不能为空！" title:@"连接目标服务器失败"];
        
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    
    [CommunicateManager shareInstance].CommunicateManagerInfoCallBack = ^(NSString *info){
        weakSelf.txvContent.text = [weakSelf.txvContent.text stringByAppendingFormat:@"%@\n",info];
        
        [weakSelf.txvContent scrollRangeToVisible:NSMakeRange(weakSelf.txvContent.text.length - 1, 1)];
        
        if ([info isEqualToString:@"连接目标服务器成功!"]) {
            weakSelf.btnTalk.hidden = NO;
        }
    };
    
    [CommunicateManager shareInstance].destIP = self.txDestIP.text;
    [[CommunicateManager shareInstance] socketClientPrepare];
}

-(void)btnTalkClicked:(UIButton *)sender
{
    NSString *title = @"先给自己取个名字吧";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"输入昵称";
    
    }];
    
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        CommunicationVC *vc = [[CommunicationVC alloc] init];
        vc.name = alert.textFields.firstObject.text;
        
        [self.navigationController pushViewController:vc animated:YES];
    }];
    
    //[actionOK setValue:NavBarBGColor forKey:@"titleTextColor"];
    
    [alert addAction:actionOK];
    
    
    alert.popoverPresentationController.sourceView = self.view;
    alert.popoverPresentationController.sourceRect = CGRectMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height, 1, 1);
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Delegate
#pragma mark UITextFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.txServerIP.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5 - 50);
        self.txDestIP.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5 );
    } completion:^(BOOL finished) {
        
    }];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.txServerIP.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5 + 50);
        self.txDestIP.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5 + 100);
    } completion:^(BOOL finished) {
        
    }];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

#pragma mark - LazyLoad
-(UIButton *)btnServer
{
    if (!_btnServer) {
        _btnServer = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnServer.frame = CGRectMake(0, 350, 200, 40);
        _btnServer.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5 + 150);
        [_btnServer setTitle:@"启动服务器" forState:UIControlStateNormal];
        [_btnServer addTarget:self action:@selector(btnServerClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnServer;
}

-(UIButton *)btnClient
{
    if (!_btnClient) {
        _btnClient = [UIButton buttonWithType:UIButtonTypeSystem];
        _btnClient.frame = CGRectMake(0, 400, 200, 40);
        _btnClient.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5 + 200);
        [_btnClient setTitle:@"连接目标服务器" forState:UIControlStateNormal];
        [_btnClient addTarget:self action:@selector(btnClientClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnClient;
}

-(UIButton *)btnTalk
{
    if (!_btnTalk) {
        _btnTalk = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _btnTalk.frame = CGRectMake(0, 400, 200, 40);
        _btnTalk.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5 + 250);
        [_btnTalk setTitle:@"进入聊天" forState:UIControlStateNormal];
        [_btnTalk setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [_btnTalk addTarget:self action:@selector(btnTalkClicked:) forControlEvents:UIControlEventTouchUpInside];
        _btnTalk.hidden = YES;
    }
    
    return _btnTalk;
}

-(UITextField *)txServerIP
{
    if (!_txServerIP) {
        _txServerIP = [[UITextField alloc] initWithFrame:CGRectMake(0, 200, 200, 40)];
        _txServerIP.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5 + 50);
        _txServerIP.borderStyle = UITextBorderStyleRoundedRect;
        _txServerIP.delegate = self;
        _txServerIP.placeholder = @"输入作为服务器的IP";
    }
    
    return _txServerIP;
}

-(UITextField *)txDestIP
{
    if (!_txDestIP) {
        _txDestIP = [[UITextField alloc] initWithFrame:CGRectMake(0, 250, 200, 40)];
        _txDestIP.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5 + 100);
        _txDestIP.borderStyle = UITextBorderStyleRoundedRect;
        _txDestIP.delegate = self;
        _txDestIP.placeholder = @"请输入目标服务器的IP";
    }
    
    return _txDestIP;
}

-(UITextView *)txvContent
{
    if (!_txvContent) {
        _txvContent = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
        _txvContent.backgroundColor = [UIColor blackColor];
        _txvContent.textColor = [UIColor whiteColor];
        _txvContent.selectable = NO;
    }
    
    return _txvContent;
}

@end
