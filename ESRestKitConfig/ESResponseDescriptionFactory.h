//
//  ESResponseDescriptionFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 16/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKResponseDescriptor;

@protocol ESResponseDescriptionFactory <NSObject>

-(NSArray<RKResponseDescriptor*>*)createResponseDescriptors;

@end
