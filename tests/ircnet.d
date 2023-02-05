import lu.conv : Enum;
import dialect;
import std.conv : to;

unittest
{
    IRCParser parser;
    parser.client.nickname = "kameloso";  // Because we removed the default value

    {
        immutable event = parser.toIRCEvent(":irc.nlnog.net 004 kameloso irc.nlnog.net 2.11.2p3 aoOirw abeiIklmnoOpqrRstv");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_MYINFO), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.nlnog.net"), sender.address);
            assert((content == "aoOirw abeiIklmnoOpqrRstv"), content);
            assert((aux[0] == "2.11.2p3"), aux[0]);
            assert((num == 4), num.to!string);
        }
    }

    /*
    server.daemon = IRCServer.Daemon.unknown;
    server.daemonstring = "2.11.2p3";
    */

    with (parser)
    {
        assert((server.daemon == IRCServer.Daemon.unknown), Enum!(IRCServer.Daemon).toString(server.daemon));
        assert((server.daemonstring == "2.11.2p3"), server.daemonstring);
    }

    /+{
        immutable event = parser.toIRCEvent(":irc.nlnog.net 005 kameloso RFC2812 PREFIX=(ov)@+ CHANTYPES=#&!+ MODES=3 CHANLIMIT=#&!+:42 NICKLEN=15 TOPICLEN=255 KICKLEN=255 MAXLIST=beIR:64 CHANNELLEN=50 IDCHAN=!:5 CHANMODES=beIR,k,l,imnpstaqr :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.nlnog.net"), sender.address);
            assert((content == "RFC2812 PREFIX=(ov)@+ CHANTYPES=#&!+ MODES=3 CHANLIMIT=#&!+:42 NICKLEN=15 TOPICLEN=255 KICKLEN=255 MAXLIST=beIR:64 CHANNELLEN=50 IDCHAN=!:5 CHANMODES=beIR,k,l,imnpstaqr"), content);
            assert((num == 5), num.to!string);
        }
    }

    /*
    server.maxNickLength = 15;
    server.maxChannelLength = 50;
    server.aModes = "beIR";
    server.cModes = "l";
    server.dModes = "imnpstaqr";
    server.chantypes = "#&!+";
    */

    with (parser)
    {
        assert((server.maxNickLength == 15), server.maxNickLength.to!string);
        assert((server.maxChannelLength == 50), server.maxChannelLength.to!string);
        assert((server.aModes == "beIR"), server.aModes);
        assert((server.cModes == "l"), server.cModes);
        assert((server.dModes == "imnpstaqr"), server.dModes);
        assert((server.chantypes == "#&!+"), server.chantypes);
    }+/

    {
        immutable event = parser.toIRCEvent(":irc.nlnog.net 005 kameloso RFC2812 PREFIX=(ov)@+ CHANTYPES=#&!+ MODES=3 CHANLIMIT=#&!+:42 NICKLEN=15 TOPICLEN=255 KICKLEN=255 MAXLIST=beIR:64 CHANNELLEN=50 IDCHAN=!:5 CHANMODES=beIR,k,l,imnpstaqr :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.nlnog.net"), sender.address);
            assert((aux == ["RFC2812", "PREFIX=(ov)@+", "CHANTYPES=#&!+", "MODES=3", "CHANLIMIT=#&!+:42", "NICKLEN=15", "TOPICLEN=255", "KICKLEN=255", "MAXLIST=beIR:64", "CHANNELLEN=50", "IDCHAN=!:5", "CHANMODES=beIR,k,l,imnpstaqr", "", "", "", ""]), aux.to!string);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.maxNickLength == 15), server.maxNickLength.to!string);
        assert((server.maxChannelLength == 50), server.maxChannelLength.to!string);
        assert((server.aModes == "beIR"), server.aModes);
        assert((server.cModes == "l"), server.cModes);
        assert((server.dModes == "imnpstaqr"), server.dModes);
        assert((server.chantypes == "#&!+"), server.chantypes);
        assert((server.supports == "RFC2812 PREFIX=(ov)@+ CHANTYPES=#&!+ MODES=3 CHANLIMIT=#&!+:42 NICKLEN=15 TOPICLEN=255 KICKLEN=255 MAXLIST=beIR:64 CHANNELLEN=50 IDCHAN=!:5 CHANMODES=beIR,k,l,imnpstaqr"), server.supports);
    }

    {
        immutable event = parser.toIRCEvent(":irc.nlnog.net 005 kameloso PENALTY FNC EXCEPTS=e INVEX=I CASEMAPPING=ascii NETWORK=IRCnet :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.nlnog.net"), sender.address);
            assert((aux == ["PENALTY", "FNC", "EXCEPTS=e", "INVEX=I", "CASEMAPPING=ascii", "NETWORK=IRCnet", "", "", "", "", "", "", "", "", "", ""]), aux.to!string);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.daemon == IRCServer.Daemon.ircnet), Enum!(IRCServer.Daemon).toString(server.daemon));
        assert((server.network == "IRCnet"), server.network);
        assert((server.supports == "RFC2812 PREFIX=(ov)@+ CHANTYPES=#&!+ MODES=3 CHANLIMIT=#&!+:42 NICKLEN=15 TOPICLEN=255 KICKLEN=255 MAXLIST=beIR:64 CHANNELLEN=50 IDCHAN=!:5 CHANMODES=beIR,k,l,imnpstaqr PENALTY FNC EXCEPTS=e INVEX=I CASEMAPPING=ascii NETWORK=IRCnet"), server.supports);
        assert((server.exceptsChar == 'e'), server.exceptsChar.to!string);
        assert((server.invexChar == 'I'), server.invexChar.to!string);
    }

    {
        immutable event = parser.toIRCEvent(":irc.atw-inter.net 344 kameloso #debian.de towo!towo@littlelamb.szaf.org");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == RPL_REOPLIST), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.atw-inter.net"), sender.address);
            assert((channel == "#debian.de"), channel);
            assert((content == "towo!towo@littlelamb.szaf.org"), content);
            assert((num == 344), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":irc.atw-inter.net 345 kameloso #debian.de :End of Channel Reop List");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == RPL_ENDOFREOPLIST), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.atw-inter.net"), sender.address);
            assert((channel == "#debian.de"), channel);
            assert((content == "End of Channel Reop List"), content);
            assert((num == 345), num.to!string);
        }
    }
}
