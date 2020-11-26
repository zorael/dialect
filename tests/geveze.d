import dialect;
import lu.conv;
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
        server.address = "irc.geveze.org";
        server.daemon = IRCServer.Daemon.unreal;
        server.network = "Geveze";
        server.daemonstring = "unreal";
        server.aModes = "eIbq";
        server.bModes = "k";
        server.cModes = "flj";
        server.dModes = "CFLMPQScgimnprstz";
        server.prefixchars = ['v':'+', 'o':'@'];
        server.prefixes = "ov";
    }

    parser.typenums = typenumsOf(parser.server.daemon);

    {
        immutable event = parser.toIRCEvent(":irc.geveze.org 001 kameloso :Welcome to the Geveze IRC Network kameloso!kameloso@194.117.188.126");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_WELCOME), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.geveze.org"), sender.address);
            assert((target.nickname == "kameloso"), target.nickname);
            assert((content == "Welcome to the Geveze IRC Network kameloso!kameloso@194.117.188.126"), content);
            assert((num == 1), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":irc.geveze.org 002 kameloso :Your host is irc.geveze.org, running version Unreal3.2.8.1");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_YOURHOST), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.geveze.org"), sender.address);
            assert((target.nickname == "kameloso"), target.nickname);
            assert((content == "Your host is irc.geveze.org, running version Unreal3.2.8.1"), content);
            assert((num == 2), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":irc.geveze.org 003 kameloso :This server was created Fri Sep 13 2019 at 13:18:00 +03");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_CREATED), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.geveze.org"), sender.address);
            assert((target.nickname == "kameloso"), target.nickname);
            assert((content == "This server was created Fri Sep 13 2019 at 13:18:00 +03"), content);
            assert((num == 3), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":irc.geveze.org 004 kameloso irc.geveze.org Unreal3.2.8.1 iowghraAsORTVSxUXNClWqBzdHtGpQD lvhopsmntikrRcaqOALQbSeIKVfMCuzNTGjZ");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_MYINFO), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.geveze.org"), sender.address);
            assert((content == "iowghraAsORTVSxUXNClWqBzdHtGpQD lvhopsmntikrRcaqOALQbSeIKVfMCuzNTGjZ"), content);
            assert((aux == "Unreal3.2.8.1"), aux);
            assert((num == 4), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.daemonstring == "Unreal3.2.8.1"), server.daemonstring);
    }

    {
        immutable event = parser.toIRCEvent(":irc.geveze.org 005 kameloso CMDS=KNOCK,MAP,DCCALLOW,xUSERIPx UHNAMES NAMESX SAFELIST HCN MAXCHANNELS=24 CHANLIMIT=#:24 MAXLIST=b:1000,e:1000,I:1000 NICKLEN=30 CHANNELLEN=32 TOPICLEN=307 KICKLEN=307 AWAYLEN=307 :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.geveze.org"), sender.address);
            assert((content == "CMDS=KNOCK,MAP,DCCALLOW,xUSERIPx UHNAMES NAMESX SAFELIST HCN MAXCHANNELS=24 CHANLIMIT=#:24 MAXLIST=b:1000,e:1000,I:1000 NICKLEN=30 CHANNELLEN=32 TOPICLEN=307 KICKLEN=307 AWAYLEN=307"), content);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.maxNickLength == 30), server.maxNickLength.to!string);
        assert((server.maxChannelLength == 32), server.maxChannelLength.to!string);
        assert((server.supports == "CMDS=KNOCK,MAP,DCCALLOW,xUSERIPx UHNAMES NAMESX SAFELIST HCN MAXCHANNELS=24 CHANLIMIT=#:24 MAXLIST=b:1000,e:1000,I:1000 NICKLEN=30 CHANNELLEN=32 TOPICLEN=307 KICKLEN=307 AWAYLEN=307"), server.supports);
    }

    {
        immutable event = parser.toIRCEvent(":irc.geveze.org 005 kameloso MAXTARGETS=20 WALLCHOPS WATCH=128 WATCHOPTS=A SILENCE=15 MODES=12 CHANTYPES=# PREFIX=(qaohv)~&@%+ CHANMODES=beI,kfL,lj,psmntirRcOAQKVCuzNSMTGZ NETWORK=Geveze CASEMAPPING=ascii EXTBAN=~,cqnrT ELIST=MNUCT :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.geveze.org"), sender.address);
            assert((content == "MAXTARGETS=20 WALLCHOPS WATCH=128 WATCHOPTS=A SILENCE=15 MODES=12 CHANTYPES=# PREFIX=(qaohv)~&@%+ CHANMODES=beI,kfL,lj,psmntirRcOAQKVCuzNSMTGZ NETWORK=Geveze CASEMAPPING=ascii EXTBAN=~,cqnrT ELIST=MNUCT"), content);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.aModes == "beI"), server.aModes);
        assert((server.bModes == "kfL"), server.bModes);
        assert((server.cModes == "lj"), server.cModes);
        assert((server.dModes == "psmntirRcOAQKVCuzNSMTGZ"), server.dModes);
        assert((server.prefixes == "qaohv"), server.prefixes);
        assert((server.extbanPrefix == '~'), server.extbanPrefix.to!string);
        assert((server.extbanTypes == "cqnrT"), server.extbanTypes);
        assert((server.supports == "CMDS=KNOCK,MAP,DCCALLOW,xUSERIPx UHNAMES NAMESX SAFELIST HCN MAXCHANNELS=24 CHANLIMIT=#:24 MAXLIST=b:1000,e:1000,I:1000 NICKLEN=30 CHANNELLEN=32 TOPICLEN=307 KICKLEN=307 AWAYLEN=307 MAXTARGETS=20 WALLCHOPS WATCH=128 WATCHOPTS=A SILENCE=15 MODES=12 CHANTYPES=# PREFIX=(qaohv)~&@%+ CHANMODES=beI,kfL,lj,psmntirRcOAQKVCuzNSMTGZ NETWORK=Geveze CASEMAPPING=ascii EXTBAN=~,cqnrT ELIST=MNUCT"), server.supports);
    }

    {
        immutable event = parser.toIRCEvent(":irc.geveze.org 005 kameloso STATUSMSG=~&@%+ EXCEPTS INVEX :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.geveze.org"), sender.address);
            assert((content == "STATUSMSG=~&@%+ EXCEPTS INVEX"), content);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.supports == "CMDS=KNOCK,MAP,DCCALLOW,xUSERIPx UHNAMES NAMESX SAFELIST HCN MAXCHANNELS=24 CHANLIMIT=#:24 MAXLIST=b:1000,e:1000,I:1000 NICKLEN=30 CHANNELLEN=32 TOPICLEN=307 KICKLEN=307 AWAYLEN=307 MAXTARGETS=20 WALLCHOPS WATCH=128 WATCHOPTS=A SILENCE=15 MODES=12 CHANTYPES=# PREFIX=(qaohv)~&@%+ CHANMODES=beI,kfL,lj,psmntirRcOAQKVCuzNSMTGZ NETWORK=Geveze CASEMAPPING=ascii EXTBAN=~,cqnrT ELIST=MNUCT STATUSMSG=~&@%+ EXCEPTS INVEX"), server.supports);
    }

    {
        immutable event = parser.toIRCEvent(":Geveze PRIVMSG kameloso  Son Guncellemeden itibaren, sunucuya giren  433917 .  Kisisiniz");
        with (event)
        {
            assert((type == IRCEvent.Type.QUERY), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "Geveze"), sender.nickname);
            assert((target.nickname == "kameloso"), target.nickname);
            assert((content == " Son Guncellemeden itibaren, sunucuya giren  433917 .  Kisisiniz"), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":Geveze PRIVMSG kameloso ");
        with (event)
        {
            assert((type == IRCEvent.Type.QUERY), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "Geveze"), sender.nickname);
            assert((target.nickname == "kameloso"), target.nickname);
        }
    }
}
