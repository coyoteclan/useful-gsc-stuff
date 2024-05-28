/*
* Rank system by Scappy CoCo v1.1 beta
*/

main(phase, register)
{
	switch(phase)
	{
		case "init":	_init(register);	break;
		case "load":	_load();			break;
	}
}

_init(register)
{
	level.users = [];
	level.dbugging = false;

	level.statDB = codam\coddb::load("stat");
	level.userDB = codam\coddb::load("users");

	[[register]]("PlayerConnect", 	::PlayerConnect, 	"thread");
	[[register]]("PlayerDisconnect", 	::PlayerDisconnect, 	"thread");
	[[register]]("PlayerKilled",		::PlayerKilled,		"thread");
	[[register]]("PlayerKilledFtag",		::PlayerKilled,		"thread");
	[[register]]("finishPlayerDamage",	::finishPlayerDamage,	"thread");
	[[register]]("endMap",		::endMap,		"thread");
}

_load()
{
	level.TEXT_ACCURACY = &"Accuracy^6:^7";
	level.TEXT_EXP = &"XP^6:^7";
	level.TEXT_KILLS = &"Kills^6:^7";
	level.TEXT_KPD = &"K/D^6:^7";
	level.TEXT_LOGGED_OUT = &"Rank^6:^7 Logged out^6.";
	level.TEXT_LOGIN_HELP = &"Use ^6!^7register or ^6!^7signin^6.";
	level.TEXT_PER = &"^6/^7";
	level.TEXT_RANK = &"Rank^6:^7";
	level.TEXT_UNRANKED = &"No rank.";
	
	codam\rs_titles::_initRank();
	
	precacheShader("black");
	precacheShader("white");
	
	precacheString(level.TEXT_ACCURACY);
	precacheString(level.TEXT_EXP);
	precacheString(level.TEXT_KILLS);
	precacheString(level.TEXT_KPD);
	precacheString(level.TEXT_LOGGED_OUT);
	precacheString(level.TEXT_LOGIN_HELP);
	precacheString(level.TEXT_PER);
	precacheString(level.TEXT_RANK);
	precacheString(level.TEXT_UNRANKED);
	
	for(i = 0; i<level.l_rank.size; i++) {
		precacheString(level.l_rank[i]);
	}

	/*
    regid = level.commands.size;
	level.perms["default"][level.perms["default"].size] = "" + regid;
	codam\_mm_commands::commands(level.prefix + "register", ::cmd_register,	"Create a rank account. ["+ level.prefix + "register <name> <password>]");
	
	signinid = level.commands.size;
	level.perms["default"][level.perms["default"].size] = "" + signinid;
	codam\_mm_commands::commands(level.prefix + "signin", ::cmd_login, "Sign into your rank account. ["+ level.prefix + "signin <name> <password>]");

	logoutid = level.commands.size;
	level.perms["default"][level.perms["default"].size] = "" + logoutid;
	codam\_mm_commands::commands(level.prefix + "signout", ::cmd_logout, "Logout from your rank account. ["+ level.prefix + "signout]");

	topid = level.commands.size;
	level.perms["default"][level.perms["default"].size] = "" + topid;
	codam\_mm_commands::commands(level.prefix + "top", ::cmd_top, "Show the top 10 players. ["+ level.prefix + "top]");

	playerstatid = level.commands.size;
	level.perms["default"][level.perms["default"].size] = "" + playerstatid;
	codam\_mm_commands::commands(level.prefix + "playerstat", ::cmd_stat, "Shows stats of a player. ["+ level.prefix + "playerstat <name>]");

	dumpid = level.commands.size;
	codam\_mm_commands::commands(level.prefix + "dumpdbs", ::cmd_dumpdbs, "Dump databases. ["+ level.prefix + "dumpdbs]");//*/
}

PlayerConnect(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8 ,b9) {
	self.pers["rank"] = -1;
	self.pers["prv_rank"] = -1;
	self.pers["exp"] = 0;

	stat = [];
	stat["kills"] = 0;
	stat["deaths"] = 0;
	stat["headshots"] = 0;
	stat["bash"] = 0;
	stat["longestDist"] = 0;
	stat["shots"] = 0;
	stat["hits"] = 0;
	stat["timePlayed"] = 0;
	stat["dmg"] = 0;
	stat["suicides"] = 0;
	
	self.pers["stat"] = stat;

	self auto_login();
	self thread drawHud();
	self thread _detectFire();
	self thread _save();
}

