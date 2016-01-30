//
//  HXProfileSongCell.h
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FavoriteItem.h"

@interface HXProfileSongCell : UITableViewCell

@property (weak, nonatomic) IBOutlet     UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet     UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIImageView *downLoadIcon;
@property (weak, nonatomic) IBOutlet     UILabel *songInfoLabel;

- (void)displayWithItem:(FavoriteItem *)item index:(NSInteger)index;

@end
