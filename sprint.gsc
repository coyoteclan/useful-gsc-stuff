main( phase, register )
{
	codam\utils::debug( 0, "======== sprint/main:: |", phase, "|", register, "|" );


	switch ( phase )
	{
	  case "init":		_init( register );	 break;
	  case "load":		_load();		break;
	  case "start":	  	_start();		break;
	}
	return;
}

_init( register )
{
	codam\utils::debug( 0, "======== sprint/_init:: |", register, "|" );
	
	[[ register ]]( "PlayerConnect", ::sprint,	"thread"  );
	
	return;
}

_load()
{
	codam\utils::debug( 0, "======== sprint/_load" );
	
	return;
}

_start()
{
	codam\utils::debug( 0, "======== sprint/_start" );
	
	return;
}

sprint()
{
	self waittill("begin");
	self.Sprinting = false;
	for(;;)
	{
		wait 0.5;

		while(isAlive(self) && self.sessionstate == "playing" && self meleeButtonPressed() && self forwardButtonPressed())
		{
			self.Sprinting = true;
			wait 0.5;
		}
	}
	for(;;)
	{
		wait 0.3;
		if(self.Sprinting)
		{
			self setMoveSpeedScale(1.3);
		}
		if(!self.Sprinting)
		{
			self setMoveSpeedScale(1.0);
		}
		wait 0.3;
	}

}
