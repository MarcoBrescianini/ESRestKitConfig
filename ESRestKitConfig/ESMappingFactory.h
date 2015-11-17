//
//  ESMappingFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RKMapping;

@protocol ESMappingFactory <NSObject>

-(NSDictionary<NSString*, RKMapping*>*)createMappings;

@end
