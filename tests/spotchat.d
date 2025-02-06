import lu.conv : Enum;
import dialect;
import std.conv : to;

unittest
{
    IRCParser parser;
    parser.client.nickname = "kameloso";  // Because we removed the default value

    {
        immutable event = parser.toIRCEvent(":medusa.us.SpotChat.org 004 kameloso medusa.us.SpotChat.org InspIRCd-2.0 BHIRSWcdghikorswx ACIJKMNOPQRSTYabceghiklmnopqrstvz IJYabeghkloqv");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_MYINFO), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "medusa.us.SpotChat.org"), sender.address);
            assert((content == "BHIRSWcdghikorswx ACIJKMNOPQRSTYabceghiklmnopqrstvz IJYabeghkloqv"), content);
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
        immutable event = parser.toIRCEvent(":medusa.us.SpotChat.org 005 kameloso AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=Ibeg,k,Jl,ACKMNOPQRSTcimnprstz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU EXCEPTS=e EXTBAN=,ACNOQRSTUcmz FNC INVEX=I KICKLEN=255 :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "medusa.us.SpotChat.org"), sender.address);
            assert((aux[0] == "AWAYLEN=200"), aux[0]);
            assert((aux[1] == "CALLERID=g"), aux[1]);
            assert((aux[2] == "CASEMAPPING=rfc1459"), aux[2]);
            assert((aux[3] == "CHANMODES=Ibeg,k,Jl,ACKMNOPQRSTcimnprstz"), aux[3]);
            assert((aux[4] == "CHANNELLEN=64"), aux[4]);
            assert((aux[5] == "CHANTYPES=#"), aux[5]);
            assert((aux[6] == "CHARSET=ascii"), aux[6]);
            assert((aux[7] == "ELIST=MU"), aux[7]);
            assert((aux[8] == "EXCEPTS=e"), aux[8]);
            assert((aux[9] == "EXTBAN=,ACNOQRSTUcmz"), aux[9]);
            assert((aux[10] == "FNC"), aux[10]);
            assert((aux[11] == "INVEX=I"), aux[11]);
            assert((aux[12] == "KICKLEN=255"), aux[12]);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.maxChannelLength == 64), server.maxChannelLength.to!string);
        assert((server.aModes == "Ibeg"), server.aModes);
        assert((server.cModes == "Jl"), server.cModes);
        assert((server.dModes == "ACKMNOPQRSTcimnprstz"), server.dModes);
        assert((server.caseMapping == IRCServer.CaseMapping.rfc1459), Enum!(IRCServer.CaseMapping).toString(server.caseMapping));
        assert((server.extbanPrefix == '$'), server.extbanPrefix.to!string);
        assert((server.extbanTypes == "ACNOQRSTUcmz"), server.extbanTypes);
        assert((server.exceptsChar == 'e'), server.exceptsChar.to!string);
        assert((server.invexChar == 'I'), server.invexChar.to!string);
    }

    {
        immutable event = parser.toIRCEvent(":medusa.us.SpotChat.org 005 kameloso MAP MAXBANS=60 MAXCHANNELS=20 MAXPARA=32 MAXTARGETS=20 MODES=20 NAMESX NETWORK=SpotChat NICKLEN=31 OVERRIDE PREFIX=(Yqaohv)!~&@%+ REMOVE SECURELIST :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "medusa.us.SpotChat.org"), sender.address);
            assert((aux[0] == "MAP"), aux[0]);
            assert((aux[1] == "MAXBANS=60"), aux[1]);
            assert((aux[2] == "MAXCHANNELS=20"), aux[2]);
            assert((aux[3] == "MAXPARA=32"), aux[3]);
            assert((aux[4] == "MAXTARGETS=20"), aux[4]);
            assert((aux[5] == "MODES=20"), aux[5]);
            assert((aux[6] == "NAMESX"), aux[6]);
            assert((aux[7] == "NETWORK=SpotChat"), aux[7]);
            assert((aux[8] == "NICKLEN=31"), aux[8]);
            assert((aux[9] == "OVERRIDE"), aux[9]);
            assert((aux[10] == "PREFIX=(Yqaohv)!~&@%+"), aux[10]);
            assert((aux[11] == "REMOVE"), aux[11]);
            assert((aux[12] == "SECURELIST"), aux[12]);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.network == "SpotChat"), server.network);
        assert((server.maxNickLength == 31), server.maxNickLength.to!string);
        assert((server.prefixes == "Yqaohv"), server.prefixes);
        assert((server.supports == "AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=Ibeg,k,Jl,ACKMNOPQRSTcimnprstz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU EXCEPTS=e EXTBAN=,ACNOQRSTUcmz FNC INVEX=I KICKLEN=255 MAP MAXBANS=60 MAXCHANNELS=20 MAXPARA=32 MAXTARGETS=20 MODES=20 NAMESX NETWORK=SpotChat NICKLEN=31 OVERRIDE PREFIX=(Yqaohv)!~&@%+ REMOVE SECURELIST"), server.supports);
    }

    {
        immutable event = parser.toIRCEvent(":medusa.us.SpotChat.org 005 kameloso SSL=64.57.93.14:6697 STARTTLS STATUSMSG=!~&@%+ TOPICLEN=307 UHNAMES VBANLIST WALLCHOPS WALLVOICES WATCH=32 :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "medusa.us.SpotChat.org"), sender.address);
            assert((aux[0] == "SSL=64.57.93.14:6697"), aux[0]);
            assert((aux[1] == "STARTTLS"), aux[1]);
            assert((aux[2] == "STATUSMSG=!~&@%+"), aux[2]);
            assert((aux[3] == "TOPICLEN=307"), aux[3]);
            assert((aux[4] == "UHNAMES"), aux[4]);
            assert((aux[5] == "VBANLIST"), aux[5]);
            assert((aux[6] == "WALLCHOPS"), aux[6]);
            assert((aux[7] == "WALLVOICES"), aux[7]);
            assert((aux[8] == "WATCH=32"), aux[8]);
            assert((num == 5), num.to!string);
        }
    }

    {
        immutable event = parser.toIRCEvent(":lamia.uk.SpotChat.org 926 kameloso #stuffwecantdiscuss :Channel #stuffwecantdiscuss is forbidden: This channel is closed by request of the channel operators.");
        with (event)
        {
            assert((type == IRCEvent.Type.CHANNELFORBIDDEN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "lamia.uk.SpotChat.org"), sender.address);
            assert((channel.name == "#stuffwecantdiscuss"), channel.name);
            assert((content == "Channel #stuffwecantdiscuss is forbidden: This channel is closed by request of the channel operators."), content);
            assert((num == 926), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":lamia.ca.SpotChat.org 940 kameloso #garderoben :End of channel spamfilter list");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == ENDOFSPAMFILTERLIST), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "lamia.ca.SpotChat.org"), sender.address);
            assert((channel.name == "#garderoben"), channel.name);
            //assert((target.nickname == "kameloso"), target.nickname);
            assert((content == "End of channel spamfilter list"), content);
            assert((num == 940), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":lamia.ca.SpotChat.org 221 kameloso :+ix");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == RPL_UMODEIS), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "lamia.ca.SpotChat.org"), sender.address);
            assert((aux[0] == "+ix"), aux[0]);
            assert((num == 221), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":Halcy0n!~Halcy0n@SpotChat-rauo6p.dyn.suddenlink.net AWAY :I'm busy");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == AWAY), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "Halcy0n"), sender.nickname);
            assert((sender.ident == "~Halcy0n"), sender.ident);
            assert((sender.address == "SpotChat-rauo6p.dyn.suddenlink.net"), sender.address);
            assert((content == "I'm busy"), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":Halcy0n!~Halcy0n@SpotChat-rauo6p.dyn.suddenlink.net AWAY");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == BACK), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "Halcy0n"), sender.nickname);
            assert((sender.ident == "~Halcy0n"), sender.ident);
            assert((sender.address == "SpotChat-rauo6p.dyn.suddenlink.net"), sender.address);
        }
    }
}


