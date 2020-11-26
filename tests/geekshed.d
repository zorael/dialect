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
        server.address = "irc.geekshed.net";
        server.port = 6667;
        server.daemon = IRCServer.Daemon.unreal;
        server.network = "GeekShed";
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
        immutable event = parser.toIRCEvent(":NickServ!services@geekshed.net NOTICE kameloso :nick, type /msg NickServ IDENTIFY password.  Otherwise,");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_CHALLENGE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "geekshed.net"), sender.address);
            assert((content == "nick, type /msg NickServ IDENTIFY password.  Otherwise,"), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":NickServ!services@geekshed.net NOTICE kameloso :Password incorrect.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_FAILURE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "geekshed.net"), sender.address);
            assert((content == "Password incorrect."), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":NickServ!services@geekshed.net NOTICE kameloso :Password accepted - you are now recognized.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_SUCCESS), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "geekshed.net"), sender.address);
            assert((content == "Password accepted - you are now recognized."), content);
        }
    }
}
