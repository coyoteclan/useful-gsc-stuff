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
}

_load()
{
    if(isDefined(level.modmmccbycato2))
        return;
    level.modmmccbycato2 = true;

    // Example: custom commands
	commands(130, level.prefix + "register"  , ::r_register    , "Create a rank account. ["+ level.prefix + "register <name> <password>]");
	commands(131, level.prefix + "signin"  , ::r_login    , "Sign into your rank account. ["+ level.prefix + "signin <name> <password>]");
	commands(132, level.prefix + "signout"  , ::r_logout    , "Logout from your rank account. ["+ level.prefix + "signout]");
    commands(133, level.prefix + "top"  , ::r_top    , "Show the top 10 players. ["+ level.prefix + "top]");
	commands(134, level.prefix + "playerstat"  , ::r_stat    , "Shows stats of a player. ["+ level.prefix + "playerstat <name>]");
	commands(135, level.prefix + "dumpdbs"  , ::r_dumpdbs    , "Dump databases. ["+ level.prefix + "dumpdbs]");
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

message(msg)
{
    codam\_mm_commands::message(msg);
}

r_register(args)
{
	self codam\ranksys::cmd_ranked_register(args);
}

r_login(args)
{
	self codam\ranksys::cmd_ranked_login(args);
}

r_logout(args)
{
	self codam\ranksys::cmd_ranked_logout(args);
}

r_stat(args)
{
	self codam\ranksys::cmd_ranked_stat(args);
}

r_top(args)
{
	self codam\ranksys::cmd_ranked_top(args);
}

r_dumpdbs(args)
{
	self codam\ranksys::cmd_dumpdbs(args);
}
