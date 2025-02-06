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
            assert((aux[0] == "hybrid-7.2.2+oftc1.7.3"), aux[0]);
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
            assert((aux[0] == "CALLERID"), aux[0]);
            assert((aux[1] == "CASEMAPPING=rfc1459"), aux[1]);
            assert((aux[2] == "DEAF=D"), aux[2]);
            assert((aux[3] == "KICKLEN=160"), aux[3]);
            assert((aux[4] == "MODES=4"), aux[4]);
            assert((aux[5] == "NICKLEN=30"), aux[5]);
            assert((aux[6] == "PREFIX=(ov)@+"), aux[6]);
            assert((aux[7] == "STATUSMSG=@+"), aux[7]);
            assert((aux[8] == "TOPICLEN=391"), aux[8]);
            assert((aux[9] == "NETWORK=OFTC"), aux[9]);
            assert((aux[10] == "MAXLIST=beI:100"), aux[10]);
            assert((aux[11] == "MAXTARGETS=1"), aux[11]);
            assert((aux[12] == "CHANTYPES=#"), aux[12]);
            assert((num == 5), num.to!string);
        }
    }

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
            assert((aux[0] == "CHANLIMIT=#:90"), aux[0]);
            assert((aux[1] == "CHANNELLEN=50"), aux[1]);
            assert((aux[2] == "CHANMODES=eIqb,k,l,cimnpstzMRS"), aux[2]);
            assert((aux[3] == "AWAYLEN=160"), aux[3]);
            assert((aux[4] == "KNOCK"), aux[4]);
            assert((aux[5] == "ELIST=CMNTU"), aux[5]);
            assert((aux[6] == "SAFELIST"), aux[6]);
            assert((aux[7] == "EXCEPTS=e"), aux[7]);
            assert((aux[8] == "INVEX=I"), aux[8]);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.maxChannelLength == 50), server.maxChannelLength.to!string);
        assert((server.aModes == "eIqb"), server.aModes);
        assert((server.cModes == "l"), server.cModes);
        assert((server.dModes == "cimnpstzMRS"), server.dModes);
        assert((server.supports == "CALLERID CASEMAPPING=rfc1459 DEAF=D KICKLEN=160 MODES=4 NICKLEN=30 PREFIX=(ov)@+ STATUSMSG=@+ TOPICLEN=391 NETWORK=OFTC MAXLIST=beI:100 MAXTARGETS=1 CHANTYPES=# CHANLIMIT=#:90 CHANNELLEN=50 CHANMODES=eIqb,k,l,cimnpstzMRS AWAYLEN=160 KNOCK ELIST=CMNTU SAFELIST EXCEPTS=e INVEX=I"), server.supports);
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
            assert((aux[0] == "4G4AAA7BH"), aux[0]);
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
            assert((channel.name == "#garderoben"), channel.name);
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
            assert((channel.name == "#garderoben"), channel.name);
            assert((content == "harbl!snarbl@*"), content);
            assert((aux[0] == "kameloso!~NaN@194.117.188.126"), aux[0]);
            assert((count[0] == 1515418362), count[0].to!string);
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
            assert((type == IRCEvent.Type.AUTH_SUCCESS), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "services.oftc.net"), sender.address);
            assert((content == "You are successfully identified as kameloso."), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":helix.oftc.net 479 zorael|8 - :Illegal channel name");
        with (event)
        {
            assert((type == IRCEvent.Type.ERR_BADCHANNAME), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "helix.oftc.net"), sender.address);
            assert((content == "Illegal channel name"), content);
            assert((aux[0] == "-"), aux[0]);
            assert((num == 479), num.to!string);
        }
    }
}
