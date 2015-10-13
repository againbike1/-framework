//
//  WJNetworking.m
//  WJNetworking
//
//  Created by apple on 15/10/9.
//  Copyright (c) 2015年 tqh. All rights reserved.
//

#import "WJNetworking.h"

static BOOL isFirst = NO;
static BOOL canCHeckNetwork = NO;

@interface WJNetworking () {
    
}
@property (nonatomic,assign)NSInteger timeoutID;
@end

@implementation WJNetworking

+ (void)netWorkingIsGetWithURL:(NSString *)urlpath param:(NSDictionary *)dict success:(SuccessBlock)succsess fail:(FailBlock)fail {
    //1..检查网络连接(苹果公司提供的检查网络的第三方库 Reachability)
    //AFN 在 Reachability基础上做了一个自己的网络检查的库, 基本上一样
    [self start];
    //2..实现解析
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 30;
    [manager GET:urlpath parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
        //成功 
        NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        succsess(obj);
        [self stop];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //失败
        NSLog(@"error: %@",error.localizedDescription);
        fail(error);
        [self stop];
    }];
}


+ (void)netWorkingIsPostWithURL:(NSString *)urlpath param:(NSDictionary *)dict success:(SuccessBlock)succsess fail:(FailBlock)fail {
    [self start];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //请求超时,默认60秒，afnetworking默认的60秒
    manager.requestSerializer.timeoutInterval = 30;
    [manager POST:urlpath parameters:dict success:^(NSURLSessionDataTask *task, id responseObject) {
//        [task cancel];
        NSDictionary *obj = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        succsess(obj);
        [self stop];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error: %@",error.localizedDescription);
        fail(error);
        [self stop];
    }];
}

/*
 网络请求开始,hud等等都在这里加入
 */
+ (void)start {
    [self reachability:^{
        
    }];
//    static NSInteger timeoutID = 0;
//    timeoutID ++;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"链接超时");
//       
//    });
}

/*
 网络请求结束,hud等等都在这里结束
 */

+ (void)stop {
//    requestfinish = YES;
}

/**
 检测网络连接状态,wifi,WWAN
 *
 */
+ (void)reachability:(dispatch_block_t)block {
    if (isFirst == NO) {
        //实时监测网络连接状态
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
        [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            canCHeckNetwork = YES;
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                    NSLog(@"未知网络");
                    break;
                case AFNetworkReachabilityStatusNotReachable:
                    NSLog(@"无网络");
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    NSLog(@"无线网络");
                    break;
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    NSLog(@"wifi网络");
                    break;
                    
                default:
                    break;
            }
            
        }];
        isFirst = YES;
    }
//    //只能在监听完善之后才可以调用
    BOOL isOK = [[AFNetworkReachabilityManager sharedManager] isReachable];
////    BOOL isWifiOK = [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
////    BOOL is3GOK = [[AFNetworkReachabilityManager sharedManager]isReachableViaWWAN];
    //因为上面是异步的，所以要这样判定
    if(isOK == NO && canCHeckNetwork == YES){
        block();
        NSLog(@"网络连接失败");
        return ;
    }
}

@end
