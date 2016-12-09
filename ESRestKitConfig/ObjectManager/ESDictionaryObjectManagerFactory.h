//
// Created by Engineering Solutions on 09/12/2016.
// Copyright (c) 2016 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESObjectManagerFactory.h"

@class RKManagedObjectStore;
@class RKEntityMapping;
@class NSManagedObjectModel;

@protocol ESMappingFactory;
@protocol ESRoutesFactory;
@protocol ESResponseDescriptorFactory;
@protocol ESRequestDescriptorFactory;

NS_ASSUME_NONNULL_BEGIN

@interface ESDictionaryObjectManagerFactory : NSObject <ESObjectManagerFactory>

@property (nonatomic, strong, readonly) NSDictionary * config;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithConfig:(NSDictionary * )config NS_DESIGNATED_INITIALIZER;

- (RKManagedObjectStore *)createManagedObjectStore:(NSDictionary *)storeConfig;
- (NSManagedObjectModel *)loadManagedObjectModel:(NSDictionary *)storeConfig;

- (void)createCoreDataStack:(NSDictionary *)storeConfig store:(RKManagedObjectStore *)store;
- (void)setupStoreCache:(NSDictionary *)storeConfig store:(RKManagedObjectStore *)store;
- (void)loadRoutesAndDescriptorsIn:(RKObjectManager *)manager;

- (id <ESRoutesFactory>)createRoutesFactory;
- (id <ESMappingFactory>)createMappingsFactory:(RKObjectManager *)manager;
- (id <ESResponseDescriptorFactory>)createResponseDescriptorFactory:(NSDictionary<NSString *, RKEntityMapping *> *)mappings;
- (id <ESRequestDescriptorFactory>)createRequestDescriptorFactory:(NSDictionary<NSString *, RKEntityMapping *> *)mappings;

+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
