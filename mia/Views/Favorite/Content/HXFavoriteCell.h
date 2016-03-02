//
//  HXFavoriteCell.h
//  mia
//
//  Created by miaios on 16/2/26.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXFavoriteCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *singerNameLabel;

- (void)displayWithFavoriteList:(NSArray *)list index:(NSInteger)index selected:(BOOL)selected;

@end
