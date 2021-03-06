//
// Created by Marco Brescianini on 16/11/15.
// Copyright (c) 2015 Engineering Solutions. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ESPlistRequestDescriptorFactory.h"

static NSString * const kDefaultFilename = @"Request";

@implementation ESPlistRequestDescriptorFactory


- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:@"Wrong designated initializer"
                                 userInfo:nil];
}

- (instancetype)initWithMappings:(ESMappingMap)mappings
{
    self = [self initWithMappings:mappings filename:kDefaultFilename];
    return self;
}

- (instancetype)initWithMappings:(ESMappingMap)mappings filename:(NSString *)filename
{
    self = [self initWithMappings:mappings filename:filename inBundle:[NSBundle mainBundle]];
    return self;
}


- (instancetype)initWithMappings:(ESMappingMap)mappings filename:(NSString *)filename inBundle:(NSBundle *)bundle
{
    NSString * path = [bundle pathForResource:filename ofType:@"plist"];

    if(!path)
        @throw [NSException exceptionWithName:@"PlistNotFoundException" reason:@"Plist file not found" userInfo:nil];

    self = [self initWithMappings:mappings filepath:path];
    return self;
}

- (instancetype)initWithMappings:(ESMappingMap)mappings filepath:(NSString *)filepath
{
    self = [super initWithMappings:mappings config:[NSDictionary dictionaryWithContentsOfFile:filepath] ];
    return self;
}

@end
