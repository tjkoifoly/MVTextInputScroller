MVTextInputScroller
===================

Class to keep any selected input fields visible on screen when the keyboard is shown.

Purpose
-------------------------------------------------------

When a UITextField or UITextView input is active, the default iOS keyboard appears, reducing the visible screen area above it.
If the input was originally positioned below the keyboard in the view layout, it will be hidden when the keyboard appears, making it hard to see what text is entered.
A common solution to this problem is to embed all content in the input form inside a UIScrollView that can scroll vertically as necessary so that the active input field is visible.

This project provides a MVTextInputScroller class that implements a robust solution to this problem.

Features
-------------------------------------------------------
- Automatically aligns the currently selected input field to the center of the visible screen area not covered by the keyboard.
- Support for interface rotation. If an input field is active when the interface rotation changes, it is automatically adjusted.
- Support for non-fullscreen presented view controllers such as UIModalPresentationPageSheet and UIModalPresentationFormSheet.
- Supports keyboards with input accessory views.
- Simple to use API.

Usage
-------------------------------------------------------
MVTextInputsScroller aims to provide the simplest possible API, only requiring the input UIScrollView to be passed upon initialization. All input fields part of the UIScrollView sub-hierarchy are automatically registered

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
Copyright (c) 2014 Andrea Bizzotto bizz84@gmail.com

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
