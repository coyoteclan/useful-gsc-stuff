main(phase, register)
{
  switch(phase)
  {
    case "init": _init(register); break;
    case "load" _load(); break;
  }
}

_init(register)
{
  if (isdefined(level.thirdpmod))
    return;
  level.thirdpmod = true;
  
  [[register]]("spawnPlayer", ::thirdp, "thread");
}
_load()
{
  if (isdefined(level.thirdpmod2))
    return;
  level.thirdpmod2 = true;
}

spawnPlayer(a0,a1, a2, a3, a4, a5, a6, a7, a8, a9, b0, b1, b2, b3, b4, b5, b6, b7, b8, b9)
{
  self setClientCvar("cg_thirdperson", "0");
  self thirdperson = false;
  wait 1;
  self iPrintln(&"Double Press ^2Reload ^7 to change perspective.")
  self thread thirdp();
}

thirdp()
{
  keypress = ""; //from miscmod
  timerr = 0;
  
  for(;;)
  {
    if (isdefined(self.pers["dumbbot"]))
      return;
    if (self.sessionstate != "playing" || (isdefined(bombzone_A) && isdefined(bombzone_A.planting)) || (isdefined(bombzone_B) && isdefined(bombzone_B.planting)))
      continue;
    
    if (self useReloadPressed()){
      while(self useButtonPressed())
        wait 0.05;
      keypress += "r";
    }
    if(keypress.size > 0){
      timerr += 0.05;
      resett = false;
      
      switch(keypress){
        case "rr":
          if (self thirdperson)
            setclientcvar("cg_thirdperson", "0")
          else
            setclientcvar("cg_thirdperson", "1")
        break;
      }
      if(timerr > 0 || resett){
        timerr = 0;
        keypress = "";
      }
    }
  }
}
