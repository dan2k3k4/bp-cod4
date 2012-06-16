main()
{

	maps\mp\mp_rd3_fx::main();
	maps\mp\_load::main();
	maps\mp\_explosive_barrels::main();
	ambientPlay("ambient_farm");
	setExpFog(300, 1400, 0.5, 0.5, 0.5, 0);
	maps\mp\_compass::setupMiniMap("compass_map_mp_rd3");

	game["allies"] = "sas";
	game["axis"] = "russian";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "woodland";
	game["axis_soldiertype"] = "woodland";
	
	setdvar( "r_specularcolorscale", "1" );
	
	setdvar("r_glowbloomintensity0",".25");
	setdvar("r_glowbloomintensity1",".25");
	setdvar("r_glowskybleedintensity0",".3");
	setdvar("compassmaxrange","1800");

	if( getDvar("g_gametype") == "ctf")
	{
		addobj("allied_flag", (3202, -825, 19), (0, 0, 0));
		addobj("axis_flag", (-1347, 1738, 38), (0, 0, 0));
	}

	if(getDvar("g_gametype") == "ctfb")
	{
		addobj("allied_flag", (3202, -825, 19), (0, 0, 0));
		addobj("axis_flag", (-1347, 1738, 38), (0, 0, 0));
	}
}

addobj(name, origin, angles)
{
	ent = spawn("trigger_radius", origin, 0, 48, 148);
	ent.targetname = name;
	ent.angles = angles;
}