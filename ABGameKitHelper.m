//
//  ABGameKitHelper.m
//  Pastry Panic
//
//  Created by Alexander Blunck on 27.02.12.
//  Copyright (c) 2012 Ablfx. All rights reserved.
//

#import "ABGameKitHelper.h"
#import "AppDelegate.h"

#define APPNAME @"AppName"

@implementation ABGameKitHelper

@synthesize isAuthenticated, isActivated;

//Singleton Setup
+ (id)sharedClass
{
    static dispatch_once_t pred;
    static ABGameKitHelper *gameKit = nil;
    
    dispatch_once(&pred, ^{ gameKit = [[self alloc] init]; });
    return gameKit;
}

-(void) authenticatePlayer {
    GKLocalPlayer *player = [GKLocalPlayer localPlayer];
    [player authenticateWithCompletionHandler:^(NSError *error) {
        if (player.isAuthenticated) {
            isAuthenticated = YES;
            NSLog(@"GK - Player successfully authenticated");
            //Report possible cached Achievements / Scores
            [self reportCachedAchievements];
            [self reportCachedScores];
        }
        
        if (error != nil) {
            NSLog(@"GK - Error in authenticatePlayer - Error: %@", error);
        }
    }];
}

-(void) showLeaderboard {
    GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
    leaderboardViewController.leaderboardDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] presentModalViewController:leaderboardViewController animated:YES];
}

-(void) showAchievements {
    GKAchievementViewController *achievementsViewController = [[GKAchievementViewController alloc] init];
    achievementsViewController.achievementDelegate = self;
    
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
    [[app navController] presentModalViewController:achievementsViewController animated:YES];
}

-(void) reportScore:(int)score forLeaderboard:(NSString*)leaderboardName {
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:leaderboardName] autorelease];
    scoreReporter.value = score;
    
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if (error != nil){
            NSLog(@"GK - Error during reportScore: - Error: %@", error);
            [self cacheScore:scoreReporter];
        } else {
            NSLog(@"GK - Score:%i Leaderboard:%@ reported", score, leaderboardName);
        }
    }];
}

-(void) cacheScore:(GKScore*)score {
    //Retrieve Array of all Cached Scoress
    NSData *loadedArrayData = [self loadDataForKey:@"cachedscores"];
    NSMutableArray *scoresArray = [NSKeyedUnarchiver unarchiveObjectWithData:loadedArrayData];
    
    //Add new achievement to Array
    [scoresArray addObject:score];
    
    //Save Array back to presitent storage
    NSData *newArrayData = [NSKeyedArchiver archivedDataWithRootObject:scoresArray];
    [self saveData:newArrayData withKey:@"cachedscores"];
}

-(void) reportCachedScores {
    //Retrieve Array of all Cached Achievements
    NSData *loadedArrayData = [self loadDataForKey:@"cachedscores"];
    NSMutableArray *scoresArray = [NSKeyedUnarchiver unarchiveObjectWithData:loadedArrayData];
    
    //Array to keep track of successfully reported Achievements
    NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
    
    for (GKScore *score in scoresArray) {
        
        [score reportScoreWithCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"GK - Error during reportCachesScores: - Error: %@", error);
            } else {
                NSLog(@"GK - Score:%@ Leaderboard:%@ reported", score.value, score.category);
                //Add to deleteArray
                [deleteArray addObject:score];
            }
        }];
        
    }
    
    //Delete successfully reported Achievement Objects from achievementArray 
    [scoresArray removeObjectsInArray:deleteArray];
    
    //Save Array back to presitent storage
    NSData *newArrayData = [NSKeyedArchiver archivedDataWithRootObject:scoresArray];
    [self saveData:newArrayData withKey:@"cachedscores"];
    
    [deleteArray release];
    deleteArray = nil;
}

-(void) reportAchievement:(NSString*)identifier percentComplete:(float)percent {
    
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier:identifier ]  autorelease];
    if (achievement) {
        achievement.percentComplete = percent;
        
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"GK - Error during reportAchievement: - Error: %@", error);
                //Caching solution
                [self cacheAchievement:achievement];
                
            } else {
                NSLog(@"GK - Achievement:%@ Percent:%f reported", identifier, percent);
                //Locally report Achievement as completed
                if (percent == 100) {
                    [self saveBool:YES withKey:identifier];
                }
            }
            
        }];
    }
    
}

