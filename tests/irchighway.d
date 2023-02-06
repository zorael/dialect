import lu.conv : Enum;
import dialect;
import std.conv : to;

unittest
{
    IRCParser parser;
    parser.client.nickname = "kameloso";  // Because we removed the default value

    {
        immutable event = parser.toIRCEvent(":eggbert.ca.na.irchighway.net 004 kameloso eggbert.ca.na.irchighway.net InspIRCd-2.0 BIRSWghiorswx ACDIMNORSTabcdehiklmnopqrstvz Iabdehkloqv");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_MYINFO), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "eggbert.ca.na.irchighway.net"), sender.address);
            assert((content == "BIRSWghiorswx ACDIMNORSTabcdehiklmnopqrstvz Iabdehkloqv"), content);
            assert((aux[0] == "InspIRCd-2.0"), aux[0]);
            assert((num == 4), num.to!string);
        }
    }

    /*
    server.daemon = IRCServer.Daemon.inspircd;
    server.daemonstring = "InspIRCd-2.0";
    */

    with (parser)
    {
        assert((server.daemon == IRCServer.Daemon.inspircd), Enum!(IRCServer.Daemon).toString(server.daemon));
        assert((server.daemonstring == "InspIRCd-2.0"), server.daemonstring);
    }

    {
        immutable event = parser.toIRCEvent(":eggbert.ca.na.irchighway.net 005 kameloso AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=Ibe,k,dl,ACDMNORSTcimnprstz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU ESILENCE EXCEPTS=e EXTBAN=,ACNORSTUcjmz FNC INVEX=I :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "eggbert.ca.na.irchighway.net"), sender.address);
            assert((aux[0] == "AWAYLEN=200"), aux[0]);
            assert((aux[1] == "CALLERID=g"), aux[1]);
            assert((aux[2] == "CASEMAPPING=rfc1459"), aux[2]);
            assert((aux[3] == "CHANMODES=Ibe,k,dl,ACDMNORSTcimnprstz"), aux[3]);
            assert((aux[4] == "CHANNELLEN=64"), aux[4]);
            assert((aux[5] == "CHANTYPES=#"), aux[5]);
            assert((aux[6] == "CHARSET=ascii"), aux[6]);
            assert((aux[7] == "ELIST=MU"), aux[7]);
            assert((aux[8] == "ESILENCE"), aux[8]);
            assert((aux[9] == "EXCEPTS=e"), aux[9]);
            assert((aux[10] == "EXTBAN=,ACNORSTUcjmz"), aux[10]);
            assert((aux[11] == "FNC"), aux[11]);
            assert((aux[12] == "INVEX=I"), aux[12]);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.maxChannelLength == 64), server.maxChannelLength.to!string);
        assert((server.aModes == "Ibe"), server.aModes);
        assert((server.cModes == "dl"), server.cModes);
        assert((server.dModes == "ACDMNORSTcimnprstz"), server.dModes);
        assert((server.caseMapping == IRCServer.CaseMapping.rfc1459), Enum!(IRCServer.CaseMapping).toString(server.caseMapping));
        assert((server.extbanPrefix == '$'), server.extbanPrefix.to!string);
        assert((server.extbanTypes == "ACNORSTUcjmz"), server.extbanTypes);
        assert((server.supports == "AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=Ibe,k,dl,ACDMNORSTcimnprstz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU ESILENCE EXCEPTS=e EXTBAN=,ACNORSTUcjmz FNC INVEX=I"), server.supports);
        assert((server.exceptsChar == 'e'), server.exceptsChar.to!string);
        assert((server.invexChar == 'I'), server.invexChar.to!string);
    }

    {
        immutable event = parser.toIRCEvent(":eggbert.ca.na.irchighway.net 005 kameloso KICKLEN=255 MAP MAXBANS=60 MAXCHANNELS=30 MAXPARA=32 MAXTARGETS=20 MODES=20 NAMESX NETWORK=irchighway NICKLEN=31 PREFIX=(qaohv)~&@%+ SILENCE=32 SSL=10.0.30.4:6697 :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "eggbert.ca.na.irchighway.net"), sender.address);
            assert((aux[0] == "KICKLEN=255"), aux[0]);
            assert((aux[1] == "MAP"), aux[1]);
            assert((aux[2] == "MAXBANS=60"), aux[2]);
            assert((aux[3] == "MAXCHANNELS=30"), aux[3]);
            assert((aux[4] == "MAXPARA=32"), aux[4]);
            assert((aux[5] == "MAXTARGETS=20"), aux[5]);
            assert((aux[6] == "MODES=20"), aux[6]);
            assert((aux[7] == "NAMESX"), aux[7]);
            assert((aux[8] == "NETWORK=irchighway"), aux[8]);
            assert((aux[9] == "NICKLEN=31"), aux[9]);
            assert((aux[10] == "PREFIX=(qaohv)~&@%+"), aux[10]);
            assert((aux[11] == "SILENCE=32"), aux[11]);
            assert((aux[12] == "SSL=10.0.30.4:6697"), aux[12]);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.network == "irchighway"), server.network);
        assert((server.maxNickLength == 31), server.maxNickLength.to!string);
        assert((server.prefixes == "qaohv"), server.prefixes);
        assert((server.supports == "AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=Ibe,k,dl,ACDMNORSTcimnprstz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU ESILENCE EXCEPTS=e EXTBAN=,ACNORSTUcjmz FNC INVEX=I KICKLEN=255 MAP MAXBANS=60 MAXCHANNELS=30 MAXPARA=32 MAXTARGETS=20 MODES=20 NAMESX NETWORK=irchighway NICKLEN=31 PREFIX=(qaohv)~&@%+ SILENCE=32 SSL=10.0.30.4:6697"), server.supports);
    }

    {
        immutable event = parser.toIRCEvent(":eggbert.ca.na.irchighway.net 005 kameloso STARTTLS STATUSMSG=~&@%+ TOPICLEN=307 UHNAMES USERIP VBANLIST WALLCHOPS WALLVOICES :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "eggbert.ca.na.irchighway.net"), sender.address);
            assert((aux[0] == "STARTTLS"), aux[0]);
            assert((aux[1] == "STATUSMSG=~&@%+"), aux[1]);
            assert((aux[2] == "TOPICLEN=307"), aux[2]);
            assert((aux[3] == "UHNAMES"), aux[3]);
            assert((aux[4] == "USERIP"), aux[4]);
            assert((aux[5] == "VBANLIST"), aux[5]);
            assert((aux[6] == "WALLCHOPS"), aux[6]);
            assert((aux[7] == "WALLVOICES"), aux[7]);
            assert((num == 5), num.to!string);
        }
    }


    {
        immutable event = parser.toIRCEvent(":caliburn.pa.us.irchighway.net 042 kameloso 132AAMJT5 :your unique ID");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == RPL_YOURID), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "caliburn.pa.us.irchighway.net"), sender.address);
            assert((content == "your unique ID"), content);
            assert((aux[0] == "132AAMJT5"), aux[0]);
            assert((num == 42), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":genesis.ks.us.irchighway.net CAP 867AAF66L LS :away-notify extended-join account-notify multi-prefix sasl tls userhost-in-names");
        with (event)
        {
            assert((type == IRCEvent.Type.CAP), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "genesis.ks.us.irchighway.net"), sender.address);
            assert((content == "LS"), content);
            assert((aux[0] == "away-notify"), aux[0]);
            assert((aux[1] == "extended-join"), aux[1]);
            assert((aux[2] == "account-notify"), aux[2]);
            assert((aux[3] == "multi-prefix"), aux[3]);
            assert((aux[4] == "sasl"), aux[4]);
            assert((aux[5] == "tls"), aux[5]);
            assert((aux[6] == "userhost-in-names"), aux[6]);
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
        server.address = "irc.irchighway.net";
        server.port = 6667;
        server.daemon = IRCServer.Daemon.inspircd;
        server.network = "irchighway";
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
        immutable event = parser.toIRCEvent(":NickServ!services@services.irchighway.net NOTICE kameloso :nick, type /msg NickServ IDENTIFY password.  Otherwise,");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_CHALLENGE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "services.irchighway.net"), sender.address);
            assert((content == "nick, type /msg NickServ IDENTIFY password.  Otherwise,"), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":NickServ!services@services.irchighway.net NOTICE kameloso :Password incorrect.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_FAILURE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "services.irchighway.net"), sender.address);
            assert((content == "Password incorrect."), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":NickServ!services@services.irchighway.net NOTICE kameloso :Password accepted - you are now recognized.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_SUCCESS), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "services.irchighway.net"), sender.address);
            assert((content == "Password accepted - you are now recognized."), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":ceres.dk.eu.irchighway.net 900 kameloso kameloso!kameloso@ihw-3lt.aro.117.194.IP kameloso :You are now logged in as kameloso");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_LOGGEDIN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "ceres.dk.eu.irchighway.net"), sender.address);
            assert((target.nickname == "kameloso"), target.nickname);
            assert((target.address == "ihw-3lt.aro.117.194.IP"), target.address);
            assert((target.account == "kameloso"), target.account);
            assert((content == "You are now logged in as kameloso"), content);
            assert((num == 900), num.to!string);
        }
    }
}
