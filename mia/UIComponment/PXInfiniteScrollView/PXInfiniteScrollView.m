//
//  PXInfiniteScrollView.m
//  PXAdditions
//
//  Created by Kevin Wong on 12/29/13.
//
//  Copyright (c) 2015 Pixio
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PXInfiniteScrollView.h"

@implementation PXInfiniteScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;

    // Enable paging and disable scrolling (scrolling is enabled if more than one page is set)
    [super setPagingEnabled:TRUE];
    [super setScrollEnabled:FALSE];

    [self setBounces:FALSE];
    [self setShowsHorizontalScrollIndicator:FALSE];
    [self setShowsVerticalScrollIndicator:FALSE];

    _pages = [NSArray array];
    _scrollDirection = PXInfiniteScrollViewDirectionHorizontal;

    return self;
}

#pragma mark PXInfiniteScrollView methods

- (void) setPages:(NSArray*)pages
{
    for (UIView* view in _pages)
    {
        [view removeFromSuperview];
    }

    _pages = [pages copy];

    for (UIView* view in _pages)
    {
        [view removeFromSuperview];
        [self addSubview:view];
    }

    [self layoutPages];
}

- (NSUInteger)pageCount
{
    return [_pages count];
}

- (void) setScrollDirection:(PXInfiniteScrollViewDirection)scrollDirection
{
    _scrollDirection = scrollDirection;
    [self layoutPages];
}

- (void) layoutPages
{
    CGRect frame = [self bounds];
    frame.origin = CGPointZero;

    // Add 2 so there is one page before and after all the pages
    NSInteger count = [_pages count] + 2;
    [super setScrollEnabled:([_pages count] > 1)];

    if (_scrollDirection == PXInfiniteScrollViewDirectionHorizontal)
    {
        [self setContentSize:CGSizeMake(frame.size.width * count, frame.size.height)];
    }
    else
    {
        [self setContentSize:CGSizeMake(frame.size.width, frame.size.height * count)];
    }

    for (UIView* view in _pages)
    {
        if (_scrollDirection == PXInfiniteScrollViewDirectionHorizontal)
        {
            frame = CGRectOffset(frame, frame.size.width, 0.0f);
        }
        else
        {
            frame = CGRectOffset(frame, 0.0f, frame.size.height);
        }
        [view setFrame:CGRectIntegral(frame)];
    }

    [self setCurrentPage:0];
}

- (NSInteger) currentPage
{
    NSInteger offset = (NSInteger) ((_scrollDirection == PXInfiniteScrollViewDirectionHorizontal) ? [self contentOffset].x : [self contentOffset].y);
    NSInteger pageSize = (NSInteger) ((_scrollDirection == PXInfiniteScrollViewDirectionHorizontal) ? [self bounds].size.width : [self bounds].size.height);

    NSInteger pageCount = [_pages count];

    if (pageSize == 0 || pageCount == 0)
    {
        return 0;
    }

    offset -= pageSize;
    if (offset < 0)
    {
        offset += pageSize * pageCount;
    }

    NSInteger center = offset + pageSize / 2;

    return (center / pageSize) % pageCount;
}

- (void)setCurrentPage:(NSInteger)currentPage
{
    [self setCurrentPage:currentPage animated:FALSE];
}

- (void) setCurrentPage:(NSInteger)page animated:(BOOL)animated
{
    CGFloat pageSize = (_scrollDirection == PXInfiniteScrollViewDirectionHorizontal) ? [self bounds].size.width : [self bounds].size.height;

    // adjust the page so that is no more than pageCount from the current page
    if (pageSize <= 0.0f || [_pages count] == 0)
    {
        page = 0;
    }
    else
    {
        NSInteger pageDifference = page - [self currentPage];
        page -= pageDifference - pageDifference % (NSInteger)[_pages count];
    }

    CGFloat offset = pageSize * page + pageSize;

    if (_scrollDirection == PXInfiniteScrollViewDirectionHorizontal)
    {
        [self setContentOffset:CGPointMake(offset, 0.0f) animated:animated];
    }
    else
    {
        [self setContentOffset:CGPointMake(0.0f, offset) animated:animated];
    }
}

