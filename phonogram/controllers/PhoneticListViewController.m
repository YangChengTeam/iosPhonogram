//
//  PhoneticListViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/23.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "PhoneticListViewController.h"
#import "PhoneticCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "AppDelegate.h"
#import "Config.h"

@interface PhoneticListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, assign) IBOutlet UICollectionView *listConllectionView;
@end

@implementation PhoneticListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if([AppDelegate sharedAppDelegate].phoneticList){
        [self.listConllectionView reloadData];
        return;
    } else {
        [self show:@"正在加载"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setupPhoneticList:)
                                                     name:kNotiPhoneticListLoadCompleted
                                                   object:nil];
    }
}

- (void)setupPhoneticList:(NSNotification *)noti {
    [self dismiss:nil];
    [self.listConllectionView reloadData];
}

#pragma  mark -- UICollectionView datasource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(![AppDelegate sharedAppDelegate].phoneticList){
        return 0;
    }
    return [[AppDelegate sharedAppDelegate].phoneticList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"phoneticListCell";
    PhoneticCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSDictionary *phoneticInfo = [AppDelegate sharedAppDelegate].phoneticList[indexPath.row];
    [cell.wordImageView sd_setImageWithURL:[NSURL URLWithString: phoneticInfo[@"img"]]
                          placeholderImage:[UIImage imageNamed:@"sample.png"]];
   
    return cell;
}

#pragma  mark -- UICollectionView delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotiPhoneticListChange object:indexPath];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
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
