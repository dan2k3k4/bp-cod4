#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

/*
Strategy Gametype by Lepko, Editted by DaN for BP Mod.
Add: Tracer changes, so can see where shots go - set by dvar
Try to implement RPG/GL linkTo() but don't seem to be entities being fired - don't think it's possible?
Try to implement a hovering target that appears at the minDmgRange of the weapon you have, where you can aim through a wall and see if the target gets affected by the shot (therefore finding where you can wallbang, instead of having to use someone else) - not sure if you can read min Range values for each weapon file etc.
Implement bots per side, e.g. scr_bot_allies 20 - shouldn't be too hard
Use bots as models not as fake players, like Before Dawn mod, kill3r can help if I bug him
Add something that counts current entities placed in the map, and deletes oldest one as new ones are placed (so someone can't crash the server by placing lots of C4, or if lots of players all place lots of C4 it won't crash server)
Hit Location - (I forget if this shows up in the damage feedback) but would be nice to know where you shot someone, e.g. head/upper torso/left foot etc.)
Implement gametype dvars like: scr_show_sab_spawns - spawns player models at all sab spawns, axis players at axis spawns, allies at allies
Double tap Bash to set target - spawns a player model, then you would try to do damage to it from nades/shots etc. - would show as "damaged: target1" or something, then tap bash and use to remove target (codjumper has this feature for saving so shouldn't be hard to tweak)
Set modes to: all gametypes, or one (and pick the gametype) e.g. scr_strat_mode: 0 = all, 1 = sd, 2 = sab, 3 = dom, 4 = ctf, 5 = re

getentarray("rocket", "classname");

*/

