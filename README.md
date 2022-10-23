


### 第一步: 集成SDK
CocoaPods:

1.  在 Podfile 中添加 ```pod  'CloudPay```
2.  执行 ```pod install``` 或 ```pod update```
3.  导入头文件``` #import "CloudPay.h"```

         pod  'CloudPay' 

### 第二步: 注册微信appid ，设置Associated Domains

商户在微信开放平台申请开发APP应用后，微信开放平台会生成APP的唯一标识APPID。在Xcode中打开项目，设置项目属性中的URL Schemes为您的APPID

另外添加一个URL Schemes，值为```CloudAliPay```，如图所示：

![](https://upload-images.jianshu.io/upload_images/1154433-5546eb12058aaa2a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


在 AppDelegate.m 文件中，增加引用代码：

```
#import "CloudPay.h"
```
1.调用API前，需要先向微信注册您的APPID，代码如下：

    [CloudPay registerApp:@"wxd930ea5d5a258f4f" universalLink:@"applinks:catering.yonyou.com"];

其中 APPID和universalLink需要替换成自己平台的

2.添加Associated Domains，值为：```applinks:catering.yonyou.com```  如图：

![image.png](https://upload-images.jianshu.io/upload_images/1154433-e8aa69a7de2ff7ef.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)



### 第三步: 在WKWebVeiw中掉起支付
引用头文件：

```
#import "CloudPay.h"
```

```
    [[CloudPay defaultManager] cloudPayWithWebview:self.webView success:^(NSString * _Nonnull resultUrl) {

        self.payResulturl = resultUrl;

    } failure:^(CloudPay_Status status) {

        if(status == CloudPay_WXAppUnInstalled){
            //提示用户 【请先安装微信】
        }else if(status == CloudPay_ALiPayAppUninstall){
            //提示用户 【请先安装支付宝】
        }
    }];
```

### 第四步: 配置返回 URL 处理方法
本步骤指引开发者配置【支付宝客户端】或 【微信客户端】返回 URL 处理方法
在```AppDelegate```中调用如下方法：

```
#pragma mark -- 通过 URL Schemes 启动App时调用
-(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    BOOL result = [CloudPay handleOpenURL:url];
    
    if(!result){
        //这里处理其他SDK(例如QQ登录,微博登录等)
    }
    return result;
}
```
如果使用的是``` Universal Link```则在该方法中调用：

```
    #pragma mark -- 通过 Universal Link 启动App时调用
    -(BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler{
    BOOL result = [CloudPay handleOpenUniversalLink:userActivity];
    
    if(!result){
        //这里处理其他SDK(例如QQ登录,微博登录等)
    }
    return result;
}
```
### 第五步: 在WKWebVeiw中接收支付结果通知

支付成功后SDK会发送一个CLOUDPAY_RESULT通知，用户需要在WKWebVeiw进行接收处理

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dealPayResult:) name:CLOUDPAY_RESULT object:nil];



    - (void)dealPayResult:(NSNotification *)noti{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.payResulturl]]];
    }


