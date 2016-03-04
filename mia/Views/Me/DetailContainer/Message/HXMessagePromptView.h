//
//  HXMessagePromptView.h
//  mia
//
//  Created by miaios on 16/3/4.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HXMessagePromptView;


@protocol HXMessagePromptViewDelegate <NSObject>

@optional
- (void)messagePromptViewTaped:(HXMessagePromptView *)view;

@end


@interface HXMessagePromptView : UIView

@property (weak, nonatomic) IBOutlet          id  <HXMessagePromptViewDelegate>delegate;

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet     UILabel *promptLabel;

- (IBAction)tapGesture;

- (void)displayWithAvatarURL:(NSString *)url promptCount:(NSInteger)count;

@end
