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
            assert((aux[0] == "Unreal3.2.8.1"), aux[0]);
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
            assert((aux[0] == "CMDS=KNOCK,MAP,DCCALLOW,xUSERIPx"), aux[0]);
            assert((aux[1] == "UHNAMES"), aux[1]);
            assert((aux[2] == "NAMESX"), aux[2]);
            assert((aux[3] == "SAFELIST"), aux[3]);
            assert((aux[4] == "HCN"), aux[4]);
            assert((aux[5] == "MAXCHANNELS=24"), aux[5]);
            assert((aux[6] == "CHANLIMIT=#:24"), aux[6]);
            assert((aux[7] == "MAXLIST=b:1000,e:1000,I:1000"), aux[7]);
            assert((aux[8] == "NICKLEN=30"), aux[8]);
            assert((aux[9] == "CHANNELLEN=32"), aux[9]);
            assert((aux[10] == "TOPICLEN=307"), aux[10]);
            assert((aux[11] == "KICKLEN=307"), aux[11]);
            assert((aux[12] == "AWAYLEN=307"), aux[12]);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.maxNickLength == 30), server.maxNickLength.to!string);
        assert((server.maxChannelLength == 32), server.maxChannelLength.to!string);
        assert((server.supports == "CMDS=KNOCK,MAP,DCCALLOW,xUSERIPx UHNAMES NAMESX SAFELIST HCN MAXCHANNELS=24 CHANLIMIT=#:24 MAXLIST=b:1000,e:1000,I:1000 NICKLEN=30 CHANNELLEN=32 TOPICLEN=307 KICKLEN=307 AWAYLEN=307"), server.supports);
    }

    /*{
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
    }*/

    {
        immutable event = parser.toIRCEvent(":irc.geveze.org 005 kameloso MAXTARGETS=20 WALLCHOPS WATCH=128 WATCHOPTS=A SILENCE=15 MODES=12 CHANTYPES=# PREFIX=(qaohv)~&@%+ CHANMODES=beI,kfL,lj,psmntirRcOAQKVCuzNSMTGZ NETWORK=Geveze CASEMAPPING=ascii EXTBAN=~,cqnrT ELIST=MNUCT :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "irc.geveze.org"), sender.address);
            assert((aux[0] == "MAXTARGETS=20"), aux[0]);
            assert((aux[1] == "WALLCHOPS"), aux[1]);
            assert((aux[2] == "WATCH=128"), aux[2]);
            assert((aux[3] == "WATCHOPTS=A"), aux[3]);
            assert((aux[4] == "SILENCE=15"), aux[4]);
            assert((aux[5] == "MODES=12"), aux[5]);
            assert((aux[6] == "CHANTYPES=#"), aux[6]);
            assert((aux[7] == "PREFIX=(qaohv)~&@%+"), aux[7]);
            assert((aux[8] == "CHANMODES=beI,kfL,lj,psmntirRcOAQKVCuzNSMTGZ"), aux[8]);
            assert((aux[9] == "NETWORK=Geveze"), aux[9]);
            assert((aux[10] == "CASEMAPPING=ascii"), aux[10]);
            assert((aux[11] == "EXTBAN=~,cqnrT"), aux[11]);
            assert((aux[12] == "ELIST=MNUCT"), aux[12]);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.network == "Geveze"), server.network);
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
        assert((aux[0] == "STATUSMSG=~&@%+"), aux[0]);
        assert((aux[1] == "EXCEPTS"), aux[1]);
        assert((aux[2] == "INVEX"), aux[2]);
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
