//
//  cppBridge.m
//  
// Author: Alexandre Brehmer
// @alexnesnes

#import "cppFunctions.h"
#import "cppBridge.h"

@implementation cppFunctionsBridge

+ (void) getCpu: (float*) returnTab
{
    cppFunctions::getCpu(returnTab);
}

+ (void) getRam: (float*) returnTab
{
    cppFunctions::getRam(returnTab);
}

+ (void) getNetwork: (float*) returnTab
{
    cppFunctions::getNetwork(returnTab);
}
@end