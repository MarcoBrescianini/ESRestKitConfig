//
//  ESPlistMappingFactory.m
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <RestKit/RestKit.h>

#import "ESPlistMappingFactory.h"

static NSString * const kDefaultFilename = @"Mappings";

@implementation ESPlistMappingFactory


-(instancetype)init
{
    self = [self initWithFilename:kDefaultFilename];
    return self;
}

- (instancetype)initWithStore:(RKManagedObjectStore *)store
{
    self = [self initWithFilename:kDefaultFilename store:store];
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename
{
    self = [self initWithFilename:filename inBundle:[NSBundle mainBundle]];
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename inBundle:(NSBundle *)bundle
{
    self = [self initWithFilename:filename inBundle:bundle store:nil];
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename store:(RKManagedObjectStore *)store
{
    self = [self initWithFilename:filename inBundle:[NSBundle mainBundle] store:store];
    return self;
}

- (instancetype)initWithFilename:(NSString *)filename inBundle:(NSBundle *)bundle store:(RKManagedObjectStore *)store
{
    NSString * path = [bundle pathForResource:filename ofType:@"plist"];

    if (!path)
        @throw [NSException exceptionWithName:@"PlistNotFoundException" reason:@"File not found" userInfo:nil];

    self = [self initWithFilepath:path store:store];
    return self;
}

- (instancetype)initWithFilepath:(NSString *)filepath
{
    self = [self initWithFilepath:filepath store:nil];
    return self;
}

- (instancetype)initWithFilepath:(NSString *)filepath store:(RKManagedObjectStore *)store
{
    self = [super initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:filepath] store:store];
    return self;
}

@end
