//
//  CYContext.m
//  CYContext
//
//  Created by Conrad Kramer on 8/25/13.
//  Copyright (c) 2013 Kramer Software Productions, LLC. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

#include <cycript/cycript.h>

#import "CYContext.h"

@implementation CYContext {
    JSGlobalContextRef _context;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _context = JSGlobalContextCreate(NULL);
        CydgetSetupContext(_context);
    }
    return self;
}

- (void)dealloc {
    JSGlobalContextRelease(_context);
}

- (NSString *)evaluateCycript:(NSString *)cycript error:(NSError **)error {
    // Parse Cycript into Javascript
    size_t length = cycript.length;
    unichar *buffer = malloc(length * sizeof(unichar));
    [cycript getCharacters:buffer range:NSMakeRange(0, length)];
    const uint16_t *characters = buffer;
    CydgetMemoryParse(&characters, &length);
    JSStringRef expression = JSStringCreateWithCharacters(characters, length);

    // Evaluate the Javascript
    JSValueRef exception = NULL;
    JSValueRef result = JSEvaluateScript(_context, expression, NULL, NULL, 0, &exception);
    free(buffer);
    JSStringRelease(expression);

    NSString *resultString = nil;

    // If a result was returned, convert it into an NSString
    if (result) {
        JSStringRef string = JSValueToStringCopy(_context, result, &exception);
        if (string) {
            resultString = (__bridge_transfer NSString *)JSStringCopyCFString(kCFAllocatorDefault, string);
            JSStringRelease(string);
        }
    }

    // If an exception was thrown, convert it into an NSError
    if (exception) {
        JSStringRef string = JSValueToStringCopy(_context, exception, NULL);
        NSString *errorDescription = (__bridge_transfer NSString *)JSStringCopyCFString(kCFAllocatorDefault, string);
        JSStringRelease(string);
        if (error) {
            NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: errorDescription };
            *error = [NSError errorWithDomain:@"CYContextDomain" code:0 userInfo:userInfo];
        }
    }

    return resultString;
}

@end
