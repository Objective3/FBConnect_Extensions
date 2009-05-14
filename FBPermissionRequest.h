//
//  FBPermissionRequest.h
//  Thumbprint
//
//  Created by Blake Watters on 5/13/09.
//  Copyright 2009 Objective 3. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"

@protocol FBPermissionRequestDelegate;

@interface FBPermissionRequest : NSObject <FBRequestDelegate, FBDialogDelegate> {
	FBSession* _session;
	FBRequest* _permissionRequest;
	FBPermissionDialog* _permissionDialog;
	NSString* _permissionName;
	
	id<FBPermissionRequestDelegate> _delegate;
	
	BOOL attemptAcquisition;
}

@property (nonatomic, retain) FBSession* session;
@property (nonatomic, readonly) NSString* permissionName;

@property (nonatomic, assign) id<FBPermissionRequestDelegate> delegate;

+ (FBPermissionRequest*)checkForPermission:(NSString*)permissionName withSession:(FBSession*)session delegate:(id<FBPermissionRequestDelegate>)delegate;
+ (FBPermissionRequest*)checkForPermission:(NSString*)permissionName delegate:(id<FBPermissionRequestDelegate>)delegate;

+ (FBPermissionRequest*)askForPermission:(NSString*)permissionName withSession:(FBSession*)session delegate:(id<FBPermissionRequestDelegate>)delegate;
+ (FBPermissionRequest*)askForPermission:(NSString*)permissionName delegate:(id<FBPermissionRequestDelegate>)delegate;

+ (FBPermissionRequest*)acquirePermission:(NSString*)permissionName withSession:(FBSession*)session delegate:(id<FBPermissionRequestDelegate>)delegate;
+ (FBPermissionRequest*)acquirePermission:(NSString*)permissionName delegate:(id<FBPermissionRequestDelegate>)delegate;
											
- (id)initWithSession:(FBSession*)session;
- (void)checkForPermission:(NSString*)permissionName;
- (void)askForPermission:(NSString*)permissionName;
- (void)acquirePermission:(NSString*)permissionName;

@end

@protocol FBPermissionRequestDelegate <NSObject>

@optional

/**
 * Called when the permission request succeeded in obtaining the permission.
 */
- (void)permissionRequestWasGranted:(FBPermissionRequest*)permissionRequest;

/**
 * Called when the permission request failed to obtain the permission.
 */
- (void)permissionRequestWasDenied:(FBPermissionRequest*)permissionRequest;

/**
 * Called when an error prevents the request from completing successfully.
 */
- (void)permissionRequest:(FBPermissionRequest*)permissionRequest didFailWithError:(NSError*)error;

@end
