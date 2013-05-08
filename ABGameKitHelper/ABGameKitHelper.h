//
//  ABGameKitHelper.h
//
//  Created by Alexander Blunck on 27.02.12.
//  Copyright (c) 2012 Ablfx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#ifndef ABGAMEKITHELPER_LOGGING
    #define ABGAMEKITHELPER_LOGGING 1
#endif

/**
 * Set SECRET_KEY for proper encryption
 */
#define SECRET_KEY @"MySecretKeyHere"

@protocol ABGameKitHelperDelegate

- (void) matchStarted;
- (void) matchEnded;
- (void) match:(GKMatch*)match didReceiveData:(NSData *)data
   fromPlayer:(NSString*)playerID;

@end

@interface ABGameKitHelper : NSObject <GKMatchmakerViewControllerDelegate, GKMatchDelegate> 

/**
 * Always access class through this singleton
 * Call it once on application start to authenticate local player
 */

@property (retain) UIViewController* presentingViewController;
@property (retain) GKMatch* match;
@property (assign) id <ABGameKitHelperDelegate> delegate;

@property (nonatomic, assign, getter = isAuthenticated) BOOL authenticated;


+(id) sharedHelper;


/**
 * Leaderboards
 */
-(void) reportScore:(long long)aScore forLeaderboard:(NSString*)leaderboardId;
-(void) showLeaderboard:(NSString*)leaderboardId;


/**
 * Achievements
 */
-(void) reportAchievement:(NSString*)achievementId percentComplete:(double)percent;
-(void) showAchievements;
-(void) resetAchievements;


/**
 * Notifications
 */
-(void) showNotification:(NSString*)title message:(NSString*)message identifier:(NSString*)achievementId;

/**
 * MatchMaking
 */

- (void)findMatchWithMinPlayers:(int)minPlayers maxPlayers:(int)maxPlayers
				 viewController:(UIViewController *)viewController
					   delegate:(id<ABGameKitHelperDelegate>)theDelegate;

@end
