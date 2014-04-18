MVTextInputScroller
===================

Class to keep any selected input fields visible on screen when the keyboard is shown.

Purpose
-------------------------------------------------------

When a UITextField or UITextView input is active the default iOS keyboard appears, reducing the visible screen area above it.
If the input was originally positioned below the keyboard in the view layout, it will be hidden when the keyboard appears, making it hard to see what text is entered.
A common solution to this problem is to embed all content in the input form inside a UIScrollView that can scroll vertically as necessary so that the active input field is visible.

This project provides a MVTextInputScroller class that implements a robust solution to this problem.

Features
-------------------------------------------------------
- Automatically aligns the currently selected input field to the center of the visible screen area not covered by the keyboard.
- Support for interface rotation. If an input field is active when the interface rotation changes, it is automatically adjusted.
- Support for non-fullscreen presented view controllers such as UIModalPresentationPageSheet and UIModalPresentationFormSheet.
- Supports keyboards with input accessory views.

Usage
-------------------------------------------------------
MVTextInputsScroller aims to use the simplest possible API, only requiring the input UIScrollView to be passed upon initialization.

<pre>
@interface ViewController()<UITextFieldDelegate, UITextViewDelegate>
@property(strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property(strong, nonatomic) MVTextInputsScroller *inputsScroller;
@end
@implementation ViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Register inputs scroller
    self.inputsScroller = [[MVTextInputsScroller alloc] initWithScrollView:self.scrollView];
}
- (void)dealloc {
    [self.inputsScroller unregister];
}
</pre>

A sample application demonstrating the usage MVTextInputsScroller is included.


License
-------------------------------------------------------
License information can be found in the LICENSE.md file.

Contact
-------------------------------------------------------
Andrea Bizzotto <bizz84@gmail.com>
