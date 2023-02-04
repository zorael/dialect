import dialect;
import lu.conv : Enum;
import std.conv : to;

unittest
{
    IRCParser parser;

    with (parser)
    {
        client.nickname = "kameloso";
        client.user = "kameloso";
        client.realName = "kameloso IRC bot";
        client.ident = "NaN";
        server.address = "irc.snoonet.org";
        server.daemon = IRCServer.Daemon.inspircd;
        server.network = "Snoonet";
        server.daemonstring = "inspircd";
        server.aModes = "eIbq";
        server.bModes = "k";
        server.cModes = "flj";
        server.dModes = "CFLMPQScgimnprstz";
        server.prefixchars = ['v':'+', 'o':'@'];
        server.prefixes = "ov";
    }

    parser.typenums = typenumsOf(parser.server.daemon);

    {
        immutable event = parser.toIRCEvent(":van-halen.snoonet.org 004 kameloso van-halen.snoonet.org InspIRCd-2.0 BHILRSTWcdghikorswx ABCDFHIJKLMNOPQRSTWXYZbcdefghijklmnoprstuvwxz FHIJLWXYZbdefghjklovwx");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_MYINFO), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "van-halen.snoonet.org"), sender.address);
            assert((content == "BHILRSTWcdghikorswx ABCDFHIJKLMNOPQRSTWXYZbcdefghijklmnoprstuvwxz FHIJLWXYZbdefghjklovwx"), content);
            assert((auxstrings[0] == "InspIRCd-2.0"), auxstrings[0]);
            assert((num == 4), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.daemonstring == "InspIRCd-2.0"), server.daemonstring);
    }

    {
        immutable event = parser.toIRCEvent(":van-halen.snoonet.org 005 kameloso AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=IXZbegw,k,FHJLWdfjlx,ABCDKMNOPQRSTcimnprstuz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU ESILENCE EXCEPTS=e EXTBAN=,ABCNOQRSTUcjmprsz FNC INVEX=I :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "van-halen.snoonet.org"), sender.address);
            assert((content == "AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=IXZbegw,k,FHJLWdfjlx,ABCDKMNOPQRSTcimnprstuz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU ESILENCE EXCEPTS=e EXTBAN=,ABCNOQRSTUcjmprsz FNC INVEX=I"), content);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.maxChannelLength == 64), server.maxChannelLength.to!string);
        assert((server.aModes == "IXZbegw"), server.aModes);
        assert((server.cModes == "FHJLWdfjlx"), server.cModes);
        assert((server.dModes == "ABCDKMNOPQRSTcimnprstuz"), server.dModes);
        assert((server.caseMapping == IRCServer.CaseMapping.rfc1459), Enum!(IRCServer.CaseMapping).toString(server.caseMapping));
        assert((server.extbanTypes == "ABCNOQRSTUcjmprsz"), server.extbanTypes);
        assert((server.supports == "AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=IXZbegw,k,FHJLWdfjlx,ABCDKMNOPQRSTcimnprstuz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU ESILENCE EXCEPTS=e EXTBAN=,ABCNOQRSTUcjmprsz FNC INVEX=I"), server.supports);
    }

    {
        immutable event = parser.toIRCEvent(":van-halen.snoonet.org 005 kameloso KICKLEN=255 MAP MAXBANS=60 MAXCHANNELS=200 MAXPARA=32 MAXTARGETS=20 MODES=50 NAMESX NETWORK=Snoonet NICKLEN=27 OPERLOG PREFIX=(Yohv)!@%+ REMOVE :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "van-halen.snoonet.org"), sender.address);
            assert((content == "KICKLEN=255 MAP MAXBANS=60 MAXCHANNELS=200 MAXPARA=32 MAXTARGETS=20 MODES=50 NAMESX NETWORK=Snoonet NICKLEN=27 OPERLOG PREFIX=(Yohv)!@%+ REMOVE"), content);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.maxNickLength == 27), server.maxNickLength.to!string);
        assert((server.prefixes == "Yohv"), server.prefixes);
        assert((server.supports == "AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=IXZbegw,k,FHJLWdfjlx,ABCDKMNOPQRSTcimnprstuz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU ESILENCE EXCEPTS=e EXTBAN=,ABCNOQRSTUcjmprsz FNC INVEX=I KICKLEN=255 MAP MAXBANS=60 MAXCHANNELS=200 MAXPARA=32 MAXTARGETS=20 MODES=50 NAMESX NETWORK=Snoonet NICKLEN=27 OPERLOG PREFIX=(Yohv)!@%+ REMOVE"), server.supports);
    }

    {
        immutable event = parser.toIRCEvent(":van-halen.snoonet.org 005 kameloso SECURELIST SILENCE=32 SSL=[::]:6697 STATUSMSG=!@%+ TOPICLEN=1000 UHNAMES USERIP VBANLIST WALLCHOPS WALLVOICES WATCH=64 :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "van-halen.snoonet.org"), sender.address);
            assert((content == "SECURELIST SILENCE=32 SSL=[::]:6697 STATUSMSG=!@%+ TOPICLEN=1000 UHNAMES USERIP VBANLIST WALLCHOPS WALLVOICES WATCH=64"), content);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.supports == "AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=IXZbegw,k,FHJLWdfjlx,ABCDKMNOPQRSTcimnprstuz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU ESILENCE EXCEPTS=e EXTBAN=,ABCNOQRSTUcjmprsz FNC INVEX=I KICKLEN=255 MAP MAXBANS=60 MAXCHANNELS=200 MAXPARA=32 MAXTARGETS=20 MODES=50 NAMESX NETWORK=Snoonet NICKLEN=27 OPERLOG PREFIX=(Yohv)!@%+ REMOVE SECURELIST SILENCE=32 SSL=[::]:6697 STATUSMSG=!@%+ TOPICLEN=1000 UHNAMES USERIP VBANLIST WALLCHOPS WALLVOICES WATCH=64"), server.supports);
    }

    {
        immutable event = parser.toIRCEvent(":van-halen.snoonet.org 042 kameloso 1VHANCEH8 :your unique ID");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_YOURID), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "van-halen.snoonet.org"), sender.address);
            assert((content == "your unique ID"), content);
            assert((auxstrings[0] == "1VHANCEH8"), auxstrings[0]);
            assert((num == 42), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":van-halen.snoonet.org 324 kameloso #garderoben123 +CFTfjntx 5:60 30:5 5:1 10:5");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_CHANNELMODEIS), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "van-halen.snoonet.org"), sender.address);
            assert((channel == "#garderoben123"), channel);
            assert((content == "5:60 30:5 5:1 10:5"), content);
            assert((auxstrings[0] == "+CFTfjntx"), auxstrings[0]);
            assert((num == 324), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":van-halen.snoonet.org 961 kameloso #garderoben123 +noctcp +nickflood 5:60 +nonotice +flood 30:5 +joinflood 5:1 +noextmsg +topiclock +globalflood 10:5");
        with (event)
        {
            assert((type == IRCEvent.Type.MODELIST), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "van-halen.snoonet.org"), sender.address);
            assert((channel == "#garderoben123"), channel);
            assert((target.nickname == "kameloso"), target.nickname);
            assert((content == "+noctcp"), content);
            assert((auxstrings[0] == "+nickflood 5:60 +nonotice +flood 30:5 +joinflood 5:1 +noextmsg +topiclock +globalflood 10:5"), auxstrings[0]);
            assert((num == 961), num.to!string);
        }
    }
}
