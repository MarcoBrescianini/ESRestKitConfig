//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import "ESPlistObjectManagerFactory.h"

@implementation ESPlistObjectManagerFactory


- (instancetype)init
{
    self = [self initWithFilename:@"Configuration"];
    return self;
}


- (instancetype)initWithFilename:(NSString *)filename
{
    self = [self initWithFilename:filename inBundle:[NSBundle mainBundle]];
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename inBundle:(NSBundle *)bundle
{
    NSString * filepath = [bundle pathForResource:filename ofType:@"plist"];

    if(!filepath)
        @throw [NSException exceptionWithName:@"PlistNotFoundException" reason:@"Plist file not found" userInfo:nil];

    self = [self initWithFilepath:filepath];
    return self;
}

- (instancetype)initWithFilepath:(NSString *)filepath
{
    self = [self initWithFilepath:filepath baseURL:nil];
    return self;
}

- (instancetype)initWithFilepath:(NSString *)filepath baseURL:(NSString *)baseURL
{
    self = [super initWithConfig:[NSDictionary dictionaryWithContentsOfFile:filepath] baseURL:baseURL];
    return self;
}


@end
