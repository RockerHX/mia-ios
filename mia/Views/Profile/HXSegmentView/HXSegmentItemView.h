//
//  HXSegmentItemView.h
//  Mia
//
//  Created by miaios on 15/12/8.
//  Copyright © 2015年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXSegmentItemView;

@protocol HXSegmentItemViewDelegate <NSObject>

@required
- (void)itemViewSelected:(HXSegmentItemView *)itemView;

@end

@interface HXSegmentItemView : UIView

@property (weak, nonatomic) IBOutlet      id  <HXSegmentItemViewDelegate>delegate;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@property (nonatomic, assign) BOOL  selected;

- (IBAction)buttonPressed;

@end
