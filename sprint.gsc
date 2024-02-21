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
	for(;;)
	    {}
}
