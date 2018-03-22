//
//  LearnContentViewController.m
//  phonogram
//
//  Created by zhangkai on 2018/3/20.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import "LearnContentViewController.h"
#import "LearnSampleCellCollectionViewCell.h"
#import "VideoPlayView.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface LearnContentViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, assign) IBOutlet VideoPlayView *playerView;
@property (nonatomic, assign) IBOutlet UIImageView *wordImageView;
@property (nonatomic, assign) IBOutlet UITextView *despTextView;
@property (nonatomic, assign) IBOutlet UIImageView *voiceImageView;

@end

@implementation LearnContentViewController {
    NSString *type;
    UIView *itemView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if(self.phoneticInfo) {
        self.playerView.videoUrl = self.phoneticInfo[@"video"];
        [self.playerView setCoverUrl:self.phoneticInfo[@"cover"]];
        [self.wordImageView sd_setImageWithURL:[NSURL URLWithString:self.phoneticInfo[@"img"]]
                     placeholderImage:[UIImage imageNamed:@"sample.png"]];
        self.despTextView.text = self.phoneticInfo[@"desp"];
    }
    self.voiceImageView.animationImages = [NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"ic_learn_voice_1.jpg"],
                                          [UIImage imageNamed:@"ic_learn_voice_2.jpg"],
                                          [UIImage imageNamed:@"ic_learn_voice_3.jpg"],
                                    nil];
    self.voiceImageView.animationDuration = 1.0f;
    self.voiceImageView.animationRepeatCount = 0;
}

- (IBAction)playDesp:(id)sender {
    [self hideDespImageView];
    type = @"desp";
    NSURL *url = [NSURL URLWithString: self.phoneticInfo[@"desp_audio"]];
    [self play: url];
    [self show:@"正在加载..."];
}

- (void)playSample:(NSString *)str {
    [self hideDespImageView];
    type = @"sample";
    NSURL *url = [NSURL URLWithString: str];
    [self play: url];
    [self show:@"正在加载..."];
}

- (void)playing {
    [self dismiss:nil];
    if([type isEqualToString:@"desp"]){
        [self showDespImageView];
    } else if([type isEqualToString:@"sample"]){
        CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        basicAnimation.toValue = @1.4;
        basicAnimation.duration = 1;
        basicAnimation.removedOnCompletion = YES;
        basicAnimation.fillMode = kCAFillModeForwards;
        [itemView.layer addAnimation:basicAnimation forKey:nil];
    }
}

- (void)finished {
    [self hideDespImageView];
}

- (void)error {
    [self dismiss:nil];
}

- (void)showDespImageView {
    self.voiceImageView.hidden = NO;
    [self.voiceImageView startAnimating];
}

- (void)hideDespImageView {
    self.voiceImageView.hidden = YES;
    [self.voiceImageView stopAnimating];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.phoneticInfo[@"example"] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"learnSampleCell";
    LearnSampleCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSDictionary *sampleInfo = self.phoneticInfo[@"example"][indexPath.row];
    
    NSString *word  = sampleInfo[@"word"];
   
    NSMutableAttributedString *wordAttrs = [[NSMutableAttributedString alloc] initWithString:word];
    [wordAttrs addAttribute:NSForegroundColorAttributeName value:kColorWithHex(0xff0000) range:[word rangeOfString:sampleInfo[@"letter"]]];
    cell.enLable.attributedText = wordAttrs;
    
    NSString *word_phonetic  = sampleInfo[@"word_phonetic"];
    NSString *name = self.phoneticInfo[@"name"];
    NSRange range = NSMakeRange(1, name.length - 2);
    NSMutableAttributedString *ybAttrs = [[NSMutableAttributedString alloc] initWithString:word_phonetic];
    [ybAttrs addAttribute:NSForegroundColorAttributeName value:kColorWithHex(0xff0000) range:[word_phonetic rangeOfString:[name substringWithRange:range]]];
    cell.ybLable.attributedText = ybAttrs;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    itemView = [collectionView cellForItemAtIndexPath:indexPath];
    
    NSDictionary *sampleInfo = self.phoneticInfo[@"example"][indexPath.row];
    [self playSample:sampleInfo[@"video"]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self dismiss:nil];
    [self hideDespImageView];
    [self clear];
    if(self.playerView){
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
