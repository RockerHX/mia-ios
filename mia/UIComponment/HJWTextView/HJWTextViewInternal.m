//
//  HJWTextViewInternal.m
//  huanjuwan
//
//  Created by huanjuwan on 14-8-12.
//  Copyright (c) 2014年 duowan. All rights reserved.
//

#import "HJWTextViewInternal.h"

@implementation HJWTextViewInternal

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setText:(NSString *)text{
    BOOL originalValue = self.scrollEnabled;
    [self setScrollEnabled:YES];
    [super setText:text];
    [self setScrollEnabled:originalValue];
}

-(void)setContentOffset:(CGPoint)s
{
	if(self.tracking || self.decelerating){
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
	} else {
		float bottomOffset = (self.contentSize.height - self.frame.size.height + self.contentInset.bottom);
		if(s.y < bottomOffset && self.scrollEnabled){
            UIEdgeInsets insets = self.contentInset;
            insets.bottom = 8;
            insets.top = 0;
            self.contentInset = insets;
        }
	}
	[super setContentOffset:s];
}

-(void)setContentInset:(UIEdgeInsets)s
{
	UIEdgeInsets insets = s;
	if(s.bottom > 8){
        insets.bottom = 0;
    }
	insets.top = 0;
	[super setContentInset:insets];
}

-(void)setContentSize:(CGSize)contentSize
{
    if(self.contentSize.height > contentSize.height){
        UIEdgeInsets insets = self.contentInset;
        insets.bottom = 0;
        insets.top = 0;
        self.contentInset = insets;
    }
    [super setContentSize:contentSize];
}


@end