main()
{
	if(getdvar("mapname") == "mp_background")
		return;

	maps\mp\gametypes\_globallogic::init();
	maps\mp\gametypes\_callbacksetup::SetupCallbacks();
	maps\mp\gametypes\_globallogic::SetupCallbacks();

	maps\mp\gametypes\_globallogic::registerRoundSwitchDvar( level.gameType, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerTimeLimitDvar( level.gameType, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerScoreLimitDvar( level.gameType, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerRoundLimitDvar( level.gameType, 0, 0, 0 );
	maps\mp\gametypes\_globallogic::registerNumLivesDvar( level.gameType, 0, 0, 0 );

	level.teamBased = true;
	level.overrideTeamScore = false;
	level.onPrecacheGameType = ::onPrecacheGameType;
	level.onStartGameType = ::onStartGameType;
	level.onSpawnPlayer = ::onSpawnPlayer;
	level.onPlayerKilled = maps\mp\gametypes\_globallogic::blank;
	level.onDeadEvent = maps\mp\gametypes\_globallogic::blank;
	level.onOneLeftEvent = maps\mp\gametypes\_globallogic::blank;
	level.onTimeLimit = maps\mp\gametypes\_globallogic::blank;
	level.onForfeit = maps\mp\gametypes\_globallogic::blank;

	level.callbackPlayerDamage = ::callbackPlayerDamage;

	level.endGameOnScoreLimit = false;

	game["dialog"]["gametype"] = "tactical";
	game["dialog"]["offense_obj"] = "obj_destroy";
	game["dialog"]["defense_obj"] = "obj_defend";
}

onPrecacheGameType()
{
	precacheString( &"BP_STRAT_DAMAGED_X_Y" );
	precacheString( &"BP_STRAT_DAMAGE_FROM_X_Y" );
	precacheString( &"BP_STRAT_END" );
	precacheString( &"BP_STRAT_GAMETYPE" );
}

onStartGameType()
{
	setClientNameMode( "auto_change" );
	
	maps\mp\gametypes\_globallogic::setObjectiveText( "allies", &"BP_STRAT_GAMETYPE_OBJ" );
	maps\mp\gametypes\_globallogic::setObjectiveText( "axis", &"BP_STRAT_GAMETYPE_OBJ" );
	
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "allies", &"BP_STRAT_GAMETYPE_SCORE" );
	maps\mp\gametypes\_globallogic::setObjectiveScoreText( "axis", &"BP_STRAT_GAMETYPE_SCORE" );

	maps\mp\gametypes\_globallogic::setObjectiveHintText( "allies", &"BP_STRAT_GAMETYPE_HINT" );
	maps\mp\gametypes\_globallogic::setObjectiveHintText( "axis", &"BP_STRAT_GAMETYPE_HINT" );
	
	//thread sv_cheats();

	level.spawnMins = ( 0, 0, 0 );
	level.spawnMaxs = ( 0, 0, 0 );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "allies", "mp_tdm_spawn" );
	maps\mp\gametypes\_spawnlogic::addSpawnPoints( "axis", "mp_tdm_spawn" );

	level.mapCenter = maps\mp\gametypes\_spawnlogic::findBoxCenter( level.spawnMins, level.spawnMaxs );
	setMapCenter( level.mapCenter );

	ents = getEntArray();
	level.spawn_all = [];
	for ( index = 0; index < ents.size; index++ )
	{
		classname = ents[index].classname;
		if ( isSubStr( classname, "_spawn" ) )
		{
			curEnt = ents[index];
			level.spawn_all[level.spawn_all.size] = curEnt;
		}
	}

	maps\mp\gametypes\_rank::registerScoreInfo( "win", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "loss", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "tie", 0 );

	maps\mp\gametypes\_rank::registerScoreInfo( "kill", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "headshot", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "assist", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "plant", 0 );
	maps\mp\gametypes\_rank::registerScoreInfo( "defuse", 0 );
}

onSpawnPlayer()
{
	spawnpoint = maps\mp\gametypes\_spawnlogic::getSpawnpoint_NearTeam( level.spawn_all );
	self spawn( spawnpoint.origin, spawnpoint.angles );
	
	self thread give_ammo();
	self thread nade_fly();
	self thread rpg_fly();
}

callbackPlayerDamage( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	// Check if we need to modify the damage done
	if ( level.scr_wdm_enabled == 1 ) {
		iDamage = openwarfare\_weapondamagemodifier::wdmDamage( iDamage, sWeapon, sHitLoc, sMeansOfDeath );
		if ( iDamage == 0 )
				return;
	}

	// Check if we need to modify the damage done
	if ( level.scr_wlm_enabled == 1 ) {
		iDamage = openwarfare\_weaponlocationmodifier::wlmDamage( iDamage, sHitLoc, sMeansOfDeath );
		if ( iDamage == 0 )
				return;
	}

	if ( level.scr_wrm_enabled == 1 ) {
		iDamage = openwarfare\_weaponrangemodifier::wrmDamage( eAttacker, iDamage, sWeapon, sHitLoc, sMeansOfDeath );
		if ( iDamage == 0 )
				return;
	}

	// Check if rng is enabled.
	if( level.scr_rng_enabled != 0 ) {
		iDamage = self openwarfare\_rng::rngDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime );
		if ( iDamage == 0 )
				return;
	}
		
	// create a class specialty checks; CAC:bulletdamage, CAC:armorvest
	if ( sWeapon != "concussion_grenade_mp" ) {
		if ( !level.rankedMatch ) {
			iDamage = maps\mp\gametypes\_class_unranked::cac_modified_damage( self, eAttacker, iDamage, sMeansOfDeath );
		} else {
			iDamage = maps\mp\gametypes\_class::cac_modified_damage( self, eAttacker, iDamage, sMeansOfDeath );
		}
	}

	if ( game["state"] == "postgame" )
		return;

	if ( self.sessionteam == "spectator" )
		return;

	if ( isDefined( self.canDoCombat ) && !self.canDoCombat )
		return;

	if ( isDefined( eAttacker ) && isPlayer( eAttacker ) && isDefined( eAttacker.canDoCombat ) && !eAttacker.canDoCombat )
		return;

	prof_begin( "Callback_PlayerDamage flags/tweaks" );

	// Don't do knockback if the damage direction was not specified
	if( !isDefined( vDir ) )
		iDFlags |= level.iDFLAGS_NO_KNOCKBACK;

	prof_end( "Callback_PlayerDamage flags/tweaks" );

	if( isdefined(eAttacker) && isPlayer(eAttacker) )
	{
		hasBodyArmor = self hasPerk( "specialty_armorvest" );

		if( iDamage > 0 )
		{
			self iprintln(&"BP_STRAT_DAMAGE_FROM_X_Y", eAttacker.name, iDamage);
			if(eAttacker != self)
				eAttacker iprintln(&"BP_STRAT_DAMAGED_X_Y", self.name, iDamage);

			if( getDvarInt( "scr_enable_hiticon" ) != 2 || !(iDFlags & level.iDFLAGS_PENETRATION) )
				eAttacker thread maps\mp\gametypes\_damagefeedback::updateDamageFeedback( hasBodyArmor );
		}
	}

	level.useStartSpawns = false;
}

