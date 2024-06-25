main(phase, register)
{
    switch(phase) {
        case "init": _init(register); break;
        case "load": _load(); break;
    }
}

_init(register)
{
    if(isDefined(level.modmmccbycato1))
        return;
    level.modmmccbycato1 = true;

    // Add your own CoDaM takeover/threads etc here
    // ...
    precacheModel("xmodel/vehicle_plane_stuka_shot");
    precacheModel("xmodel/vehicle_plane_stuka_d");
    level._effect["blacksmokelinger"] = loadfx("fx/smoke/blacksmokelinger.efx");
}

_load()
{
    if(isDefined(level.modmmccbycato2))
        return;
    level.modmmccbycato2 = true;

    // Example: custom commands

	commands(150, level.prefix + "gg"  , ::cmd_gg    , "Say GG to everyone ["+ level.prefix + "gg]");
    commands(151, level.prefix + "n1"  , ::cmd_n1    , "Nice ["+ level.prefix + "n1]");
    commands(152, level.prefix + "maplist"    , ::cmd_maplist      , "List maps on the server. ["+ level.prefix + "maplist]");
    commands(153, level.prefix + "fps"         , ::cmd_fps         , "Change FPS limit. [" + level.prefix + "fps <value>]");
    commands(154, level.prefix + "dfps"         , ::cmd_dfps         , "show fps. [" + level.prefix + "dfps on/off]");
    commands(155, level.prefix + "disco"         , ::cmd_disco         , "Disco. [" + level.prefix + "disco]");
    commands(156, level.prefix + "dash"         , ::cmd_dash         , "Dash where you're looking. Need forward button pressed. [" + level.prefix + "dash]");
    commands(157, level.prefix + "stuka"         , ::cmd_stuka         , "Stuka. [" + level.prefix + "stuka <num || name> ]");
}

commands(id, cmd, func, desc)
{
    if(!isDefined(level.commands[cmd]))
        level.help[level.help.size]["cmd"] = cmd;

    level.commands[cmd]["func"] = func;
    level.commands[cmd]["desc"] = desc;
    level.commands[cmd]["id"]   = id;
}

message_player(msg)
{
    codam\_mm_commands::message_player(msg);
}

cmd_gg(args)
{
    if(isDefined(self.cooldown)) {
        message_player("Cooldown, wait " + self.cooldown + " seconds.");
        return;
    }
    message(codam\_mm_mmm::namefix(self.name) + " ^7says ^2G^3o^5o^1D ^2G^44^6M^0e ^7!");
    self.cooldown = 5;
    i = self.cooldown;
	for(n=0; n<i; n++) {
		self.cooldown--;
		wait 1;
	}
	self.cooldown = undefined;
}

cmd_n1(args)
{
    if(isDefined(self.cooldown)) {
        message_player("Cooldown, wait " + self.cooldown + " seconds.");
        return;
    }
    messages = [];
    messages[0] = " ^7says ^3Nice One ^7Mate^1!";
    messages[1] = " ^7says ^2Nice Shot ^7Mate^1!";
    messages[2] = " ^7says GooD Shooting^1!";
    messages[3] = " ^7says ^5Great Shot ^7Buddy^1!";
    messages[4] = " ^7says GooD Shooting^1!";
    message(codam\_mm_mmm::namefix(self.name) + messages[randomInt(4)]);
    self.cooldown = 5;
    i = self.cooldown;
	for(n=0; n<i; n++) {
		self.cooldown--;
		wait 1;
	}
	self.cooldown = undefined;
}

cmd_maplist(args)
{
    mapRotation = getCvar("sv_mapRotation");
    if(mapRotation == "") {
        message_player("^1ERROR: ^7No maps in mapRotation.");
        return;
    }

    for(i = 1; /*!*/; i++) {
        _cvar = getCvar("sv_mapRotation" + i);
        if(_cvar == "")
            break;
        mapRotation += " " + _cvar;
    }

    mapRotation = codam\_mm_mmm::strTok(mapRotation, " ");
    if(mapRotation[0] != "gametype" || mapRotation.size % 2 != 0) {
        message_player("^1ERROR: ^7Error in mapRotation.");
        return;
    }

    maps = []; gametypes = [];
    for(i = 0; i < mapRotation.size; i += 2) {
        if(mapRotation[i] == "gametype") {
            gametype = mapRotation[i + 1]; // gametype <gametype>
            if(!codam\_mm_mmm::in_array(gametypes, gametype))
                gametypes[gametypes.size] = gametype;
        } else {
            if(!isDefined(maps[gametype]))
                maps[gametype] = [];
            index = maps[gametype].size;
            maps[gametype][index] = mapRotation[i + 1]; // map <map>
        }
    }

    color[0] = "2"; color[1] = "3"; color[2] = "4"; color[3] = "6";
    color = codam\_mm_mmm::array_shuffle(color); color = color[0];
    for(i = 0; i < gametypes.size; i++) {
        gametype = gametypes[i];
        message_player("^5-------------------------^1" + toupper(gametype) + "^5-------------------------");
        message = "";
        for(m = 0; m < maps[gametype].size; m++) {
            message += maps[gametype][m];
            if((m + 1) % 7 == 0) {
                message_player("^" + color + message);
                message = "";
            } else
                message += " ";
        }

        if(m % 7 != 0)
            message_player("^" + color + codam\_mm_mmm::strip(message));
    }
}

