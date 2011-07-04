/*
 * Copyright (c) 2008 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "RadarForwarderPref.h"
#import "AppInfo.h"
#import "RadarForwarderConstants.h"

#import <CoreServices/CoreServices.h>

@interface RadarForwarderPref ()

- (void)launchEmbeddedForwarder;
- (void)updatePreferences;
- (void)updateApplications;
- (void)updateForwardingUrl;

- (NSString *)defaultHandlerByScheme;
- (NSString *)defaultHandlerByUrl;
- (NSString *)defaultHandler;

@end

#define kAppIdStr ((CFStringRef)kAppId)
#define kForwardingUrlFormatKeyStr ((CFStringRef)kForwardingUrlFormatKey)

@implementation RadarForwarderPref

@synthesize applications = _applications;
@synthesize selectedApplication = _selectedApplication;
@synthesize forwardingUrl = _forwardingUrl;

- (void)dealloc
{
    [_selectedApplication release];
    [_applications release];
    [_forwardingUrl release];
    
    [super dealloc];
}

- (void) mainViewDidLoad
{
    [self launchEmbeddedForwarder];
    [self updatePreferences];
}

- (void)didSelect
{
    [self updatePreferences];
}

- (void)didUnselect
{
    CFPreferencesSetAppValue(kForwardingUrlFormatKeyStr, _forwardingUrl, kAppIdStr);
    CFPreferencesAppSynchronize(kAppIdStr);
    
#if 0 // TODO: Send distributed notification
    CFNotificationCenterRef center;
    center = CFNotificationCenterGetDistributedCenter();
    CFNotificationCenterPostNotification(center,
                                         CFSTR("Preferences Changed"), kAppId, NULL, TRUE);
#endif
}

- (IBAction)applicationChanged:(id)sender;
{
    OSStatus result = LSSetDefaultHandlerForURLScheme(CFSTR("rdar"),
                                                      (CFStringRef)_selectedApplication.bundleId);
    if (result != noErr)
    {
        NSLog(@"LSSetDefaultHandlerForURLScheme failed: (%d) %s", result,
              GetMacOSStatusErrorString(result));
    }
}

- (void)launchEmbeddedForwarder;
{
    NSBundle * bundle = [self bundle];
    NSString * appPath = [bundle pathForResource:@"RadarForwarder" ofType:@"app"];

    // Use Launch Services because -[NSWorkspace launchApplication:] activates
    // the new application.
    FSRef appRef;
    FSPathMakeRef((const UInt8 *)[appPath fileSystemRepresentation], &appRef, NULL);
    LSApplicationParameters parameters;
    parameters.version = 0;
    parameters.flags = kLSLaunchDefaults;
    parameters.application = &appRef;
    parameters.asyncLaunchRefCon = NULL;
    parameters.environment = NULL;
    parameters.argv = NULL;
    parameters.initialEvent = NULL;
    OSStatus result = LSOpenApplication(&parameters, NULL);
    if (result != noErr)
    {
        NSLog(@"LSOpenApplication failed: (%d) %s", result,
              GetMacOSStatusErrorString(result));
    }
}

- (void)updatePreferences;
{
    [self updateApplications];
    [self updateForwardingUrl];
}

- (void)updateApplications;
{
    NSArray * handlers = (NSArray *)
        LSCopyAllHandlersForURLScheme(CFSTR("rdar"));
    [handlers autorelease];
    
    NSString * defaultHandler = [self defaultHandler];
    
    NSMutableArray * applications = [NSMutableArray array];
    AppInfo * selectedApp = nil;
    for (NSString * bundleId in handlers)
    {
        AppInfo * info = [AppInfo appInfoWithBundleId:bundleId];
        [applications addObject:info];
        if ([bundleId isEqualToString:defaultHandler])
            selectedApp = info;
    }
    self.applications = applications;
    self.selectedApplication = selectedApp;
}

- (void)updateForwardingUrl;
{
    CFPropertyListRef value = CFPreferencesCopyAppValue(kForwardingUrlFormatKeyStr, kAppIdStr);
    if (value && CFGetTypeID(value) == CFStringGetTypeID())
        self.forwardingUrl = (NSString *)value;
    else
        self.forwardingUrl = nil;
    if (value != nil)
        CFRelease(value);
}

- (NSString *)defaultHandler;
{
    NSString * defaultHandler = [self defaultHandlerByScheme];
    if (defaultHandler == nil)
        defaultHandler = [self defaultHandlerByUrl];
    return defaultHandler;
}

- (NSString *)defaultHandlerByScheme;
{
    NSString * defaultHandler = (NSString *)
        LSCopyDefaultHandlerForURLScheme(CFSTR("rdar"));
    [defaultHandler autorelease];
    return defaultHandler;
}

- (NSString *)defaultHandlerByUrl;
{
    NSURL * appUrl;
    NSURL * testUrl = [NSURL URLWithString:@"rdar://1"];
    LSGetApplicationForURL((CFURLRef)testUrl, kLSRolesAll, NULL,
                           (CFURLRef *)&appUrl);
    [appUrl autorelease];
    
    if (appUrl == nil)
        return nil;
    
    NSString * appPath = [appUrl path];
    if (appPath == nil)
        return nil;
    
    NSBundle * appBundle = [NSBundle bundleWithPath:appPath];
    if (appBundle == nil)
        return nil;
    
    NSString * identifier = [appBundle bundleIdentifier];
    return identifier;
}

@end
