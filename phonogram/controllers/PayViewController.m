//
//  PayViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "PayViewController.h"
#import "AppDelegate.h"
#import "PayCollectionViewCell.h"
#import "Config.h"
#import "NetUtils.h"
#import "WXApi.h"
#import "UIView+Toast.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APAuthInfo.h"
#import "APOrderInfo.h"
#import "APRSASigner.h"

@interface PayViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) IBOutlet UIButton *wxpayButton;
@property (nonatomic, assign) IBOutlet UIButton *alipayButton;
@property (nonatomic, assign) IBOutlet UIButton *paySubmitButton;
@property (nonatomic, assign) IBOutlet UICollectionView *vipListCollectionView;

@end

@implementation PayViewController {
    NSInteger currentIndex;
    NSInteger payType;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    currentIndex = 0;
    payType = 0;
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(paySuccess:)
                                                 name:kNotiPaySuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(payFailure:)
                                                 name:kNotiPayFailure
                                               object:nil];
    if(![AppDelegate sharedAppDelegate].vipList){
        [self show:@"正在加载..."];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setupVipList:)
                                                     name:kNotiVipListLoadCompleted
                                                   object:nil];
    }
}

- (void)setupVipList:(NSNotification *)noti {
    [self dismiss:nil];
    [self.vipListCollectionView reloadData];
}

- (void)paySuccess:(NSNotification *)noti {
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf updateVipList];
    }];
}

- (void)payFailure:(NSNotification *)noti {
    if([noti.object isKindOfClass:[PayResp class]]){
        PayResp *resp = noti.object;
        if(resp.errCode == -2){
            [self.view makeToast:@"支付取消"
                        duration:3.0
                        position:CSToastPositionCenter];
        } else {
            [self.view makeToast:@"支付失败"
                        duration:3.0
                        position:CSToastPositionCenter];
        }
    
    } else if([noti.object isKindOfClass:[NSDictionary class]]){
        NSDictionary *resp = noti.object;
        if([resp[@"resultStatus"] integerValue] == 6001){
            [self.view makeToast:@"支付取消"
                        duration:3.0
                        position:CSToastPositionCenter];
        } else {
            [self.view makeToast:@"支付失败"
                        duration:3.0
                        position:CSToastPositionCenter];
        }
    }
}

- (void)updateVipList {
    [AppDelegate sharedAppDelegate].vipList[currentIndex][@"is_vip"] = [NSNumber numberWithBool:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiVipChange object:nil];
}

- (IBAction)changePayway:(id)sender {
    payType = ((UIButton *)sender).tag;
    if(payType == 0){
        self.wxpayButton.enabled = NO;
        self.alipayButton.enabled = YES;
    } else if(payType == 1) {
        self.wxpayButton.enabled = YES;
        self.alipayButton.enabled = NO;
    }
}

- (IBAction)paySubmit:(id)sender {
    NSDictionary *info = [AppDelegate sharedAppDelegate].vipList[currentIndex];
    NSDictionary *params = nil;
    if(payType == 0){
        params = @{
                                 @"goods_id": info[@"id"],
                                 @"goods_num": @"1",
                                 @"payway_name": @"wxpay",
                                 @"money": info[@"real_price"]
                                 };
    } else if(payType == 1){
        params = @{
                                 @"goods_id": info[@"id"],
                                 @"goods_num": @"1",
                                 @"payway_name": @"alipay",
                                 @"money": info[@"real_price"]
                                 };
    }
    [self show:@"正在创建订单..."];
    [NetUtils postWithUrl:ORDER_URL params:params callback:^(NSDictionary *data) {
        [self dismiss:nil];
        if(data && [data[@"code"] integerValue] == 1) {
            if(payType == 0){
                [self wxpay:data[@"data"]];
            } else if(payType == 1){
                [self alipay:data[@"data"]];
            }
        } else {
            [self.view makeToast:data[@"msg"]
                            duration:3.0
                            position:CSToastPositionCenter];
        }
    }];
}



- (void)wxpay:(NSDictionary *)info {
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = info[@"params"][@"mch_id"];
    request.prepayId= info[@"params"][@"prepay_id"];
    request.package = @"Sign=WXPay";
    request.nonceStr= info[@"params"][@"nonce_str"];
    request.timeStamp = [info[@"params"][@"timestamp"] intValue];
    request.sign= info[@"params"][@"sign"];
    [WXApi sendReq:request];
}

