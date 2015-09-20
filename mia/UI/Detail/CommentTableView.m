//
//  CommentTableView.m
//  mia
//
//  Created by linyehui on 2015-09-20.
//  Copyright (c) 2015年 Mia Music. All rights reserved.
//

#import "CommentTableView.h"
#import "CommentTableViewCell.h"
#import "MIAButton.h"
#import "CommentModel.h"

@implementation CommentTableView {
	CommentModel *model;
}

static const CGFloat CELL_HEIGHT                                    = 55.0f;

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
		model = [[CommentModel alloc] init];
		[model populateDataSource];
		
        [self setBackgroundColor:UIColorFromHex(@"#FBFBFB", 1.0)];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        self.delegate = self;
        self.dataSource = self;
        
        self.scrollEnabled = NO;
    }
    return self;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return model.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CommentTableViewIdentifier = @"CommentTableViewIdentifier";
    CommentTableViewCell *cell = (CommentTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CommentTableViewIdentifier];
    if(!cell){
        cell = [[CommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CommentTableViewIdentifier];
    }
    [cell updateWithCommentItem:[model.dataSource objectAtIndex:indexPath.row]];
    return cell;
}

@end















