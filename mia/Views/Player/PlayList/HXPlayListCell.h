//
//  HXPlayListCell.h
//  mia
//
//  Created by miaios on 15/12/1.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HXPlayListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *frontCover;
@property (weak, nonatomic) IBOutlet     UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet     UILabel *singerLabel;

@end
