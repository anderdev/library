//
//  LoginViewController.m
//  Library-iOS
//
//  Created by Vitor Leonardi on 6/27/13.
//  Copyright (c) 2013 Vitor Leonardi. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController () <UITextFieldDelegate>
{
    CGPoint scrollViewOffSet;
}
@property (weak, nonatomic) IBOutlet UITextField *textUser;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnDismissKeyboard;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)didClickAtConnect:(id)sender;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.textUser setTag:0];
    [self.textPassword setTag:1];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didClickAtConnect:(id)sender
{
    [self performSegueWithIdentifier:@"listBookSegue" sender:self];
}

- (IBAction)didEnterEditing:(id)sender
{
    [self.btnDismissKeyboard setHidden:NO];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 0) {
        CGPoint textOffset;
        textOffset.y = self.textPassword.frame.origin.y - 215;
        textOffset.x = 0;
        [self.scrollView setContentOffset:textOffset animated:YES];
        [textField resignFirstResponder];
        [self.textPassword becomeFirstResponder];
    }
    else
    {
        [self.textPassword resignFirstResponder];
    }
    
    return YES;
}

@end