#pragma mark UIScrollView methods

- (void) setContentOffset:(CGPoint)contentOffset
{
    NSInteger pageCount = [_pages count];
    BOOL horizontal = (_scrollDirection == PXInfiniteScrollViewDirectionHorizontal);

    // Don't bother adjusting frames or the offset if there are no pages
    if ([_pages count] == 0)
    {
        [super setContentOffset:contentOffset];
        return;
    }

    CGRect frame = [self bounds];
    frame.origin = CGPointZero;

    CGFloat pageSize = horizontal ? frame.size.width : frame.size.height;
    CGFloat currentOffset = horizontal ? contentOffset.x : contentOffset.y;
    CGFloat firstPageOffset = pageSize;
    CGFloat lastPageOffset = pageSize * pageCount;
    
    if (pageSize > 0.0f && currentOffset <= 0.0f)
    {
        currentOffset = pageSize;
    }
    
    // Whether or not the content offset should 'jump'. This works great when physicially dragging,
    // but can problematic when jumping a large distance programatically
    BOOL adjustContentOffset = [self isTracking] == TRUE || [self isDecelerating] == FALSE;

    // Calculate offsets for the frames of the first and last page. Also, adjust the offset to jump if necessary

    if (currentOffset < pageSize)
    {
        // Overscroll to the left (or top)
        if (adjustContentOffset)
        {
            currentOffset += pageSize * pageCount;
            firstPageOffset = pageSize * (pageCount + 1);
        }
        else
        {
            firstPageOffset = pageSize;
            lastPageOffset = 0.0f;
        }
    }
    else if (currentOffset > pageSize * pageCount)
    {
        // Overscroll to the right (or bottom)
        if (adjustContentOffset)
        {
            currentOffset -= pageSize * pageCount;
            firstPageOffset = pageSize;
            lastPageOffset = 0.0f;
        }
        else
        {
            firstPageOffset = pageSize * (pageCount + 1);
        }
    }

    if (horizontal)
    {
        contentOffset.x = currentOffset;
        [[_pages firstObject] setFrame:CGRectIntegral(CGRectOffset(frame, firstPageOffset, 0.0f))];
        [[_pages lastObject] setFrame:CGRectIntegral(CGRectOffset(frame, lastPageOffset, 0.0f))];
    }
    else
    {
        contentOffset.y = currentOffset;
        [[_pages firstObject] setFrame:CGRectIntegral(CGRectOffset(frame, 0.0f, firstPageOffset))];
        [[_pages lastObject] setFrame:CGRectIntegral(CGRectOffset(frame, 0.0f, lastPageOffset))];
    }


    [super setContentOffset:contentOffset];
}

- (void) setScrollEnabled:(BOOL)scrollEnabled
{
    // NOP
}

- (void) setPagingEnabled:(BOOL)pagingEnabled
{
    // NOP
}

- (UIView*) currentPageView
{
    return _pages[[self currentPage]];
}

- (void) setFrame:(CGRect)frame
{
    CGRect oldFrame = [self frame];

    [super setFrame:frame];

    if (CGSizeEqualToSize(frame.size, oldFrame.size))
    {
        return;
    }

    // Layout pages if necessary
    NSInteger page = [self currentPage];
    [self layoutPages];
    [self setCurrentPage:page];
}

- (void) setBounds:(CGRect)bounds
{
    CGRect oldBounds = [self bounds];

    [super setBounds:bounds];

    if (CGSizeEqualToSize(bounds.size, oldBounds.size))
    {
        return;
    }

    // Layout pages if necessary
    NSInteger page = [self currentPage];
    [self layoutPages];
    [self setCurrentPage:page];
}

@end
