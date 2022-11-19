//
//  YYWKWebVC.m
//  CloudPay_Example
//
//  Created by 郑隋 on 2022/10/21.
//  Copyright © 2022 ZhengSu. All rights reserved.
//

#import "YYWKWebVC.h"
#import <WebKit/WebKit.h>
#import <CloudPay/CloudPay.h>
#import "WKWebViewJavascriptBridge.h"
@interface YYWKWebVC ()
@property (nonatomic, strong) WKWebView *  webView;
@property (nonatomic, strong) NSString *payResulturl;

@property (nonatomic, strong) WKWebViewJavascriptBridge *bridge;
@end

@implementation YYWKWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];

    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];

    [[CloudPay defaultManager] cloudPayWithWebViewJavascriptBridge:self.bridge success:^(NSString * _Nonnull resultUrl) {

        self.payResulturl = resultUrl;

    } failure:^(CloudPay_Status status) {

        if(status == CloudPay_WXAppUnInstalled){
            //提示用户 【请先安装微信】
        }else if(status == CloudPay_ALiPayAppUninstall){
            //提示用户 【请先安装支付宝】
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealPayResult:) name:CLOUDPAY_RESULT object:nil];
}
- (void)dealPayResult:(NSNotification *)noti{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.payResulturl]]];
}

- (WKWebView *)webView{
    if(_webView == nil){

        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];

        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://catering.uat.hhtdev.com/cloud-business-platform-mobile/#/mcashier/demo"]];
        [_webView loadRequest:request];
    }
    return _webView;
}
@end
