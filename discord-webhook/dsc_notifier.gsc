// Made by Kazam

init()
{
    level.enableNotifier = false;
    if(getCvarInt("scr_enablenotifier") >= 1)
    {
        level.enableNotifier = true;
    }
    if(isDefined(getCvar("scr_notifierwebhook")) && getCvar("scr_notifierwebhook") != "")
    {
        level.notifierWebhook = getCvar("scr_notifierwebhook");
    }
    /*if(isDefined(getCvar("scr_discordLogWebhook")) && getCvar("scr_discordLogWebhook") != "")
    {
        level.discordLogWebhook = getCvar("scr_discordLogWebhook");
    }*/
}

notifyDiscordConn(name)
{
    if(!level.enableNotifier)
        return;
    if(!isDefined(level.notifierWebhook))
        return;
    wait 0.5;
    
    if(!isDefined(name)) {
        printLn("##### notifyDiscordConn: name is not defined");
        return;
    }
    if(isDefined(self.pers["notifiedConn"]))
        return;
    self.pers["notifiedConn"] = 1; // to prevent sending a message in every new round

    i = randomInt(10);
    if(i == 1) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " has joined the battle!");
        return;
    }
    else if(i == 2) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " just dropped in!");
        return;
    }
    else if(i == 3) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " has arrived on the battlefield. Let the chaos begin!");
        return;
    }
    else if(i == 4) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " is here to change the game!");
        return;
    }
    else if(i == 5) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " just connected, armed and dangerous!");
        return;
    }
    else if(i == 6) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " is back, and the enemy is trembling!");
        return;
    }
    else if(i == 7) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " stepped into the warzone, bringing their A-game.");
        return;
    }
    else if(i == 8) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " connected, eager for some action!");
        return;
    }
    else if(i == 9) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " is now in the game.");
        return;
    }
    else {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " joined the game.");
        return;
    }
}

notifyDiscordDisconn(name)
{
    if(!level.enableNotifier)
        return;
    if(!isDefined(level.notifierWebhook))
        return;
    
    wait 0.5;
    
    if(!isDefined(name)) {
        printLn("##### notifyDiscordDisconn: name is not defined");
        return;
    }

    i = randomInt(10);
    if(i == 1) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " ran out of ammo and left the battlefield!");
        return;
    }
    else if(i == 2) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " got bored and decided to quit the fight.");
        return;
    }
    else if(i == 3) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " vanished into thin air.");
        return;
    }
    else if(i == 4) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " decided it's safer offline!");
        return;
    }
    else if(i == 5) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " has left the warzone. Better luck next time!");
        return;
    }
    else if(i == 6) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " disconnected, probably to reload their snacks!");
        return;
    }
    else if(i == 7) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " retreated from the battlefield.");
        return;
    }
    else if(i == 8) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " escaped the chaos.");
        return;
    }
    else if(i == 9) {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " disconnected, but their legend remains.");
        return;
    }
    else {
        webhookMessage(level.notifierWebhook, boldify(monotone(name)) + " has left the game. Guess it was time for a break.");
        return;
    }
}

