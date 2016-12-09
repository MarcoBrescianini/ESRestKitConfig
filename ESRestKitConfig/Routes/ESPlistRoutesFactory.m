//
//  ESPlistRoutesFactory.m
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ESPlistRoutesFactory.h"

static NSString * const kDefaultFilename = @"Routes";


@implementation ESPlistRoutesFactory


- (instancetype)init
{
    self = [self initWithFilename:kDefaultFilename];
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename
{
    self = [self initWithFilename:filename inBundle:[NSBundle mainBundle]];
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename inBundle:(NSBundle *)bundle
{
    NSString * path = [bundle pathForResource:filename ofType:@"plist"];

    if (!path)
        @throw [NSException exceptionWithName:@"PlistNotFoundException" reason:@"Plist file not found" userInfo:nil];

    self = [self initWithFilepath:path];
    return self;
}


- (instancetype)initWithFilepath:(NSString *)filepath
{
    self = [super initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:filepath]];
    return self;
}


@end
