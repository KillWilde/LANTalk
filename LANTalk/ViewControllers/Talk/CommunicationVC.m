//
//  CommunicationVC.m
//  LANTalk
//
//  Created by SaturdayNight on 26/07/2017.
//  Copyright © 2017 SaturdayNight. All rights reserved.
//

#import "CommunicationVC.h"
#import "CommunicateManager.h"

@interface CommunicationVC () <UITextFieldDelegate,UITextViewDelegate>

@property (nonatomic,strong) UITextField *txUserInput;
@property (nonatomic,strong) UITextView *txvContent;

@end

@implementation CommunicationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    if (self.name.length == 0) {
        self.name = @"螃蟹大元帅🦀";
    }
    
    [self.view addSubview:self.txvContent];
    [self.view addSubview:self.txUserInput];
    
    // 初始化聊天服务
    __weak typeof(self) weakSelf = self;
    [CommunicateManager shareInstance].CommunicateManagerInfoCallBack = ^(NSString *info){
        weakSelf.txvContent.text = [_txvContent.text stringByAppendingFormat:@"%@\n",info];
        
        [weakSelf.txvContent scrollRangeToVisible:NSMakeRange(weakSelf.txvContent.text.length - 1, 1)];
    };
    
    [CommunicateManager shareInstance].CommunicateManagerReceiveMessageCallBack = ^(NSString *message){
        weakSelf.txvContent.text = [_txvContent.text stringByAppendingFormat:@"%@\n",message];
        
        [weakSelf.txvContent scrollRangeToVisible:NSMakeRange(weakSelf.txvContent.text.length - 1, 1)];
    };
}

#pragma mark - Delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.txUserInput.frame = CGRectMake(0, SCREEN_HEIGHT - 40 - 260, SCREEN_WIDTH, 40);
        self.txvContent.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 40 - 260);
    } completion:^(BOOL finished) {
        
    }];
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[CommunicateManager shareInstance] sendMessage:[NSString stringWithFormat:@"%@:%@",self.name,textField.text]];
    _txvContent.text = [_txvContent.text stringByAppendingFormat:@"%@:%@\n",self.name,textField.text];
    textField.text = @"";
    
    return YES;
}

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

#pragma mark - LazyLoad
-(UITextField *)txUserInput
{
    if (!_txUserInput) {
        _txUserInput = [[UITextField alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 40, SCREEN_WIDTH, 40)];
        _txUserInput.borderStyle = UITextBorderStyleRoundedRect;
        _txUserInput.returnKeyType = UIReturnKeySend;
        _txUserInput.delegate = self;
    }
    
    return _txUserInput;
}

-(UITextView *)txvContent
{
    if (!_txvContent) {
        _txvContent = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 40)];
        _txvContent.backgroundColor = [UIColor orangeColor];
        _txvContent.selectable = NO;
    }
    
    return _txvContent;
}

@end
