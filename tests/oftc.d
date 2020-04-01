import lu.conv : Enum;
import dialect;
import std.conv : to;

unittest
{
    IRCParser parser;
    parser.client.nickname = "kameloso";  // Because we removed the default value

    {
        immutable event = parser.toIRCEvent(":helix.oftc.net 004 kameloso helix.oftc.net hybrid-7.2.2+oftc1.7.3 CDGPRSabcdfgijklnorsuwxyz bciklmnopstvzeIMRS bkloveI");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_MYINFO), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "helix.oftc.net"), sender.address);
            assert((content == "CDGPRSabcdfgijklnorsuwxyz bciklmnopstvzeIMRS bkloveI"), content);
            assert((aux == "hybrid-7.2.2+oftc1.7.3"), aux);
            assert((num == 4), num.to!string);
        }
    }

    /*
    server.daemon = IRCServer.Daemon.hybrid;
    server.daemonstring = "hybrid-7.2.2+oftc1.7.3";
    */

    with (parser)
    {
        assert((server.daemon == IRCServer.Daemon.hybrid), Enum!(IRCServer.Daemon).toString(server.daemon));
        assert((server.daemonstring == "hybrid-7.2.2+oftc1.7.3"), server.daemonstring);
    }

    {
        immutable event = parser.toIRCEvent(":helix.oftc.net 005 kameloso CALLERID CASEMAPPING=rfc1459 DEAF=D KICKLEN=160 MODES=4 NICKLEN=30 PREFIX=(ov)@+ STATUSMSG=@+ TOPICLEN=391 NETWORK=OFTC MAXLIST=beI:100 MAXTARGETS=1 CHANTYPES=# :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "helix.oftc.net"), sender.address);
            assert((content == "CALLERID CASEMAPPING=rfc1459 DEAF=D KICKLEN=160 MODES=4 NICKLEN=30 PREFIX=(ov)@+ STATUSMSG=@+ TOPICLEN=391 NETWORK=OFTC MAXLIST=beI:100 MAXTARGETS=1 CHANTYPES=#"), content);
            assert((num == 5), num.to!string);
        }
    }

    /*
    server.network = "OFTC";
    server.maxNickLength = 30;
    server.caseMapping = IRCServer.CaseMapping.rfc1459;
    */

    with (parser)
    {
        assert((server.network == "OFTC"), server.network);
        assert((server.maxNickLength == 30), server.maxNickLength.to!string);
        assert((server.caseMapping == IRCServer.CaseMapping.rfc1459), Enum!(IRCServer.CaseMapping).toString(server.caseMapping));
    }

    {
        immutable event = parser.toIRCEvent(":helix.oftc.net 005 kameloso CHANLIMIT=#:90 CHANNELLEN=50 CHANMODES=eIqb,k,l,cimnpstzMRS AWAYLEN=160 KNOCK ELIST=CMNTU SAFELIST EXCEPTS=e INVEX=I :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "helix.oftc.net"), sender.address);
            assert((content == "CHANLIMIT=#:90 CHANNELLEN=50 CHANMODES=eIqb,k,l,cimnpstzMRS AWAYLEN=160 KNOCK ELIST=CMNTU SAFELIST EXCEPTS=e INVEX=I"), content);
            assert((num == 5), num.to!string);
        }
    }

    /*
    server.maxChannelLength = 50;
    server.aModes = "eIqb";
    server.cModes = "l";
    server.dModes = "cimnpstzMRS";
    server.exceptsChar = 'e';
    server.invexChar = 'I';
    */

    with (parser)
    {
        assert((server.maxChannelLength == 50), server.maxChannelLength.to!string);
        assert((server.aModes == "eIqb"), server.aModes);
        assert((server.cModes == "l"), server.cModes);
        assert((server.dModes == "cimnpstzMRS"), server.dModes);
        assert((server.exceptsChar == 'e'), server.exceptsChar.to!string);
        assert((server.invexChar == 'I'), server.invexChar.to!string);
    }

    {
        immutable event = parser.toIRCEvent(":helix.oftc.net 042 kameloso 4G4AAA7BH :your unique ID");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_YOURID), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "helix.oftc.net"), sender.address);
            assert((content == "your unique ID"), content);
            assert((aux == "4G4AAA7BH"), aux);
            assert((num == 42), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":kinetic.oftc.net 338 kameloso wh00nix 255.255.255.255 :actually using host");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == RPL_WHOISACTUALLY), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "kinetic.oftc.net"), sender.address);
            assert((target.nickname == "wh00nix"), target.nickname);
            assert((target.address == "255.255.255.255"), target.address);
            assert((content == "actually using host"), content);
            assert((num == 338), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":irc.oftc.net 345 kameloso #garderoben :End of Channel Quiet List");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == RPL_ENDOFQUIETLIST), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.oftc.net"), sender.address);
            assert((channel == "#garderoben"), channel);
            //assert((target.nickname == "kameloso"), target.nickname);
            assert((content == "End of Channel Quiet List"), content);
            assert((num == 345), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":irc.oftc.net 344 kameloso #garderoben harbl!snarbl@* kameloso!~NaN@194.117.188.126 1515418362");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == RPL_QUIETLIST), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.oftc.net"), sender.address);
            assert((channel == "#garderoben"), channel);
            assert((content == "harbl!snarbl@*"), content);
            assert((aux == "kameloso!~NaN@194.117.188.126"), aux);
            assert((count == 1515418362), count.to!string);
            assert((num == 344), num.to!string);
        }
    }
}

unittest
{
    IRCParser parser;

    with (parser)
    {
        client.nickname = "kameloso";
        client.user = "kameloso";
        client.ident = "NaN";
        client.realName = "kameloso IRC bot";
        server.address = "irc.oftc.net";
        server.port = 6667;
        server.daemon = IRCServer.Daemon.hybrid;
        server.network = "OFTC";
        server.daemonstring = "hybrid";
        server.aModes = "eIbq";
        server.bModes = "k";
        server.cModes = "flj";
        server.dModes = "CFLMPQScgimnprstz";
        server.prefixchars = ['v':'+', 'o':'@'];
        server.prefixes = "ov";
    }

    parser.typenums = typenumsOf(parser.server.daemon);

    {
        immutable event = parser.toIRCEvent(":NickServ!services@services.oftc.net NOTICE kameloso :This nickname is registered and protected.  If it is your nickname, you may");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_CHALLENGE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "services.oftc.net"), sender.address);
            assert((content == "This nickname is registered and protected.  If it is your nickname, you may"), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":NickServ!services@services.oftc.net NOTICE kameloso :Identify failed as kameloso.  You may have entered an incorrect password.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_FAILURE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "services.oftc.net"), sender.address);
            assert((content == "Identify failed as kameloso.  You may have entered an incorrect password."), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":NickServ!services@services.oftc.net NOTICE kameloso :You are successfully identified as kameloso.");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_LOGGEDIN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "services.oftc.net"), sender.address);
            assert((content == "You are successfully identified as kameloso."), content);
        }
    }
}
