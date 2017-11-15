//
//  CommunicateManager.m
//  LANTalk
//
//  Created by SaturdayNight on 26/07/2017.
//  Copyright © 2017 SaturdayNight. All rights reserved.
//

#import "CommunicateManager.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <netdb.h>

#define BUFFER_SIZE 1024
#define PORT 6680

@interface CommunicateManager ()

@property (nonatomic,assign) BOOL isClosed;
@property (nonatomic, assign) int serverSocket;
@property (nonatomic, assign) int clientSocket;

@end

@implementation CommunicateManager

+(instancetype)shareInstance
{
    static CommunicateManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CommunicateManager alloc] init];
    });
    
    return manager;
}

-(void)socketServerPrepare
{
    // 创建Socket
    self.serverSocket = socket(AF_INET, SOCK_STREAM, 0);
    
    // sockfd为需要端口复用的套接字
    int opt = 1;
    setsockopt(self.serverSocket, SOL_SOCKET, SO_REUSEADDR, (const void *)&opt, sizeof(opt));
    
    if (self.serverSocket > 0) {
        NSLog(@"Socket 创建成功 %d", self.serverSocket);
        NSString *info = [NSString stringWithFormat:@"Socket 创建成功 %d", self.serverSocket];
        if (self.CommunicateManagerInfoCallBack) {
            self.CommunicateManagerInfoCallBack(info);
        }
    } else {
        NSLog(@"Socket 创建失败");
        if (self.CommunicateManagerInfoCallBack) {
            self.CommunicateManagerInfoCallBack(@"Socket 创建失败");
        }
    }
    
    // 创建服务器地址结构体
    struct sockaddr_in serverAddress;
    bzero(&serverAddress, sizeof(serverAddress));
    serverAddress.sin_family      = AF_INET;
    serverAddress.sin_port        = htons(PORT);
    serverAddress.sin_addr.s_addr = inet_addr(self.serverIP.UTF8String);
    
    int isBind = bind(self.serverSocket, (const struct sockaddr *)&serverAddress, sizeof(serverAddress));
    
    if (isBind) {
        NSLog(@"绑定失败 %d", isBind);
        NSString *info = [NSString stringWithFormat:@"绑定失败 %d",isBind];
        if (self.CommunicateManagerInfoCallBack) {
            self.CommunicateManagerInfoCallBack(info);
        }
        return;
    } else {
        NSLog(@"绑定成功");
        if (self.CommunicateManagerInfoCallBack) {
            self.CommunicateManagerInfoCallBack(@"绑定成功");
        }
    }
    
    int isListen = listen(self.serverSocket, 10);
    
    if (isListen) {
        NSLog(@"监听失败 %d", isListen);
        NSString *info = [NSString stringWithFormat:@"监听失败 %d",isListen];
        if (self.CommunicateManagerInfoCallBack) {
            self.CommunicateManagerInfoCallBack(info);
        }
        return;
    } else {
        NSLog(@"监听成功");
        if (self.CommunicateManagerInfoCallBack) {
            self.CommunicateManagerInfoCallBack(@"监听成功");
        }
    }
    
    if (self.CommunicateManagerInfoCallBack) {
        self.CommunicateManagerInfoCallBack(@"Server Start...");
    }

        //接受一个到server_socket代表的socket的一个连接
        //如果没有连接请求,就等待到有连接请求--这是accept函数的特性
        //accept函数返回一个新的socket,这个socket(new_server_socket)用于同连接到的客户的通信
        //new_server_socket代表了服务器和客户端之间的一个通信通道
        //accept函数把连接到的客户端信息填写到客户端的socket地址结构client_addr中
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //定义客户端的socket地址结构client_addr
            struct sockaddr_in client_addr;
            socklen_t length = sizeof(client_addr);
            
            int new_client_socket = accept(self.serverSocket,(struct sockaddr*)&client_addr,&length);
            if ( new_client_socket < 0)
            {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.CommunicateManagerInfoCallBack) {
                    self.CommunicateManagerInfoCallBack(@"Server Accept Failed!");
                }
              });
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
            if (self.CommunicateManagerInfoCallBack) {
                self.CommunicateManagerInfoCallBack(@"one client connted..");
            }
            });
            
            [NSThread detachNewThreadSelector:@selector(readData:)
                                     toTarget:self
                                   withObject:[NSNumber numberWithInt:new_client_socket]];
        });
}

-(void)socketClientPrepare
{
    NSString *host = self.destIP;
    NSNumber *myPort = [NSNumber numberWithInt:PORT];
    ;
    // 创建 socket
    self.clientSocket = socket(AF_INET, SOCK_STREAM, 0);
    int opt = 1;
    // sockfd为需要端口复用的套接字
    setsockopt(self.clientSocket, SOL_SOCKET, SO_REUSEADDR, (const void *)&opt, sizeof(opt));
    if (-1 == self.clientSocket) {
        NSLog(@"创建失败");
        NSString *info = [NSString stringWithFormat:@"创建失败"];
        if (self.CommunicateManagerInfoCallBack) {
            self.CommunicateManagerInfoCallBack(info);
        }
    }
    // 获取 IP 地址
    struct hostent * remoteHostEnt = gethostbyname([host UTF8String]);
    if (NULL == remoteHostEnt) {
        close(self.clientSocket);
        NSLog(@"%@",@"无法解析服务器的主机名");
        NSString *info = [NSString stringWithFormat:@"%@",@"无法解析服务器的主机名"];
                if (self.CommunicateManagerInfoCallBack) {
                    self.CommunicateManagerInfoCallBack(info);
                }
    }
    struct in_addr * remoteInAddr = (struct in_addr *)remoteHostEnt->h_addr_list[0];
    // 设置 socket 参数
    struct sockaddr_in socketParameters;
    socketParameters.sin_family = AF_INET;
    socketParameters.sin_addr = *remoteInAddr;
    socketParameters.sin_port = htons([myPort intValue]);
    // 连接 socket
    int ret = connect(self.clientSocket, (struct sockaddr *) &socketParameters, sizeof(socketParameters));
    if (-1 == ret) {
        close(self.clientSocket);
        NSLog(@"连接失败");
        NSString *info = [NSString stringWithFormat:@"连接失败"];
        if (self.CommunicateManagerInfoCallBack) {
            self.CommunicateManagerInfoCallBack(info);
        }
        
        return;
    }
    
    if (self.CommunicateManagerInfoCallBack) {
        self.CommunicateManagerInfoCallBack(@"连接目标服务器成功!");
    }
}

// 读客户端数据
-(void)readData:(NSNumber*) clientSocket{
    char buffer[BUFFER_SIZE];
    int intSocket = [clientSocket intValue];
    
    while(buffer[0] != '-'){
        
        bzero(buffer,BUFFER_SIZE);
        //接收客户端发送来的信息到buffer中
        long size = recv(intSocket,buffer,BUFFER_SIZE,0);
        
        //printf("client:%s\n",buffer);
        NSString *message = [NSString stringWithUTF8String:buffer];
        if (message.length > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.CommunicateManagerReceiveMessageCallBack) {
                    self.CommunicateManagerReceiveMessageCallBack(message);
                }
            });
        }
    }
    //关闭与客户端的连接
    printf("client:close\n");
    close(intSocket);
}

-(void)sendMessage:(NSString *)message
{
    const char* ms = [[NSString stringWithFormat:@"%@",message] UTF8String];
    long resutl = send(self.clientSocket, ms, BUFFER_SIZE, 0);
    
    //self.CommunicateManagerInfoCallBack([NSString stringWithFormat:@"send result%li",resutl]);
}

@end
