import lu.conv : Enum;
import dialect;
import std.conv : to;

unittest
{
    IRCParser parser;
    parser.client.nickname = "kameloso";  // Because we removed the default value

    {
        immutable event = parser.toIRCEvent(":irc.run.net 004 kameloso irc.run.net 1.5.24/uk_UA.KOI8-U aboOirswx abcehiIklmnoOpqrstvz");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_MYINFO), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.run.net"), sender.address);
            assert((content == "aboOirswx abcehiIklmnoOpqrstvz"), content);
            assert((aux[0] == "1.5.24/uk_UA.KOI8-U"), aux[0]);
            assert((num == 4), num.to!string);
        }
    }

    /*
    server.daemon = IRCServer.Daemon.unknown;
    server.daemonstring = "1.5.24/uk_UA.KOI8-U";
    */

    with (parser)
    {
        assert((server.daemon == IRCServer.Daemon.unknown), Enum!(IRCServer.Daemon).toString(server.daemon));
        assert((server.daemonstring == "1.5.24/uk_UA.KOI8-U"), server.daemonstring);
    }

    {
        immutable event = parser.toIRCEvent(":irc.run.net 005 kameloso PREFIX=(ohv)@%+ CODEPAGES MODES=3 CHANTYPES=#&!+ MAXCHANNELS=20 NICKLEN=31 TOPICLEN=255 KICKLEN=255 NETWORK=RusNet CHANMODES=beI,k,l,acimnpqrstz :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.run.net"), sender.address);
            assert((aux == ["PREFIX=(ohv)@%+", "CODEPAGES", "MODES=3", "CHANTYPES=#&!+", "MAXCHANNELS=20", "NICKLEN=31", "TOPICLEN=255", "KICKLEN=255", "NETWORK=RusNet", "CHANMODES=beI,k,l,acimnpqrstz", "", "", "", "", "", ""]), aux.to!string);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.maxNickLength == 31), server.maxNickLength.to!string);
        assert((server.aModes == "beI"), server.aModes);
        assert((server.cModes == "l"), server.cModes);
        assert((server.dModes == "acimnpqrstz"), server.dModes);
        assert((server.prefixes == "ohv"), server.prefixes);
        assert((server.chantypes == "#&!+"), server.chantypes);
        assert((server.supports == "PREFIX=(ohv)@%+ CODEPAGES MODES=3 CHANTYPES=#&!+ MAXCHANNELS=20 NICKLEN=31 TOPICLEN=255 KICKLEN=255 NETWORK=RusNet CHANMODES=beI,k,l,acimnpqrstz"), server.supports);
    }

    {
        immutable event = parser.toIRCEvent(":irc.run.net 222 kameloso KOI8-U :is your charset now");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_CODEPAGE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.run.net"), sender.address);
            assert((content == "is your charset now"), content);
            assert((aux[0] == "KOI8-U"), aux[0]);
            assert((num == 222), num.to!string);
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
        server.address = "irc.run.net";
        server.port = 6667;
        server.daemon = IRCServer.Daemon.rusnet;
        server.network = "RusNet";
        server.daemonstring = "rusnet";
        server.aModes = "eIbq";
        server.bModes = "k";
        server.cModes = "flj";
        server.dModes = "CFLMPQScgimnprstz";
        server.prefixchars = ['v':'+', 'o':'@'];
        server.prefixes = "ov";
    }

    parser.typenums = typenumsOf(parser.server.daemon);

    {
        immutable event = parser.toIRCEvent(":NickServ!service@RusNet NOTICE kameloso :Password incorrect.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_FAILURE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "service"), sender.ident);
            assert((sender.address == "RusNet"), sender.address);
            assert((content == "Password incorrect."), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":NickServ!service@RusNet NOTICE kameloso :Password accepted for nick kameloso.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_SUCCESS), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "service"), sender.ident);
            assert((sender.address == "RusNet"), sender.address);
            assert((content == "Password accepted for nick kameloso."), content);
        }
    }
}
