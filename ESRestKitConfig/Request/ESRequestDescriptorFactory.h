//
// Created by Marco Brescianini on 16/11/15.
// Copyright (c) 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKRequestDescriptor;

NS_ASSUME_NONNULL_BEGIN

@protocol ESRequestDescriptorFactory <NSObject>

- (NSArray<RKRequestDescriptor *> *)createAllDescriptors:(NSDictionary<NSString *, RKMapping *> *)mappings;
- (RKRequestDescriptor *)createDescriptorNamed:(NSString *)name forMappings:(NSDictionary<NSString *, RKMapping *> *)mappings;

@end

NS_ASSUME_NONNULL_END