- (void)alipay:(NSDictionary *)info {
    NSString *appID = info[@"params"][@"appid"];
    NSString *rsa2PrivateKey = info[@"params"][@"privatekey"];
   
    //将商品信息赋予AlixPayOrder的成员变量
    APOrderInfo* order = [APOrderInfo new];
    
    // NOTE: app_id设置
    order.app_id = appID;
    
    // NOTE: 支付接口名称
    order.method = @"alipay.trade.app.pay";
    
    // NOTE: 参数编码格式
    order.charset = @"utf-8";
    
    // NOTE: 当前时间点
    NSDateFormatter* formatter = [NSDateFormatter new];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    order.timestamp = [formatter stringFromDate:[NSDate date]];
    
    // NOTE: 支付版本
    order.version = @"1.0";
    
    // NOTE: sign_type设置
    order.sign_type = @"RSA2";
    
    
    // NOTE: 商品数据
    NSDictionary *vipInfo = [AppDelegate sharedAppDelegate].vipList[currentIndex];
    order.biz_content = [APBizContent new];
    order.biz_content.body = vipInfo[@"title"];
    order.biz_content.subject =vipInfo[@"title"];
    order.biz_content.out_trade_no = info[@"order_sn"]; //订单ID（由商家自行制定）
    order.biz_content.timeout_express = @"30m"; //超时时间设置
    order.biz_content.total_amount = vipInfo[@"real_price"]; //商品价格
    
    //将商品信息拼接成字符串
    NSString *orderInfo = [order orderInfoEncoded:NO];
    NSString *orderInfoEncoded = [order orderInfoEncoded:YES];
    
    // NOTE: 获取私钥并将商户信息签名，外部商户的加签过程请务必放在服务端，防止公私钥数据泄露；
    //       需要遵循RSA签名规范，并将签名字符串base64编码和UrlEncode
    APRSASigner* signer = [[APRSASigner alloc] initWithPrivateKey:rsa2PrivateKey];

    NSString *signedString = [signer signString:orderInfo withRSA2:YES];
    
    // NOTE: 如果加签成功，则继续执行支付
    if (signedString != nil) {
        //应用注册scheme,在AliSDKDemo-Info.plist定义URL types
        NSString *appScheme = @"yinbao";
        
        // NOTE: 将签名成功字符串格式化为订单字符串,请严格按照该格式
        NSString *orderString = [NSString stringWithFormat:@"%@&sign=%@",
                                 orderInfoEncoded, signedString];
        
        // NOTE: 调用支付结果开始支付
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        }];
    }
}

#pragma mark -- UICollectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [[AppDelegate sharedAppDelegate].vipList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"vipListCell";
    PayCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSDictionary *vipInfo = [AppDelegate sharedAppDelegate].vipList[indexPath.row];
    cell.numImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"good_info_num%ld.png", indexPath.row + 1]];
    cell.titleLabel.text =  vipInfo[@"title"];
    cell.despLabel.text = vipInfo[@"sub_title"];
    cell.priceLabel.text = [NSString stringWithFormat:@"¥%@", vipInfo[@"real_price"]];
    cell.oldPriceLabel.text = [NSString stringWithFormat:@"原价%@元", vipInfo[@"price"]];
    if([vipInfo[@"is_vip"] boolValue]){
        cell.selectButton.enabled = NO;
        [cell.selectButton setImage:[UIImage imageNamed:@"pay_selected.png"] forState: UIControlStateNormal];
        [cell.selectButton setImage:[UIImage imageNamed:@"pay_selected.png"] forState: UIControlStateDisabled];
    } else {
        cell.selectButton.enabled = YES;
        [cell.selectButton setImage:[UIImage imageNamed:@"pay_select_normal.png"] forState: UIControlStateNormal];
        [cell.selectButton setImage:[UIImage imageNamed:@"pay_select_normal.png"] forState: UIControlStateDisabled];
        if(currentIndex == indexPath.row){
            cell.selectButton.selected = YES;
        } else {
            cell.selectButton.selected = NO;
        }
    }
    return cell;
}

#pragma  mark -- UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    currentIndex = indexPath.row;
    [self.vipListCollectionView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
