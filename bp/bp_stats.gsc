// ----------------------------------------------------------------------------
// Mod: BP Mod
// Website: http://www.bptourneys.com
// 
// Module: Stats
// Author: JackTheRipper & Dan2k3k4
// Contents: 
// Description: 
// Notes: 
// ----------------------------------------------------------------------------

#include openwarfare\_eventmanager;
#include openwarfare\_utils;

init()
{
	/#
	[[level.bp_log]]("Initializing Stats Code");
	#/
	
	precacheMenu("bp_popup_stats");
	
	level thread addNewEvent( "onPlayerConnected", ::onPlayerConnected );
	
	switch( level.gametype )
	{
		case "sd":
		case "osd":
		case "sab":
			level thread bombPlants();
			level thread bombDefuses();
		break;
		
		case "ctf":
		case "rctf":
			level thread axisFlagCaptures();
			level thread axisFlagReturns();
			level thread axisFlagPickUps();
			level thread alliesFlagCaptures();
			level thread alliesFlagReturns();
			level thread alliesFlagPickUps();
			level thread flagDefended();
		break;
		
		case "ass":
			level thread assVIPKilled();
			level thread assVIPPlayer();
			level thread assVIPExtract();
		break;
		
		case "re":
			level thread rePicked();
			level thread reDropped();
			level thread reExtract();
		break;
		
		case "gg":
			level thread ggWins();
			level thread ggDemotes();
		break;
	}
}

onPlayerConnected()
{
	self thread initStats();
	self thread addNewEvent( "onPlayerSpawned", ::onPlayerSpawned );
	//self thread addNewEvent( "onPlayerKilled", ::onPlayerKilled );
}

initStats()
{
	if(!isDefined(self.pers["bp_stats_firstspawn"])) 
	{
		//all gametypes:
		self.pers["bp_stats_hits"] = 0;
		self.pers["bp_stats_accuracy"] = 0;
		self.pers["bp_stats_shotsFired"] = 0;
		self.pers["bp_stats_totalDamage"] = 0;
		self.pers["bp_stats_highestkillingStreak"] = 0; // 	attacker notify( "kill_streak", attacker.cur_kill_streak, streakGiven, sMeansOfDeath );
		self.pers["bp_stats_tks"] = 0;
		self.pers["bp_stats_tkd"] = 0;
		self.pers["bp_stats_longestShot"] = 0;
		self.pers["bp_stats_headshots"] = 0;
		self.pers["bp_stats_knives"] = 0;
		self.pers["bp_stats_distance"] = 0;
		self.pers["bp_stats_totalTimeAlive"] = 0;
		
		if(level.gametype == "sd" || level.gametype == "osd"  || level.gametype == "sab")
		{
			self.pers["bp_stats_BombsPlanted"] = 0;
			self.pers["bp_stats_BombsDefused"] = 0;
		}
		else if(level.gametype == "dom")
			self.pers["bp_stats_domFlagsCaptured"] = 0;
		else if(level.gametype == "ctf" || level.gametype == "rctf")
		{
			self.pers["bp_stats_ctfFlagsCaptured"] = 0;
			self.pers["bp_stats_ctfFlagsReturned"] = 0;
			self.pers["bp_stats_ctfFlagsPickedUp"] = 0;
			self.pers["bp_stats_ctfFlagsDefended"] = 0;
		}
		else if(level.gametype == "ass")
		{
			self.pers["bp_stats_assVipKilled"] = 0;
			self.pers["bp_stats_assVipPlayer"] = 0;
			self.pers["bp_stats_assVipExtract"] = 0;
		}
		else if(level.gametype == "re")
		{
			self.pers["bp_stats_rePicked"] = 0;
			self.pers["bp_stats_reDropped"] = 0;
			self.pers["bp_stats_reExtract"] = 0;
		}
		else if(level.gametype == "gg")
		{
			self.pers["bp_stats_ggWins"] = 0;
			self.pers["bp_stats_ggDemotes"] = 0;
		}
		
		self.pers["bp_stats_firstspawn"] = false;
	}
}

onPlayerSpawned()
{
	//self thread onDamageTaken();
	self thread setAccuracy();
	self thread distanceTraveled();
	
	/* for(;;)
	{
		self waittill("spawned_player");
		
		self.spawnTime = getTime();
	} */
}

