//
//  UserListViewController.m
//  Library-iOS
//
//  Created by Vitor Leonardi on 7/4/13.
//  Copyright (c) 2013 Vitor Leonardi. All rights reserved.
//

#import "UserListViewController.h"
#import <RestKit/RestKit.h>
#import "User.h"

@interface UserListViewController ()
{
    NSArray *arrayUsers;
}
@end

@implementation UserListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self getUserList];
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
    return [arrayUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    User *user = arrayUsers[indexPath.row];
    [cell.textLabel setText:user.name];
    [cell.detailTextLabel setText:user.email];
    
    return cell;
}

- (void)getUserList
{
    RKObjectMapping *bookMapping = [RKObjectMapping requestMapping];
    [bookMapping addAttributeMappingsFromArray:@[@"name", @"email"]];
    
    NSIndexSet *statusCodes = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:bookMapping pathPattern:nil keyPath:@"user" statusCodes:statusCodes];
    
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
    [manager getObjectsAtPath:@"user" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSMutableArray *userList = [[NSMutableArray alloc] init];
        for (NSDictionary *userDict in [mappingResult array]) {
            User *user = [[User alloc] init];
            [user setName:userDict[@"name"]];
            [user setEmail:userDict[@"email"]];
            [userList addObject:user];
            user = nil;
        }
        
        arrayUsers = userList;
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
