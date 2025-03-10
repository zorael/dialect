import lu.conv : Enum;
import dialect;
import std.conv : to;

unittest
{
    IRCParser parser;
    parser.client.nickname = "kameloso";  // Because we removed the default value

    {
        immutable event = parser.toIRCEvent(":underworld1.no.quakenet.org 004 kameloso underworld1.no.quakenet.org u2.10.12.10+snircd(1.3.4a) dioswkgxRXInP biklmnopstvrDcCNuMT bklov");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_MYINFO), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "underworld1.no.quakenet.org"), sender.address);
            assert((content == "dioswkgxRXInP biklmnopstvrDcCNuMT bklov"), content);
            assert((aux[0] == "u2.10.12.10+snircd(1.3.4a)"), aux[0]);
            assert((num == 4), num.to!string);
        }
    }

    /*
    server.daemon = IRCServer.Daemon.snircd;
    server.daemonstring = "u2.10.12.10+snircd(1.3.4a)";
    */

    with (parser)
    {
        assert((server.daemon == IRCServer.Daemon.snircd), Enum!(IRCServer.Daemon).toString(server.daemon));
        assert((server.daemonstring == "u2.10.12.10+snircd(1.3.4a)"), server.daemonstring);
    }

    {
        immutable event = parser.toIRCEvent(":underworld1.no.quakenet.org 005 kameloso WHOX WALLCHOPS WALLVOICES USERIP CPRIVMSG CNOTICE SILENCE=15 MODES=6 MAXCHANNELS=20 MAXBANS=45 NICKLEN=15 :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "underworld1.no.quakenet.org"), sender.address);
            assert((aux[0] == "WHOX"), aux[0]);
            assert((aux[1] == "WALLCHOPS"), aux[1]);
            assert((aux[2] == "WALLVOICES"), aux[2]);
            assert((aux[3] == "USERIP"), aux[3]);
            assert((aux[4] == "CPRIVMSG"), aux[4]);
            assert((aux[5] == "CNOTICE"), aux[5]);
            assert((aux[6] == "SILENCE=15"), aux[6]);
            assert((aux[7] == "MODES=6"), aux[7]);
            assert((aux[8] == "MAXCHANNELS=20"), aux[8]);
            assert((aux[9] == "MAXBANS=45"), aux[9]);
            assert((aux[10] == "NICKLEN=15"), aux[10]);
            assert((num == 5), num.to!string);
        }
    }


    with (parser)
    {
        assert((server.maxNickLength == 15), server.maxNickLength.to!string);
        assert((server.supports == "WHOX WALLCHOPS WALLVOICES USERIP CPRIVMSG CNOTICE SILENCE=15 MODES=6 MAXCHANNELS=20 MAXBANS=45 NICKLEN=15"), server.supports);
    }

    /*
    server.maxNickLength = 15;
    */

    with (parser)
    {
        assert((server.maxNickLength == 15), server.maxNickLength.to!string);
    }

    {
        immutable event = parser.toIRCEvent(":underworld1.no.quakenet.org 005 kameloso MAXNICKLEN=15 TOPICLEN=250 AWAYLEN=160 KICKLEN=250 CHANNELLEN=200 MAXCHANNELLEN=200 CHANTYPES=#& PREFIX=(ov)@+ STATUSMSG=@+ CHANMODES=b,k,l,imnpstrDducCNMT CASEMAPPING=rfc1459 NETWORK=QuakeNet :are supported by this server");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_ISUPPORT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "underworld1.no.quakenet.org"), sender.address);
            assert((aux[0] == "MAXNICKLEN=15"), aux[0]);
            assert((aux[1] == "TOPICLEN=250"), aux[1]);
            assert((aux[2] == "AWAYLEN=160"), aux[2]);
            assert((aux[3] == "KICKLEN=250"), aux[3]);
            assert((aux[4] == "CHANNELLEN=200"), aux[4]);
            assert((aux[5] == "MAXCHANNELLEN=200"), aux[5]);
            assert((aux[6] == "CHANTYPES=#&"), aux[6]);
            assert((aux[7] == "PREFIX=(ov)@+"), aux[7]);
            assert((aux[8] == "STATUSMSG=@+"), aux[8]);
            assert((aux[9] == "CHANMODES=b,k,l,imnpstrDducCNMT"), aux[9]);
            assert((aux[10] == "CASEMAPPING=rfc1459"), aux[10]);
            assert((aux[11] == "NETWORK=QuakeNet"), aux[11]);
            assert((num == 5), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.network == "QuakeNet"), server.network);
        assert((server.aModes == "b"), server.aModes);
        assert((server.cModes == "l"), server.cModes);
        assert((server.dModes == "imnpstrDducCNMT"), server.dModes);
        assert((server.chantypes == "#&"), server.chantypes);
        assert((server.caseMapping == IRCServer.CaseMapping.rfc1459), Enum!(IRCServer.CaseMapping).toString(server.caseMapping));
        assert((server.supports == "WHOX WALLCHOPS WALLVOICES USERIP CPRIVMSG CNOTICE SILENCE=15 MODES=6 MAXCHANNELS=20 MAXBANS=45 NICKLEN=15 MAXNICKLEN=15 TOPICLEN=250 AWAYLEN=160 KICKLEN=250 CHANNELLEN=200 MAXCHANNELLEN=200 CHANTYPES=#& PREFIX=(ov)@+ STATUSMSG=@+ CHANMODES=b,k,l,imnpstrDducCNMT CASEMAPPING=rfc1459 NETWORK=QuakeNet"), server.supports);
    }

    {
        immutable event = parser.toIRCEvent(":port80b.se.quakenet.org 221 kameloso +i");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == RPL_UMODEIS), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "port80b.se.quakenet.org"), sender.address);
            assert((aux[0] == "+i"), aux[0]);
            assert((num == 221), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":port80b.se.quakenet.org 353 kameloso = #garderoben :@kameloso");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == RPL_NAMREPLY), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "port80b.se.quakenet.org"), sender.address);
            assert((channel.name == "#garderoben"), channel.name);
            assert((content == "@kameloso"), content);
            assert((num == 353), num.to!string);
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
        server.address = "irc.quakenet.org";
        server.port = 6667;
        server.daemon = IRCServer.Daemon.snircd;
        server.network = "QuakeNet";
        server.daemonstring = "snircd";
        server.aModes = "eIbq";
        server.bModes = "k";
        server.cModes = "flj";
        server.dModes = "CFLMPQScgimnprstz";
        server.prefixchars = ['v':'+', 'o':'@'];
        server.prefixes = "ov";
    }

    parser.typenums = typenumsOf(parser.server.daemon);

    {
        immutable event = parser.toIRCEvent(":Q!TheQBot@CServe.quakenet.org NOTICE kameloso :Username or password incorrect.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_FAILURE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "Q"), sender.nickname);
            assert((sender.ident == "TheQBot"), sender.ident);
            assert((sender.address == "CServe.quakenet.org"), sender.address);
            assert((content == "Username or password incorrect."), content);
        }
    }
}
