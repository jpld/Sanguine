//
//  SanguinePlugIn.m
//  Sanguine
//
//  Created by jpld on 14 Dec 2009.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
//

#import "SanguinePlugIn.h"
#import "SanguinePlugInViewController.h"
#import <MacRuby/MacRuby.h>

#if CONFIGURATION == DEBUG
    #define SADebugLogSelector() NSLog(@"-[%@ %@]", /*NSStringFromClass([self class])*/self, NSStringFromSelector(_cmd))
    #define SADebugLog(a...) NSLog(a)
#else
    #define SADebugLogSelector()
    #define SADebugLog(a...)
#endif

#define SALocalizedString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:(nil)]

static NSString* _SASourceCodeStringObservationContext = @"_SASourceCodeStringObservationContext";
static NSString* _SACodePrologueString = @"begin;";
static NSString* _SACodeEpilogueString = @"; rescue Exception => e; $stderr.puts $!.inspect; end;";
// static NSString* _SACodeHelperString = @"; class SACodeHelper; def self.inputs(); Inputs; end; def self.outputs(); Outputs; end; def self.run_main(inputs=nil); main(inputs); end; end;";


// WORKAROUND - naming violation for cocoa memory management
@interface QCPlugIn(CameraObscuraAdditions)
- (QCPlugInViewController*)createViewController NS_RETURNS_RETAINED;
@end


@interface SanguinePlugIn()
@property (nonatomic, retain) NSArray* inPorts;
@property (nonatomic, retain) NSArray* outPorts;
- (void)_setupObservation;
- (void)_invalidateObservation;
- (void)_setupPorts;
@end

@implementation SanguinePlugIn

@synthesize sourceCodeString = _sourceCodeString, inPorts = _inputPorts, outPorts = _outputPorts;

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
    return [NSArray arrayWithObjects:@"sourceCodeString", nil];
}

#pragma mark -

- (id)init {
    self = [super init];
    if(self) {
        // self.sourceCodeString = @"puts 'hello'\n";
        [self _setupObservation];
    }
    return self;
}

- (void)finalize {
	/*
	Release any non garbage collected resources created in -init.
	*/

    [_sourceCodeString release];
    [_inputPorts release];
    [_outputPorts release];

    [self _invalidateObservation];

    [super finalize];
}

- (void)dealloc {
	/*
	Release any resources created in -init.
	*/

    [_sourceCodeString release];
    [_inputPorts release];
    [_outputPorts release];

    [self _invalidateObservation];

    [super dealloc];
}

#pragma mark -

- (id)serializedValueForKey:(NSString*)key {
	/*
	Provide custom serialization for the plug-in internal settings that are not values complying to the <NSCoding> protocol.
	The return object must be nil or a PList compatible i.e. NSString, NSNumber, NSDate, NSData, NSArray or NSDictionary.
	*/

    SADebugLogSelector();

    id value = nil;
    if ([key isEqualToString:@"sourceCodeString"])
        // TODO - should probably be localized default snippet not a newline
        value = self.sourceCodeString ? self.sourceCodeString : @"\n";
    else
        value = [super serializedValueForKey:key];
    return value;
}

- (void)setSerializedValue:(id)serializedValue forKey:(NSString*)key {
	/*
	Provide deserialization for the plug-in internal settings that were custom serialized in -serializedValueForKey.
	Deserialize the value, then call [self setValue:value forKey:key] to set the corresponding internal setting of the plug-in instance to that deserialized value.
	*/

    SADebugLogSelector();

    if ([key isEqualToString:@"sourceCodeString"])
        self.sourceCodeString = (NSString*)serializedValue;
    else
        [super setSerializedValue:serializedValue forKey:key];
}

- (QCPlugInViewController*)createViewController {
	/*
	Return a new QCPlugInViewController to edit the internal settings of this plug-in instance.
	You can return a subclass of QCPlugInViewController if necessary.
	*/

    return [[SanguinePlugInViewController alloc] initWithPlugIn:self viewNibName:@"Settings"];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if (context == _SASourceCodeStringObservationContext) {
        // TODO - validate
        // TODO - check inputs and outputs
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark -

- (BOOL)startExecution:(id<QCPlugInContext>)context {
	/*
	Called by Quartz Composer when rendering of the composition starts: perform any required setup for the plug-in.
	Return NO in case of fatal failure (this will prevent rendering of the composition to start).
	*/

    SADebugLogSelector();

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

#pragma mark -
#pragma mark PRIVATE

- (void)_setupObservation {
    [self addObserver:self forKeyPath:@"sourceCodeString" options:0 context:_SASourceCodeStringObservationContext];
}

- (void)_invalidateObservation {
    [self removeObserver:self forKeyPath:@"sourceCodeString"];
}

- (void)_setupPorts {
    [[MacRuby sharedRuntime] evaluateString:[NSString stringWithFormat:@"%@ %@ %@", _SACodePrologueString, self.sourceCodeString, _SACodeEpilogueString]];
    // NB - this only needs to be executed once
    // [[MacRuby sharedRuntime] evaluateString:_SACodeHelperString];

    id typeSymbol = [[MacRuby sharedRuntime] evaluateString:@":type"];
    id keySymbol = [[MacRuby sharedRuntime] evaluateString:@":key"];

    NSArray* inputs = [[MacRuby sharedRuntime] evaluateString:@"Sanguine.inputs"];
    BOOL inputsChanged = ![inputs isEqual:self.inPorts];
    if (inputsChanged) {
        for (NSDictionary* dict in self.inPorts)
            [self removeInputPortForKey:[dict objectForKey:keySymbol]];
        for (NSDictionary* dict in inputs) {
            NSString* type = [dict objectForKey:typeSymbol];
            NSString* key = [dict objectForKey:keySymbol];
            [self addInputPortWithType:type forKey:key withAttributes:nil];
        }
        self.inPorts = inputs;
    }

    NSArray* outputs = [[MacRuby sharedRuntime] evaluateString:@"Sanguine.outputs"];
    BOOL outputsChanged = ![outputs isEqual:self.outPorts];
    if (outputsChanged) {
        for (NSDictionary* dict in self.outPorts)
            [self removeOutputPortForKey:[dict objectForKey:keySymbol]];
        for (NSDictionary* dict in outputs) {
            NSString* type = [dict objectForKey:typeSymbol];
            NSString* key = [dict objectForKey:keySymbol];
            [self addOutputPortWithType:type forKey:key withAttributes:nil];
        }
        self.outPorts = outputs;
    }    
}

@end
