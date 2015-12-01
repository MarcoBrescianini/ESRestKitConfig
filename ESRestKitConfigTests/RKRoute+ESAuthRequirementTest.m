//
//  RKRoute+TYAuthRequirementTest.m
//  Engineering Solutions
//
//  Created by Marco Brescianini on 26/11/15.
//  Copyright (c) 2015 Engineering Solutions. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RKRoute+ESAuthRequirement.h"

@interface RKRoute_ESAuthRequirementTest : XCTestCase

@end

@implementation RKRoute_ESAuthRequirementTest


//-------------------------------------------------------------------------------------------
#pragma mark - Test Associated Objects


-(void)testRouteWithNameFactoryMethod
{
    RKRoute * route = [RKRoute routeWithName:@"route_name"
               pathPattern:@"foo/bar"
                    method:RKRequestMethodGET
              authRequired:YES
                 authScope:@"dummy"];

    XCTAssertNotNil(route);
    XCTAssertEqual(route.isAuthRequired, YES);
    XCTAssertEqualObjects(route.authScope, @"dummy");
}


-(void)testRouteWithClassFactoryMethod
{
    RKRoute * route = [RKRoute routeWithClass:[NSString class]
                                 pathPattern:@"foo/bar"
                                      method:RKRequestMethodGET
                                authRequired:YES
                                   authScope:@"dummy"];

    XCTAssertNotNil(route);
    XCTAssertEqual(route.isAuthRequired, YES);
    XCTAssertEqualObjects(route.authScope, @"dummy");
}


-(void)testRouteWithRelationshipNameFactoryMethod
{
    RKRoute *route = [RKRoute routeWithRelationshipName:@"relationship"
                                            objectClass:[NSString class]
                                            pathPattern:@"foo/bar"
                                                 method:RKRequestMethodGET
                                           authRequired:NO
                                              authScope:@"dummy"];

    XCTAssertNotNil(route);
    XCTAssertEqual(route.isAuthRequired, NO);
    XCTAssertEqualObjects(route.authScope, @"dummy");
}


@end
