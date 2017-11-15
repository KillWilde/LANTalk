//
//  CommunicateManager.h
//  LANTalk
//
//  Created by SaturdayNight on 26/07/2017.
//  Copyright © 2017 SaturdayNight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommunicateManager : NSObject

@property (nonatomic,copy) NSString *destIP;
@property (nonatomic,copy) NSString *serverIP;

@property (nonatomic,copy) void (^CommunicateManagerInfoCallBack)(NSString *info);
@property (nonatomic,copy) void (^CommunicateManagerReceiveMessageCallBack)(NSString *message);

+(instancetype)shareInstance;

-(void)socketServerPrepare;
-(void)socketClientPrepare;

-(void)sendMessage:(NSString *)message;

@end