PlayerDisconnect(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
				b0, b1, b2, b3, b4, b5, b6, b7, b8 ,b9)
{
	self update_stats();
	
	self ranklogout();
}

PlayerKilled(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, a9,
				b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
	self.pers["stat"]["deaths"] ++;					
	if(isDefined(eAttacker) && isPlayer(eAttacker) && self != eAttacker) {
		eAttacker.pers["stat"]["kills"]++;
		action = " killed "; // " killed ";
		name = eAttacker getTitle() + ". " + eAttacker.name + "^7^7";

		if(isDefined(sHitLoc) && sHitLoc == "head" && sMeansOfDeath != "MOD_MELEE") {
			eAttacker.pers["stat"]["headshots"]++;
			action = " headshotted ";
		}

		if(sMeansOfDeath == "MOD_MELEE") {
			eAttacker.pers["stat"]["bash"]++;
			action = " bashed ";
		}

		dist = distance(self.origin, eAttacker.origin);
		if(dist > eAttacker.pers["stat"]["longestDist"])
			eAttacker.pers["stat"]["longestDist"] = dist;
		
		eAttacker thread update_stats();
	} else {
		self.pers["stat"]["suicides"]++;
		action = " committed die.";
		name = self getTitle() + ". " + self.name + "^7^7";
	}

	self thread update_stats();
	msg = name + action;
	if(isDefined(eAttacker) && isPlayer(eAttacker) && self != eAttacker) {
		msg += self getTitle() + ". " + self.name + "^7^7";
	}

	iprintln(msg);
}

finishPlayerDamage(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, a9,
				b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
	if(isDefined(eAttacker) && isPlayer(eAttacker) && self != eAttacker)
	{
		eAttacker.pers["stat"]["dmg"] += iDamage;
		eAttacker.pers["stat"]["hits"]++;
		eAttacker thread update_stats();
	}

	self thread update_stats();

}

endMap(a0, a1, a2, a3, a4, a5, a6, a7, a8, a9,
				b0, b1, b2, b3, b4, b5, b6, b7, b8 ,b9)
{
	level waittill("end_map");
	
	players = getentarray("player", "classname");
	for(i=0; i<players.size; i++)
	{
		if(!playes[i] isLoggedIn())
			continue;

		players[i] update_stats();
		wait 0.05;
	}
}

// Commands

cmd_ranked_login(args)
{
	if(args.size != 3)
	{
		message_player("^6ERROR: ^7Use ^6!^7signin username password.");
		return;
	}
	ranklogin(args[1], args[2]);
}

cmd_ranked_logout(args)
{
	if(args.size != 1)
	{
		message_player("^6ERROR: ^7Use ^6!^7signout.");
		return;
	}
	message_player("You are logged out.");
	ranklogout();
}

cmd_ranked_register(args)
{
	if(args.size != 3)
	{
		message_player("^6ERROR: ^7Use ^6!^7register username password.");
		return;
	}
	rankregister(args[1], args[2]);
}

cmd_dumpdbs(args)
{
	self codam\coddb::dumpdbs();
}

cmd_ranked_top(args)
{
	if(args.size > 1)
	{
		message_player("^6ERROR: ^7Invalid number of arguments!");
		return;
	}
	
	x = 10;

	if(isDefined(args[1]))
	{
		y = (int)args[1];
		if(y > 10)
		{
			x = y;
		}
	}

	colors = [];
	colors[0] = "^3";
	colors[1] = "^6";
	colors[2] = "^5";
	colors[3] = "^0";
	colors[4] = "^0";
	colors[5] = "^0";
	colors[6] = "^0";
	colors[7] = "^0";
	colors[8] = "^0";
	colors[9] = "^0";

	topplayers = get_topX(x);

	message_player("Top " + topplayers.size + " players");

	for(i=0; i<topplayers.size; i++)
	{
		color = colors[i];
		user = topplayers[i];
		if(user["id"] == self.pers["userID"])
			color = "^2";
		
		rank = xrank(get_xp(user));
		
		message_player(color + "#" + (i+1) + ": ^7" + user["name"] + color + " kills: ^7" + user["kills"] + color + " rank: ^7" + rank + " " + level.t_rank[rank-1]);
		wait 0.5;
	}

	message_player("__________________");
	
}

