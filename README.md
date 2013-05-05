ABGameKitHelper
===============

Objective-C Helper class to ease interaction with Apple&#39;s GameKit API

Should work with all types of Apps, also Cocos2d 1 & 2+

Features:
--
- Show Leaderboards (specify which) / Achievements
- Report Scores to Leaderboards / Report Achievements
- Achievement / Score Caching System
- All saved data is encrypted (AppStore Safe) … no cheating here ;)

____

ARC:
--
ABGameKitHelper uses ARC, to use it in a non ARC project be sure to add "-fobjc-arc" flag in "Compile Sources" configuration:

Targets->Build Phases->Compile Sources->ABGameKitHelper.m
___

Tutorial:
--
Getting ABGameKitHelper up and running is fairly easy, here a step by step guide to get you started:

1. Link "GameKit.framework" with your Project

2. In ABGameKitHelper.h edit SECRET_KEY  to your liking

3. Call following code once the UI of your application is loaded

	<code>[ABGameKitHelper sharedHelper];</code>


3. Thats the basic setup, easy huh? Now on to actually interacting with GameCenter:

<strong>Show Leaderboard</strong>

<code>[[ABGameKitHelper sharedHelper] showLeaderboard:@"leaderboardId"];</code>

<strong>Show Achievements</strong>

<code>[[ABGameKitHelper sharedHelper] showAchievements];</code>

<strong>Report Achievement</strong>

<code>[[ABGameKitHelper sharedHelper] reportAchievement:@"achievementId" percentComplete:100.0f];</code>

<strong>Show Notification</strong> (Shown only once per completed Achievement)

<code>[[ABGameKitHelper sharedHelper] showNotification:@"Notification Title" message:@"Some Message" identifier:@"achievementID"];</code>

<strong>Report Leaderboard Score</strong>

<code>
[[ABGameKitHelper sharedHelper] reportScore:2000 forLeaderboard:@"leaderboardId"];
</code>

<strong>!</strong>
If no Internet connection is present during reporting Achievemnts/Leaderboard Scores are automatically cached and reported the next time the Player authenticates

____

Future:
--
- Mac / Moutain Lion Compatibility

____

License:
--
MIT License, check "LICENSE"