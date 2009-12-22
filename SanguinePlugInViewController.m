//
//  SanguinePlugInViewController
//  Sanguine
//
//  Created by jpld on 20 Dec 2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SanguinePlugInViewController.h"
#import "SanguinePlugIn.h"

@implementation SanguinePlugInViewController

- (IBAction)build:(id)sender {
    [(SanguinePlugIn*)self.plugIn performSelector:@selector(_setupPorts)];
}

@end
