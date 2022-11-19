//
//  CloudPay.m
//  Cloud-Pay
//
//  Created by 郑隋 on 2022/10/19.
//

#import "CloudPay.h"
#import "WXAPI.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WKWebViewJavascriptBridge.h"
@interface CloudPay()<WXApiDelegate>
@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
@property (nonatomic, strong) NSString *appid;
@property (nonatomic, strong) NSString *universalLink;
@property (nonatomic, strong) NSString *appScheme;

@end
@implementation CloudPay

static CloudPay *manager = nil;
+(instancetype)defaultManager{
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}
///用alloc返回也是唯一实例
+ (id)allocWithZone:(struct _NSZone *)zone{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}

///对对象使用copy也是返回唯一实例
- (nonnull id)copyWithZone:(nullable NSZone *)zone {
    return manager;
}

 ///对对象使用mutablecopy也是返回唯一实例
- (nonnull id)mutableCopyWithZone:(nullable NSZone *)zone {
    return manager;
}

- (BOOL)registerApp:(NSString *)appid universalLink:(NSString *)universalLink appScheme:(nonnull NSString *)appScheme{
    
    self.appid = appid;
    self.universalLink = universalLink;
    self.appScheme = appScheme;
    
    return [WXApi registerApp:appid universalLink:universalLink];
}

#pragma mark 如果项目中使用了WKWebViewJavascriptBridge,则调用该方法
/*! @brief 处理H5返回的订单信息，从而根据用户选择拉起【微信】或【支付宝】
 * @param success  返回支付结果的URL
 * @param failure  用来处理支付状态，比如用户【未安装微信】或【未安装支付宝】
 */
- (void)cloudPayWithWebViewJavascriptBridge:(WKWebViewJavascriptBridge*)bridge  success:(void (^)(NSString *resultUrl))success failure:(void(^)(CloudPay_Status status))failure{
    
    self.bridge = bridge;
    
    [self.bridge registerHandler:@"getEnv" handler:^(id data, WVJBResponseCallback responseCallback) {
       if (responseCallback) {
             // 反馈给JS
             responseCallback(@"iOS");
        }
    }];

    [self.bridge registerHandler:@"getAppId" handler:^(id data, WVJBResponseCallback responseCallback) {
       if (responseCallback) {
             // 反馈给JS
           responseCallback(@{@"WXAppId":self.appid});
        }
    }];    
    
    //注册原生事件 callTradePay 供 JavaScript 调用, data 是 JavaScript 传给原生的数据。responseCallback 是原生给 JavaScript 回传数据
    [self.bridge registerHandler:@"callTradePay" handler:^(NSDictionary *data, WVJBResponseCallback responseCallback) {
        NSDictionary *payData = data[@"payResponse"];
        NSString *paySource = payData[@"paySource"];//来源
        NSString *payStatus = payData[@"payStatus"];//支付状态
        NSString *payResulturl = payData[@"url"]; //支付结果URL
        
        if([payStatus isEqualToString:@"success"]){
            NSDictionary *payDataResponse = payData[@"wxPayData"];
            
            if([paySource isEqualToString:@"wechat"]){
                if(!WXApi.isWXAppInstalled){
                    if(failure){
                        //提示用户 【请先安装微信】
                        failure(CloudPay_WXAppUnInstalled);
                        return;
                    }
                }
                if(payDataResponse == nil ){
                    if(failure){
                        //提示用户 【请先安装微信】
                        failure(CloudPay_DataError);
                        return;
                    }
                }
                if(success){
                    success(payResulturl);
                }
                PayReq *request = [[PayReq alloc] init];
                
                request.partnerId = payDataResponse[@"partnerId"];
                request.prepayId = payDataResponse[@"prepayId"];
                request.nonceStr = payDataResponse[@"nonceStr"];
                request.timeStamp = [payDataResponse[@"timeStamp"] intValue];
                request.package = payDataResponse[@"package"];
                request.sign = payDataResponse[@"sign"] ;
                [WXApi sendReq:request completion:nil];
                
                
            }else if([paySource isEqualToString:@"alipay"]){
                NSURL *alipayUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@://",self.appScheme]];
                
                if(![[UIApplication sharedApplication] canOpenURL:alipayUrl]){
                    if(failure){
                        //提示用户 【请先安装支付宝】
                        failure(CloudPay_ALiPayAppUninstall);
                        return;
                    }                    
                }
                NSString *appScheme = self.appScheme;
                if(payDataResponse == nil ){
                    if(failure){
                        //提示用户 【请先安装支付宝】
                        failure(CloudPay_DataError);
                        return;
                    }
                }
                if(success){
                    success(payResulturl);
                }
                NSString *orderString = payData[@"aliPayData"];//"后台给的订单拼接字符串"
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *result) {
                    NSLog(@"支付宝支付结果 %@",result);
                }];
            }
        }
    }];
}

+(BOOL)handleOpenURL:(NSURL *)url{
    NSString *string = url.absoluteString;
    NSString *urlStr=(__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL, (__bridge CFStringRef)string, CFSTR(""), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    
    
//    if ([urlStr containsString:@"catering.uat.hhtdev.com"] && [urlStr containsString:@"pay"]){
        if([url.host isEqualToString:@"safepay"]){
            //跳转支付宝客户端进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSLog(@"result = %@",resultDic);
                NSString * resultStatus = resultDic[@"resultStatus"];
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                param[@"CloudPay_Type"] = @"alipay";
                param[@"result"] = resultDic;
                [[NSNotificationCenter defaultCenter] postNotificationName:CLOUDPAY_RESULT object:nil userInfo:param];
            }];
            return true;
        }else if([urlStr containsString:@"pay"]){
            return [WXApi handleOpenURL:url delegate:[CloudPay defaultManager]];
        }
    return false;
}

+ (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity{
    NSURL *url = [userActivity webpageURL];
    NSString *urlStr = [url absoluteString];
    if ([urlStr containsString:@"catering.yonyou.com"] && [urlStr containsString:@"pay"]){
        if([url.host isEqualToString:@"safepay"]){
            [[AlipaySDK defaultService]processAuthResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                param[@"CloudPay_Type"] = @"alipay";
                param[@"result"] = resultDic;
                [[NSNotificationCenter defaultCenter] postNotificationName:CLOUDPAY_RESULT object:nil userInfo:param];
            }];
        }else if([urlStr containsString:@"pay"]){
            return [WXApi handleOpenUniversalLink:userActivity delegate:[CloudPay defaultManager]];
            
        }
        return true;
    }
    return false;
}

#pragma mark ---WXApiDelegate
-(void)onResp:(BaseResp *)resp{
    if([resp isKindOfClass:[PayResp class]]){
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[@"CloudPay_Type"] = @"weXin";
        param[@"result"] = resp;
        [[NSNotificationCenter defaultCenter] postNotificationName:CLOUDPAY_RESULT object:nil userInfo:param];
    }
    
}
@end
