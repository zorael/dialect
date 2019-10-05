import lu.conv : Enum;
import dialect;
import std.conv : to;

unittest
{
    IRCParser parser;
    parser.client.nickname = "kameloso";  // Because we removed the default value

    {
        immutable event = parser.toIRCEvent(":Portlane.SE.EU.GameSurge.net 004 kameloso Portlane.SE.EU.GameSurge.net u2.10.12.18(gs2) diOoswkgxnI biklmnopstvrDdRcCz bklov");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_MYINFO), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "Portlane.SE.EU.GameSurge.net"), sender.address);
            assert((content == "diOoswkgxnI biklmnopstvrDdRcCz bklov"), content);
            assert((aux == "u2.10.12.18(gs2)"), aux);
            assert((num == 4), num.to!string);
        }
    }

    /*
    server.daemon = IRCServer.Daemon.u2;
    server.daemonstring = "u2.10.12.18(gs2)";
    */

    with (parser)
    {
        assert((server.daemon == IRCServer.Daemon.u2), Enum!(IRCServer.Daemon).toString(server.daemon));
        assert((server.daemonstring == "u2.10.12.18(gs2)"), server.daemonstring);
    }

    {
        immutable event = parser.toIRCEvent(":Portlane.SE.EU.GameSurge.net 005 kameloso WHOX WALLCHOPS WALLVOICES USERIP CPRIVMSG CNOTICE SILENCE=25 MODES=6 MAXCHANNELS=75 MAXBANS=100 NICKLEN=30 :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "Portlane.SE.EU.GameSurge.net"), sender.address);
            assert((content == "WHOX WALLCHOPS WALLVOICES USERIP CPRIVMSG CNOTICE SILENCE=25 MODES=6 MAXCHANNELS=75 MAXBANS=100 NICKLEN=30"), content);
            assert((num == 5), num.to!string);
        }
    }

    /*
    server.maxNickLength = 30;
    */

    with (parser)
    {
        assert((server.maxNickLength == 30), server.maxNickLength.to!string);
    }

    {
        immutable event = parser.toIRCEvent(":Portlane.SE.EU.GameSurge.net 005 kameloso MAXNICKLEN=30 TOPICLEN=300 AWAYLEN=200 KICKLEN=300 CHANNELLEN=200 MAXCHANNELLEN=200 CHANTYPES=#& PREFIX=(ov)@+ STATUSMSG=@+ CHANMODES=b,k,l,imnpstrDdRcC CASEMAPPING=rfc1459 NETWORK=GameSurge :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "Portlane.SE.EU.GameSurge.net"), sender.address);
            assert((content == "MAXNICKLEN=30 TOPICLEN=300 AWAYLEN=200 KICKLEN=300 CHANNELLEN=200 MAXCHANNELLEN=200 CHANTYPES=#& PREFIX=(ov)@+ STATUSMSG=@+ CHANMODES=b,k,l,imnpstrDdRcC CASEMAPPING=rfc1459 NETWORK=GameSurge"), content);
            assert((num == 5), num.to!string);
        }
    }

    /*
    server.network = "GameSurge";
    server.aModes = "b";
    server.cModes = "l";
    server.dModes = "imnpstrDdRcC";
    server.chantypes = "#&";
    server.caseMapping = IRCServer.CaseMapping.rfc1459;
    */

    with (parser)
    {
        assert((server.network == "GameSurge"), server.network);
        assert((server.aModes == "b"), server.aModes);
        assert((server.cModes == "l"), server.cModes);
        assert((server.dModes == "imnpstrDdRcC"), server.dModes);
        assert((server.chantypes == "#&"), server.chantypes);
        assert((server.caseMapping == IRCServer.CaseMapping.rfc1459), Enum!(IRCServer.CaseMapping).toString(server.caseMapping));
    }

    {
        immutable event = parser.toIRCEvent(":TAL.DE.EU.GameSurge.net 396 kameloso ~NaN@1b24f4a7.243f02a4.5cd6f3e3.IP4 :is now your hidden host");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == RPL_HOSTHIDDEN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "TAL.DE.EU.GameSurge.net"), sender.address);
            assert((content == "~NaN@1b24f4a7.243f02a4.5cd6f3e3.IP4"), content);
            assert((aux == "is now your hidden host"), aux);
            assert((num == 396), num.to!string);
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
        server.address = "Portlane.SE.EU.GameSurge.net";
        server.port = 6667;
        server.daemon = IRCServer.Daemon.u2;
        server.network = "GameSurge";
        server.daemonstring = "u2";
        server.aModes = "eIbq";
        server.bModes = "k";
        server.cModes = "flj";
        server.dModes = "CFLMPQScgimnprstz";
        server.prefixchars = ['v':'+', 'o':'@'];
        server.prefixes = "ov";
    }

    parser.typenums = typenumsOf(parser.server.daemon);

    {
        immutable event = parser.toIRCEvent(":AuthServ!AuthServ@Services.GameSurge.net NOTICE kameloso :Incorrect password; please try again.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_FAILURE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "AuthServ"), sender.nickname);
            assert((sender.ident == "AuthServ"), sender.ident);
            assert((sender.address == "Services.GameSurge.net"), sender.address);
            assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((content == "Incorrect password; please try again."), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":AuthServ!AuthServ@Services.GameSurge.net NOTICE kameloso :I recognize you.");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_LOGGEDIN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "AuthServ"), sender.nickname);
            assert((sender.ident == "AuthServ"), sender.ident);
            assert((sender.address == "Services.GameSurge.net"), sender.address);
            assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((content == "I recognize you."), content);
        }
    }
}
