//
//  InterestContentViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "InterestContentViewController.h"
#import "VideoPlayView.h"

@interface InterestContentViewController ()

@property (nonatomic, assign) IBOutlet VideoPlayView *playerView;

@end

@implementation InterestContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if(self.classInfo) {
        self.playerView.videoUrl = [self.classInfo[@"video"] stringByTrimmingCharactersInSet:
                                    [NSCharacterSet whitespaceAndNewlineCharacterSet]] ;
        [self.playerView setCoverUrl: self.classInfo[@"cover"]];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    if(self.playerView && !(self.playerView.moviePlayer.videoBounds.size.width > 250)){
        [self.playerView destory];
    }
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
