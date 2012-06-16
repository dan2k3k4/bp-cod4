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

#include openwarfare\_utils;

init()
{
  level.scr_allow_testclients = getdvarx( "scr_allow_testclients", "int", 0, 0, 1 );
}

addTestClients()
{
	wait 5;

	for(;;)
	{
		if( getdvarInt("scr_testclients") > 0 || getdvarInt("scr_testclients_allies") > 0 || getdvarInt("scr_testclients_axis") > 0 )
			break;
		wait 1;
	}

	if( getdvarInt("scr_testclients") > 0 )
		thread addTestClientTeam("autoassign");

	if ( getdvarInt("scr_testclients_allies") > 0 )
		thread addTestClientTeam("allies");

	if ( getdvarInt("scr_testclients_axis") > 0 )
		thread addTestClientTeam("axis");

	thread addTestClients();
}

addTestClientTeam(dvar, team)
{
	testclients = getdvarInt(dvar);
	setDvar( dvar, 0 );
	for(i = 0; i < testclients; i++)
	{
		ent[i] = addtestclient();

		if (!isdefined(ent[i])) {
			println("Could not add test client");
			wait 1;
			continue;
		}

		ent[i].pers["isBot"] = true;

		if( level.rankedMatch )
			ent[i] thread TestClient(team);
		else
			ent[i] thread TestClient_mw(team);
	}
}

TestClient(team)
{
	self endon( "disconnect" );

	while(!isdefined(self.pers["team"]))
		wait .05;

	self notify("menuresponse", game["menu_team"], team);
	wait 0.5;

	classes = getArrayKeys( level.classMap );
	okclasses = [];
	for ( i = 0; i < classes.size; i++ )
	{
		if ( !issubstr( classes[i], "custom" ) && isDefined( level.default_perk[ level.classMap[ classes[i] ] ] ) )
			okclasses[ okclasses.size ] = classes[i];
	}
	
	assert( okclasses.size );

	while( 1 )
	{
		class = okclasses[ randomint( okclasses.size ) ];
		
		if ( !level.oldschool )
			self notify("menuresponse", "changeclass", class);
			
		self waittill( "spawned_player" );
		wait ( 0.10 );
	}
}

TestClient_mw(team)
{
	self endon( "disconnect" );

	while( !isdefined(self.pers["team"]) )
		wait 1;

	wait 1;
	self notify("menuresponse", game["menu_team"], team);
	wait 1;

	if ( !level.oldschool )
	{
		self notify("menuresponse", game["menu_changeclass_allies"], "assault");
		wait 1;
		self notify("menuresponse", game["menu_changeclass"] , "go");
	}
}