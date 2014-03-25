//
// Created by Andrea Bizzotto on 25/03/2014.
// Copyright (c) 2014 musevisions. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 Class to automatically handle the scrolling of content on a UIScrollView so that any selected
 input fields are always visible on screen
 */

@interface MVTextInputsScroller : NSObject

- (id)initWithScrollView:(UIScrollView *)scrollView;
@property (nonatomic) BOOL dismissKeyboardOnScroll;
@property (nonatomic) BOOL dismissKeyboardOnTap;
- (void)log;

@end