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
#import "UIView+Toast.h"
#import "IAPManager.h"

@interface PayViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, IAPManagerDelegate>

@property (nonatomic, assign) IBOutlet UIButton *wxpayButton;
@property (nonatomic, assign) IBOutlet UIButton *alipayButton;
@property (nonatomic, assign) IBOutlet UIButton *paySubmitButton;
@property (nonatomic, assign) IBOutlet UICollectionView *vipListCollectionView;

@end

@implementation PayViewController {
    NSInteger currentIndex;
    NSString *currentOrderId;
    NSInteger payType;
    NSInteger n;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    currentIndex = 0;
    payType = 0;
    n = 3;
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(paySuccess:)
                                                 name:kNotiPaySuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(payFailure:)
                                                 name:kNotiPayFailure
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(payCancel:)
                                                 name:kNotiPayCancel
                                               object:nil];
    [IAPManager sharedManager].delegate = self;
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
    currentOrderId = @"";
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf updateVipList];
    }];
}

- (void)payFailure:(NSNotification *)noti {
    [self.view makeToast:@"支付失败"
                duration:3.0
                position:CSToastPositionCenter];
}

- (void)payCancel:(NSNotification *)noti {
    [self.view makeToast:@"支付取消"
                duration:3.0
                position:CSToastPositionCenter];
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
    params = @{
               @"goods_id": info[@"id"],
               @"goods_num": @"1",
               @"payway_name": @"iap",
               @"money": info[@"real_price"]
               };
    [self show:@"正在创建订单..."];
    __weak typeof(self) weakSelf = self;
    [NetUtils postWithUrl:ORDER_URL params:params callback:^(NSDictionary *data) {
        if(data && [data[@"code"] integerValue] == 1) {
            currentOrderId = data[@"data"][@"order_sn"];
            [weakSelf iapPay:info];
        } else {
            [weakSelf dismiss:nil];
            [weakSelf.view makeToast:data[@"msg"]
                            duration:3.0
                            position:CSToastPositionCenter];
        }
    }];
}


- (void)iapPay:(NSDictionary *)orderInfo {
    [self show:@"请稍后..."];
    [[IAPManager sharedManager] requestProductWithId: [NSString stringWithFormat:@"SE%@", orderInfo[@"id"]] userId: [AppDelegate sharedAppDelegate].loginInfo[@"user_info"][@"user_id"]  count:1];
}


#pragma mark -- 接收内购支付回调
- (void)receiveProduct:(SKProduct *)product {
    NSLog(@"%@", @"接收内购支付回调");
    [self dismiss:nil];
    if (product != nil) {
        if (![[IAPManager sharedManager] purchaseProduct:product]) {
            [self alert:@"您禁止了应用内购买权限,请到设置中开启!"];
        }
    } else {
        [self alert:@"无法获取产品信息"];
    }
}

#pragma mark -- 订单验证
- (void)checkOrder:(NSString *)transactionReceiptString {
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setValue:transactionReceiptString forKey:@"receipt"];
    [params setValue:currentOrderId forKey:@"order_sn"];
    __weak typeof(self) weakSelf = self;
    [NetUtils postWithUrl:CHECK_URL params:params callback:^(NSDictionary *res){
        [[IAPManager sharedManager] finishTransaction];
        if(res && [res[@"code"] integerValue] == 1){
            [weakSelf dismiss:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPaySuccess object:nil];
            
        } else {
            if(--n > 0){
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf checkOrder:transactionReceiptString];
                    });
                });
                return;
            }
            [weakSelf dismiss:nil];
            n = 3;
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPayFailure object:nil];
        }
    } error:^(NSError * error) {
        [weakSelf showByError:error];
        if(!error){
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPayFailure object:nil];
        }
        
    }];
}

#pragma mark -- 购买成功
- (void)successedWithReceipt:(NSData *)transactionReceipt {
    NSLog(@"%@", @"购买成功 开始验证订单");
    NSString  *transactionReceiptString = [transactionReceipt base64EncodedStringWithOptions:0];
    if ([transactionReceiptString length] > 0) {
        [self show:@"订单校验中..."];
        [self checkOrder:transactionReceiptString];
    }
}


#pragma mark -- 购买失败
- (void)failedPurchaseWithError:(NSString *)errorDescripiton {
    NSLog(@"%@", @"购买失败");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPayFailure object:nil];
}

#pragma mark -- 取消购买
- (void)canceledPurchaseWithError:(NSString *)errorDescripiton {
    NSLog(@"%@", @"取消购买");
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPayCancel object:nil];
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
        cell.selectImageView.image = [UIImage imageNamed:@"pay_selected.png"];
    } else {
        if(currentIndex == indexPath.row){
            cell.selectImageView.image = [UIImage imageNamed:@"pay_select_press.png"];
        } else {
            cell.selectImageView.image = [UIImage imageNamed:@"pay_select_normal.png"];
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
