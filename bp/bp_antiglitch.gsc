// ----------------------------------------------------------------------------
// Mod: BP Mod
// Website: http://www.bptourneys.com
// 
// Module: Anti-Glitch
// Author: Dan2k3k4
// Contents: 
// Description: 
// Notes: 
// ----------------------------------------------------------------------------
#include openwarfare\_utils;

init()
{
	precacheString(&"BP_ANTIGLITCH_KILLED_GLITCH");
	precacheString(&"BP_ANTIGLITCH_WARN_PLAYER");
	precacheString(&"BP_ANTIPRONE_WARN_PLAYER");

	switch( getDvar("mapname") )
	{
		case "mp_dhc_carentan_r":		thread dhc_carentan();			break;
		case "mp_convoy":				thread convoy();				break;
		case "mp_backlot":				thread backlot();				break;
		case "mp_citystreets":			thread district();				break;
		case "mp_crash":				thread crash();					break;
		case "mp_crossfire":			thread crossfire();				break;
		case "mp_overgrown":			thread overgrown();				break;
		case "mp_strike":				thread strike();				break;
		case "mp_meanstreet2":			thread meanstreet2();			break;
		case "mp_thehunt_final":		thread thehunt_final();			break;
		case "mp_sconsegrad":			thread sconsegrad();			break;
		case "mp_village":				thread village();				break;
		case "mp_doneck":				thread doneck();				break;
		case "mp_shipment":				thread shipment();				break;
	}
}

doneck()
{
	add_kill((2900, -734, -505), 100, 30);
}

village()
{
	add_kill((-1505, -2920, 697), 100, 10);
}

shipment()
{
	add_prone((229, 302, 418), 100, 100);
}

thehunt_final()
{
	add_prone((2570, 1688, -87), 30, 30);
}

sconsegrad()
{
	add_prone((-1730, -2114, -337), 170, 30);
}

dhc_carentan()
{
	add_kill((-2453, -2444, 14), 40, 52);
}

convoy()
{
	add_kill((-453, 202, 118), 40, 52);
	add_kill((-1093, 276, 142), 36, 52);
	add_kill((692, 1151, 76), 40, 52);
	add_kill((717, 956, 136), 40, 52);
	add_kill((644, 469, 136), 40, 52);
	add_kill((692, 1101, 76), 40, 52);
	add_kill((611, 1150, 78), 30, 52);
	add_kill((1413, -510, 146), 40, 52);
	add_kill((-393, -243, 106), 40, 52);
}

backlot()
{
	add_kill((-385, -1419, 248), 38, 52);
	add_kill((630, -1041, 384), 38, 52);
	add_kill((248, 225, 352), 38, 52);
	add_kill((-411, -2053, 268), 26, 52);
	add_kill((1361, 521, 304), 26, 52);
}

district()
{
	add_kill((3285, -284, 164), 26, 58);
}

crash()
{
	add_kill((656, -600, 428), 26, 52);
	add_kill((657, -712, 428), 26, 52);
	add_kill((-42, -1006, 418), 24, 52);
	add_kill((1686, 663, 736), 24, 52);
	add_kill((199, -982, 420), 24, 52);
	add_kill((622, -855, 414), 24, 52);
}

crossfire()
{
	add_kill((6315, -4178, 118), 24, 52);
	add_kill((6334, -1383, 238), 24, 52);
	add_kill((4377, -3001, 228), 24, 52);
}

overgrown()
{
	add_kill((-396, -3823, 12), 26, 52);
	add_kill((465, -4103, -7), 26, 52);
	add_kill((424, -4103, -7), 26, 52);
	add_kill((1230, -2923, -12), 26, 52);
	add_kill((890, -2936, -8), 26, 52);
	add_kill((782, -3808, -30), 26, 52);
	add_kill((1403, -1777, -38), 26, 52);
	add_kill((1847, -1694, -18), 26, 52);
}

strike()
{
	add_kill((-2309, 671, 204), 20, 52);
	add_kill((651, 848, 304), 20, 52);
	add_kill((737, -83, 164), 20, 52);
}

meanstreet2()
{
	add_kill((2035, -426, 376), 22, 52);
}

add_kill(origin, width, height)
{
	kill_ent = spawn("trigger_radius", origin, 0, width, height);
	warn_ent = spawn("trigger_radius", origin - (0, 0, 40), 0, width + 74, height + 64);
	warn_ent thread warn();
	kill_ent thread kill();
}

add_prone(origin, width, height)
{
	prone_ent = spawn("trigger_radius", origin, 0, width, height);
	prone_ent thread prevent_prone();
}

add_tele(origin, teleport_origin, width, height)
{
	tele_ent = spawn("trigger_radius", origin, 0, width, height);
	warn_ent = spawn("trigger_radius", origin - (0, 0, 40), 0, width + 74, height + 64);
	warn_ent thread warn();
	tele_ent thread tele_loop(teleport_origin);
}

tele_loop(teleport_origin)
{
	while (1)
	{
		self waittill ("trigger", player);
		
		if(isPlayer(player))
		{
			player setOrigin(teleport_origin);
			player suicide();
			iPrintln(&"BP_ANTIGLITCH_KILLED_GLITCH", player.name);
		}
		wait 1;
	}
}

prevent_prone()
{
	while(1)
	{
		self waittill("trigger", player);
		if(player.sessionstate != "playing")
			continue;
		if(isPlayer(player) && player getStance() == "prone")
		{
			player iPrintlnBold(&"BP_ANTIPRONE_WARN_PLAYER");
			player execClientCommand("+gostand");
		}
		wait 2;
	}
}

kill()
{
	while(1)
	{
		self waittill("trigger", player);
		if(player.sessionstate != "playing")
			continue;
		if(isPlayer(player))
		{
			player suicide();
			iPrintln(&"BP_ANTIGLITCH_KILLED_GLITCH", player.name);
		}
		wait 1;
	}
}

warn()
{
	while(1)
	{
		self waittill("trigger", player);
		if(player.sessionstate != "playing")
			continue;
		if(isPlayer(player))
			player iPrintlnBold(&"BP_ANTIGLITCH_WARN_PLAYER");
		wait 5;
	}
}

