//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESResponseDescriptorFactory.h"

@class RKMapping;

typedef NSDictionary<NSString *, RKMapping *> * ESMappingMap;

NS_ASSUME_NONNULL_BEGIN

@interface ESDictionaryResponseDescriptorFactory : NSObject <ESResponseDescriptorFactory>

@property (nonatomic, strong, readonly) ESMappingMap mappings;
@property (nonatomic, strong, readonly) NSDictionary * config;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithMappings:(ESMappingMap)mappings config:(NSDictionary *)config NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