cmd_ranked_stat(args)
{
	if(args.size != 2)
	{
		message_player("^6ERROR: ^7Invalid number of arguments!");
		return;
	}
	
	args1 = args[1]; // num | string
	if(!isDefined(args1)) {
		message_player("^6ERROR: ^7Invalid argument.");
		return;
	}
	
	if(codam\_mm_mmm::validate_number(args1)) {

		player = getEntByNum(args1);
		if(!isDefined(player)) {
			message_player("^6ERROR: ^7No such player.");
			return;
		}
	} else {
		player = codam\_mm_commands::playerByName(args1);
		if(!isDefined(player)) return;
		
	}

	if(player isLoggedIn())
	{
		
		kpd = "--";
		if(player.pers["stat"]["deaths"] != 0)
			kpd = player.pers["stat"]["kills"] / player.pers["stat"]["deaths"];
	
		rank = player.pers["rank"];
		
		message_player(player.name + "^7: Kills: " + player.pers["stat"]["kills"] + " K/D: " + kpd + " Rank: " + rank + " " + level.t_rank[rank-1]);

	}
}

// Functions

sync_stats()
{
	if(self isLoggedIn())
	{
		stat = codam\coddb::db_select(level.statDB, "user", "=", self.pers["userID"])[0];

		if(isDefined(stat))
		{
			_stat = [];
			_stat["kills"] = (int)stat["kills"];
			_stat["deaths"] = (int)stat["deaths"];
			_stat["headshots"] = (int)stat["headshots"];
			_stat["bash"] = (int)stat["bash"];
			_stat["longestDist"] = (float)stat["longestDist"];
			_stat["shots"] = (int)stat["shots"];
			_stat["hits"] = (int)stat["hits"];
			_stat["timePlayed"] = (int)stat["timePlayed"];
			_stat["dmg"] = (int)stat["dmg"];
			_stat["suicides"] = (int)stat["suicides"];
			self.pers["stat"] = _stat;
			
			exp = get_xp(_stat);
			self.pers["exp"] = exp;
			self.pers["rank"] = xrank(exp);
			
			self notify("rsready");

			return true;
		}
		else
		{
			_stat = [];
			_stat["user"] = self.pers["userID"];
			_stat["kills"] = 0;
			_stat["deaths"] = 0;
			_stat["headshots"] = 0;
			_stat["bash"] = 0;
			_stat["longestDist"] = 0;
			_stat["shots"] = 0;
			_stat["hits"] = 0;
			_stat["timePlayed"] = 0;
			_stat["dmg"] = 0;
			_stat["suicides"] = 0;

			codam\coddb::db_insert(level.statDB, _stat);
		}
	}
	
	return false;
}

update_stats()
{
	if(self isLoggedIn())
	{
		if(codam\coddb::db_update(level.statDB, "user", "=", self.pers["userID"], self.pers["stat"]))
		{
			//print("RankSystem: Stat updated successfully");
			exp = get_xp(self.pers["stat"]);
			self.pers["exp"] = exp;
			self.pers["rank"] = xrank(exp);
			return true;
		}
	}
	return false;
}

auto_login()
{
	self.pers["userID"] = -1;
	self.pers["rank"] = 0;
	
	user = codam\coddb::db_select(level.userDB, "ip", "=", self getip());
	
	if(user.size == 1 && isDefined(user[0]["id"]))
	{
		self do_login(user[0]);
	}
	
}

do_login(user)
{
	id = level.users.size;
	level.users[id] = user["id"];
	self.pers["userID"] = user["id"];
	self thread onLogin();
}

ranklogin(username, password)
{

	if(!(validate_input(username) && validate_input(password)))
	{
		message_player("Invalid password or username format!");
		message_player("Username: 3 to 10 characters. Can contain: a-z A-Z 0-9");
		message_player("Password: 3 to 10 characters. Can contain: a-z A-Z 0-9");
		return;
	}
	
	r = codam\coddb::db_select(level.userDB, "name", "=", username);
	
	if(r.size == 0)
	{
		message_player("^6ERROR: ^7Unknown user. Use ^6!register username password ^7to register.");
		return;
	}
	
	// if(array_indexOf(level.users, r[0]["id"]) != -1)
	if(self isLoggedIn())
	{
		message_player("^5INFO: ^7You are already logged in.");
		return;
	}
	
	if(r[0]["password"] == password)
	{
		self.pers["userID"] = r[0]["id"];
		
		ip = [];
		ip["ip"] = self getip();
		
		
		if(codam\coddb::db_update(level.userDB, "id", "=", r[0]["id"], ip))
		{
			//print("Rank System: Ip updated for user");
		}
		
		message_player("You are logged in.");
		
		self do_login(r[0]);

	}
	else
	{
		message_player("^6ERROR: ^7You shall not pass!");
	}
}

