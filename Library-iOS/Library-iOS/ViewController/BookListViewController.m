//
//  BookListViewController.m
//  Library-iOS
//
//  Created by Vitor Leonardi on 6/13/13.
//  Copyright (c) 2013 Vitor Leonardi. All rights reserved.
//

#import "BookListViewController.h"
#import "BookDetailViewController.h"
#import <RestKit/RestKit.h>
#import "Book.h"

@interface BookListViewController ()
{
    NSArray *arrayBooks;
    BOOL isLogedIn;
}
@end

@implementation BookListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        isLogedIn = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self getBookList];
    
//    arrayBooks = @[@{@"Autor": @"Bernard Cornwell", @"Livro": @"O Arqueiro", @"Capa": @"images.jpeg"}, @{@"Autor": @"Bernard Cornwell", @"Livro": @"O Andarilho", @"Capa": @"images-1.jpeg"}, @{@"Autor": @"Bernard Cornwell", @"Livro": @"O Herege", @"Capa": @"images-2.jpeg"}, @{@"Autor": @"George R. Martin", @"Livro": @"Game of Thrones", @"Capa": @"images.jpeg"}, @{@"Autor": @"George R. Martin", @"Livro": @"Dance With Dragons", @"Capa": @"images-1.jpeg"}];

    self.title = @"Livros";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayBooks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Book *book = arrayBooks[indexPath.row];
    
    [cell.textLabel setText:book.title];
    [cell.detailTextLabel setText:book.author];
    
    return cell;
}

- (void)getBookList
{
    RKObjectMapping *bookMapping = [RKObjectMapping requestMapping];
    [bookMapping addAttributeMappingsFromArray:@[@"title", @"author", @"category", @"available"]];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:bookMapping pathPattern:nil keyPath:@"book" statusCodes:statusCodes];
    
    // Error mapping
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                    pathPattern:nil
                                                                                        keyPath:@"errors.message"
                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://192.241.132.106:8080/libraryWS/"]];
    
    //    [manager addRequestDescriptor:requestDescriptor];
    [manager addResponseDescriptorsFromArray:@[responseDescriptor, errorDescriptor]];
    
    // POST to create
    [manager getObjectsAtPath:@"book" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSMutableArray *bookList = [[NSMutableArray alloc] init];
        for (NSDictionary *bookDict in [mappingResult array]) {
            Book *book = [[Book alloc] init];
            [book setTitle:bookDict[@"title"]];
//            [book setAvailable:bookDict["available"]];
            [book setAuthor:bookDict[@"author"][@"name"]];
            [book setCategory:bookDict[@"category"][@"type"]];
            [bookList addObject:book];
            book = nil;
        }
        
        arrayBooks = bookList;
        [self.tableView reloadData];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self performSegueWithIdentifier:@"bookEditSegue" sender:arrayBooks[indexPath.row]];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"bookEditSegue"]) {
        BookDetailViewController *bookVC = [segue destinationViewController];
        [bookVC setBook:sender];
    }
}

@end
