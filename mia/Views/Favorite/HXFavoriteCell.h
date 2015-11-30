//
//  HXFavoriteCell.h
//  mia
//
//  Created by miaios on 15/11/27.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteItem.h"

@interface HXFavoriteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *frontCover;
@property (weak, nonatomic) IBOutlet UIImageView *downloadStateIcon;
@property (weak, nonatomic) IBOutlet     UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *singerLabel;

- (void)displayWithItem:(FavoriteItem *)item;

@end