isLoggedIn()
{
	return (isDefined(self.pers["userID"]) && self.pers["userID"] != -1);
}

ranklogout()
{
	if(!self isLoggedIn())
		return;
	
	self.pers["rank"] = -1;
	self.pers["exp"] = 0;

	stat = [];
	stat["kills"] = self.score;
	stat["deaths"] = self.deaths;
	stat["headshots"] = 0;
	stat["bash"] = 0;
	stat["longestDist"] = 0;
	stat["shots"] = 0;
	stat["hits"] = 0;
	stat["timePlayed"] = 0;
	stat["dmg"] = 0;
	stat["suicides"] = 0;
	
	self.pers["stat"] = stat;

	userID = self.pers["userID"];
	
	self.pers["userID"] = -1;
	
	
}

onLogin()
{
	self thread timer();
	self sync_stats();
	wait 1;
	self thread _save();
	return;
}

rankregister(username, password, ip)
{
	// validate username and password
	if(!(validate_input(username, "^") && validate_input(password) && username.size >= 3
			&& password.size >= 3 && username.size <= 10 && password.size <= 10 ))
	{
		message_player("^6ERROR: ^7Invalid password or username format!");
		message_player("Username: 3 to 10 characters. Can contain: a-z A-Z 0-9");
		message_player("Password: 3 to 10 characters. Can contain: a-z A-Z 0-9");
		return;
	}

	// check the username is free
	r = codam\coddb::db_select(level.userDB, "name", "=", username);
	
	// detect multi account
	rip = codam\coddb::db_select(level.userDB, "ip", "=", self getip());
	
	if(r.size == 0 && rip.size < 1)
	{
		// username free
		user = [];
		user["name"] = username;
		user["password"] = password;
		user["ip"] = ip;
		
		if(codam\coddb::db_insert(level.userDB, user))
		{
			self ranklogin(username, password);
		}
		else
		{
			message_player("^6ERROR: ^7Failed to register due unknown error.");
		}
	}
	else
	{
		if(r.size != 0)
			message_player("^6ERROR: ^7Username in use.");

		if(rip.size >= 1)
			message_player("^6ERROR: ^7You can only register once with the same IP address.");
	}
}

validate_input(username, additional)
{
	
	if(!isDefined(additional))
		additional = "";
	
	enabledchars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" + additional;
	for(i=0; i<username.size; i++)
	{
		r = false;
		for(j=0; j<enabledchars.size; j++)
		{
			if(username[i] == enabledchars[j])
			{
				r = true;
				break;
			}
		}
		
		if(!r)
			return false;
	}
	
	return true;
}

timer()
{
	self endon("disconnect");
	
	for(;;)
	{
		wait 1;
		self.pers["stat"]["timePlayed"]++;
	}
}

// Weapon 
fire(weapon, slot)
{
	
}

_detectFire()
{
	self endon("disconnect");
	
	// onFire(::fire);
	
	slot = self getCurrentWeaponSlot();
	clipammo = self getCurrentWeaponClipAmmo();

	while(true)
	{
		ammo = self getCurrentWeaponClipAmmo();
		cslot = self getCurrentWeaponSlot();
		wait 0.01;
		if(clipammo > ammo && slot == cslot)
		{
			if(cslot != "grenade")
				self.pers["stat"]["shots"]++;	

		}
		clipammo = ammo;
		slot = cslot;
		
	}
}

onFire(listener)
{
	if(!isDefined(level._fdlisteners))
			level._fdlisteners = [];
		
	id = level._fdlisteners.size;
	
	level._fdlisteners[id] = listener;
	
	return id;
}

getCurrentWeaponClipAmmo()
{
	slot = self getCurrentWeaponSlot();
	if(slot != "grenade")
		return self getWeaponSlotClipAmmo(slot);
	else
		return self getWeaponSlotAmmo(slot);
}

