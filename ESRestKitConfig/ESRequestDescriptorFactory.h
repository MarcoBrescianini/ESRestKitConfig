//
// Created by Marco Brescianini on 16/11/15.
// Copyright (c) 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKRequestDescriptor;

@protocol ESRequestDescriptorFactory <NSObject>

- (NSArray<RKRequestDescriptor *> *)createRequestDescriptors;
- (RKRequestDescriptor *)createDescriptorNamed:(NSString *)name;

@end
