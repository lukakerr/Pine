#ifdef __OBJC__
#import <Cocoa/Cocoa.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "cmark-gfm-swift.h"

FOUNDATION_EXPORT double cmark_gfm_swiftVersionNumber;
FOUNDATION_EXPORT const unsigned char cmark_gfm_swiftVersionString[];