getCurrentWeaponSlot()
{
	current = self getCurrentWeapon();
	slot = "grenade";
	if(self getWeaponSlotWeapon("pistol") == current)
		slot = "pistol";
	else if(self getWeaponSlotWeapon("primary") == current)
		slot = "primary";
	else if(self getWeaponSlotWeapon("primaryb") == current)
		slot = "primaryb";

	return slot;
}

// Hud
drawHud()
{
	self endon("disconnect");
	
	for(;;)
	{
		self _drawHud();
		wait 1;
	}
}

_drawHud()
{
	self endon("disconnect");

	if(!isDefined(self._logged_out)) {
		self._logged_out = newClientHudElem(self);
		self._logged_out.archived = false;
		self._logged_out.x = 110; // 2
		self._logged_out.y = 390; // 230
		self._logged_out.fontScale = 0.8;
		self._logged_out.alignX = "left";
		self._logged_out.alignY = "middle";
		self._logged_out settext(level.TEXT_LOGGED_OUT);
	}

	if(!isDefined(self._login_help)) {
		self._login_help = newClientHudElem(self);
		self._login_help.archived = false;
		self._login_help.x = 110; // 2;
		self._login_help.y = 400; // 240
		self._login_help.fontScale = 0.8;
		self._login_help.alignX = "left";
		self._login_help.alignY = "middle";
		self._login_help settext(level.TEXT_LOGIN_HELP);
	}

	if(self isLoggedIn()) {
		if(isDefined(self._logged_out)) self._logged_out destroy();
		if(isDefined(self._login_help)) self._login_help destroy();
	} else {
		if(isDefined(self._hud_rank)) self._hud_rank destroy();
		if(isDefined(self._hud_rank_value)) self._hud_rank_value destroy();
		if(isDefined(self._hud_kills)) self._hud_kills destroy();
		if(isDefined(self._hud_kills_value)) self._hud_kills_value destroy();
		if(isDefined(self._hud_kpd)) self._hud_kpd destroy();
		if(isDefined(self._hud_kpd_value)) self._hud_kpd_value destroy();
		if(isDefined(self._hud_acc)) self._hud_acc destroy();
		if(isDefined(self._hud_acc_value)) self._hud_acc_value destroy();
		if(isDefined(self._hud_exp)) self._hud_exp destroy();
		if(isDefined(self._hud_exp_value)) self._hud_exp_value destroy();
		if(isDefined(self._hud_exp_per)) self._hud_exp_per destroy();
		if(isDefined(self._hud_exp_next)) self._hud_exp_next destroy();
		
		return;
	}
	
	if(!isDefined(self._hud_rank))
	{
		self._hud_rank = newClientHudElem(self);
		self._hud_rank.archived = false;
		self._hud_rank.x = 110;
		self._hud_rank.y = 390; // 220
		self._hud_rank.fontScale = 0.8;
		self._hud_rank.alignX = "left";
		self._hud_rank.alignY = "middle";
		self._hud_rank settext(level.TEXT_RANK);
	}
	
	if(!isDefined(self._hud_rank_value))
	{
		self._hud_rank_value = newClientHudElem(self);
		self._hud_rank_value.archived = false;
		self._hud_rank_value.x = 150;
		self._hud_rank_value.y = 390; // 220
		self._hud_rank_value.fontScale = 0.8;
		self._hud_rank_value.alignX = "left";
		self._hud_rank_value.alignY = "middle";
		
		self._hud_rank_value settext(level.TEXT_UNRANKED);
	}

	if (self.pers["rank"] != -1)
		self._hud_rank_value settext(self getLocalizedTitle());
	else
		self._hud_rank_value settext(level.TEXT_UNRANKED);

	if(!isDefined(self._hud_kills))
	{
		self._hud_kills = newClientHudElem(self);
		self._hud_kills.archived = false;
		self._hud_kills.x = 110; // 2
		self._hud_kills.y = 400; // 230
		self._hud_kills.fontScale = 0.8;
		self._hud_kills.alignX = "left";
		self._hud_kills.alignY = "middle";
		self._hud_kills settext(level.TEXT_KILLS);
	}

	kills = self.score;
	deaths = self.deaths;

	if(self isLoggedIn())
	{

		kills = self.pers["stat"]["kills"];
		deaths = self.pers["stat"]["deaths"];
	}

	if(!isDefined(self._hud_kills_value))
	{
		self._hud_kills_value = newClientHudElem(self);
		self._hud_kills_value.archived = false;
		self._hud_kills_value.x = 150; // 45
		self._hud_kills_value.y = 400; // 230
		self._hud_kills_value.fontScale = 0.8;
		self._hud_kills_value.alignX = "left";
		self._hud_kills_value.alignY = "middle";
		self._hud_kills_value setvalue(kills);
	}

	self._hud_kills_value setvalue(kills);
	
	if(!isDefined(self._hud_kpd))
	{
		self._hud_kpd = newClientHudElem(self);
		self._hud_kpd.archived = false;
		self._hud_kpd.x = 110; // 2;
		self._hud_kpd.y = 410; // 240
		self._hud_kpd.fontScale = 0.8;
		self._hud_kpd.alignX = "left";
		self._hud_kpd.alignY = "middle";
		self._hud_kpd settext(level.TEXT_KPD);
	}

	if(!isDefined(self._hud_kpd_value))
	{
		self._hud_kpd_value = newClientHudElem(self);
		self._hud_kpd_value.archived = false;
		self._hud_kpd_value.x = 150; // 45;
		self._hud_kpd_value.y = 410; // 240
		self._hud_kpd_value.fontScale = 0.8;
		self._hud_kpd_value.alignX = "left";
		self._hud_kpd_value.alignY = "middle";
		self._hud_kpd_value settext(&"--");
	}

	if(deaths == 0)
	{
		self._hud_kpd_value settext(&"--");
	}
	else
	{
		kdr = (int)((float)kills/(float)deaths * 100);
		self._hud_kpd_value setvalue((float)kdr / 100);
	}

	if(!isDefined(self._hud_acc))
	{
		self._hud_acc = newClientHudElem(self);
		self._hud_acc.archived = false;
		self._hud_acc.x = 110; // 2
		self._hud_acc.y = 420; // 250
		self._hud_acc.fontScale = 0.8;
		self._hud_acc.alignX = "left";
		self._hud_acc.alignY = "middle";
		self._hud_acc settext(level.TEXT_ACCURACY);
	}

	if(!isDefined(self._hud_acc_value))
	{
		self._hud_acc_value = newClientHudElem(self);
		self._hud_acc_value.archived = false;
		self._hud_acc_value.x = 150; // 45
		self._hud_acc_value.y = 420; // 250
		self._hud_acc_value.fontScale = 0.8;
		self._hud_acc_value.alignX = "left";
		self._hud_acc_value.alignY = "middle";
		self._hud_acc_value settext(&"--");
	}

	if(self.pers["stat"]["shots"] == 0)
	{
		self._hud_acc_value settext(&"--");
	}
	else
	{
		acc = (int)((float)self.pers["stat"]["hits"]/(float)self.pers["stat"]["shots"] * 100);
		self._hud_acc_value setvalue((float)acc / 100);
	}
	
	if(self isLoggedIn())
	{
		next = level.RankExp[self.pers["rank"]];
		current = level.RankExp[self.pers["rank"] - 1];
	}
	else
	{
		next = 0;
		current = 0;
	}
	
	// Exp
	if(!isDefined(self._hud_exp))
	{
		self._hud_exp = newClientHudElem(self);
		self._hud_exp.archived = false;
		self._hud_exp.x = 110; // 3
		self._hud_exp.y = 430; // 260
		self._hud_exp.fontScale = 0.8;
		self._hud_exp.alignX = "left";
		self._hud_exp.alignY = "middle";
		self._hud_exp settext(level.TEXT_EXP);
	}

	if(!isDefined(self._hud_exp_value))
	{
		self._hud_exp_value = newClientHudElem(self);
		self._hud_exp_value.archived = false;
		self._hud_exp_value.x = 150; // 28
		self._hud_exp_value.y = 430; // 260
		self._hud_exp_value.fontScale = 0.8;
		self._hud_exp_value.alignX = "left";
		self._hud_exp_value.alignY = "middle";
		self._hud_exp_value setvalue(0);
	}

	self._hud_exp_value setvalue(self.pers["exp"] - current);

	if(!isDefined(self._hud_exp_per))
	{
		self._hud_exp_per = newClientHudElem(self);
		self._hud_exp_per.archived = false;
		self._hud_exp_per.x = 166; // 50
		self._hud_exp_per.y = 430; // 260
		self._hud_exp_per.fontScale = 0.8;
		self._hud_exp_per.alignX = "left";
		self._hud_exp_per.alignY = "middle";
		self._hud_exp_per settext(level.TEXT_PER);
	}

	if(!isDefined(self._hud_exp_next))
	{
		self._hud_exp_next = newClientHudElem(self);
		self._hud_exp_next.archived = false;
		self._hud_exp_next.x = 170; // 56
		self._hud_exp_next.y = 430; // 260
		self._hud_exp_next.fontScale = 0.8;
		self._hud_exp_next.alignX = "left";
		self._hud_exp_next.alignY = "middle";
		self._hud_exp_next setvalue(next - current);
	}

	self._hud_exp_next setvalue(next - current);
}


