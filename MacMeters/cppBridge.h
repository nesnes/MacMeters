//
//  Header.h
//
// Author: Alexandre Brehmer
// @alexnesnes

#import <objc/NSObject.h>

#ifndef MacMeters_cppBridge_h
#define MacMeters_cppBridge_h

/// This Objective-C class represents a bridge to the C++ class ``` cppFunctions ```
@interface cppFunctionsBridge : NSObject
+ (void) getCpu: (float*) returnTab;
+ (void) getRam: (float*) returnTab;
+ (void) getNetwork: (float*) returnTab;
@end

#endif
