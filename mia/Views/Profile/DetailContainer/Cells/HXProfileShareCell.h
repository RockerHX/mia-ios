//
//  HXProfileShareCell.h
//  mia
//
//  Created by miaios on 16/1/29.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShareItem.h"

@interface HXProfileShareCell : UITableViewCell

@property (weak, nonatomic) IBOutlet     UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet     UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet    UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *cover;
@property (weak, nonatomic) IBOutlet     UILabel *songLabel;
@property (weak, nonatomic) IBOutlet     UILabel *singerLabel;
@property (weak, nonatomic) IBOutlet    UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet     UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet     UILabel *seeCountLabel;
@property (weak, nonatomic) IBOutlet    UIButton *deleteButton;

- (IBAction)playButtonPressed;
- (IBAction)favoriteButtonPressed;
- (IBAction)deleteButtonPressed;

- (void)displayWithItem:(ShareItem *)item;

@end
