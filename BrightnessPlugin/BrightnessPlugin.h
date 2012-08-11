//
//  BrightnessPlugin.h
//  BrightnessPlugin
//
//  Created by Atsushi on 11/03/27.
//  Copyright 2011 Atsushi Tagami. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/Webkit.h>

@interface BrightnessPlugin : NSObject {
	NSTimer* _timer;
}

-(void) dealloc;
-(id) initWithWebView:(WebView*) webView;
-(void) windowScriptObjectAvailable:(WebScriptObject*) webScriptObject;
+(BOOL) isSelectorExcludedFromWebScript:(SEL)selector;
+(NSString*) webScriptNameForSelector:(SEL)selector;
-(BOOL) setBrightness:(NSString*) value;

@end
