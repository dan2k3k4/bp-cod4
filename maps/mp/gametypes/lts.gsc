//******************************************************************************
//  _____                  _    _             __
// |  _  |                | |  | |           / _|
// | | | |_ __   ___ _ __ | |  | | __ _ _ __| |_ __ _ _ __ ___
// | | | | '_ \ / _ \ '_ \| |/\| |/ _` | '__|  _/ _` | '__/ _ \
// \ \_/ / |_) |  __/ | | \  /\  / (_| | |  | || (_| | | |  __/
//  \___/| .__/ \___|_| |_|\/  \/ \__,_|_|  |_| \__,_|_|  \___|
//       | |               We don't make the game you play.
//       |_|                 We make the game you play BETTER.
//
//            Website: http://openwarfaremod.com/
//******************************************************************************

#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include openwarfare\_utils;

/*
	Last Team Standing
	Objective: 	Score points for your team by eliminating players on the opposing team
	Map ends:	When one team is eliminated, one team reaches the score limit, or time limit is reached
	Respawning:	No respawning

	Level requirements
	------------------
		Spawnpoints:
			classname		mp_tdm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of teammates and enemies
			at the time of spawn. Players generally spawn behind their teammates relative to the direction of enemies.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

	Level script requirements
	-------------------------
		Team Definitions:
			game["allies"] = "marines";
			game["axis"] = "opfor";
			This sets the nationalities of the teams. Allies can be american, british, or russian. Axis can be german.

		If using minefields or exploders:
			maps\mp\_load::main();

	Optional level script settings
	------------------------------
		Soldier Type and Variation:
			game["american_soldiertype"] = "normandy";
			game["german_soldiertype"] = "normandy";
			This sets what character models are used for each nationality on a particular map.

			Valid settings:
				american_soldiertype	normandy
				british_soldiertype		normandy, africa
				russian_soldiertype		coats, padded
				german_soldiertype		normandy, africa, winterlight, winterdark
*/

/*QUAKED mp_tdm_spawn (0.0 0.0 1.0) (-16 -16 0) (16 16 72)
Players spawn away from enemies and near their team at one of these positions.*/

/*QUAKED mp_tdm_spawn_axis_start (0.5 0.0 1.0) (-16 -16 0) (16 16 72)
Axis players spawn away from enemies and near their team at one of these positions at the start of a round.*/

/*QUAKED mp_tdm_spawn_allies_start (0.0 0.5 1.0) (-16 -16 0) (16 16 72)
Allied players spawn away from enemies and near their team at one of these positions at the start of a round.*/

main()
{
	if(getdvar("mapname") == "mp_background")
		return;
		
	if ( !isdefined( game["switchedsides"] ) )
		game["switchedsides"] = false;
	
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 1, 1, 10 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 5, 0, 500 );
	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 2, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 3, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 0, 0, 1440 );

	level.scr_lts_method = getdvarx( "scr_lts_method", "int", 1, 0, 1 );
	level.killed["allies"] = 0;
	level.killed["axis"] = 0;

	level.teamBased = true;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onRoundSwitch = ::onRoundSwitch;
	level.onTimeLimit = ::onTimeLimit;

	game["dialog"]["gametype"] = gameTypeDialog( "lastteam" );
}


onStartGameType()
{
	setClientNameMode("auto_change");

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OW_OBJECTIVES_LTS" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OW_OBJECTIVES_LTS" );
	
	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_OBJECTIVES_LTS" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_OBJECTIVES_LTS" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OW_OBJECTIVES_LTS_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OW_OBJECTIVES_LTS_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OW_OBJECTIVES_LTS_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OW_OBJECTIVES_LTS_HINT" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_allies_start" );
	maps\mp\gametypes\_spawnlogic::placeSpawnPoints( "mp_tdm_spawn_axis_start" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );

	//level.spawn_axis_start = getentarray( "mp_tdm_spawn_axis_start", "classname" );
	//level.spawn_allies_start = getentarray( "mp_tdm_spawn_allies_start", "classname" );
	//logPrint( "MI;" + level.script + ";spawn_allies_start;" + level.spawn_allies_start.size + ";spawn_axis_start;" + level.spawn_axis_start.size + "\n" );
	
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	allowed[0] = "war";
	
	if ( getDvarInt( "scr_oldHardpoints" ) > 0 )
		allowed[1] = "hardpoint";
	
	maps\mp\gametypes\_gameobjects::main(allowed);
	
	// elimination style
	level.overrideTeamScore = true;
	level.displayRoundEndText = true;
	level.onDeadEvent = ::onDeadEvent;
	
	if(level.scr_lts_method)
	{
		level.onPlayerKilled = ::onPlayerKilled;
		level.onPlayerDisconnect = ::onPlayerDisconnect;
		level.killed["axis"] = 0;
		level.killed["allies"] = 0;
		createHudElements();
	}
}

