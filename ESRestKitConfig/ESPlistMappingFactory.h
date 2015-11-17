//
//  ESPlistMappingFactory.h
//  Engineering Solutions
//
//  Created by Marco Brescianini on 15/10/15.
//  Copyright © 2015 Engineering Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ESMappingFactory.h"

@class RKManagedObjectStore;

@interface ESPlistMappingFactory : NSObject<ESMappingFactory>


@property (nonatomic, strong, readonly) NSDictionary * config;
@property (nonatomic, strong, readonly) RKManagedObjectStore * store; //TODO: SHOULD BE MOVED IN INTERFACE Entity Mapping cannot be created without a managed store

-(instancetype)initFromMainBundle:(NSString*)filename store:(RKManagedObjectStore*)store;
-(instancetype)initWithPlistFile:(NSString*)filepath store:(RKManagedObjectStore*)store;
-(instancetype)initWithDictionary:(NSDictionary*)config store:(RKManagedObjectStore*)store;

-(RKMapping*)mappingWithName:(NSString*)name;

@end
