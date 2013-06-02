//
//  ABGameKitHelper.h
//
//  Created by Alexander Blunck on 27.02.12.
//  Copyright (c) 2013 Alexander Blunck | Ablfx
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#ifndef ABGAMEKITHELPER_LOGGING
    #define ABGAMEKITHELPER_LOGGING 1
#endif

/**
 * Set SECRET_KEY for proper encryption
 */
#define SECRET_KEY @"MySecretKeyHere"

@interface ABGameKitHelper : NSObject

/**
 * Always access class through this singleton
 * Call it once on application start to authenticate local player
 */
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


@property (nonatomic, assign, getter = isAuthenticated) BOOL authenticated;

@end
