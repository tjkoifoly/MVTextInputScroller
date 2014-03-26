//
//  ViewController.m
//  MVTextInputScroller
//
//  Created by Andrea Bizzotto on 25/03/2014.
//  Copyright (c) 2014 musevisions. All rights reserved.
//

#import "ViewController.h"
#import "MVTextInputsScroller.h"

@interface ViewController()<UITextFieldDelegate, UITextViewDelegate>
@property(strong, nonatomic) MVTextInputsScroller *inputsScroller;
@property(strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property(strong, nonatomic) IBOutlet UITextField *nameInput;
@property(strong, nonatomic) IBOutlet UITextField *surnameInput;
@property(strong, nonatomic) IBOutlet UITextView *bioInput;
@property(strong, nonatomic) IBOutlet UITextField *postcodeInput;
@property(strong, nonatomic) IBOutlet UITextField *addressL1Input;
@property(strong, nonatomic) IBOutlet UITextField *addressL2Input;
@end
@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.inputsScroller = [[MVTextInputsScroller alloc] initWithScrollView:self.scrollView];
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
