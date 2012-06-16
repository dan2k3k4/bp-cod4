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
	Deathmatch
	Objective: 	Score points by eliminating other players
	Map ends:	When one player reaches the score limit, or time limit is reached
	Respawning:	No wait / Away from other players

	Level requirements
	------------------
		Spawnpoints:
			classname		mp_dm_spawn
			All players spawn from these. The spawnpoint chosen is dependent on the current locations of enemies at the time of spawn.
			Players generally spawn away from enemies.

		Spectator Spawnpoints:
			classname		mp_global_intermission
			Spectators spawn from these and intermission is viewed from these positions.
			Atleast one is required, any more and they are randomly chosen between.

	Level script requirements
	-------------------------
		Team Definitions:
			game["allies"] = "marines";
			game["axis"] = "opfor";
			Because Deathmatch doesn't have teams with regard to gameplay or scoring, this effectively sets the available weapons.

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

/*QUAKED mp_dm_spawn (1.0 0.5 0.0) (-16 -16 0) (16 16 72)
Players spawn away from enemies at one of these positions.*/

main()
{
	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();
	
	thread onPlayerConnect();	// OnPlayerConnect
	
	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 10 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 1, 0, 500 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 0, 0, 5000 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 30, 0, 1440 );


	level.teamBased = false;

	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;

	game["dialog"]["gametype"] = "tactical";
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player.cj = [];
		player.cj["save"] = [];
		player.cj["hud"] = [];
		player.cj["status"] = 0;
		player.cj["language"] = 0;
		player thread setupLanguage();
		
		player thread onPlayerSpawned();
	}
}

setupLanguage()
{
	self.cj["local"]["NOPOS"] = "^8No Position ^9Saved";
	self.cj["local"]["NOPOS2"] = "^8No Position 2 ^9Saved";
	self.cj["local"]["POSLOAD"] = "^8Position ^9Loaded";
	self.cj["local"]["POS2LOAD"] = "^8Position 2 ^9Loaded";
	self.cj["local"]["SAVED"] = "^8Position ^9Saved";
	self.cj["local"]["SAVED2"] = "^8Position 2 ^9Saved";
	
	self.cj["local"]["NOPOS3"] = "^8No Position 3 ^9Saved";
	self.cj["local"]["POS3LOAD"] = "^8Position 3 ^9Loaded";
	self.cj["local"]["SAVED3"] = "^8Position 3 ^9Saved";
}

onPlayerSpawned()
{
	for(;;)
	{
		self waittill("spawned_player");
		
		self thread _MeleeKey();						// Melee Key Watch
		self thread _UseKey();							// Use Key Watch
		self thread checkGrenades();					// Grenade Watch
	
		self thread removeAmmo();						// Remove ammo & loadout
		self thread removePerks();						// Remove Perks
		self thread checkSuicide();						// Check for Suicide
	}
}

_MeleeKey()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");

	for(;;)
	{
		if(self meleeButtonPressed())
		{
			catch_next = false;
			count = 0;

			for(i=0; i<0.5; i+=0.05)
			{
				if(catch_next && self meleeButtonPressed() && self isOnground())
				{
					self thread savePos();
					wait 1;
					break;
				}
				else if(catch_next && self attackButtonPressed() && self isOnGround())
				{
					while(self attackButtonPressed() && count < 1)
					{
						count+=0.1;
						wait 0.1;
					}
					if(count >= 1 && self isOnGround())
						self thread savePos3();
					else if(count < 1 && self isOnGround())
						self thread savePos2();
						
					wait 1;
					break;
				}
				else if(!(self meleeButtonPressed()) && !(self attackButtonPressed()))
					catch_next = true;

				wait 0.05;
			}
		}
		wait 0.05;
	}

}

_UseKey()
{
	self endon("disconnect");
	self endon("killed_player");
	self endon("joined_spectators");

	for(;;)
	{
		if(self useButtonPressed())
		{
			catch_next = false;
			count = 0;
			
			for(i=0; i<=0.5; i+=0.05)
			{
				if(catch_next && self useButtonPressed() && !(self isMantling()))
				{
					self thread loadPos();
					wait 1;
					break;
				}
				else if(catch_next && self attackButtonPressed() && !(self isMantling()))
				{
					while(self attackButtonPressed() && count < 1)
					{
						count+= 0.1;
						wait 0.1;
					}
					if(count < 1 && self isOnGround() && !(self isMantling()))
						self thread loadPos2();
					else if(count >= 1 && self isOnGround() && !(self isMantling()))
						self thread loadPos3();
					
					wait 1;
					break;
				}
				else if(!(self useButtonPressed()))
					catch_next = true;
				
				wait 0.05;
			}
		}
		wait 0.05;
	}
}

// Load, Save & Suicide //
loadPos()
{
	
	if(!isDefined(self.cj["save"]["org1"]))
		self iprintlnbold(self.cj["local"]["NOPOS"]);
	else
	{
		if(!self isOnGround())
		{
			self setPlayerAngles(self.cj["save"]["ang1"]);
			self setOrigin(self.cj["save"]["org1"]);
			self freezecontrols(true);
			wait 0.5;
		}
		else
		{
			self setPlayerAngles(self.cj["save"]["ang1"]);
			self setOrigin(self.cj["save"]["org1"]);
			self freezecontrols(true);
			wait 0.05;
		}
		
		self iprintln(self.cj["local"]["POSLOAD"]);
		self freezecontrols(false);
	}
}

