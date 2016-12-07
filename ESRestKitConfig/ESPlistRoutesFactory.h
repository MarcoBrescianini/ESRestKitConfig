//
//  ESPlistRoutesFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESRoutesFactory.h"

@interface ESPlistRoutesFactory : NSObject<ESRoutesFactory>

@property (nonatomic, strong, readonly) NSDictionary * config;

-(instancetype)initFromMainBundle:(NSString*)filename;
-(instancetype)initWithPlistFilePath:(NSString*)filepath;
-(instancetype)initWithDictionary:(NSDictionary*)dictionary;

-(RKRoute*)createRouteNamed:(NSString*)routeName;

@end
