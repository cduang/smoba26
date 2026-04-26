//
//  crossproc.h
//  h5gg
//
//  Created by admin on 25/4/2022.
//

#ifndef crossproc_h
#define crossproc_h


#import <sys/sysctl.h>
#import <mach-o/dyld_images.h>

extern "C" {
#include "dyld64.h"
#include "libproc.h"
}

#endif /* crossproc_h */