loadPos2()
{
	if(!isDefined(self.cj["save"]["org2"]))
		self iprintlnbold(self.cj["local"]["NOPOS2"]);
	else
	{
		if(!self isOnGround())
		{
			self setPlayerAngles(self.cj["save"]["ang2"]);
			self setOrigin(self.cj["save"]["org2"]);
			self freezecontrols(true);
			wait 0.5;
		}
		else
		{
			self setPlayerAngles(self.cj["save"]["ang2"]);
			self setOrigin(self.cj["save"]["org2"]);
			self freezecontrols(true);
			wait 0.05;
		}
		
		self iprintln(self.cj["local"]["POS2LOAD"]);
		self freezecontrols(false);
	}
}

loadPos3()
{
	if(!isDefined(self.cj["save"]["org3"]))
		self iprintlnbold(self.cj["local"]["NOPOS3"]);
	else
	{
		if(!self isOnGround())
		{
			self setPlayerAngles(self.cj["save"]["ang3"]);
			self setOrigin(self.cj["save"]["org3"]);
			self freezecontrols(true);
			wait 0.5;
		}
		else
		{
			self setPlayerAngles(self.cj["save"]["ang3"]);
			self setOrigin(self.cj["save"]["org3"]);
			self freezecontrols(true);
			wait 0.05;
		}
		
		self iprintln(self.cj["local"]["POS3LOAD"]);
		self freezecontrols(false);
	}
}

savePos()
{
	wait 0.05;
	self.cj["save"]["org1"] = self.origin;
	self.cj["save"]["ang1"] = self.angles;
	self iprintln(self.cj["local"]["SAVED"]);
}

savePos2()
{
	wait 0.05;
	self.cj["save"]["org2"] = self.origin;
	self.cj["save"]["ang2"] = self.angles;
	self iprintln(self.cj["local"]["SAVED2"]);
}

savePos3()
{
	wait 0.05;
	self.cj["save"]["org3"] = self.origin;
	self.cj["save"]["ang3"] = self.angles;
	self iprintln(self.cj["local"]["SAVED3"]);
}

checkSuicide()
{
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("killed_player");
	
	while(1)
	{
		i = 0;
		while(self meleeButtonPressed() && i < 3)
		{
			wait 0.05;
			i+=0.05;
		}
		
		if(i > 2)
			self suicide();

		wait 0.1;
	}
}

// Loadout //
checkGrenades()
{
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("killed_player");
	
	self SetWeaponAmmoClip( "frag_grenade_mp", 1 );
	while(1)
	{
		if(self getAmmoCount("frag_grenade_mp") < 1)
			self SetWeaponAmmoClip( "frag_grenade_mp", 1 );
		
		wait 1;
	}
}

removeAmmo()
{
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("killed_player");
	
	self takeAllWeapons();
	
	self giveWeapon("rpg_mp");
	
	wait 0.05;
	
	self.cj["weapon"] = "deserteaglegold_mp";
	
	self giveWeapon(self.cj["weapon"]);
	
	wait 0.05;
	
	self switchToWeapon(self.cj["weapon"]);
	
	self giveMaxAmmo("deserteaglegold_mp");
	
	self SetActionSlot( 3, "weapon", "rpg_mp" );
	
	wait 0.05;
	
	
	while(1)
	{
		if(self getAmmoCount("rpg_mp") < 1)
			self giveMaxAmmo("rpg_mp");
		
		if(self getWeaponAmmoClip("rpg_mp") < 1)
			self SetWeaponAmmoClip("rpg_mp", 1);
		wait 3;
	}
}

removePerks()
{
	self endon("disconnect");
	self endon("joined_spectators");
	self endon("killed_player");

	self clearPerks();
	self setPerk("specialty_longersprint");
	self setPerk("specialty_armorvest");
	self setPerk("specialty_fastreload");
	
	self setPerk("specialty_holdbreath");
	self setPerk("specialty_quieter");
}


onStartGameType()
{
	setClientNameMode("auto_change");

	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"OBJECTIVES_DM" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"OBJECTIVES_DM" );

	if ( level.splitscreen )
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_DM" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_DM" );
	}
	else
	{
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"OBJECTIVES_DM_SCORE" );
		maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"OBJECTIVES_DM_SCORE" );
	}
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"OBJECTIVES_DM_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"OBJECTIVES_DM_HINT" );

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_dm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_dm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );
	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );
	
	allowed[0] = "dm";
	maps\mp\gametypes\_gameobjects::main(allowed);

	level.displayRoundEndText = false;
	level.QuickMessageToAll = true;

	// elimination style
	if ( level.roundLimit != 1 && level.numLives )
	{
		level.overridePlayerScore = true;
		level.displayRoundEndText = true;
		level.onEndGame = ::onEndGame;
	}
}


onSpawnPlayer()
{
	spawnPoints = maps\mp\gametypes\_spawnlogic::getTeamSpawnPoints( self.pers["team"] );
	spawnPoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_DM( spawnPoints );

	self spawn( spawnPoint.origin, spawnPoint.angles );
}


onEndGame( winningPlayer )
{
	if ( isDefined( winningPlayer ) )
		[[level._setPlayerScore]]( winningPlayer, winningPlayer [[level._getPlayerScore]]() + 1 );
}
