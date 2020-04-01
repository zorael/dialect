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
        server.address = "irc.swiftirc.net";
        server.port = 6667;
        server.daemon = IRCServer.Daemon.unreal;
        server.network = "SwiftIRC";
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
        immutable event = parser.toIRCEvent(":NickServ!services@services.host NOTICE kameloso^ :Nick kameloso^ isn't registered.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_FAILURE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "services.host"), sender.address);
            assert((content == "Nick kameloso^ isn't registered."), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":NickServ!services@services.host NOTICE kameloso^ :Password incorrect.");
        with (event)
        {
            assert((type == IRCEvent.Type.AUTH_FAILURE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "services.host"), sender.address);
            assert((content == "Password incorrect."), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":NickServ!services@services.host NOTICE kameloso^ :Password accepted - you are now recognized.");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_LOGGEDIN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "NickServ"), sender.nickname);
            assert((sender.ident == "services"), sender.ident);
            assert((sender.address == "services.host"), sender.address);
            assert((content == "Password accepted - you are now recognized."), content);
        }
    }
}
