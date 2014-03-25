//
// Created by Andrea Bizzotto on 25/03/2014.
// Copyright (c) 2014 musevisions. All rights reserved.
//

#import "MVTextInputsScroller.h"


static BOOL isIPad() {
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
}

///////////////////////////////////////////////////////
@interface UIView (ViewHierarchyInputs)
- (NSArray *)textInputsInHierarchy;
@end

@implementation UIView (ViewHierarchyInputs)
- (NSArray *)textInputsInHierarchy
{
    NSMutableArray *textInputs = [NSMutableArray new];
    for (UIView *subview in self.subviews)
    {
        NSArray *subviewInputs = [subview textInputsInHierarchy];
        if (subviewInputs != nil) {
            [textInputs addObjectsFromArray:subviewInputs];
        }
    }
    if ([self isKindOfClass:[UITextField class]] || [self isKindOfClass:[UITextView class]]) {
        [textInputs addObject:self];
    }
    return textInputs;
}
@end
///////////////////////////////////////////////////////

@interface MVTextInputsScroller ()
@property(weak, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) NSArray *textInputs;
@property CGSize keyboardSize;
@property BOOL keyboardVisible;
@property(weak, nonatomic) UIView *activeView;
@property(weak, nonatomic) UIView *activeViewBeforeOrientationChange;
@end

@implementation MVTextInputsScroller

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithScrollView:(UIScrollView *)scrollView {
    if (self = [super init]) {

        self.scrollView = scrollView;
        self.textInputs = [scrollView textInputsInHierarchy];

        [self setupObservers];
    }
    return self;
}