notifyDiscordKill(player, eAttacker, sWeapon, sMeansOfDeath)
{
    if(!level.enableNotifier)
        return;
    if(!isDefined(level.notifierWebhook))
        return;
    
    wait 0.5;
    
    if(!isDefined(player)) {
        printLn("##### notifyDiscordConn: player is not defined");
        return;
    }

    if(sMeansOfDeath == "MOD_FALLING") {
        webhookMessage(level.notifierWebhook, boldify(monotone(player)) + " fell from a high place.");
        return;
    }
    if(sMeansOfDeath == "MOD_SUICIDE") {
        webhookMessage(level.notifierWebhook, boldify(monotone(player)) + " committed suicide.");
        return;
    }

    if(!isDefined(eAttacker)) {
        printLn("##### notifyDiscordConn: eAttacker is not defined");
        return;
    }

    if(sMeansOfDeath == "MOD_GRENADE_SPLASH") {
        webhookMessage(level.notifierWebhook, boldify(monotone(player)) + " was blown up by " + boldify(monotone(eAttacker)) + "'s nade.");
        return;
    }
    weap = _weapName(sWeapon);

    if(sMeansOfDeath == "MOD_HEADSHOT") {
        i = randomInt(3);
        if(i == 1) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " nailed " + boldify(monotone(player)) + " with a headshot using " + weap + "!");
            return;
        }
        else if(i == 2) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " turned " + boldify(monotone(player)) + "'s head into a target practice with " + weap + "!");
            return;
        }
        else {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " scored a clean headshot on " + boldify(monotone(player)) + " with " + weap + ". Precision!");
            return;
        }
    }
    else if(sMeansOfDeath == "MOD_MELEE") {
        i = randomInt(3);
        if(i == 1) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " closed in and took down " + boldify(monotone(player)) + " with a brutal melee!");
            return;
        }
        else if(i == 2) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " finished off " + boldify(monotone(player)) + " with a swift melee. No escape!");
            return;
        }
        else {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " got up close and personal, taking out " + boldify(monotone(player)) + " with a melee.");
            return;
        }
    }
    else {
        i = randomInt(10);
        if(i == 1) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " took out " + boldify(monotone(player)) + " with a deadly " + weap + "!");
            return;
        }
        else if(i == 2) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " ended " + boldify(monotone(player)) + "'s run with a precise " + weap + ".");
            return;
        }
        else if(i == 3) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " sent " + boldify(monotone(player)) + " packing with a well-placed " + weap + "!");
            return;
        }
        else if(i == 4) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " delivered a fatal blow to " + boldify(monotone(player)) + " with " + weap + ".");
            return;
        }
        else if(i == 5) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " killed " + boldify(monotone(player)) + " with " + weap + ".");
            return;
        }
        else if(i == 6) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " eliminated " + boldify(monotone(player)) + " using " + weap + ". No mercy!");
            return;
        }
        else if(i == 7) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " crushed " + boldify(monotone(player)) + " with a lethal " + weap + "!");
            return;
        }
        else if(i == 8) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " swiped " + boldify(monotone(player)) + " with their " + weap + ".");
            return;
        }
        else if(i == 9) {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " finished " + boldify(monotone(player)) + " with their " + weap + ". Talk about skill!");
            return;
        }
        else {
            webhookMessage(level.notifierWebhook, boldify(monotone(eAttacker)) + " obliterated " + boldify(monotone(player)) + " using " + weap + ".");
            return;
        }
    }//*/
}

_weapName(sWeapon)
{
    switch(sWeapon)
    {
        case "kar98k_mp":
            return boldify("Kar98k");
            break;
        case "kar98k_sniper_mp":
            return boldify("Scoped Kar98k");
            break;
        case "springfield_mp":
            return boldify("Springfield");
            break;
        case "mp40_mp":
            return boldify("MP40");
            break;
        case "mp44_mp":
            return boldify("MP44");
            break;
        case "thompson_mp":
            return boldify("Thompson");
            break;
        case "m1garand_mp":
            return boldify("M1 Garand");
            break;
        case "m1carbine_mp":
            return boldify("M1A1 Carbine");
            break;
        case "bar_mp":
            return boldify("BAR");
            break;
        case "mosin_nagant_mp":
            return boldify("Nagant");
            break;
        case "ppsh_mp":
            return boldify("PPSH");
            break;
        case "mosin_nagant_sniper_mp":
            return boldify("Scoped Nagant");
            break;
        case "sten_mp":
            return boldify("Sten");
            break;
        case "bren_mp":
            return boldify("Bren");
            break;
        case "enfield_mp":
            return boldify("Lee Enfield");
            break;
        case "luger_mp":
            return boldify("Luger");
            break;
        case "colt_mp":
            return boldify("Colt");
            break;
        default:
            return boldify("Mysterious Weapon");
            break;
    }
}

boldify(str)
{
	return "**" + str + "**";
}