// utils

message_player(msg, player)
{
	self codam\_mm_commands::message_player(msg, player);
}

message(msg)
{
	codam\_mm_commands::message(msg);
}

array_remove(arr, elem)
{
	out = [];

	if(!isDefined(elem) || !isDefined(arr))
		return out;

	for(i=0; i<arr.size; i++)
	{
		if(arr[i] != elem)
			out[out.size] = arr[i];
	}
	
	return out;
}

array_removeAt(arr, index)
{
	out = [];

	if(!isDefined(index) || !isDefined(arr))
		return out;

	for(i=0; i<arr.size; i++)
	{
		if(i != index)
			out[out.size] = arr[i];
	}
	
	return out;
}

array_indexOf(arr, elem)
{
	if(!isDefined(elem) || !isDefined(arr))
		return -1;

	for(i=0; i<arr.size; i++)
	{
		if(!isDefined(arr[i]))
			continue;

		if(arr[i] == elem)
			return i;
	}
	
	return -1;
}

lerp(v0, v1, t)
{
	return ((1 - t) * v0 + t * v1);
}

vlerp(v0, v1, t)
{
	return (vscale(v0, (1 - t)) + vscale(v1, t));
}

vscale(v, s)
{
	return (v[0] * s, v[1] * s, v[2] * s);
}

