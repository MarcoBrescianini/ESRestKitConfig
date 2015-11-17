//
// Created by Marco Brescianini on 16/11/15.
// Copyright (c) 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

#import "ESRequestDescriptorFactory.h"

typedef NSDictionary<NSString*, RKMapping*> * TYMappingMap;

@interface ESPlistRequestDescriptorFactory : NSObject<ESRequestDescriptorFactory>

@property (nonatomic, strong, readonly, nonnull) TYMappingMap mappings; //TODO: SHOULD BE READWRITE AND MOVED IN INTERFACE
@property (nonatomic, strong, readonly, nonnull) NSDictionary * config;


-(instancetype)initWithMappings:(TYMappingMap)mappings config:(NSDictionary*)config;
-(instancetype)initWithMappings:(TYMappingMap)mappings filepath:(NSString*)filepath;
-(instancetype)initWithMappings:(TYMappingMap)mappings fromMainBundle:(NSString*)filename;

-(RKRequestDescriptor*)descriptorForName:(NSString*)name;

@end
