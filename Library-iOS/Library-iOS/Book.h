//
//  Book.h
//  Library-iOS
//
//  Created by Vitor Leonardi on 7/3/13.
//  Copyright (c) 2013 Vitor Leonardi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Book : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *category;
@property (assign) BOOL available;
@end