-(void) cacheAchievement:(GKAchievement*)achievement {
    //Retrieve Array of all Cached Achievements
    NSData *loadedArrayData = [self loadDataForKey:@"cachedachievements"];
    NSMutableArray *achievementArray = [NSKeyedUnarchiver unarchiveObjectWithData:loadedArrayData];
    
    //Add new achievement to Array
    [achievementArray addObject:achievement];
    
    //Save Array back to presitent storage
    NSData *newArrayData = [NSKeyedArchiver archivedDataWithRootObject:achievementArray];
    [self saveData:newArrayData withKey:@"cachedachievements"];
}

-(void) reportCachedAchievements {
    //Retrieve Array of all Cached Achievements
    NSData *loadedArrayData = [self loadDataForKey:@"cachedachievements"];
    NSMutableArray *achievementArray = [NSKeyedUnarchiver unarchiveObjectWithData:loadedArrayData];
    
    //Array to keep track of successfully reported Achievements
    NSMutableArray *deleteArray = [[NSMutableArray alloc] init];
    
    for (GKAchievement *achievement in achievementArray) {
        if (achievement) {
            [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"GK - Error during reportCachedAchievement: - Error: %@", error);
                    
                } else {
                    NSLog(@"GK - CachedAchievement:%@ Percent:%f reported", achievement.identifier, achievement.percentComplete);
                    //Locally report Achievement as completed
                    if (achievement.percentComplete == 100) {
                        [self saveBool:YES withKey:achievement.identifier];
                    }
                    //Add to deleteArray
                    [deleteArray addObject:achievement];
                }
            }];
        }
    }
    
    //Delete successfully reported Achievement Objects from achievementArray 
    [achievementArray removeObjectsInArray:deleteArray];
    
    //Save Array back to presitent storage
    NSData *newArrayData = [NSKeyedArchiver archivedDataWithRootObject:achievementArray];
    [self saveData:newArrayData withKey:@"cachedachievements"];
    
    [deleteArray release];
    deleteArray = nil;
}

-(void) resetAchievements {
    [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"GK - Error during resetAchievements: - Error: %@", error);
        }
    }];
}

-(void) showNotification:(NSString*)title message:(NSString*)message identifier:(NSString*)identifier {
    //Show notification only if it hasn't been achieved before
    if (![self loadBoolForKey:identifier]) {
        [GKNotificationBanner showBannerWithTitle:title message:message completionHandler:^{
            //
        }];
    }
}

#pragma mark GK Delegate Methods
-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController {
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController {
    AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}


#pragma mark Data Persistence Methods

-(NSString*) getPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@_ABGameKitHelper.plist", APPNAME];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName]; 
    return path;
}

-(void) saveData:(NSData *)data withKey:(NSString *)key {
    //Check if file exits, if so init Dictionary with it's content, otherwise allocate new one
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[self getPath]];
    NSMutableDictionary *tempDic;
    if (fileExists == NO) {
        tempDic = [[NSMutableDictionary alloc] init];
    } else {
        tempDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[self getPath]];
    }
    //Populate Dictionary with to save value/key and write to file
    [tempDic setObject:data forKey:key];
    [tempDic writeToFile:[self getPath] atomically:YES];
    //Release allocated Dictionary
    [tempDic release];
}

-(NSData*) loadDataForKey:(NSString*)key {
    NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] initWithContentsOfFile:[self getPath]];
    NSData *loadedData = [tempDic objectForKey:key];
    return loadedData;
}

-(void) saveBool:(BOOL) boolean withKey:(NSString*) key {
    NSNumber *boolNumber = [NSNumber numberWithBool:boolean];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:boolNumber];
    [self saveData:data withKey:key];
}

-(BOOL) loadBoolForKey:(NSString*) key {
    NSData *loadedData = [self loadDataForKey:key];
    NSNumber *boolean;
    if (loadedData != NULL) {
        boolean = [NSKeyedUnarchiver unarchiveObjectWithData:loadedData];
    } else {
        boolean = [NSNumber numberWithBool:NO];
    }
    return [boolean boolValue];
}




@end










