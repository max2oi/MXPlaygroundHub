//
//  AppDelegate.m
//  MXPlaygroundHubExample
//
//  Created by max2oi on 2018/7/18.
//  Copyright © 2018 max2oi. All rights reserved.
//

#import "AppDelegate.h"
#import "MXPlaygroundHubViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[MXPlaygroundHubViewController alloc] init]];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