onPlayerKilled()
{
	for(;;)
	{
		self waittill( "player_killed", eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration, fDistance );
		
		self.pers["bp_stats_totalTimeAlive"] = self.pers["bp_stats_totalTimeAlive"] + ((getTime() - self.spawnTime) / 1000);
		
		if ( isDefined(level.teamBased) && level.teamBased && self.pers["team"] == attacker.pers["team"]  && self != attacker ) // killed by a friendly
		{
			attacker.pers["bp_stats_tks"]++;
			self.pers["bp_stats_tkd"]++;
		}
		
		if ( !isDefined(level.teamBased) || !level.teamBased || (isDefined(level.teamBased) && level.teamBased && isDefined(attacker) && isDefined(self) && isDefined(attacker.pers["team"]) && self.pers["team"] != attacker.pers["team"] ))
		{
			switch ( sMeansOfDeath )
			{
				case "MOD_MELEE":
					if(isDefined(attacker.pers["bp_stats_knives"]))
						attacker.pers["bp_stats_knives"]++;
					break;
				case "MOD_HEAD_SHOT":
					if(isDefined(attacker.pers["bp_stats_headshots"]))
						attacker.pers["bp_stats_headshots"]++;
					break;
				default: break;
			}
		}
	}
}

onDamageTaken()
{
	self endon("disconnect");
	self endon("death");
	level endon( "game_ended" );
	
	for(;;)
	{
		self waittill("damage_taken", eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
		
		// Make sure there was damage done
		if ( iDamage == 0 )
			continue;
		
		if ( !isDefined(level.teamBased) || !level.teamBased || (isDefined(level.teamBased) && level.teamBased && isDefined(eAttacker) && isDefined(self) && isDefined(eAttacker.pers["team"]) && self.pers["team"] != eAttacker.pers["team"] ))
		{
			weapclass = weaponClass(sWeapon);
			if(weapclass == "smg" || weapclass == "mg" || weapclass == "pistol" || weapclass == "rifle" || weapclass == "spread") 
			{
				if(isDefined(eAttacker.pers["bp_stats_hits"]))
					eAttacker.pers["bp_stats_hits"]++;
				
				if(isDefined(eAttacker.pers["bp_stats_longestShot"]))
				{
					attackerdist = distance( self.origin, eAttacker.origin );
					if (attackerdist > eAttacker.pers["bp_stats_longestShot"])
						eAttacker.pers["bp_stats_longestShot"] = attackerdist;
				}
			}
		
			if(isDefined(eAttacker) && isDefined(eAttacker.pers["bp_stats_totalDamage"]))
				eAttacker.pers["bp_stats_totalDamage"] += iDamage;
				
			if ( sMeansOfDeath == "MOD_HEAD_SHOT" && isDefined(eAttacker.pers["bp_stats_headshots"]))
				eAttacker.pers["bp_stats_headshots"]++;
		}
	}
}

calculateTopStats()
{
	level.topDamageName = "none";
	level.topDamage = 0;
	level.topKillingStreakName = "none";
	level.topKillingStreak = 0;
	level.topLongestShotName = "none";
	level.topLongestShot = 0;
	level.topAccuracyName = "none";
	level.topAccuracy = 0;
	level.topTksName = "none";
	level.topTks = 0;
	level.topTkdName = "none";
	level.topTkd = 0;
	level.topHeadshotsName = "none";
	level.topHeadshots = 0;
	level.topKnivesName = "none";
	level.topKnives = 0;
	level.topBombsPlantedName = "none";
	level.topBombsPlanted = 0;
	level.topBombsDefusedName = "none";
	level.topBombsDefused = 0;
	level.topFlagsCapturedName = "none";
	level.topFlagsCaptured = 0;
	level.topFlagsReturnedName = "none";
	level.topFlagsReturned = 0;
	level.topFlagsPickedUpName = "none";
	level.topFlagsPickedUp = 0;
	level.topFlagsDefendedName = "none";
	level.topFlagsDefended = 0;
	level.topObjsCapturedName = "none";
	level.topObjsCaptured = 0;
	level.topObjsReturnedName = "none";
	level.topObjsReturned = 0;
	level.topObjsPickedUpName = "none";
	level.topObjsPickedUp = 0;
	level.topRadiosCapturedName = "none";
	level.topRadiosCaptured = 0;
	level.topTimeAliveName = "none";
	level.topTimeAlive = 0;
	level.topDistanceName = "none";
	level.topDistance = 0;
	level.topCampName = "none";
	level.topCamp = 9999;
	level.topSprayName = "none";
	level.topSpray = 0;
	level.topVipKilled = 0;
	level.topVipKilledName = "none";
	level.topVipPlayer = 0;
	level.topVipPlayerName = "none";
	level.topVipExtract = 0;
	level.topVipExtractName = "none";
	level.topRePicked = 0;
	level.topRePickedName = "none";
	level.topReDropped = 0;
	level.topReDroppedName = "none";
	level.topReExtract = 0;
	level.topReExtractName = "none";
	level.topGgWins = 0;
	level.topGgWinsName = "none";
	level.topGgDemotes = 0;
	level.topGgDemotesName = "none";
	
	players = level.players;
	for ( index = 0; index < players.size; index++ )
	{
		player = players[index];

		player.pers["bp_stats_longestShot"] = int(player.pers["bp_stats_longestShot"] * 0.0254);
		player.pers["bp_stats_distance"] = int(player.pers["bp_stats_distance"] * 0.0254);
		if(player.pers["bp_stats_distance"] < 1)
			player.pers["bp_stats_distance"] = 1; // Hack to stop errors if player doesnt move (afk)
		player.pers["bp_stats_totalTimeAlive"] = int(player.pers["bp_stats_totalTimeAlive"]);
		if(player.pers["bp_stats_totalTimeAlive"] < 1)
			player.pers["bp_stats_totalTimeAlive"] = 1; // Hack to stop errors if player doesnt spawn (spec)
		player.pers["bp_stats_campPoints"] = player.pers["bp_stats_distance"] / player.pers["bp_stats_totalTimeAlive"];
		
		if(isDefined(player.pers["bp_stats_totalDamage"]) && player.pers["bp_stats_totalDamage"] > level.topDamage) 
		{
			level.topDamage = player.pers["bp_stats_totalDamage"];
			level.topDamageName = player.name;
		}
		if(isDefined(player.pers["bp_stats_highestkillingStreak"]) && player.pers["bp_stats_highestkillingStreak"] > level.topKillingStreak) 
		{
			level.topKillingStreak = player.pers["bp_stats_highestkillingStreak"];
			level.topKillingStreakName = player.name;
		}
		if(isDefined(player.pers["bp_stats_longestShot"]) && player.pers["bp_stats_longestShot"] > level.topLongestShot) 
		{
			level.topLongestShot = player.pers["bp_stats_longestShot"];
			level.topLongestShotName = player.name;
		}
		if(isDefined(player.pers["bp_stats_accuracy"]) && player.pers["bp_stats_accuracy"] > level.topAccuracy) 
		{
			level.topAccuracy = player.pers["bp_stats_accuracy"];
			level.topAccuracyName = player.name;
		}
		if(isDefined(player.pers["bp_stats_shotsFired"]) && player.pers["bp_stats_shotsFired"] > level.topSpray) 
		{
			level.topSpray = player.pers["bp_stats_shotsFired"];
			level.topSprayName = player.name;
		}
		if(isDefined(player.pers["bp_stats_tks"]) && player.pers["bp_stats_tks"] > level.topTks) 
		{
			level.topTks = player.pers["bp_stats_tks"];
			level.topTksName = player.name;
		}
		if(isDefined(player.pers["bp_stats_tkd"]) && player.pers["bp_stats_tkd"] > level.topTkd) 
		{
			level.topTkd = player.pers["bp_stats_tkd"];
			level.topTkdName = player.name;
		}
		if(isDefined(player.pers["bp_stats_headshots"]) && player.pers["bp_stats_headshots"] > level.topHeadshots) 
		{
			level.topHeadshots = player.pers["bp_stats_headshots"];
			level.topHeadshotsName = player.name;
		}
		if(isDefined(player.pers["bp_stats_knives"]) && player.pers["bp_stats_knives"] > level.topKnives) 
		{
			level.topKnives = player.pers["bp_stats_knives"];
			level.topKnivesName = player.name;
		}
		if(isDefined(player.pers["bp_stats_distance"]) && player.pers["bp_stats_distance"] > level.topDistance) 
		{
			level.topDistance = player.pers["bp_stats_distance"];
			level.topDistanceName = player.name;
		}
		if(isDefined(player.pers["bp_stats_totalTimeAlive"]) && player.pers["bp_stats_totalTimeAlive"] > level.topTimeAlive) 
		{
			level.topTimeAlive = player.pers["bp_stats_totalTimeAlive"];
			level.topTimeAliveName = player.name;
		}
		if(isDefined(player.pers["bp_stats_campPoints"]) && player.pers["bp_stats_campPoints"] < level.topCamp) 
		{
			level.topCamp = player.pers["bp_stats_campPoints"];
			level.topCampName = player.name;
		}
		
		if(level.gametype == "sd" || level.gametype == "osd" || level.gametype == "sab")
		{
			if(isDefined(player.pers["bp_stats_BombsPlanted"]) && player.pers["bp_stats_BombsPlanted"] > level.topBombsPlanted) 
			{
				level.topBombsPlanted = player.pers["bp_stats_BombsPlanted"];
				level.topBombsPlantedName = player.name;
			}
			if(isDefined(player.pers["bp_stats_BombsDefused"]) && player.pers["bp_stats_BombsDefused"] > level.topBombsDefused) 
			{
				level.topBombsDefused = player.pers["bp_stats_BombsDefused"];
				level.topBombsDefusedName = player.name;
			}
		}
		else if(level.gametype == "dom")
		{
			if(isDefined(player.pers["bp_stats_domFlagsCaptured"]) && player.pers["bp_stats_domFlagsCaptured"] > level.topFlagsCaptured) 
			{
				level.topFlagsCaptured = player.pers["bp_stats_domFlagsCaptured"];
				level.topFlagsCapturedName = player.name;
			}
		}
		else if(level.gametype == "ctf" || level.gametype == "rctf")
		{
			if(isDefined(player.pers["bp_stats_ctfFlagsCaptured"]) && player.pers["bp_stats_ctfFlagsCaptured"] > level.topFlagsCaptured) 
			{
				level.topFlagsCaptured = player.pers["bp_stats_ctfFlagsCaptured"];
				level.topFlagsCapturedName = player.name;
			}
			if(isDefined(player.pers["bp_stats_ctfFlagsReturned"]) && player.pers["bp_stats_ctfFlagsReturned"] > level.topFlagsReturned) 
			{
				level.topFlagsReturned = player.pers["bp_stats_ctfFlagsReturned"];
				level.topFlagsReturnedName = player.name;
			}
			if(isDefined(player.pers["bp_stats_ctfFlagsPickedUp"]) && player.pers["bp_stats_ctfFlagsPickedUp"] > level.topFlagsPickedUp) 
			{
				level.topFlagsPickedUp = player.pers["bp_stats_ctfFlagsPickedUp"];
				level.topFlagsPickedUpName = player.name;
			}
			if(isDefined(player.pers["bp_stats_ctfFlagsDefended"]) && player.pers["bp_stats_ctfFlagsDefended"] > level.topFlagsDefended) 
			{
				level.topFlagsDefended = player.pers["bp_stats_ctfFlagsDefended"];
				level.topFlagsDefendedName = player.name;
			}
		}
		else if(level.gametype == "ass")
		{
			if(isDefined(player.pers["bp_stats_assVipKilled"]) && player.pers["bp_stats_assVipKilled"] > level.topVipKilled)
			{
				level.topVipKilled = player.pers["bp_stats_assVipKilled"];
				level.topVipKilledName = player.name;
			}
			if(isDefined(player.pers["bp_stats_assVipPlayer"]) && player.pers["bp_stats_assVipPlayer"] > level.topVipPlayer)
			{
				level.topVipPlayer = player.pers["bp_stats_assVipPlayer"];
				level.topVipPlayerName = player.name;
			}
			if(isDefined(player.pers["bp_stats_assVipExtract"]) && player.pers["bp_stats_assVipExtract"] > level.topVipExtract)
			{
				level.topVipExtract = player.pers["bp_stats_assVipExtract"];
				level.topVipExtractName = player.name;
			}
		}
		else if(level.gametype == "re")
		{
			if(isDefined(player.pers["bp_stats_rePicked"]) && player.pers["bp_stats_rePicked"] > level.topRePicked)
			{
				level.topRePicked = player.pers["bp_stats_rePicked"];
				level.topRePickedName = player.name;
			}
			if(isDefined(player.pers["bp_stats_reDropped"]) && player.pers["bp_stats_reDropped"] > level.topReDropped)
			{
				level.topReDropped = player.pers["bp_stats_reDropped"];
				level.topReDroppedName = player.name;
			}
			if(isDefined(player.pers["bp_stats_reExtract"]) && player.pers["bp_stats_reExtract"] > level.topReExtract)
			{
				level.topReExtract = player.pers["bp_stats_reExtract"];
				level.topReExtractName = player.name;
			}
		}
		else if(level.gametype == "gg")
		{
			if(isDefined(player.pers["bp_stats_ggWins"]) && player.pers["bp_stats_ggWins"] > level.topGgWins)
			{
				level.topGgWins = player.pers["bp_stats_ggWins"];
				level.topGgWinsName = player.name;
			}
			if(isDefined(player.pers["bp_stats_ggDemotes"]) && player.pers["bp_stats_ggDemotes"] > level.topGgDemotes)
			{
				level.topGgDemotes = player.pers["bp_stats_ggDemotes"];
				level.topGgDemotesName = player.name;
			}
		}
	}
	
	for(i = 0; i < level.players.size; i++)
	{
		player = level.players[i];
		
		player setClientDvar("ui_stats_mostdamageinflicted_name", level.topDamageName);
		player setClientDvar("ui_stats_mostdamageinflicted", level.topDamage);
		player setClientDvar("ui_stats_owndamageinflicted", player.pers["bp_stats_totalDamage"]);
		
		player setClientDvar("ui_stats_bestaccuracy_name", level.topAccuracyName);
		player setClientDvar("ui_stats_bestaccuracy", level.topAccuracy);
		player setClientDvar("ui_stats_ownaccuracy", player.pers["bp_stats_accuracy"]);
		
		player setClientDvar("ui_stats_mostheadshots_name", level.topHeadshotsName);
		player setClientDvar("ui_stats_mostheadshots", level.topHeadshots);
		player setClientDvar("ui_stats_ownheadshots", player.pers["bp_stats_headshots"]);
		
		player setClientDvar("ui_stats_mostknives_name", level.topKnivesName);
		player setClientDvar("ui_stats_mostknives", level.topKnives);
		player setClientDvar("ui_stats_ownknives", player.pers["bp_stats_knives"]);
		
		player setClientDvar("ui_stats_bestkillstreak_name", level.topKillingStreakName);
		player setClientDvar("ui_stats_bestkillstreak", level.topKillingStreak);
		player setClientDvar("ui_stats_ownkillstreak", player.pers["bp_stats_highestkillingStreak"]);
		
		player setClientDvar("ui_stats_longestshot_name", level.topLongestShotName);
		player setClientDvar("ui_stats_longestshot", level.topLongestShot);
		player setClientDvar("ui_stats_ownlongestshot", player.pers["bp_stats_longestShot"]);
		
		player setClientDvar("ui_stats_mostdistance_name", level.topDistanceName);
		player setClientDvar("ui_stats_mostdistance", level.topDistance);
		player setClientDvar("ui_stats_owndistance", player.pers["bp_stats_distance"]);
		
		player setClientDvar("ui_stats_mostteamkills_name", level.topTksName);
		player setClientDvar("ui_stats_mostteamkills", level.topTks);
		player setClientDvar("ui_stats_ownteamkills", player.pers["bp_stats_tks"]);
		
		player setClientDvar("ui_stats_mostteamkilld_name", level.topTkdName);
		player setClientDvar("ui_stats_mostteamkilld", level.topTkd);
		player setClientDvar("ui_stats_ownteamkilld", player.pers["bp_stats_tkd"]);
		
		player setClientDvar("ui_stats_longesttimealive_name", level.topTimeAliveName);
		player setClientDvar("ui_stats_longesttimealive", level.topTimeAlive);
		player setClientDvar("ui_stats_owntimealive", player.pers["bp_stats_totalTimeAlive"]);
		
		player setClientDvar("ui_stats_topsprayer_name", level.topSprayName);
		player setClientDvar("ui_stats_topsprayer", level.topSpray);
		player setClientDvar("ui_stats_ownsprayer", player.pers["bp_stats_shotsFired"]);
		
		player setClientDvar("ui_stats_topcamper_name", level.topCampName);
		player setClientDvar("ui_stats_topcamper", level.topCamp);
		player setClientDvar("ui_stats_owncamper", player.pers["bp_stats_campPoints"]);
		
		player setClientDvar("ui_stats_gametype", level.gametype);
		
		if(level.gametype == "sd" || level.gametype == "osd" || level.gametype == "sab")
		{
			player setClientDvar("ui_stats_mostbombsplanted_name", level.topBombsPlantedName);
			player setClientDvar("ui_stats_mostbombsplanted", level.topBombsPlanted);
			player setClientDvar("ui_stats_ownbombsplanted", player.pers["bp_stats_BombsPlanted"]);
			
			player setClientDvar("ui_stats_mostbombsdefused_name", level.topBombsDefusedName);
			player setClientDvar("ui_stats_mostbombsdefused", level.topBombsDefused);
			player setClientDvar("ui_stats_ownbombsdefused", player.pers["bp_stats_BombsDefused"]);
		}
		else if(level.gametype == "dom")
		{
			player setClientDvar("ui_stats_dom_mostflagscaptured_name", level.topFlagsCapturedName);
			player setClientDvar("ui_stats_dom_mostflagscaptured", level.topFlagsCaptured);
			player setClientDvar("ui_stats_dom_ownflagscaptured", player.pers["bp_stats_domFlagsCaptured"]);
		}
		else if(level.gametype == "ctf" || level.gametype == "rctf")
		{
			player setClientDvar("ui_stats_ctf_mostflagscaptured_name", level.topFlagsCapturedName);
			player setClientDvar("ui_stats_ctf_mostflagscaptured", level.topFlagsCaptured);
			player setClientDvar("ui_stats_ctf_ownflagscaptured", player.pers["bp_stats_ctfFlagsCaptured"]);
			
			player setClientDvar("ui_stats_ctf_mostflagsreturned_name", level.topFlagsReturnedName);
			player setClientDvar("ui_stats_ctf_mostflagsreturned", level.topFlagsReturned);
			player setClientDvar("ui_stats_ctf_ownflagsreturned", player.pers["bp_stats_ctfFlagsReturned"]);
			
			player setClientDvar("ui_stats_ctf_mostflagspickedup_name", level.topFlagsPickedUpName);
			player setClientDvar("ui_stats_ctf_mostflagspickedup", level.topFlagsPickedUp);
			player setClientDvar("ui_stats_ctf_ownflagspickedup", player.pers["bp_stats_ctfFlagsPickedUp"]);
			
			player setClientDvar("ui_stats_ctf_mostflagsdefended_name", level.topFlagsDefendedName);
			player setClientDvar("ui_stats_ctf_mostflagsdefended", level.topFlagsDefended);
			player setClientDvar("ui_stats_ctf_ownflagsdefended", player.pers["bp_stats_ctfFlagsDefended"]);
		}
		else if(level.gametype == "ass")
		{
			player setClientDvar("ui_stats_ass_mostkilled_name", level.topVipKilledName);
			player setClientDvar("ui_stats_ass_mostkilled", level.topVipKilled);
			player setClientDvar("ui_stats_ass_ownkilled", player.pers["bp_stats_assVipKilled"]);
			
			player setClientDvar("ui_stats_ass_mostpicked_name", level.topVipPlayerName);
			player setClientDvar("ui_stats_ass_mostpicked", level.topVipPlayer);
			player setClientDvar("ui_stats_ass_ownpicked", player.pers["bp_stats_assVipPlayer"]);
			
			player setClientDvar("ui_stats_ass_mostextract_name", level.topVipExtractName);
			player setClientDvar("ui_stats_ass_mostextract", level.topVipExtract);
			player setClientDvar("ui_stats_ass_ownextract", player.pers["bp_stats_assVipExtract"]);
		}
		else if(level.gametype == "re")
		{
			player setClientDvar("ui_stats_re_mostpicked_name", level.topRePickedName);
			player setClientDvar("ui_stats_re_mostpicked", level.topRePicked);
			player setClientDvar("ui_stats_re_ownpicked", player.pers["bp_stats_rePicked"]);
			
			player setClientDvar("ui_stats_re_mostdropped_name", level.topReDroppedName);
			player setClientDvar("ui_stats_re_mostdropped", level.topReDropped);
			player setClientDvar("ui_stats_re_owndropped", player.pers["bp_stats_reDropped"]);
			
			player setClientDvar("ui_stats_re_mostextract_name", level.topReExtractName);
			player setClientDvar("ui_stats_re_mostextract", level.topReExtract);
			player setClientDvar("ui_stats_re_ownextract", player.pers["bp_stats_reExtract"]);
		}
		else if(level.gametype == "gg")
		{
			player setClientDvar("ui_stats_gg_mostwins_name", level.topGgWinsName);
			player setClientDvar("ui_stats_gg_mostwins", level.topGgWins);
			player setClientDvar("ui_stats_gg_ownwins", player.pers["bp_stats_ggWins"]);
			
			player setClientDvar("ui_stats_gg_mostdemotes_name", level.topGgDemotesName);
			player setClientDvar("ui_stats_gg_mostdemotes", level.topGgDemotes);
			player setClientDvar("ui_stats_gg_owndemotes", player.pers["bp_stats_ggDemotes"]);
		}
	}
}

printAccuracy()
{
	self endon("disconnect");
	
	if(self.pers["bp_stats_shotsFired"] > 0 && self.pers["bp_stats_hits"] > 0)
	{
		if(self.pers["bp_stats_hits"] > self.pers["bp_stats_shotsFired"])
			self.pers["bp_stats_shotsFired"] = self.pers["bp_stats_hits"];
		
		hits = self.pers["bp_stats_hits"];
		shots = self.pers["bp_stats_shotsFired"];
		
		self.pers["bp_stats_accuracy"] = int(hits / shots * 100);
	}
	else
		self.pers["bp_stats_accuracy"] = 0;
	
	self iPrintLn(&"BP_STATS_YOUR_ACCURACY_IS", self.pers["bp_stats_accuracy"], self.pers["bp_stats_shotsFired"], self.pers["bp_stats_hits"]);
}

setAccuracy()
{
	self endon("disconnect");
	
	while(isAlive(self))
	{
		wait 1;
		
		if(self.pers["bp_stats_shotsFired"] > 0 && self.pers["bp_stats_hits"] > 0)
		{
			if(self.pers["bp_stats_hits"] > self.pers["bp_stats_shotsFired"])
				self.pers["bp_stats_shotsFired"] = self.pers["bp_stats_hits"];
		
			hits = self.pers["bp_stats_hits"];
			shots = self.pers["bp_stats_shotsFired"];
			
			self.pers["bp_stats_accuracy"] = int(hits / shots * 100);
		}
		else
			self.pers["bp_stats_accuracy"] = 0;
	}
}

distanceTraveled()
{
	self endon("disconnect");
	
	self.pers["bp_stats_oldspot"] = self.origin;

	while(isAlive(self))
	{
		wait 1;
		traveled = distance(self.pers["bp_stats_oldspot"], self.origin);
		self.pers["bp_stats_distance"] = self.pers["bp_stats_distance"] + traveled;
		self.pers["bp_stats_oldspot"] = self.origin;
	}
}

bombPlants()
{
	for(;;)
	{
		self waittill("bomb_planted", player);
		
		player.pers["bp_stats_BombsPlanted"]++;
	}
}

bombDefuses()
{
	for(;;)
	{
		self waittill("bomb_defused", player);
		
		player.pers["bp_stats_BombsDefused"]++;
	}
}

flagDefended()
{
	for(;;)
	{
		self waittill("ctf_flag_defended", attacker);
		
		if(isDefined(attacker) && isDefined(attacker.pers["bp_stats_ctfFlagsDefended"]))
			attacker.pers["bp_stats_ctfFlagsDefended"]++;
	}
}

assVIPKilled()
{
	for(;;)
	{
		self waittill("vipkilled", victim);
		
		if(isDefined(victim) && isDefined(victim.pers["bp_stats_assVipKilled"]))
			victim.pers["bp_stats_assVipKilled"]++;
	}
}

assVIPPlayer()
{
	for(;;)
	{
		self waittill("vippicked", player);
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_assVipPlayer"]))
			player.pers["bp_stats_assVipPlayer"]++;
	}
}

assVIPExtract()
{
	for(;;)
	{
		self waittill("vipextracted", player);
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_assVipExtract"]))
			player.pers["bp_stats_assVipExtract"]++;
	}
}

rePicked()
{
	for(;;)
	{
		self waittill( "objective_picked_up", item, player );
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_rePicked"]))
			player.pers["bp_stats_rePicked"]++;
	}
}

reDropped()
{
	for(;;)
	{
		self waittill( "objective_dropped", item, player );
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_reDropped"]))
			player.pers["bp_stats_reDropped"]++;
	}
}

reExtract()
{
	for(;;)
	{
		self waittill( "objective_extracted", player );
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_reExtract"]))
			player.pers["bp_stats_reExtract"]++;
	}
}

ggWins()
{
	for(;;)
	{
		self waittill( "gg_winner", player );
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_ggWins"]))
			player.pers["bp_stats_ggWins"]++;
	}
}

ggDemotes()
{
	for(;;)
	{
		self waittill( "gg_demoted", player );
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_ggDemotes"]))
			player.pers["bp_stats_ggDemotes"]++;
	}
}

axisFlagCaptures()
{
	for(;;)
	{
		self waittill( "allies_flag_captured", carryObject, player );
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_ctfFlagsCaptured"]))
			player.pers["bp_stats_ctfFlagsCaptured"]++;
	}
}

axisFlagReturns()
{
	for(;;)
	{
		self waittill( "axis_flag_returned", ss, player );
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_ctfFlagsReturned"]))
			player.pers["bp_stats_ctfFlagsReturned"]++;
	}
}

axisFlagPickUps()
{
	for(;;)
	{
		self waittill( "axis_flag_picked_up", ss, player );
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_ctfFlagsPickedUp"]))
			player.pers["bp_stats_ctfFlagsPickedUp"]++;
	}
}

alliesFlagCaptures()
{
	for(;;)
	{
		self waittill( "axis_flag_captured", carryObject, player );
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_ctfFlagsCaptured"]))
			player.pers["bp_stats_ctfFlagsCaptured"]++;
	}
}

alliesFlagReturns()
{
	for(;;)
	{
		self waittill( "allies_flag_returned", ss, player );
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_ctfFlagsReturned"]))
			player.pers["bp_stats_ctfFlagsReturned"]++;
	}
}

alliesFlagPickUps()
{
	for(;;)
	{
		self waittill( "allies_flag_picked_up", ss, player );
		
		if(isDefined(player) && isDefined(player.pers["bp_stats_ctfFlagsPickedUp"]))
			player.pers["bp_stats_ctfFlagsPickedUp"]++;
	}
}

spawnIntermission()
{
	if(!isDefined(self))
		return;
	
	self endon("disconnect");
	
	self notify("spawned");
	self notify("end_respawn");
	
	self.sessionstate = "playing";
	self.spectatorclient = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	
	onSpawnIntermission();
	self setDepthOfField( 0, 128, 512, 4000, 6, 1.8 );
}

onSpawnIntermission()
{
	spawnpointname = "";
	
	switch( level.gametype )
	{
		case "sd":
		case "osd":
			spawnpointname = "mp_sd_spawn_attacker";
		break;

		case "sab":
		case "ass":
			spawnpointname = "mp_sab_spawn_allies";
		break;
		
		case "ch":
		case "ctf":
		case "rctf":
			spawnpointname = ctfSpawnIntermission();
		break;
		
		case "dom":
			spawnpointname = "mp_dom_spawn";
		break;
		
		case "dm":
		case "gg":
			spawnpointname = "mp_dm_spawn";
		break;
		
		case "koth":
		case "ftag":
		case "strat":
		case "war":
			spawnpointname = "mp_tdm_spawn";
		break;
		
		default: spawnpointname = "mp_global_intermission";
	}
	
	spawnpoints = getentarray(spawnpointname, "classname");
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random(spawnpoints);

	if( isDefined( spawnpoint ) )
		self spawn( spawnpoint.origin, spawnpoint.angles );
	else
	{
		spawnPoints = getentarray("mp_global_intermission", "classname");
		spawnpoint = spawnPoints[0];
		
		if( isDefined( spawnpoint ) )
			self spawn( spawnpoint.origin, spawnpoint.angles );
	}
}

ctfSpawnIntermission()
{
	sabSpawnTest = getentarray("mp_sab_spawn_allies", "classname");
	ctfSpawnTest = getentarray("mp_ctf_spawn_allies", "classname");
	chSpawnTest = getentarray("mp_ch_spawn_allies", "classname");
	
	if( isDefined( sabSpawnTest ) )
		return "mp_sab_spawn_allies";
	else if( isDefined( ctfSpawnTest ) )
		return "mp_ctf_spawn_allies";
	else if( isDefined( chSpawnTest ) )
		return "mp_ch_spawn_allies";
	else return "mp_global_intermission";
}