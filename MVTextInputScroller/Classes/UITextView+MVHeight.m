/*
 UITextView+MVHeight.m
 Copyright (c) 2014 Andrea Bizzotto bizz84@gmail.com

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "UITextView+MVHeight.h"
#import "View+MASShorthandAdditions.h"
#import <objc/runtime.h>

static const char *kTextViewHeightKey = "TextViewHeight";

@interface UITextView (SUHeightPrivate)
- (NSNumber *)textViewHeight;
@end
@implementation UITextView (MVHeight)

- (NSNumber *)textViewHeight
{
    if (objc_getAssociatedObject(self, kTextViewHeightKey)==nil)
    {
        objc_setAssociatedObject(self, kTextViewHeightKey, @0, OBJC_ASSOCIATION_RETAIN);
    }
    return (NSNumber *)objc_getAssociatedObject(self, kTextViewHeightKey);
}

- (void)setTextViewHeight:(NSNumber *)textViewHeight {

    objc_setAssociatedObject(self, kTextViewHeightKey, textViewHeight, OBJC_ASSOCIATION_RETAIN);
}

// Code for adjusting height according to text
// http://stackoverflow.com/questions/19028743/ios7-uitextview-contentsize-height-alternative
- (BOOL)adjustHeightIfNeeded
{
    CGSize sizeThatShouldFitTheContent = [self sizeThatFits:self.frame.size];
    //DLog(@"frame: %@, sizeThatFits: %@", NSStringFromCGRect(self.frame), NSStringFromCGSize(sizeThatShouldFitTheContent));
    // Check that height is reasonable
    if (sizeThatShouldFitTheContent.height > 0 && sizeThatShouldFitTheContent.height < 1E5) {
        [self updateConstraints:^(MASConstraintMaker *make) {
           make.height.equalTo(@(sizeThatShouldFitTheContent.height));
        }];
        float oldTextViewHeight = [self.textViewHeight floatValue];
        float newTextViewHeight = sizeThatShouldFitTheContent.height;
        if (oldTextViewHeight != newTextViewHeight) {
            //DLog(@"Old Height: %f, new Height: %f", oldTextViewHeight, newTextViewHeight);
            self.textViewHeight = @(newTextViewHeight);
            [self layoutIfNeeded];
            return YES;
        }
    }
    return NO;
}

@end