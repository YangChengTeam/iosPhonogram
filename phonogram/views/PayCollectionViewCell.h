//
//  PayCollectionViewCell.h
//  phonogram
//
//  Created by zhangkai on 2018/3/26.
//  Copyright © 2018年 zhangkai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) IBOutlet UIImageView *numImageView;
@property (nonatomic, assign) IBOutlet UILabel  *titleLabel;
@property (nonatomic, assign) IBOutlet UILabel  *despLabel;
@property (nonatomic, assign) IBOutlet UILabel  *priceLabel;
@property (nonatomic, assign) IBOutlet UILabel  *oldPriceLabel;
@property (nonatomic, assign) IBOutlet UIImageView *selectImageView;

@end
