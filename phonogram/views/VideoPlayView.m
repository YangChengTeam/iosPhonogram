//
//  VideoPlayView.m
//  phonogram
//
//  Created by zhangkai on 2018/3/21.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "VideoPlayView.h"

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "AppDelegate.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface VideoPlayView ()
@property (nonatomic, assign) IBOutlet UIView *playerView;
@property (nonatomic, assign) IBOutlet UIImageView *coverImageView;

@property (strong,nonatomic) AVPlayerViewController *moviePlayer;
@property (strong,nonatomic) AVPlayer *player;
@property (strong,nonatomic) AVPlayerItem *item;

@end
@implementation VideoPlayView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)customInit {
    [super customInit];
}

- (void)setCoverUrl:(NSString *)coverUrl {
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString: coverUrl]
                 placeholderImage:[UIImage imageNamed:@"ic_player_error.png"]];
}

- (IBAction)play:(id)sender {
    self.item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString: self.videoUrl]];
    self.player = [AVPlayer playerWithPlayerItem: self.item];
    self.moviePlayer = [[AVPlayerViewController alloc] init];
    self.moviePlayer.player = self.player;
    self.moviePlayer.view.frame = self.playerView.bounds;
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [self.playerView addSubview:self.moviePlayer.view];
}

- (void)destory {
    [self.player pause];
    [self.moviePlayer.view removeFromSuperview];
    [self.item removeObserver:self forKeyPath:@"status"];
    self.item = nil;
    self.player = nil;
    self.moviePlayer.player = nil;
    self.moviePlayer = nil;
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    if ([keyPath isEqualToString:@"status"]){
        if (playerItem.status == AVPlayerItemStatusReadyToPlay){
            [self.player play];
            return;
        }
        [self destory];
    }
}


@end
