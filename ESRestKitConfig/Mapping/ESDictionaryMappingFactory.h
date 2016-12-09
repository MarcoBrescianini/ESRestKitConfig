//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESMappingFactory.h"

@class RKManagedObjectStore;
@class RKDynamicMapping;
@class RKObjectMapping;
@class RKEntityMapping;

NS_ASSUME_NONNULL_BEGIN

@interface ESDictionaryMappingFactory : NSObject <ESMappingFactory>

@property (nonatomic, strong, readonly) NSDictionary * config;
@property (nonatomic, strong, readonly) RKManagedObjectStore * store;

- (instancetype)initWithDictionary:(NSDictionary *)config;
- (instancetype)initWithDictionary:(NSDictionary *)config store:(nullable RKManagedObjectStore *)store NS_DESIGNATED_INITIALIZER;

- (RKDynamicMapping *)createDynamicMappingFrom:(NSDictionary *)dictionary;
- (RKObjectMapping *)createObjectMappingFrom:(NSDictionary *)dictionary;
- (RKEntityMapping *)createEntityMappingFrom:(NSDictionary *)mappingDictionary;
- (RKEntityMapping *)createEntityMappingFrom:(NSDictionary *)mappingDictionary inStore:(RKManagedObjectStore *)store;

@end

NS_ASSUME_NONNULL_END
