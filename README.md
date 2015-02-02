#s3eSteam
========================
Updated: 02/02/15
Marmalade version: 7.5.0
Steamworks version: 1.31
Author: Dmitry "SnipER" Vladimirov.
========================
This is an extension for the Marmalade SDK to support Steamworks API for achievements, stats and leaderboards.
Quick extension with base functionality (without callbacks) is also included.
Steamworks SDK is not included, because is provided under Valve non-disclosure agreement.
Not tested on MAC, however, code is literally the same(s3eSteam_platform.mm == s3eSteam_platform.cpp), so there should not be any problems.


========================
Setup for C++ and Quick
========================
1. Copy extension to project root folder, or any folder specified in options module_path section of project's mkb file.
2. Provide path to download steamworks SDK in steamworks_sdk_location.mkf (by default, searches for steamworks_sdk_131.zip in same folder).
3. Change steam_appid.txt (currently is set to 480 - id of Steamworks SDK's steamworksexample). Before release, remove steam_appid.txt entry from s3eSteam.mkf.
4. Add s3eSteam into subprojects section in project mkb file.
5. Include "s3eSteam.h" header.
6. Before using any other methos, call s3eSteamAvailable() + s3eSteamStart(), ensure last one returns true (see code snippets section below).
7. Call s3eSteamUpdate() from time to time to update callbacks (on each frame works fine too).
Optional for Marmalade Quick (Windows):
8. Run quickuser_tolua.bat, it will add QSteamworks.* files to build.
Even more optional for Marmalade Quick:
9. Make new Quick binaries by calling %S3E_DIR%\..\quick\quick_prebuilt.mkb


========================
Code snippets (C++)
(See full API in s3eSteam.s4e)
========================

#if defined(IW_MKF_S3ESTEAM) && (IW_MKF_S3ESTEAM != 0)
#include "s3eSteam.h"
#include "steamclientpublic.h" // Used for EResult enum
#endif // defined(IW_MKF_S3ESTEAM) && (IW_MKF_S3ESTEAM != 0)


#if defined(IW_MKF_S3ESTEAM) && (IW_MKF_S3ESTEAM != 0)
//------------------------------------------------------------------------------
// Callbacks
int32 _SteamCbUserStatsReceived(void* systemData, void* userData)
{
    EResult * result = reinterpret_cast<EResult*>(systemData);
    if (*result != k_EResultOK)
    {
        printf("=== _SteamCbUserStatsReceived: %d\n", *result);
    }
    return 0;
}
int32 _SteamCbUserStatsStored(void* systemData, void* userData)
{
    EResult * result = reinterpret_cast<EResult*>(systemData);
    if (*result != k_EResultOK)
    {
        printf("=== _SteamCbUserStatsStored: %d\n", *result);
    }
    return 0;
}
int32 _SteamCbAchievementStored(void* systemData, void* userData)
{
    uint32 * result = reinterpret_cast<uint32*>(systemData);
    printf("=== _SteamCbAchievementStored: Unlocked: %d\n", *result == 0);
    return 0;
}
int32 _SteamCbLeaderboardFound(void* systemData, void* userData)
{
    s3eSteamLeaderboardFound * data = reinterpret_cast<s3eSteamLeaderboardFound*>(systemData);
    printf("=== _SteamCbLeaderboardFound: %s, %d\n", data->name, data->success);

    s3eSteamLeaderboardDownloadEntries("Feet Traveled", s3eSteamELeaderboardDataRequestGlobalAroundUser, -2, 2);
    return 0;
}
int32 _SteamCbLeaderboardUpdated(void* systemData, void* userData)
{
    s3eSteamLeaderboardScoreUploaded * data = reinterpret_cast<s3eSteamLeaderboardScoreUploaded*>(systemData);
    printf("=== _SteamCbLeaderboardUpdated: %s, %d, %d, %d, %d, %d, %d\n", data->name, data->success, data->changed, data->score, data->globalRankNew, data->globalRankPrevious);
    return 0;
}
int32 _SteamCbLeaderboardEntries(void* systemData, void* userData)
{
    s3eSteamLeaderboardEntries * data = reinterpret_cast<s3eSteamLeaderboardEntries*>(systemData);
    printf("=== _SteamCbLeaderboardEntries: %s, %d\n", data->name, data->count);
    for (uint i = 0; i < data->count; ++i)
    {
        s3eSteamLeaderboardEntry & entry = data->entries[i];
        printf("   ===%s, %d, %d, %d\n", entry.name, entry.score, entry.globalRank, entry.details);
    }

    return 0;
}

//Init
    if (s3eSteamAvailable())
    {	
        if (s3eSteamStart())
        {
            s3eSteamRegister(s3eSteamCallback_UserStatsReceived, _SteamCbUserStatsReceived, NULL);
            s3eSteamRegister(s3eSteamCallback_UserStatsStored, _SteamCbUserStatsStored, NULL);
            s3eSteamRegister(s3eSteamCallback_AchievementStored, _SteamCbAchievementStored, NULL);
            s3eSteamRegister(s3eSteamCallback_LeaderboardFound, _SteamCbLeaderboardFound, NULL);
            s3eSteamRegister(s3eSteamCallback_LeaderboardUpdated, _SteamCbLeaderboardUpdated, NULL);
            s3eSteamRegister(s3eSteamCallback_LeaderboardEntries, _SteamCbLeaderboardEntries, NULL);

            s3eSteamLeaderboardInit("Quickest Win");
            s3eSteamLeaderboardInit("SomeOther");
            s3eSteamLeaderboardInit("Feet Traveled");
        }
    }
    else
    {
        printf("Steam initialization failed!\n");
        s3eDeviceRequestQuit();
    }
    
// Terminate
    if (s3eSteamAvailable())
    {
        s3eSteamUnRegister(s3eSteamCallback_UserStatsReceived, _SteamCbUserStatsReceived);
        s3eSteamUnRegister(s3eSteamCallback_UserStatsStored, _SteamCbUserStatsStored);
        s3eSteamUnRegister(s3eSteamCallback_AchievementStored, _SteamCbAchievementStored);
        s3eSteamUnRegister(s3eSteamCallback_LeaderboardFound, _SteamCbLeaderboardFound);
        s3eSteamUnRegister(s3eSteamCallback_LeaderboardUpdated, _SteamCbLeaderboardUpdated);
        s3eSteamUnRegister(s3eSteamCallback_LeaderboardEntries, _SteamCbLeaderboardEntries);
    }
    
// Update
    if (s3eSteamAvailable())
    {
        s3eSteamUpdate();
    }

#endif // defined(IW_MKF_S3ESTEAM) && (IW_MKF_S3ESTEAM != 0)


========================
Code snippets (Quick)
(See full API in quick/QSteamworks.h)
========================
if steamworks.isAvailable() and steamworks.isStarted() then
    steamworks.setAchievement("someid")
    lang = steamworks.getCurrentGameLanguage()
end