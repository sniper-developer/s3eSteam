/*
 * windows-specific implementation of the s3eSteam extension.
 * Add any platform-specific functionality here.
 */
/*
 * NOTE: This file was originally written by the extension builder, but will not
 * be overwritten (unless --force is specified) and is intended to be modified.
 */
#include "s3eSteam_internal.h"
#include "s3eEdk.h"
#include "IwDebug.h"

#include "steam_api.h"

#include <map>
#include <string>

CGameID g_GameID;
ISteamUserStats* g_pSteamUserStats = NULL;
bool g_bInited = false;
bool g_bStoreStats = false;
bool g_bRequestedStats = false;
typedef std::map<std::string, SteamLeaderboard_t> Leaderboards;
Leaderboards g_Leaderboards;

#define S3E_STEAM_LEADERBOARD_CALLBACK_CLEANUP(TYPE) \
{ \
	for (TYPE##s::const_iterator it = m_##TYPE.begin(), it_end = m_##TYPE.end(); it != it_end; ++it) \
	{ \
		delete it->second; \
	} \
	m_##TYPE.clear(); \
}

#define S3E_STEAM_LEADERBOARD_CALLBACK_DECLARE(CLASS, CB, STEAMTYPE, TYPE) \
private: \
	typedef CCallResult<CLASS, STEAMTYPE> TYPE; \
	typedef std::map<std::string, TYPE*> TYPE##s; \
	TYPE##s m_##TYPE; \
public: \
inline void set##TYPE(const char * pchName, SteamAPICall_t hSteamAPICall) \
{ \
	TYPE##s::iterator it = m_##TYPE.find(pchName); \
	if (it == m_##TYPE.end()) \
	{ \
		m_##TYPE.insert(std::make_pair(pchName, new TYPE)); \
		it = m_##TYPE.find(pchName); \
		if (it == m_##TYPE.end()) \
		{ \
			return; \
		} \
	} \
	it->second->Set(hSteamAPICall, this, &CLASS::CB); \
}

//--------------------------------------------------------------------------------
class CallbackHolder
{
public:
    CallbackHolder() :
        m_CallbackUserStatsReceived				(this, &CallbackHolder::OnUserStatsReceived),
        m_CallbackUserStatsStored				(this, &CallbackHolder::OnUserStatsStored),
        m_CallbackAchievementStored				(this, &CallbackHolder::OnAchievementStored)
    {}

	~CallbackHolder()
	{
		S3E_STEAM_LEADERBOARD_CALLBACK_CLEANUP(SteamCallResultFindLeaderboard);
		S3E_STEAM_LEADERBOARD_CALLBACK_CLEANUP(SteamCallResultUploadScore);
		S3E_STEAM_LEADERBOARD_CALLBACK_CLEANUP(SteamCallResultDownloadEntries);
	}

	S3E_STEAM_LEADERBOARD_CALLBACK_DECLARE(CallbackHolder, OnFindLeaderboard, LeaderboardFindResult_t, SteamCallResultFindLeaderboard);
	S3E_STEAM_LEADERBOARD_CALLBACK_DECLARE(CallbackHolder, OnUploadScore, LeaderboardScoreUploaded_t, SteamCallResultUploadScore);
	S3E_STEAM_LEADERBOARD_CALLBACK_DECLARE(CallbackHolder, OnLeaderboardDownloadedEntries, LeaderboardScoresDownloaded_t, SteamCallResultDownloadEntries);

private:
    STEAM_CALLBACK(CallbackHolder, OnUserStatsReceived, UserStatsReceived_t, m_CallbackUserStatsReceived);
    STEAM_CALLBACK(CallbackHolder, OnUserStatsStored, UserStatsStored_t, m_CallbackUserStatsStored);
    STEAM_CALLBACK(CallbackHolder, OnAchievementStored, UserAchievementStored_t, m_CallbackAchievementStored);

	void OnFindLeaderboard(LeaderboardFindResult_t *pFindLearderboardResult, bool bIOFailure);
	void OnUploadScore(LeaderboardScoreUploaded_t *pFindLearderboardResult, bool bIOFailure);
	void OnLeaderboardDownloadedEntries(LeaderboardScoresDownloaded_t *pLeaderboardScoresDownloaded, bool bIOFailure);
	static void OnLeaderboardDownloadedEntriesCompleted(uint32 extID, int32 notification, void* systemData, void* instance, int32 returnCode, void* completeData);
};

CallbackHolder * g_CallbackHolder = NULL;

//--------------------------------------------------------------------------------
s3eResult s3eSteamInit_platform()
{
    // Add any platform-specific initialisation code here
    return S3E_RESULT_SUCCESS;
}

void s3eSteamTerminate_platform()
{ 
    if (g_bInited)
    {
        SteamAPI_Shutdown();
        if (g_CallbackHolder)
        {
            delete g_CallbackHolder;
        }

		g_Leaderboards.clear();
    }
}

//--------------------------------------------------------------------------------
s3eBool s3eSteamStart_platform()
{
    if (SteamAPI_Init())
    {
        g_GameID = CGameID(SteamUtils()->GetAppID());
        g_pSteamUserStats = SteamUserStats();
        g_pSteamUserStats->RequestCurrentStats();
        
        g_CallbackHolder = new CallbackHolder();
        
        g_bInited = true;

        return S3E_TRUE;
    }
    
    return S3E_FALSE;
}

s3eBool s3eSteamRestartAppIfNecessary_platform(uint32 unOwnAppID)
{
    return SteamAPI_RestartAppIfNecessary(unOwnAppID);
}

s3eBool s3eSteamStarted_platform()
{
    return g_bInited ? S3E_TRUE : S3E_FALSE;
}
//--------------------------------------------------------------------------------
void s3eSteamUpdate_platform()
{
    if (g_bStoreStats && g_pSteamUserStats)
    {
        g_pSteamUserStats->StoreStats();
        g_bStoreStats = false;
    }
    
    SteamAPI_RunCallbacks();
}

//--------------------------------------------------------------------------------
s3eBool s3eSteamGetAchievement_platform(const char* pchName)
{
    if (g_bInited && g_pSteamUserStats)
    {
        bool achieved;
        g_pSteamUserStats->GetAchievement(pchName, &achieved);
        return achieved ? S3E_TRUE : S3E_FALSE;
    }
    
    return S3E_FALSE;
}

s3eBool s3eSteamSetAchievement_platform(const char* pchName)
{
    if (g_bInited && g_pSteamUserStats && g_pSteamUserStats->SetAchievement(pchName))
    {
        g_bStoreStats = true;
        return S3E_TRUE;
    }
    
    return S3E_FALSE;
}

s3eBool s3eSteamClearAchievement_platform(const char* pchName)
{
    return g_bInited && g_pSteamUserStats && g_pSteamUserStats->ClearAchievement(pchName);
}

//--------------------------------------------------------------------------------
int s3eSteamGetStatInt_platform(const char* pchName)
{
    if (g_bInited && g_pSteamUserStats)
    {
        int stat;
        g_pSteamUserStats->GetStat(pchName, &stat);
        return stat;
    }
    
    return 0;
}

float s3eSteamGetStatFloat_platform(const char* pchName)
{
    if (g_bInited && g_pSteamUserStats)
    {
        float stat;
        g_pSteamUserStats->GetStat(pchName, &stat);
        return stat;
    }
    
    return 0.f;
}

s3eBool s3eSteamSetStatInt_platform(const char* pchName, int nData)
{
    if (g_bInited && g_pSteamUserStats)
    {
        if (g_pSteamUserStats->SetStat(pchName, nData))
        {
            g_bStoreStats = true;
            return S3E_TRUE;
        }
    }

    return S3E_FALSE;
}

s3eBool s3eSteamSetStatFloat_platform(const char* pchName, float fData)
{
    if (g_bInited && g_pSteamUserStats)
    {
        if (g_pSteamUserStats->SetStat(pchName, fData))
        {
            g_bStoreStats = true;
            return S3E_TRUE;
        }
    }

    return S3E_FALSE;
}

s3eBool s3eSteamStoreStats_platform()
{
    return g_pSteamUserStats && g_pSteamUserStats->StoreStats();
}

s3eBool s3eSteamRequestCurrentStats_platform()
{
    return g_pSteamUserStats && g_pSteamUserStats->RequestCurrentStats();
}

//--------------------------------------------------------------------------------
void CallbackHolder::OnUserStatsReceived(UserStatsReceived_t *pCallback)
{
    if (!g_pSteamUserStats)
        return;

    if (g_GameID.ToUint64() != pCallback->m_nGameID)
        return;
        
    if (s3eEdkCallbacksIsRegistered(S3E_EXT_STEAM_HASH, s3eSteamCallback_UserStatsReceived))
    {
        s3eEdkCallbacksEnqueue(S3E_EXT_STEAM_HASH, s3eSteamCallback_UserStatsReceived, &pCallback->m_eResult, sizeof(pCallback->m_eResult));
    }
}

void CallbackHolder::OnUserStatsStored(UserStatsStored_t *pCallback)
{
    if (!g_pSteamUserStats)
        return;
        
    if (g_GameID.ToUint64() != pCallback->m_nGameID)
        return;

    if (s3eEdkCallbacksIsRegistered(S3E_EXT_STEAM_HASH, s3eSteamCallback_UserStatsStored))
    {
        s3eEdkCallbacksEnqueue(S3E_EXT_STEAM_HASH, s3eSteamCallback_UserStatsStored, &pCallback->m_eResult, sizeof(pCallback->m_eResult));
    }    
}

void CallbackHolder::OnAchievementStored(UserAchievementStored_t *pCallback)
{
    if (!g_pSteamUserStats)
        return;
        
    if (g_GameID.ToUint64() != pCallback->m_nGameID)
        return;

    if (s3eEdkCallbacksIsRegistered(S3E_EXT_STEAM_HASH, s3eSteamCallback_AchievementStored))
    {
        s3eEdkCallbacksEnqueue(S3E_EXT_STEAM_HASH, s3eSteamCallback_AchievementStored, &pCallback->m_nMaxProgress, sizeof(pCallback->m_nMaxProgress));
    }
}

//--------------------------------------------------------------------------------
const char * s3eSteamGetCurrentGameLanguage_platform()
{
    const char * lang = SteamApps() ? SteamApps()->GetCurrentGameLanguage() : NULL;
    if (!lang || strlen(lang) == 0)
    {
        lang = SteamUtils() ? SteamUtils()->GetSteamUILanguage() : NULL;
    }
    return lang;
}

//--------------------------------------------------------------------------------
s3eBool s3eSteamLeaderboardInit_platform(const char* pchName)
{
    if (g_pSteamUserStats && g_CallbackHolder)
	{
		SteamAPICall_t hSteamAPICall = g_pSteamUserStats->FindLeaderboard(pchName);
		if (hSteamAPICall != 0)
		{
			g_CallbackHolder->setSteamCallResultFindLeaderboard(pchName, hSteamAPICall);
			return S3E_TRUE;
		}
	}
    
	return S3E_FALSE;
}

s3eBool s3eSteamLeaderboardUploadScore_platform(const char* pchName, int32 value, s3eBool forceUpdate)
{
    if (g_pSteamUserStats && g_CallbackHolder)
	{
		Leaderboards::const_iterator it = g_Leaderboards.find(pchName);
		if (it != g_Leaderboards.end())
		{
			SteamAPICall_t hSteamAPICall = g_pSteamUserStats->UploadLeaderboardScore(it->second, forceUpdate == S3E_TRUE ? k_ELeaderboardUploadScoreMethodForceUpdate : k_ELeaderboardUploadScoreMethodKeepBest, value, NULL, 0);
			if (hSteamAPICall != 0)
			{
				g_CallbackHolder->setSteamCallResultUploadScore(pchName, hSteamAPICall);
				return S3E_TRUE;
			}
		}
	}

	return S3E_FALSE;
}

int s3eSteamLeaderboardGetEntryCount_platform(const char* pchName)
{
	if (g_pSteamUserStats)
	{
		Leaderboards::const_iterator it = g_Leaderboards.find(pchName);
		if (it != g_Leaderboards.end())
		{
			return g_pSteamUserStats->GetLeaderboardEntryCount(it->second);
		}
	}

	return 0;
}

s3eBool s3eSteamLeaderboardDownloadEntries_platform(const char* pchName, s3eSteamELeaderboardDataRequest eLeaderboardData, int nRangeStart, int nRangeEnd)
{
	if (g_pSteamUserStats)
	{
		Leaderboards::const_iterator it = g_Leaderboards.find(pchName);
		if (it != g_Leaderboards.end())
		{
			SteamAPICall_t hSteamAPICall = g_pSteamUserStats->DownloadLeaderboardEntries(it->second, static_cast<ELeaderboardDataRequest>(eLeaderboardData), nRangeStart, nRangeEnd);
			if (hSteamAPICall != 0)
			{
				g_CallbackHolder->setSteamCallResultDownloadEntries(pchName, hSteamAPICall);
				return S3E_TRUE;
			}
		}
	}

	return S3E_FALSE;
}

//--------------------------------------------------------------------------------
void CallbackHolder::OnFindLeaderboard(LeaderboardFindResult_t *pFindLeaderboardResult, bool bIOFailure)
{
	if (!g_pSteamUserStats)
		return;

	bool found = !bIOFailure && pFindLeaderboardResult->m_bLeaderboardFound;
	if (found)
	{
		g_Leaderboards.insert(std::make_pair(g_pSteamUserStats->GetLeaderboardName(pFindLeaderboardResult->m_hSteamLeaderboard), pFindLeaderboardResult->m_hSteamLeaderboard));
	}

	s3eSteamLeaderboardFound data;
	data.success = !bIOFailure && pFindLeaderboardResult->m_bLeaderboardFound != 0;
	strncpy(data.name, g_pSteamUserStats->GetLeaderboardName(pFindLeaderboardResult->m_hSteamLeaderboard), sizeof(data.name));
	
	if (s3eEdkCallbacksIsRegistered(S3E_EXT_STEAM_HASH, s3eSteamCallback_LeaderboardFound))
	{
		s3eEdkCallbacksEnqueue(S3E_EXT_STEAM_HASH, s3eSteamCallback_LeaderboardFound, &data, sizeof(data));
	}
}

void CallbackHolder::OnUploadScore(LeaderboardScoreUploaded_t *pScoreUploadedResult, bool bIOFailure)
{
	if (!g_pSteamUserStats)
		return;

	s3eSteamLeaderboardScoreUploaded data;
	data.success = pScoreUploadedResult->m_bSuccess != 0;
	data.changed = pScoreUploadedResult->m_bScoreChanged != 0;
	data.globalRankNew = pScoreUploadedResult->m_nGlobalRankNew;
	data.globalRankPrevious = pScoreUploadedResult->m_nGlobalRankPrevious;
	data.score = pScoreUploadedResult->m_nScore;
	strncpy(data.name, g_pSteamUserStats->GetLeaderboardName(pScoreUploadedResult->m_hSteamLeaderboard), sizeof(data.name));

	if (s3eEdkCallbacksIsRegistered(S3E_EXT_STEAM_HASH, s3eSteamCallback_LeaderboardUpdated))
	{
		s3eEdkCallbacksEnqueue(S3E_EXT_STEAM_HASH, s3eSteamCallback_LeaderboardUpdated, &data, sizeof(data));
	}
}

void CallbackHolder::OnLeaderboardDownloadedEntries(LeaderboardScoresDownloaded_t *pLeaderboardScoresDownloaded, bool bIOFailure)
{
	if (!g_pSteamUserStats)
		return;

	s3eSteamLeaderboardEntries data;
	data.count = pLeaderboardScoresDownloaded->m_cEntryCount;
	strncpy(data.name, g_pSteamUserStats->GetLeaderboardName(pLeaderboardScoresDownloaded->m_hSteamLeaderboard), sizeof(data.name));
	data.entries = new s3eSteamLeaderboardEntry[data.count];

	LeaderboardEntry_t leaderboardEntry;
	ISteamFriends * steamFriends = SteamFriends();
	for (int i = 0, i_end = pLeaderboardScoresDownloaded->m_cEntryCount; i < i_end; ++i)
	{
		g_pSteamUserStats->GetDownloadedLeaderboardEntry(pLeaderboardScoresDownloaded->m_hSteamLeaderboardEntries, i, &leaderboardEntry, NULL, 0);

		s3eSteamLeaderboardEntry & entry = data.entries[i];
		entry.score = leaderboardEntry.m_nScore;
		entry.details = leaderboardEntry.m_cDetails;
		entry.globalRank = leaderboardEntry.m_nGlobalRank;

		strncpy(entry.name, steamFriends->GetFriendPersonaName(leaderboardEntry.m_steamIDUser), sizeof(data.name));
	}

	if (s3eEdkCallbacksIsRegistered(S3E_EXT_STEAM_HASH, s3eSteamCallback_LeaderboardEntries))
	{
		s3eEdkCallbacksEnqueue(S3E_EXT_STEAM_HASH, s3eSteamCallback_LeaderboardEntries, &data, sizeof(data), NULL, S3E_FALSE, &CallbackHolder::OnLeaderboardDownloadedEntriesCompleted, data.entries);
	}
}

void CallbackHolder::OnLeaderboardDownloadedEntriesCompleted(uint32 extID, int32 notification, void* systemData, void* instance, int32 returnCode, void* completeData)
{
	if (completeData)
	{
		s3eSteamLeaderboardEntry * entries = reinterpret_cast<s3eSteamLeaderboardEntry*>(completeData);
		delete [] entries;
	}
}