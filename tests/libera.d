import lu.conv : Enum;
import dialect;
import std.conv : to;

unittest
{
    IRCParser parser;

    with (parser)
    {
        client.nickname = "kameloso";
        client.user = "kameloso";
        client.realName = "kameloso IRC bot";
        client.ident = "~kameloso";
        server.address = "irc.libera.chat";
        server.daemon = IRCServer.Daemon.solanum;
        server.network = "Libera.Chat";
        server.aModes = "eIbq";
        server.bModes = "k";
        server.cModes = "flj";
        server.dModes = "CFLMPQScgimnprstuz";
        server.prefixchars = ['v':'+', 'o':'@'];
        server.prefixes = "ov";
    }

    parser.typenums = typenumsOf(parser.server.daemon);

    {
        enum input = ":silver.libera.chat 338 zorael deadmarshal 2605:6400:10:5bf:6f87:849d:f61e:2c8c :actually using host";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.RPL_WHOISACTUALLY), Enum!(IRCEvent.Type).toString(type));
            assert((num == 338), num.to!string);
            assert((sender.address == "silver.libera.chat"), sender.address);
            assert((target.nickname == "deadmarshal"), target.nickname);
            assert((content == "actually using host"), content);
            assert((aux[0] == "2605:6400:10:5bf:6f87:849d:f61e:2c8c"), aux[0]);
        }
    }
}
