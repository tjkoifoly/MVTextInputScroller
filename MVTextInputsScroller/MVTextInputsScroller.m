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
@property(weak, nonatomic) UIView *activeView;
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

    // Listen to 'did begin editing' notifications
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(textInputDidBeginEditing:)
               name:UITextViewTextDidBeginEditingNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(textInputDidBeginEditing:)
               name:UITextFieldTextDidBeginEditingNotification
             object:nil];

//    [nc addObserver:self
//           selector:@selector(textInputDidEndEditing:)
//               name:UITextViewTextDidEndEditingNotification
//             object:nil];
//    [nc addObserver:self
//           selector:@selector(textInputDidEndEditing:)
//               name:UITextViewTextDidEndEditingNotification
//             object:nil];

    // Listen to keyboard events
//    [nc addObserver:self
//         selector:@selector(keyboardDidShow:)
//             name:UIKeyboardDidShowNotification
//           object:nil];
    [nc addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification
             object:nil];


    [nc addObserver:self
         selector:@selector(keyboardWillHide:)
             name:UIKeyboardWillHideNotification
           object:nil];

    [nc addObserver:self
         selector:@selector(keyboardDidChangeFrame:)
             name:UIKeyboardDidChangeFrameNotification
           object:nil];
}

#pragma mark - keyboard notifications
- (void)keyboardDidShow:(NSNotification *)notification
{
    DLog();
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 216, 0.0);
    self.scrollView.contentInset = contentInsets;
}
- (void)keyboardWillShow:(NSNotification *)notification
{
    DLog();
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, 216, 0.0);
    self.scrollView.contentInset = contentInsets;
}
- (void)keyboardWillHide:(NSNotification *)notification
{
    DLog();
    self.scrollView.contentInset = UIEdgeInsetsZero;
}
- (void)keyboardDidChangeFrame:(NSNotification *)notification {

    DLog();
}


#pragma mark - text input notifications

- (void)textInputDidBeginEditing:(NSNotification *)notice {
    [self processInputDidBeginEditing:notice.object];
}
//- (void)textInputDidEndEditing:(NSNotification *)notice {
//    DLog(@"%@", notice.object);
//}

- (void)processInputDidBeginEditing:(id)object {

    DLog(@"%@", object);
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

    DLog();

    self.activeView = view;

    //UIEdgeInsets currentInsets = self.scrollView.contentInset;
    float bottomInset = 0;//currentInsets.bottom;

    // Set bottom margin to keyboard height
    CGSize keyboardSize = CGSizeMake(320, 216);

    CGSize currentScreenSize = [[self class] currentScreenSize];
    CGPoint viewOriginInScrollView = [self viewOriginInScrollView:view];


    float viewCenterY = viewOriginInScrollView.y + view.frame.size.height/2;
    float visibleScreenHeight = currentScreenSize.height - keyboardSize.height;

    float desiredContentOffsetY = viewCenterY - visibleScreenHeight/2;
    float contentHeight = self.scrollView.contentSize.height;
    // If content offset would cause the scroll view to go past its bottom, recalculate
    // to the maximum content offset.
    if (desiredContentOffsetY + visibleScreenHeight > contentHeight + bottomInset) {
        desiredContentOffsetY = contentHeight + bottomInset - visibleScreenHeight;
    }
    CGPoint desiredContentOffset = CGPointMake(0, desiredContentOffsetY);
    [self.scrollView setContentOffset:desiredContentOffset animated:YES];
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

+ (CGSize)currentScreenSize
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat width = CGRectGetWidth(screenBounds);
    CGFloat height = CGRectGetHeight(screenBounds);
    UIInterfaceOrientation interfaceOrientation = [UIApplication sharedApplication].statusBarOrientation;
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
