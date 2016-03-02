//
//  HXFavoriteEditViewController.m
//  mia
//
//  Created by miaios on 16/3/2.
//  Copyright © 2016年 Mia Music. All rights reserved.
//

#import "HXFavoriteEditViewController.h"
#import "HXFavoriteEditContainerViewController.h"

@interface HXFavoriteEditViewController ()

@end

@implementation HXFavoriteEditViewController {
    HXFavoriteEditContainerViewController *_containerViewController;
}

#pragma mark - Class Methods
+ (NSString *)navigationControllerIdentifier {
    return @"HXFavoriteEditNavigaitonController";
}

+ (HXStoryBoardName)storyBoardName {
    return HXStoryBoardNameFavorite;
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    _containerViewController = segue.destinationViewController;
}

#pragma mark - View Controller Lift Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadConfigure];
    [self viewConfigure];
}

#pragma mark - Configure Methods
- (void)loadConfigure {
    ;
}

- (void)viewConfigure {
    ;
}

#pragma mark - Event Response
- (IBAction)selectAllButtonPressed {
    _containerViewController.selectAll = !_containerViewController.selectAll;
    [_selectedAllButton setTitle:(_containerViewController.selectAll ? @"取消" : @"全选") forState:UIControlStateNormal];
}

- (IBAction)doneButtonPressed {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)deleteButtonPressed {
    [_containerViewController deleteAction];
    
    if (_delegate && [_delegate respondsToSelector:@selector(editFinish:)]) {
        [_delegate editFinish:self];
    }
}

@end