unittest
{
    IRCParser parser;
    parser.client.nickname = "kameloso";  // Because we removed the default value

    with (parser)
    {
        server.daemon = IRCServer.Daemon.inspircd;
        server.network = "SpotChat";
        server.daemonstring = "inspircd";
    }

    {
        immutable event = parser.toIRCEvent(":medusa.us.SpotChat.org 005 kameloso AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=Ibeg,k,Jl,ACKMNOPQRSTcimnprstz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU EXCEPTS=e EXTBAN=,ACNOQRSTUcmz FNC INVEX=I KICKLEN=255 :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "medusa.us.SpotChat.org"), sender.address);
            assert((aux[0] == "AWAYLEN=200"), aux[0]);
            assert((aux[1] == "CALLERID=g"), aux[1]);
            assert((aux[2] == "CASEMAPPING=rfc1459"), aux[2]);
            assert((aux[3] == "CHANMODES=Ibeg,k,Jl,ACKMNOPQRSTcimnprstz"), aux[3]);
            assert((aux[4] == "CHANNELLEN=64"), aux[4]);
            assert((aux[5] == "CHANTYPES=#"), aux[5]);
            assert((aux[6] == "CHARSET=ascii"), aux[6]);
            assert((aux[7] == "ELIST=MU"), aux[7]);
            assert((aux[8] == "EXCEPTS=e"), aux[8]);
            assert((aux[9] == "EXTBAN=,ACNOQRSTUcmz"), aux[9]);
            assert((aux[10] == "FNC"), aux[10]);
            assert((aux[11] == "INVEX=I"), aux[11]);
            assert((aux[12] == "KICKLEN=255"), aux[12]);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.maxChannelLength == 64), server.maxChannelLength.to!string);
        assert((server.aModes == "Ibeg"), server.aModes);
        assert((server.cModes == "Jl"), server.cModes);
        assert((server.dModes == "ACKMNOPQRSTcimnprstz"), server.dModes);
        assert((server.caseMapping == IRCServer.CaseMapping.rfc1459), Enum!(IRCServer.CaseMapping).toString(server.caseMapping));
        assert((server.extbanTypes == "ACNOQRSTUcmz"), server.extbanTypes);
        assert((server.supports == "AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=Ibeg,k,Jl,ACKMNOPQRSTcimnprstz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU EXCEPTS=e EXTBAN=,ACNOQRSTUcmz FNC INVEX=I KICKLEN=255"), server.supports);
    }
}
