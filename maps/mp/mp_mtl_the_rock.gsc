main()
{

	maps\mp\mp_mtl_the_rock_fx::main();

	level.airstrikeheightscale = 3.0;

	maps\mp\_load::main();
	maps\mp\_explosive_barrels::main();
	maps\mp\_compass::setupMiniMap("compass_map_mp_mtl_the_rock");

	setExpFog(3000, 7000, 0.5, 0.5, 0.5, 0);

	ambientPlay("ambient_backlot_ext");

	game["allies"] = "marines";
	game["axis"] = "opfor";
	game["attackers"] = "axis";
	game["defenders"] = "allies";
	game["allies_soldiertype"] = "desert";
	game["axis_soldiertype"] = "desert";

	setdvar( "r_specularcolorscale", "1" );

	setdvar("r_glowbloomintensity0",".25");
	setdvar("r_glowbloomintensity1",".25");
	setdvar("r_glowskybleedintensity0",".3");
	setdvar("compassmaxrange","2800");

}