//
// Created by Marco Brescianini on 16/11/15.
// Copyright (c) 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESRequestDescriptorFactory.h"

@class RKMapping;

typedef NSDictionary<NSString*, RKMapping*> *ESMappingMap;

@interface ESPlistRequestDescriptorFactory : NSObject<ESRequestDescriptorFactory>

@property (nonatomic, strong, readonly, nonnull) ESMappingMap mappings; //TODO: SHOULD BE READWRITE AND MOVED IN INTERFACE
@property (nonatomic, strong, readonly, nonnull) NSDictionary * config;


-(instancetype)initWithMappings:(ESMappingMap)mappings config:(NSDictionary*)config;
-(instancetype)initWithMappings:(ESMappingMap)mappings filepath:(NSString*)filepath;
-(instancetype)initWithMappings:(ESMappingMap)mappings fromMainBundle:(NSString*)filename;

-(RKRequestDescriptor*)createDescriptorNamed:(NSString*)name;

@end