- (void)setupObservers {

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    // Listen to 'did begin editing' notifications
    [nc addObserver:self selector:@selector(textInputDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:nil];
    [nc addObserver:self selector:@selector(textInputDidBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];

    // Listen to keyboard events
    //[nc addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [nc addObserver:self selector:@selector(keyboardDidChangeFrame:) name:UIKeyboardDidChangeFrameNotification object:nil];

    // Listen to orientation changes
    [nc addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

#pragma mark - keyboard notifications
- (void)keyboardWillShow:(NSNotification *)notification
{
    DLog();
    self.keyboardVisible = YES;
    if (self.activeView == nil) {
        // Restore if this is just an orientation change
        self.activeView = self.activeViewBeforeOrientationChange;
    }
    //UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 216, 0.0);
    //self.scrollView.contentInset = contentInsets;
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    // TODO: This is sometimes called before keyboardDidChangeFrame
    DLog();
    self.keyboardVisible = NO;
    self.activeViewBeforeOrientationChange = self.activeView;
    //self.scrollView.contentInset = UIEdgeInsetsZero;
    self.activeView = nil;
}

- (void)keyboardDidChangeFrame:(NSNotification *)notification {

    NSDictionary *info = [notification userInfo];
    self.keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (UIInterfaceOrientationIsLandscape([[self class] currentOrientation])) {
        self.keyboardSize = CGSizeMake(self.keyboardSize.height, self.keyboardSize.width);
    }
    DLog(@"New keyboard size: %@", NSStringFromCGSize(self.keyboardSize));

    // Set/reset scrollView content insets based on keyboard visibility
    self.scrollView.contentInset = self.keyboardVisible ? UIEdgeInsetsMake(0.0, 0.0, self.keyboardSize.height, 0.0) : UIEdgeInsetsZero;

    // If there is an active view and the keyboard is visible
    if (self.activeView != nil && self.keyboardVisible) {

        [self makeViewVisible:self.activeView];
    }
}

- (void)orientationChanged:(NSNotification *)notification {

    DLog();
    if (self.activeView != nil) {
        [self makeViewVisible:self.activeView];
    }
}

#pragma mark - text input notifications

- (void)textInputDidBeginEditing:(NSNotification *)notice {
    [self processInputDidBeginEditing:notice.object];
}
//- (void)textInputDidEndEditing:(NSNotification *)notice {
//    DLog(@"%@", notice.object);
//}

- (void)processInputDidBeginEditing:(id)object {

    //DLog(@"%@", object);
    if ([object isKindOfClass:[UIView class]]) {
        UIView *view = (UIView *)object;
        if ([self scrollViewHasSubview:view]) {
            [self makeViewVisible:view];
        }
    }
}

#pragma mark - setters
- (void)setDismissKeyboardOnScroll:(BOOL)dismissKeyboardOnScroll
{
    _dismissKeyboardOnScroll = dismissKeyboardOnScroll;
    self.scrollView.keyboardDismissMode = dismissKeyboardOnScroll ? UIScrollViewKeyboardDismissModeOnDrag : UIScrollViewKeyboardDismissModeNone;
}

- (void)makeViewVisible:(UIView *)view {

    // Store activeView somewhere so we can recalculate on interface rotation
    self.activeView = view;

    //UIEdgeInsets currentInsets = self.scrollView.contentInset;
    float bottomInset = 0;//currentInsets.bottom;

    // Get keyboard size (if zero, it hasn't been set yet so try to guess)
    CGSize keyboardSize = self.keyboardSize;
    if (CGSizeEqualToSize(keyboardSize, CGSizeZero)) {
        keyboardSize = [[self class] currentEstimatedKeyboardSize];
    }

    CGSize currentScreenSize = [[self class] currentScreenSize];
    CGPoint viewOriginInScrollView = [self viewOriginInScrollView:view];
    // Calculate scroll view origin without offset
    CGPoint scrollViewOriginInMainWindowNoOffset = [[self class] viewOriginInMainWindow:self.scrollView];
    scrollViewOriginInMainWindowNoOffset.y += self.scrollView.contentOffset.y;

    // Calculate visible scrollable height (which is the portion of the screen that can scroll and is not hidden by the keyboard)
    float visibleScrollableHeight = currentScreenSize.height - keyboardSize.height - scrollViewOriginInMainWindowNoOffset.y;
    // Calculate the offset of the view centerY relative to the scrollView
    float viewCenterY = viewOriginInScrollView.y + view.frame.size.height/2;

    // Calculate new content offset that will cause the view to be centered in the visible scrollable area
    float newContentOffsetY = viewCenterY - visibleScrollableHeight/2;
    float contentHeight = self.scrollView.contentSize.height;
    // If content offset would cause the scroll view to scroll below its bottom, recalculate
    // to the maximum content offset. This way we don't show additional empty space below the last visible control.
    if (newContentOffsetY + visibleScrollableHeight > contentHeight + bottomInset) {
        newContentOffsetY = contentHeight + bottomInset - visibleScrollableHeight;
    }
    CGPoint newContentOffset = CGPointMake(0, newContentOffsetY);
    [self.scrollView setContentOffset:newContentOffset animated:YES];
}

#pragma mark - utility methods
- (BOOL)scrollViewHasSubview:(UIView *)view {
    return [self.textInputs containsObject:view];
}

- (void)log {

    for (UIView *view in self.textInputs) {
        DLog(@"class: %@, frame: %@", NSStringFromClass([view class]), NSStringFromCGRect(view.frame));
    }
}

+ (CGSize)currentEstimatedKeyboardSize {

    BOOL portrait = UIInterfaceOrientationIsPortrait([self currentOrientation]);
    if (isIPad()) {
        return portrait ? CGSizeMake(320, 216) : CGSizeMake(480, 162);
    }
    else {
        return portrait ? CGSizeMake(768, 264) : CGSizeMake(1024, 352);
    }
}

+ (UIInterfaceOrientation)currentOrientation {
    return [UIApplication sharedApplication].statusBarOrientation;
}
+ (CGSize)currentScreenSize
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat width = CGRectGetWidth(screenBounds);
    CGFloat height = CGRectGetHeight(screenBounds);
    UIInterfaceOrientation interfaceOrientation = [self currentOrientation];
    return UIInterfaceOrientationIsPortrait(interfaceOrientation) ? CGSizeMake(width, height) : CGSizeMake(height, width);
}

- (CGPoint)viewOriginInScrollView:(UIView *)view {

    return [self.scrollView convertPoint:CGPointZero fromView:view];
}

+ (CGPoint)viewOriginInMainWindow:(UIView *)view {

    UIWindow *mainView = [[UIApplication sharedApplication].delegate window].subviews[0];
    return [mainView convertPoint:CGPointZero fromView:view];
}


@end