_save()
{
	self waittill("rsready");
	for(;;)
	{
		if(self isLoggedIn())
		{
			self update_stats();
		}
		
		wait 5;
	}
}

get_xp(user)
{
	kill_scalar = 10;
	damage_scalar = 0.05;
	headshot_scalar = 5;
	
	xp = (int)user["kills"] * kill_scalar;
	xp += (int)((float)user["dmg"] * damage_scalar);
	xp += (int)user["headshots"] * headshot_scalar;
	
	return xp;
}

xrank(xp)
{
	for(i=0; i<level.RankExp.size; i++)
	{
		if(level.RankExp[i] > xp)
			return i;
	}
	
	return 55;
}

get_topX(x)
{
	topX = [];
	users = codam\coddb::db_select(level.userDB, "*");
	stats = codam\coddb::db_select(level.statDB, "*");
	users = codam\coddb::db_concat(users, stats, "id", "user", level.statDB);
	
	if(x > users.size)
		x = users.size;

	for(i=0; i<x; i++)
	{
		j = get_first(users);
		topX[i] = users[j];
		users = array_removeAt(users, j);
	}
	return topX;
}

get_first(users)
{
	first = users[0];
	x = 0;
	for(i=0; i<users.size; i++)
	{
		if(isDefined(users[i]["kills"]) && (int)users[i]["kills"] > (int)first["kills"])
		{
			first = users[i];
			x = i;
		}
	}
	return x;
}

// Getters

getRank()
{
	self.pers["prv_rank"] = self.pers["rank"];

	if(self isLoggedIn())
	{
		xp = get_xp(self.pers["stat"]);
		self.pers["rank"] = xrank(xp);
		self.pers["exp"] = xp;
	}
	else
	{
		self.pers["rank"] = -1;
		self.pers["exp"] = 0;
	}
	
	if(self.pers["prv_rank"] != -1 && self.pers["prv_rank"] < self.pers["rank"])
	{
		self iprintlnbold("Rank up^6! ^7" + self getTitleLng());
		iprintln(self.name + "^7^7 ranked up to " + self getTitleLng() + "^6!");
	}
	
	return self.pers["rank"];
}

getTitle()
{
	if(!self isLoggedIn())
		return "Pvt";

	return level.r_title[self getRank() -1];
}

getTitleLng()
{
	if(!self isLoggedIn())
		return "Pvt";

	return level.t_rank[self getRank() -1];
}

getLocalizedTitle()
{
	if(!self isLoggedIn())
		return level.TEXT_UNRANKED;

	return level.l_rank[self getRank() -1];
}