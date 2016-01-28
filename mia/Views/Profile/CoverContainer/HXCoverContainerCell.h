//
//  HXCoverContainerCell.h
//  mia
//
//  Created by miaios on 16/1/28.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXCoverContainerCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *cover;

- (void)displayWithURL:(NSString *)url;

@end
