//
//  UIScrollView+AllowPanGestureEventPass.h
//
//  Created by linyehui on 14-8-26.
//
//

#import <UIKit/UIKit.h>

@interface UIScrollView (AllowPanGestureEventPass)

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer;
@end
