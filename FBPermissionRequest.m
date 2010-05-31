//
//  FBPermissionRequest.m
//  Thumbprint
//
//  Created by Blake Watters on 5/13/09.
//  Copyright 2009 Two Toasters. All rights reserved.
//

#import "FBPermissionRequest.h"

@interface FBPermissionRequest (Private)
- (void)informDelegatePermissionWasGranted;
- (void)informDelegatePermissionWasDenied;
@end

@implementation FBPermissionRequest

@synthesize session = _session;
@synthesize permissionName = _permissionName;
@synthesize delegate = _delegate;

static NSString* kFacebookExtendedPermissionParamName = @"ext_perm";
static NSString* kFacebookCheckForPermissionApiCallName = @"facebook.Users.hasAppPermission";
static int kFacebookPermissionGranted = 1;

+ (FBPermissionRequest*)checkForPermission:(NSString*)permissionName withSession:(FBSession*)session delegate:(id)delegate {
	FBPermissionRequest* permissionRequest = [[[FBPermissionRequest alloc] initWithSession:session] autorelease];
	permissionRequest.delegate = delegate;
	[permissionRequest checkForPermission:permissionName];
	
	return permissionRequest;
}

+ (FBPermissionRequest*)checkForPermission:(NSString*)permissionName delegate:(id)delegate {
	FBPermissionRequest* permissionRequest = [[[FBPermissionRequest alloc] init] autorelease];
	permissionRequest.delegate = delegate;
	[permissionRequest checkForPermission:permissionName];
	
	return permissionRequest;
}

+ (FBPermissionRequest*)askForPermission:(NSString*)permissionName withSession:(FBSession*)session delegate:(id)delegate {
	FBPermissionRequest* permissionRequest = [[[FBPermissionRequest alloc] initWithSession:session] autorelease];
	permissionRequest.delegate = delegate;
	[permissionRequest askForPermission:permissionName];
	
	return permissionRequest;
}

+ (FBPermissionRequest*)askForPermission:(NSString*)permissionName delegate:(id)delegate {
	FBPermissionRequest* permissionRequest = [[[FBPermissionRequest alloc] init] autorelease];
	permissionRequest.delegate = delegate;
	[permissionRequest askForPermission:permissionName];
	
	return permissionRequest;
}

+ (FBPermissionRequest*)acquirePermission:(NSString*)permissionName withSession:(FBSession*)session delegate:(id)delegate {
	FBPermissionRequest* permissionRequest = [[[FBPermissionRequest alloc] initWithSession:session] autorelease];
	permissionRequest.delegate = delegate;
	[permissionRequest acquirePermission:permissionName];
	
	return permissionRequest;
}

+ (FBPermissionRequest*)acquirePermission:(NSString*)permissionName delegate:(id)delegate {
	FBPermissionRequest* permissionRequest = [[[FBPermissionRequest alloc] init] autorelease];
	permissionRequest.delegate = delegate;
	[permissionRequest acquirePermission:permissionName];
	
	return permissionRequest;
}

- (id)init {
	if (self = [super init]) {
		self.session = [FBSession session];
		attemptAcquisition = NO;
	}
	
	return self;
}

- (id)initWithSession:(FBSession*)session {
	if (self = [super init]) {
		self.session = session;
		attemptAcquisition = NO;
	}
	
	return self;
}

- (void)dealloc {
	[_session release];
	[_permissionRequest release];
	[_permissionDialog release];
	[_permissionName release];
	[super dealloc];
}

- (void)checkForPermission:(NSString*)permissionName {
	NSLog(@"Checking for Facebook permission: %@", permissionName);
	_permissionName = [permissionName retain];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys: permissionName, kFacebookExtendedPermissionParamName, nil];
	_permissionRequest = [FBRequest requestWithDelegate:self];
	[_permissionRequest call:kFacebookCheckForPermissionApiCallName params:params];
}

- (void)askForPermission:(NSString*)permissionName {
	NSLog(@"Asking user to grant Facebook permission: %@", permissionName);
	_permissionName = [permissionName retain];
	_permissionDialog = [[[FBPermissionDialog alloc] init] autorelease];
	_permissionDialog.delegate = self;
	_permissionDialog.permission = permissionName;
	[_permissionDialog show];
}

- (void)acquirePermission:(NSString*)permissionName {
	attemptAcquisition = YES;
	[self checkForPermission:permissionName];
}


#pragma mark FBDialogDelegate Methods

- (void)dialogDidSucceed:(FBDialog*)dialog {
	[self informDelegatePermissionWasGranted];
}

- (void)dialogDidCancel:(FBDialog*)dialog {
	[self informDelegatePermissionWasDenied];
}


#pragma mark FBRequestDelegate Methods

- (void)request:(FBRequest*)request didLoad:(id)result {
	NSLog(@"Received response on a Facebook request!!! Request: %@, Result: %@", request, result);
	if (request == _permissionRequest) {
		NSLog(@"Request checking for permission %@ returned with a result of: %@", _permissionName, result);
		if ([(NSString*) result intValue] == kFacebookPermissionGranted) {
			[self informDelegatePermissionWasGranted];
		} else {
			// Permission check return NO			
			if (attemptAcquisition == YES) {
				[self askForPermission:_permissionName];
			} else {
				[self informDelegatePermissionWasDenied];
			}
		}
	}
}

- (void)request:(FBRequest*)request didFailWithError:(NSError*)error {
	if ([_delegate respondsToSelector:@selector(permissionRequest:didFailWithError:)]) {
		[_delegate permissionRequest:self didFailWithError:error];
	}
}

#pragma mark Private

- (void)informDelegatePermissionWasGranted {
	if ([_delegate respondsToSelector:@selector(permissionRequestWasGranted:)]) {
		[_delegate permissionRequestWasGranted:self];
	}
}

- (void)informDelegatePermissionWasDenied {
	if ([_delegate respondsToSelector:@selector(permissionRequestWasDenied:)]) {
		[_delegate permissionRequestWasDenied:self];
	}
}

@end
