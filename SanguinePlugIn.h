//
//  SanguinePlugIn.h
//  Sanguine
//
//  Created by jpld on 14 Dec 2009.
//  Copyright (c) 2009 __MyCompanyName__. All rights reserved.
//

#import <Quartz/Quartz.h>

@interface SanguinePlugIn : QCPlugIn {
@private
    NSString* _sourceCodeString;
}
@property (nonatomic, retain) NSString* sourceCodeString;
@end