sv_cheats()
{
	wait 3;
	setDvar("sv_cheats", 1);
}

give_ammo()
{
	self endon("disconnect");
	self endon("death");
	
	for(;;)
	{
		wait 3;

		weapon = self getCurrentWeapon();
		
		self giveMaxAmmo( weapon );
		
		self setWeaponAmmoClip( "frag_grenade_mp", 1 );
	}
}

nade_fly()
{
	self endon("disconnect");
	self endon("death");

	for(;;)
	{
		//self waittill( "grenade_fire" );
		wait 0.05;

		the_nade = undefined;

		nades = getentarray( "grenade", "classname" );
		for( i=0; i < nades.size; i++ )
		{
			if( isDefined( nades[i].origin ) && !isDefined( nades[i].player_linked ) )
			{
				if( distance( nades[i].origin, self.origin ) < 150 )
				{
					nades[i].player_linked = true;
					the_nade = nades[i];
					break;
				}
			}
		}

		if( isDefined( the_nade ) )
		{
			self.old_origin = self.origin;
			self.old_angles = self getPlayerAngles();
			self linkto( the_nade );
			
			while( isDefined( the_nade ) )
			{
				wait 0.05;
				if( self useButtonPressed() )
				{
					self unlink();
					self.placeholder = spawn( "script_origin", self getorigin() );
					self linkto( self.placeholder );
					self thread get_down();
					break;
				}
			}
			if( !isDefined( the_nade ) )
			{
				self unlink();
				wait 1.5;
				self setOrigin( self.old_origin );
				self setPlayerAngles( self.old_angles );
			}
		}
	}
}

rpg_fly()
{
	self endon("disconnect");
	self endon("death");

	for(;;)
	{
		//self waittill( "rocket" );
		wait 0.05;

		the_rpg = undefined;

		rpgs = getentarray( "rocket", "classname" );
		for( i=0; i < rpgs.size; i++ )
		{
			if( isDefined( rpgs[i].origin ) && !isDefined( rpgs[i].player_linked ) )
			{
				if( distance( rpgs[i].origin, self.origin ) < 150 )
				{
					rpgs[i].player_linked = true;
					the_rpg = rpgs[i];
					break;
				}
			}
		}

		if( isDefined( the_rpg ) )
		{
			self.old_origin = self.origin;
			self.old_angles = self getPlayerAngles();
			self linkto( the_rpg );
			
			while( isDefined( the_rpg ) )
			{
				wait 0.05;
				if( self useButtonPressed() )
				{
					self unlink();
					self.placeholder = spawn( "script_origin", self getorigin() );
					self linkto( self.placeholder );
					self thread get_down();
					break;
				}
			}
			if( !isDefined( the_rpg ) )
			{
				self unlink();
				wait 1.5;
				self setOrigin( self.old_origin );
				self setPlayerAngles( self.old_angles );
			}
		}
	}
}

get_down()
{
	self endon("disconnect");

	while( self useButtonPressed() )
		wait 0.05;
	
	while( isDefined( self.placeholder ) )
	{
		wait 0.05;
		if( self useButtonPressed() )
		{
			self unlink();
			self.placeholder delete();
			self setOrigin( self.old_origin );
			self setPlayerAngles( self.old_angles );
			return;
		}
	}
}

