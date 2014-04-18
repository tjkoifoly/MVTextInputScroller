/*
 ViewController.m
 Copyright (c) 2014 Andrea Bizzotto bizz84@gmail.com

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "ViewController.h"
#import "MVTextInputsScroller.h"
#import "UITextView+MVHeight.h"
#import "JVFloatLabeledTextField.h"
#import "JVFloatLabeledTextView.h"

@interface ViewController()<UITextFieldDelegate, UITextViewDelegate>
@property(strong, nonatomic) MVTextInputsScroller *inputsScroller;
@property(strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property(strong, nonatomic) IBOutlet JVFloatLabeledTextField *nameInput;
@property(strong, nonatomic) IBOutlet JVFloatLabeledTextField *surnameInput;
@property(strong, nonatomic) IBOutlet JVFloatLabeledTextView *bioInput;
@property(strong, nonatomic) IBOutlet JVFloatLabeledTextField *postcodeInput;
@property(strong, nonatomic) IBOutlet JVFloatLabeledTextField *addressL1Input;
@property(strong, nonatomic) IBOutlet JVFloatLabeledTextField *addressL2Input;
@property(strong, nonatomic) IBOutlet UIButton *confirmButton;

- (IBAction)backToTopButtonPressed:(id)sender;
- (IBAction)clearButtonPressed:(id)sender;
@end
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Auto-layout
    [self updateLayout];

    // Register inputs scroller
    self.inputsScroller = [[MVTextInputsScroller alloc] initWithScrollView:self.scrollView];
    // Dismiss keyboard on drag
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;

    // Dismiss keyboard on tap
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)]];

    self.bioInput.placeholder = @"Claim details";

    // A bit of styling
    [self updateStyling];

    [self setInputResponderChain];
}

- (NSArray *)allInputFields {
    return @[self.nameInput, self.surnameInput, self.bioInput, self.postcodeInput, self.addressL1Input, self.addressL2Input, self.confirmButton];
}

- (void)updateStyling {

    for (UIView *view in [self allInputFields]) {
        view.layer.borderColor = self.confirmButton.tintColor.CGColor;
        view.layer.borderWidth = 1;
        view.layer.cornerRadius = 5;
    }
}
- (void)updateLayout {

    static CGFloat kOffset = 20.0f;
    static CGFloat kHeight = 44.0f;
    MASAttachKeys(self.view, self.scrollView, self.nameInput, self.surnameInput, self.bioInput, self.postcodeInput, self.addressL1Input, self.addressL2Input, self.confirmButton);

    for (UIView *view in [self allInputFields]) {
        [view removeConstraints:view.constraints];
        [view makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.scrollView).offset(kOffset);
            make.width.equalTo(self.scrollView).offset(-2*kOffset);
        }];
    }

    [self.nameInput makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scrollView).offset(kOffset);
        make.height.equalTo(@(kHeight));
    }];
    [self.surnameInput makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameInput.bottom).offset(kOffset);
        make.height.equalTo(@(kHeight));
    }];
    [self.bioInput makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.surnameInput.bottom).offset(kOffset);
        make.height.equalTo(@(kHeight));
    }];
    [self.postcodeInput makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bioInput.bottom).offset(kOffset);
        make.height.equalTo(@(kHeight));
    }];
    [self.addressL1Input makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.postcodeInput.bottom).offset(kOffset);
        make.height.equalTo(@(kHeight));
    }];
    [self.addressL2Input makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.addressL1Input.bottom).offset(kOffset);
        make.height.equalTo(@(kHeight));
    }];

    [self.confirmButton makeConstraints:^(MASConstraintMaker *make) {

        make.top.equalTo(self.addressL2Input.bottom).offset(kOffset);
        make.height.equalTo(@(kHeight));
        make.bottom.equalTo(self.scrollView.bottom).offset(-kOffset);
    }];
}

- (void)setInputResponderChain {

    NSArray *textFields = @[self.nameInput, self.surnameInput, self.bioInput, self.postcodeInput, self.addressL1Input, self.addressL2Input];
    for (UIResponder *responder in textFields) {
        if ([responder isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)responder;
            textField.returnKeyType = UIReturnKeyNext;
            textField.delegate = self;
        }
    }
    self.bioInput.delegate = self;
    self.bioInput.returnKeyType = UIReturnKeyNext;

    self.addressL2Input.returnKeyType = UIReturnKeyDone;
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {

    [textView adjustHeightIfNeeded];
}

// Dismiss on Done
// http://stackoverflow.com/questions/703754/how-to-dismiss-keyboard-for-uitextview-with-return-key
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self.postcodeInput becomeFirstResponder];
        //[textView resignFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDone) {
        [self.view endEditing:YES];
    }

    return [self setNextResponder:textField] ? NO : YES;
}

- (BOOL)setNextResponder:(UITextField *)textField {

    NSArray *textFields = @[self.nameInput, self.surnameInput, self.bioInput, self.postcodeInput, self.addressL1Input, self.addressL2Input];
    NSInteger indexOfInput = [textFields indexOfObject:textField];
    if (indexOfInput != NSNotFound && indexOfInput < textFields.count - 1) {
        UIResponder *next = [textFields objectAtIndex:(NSUInteger)(indexOfInput + 1)];
        if ([next canBecomeFirstResponder]) {
            [next becomeFirstResponder];
            return YES;
        }
    }
    return NO;
}

- (IBAction)backToTopButtonPressed:(id)sender {
    [self.nameInput becomeFirstResponder];
}

- (IBAction)clearButtonPressed:(id)sender {

    NSArray *textFields = @[self.nameInput, self.surnameInput, self.bioInput, self.postcodeInput, self.addressL1Input, self.addressL2Input];
    for (id input in textFields) {
        [input setText:@""];
    }
}

- (void)dismissKeyboard {
    [self.view endEditing:YES];
}


@end