cmd_fps(args)
{
    if(args.size < 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // name
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(args.size > 2) {
        for(a = 2; a < args.size; a++)
            if(isDefined(args[a]))
                args1 += " " + args[a];
    }

    self setClientCvar("com_maxfps", args1);
    message_player("Your FPS limit has set to: ^6" + args1 + "^7.");
}

cmd_dfps(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    if(!isDefined(args[1])) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    switch(args[1]) {
        case "on":
            message_player("^5INFO: ^7FPS Enabled.");
            self setClientCvar("cg_drawfps", "1");
        break;
        case "off":
            message_player("^5INFO: ^7FPS Disabled.");
            self setClientCvar("cg_drawfps", "0");
        break;
        default:
            message_player("^1ERROR: ^7Invalid argument.");
        break;
    }
}

cmd_disco(args)
{
    if(isDefined(self.cooldown)) {
        message_player("Cooldown, wait " + self.cooldown + " seconds.");
        return;
    }
    if(self.score < 6)
    {
        message_player("Need atleast ^36 ^7kills^1!");
        return;
    }
    message(codam\_mm_mmm::namefix(self.name) + "^7 used ^1D^2i^3s^4c^5o ^7Command^1!");
	for(i=0; i<5; i++)
    { 
        SetExpFog(0.0002, 1, 1, 0.3, 0.1); // yellow
        wait .5;
        SetExpFog(0.0002, 0, 0.6, 0.8, 0.1); // lightblue
        wait .5;
        SetExpFog(0.0002, 1, 0.3, 0.1, 0.1);
        wait .5;
        SetExpFog(0.0002, 0.1, 1, 0.2, 0.1);
        wait .5;
        //SetExpFog(distance, red, gree, blue, transition time);
    }
    SetExpFog(0.0002, 0.8, 0.8, 0.8, 0);
    self.cooldown = 20;
    i = self.cooldown;
	for(n=0; n<i; n++) {
		self.cooldown--;
		wait 1;
	}
	self.cooldown = undefined;
}

//Using Battleroyale physics
cmd_dash(args)
{
    if(isDefined(self.cooldown)) {
        message_player("Cooldown, wait " + self.cooldown + " seconds.");
        return;
    }
    if(self forwardButtonPressed()) {
		velocity = self getVelocity();
		angles = self getPlayerAngles();
		forwardDirection = anglesToForward(angles);
		
		newVelocity_x = velocity[0] + forwardDirection[0] * 600;
		newVelocity_y = velocity[1] + forwardDirection[1] * 600;
		newVelocity_z = velocity[2] + forwardDirection[2] * 600;
		newVelocity = (newVelocity_x, newVelocity_y, newVelocity_z);

		self setVelocity(newVelocity);
	}
    self.cooldown = 10;
    i = self.cooldown;
	for(n=0; n<i; n++) {
		self.cooldown--;
		wait 1;
	}
	self.cooldown = undefined;
}

cmd_stuka(args)
{
    if(args.size != 2) {
        message_player("^1ERROR: ^7Invalid number of arguments.");
        return;
    }

    args1 = args[1]; // num | string
    if(!isDefined(args1)) {
        message_player("^1ERROR: ^7Invalid argument.");
        return;
    }

    if(codam\_mm_mmm::validate_number(args1)) {
        player = codam\_mm_mmm::playerByNum(args1);
        if(!isDefined(player)) {
            message_player("^1ERROR: ^7No such player.");
            return;
        }
    } else {
        player = codam\_mm_commands::playerByName(args1);
        if(!isDefined(player)) return;
    }

    if(isAlive(player)) {
		message("Watch out! " + codam\_mm_mmm::namefix(player.name));
        stuka = spawn("script_model", player.origin + (0, 0, 4000));
        stuka.angles = (95, 0, 0);
        stuka setModel("xmodel/vehicle_plane_stuka_shot");

        stuka.crashed = false; //Not crashed yet

        stuka_s = spawn("script_model", stuka.origin + (200, 0, 0));
        stuka_s linkTo(stuka);

        stuka_s playLoopSound("in_plane");
        
        stuka thread stuka_smoke();
        
        stuka moveTo(player.origin, 3);
        stuka rotateroll(600 + randomInt(100), 3);

        wait 2.9;
        stuka setModel("xmodel/vehicle_plane_stuka_d");
        playFx(level._effect["bombexplosion"], stuka.origin);
        
        stuka.crashed = true; //Crashed now
        stuka_s stopLoopSound();
        stuka_s delete();
        stuka thread stuka_crashed_smoke(); //play the second smoke fx
        
        dist = distance(stuka.origin, player.origin);
        if(dist < 210)
        {
            
            player.health += 4000;
            damage = 100 + (10 - 100) * (dist / 210); //maths by chatgpt xd
            if(damage < 10)
                damage = 10;
            player finishPlayerDamage(self, self, 4000 + damage, 0, "MOD_PROJECTILE", "panzerfaust_mp", (self.origin + (0,0,-1)), vectornormalize(self.origin - (self.origin + (0,0,-1))), "none");
        }
    } else
        message_player("^1ERROR: ^7Player must be alive.");
}

stuka_smoke()
{
    while(isDefined(self))
    {
        if(self.crashed)
            break; //quit playing this fx when crashed
        if(!isDefined(level._effect["blacksmokelinger"]))
            break;
        playFx(level._effect["blacksmokelinger"], self.origin);

        wait 0.05;
    }
}

stuka_crashed_smoke()
{
    while(isDefined(self))
    {
        if(!isDefined(level._effect["fireheavysmoke"]))
            break;
        playFx(level._effect["fireheavysmoke"], self.origin);

        wait 1;
    }
}