/* **************************** Not Needed For Now
waittills()
{
	self endon("disconnect");
	self endon("death");

	for(;;)
	{
		wait 0.05;

		// gl is grenade, rpg is rocket

		ents = getentarray();
		for(i=0;i<ents.size;i++)
		{
			wait 0.05;
			if( isDefined(ents[i]) && !issubstr( ents[i].classname, "spawn" ) && ( !issubstr( ents[i].classname, "trigger" ) && !issubstr( ents[i].classname, "script" ) ) )
				iprintln( ents[i].classname );
		}
		iprintln("Testing...");
	}
}
**************************** End Block */

/* ********************** For Dan
main()
{
	registerRoundLimitDvar( level.gameType, 0, 0, 12 );
}

registerNumLivesDvar( dvarString, defaultValue, minValue, maxValue )
{
	dvarString = ("scr_" + dvarString + "_numlives");
	if ( getDvar( dvarString ) == "" )
		setDvar( dvarString, defaultValue );
		
	if ( getDvarInt( dvarString ) > maxValue )
		setDvar( dvarString, maxValue );
	else if ( getDvarInt( dvarString ) < minValue )
		setDvar( dvarString, minValue );
		
	level.numLivesDvar = dvarString;	
	level.numLivesMin = minValue;
	level.numLivesMax = maxValue;
	level.numLives = getDvarInt( level.numLivesDvar );
}

tracerStuff()
{

cg_tracerChance			0 0.2 0.4 0.6 0.8?
cg_tracerlength "160"			
cg_tracerScale "1"			
cg_tracerScaleDistRange "25000"			
cg_tracerScaleMinDist "5000"			
cg_tracerScrewDist "100"			
cg_tracerScrewRadius "0.5"			
cg_tracerSpeed "7500"			
cg_tracerwidth "4"			

}

CodJumper Stuff
init()
{

	// OnPlayerConnect
	thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	for(;;)
	{
		self waittill("spawned_player");
		self thread spawnedPlayerThreads();
	}
}

spawnedPlayerThreads()
{
	//Add threads here to run on player spawned
	self thread _MeleeKey();
	self thread _UseKey();
	self thread checkSuicide();
}

// Key Checks //
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

			for(i=0; i<0.5; i+=0.05)
			{
				if(catch_next && self meleeButtonPressed() && self isOnground())
				{
					wait 0.05;
					self thread savePos();
					wait 1;
					break;
				}
				else if(catch_next && self attackButtonPressed() && self isOnGround())
				{
					wait 0.05;
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

			for(i=0; i<=0.5; i+=0.05)
			{
				if(catch_next && self useButtonPressed() && !(self isMantling()))
				{
					wait 0.05;
					self thread loadPos();
					wait 1;
					break;
				}
				else if(catch_next && self attackButtonPressed() && !(self isMantling()))
				{
					wait 0.05;
					self thread loadPos2();
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

// Load and Save //

loadPos()
{

	if(!isDefined(self.saved_origin))
		self iprintlnbold("There is no previous position to load.");
	else
	{
		self setPlayerAngles(self.saved_angles);
		self setOrigin(self.saved_origin);
		self freezecontrols(true);
		wait 0.2;
		self freezecontrols(false);
		self iprintln("Previous position loaded.");
	}
}

loadPos2()
{

	if(!isDefined(self.saved_origin2))
		self iprintlnbold("There is no previous secondary position to load.");
	else
	{
		self setPlayerAngles(self.saved_angles2);
		self setOrigin(self.saved_origin2);
		self freezecontrols(true);
		wait 0.2;
		self freezecontrols(false);
		self iprintln("Previous secondary position loaded.");
	}
}

savePos()
{
	self.saved_origin = self.origin;
	self.saved_angles = self.angles;
	self iprintln("Position saved.");
}

savePos2()
{
	self.saved_origin2 = self.origin;
	self.saved_angles2 = self.angles;
	self iprintln("Position 2 saved.");
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

********************** */