onSpawnPlayer()
{
	// Check which spawn points should be used
	if ( game["switchedsides"] ) {
		spawnTeam = level.otherTeam[ self.pers["team"] ];
	} else {
		spawnTeam =  self.pers["team"];
	}
	
	self.usingObj = undefined;

	if ( level.inGracePeriod )
	{
		spawnPoints = getentarray("mp_tdm_spawn_" + spawnTeam + "_start", "classname");
		
		if ( !spawnPoints.size )
			spawnPoints = getentarray("mp_sab_spawn_" + spawnTeam + "_start", "classname");
			
		if ( !spawnPoints.size )
		{
			spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnTeam );
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
		}
		else
		{
			spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_Random( spawnPoints );
		}
	}
	else
	{
		spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( spawnTeam );
		spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( spawnPoints );
	}
	
	self spawn( spawnPoint.origin, spawnPoint.angles );
}

onDeadEvent( team )
{
	// Make sure players on both teams were not eliminated
	if ( team != "all" ) {
		[[level._setTeamScore]]( getOtherTeam(team), [[level._getTeamScore]]( getOtherTeam(team) ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( getOtherTeam(team), game["strings"][team + "_eliminated"] );
	} else {
		// We can't determine a winner if everyone died like in S&D so we declare a tie
		thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
	}
	
	if(level.scr_lts_method)
		destroyHudElements();
}

onTimeLimit()
{
	if(!level.scr_lts_method)
		playersAliveWin();
	else
	{
		if( level.killed["allies"] > level.killed["axis"] )
		{
			// Allies win
			[[level._setTeamScore]]( "allies", [[level._getTeamScore]]( "allies" ) + 1 );
			thread maps\mp\gametypes\_globallogic::endGame( "allies", game["strings"]["time_limit_reached"] );
		}
		else if( level.killed["axis"] > level.killed["allies"] )
		{
			// Axis win
			[[level._setTeamScore]]( "axis", [[level._getTeamScore]]( "axis" ) + 1 );
			thread maps\mp\gametypes\_globallogic::endGame( "axis", game["strings"]["time_limit_reached"] );
		}
		else if( level.killed["axis"] == level.killed["allies"] )
		{
			// Axis and Allies have same number of kills this round
			thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
		}
		
		destroyHudElements();
	}
}

playersAliveWin()
{
	level.exist["allies"] = 0;
	level.exist["axis"] = 0;

	players = level.players;
	for(i = 0; i < players.size; i++)
	{
		player = players[i];

		if(isDefined(player.pers["team"]) && player.pers["team"] != "spectator" && player.sessionstate == "playing")
			level.exist[player.pers["team"]]++;
	}

	if(level.exist["allies"] > level.exist["axis"])
	{
		// Allies have more players alive at end of the round
		[[level._setTeamScore]]( "allies", [[level._getTeamScore]]( "allies" ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( "allies", game["strings"]["time_limit_reached"] );
	}
	else if(level.exist["allies"] < level.exist["axis"])
	{
		// Axis have more players alive at end of the round
		[[level._setTeamScore]]( "axis", [[level._getTeamScore]]( "axis" ) + 1 );
		thread maps\mp\gametypes\_globallogic::endGame( "axis", game["strings"]["time_limit_reached"] );
	}
	else if(level.exist["allies"] == level.exist["axis"])
	{
		// Axis and Allies have same number of players alive
		thread maps\mp\gametypes\_globallogic::endGame( "tie", game["strings"]["round_draw"] );
	}
}

onPlayerKilled(eInflictor, attacker, iDamage, sMeansOfDeath, sWeapon, vDir, sHitLoc, psOffsetTime, deathAnimDuration)
{
	if ( isDefined(attacker) && isDefined(attacker.pers["team"]) )
	{
		if ( self.pers["team"] != attacker.pers["team"] && attacker.pers["team"] == "axis" )
		{
			level.killed["axis"]++;
			
			if ( level.killed["axis"] > level.killed["allies"] ) {
				game["killStatusAxis"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAxisForAllies"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
			} else if ( level.killed["allies"] == level.killed["axis"] ) {
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
			} else {
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAllies"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAlliesForAxis"].color = ( 0.07, 0.69, 0.26 );
			}
			
			game["killStatusAxis"] setValue( level.killed["axis"] );
			game["killStatusAxisForAllies"] setValue( level.killed["axis"] );
			game["killStatusAxis"] thread maps\mp\gametypes\_hud::fontPulse( level );
			game["killStatusAxisForAllies"] thread maps\mp\gametypes\_hud::fontPulse( level );
		}
		else if ( self.pers["team"] != attacker.pers["team"] && attacker.pers["team"] == "allies" )
		{
			level.killed["allies"]++;
			
			if ( level.killed["allies"] > level.killed["axis"] ) {
				game["killStatusAllies"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAlliesForAxis"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
			} else if ( level.killed["allies"] == level.killed["axis"] ) {
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
			} else {
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxis"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAxisForAllies"].color = ( 0.07, 0.69, 0.26 );
			}
			
			game["killStatusAllies"] setValue( level.killed["allies"] );
			game["killStatusAlliesForAxis"] setValue( level.killed["allies"] );
			game["killStatusAllies"] thread maps\mp\gametypes\_hud::fontPulse( level );
			game["killStatusAlliesForAxis"] thread maps\mp\gametypes\_hud::fontPulse( level );
		}
		else if ( self.pers["team"] == attacker.pers["team"] && attacker.pers["team"] == "axis" )
		{
			level.killed["axis"]--;
			
			if ( level.killed["axis"] > level.killed["allies"] ) {
				game["killStatusAxis"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAxisForAllies"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
			} else if ( level.killed["allies"] == level.killed["axis"] ) {
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
			} else {
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAllies"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAlliesForAxis"].color = ( 0.07, 0.69, 0.26 );
			}
			
			game["killStatusAxis"] setValue( level.killed["axis"] );
			game["killStatusAxisForAllies"] setValue( level.killed["axis"] );
			game["killStatusAxis"] thread maps\mp\gametypes\_hud::fontPulse( level );
			game["killStatusAxisForAllies"] thread maps\mp\gametypes\_hud::fontPulse( level );
		}
		else if ( self.pers["team"] == attacker.pers["team"] && attacker.pers["team"] == "allies" )
		{
			level.killed["allies"]--;
			
			if ( level.killed["allies"] > level.killed["axis"] ) {
				game["killStatusAllies"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAlliesForAxis"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
			} else if ( level.killed["allies"] == level.killed["axis"] ) {
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
			} else {
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxis"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAxisForAllies"].color = ( 0.07, 0.69, 0.26 );
			}
			
			game["killStatusAllies"] setValue( level.killed["allies"] );
			game["killStatusAlliesForAxis"] setValue( level.killed["allies"] );
			game["killStatusAllies"] thread maps\mp\gametypes\_hud::fontPulse( level );
			game["killStatusAlliesForAxis"] thread maps\mp\gametypes\_hud::fontPulse( level );
		}
	}
}

onPlayerDisconnect()
{
	if ( isDefined(self) && isPlayer(self) && isAlive(self) && isDefined(self.pers["team"]) )
	{
		if ( self.pers["team"] == "axis" )
		{
			level.killed["axis"]--;
			
			if ( level.killed["axis"] > level.killed["allies"] ) {
				game["killStatusAxis"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAxisForAllies"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
			} else if ( level.killed["allies"] == level.killed["axis"] ) {
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
			} else {
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAllies"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAlliesForAxis"].color = ( 0.07, 0.69, 0.26 );
			}
			
			game["killStatusAxis"] setValue( level.killed["axis"] );
			game["killStatusAxisForAllies"] setValue( level.killed["axis"] );
			game["killStatusAxis"] thread maps\mp\gametypes\_hud::fontPulse( level );
			game["killStatusAxisForAllies"] thread maps\mp\gametypes\_hud::fontPulse( level );
		}
		else if ( self.pers["team"] == "allies" )
		{
			level.killed["allies"]--;
			
			if ( level.killed["allies"] > level.killed["axis"] ) {
				game["killStatusAllies"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAlliesForAxis"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
			} else if ( level.killed["allies"] == level.killed["axis"] ) {
				game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
			} else {
				game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
				game["killStatusAxis"].color = ( 0.07, 0.69, 0.26 );
				game["killStatusAxisForAllies"].color = ( 0.07, 0.69, 0.26 );
			}
			
			game["killStatusAllies"] setValue( level.killed["allies"] );
			game["killStatusAlliesForAxis"] setValue( level.killed["allies"] );
			game["killStatusAllies"] thread maps\mp\gametypes\_hud::fontPulse( level );
			game["killStatusAlliesForAxis"] thread maps\mp\gametypes\_hud::fontPulse( level );
		}
	}
}


onRoundSwitch()
{
	// Just change the value for the variable controlling which map assets will be assigned to each team
	level.halftimeType = "halftime";
	game["switchedsides"] = !game["switchedsides"];
}

destroyHudElements()
{
	// Destroy all the HUD elements
	game["killStatusAllies"] destroy();
	game["killStatusAxis"] destroy();
	game["killStatusAlliesForAxis"] destroy();
	game["killStatusAxisForAllies"] destroy();

	return;
}

createHudElements()
{
	game["killStatusAllies"] = createServerFontString( "objective", 1.5, "allies" );
	game["killStatusAllies"].archived = true;
	game["killStatusAllies"].hideWhenInMenu = true;
	game["killStatusAllies"].alignX = "left";
	game["killStatusAllies"].alignY = "top";
	game["killStatusAllies"].sort = -1;
	game["killStatusAllies"] setValue( level.killed["allies"] );
	game["killStatusAllies"].color = ( 0.694, 0.220, 0.114 );
	game["killStatusAllies"] maps\mp\gametypes\_hud::fontPulseInit();

	game["killStatusAllies"].horzAlign = "left";
	game["killStatusAllies"].vertAlign = "top";
	game["killStatusAllies"].x = 150;
	game["killStatusAllies"].y = 37;

	game["killStatusAxis"] = createServerFontString( "objective", 1.5, "axis" );
	game["killStatusAxis"].archived = true;
	game["killStatusAxis"].hideWhenInMenu = true;
	game["killStatusAxis"].alignX = "left";
	game["killStatusAxis"].alignY = "top";
	game["killStatusAxis"].sort = -1;
	game["killStatusAxis"] setValue( level.killed["axis"] );
	game["killStatusAxis"].color = ( 0.694, 0.220, 0.114 );
	game["killStatusAxis"] maps\mp\gametypes\_hud::fontPulseInit();

	game["killStatusAxis"].horzAlign = "left";
	game["killStatusAxis"].vertAlign = "top";
	game["killStatusAxis"].x = 150;
	game["killStatusAxis"].y = 37;

	game["killStatusAlliesForAxis"] = createServerFontString( "objective", 1.5, "axis" );
	game["killStatusAlliesForAxis"].archived = true;
	game["killStatusAlliesForAxis"].hideWhenInMenu = true;
	game["killStatusAlliesForAxis"].alignX = "left";
	game["killStatusAlliesForAxis"].alignY = "top";
	game["killStatusAlliesForAxis"].sort = -1;
	game["killStatusAlliesForAxis"] setValue( level.killed["allies"] );
	game["killStatusAlliesForAxis"].color = ( 0.694, 0.220, 0.114 );
	game["killStatusAlliesForAxis"] maps\mp\gametypes\_hud::fontPulseInit();

	game["killStatusAlliesForAxis"].horzAlign = "left";
	game["killStatusAlliesForAxis"].vertAlign = "top";
	game["killStatusAlliesForAxis"].x = 150;
	game["killStatusAlliesForAxis"].y = 73;

	game["killStatusAxisForAllies"] = createServerFontString( "objective", 1.5, "allies" );
	game["killStatusAxisForAllies"].archived = true;
	game["killStatusAxisForAllies"].hideWhenInMenu = true;
	game["killStatusAxisForAllies"].alignX = "left";
	game["killStatusAxisForAllies"].alignY = "top";
	game["killStatusAxisForAllies"].sort = -1;
	game["killStatusAxisForAllies"] setValue( level.killed["axis"] );
	game["killStatusAxisForAllies"].color = ( 0.694, 0.220, 0.114 );
	game["killStatusAxisForAllies"] maps\mp\gametypes\_hud::fontPulseInit();

	game["killStatusAxisForAllies"].horzAlign = "left";
	game["killStatusAxisForAllies"].vertAlign = "top";
	game["killStatusAxisForAllies"].x = 150;
	game["killStatusAxisForAllies"].y = 73;

}
