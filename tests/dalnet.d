import dialect;
import lu.conv;

unittest
{
    IRCParser parser;

    with (parser)
    {
        client.nickname = "kameloso";
        client.user = "kameloso";
        client.ident = "NaN";
        client.realName = "kameloso IRC bot";
        server.address = "irc.dal.net";
        server.port = 6667;
        server.daemon = IRCServer.Daemon.bahamut;
        server.network = "DALnet";
        server.daemonstring = "bahamut";
        server.aModes = "eIbq";
        server.bModes = "k";
        server.cModes = "flj";
        server.dModes = "CFLMPQScgimnprstz";
        server.prefixchars = ['v':'+', 'o':'@'];
        server.prefixes = "ov";
    }

    parser.typenums = typenumsOf(parser.server.daemon);

    {
        immutable event = parser.toIRCEvent(":NickServ!service@dal.net NOTICE kameloso :This nick is owned by someone else. Please choose another.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_CHALLENGE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "service"), sender.ident);
            assert((sender.address == "dal.net"), sender.address);
            assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((content == "This nick is owned by someone else. Please choose another."), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":NickServ!service@dal.net NOTICE kameloso :The password supplied for kameloso is incorrect.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_FAILURE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "service"), sender.ident);
            assert((sender.address == "dal.net"), sender.address);
            assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((content == "The password supplied for kameloso is incorrect."), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":NickServ!service@dal.net NOTICE kameloso :Password accepted for kameloso.");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_LOGGEDIN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "service"), sender.ident);
            assert((sender.address == "dal.net"), sender.address);
            assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((content == "Password accepted for kameloso."), content);
        }
    }
}
