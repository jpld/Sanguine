//
//  SanguinePlugIn.m
//  Sanguine
//
//  Created by jpld on 14 Dec 2009.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
//

#import "SanguinePlugIn.h"
#import <MacRuby/MacRuby.h>

#if CONFIGURATION == DEBUG
    #define SADebugLogSelector() NSLog(@"-[%@ %@]", /*NSStringFromClass([self class])*/self, NSStringFromSelector(_cmd))
    #define SADebugLog(a...) NSLog(a)
#else
    #define SADebugLogSelector()
    #define SADebugLog(a...)
#endif

#define SALocalizedString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:(nil)]


// WORKAROUND - naming violation for cocoa memory management
@interface QCPlugIn(CameraObscuraAdditions)
- (QCPlugInViewController*)createViewController NS_RETURNS_RETAINED;
@end


@implementation SanguinePlugIn

@synthesize sourceCodeString = _sourceCodeString;

+ (NSDictionary*)attributes {
    return [NSDictionary dictionaryWithObjectsAndKeys:SALocalizedString(@"kQCPlugIn_Name", NULL), QCPlugInAttributeNameKey, SALocalizedString(@"kQCPlugIn_Description", NULL), QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary*)attributesForPropertyPortWithKey:(NSString*)key {
    // ports are dynamically added, none available by default
    return nil;
}

+ (QCPlugInExecutionMode)executionMode {
    return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode)timeMode {
    return kQCPlugInTimeModeNone;
}

+ (NSArray*)plugInKeys {
    // TODO - code
    return nil;
}

#pragma mark -

- (id)init {
    self = [super init];
    if(self) {
    }	
    return self;
}

- (void)finalize {
	/*
	Release any non garbage collected resources created in -init.
	*/

    [_sourceCodeString release];

    [super finalize];
}

- (void)dealloc {
	/*
	Release any resources created in -init.
	*/

    [_sourceCodeString release];

    [super dealloc];
}

#pragma mark -

- (id)serializedValueForKey:(NSString*)key {
	/*
	Provide custom serialization for the plug-in internal settings that are not values complying to the <NSCoding> protocol.
	The return object must be nil or a PList compatible i.e. NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
	*/

    SADebugLogSelector();

    return [super serializedValueForKey:key];
}

- (void)setSerializedValue:(id)serializedValue forKey:(NSString*)key {
	/*
	Provide deserialization for the plug-in internal settings that were custom serialized in -serializedValueForKey.
	Deserialize the value, then call [self setValue:value forKey:key] to set the corresponding internal setting of the plug-in instance to that deserialized value.
	*/

    SADebugLogSelector();

    [super setSerializedValue:serializedValue forKey:key];
}

- (QCPlugInViewController*)createViewController {
	/*
	Return a new QCPlugInViewController to edit the internal settings of this plug-in instance.
	You can return a subclass of QCPlugInViewController if necessary.
	*/

    return [[QCPlugInViewController alloc] initWithPlugIn:self viewNibName:@"Settings"];
}

#pragma mark -

- (BOOL)startExecution:(id<QCPlugInContext>)context {
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/

    SADebugLogSelector();

    // DEBUG
    [[MacRuby sharedRuntime] evaluateString:@"puts 'hi'"];

    return YES;
}

- (void)enableExecution:(id<QCPlugInContext>)context {
	/*
	Called by Quartz Composer when the plug-in instance starts being used by Quartz Composer.
	*/

    SADebugLogSelector();
}

- (BOOL)execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary*)arguments {
	/*
	Called by Quartz Composer whenever the plug-in instance needs to execute.
	Only read from the plug-in inputs and produce a result (by writing to the plug-in outputs or rendering to the destination OpenGL context) within that method and nowhere else.
	Return NO in case of failure during the execution (this will prevent rendering of the current frame to complete).
	
	The OpenGL context for rendering can be accessed and defined for CGL macros using:
	CGLContextObj cgl_ctx = [context CGLContextObj];
	*/

    SADebugLogSelector();

    return YES;
}

- (void)disableExecution:(id<QCPlugInContext>)context {
	/*
	Called by Quartz Composer when the plug-in instance stops being used by Quartz Composer.
	*/

    SADebugLogSelector();
}

- (void)stopExecution:(id<QCPlugInContext>)context {
	/*
	Called by Quartz Composer when rendering of the composition stops: perform any required cleanup for the plug-in.
	*/

    SADebugLogSelector();
}

@end
