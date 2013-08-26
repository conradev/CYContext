//
//  CYContext.h
//  CYContext
//
//  Created by Conrad Kramer on 8/25/13.
//  Copyright (c) 2013 Kramer Software Productions, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CYContext : NSObject

- (NSString *)evaluateCycript:(NSString *)cycript error:(NSError **)error;

@end
