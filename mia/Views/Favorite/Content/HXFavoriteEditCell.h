//
//  HXFavoriteEditCell.h
//  mia
//
//  Created by miaios on 16/3/2.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXFavoriteEditCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *stateIcon;
@property (weak, nonatomic) IBOutlet     UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *singerNameLabel;

@end
