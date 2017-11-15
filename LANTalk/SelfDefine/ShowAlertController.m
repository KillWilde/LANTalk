//
//  ShowAlertController.m
//  未来家庭
//
//  Created by Megatron on 11/7/16.
//  Copyright © 2016 Megatron. All rights reserved.
//

#import "ShowAlertController.h"

@implementation ShowAlertController

+(void)showAlertInVC:(UIViewController *)vc message:(NSString *)message title:(NSString *)title
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    if (message) {
        NSMutableAttributedString *alertControllerMessageStr = [[NSMutableAttributedString alloc] initWithString:message];
        [alertControllerMessageStr addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:NSMakeRange(0, message.length)];
        [alertControllerMessageStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, message.length)];
        [alert setValue:alertControllerMessageStr forKey:@"attributedMessage"];
    }
    
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        
    }];
    //[actionOK setValue:NavBarBGColor forKey:@"titleTextColor"];
    
    [alert addAction:actionOK];
    
    
    alert.popoverPresentationController.sourceView = vc.view;
    alert.popoverPresentationController.sourceRect = CGRectMake(vc.view.bounds.size.width / 2.0, vc.view.bounds.size.height, 1, 1);
    
    [vc presentViewController:alert animated:YES completion:nil];
}

@end
