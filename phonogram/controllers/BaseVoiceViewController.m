//
//  BaseVoiceViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/22.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "BaseVoiceViewController.h"
#import "AppDelegate.h"

@interface BaseVoiceViewController ()

@end

@implementation BaseVoiceViewController {
    id _timeObserve;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)clear {
    if(self.player){
        [self.player pause];
        [self.item removeObserver:self forKeyPath:@"status"];
        if(_timeObserve){
            [self.player removeTimeObserver:_timeObserve];
        }
        self.player = nil;
    }  
    self.isOver = NO;
}

- (void)play:(NSURL *)url {
    [self clear];
    self.item = [[AVPlayerItem alloc] initWithURL: url];
    self.player = [[AVPlayer alloc]initWithPlayerItem: self.item];
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    __weak typeof(self) weakSelf = self;
    _timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        float current = CMTimeGetSeconds(time);
        float total = CMTimeGetSeconds(weakSelf.item.duration);
        if(current == 0){
            if([weakSelf respondsToSelector:@selector(playing)]){
                [weakSelf performSelector:@selector(playing)
                                 onThread:[NSThread mainThread]
                               withObject:nil
                            waitUntilDone:NO];
            }
        }
        else if (current == total) {
            weakSelf.isOver = YES;
            if([weakSelf respondsToSelector:@selector(finished)]){
                [weakSelf performSelector:@selector(finished)
                             onThread:[NSThread mainThread]
                           withObject:nil
                        waitUntilDone:NO];
            }
        }
    }];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"status"]) {
        switch (self.player.status) {
            case AVPlayerStatusReadyToPlay:
                [self.player play];
                break;
            default:
                self.isOver = YES;
                if([self respondsToSelector:@selector(error)]){
                    [self performSelector:@selector(error)
                                 onThread:[NSThread mainThread]
                               withObject:nil
                            waitUntilDone:NO];
                }
                break;
        }
    }
}


- (void)dealloc {
    [self clear];
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
