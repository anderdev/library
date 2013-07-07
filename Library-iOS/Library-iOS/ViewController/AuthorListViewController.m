//
//  AuthorListViewController.m
//  Library-iOS
//
//  Created by Vitor Leonardi on 6/13/13.
//  Copyright (c) 2013 Vitor Leonardi. All rights reserved.
//

#import "AuthorListViewController.h"
#import <RestKit/RestKit.h>
#import "Author.h"

@interface AuthorListViewController ()
{
    NSArray *arrayAuthors;
}
@end

@implementation AuthorListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Autores";
    
    [self getAuthorList];
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
    return [arrayAuthors count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    Author *author = arrayAuthors[indexPath.row];
    [cell.textLabel setText:author.name];
    
    return cell;
}

- (void)getAuthorList
{
    RKObjectMapping *bookMapping = [RKObjectMapping requestMapping];
    [bookMapping addAttributeMappingsFromArray:@[@"name", @"id"]];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:bookMapping pathPattern:nil keyPath:@"author" statusCodes:statusCodes];
    
    // Error mapping
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[RKErrorMessage class]];
    [errorMapping addPropertyMapping:[RKAttributeMapping attributeMappingFromKeyPath:nil toKeyPath:@"errorMessage"]];
    RKResponseDescriptor *errorDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping
                                                                                    pathPattern:nil
                                                                                        keyPath:@"errors.message"
                                                                                    statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    
    RKObjectManager *manager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://192.241.132.106:8080/libraryWS/"]];
    
    [manager addResponseDescriptorsFromArray:@[responseDescriptor, errorDescriptor]];
    
    // POST to create
    [manager getObjectsAtPath:@"author" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSMutableArray *authorList = [[NSMutableArray alloc] init];
        for (NSDictionary *authorDict in [mappingResult array]) {
            Author *author = [[Author alloc] init];
            [author setName:authorDict[@"name"]];
            [author setAuthorId:authorDict[@"id"]];
            [authorList addObject:author];
            author = nil;
        }
        
        arrayAuthors = authorList;
        [self.tableView reloadData];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
