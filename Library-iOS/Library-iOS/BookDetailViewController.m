//
//  BookDetailViewController.m
//  Library-iOS
//
//  Created by Vitor Leonardi on 7/1/13.
//  Copyright (c) 2013 Vitor Leonardi. All rights reserved.
//

#import "BookDetailViewController.h"

@interface BookDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblBookTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblAuthorName;
@property (weak, nonatomic) IBOutlet UIImageView *imgBookCover;

@end

@implementation BookDetailViewController

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
    
    [self.lblBookTitle setText:self.book.title];
    [self.lblAuthorName setText:self.book.author];
//    [self.imgBookCover setImage:[UIImage imageNamed:self.book[@"Capa"]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
