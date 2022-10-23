//
//  YYViewController.m
//  CloudPay
//
//  Created by ZhengSu on 10/21/2022.
//  Copyright (c) 2022 ZhengSu. All rights reserved.
//

#import "YYViewController.h"
#import "YYWKWebVC.h"
@interface YYViewController ()

@end

@implementation YYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    payBtn.frame = CGRectMake(20, 100, self.view.frame.size.width - 40, 50);
    payBtn.backgroundColor = [UIColor lightGrayColor];
    [payBtn setTitle:@"去支付" forState:0];
    [payBtn addTarget:self action:@selector(payClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:payBtn];
}
- (void)payClick{
    [self.navigationController pushViewController:[YYWKWebVC new] animated:YES];
}

@end
