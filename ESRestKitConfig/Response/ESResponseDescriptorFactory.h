//
//  ESResponseDescriptorFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 16/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKResponseDescriptor;

NS_ASSUME_NONNULL_BEGIN

@protocol ESResponseDescriptorFactory <NSObject>

- (NSArray<RKResponseDescriptor *> *)createAllDescriptors;
- (RKResponseDescriptor *)createDescriptorNamed:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
