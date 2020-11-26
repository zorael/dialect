/++
    Interactive assert statement generation from raw IRC strings, for use in the
    source code `unittest` blocks.

    Example:

    $(CONSOLE
    $ dub run :assertgen
    (...)

    // Paste a raw event string and hit Enter to generate an assert block. Ctrl+C to exit.

    $(I @badge-info=subscriber/15;badges=subscriber/12;color=;display-name=tayk47_mom;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=tayk47_mom;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\s9d\s3e\s68\sca\s26\se9\s2a\s6e\s44\sd4\s60\s9b\s3d\saa\sb9\s4c\sad\s43\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=tayk47_mom\sis\sgifting\s1\sTier\s1\sSubs\sto\sxQcOW's\scommunity!\sThey've\sgifted\sa\stotal\sof\s4\sin\sthe\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type= :tmi.twitch.tv USERNOTICE #xqcow)

    {
        immutable event = parser.toIRCEvent("@badge-info=subscriber/15;badges=subscriber/12;color=;display-name=tayk47_mom;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=tayk47_mom;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\\s9d\\s3e\\s68\\sca\\s26\\se9\\s2a\\s6e\\s44\\sd4\\s60\\s9b\\s3d\\saa\\sb9\\s4c\\sad\\s43\\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=tayk47_mom\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sxQcOW's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s4\\sin\\sthe\\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type= :tmi.twitch.tv USERNOTICE #xqcow");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "tayk47_mom"), sender.nickname);
            assert((sender.displayName == "tayk47_mom"), sender.displayName);
            assert((sender.account == "tayk47_mom"), sender.account);
            assert((sender.badges == "subscriber/12"), sender.badges);
            assert((channel == "#xqcow"), channel);
            assert((content == "tayk47_mom is gifting 1 Tier 1 Subs to xQcOW's community! They've gifted a total of 4 in the channel!"), content);
            assert((aux == "1000"), aux);
            assert((tags == "badge-info=subscriber/15;badges=subscriber/12;color=;display-name=tayk47_mom;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=tayk47_mom;mod=0;msg-
    id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\\s9d\\s3e\\s68\\sca\\s26\\se9\\s2a\\s6e\\s44\\sd4\\s60\\s9b\\s3d\\saa\\sb9\\s4c\\sad\\s43\\s5c;msg-param-sender-cou
    nt=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=tayk47_mom\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sxQcOW's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s
    4\\sin\\sthe\\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type="), tags);
            assert((count == 1), count.to!string);
            assert((altcount == 4), altcount.to!string);
            assert((id == "d6729804-2bf3-495d-80ce-a2fe8ed00a26"), id);
        }
    }
    )

    These can be directly copy/pasted into the appropriate files in `/tests`.
    They only carry state from the events pasted before it, but the changes made
    are also expressed as asserts.

    Example:

    $(CONSOLE
    $ dub run :assertgen
    (...)

    // Paste a raw event string and hit Enter to generate an assert block. Ctrl+C to exit.

    $(I @badge-info=;badges=;color=#5F9EA0;display-name=Zorael;emote-sets=0,185411,771823,1511983;user-id=22216721;user-type= :tmi.twitch.tv GLOBALUSERSTATE)

    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=;color=#5F9EA0;display-name=Zorael;emote-sets=0,185411,771823,1511983;user-id=22216721;user-type= :tmi.twitch.tv GLOBALUSERSTATE");
        with (event)
        {
            assert((type == IRCEvent.Type.GLOBALUSERSTATE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((target.nickname == "zorael"), target.nickname);
            assert((target.displayName == "Zorael"), target.displayName);
            assert((target.class_ == IRCUser.Class.admin), Enum!(IRCUser.Class).toString(target.class_));
            assert((target.badges == "*"), target.badges);
            assert((target.colour == "5F9EA0"), target.colour);
            assert((tags == "badge-info=;badges=;color=#5F9EA0;display-name=Zorael;emote-sets=0,185411,771823,1511983;user-id=22216721;user-type="), tags);
        }
    }

    with (parser.client)
    {
        assert((displayName == "Zorael"), displayName);
    }
    )

    This makes it easy to generate tests that verify wanted side-effects
    incurred by events.
 +/
module dialect.assertgen;

version(AssertGeneration):

private:

import dialect.defs;
import lu.deltastrings : formatDeltaInto;
import std.range.primitives : isOutputRange;
import std.typecons : Flag, No, Yes;

@safe:


// formatClientAssignment
/++
    Constructs statement lines for each changed field of an
    [dialect.defs.IRCClient], including instantiating a fresh one.

    Example:
    ---
    IRCClient client;
    IRCServer server;
    Appender!(char[]) sink;

    sink.formatClientAssignment(client, server);
    ---

    Params:
        sink = Output buffer to write to.
        client = [dialect.defs.IRCClient] to simulate the assignment of.
        server = [dialect.defs.IRCServer] to simulate the assignment of.
 +/
void formatClientAssignment(Sink)(auto ref Sink sink, const IRCClient client, const IRCServer server)
if (isOutputRange!(Sink, char[]))
{
    sink.put("IRCParser parser;\n\n");
    sink.put("with (parser)\n");
    sink.put("{\n");
    sink.formatDeltaInto(IRCClient.init, client, 1, "client");
    sink.formatDeltaInto(IRCServer.init, server, 1, "server");
    sink.put('}');

    static if (!__traits(hasMember, Sink, "data"))
    {
        sink.put('\n');
    }
}

///
unittest
{
    import std.array : Appender;

    Appender!(char[]) sink;
    sink.reserve(128);

    IRCClient client;
    IRCServer server;

    with (client)
    {
        nickname = "NICKNAME";
        user = "UUUUUSER";
        server.address = "something.freenode.net";
        server.port = 6667;
        server.daemon = IRCServer.Daemon.unreal;
        server.aModes = "eIbq";
    }

    sink.formatClientAssignment(client, server);

    assert(sink.data ==
`IRCParser parser;

with (parser)
{
    client.nickname = "NICKNAME";
    client.user = "UUUUUSER";
    server.address = "something.freenode.net";
    server.port = 6667;
    server.daemon = IRCServer.Daemon.unreal;
    server.aModes = "eIbq";
}`, '\n' ~ sink.data);
}


// formatEventAssertBlock
/++
    Constructs assert statement blocks for each changed field of an
    [dialect.defs.IRCEvent].

    Example:
    ---
    IRCEvent event;
    Appender!(char[]) sink;
    sink.formatEventAssertBlock(event);
    ---

    Params:
        sink = Output buffer to write to.
        event = [dialect.defs.IRCEvent] to construct assert statements for.
 +/
void formatEventAssertBlock(Sink)(auto ref Sink sink, const IRCEvent event)
if (isOutputRange!(Sink, char[]))
{
    import lu.string : tabs;
    import std.array : replace;
    import std.format : format, formattedWrite;

    immutable raw = event.tags.length ?
        "@%s %s".format(event.tags, event.raw) : event.raw;

    immutable escaped = raw
        .replace('\\', `\\`)
        .replace('"', `\"`);

    sink.put("{\n");
    if (escaped != raw) sink.formattedWrite("%s// %s\n", 1.tabs, raw);
    sink.formattedWrite("%simmutable event = parser.toIRCEvent(\"%s\");\n", 1.tabs, escaped);
    sink.formattedWrite("%swith (event)\n", 1.tabs);
    sink.formattedWrite("%s{\n", 1.tabs);
    sink.formatDeltaInto!(Yes.asserts)(IRCEvent.init, event, 2);
    sink.formattedWrite("%s}\n", 1.tabs);
    sink.put("}");

    static if (!__traits(hasMember, Sink, "data"))
    {
        sink.put('\n');
    }
}

unittest
{
    import dialect.parsing : IRCParser;
    import lu.string : tabs;
    import std.array : Appender;
    import std.format : formattedWrite;

    Appender!(char[]) sink;
    sink.reserve(1024);

    IRCClient client;
    IRCServer server;
    auto parser = IRCParser(client, server);

    immutable event = parser.toIRCEvent(":zorael!~NaN@2001:41d0:2:80b4:: PRIVMSG #flerrp :kameloso: 8ball");

    // copy/paste the above
    sink.put("{\n");
    sink.formattedWrite("%simmutable event = parser.toIRCEvent(\"%s\");\n", 1.tabs, event.raw);
    sink.formattedWrite("%swith (event)\n", 1.tabs);
    sink.formattedWrite("%s{\n", 1.tabs);
    sink.formatDeltaInto!(Yes.asserts)(IRCEvent.init, event, 2);
    sink.formattedWrite("%s}\n", 1.tabs);
    sink.put("}");

    assert(sink.data ==
`{
    immutable event = parser.toIRCEvent(":zorael!~NaN@2001:41d0:2:80b4:: PRIVMSG #flerrp :kameloso: 8ball");
    with (event)
    {
        assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
        assert((sender.nickname == "zorael"), sender.nickname);
        assert((sender.ident == "~NaN"), sender.ident);
        assert((sender.address == "2001:41d0:2:80b4::"), sender.address);
        assert((channel == "#flerrp"), channel);
        assert((content == "kameloso: 8ball"), content);
    }
}`, '\n' ~ sink.data);
}


public:


// main
/++
    Entry point when compiling the `assertgen` dub configuration.

    Reads raw server strings from `stdin`, parses them into
    [dialect.defs.IRCEvent]s and constructs assert blocks of their contents.
 +/
version(unittest) {}
else
void main() @system
{
    import dialect.defs : IRCServer;
    import dialect.parsing : IRCParser;
    import lu.string : contains, nom, stripped, strippedLeft, strippedRight;
    import std.conv : ConvException;
    import std.range : chunks, only;
    import std.stdio : stdout, readln, write, writeln, writefln;
    import std.string : chomp;
    import std.traits : EnumMembers;
    import std.typecons : No, Yes;

    IRCParser parser;
    parser.initPostprocessors();  // Normally done in IRCParser(IRCClient) constructor

    writeln("-- Available daemons --");
    writefln("%(%(%-14s%)\n%)", EnumMembers!(IRCServer.Daemon).only.chunks(3));
    writeln();

    write("Enter daemon [optional daemon literal] (ircdseven): ");
    stdout.flush();
    string slice = readln().stripped;  // mutable so we can nom it
    immutable daemonstring = slice.nom!(Yes.inherit)(' ');
    immutable daemonLiteral = slice.length ? slice : daemonstring;

    try
    {
        import dialect.common : typenumsOf;
        import lu.conv : Enum;

        parser.server.daemon = daemonstring.length ?
            Enum!(IRCServer.Daemon).fromString(daemonstring) : IRCServer.Daemon.ircdseven;
        parser.typenums = typenumsOf(parser.server.daemon);
        parser.server.daemonstring = daemonLiteral;
    }
    catch (ConvException e)
    {
        writeln();
        writeln("-- Conversion exception caught when parsing daemon: ", e.msg);
        version(PrintStacktraces) writeln(e.info);
        stdout.flush();
        return;
    }

    write("Enter network (freenode): ");
    stdout.flush();
    immutable network = readln().stripped;
    parser.server.network = network.length ? network : "freenode";

    // Provide skeletal user defaults.
    with (parser.client)
    {
        nickname = "kameloso";
        user = "kameloso";
        ident = "~kameloso";
        realName = "kameloso IRC bot";
    }

    // Provide Freenode defaults here, now that they're no longer in IRCServer.init
    // If we need different values we'll have to provide a RPL_MYINFO event.
    with (parser.server)
    {
        aModes = "eIbq";
        bModes = "k";
        cModes = "flj";
        dModes = "CFLMPQScgimnprstz";
        prefixes = "ov";
        prefixchars = [ 'o' : '@', 'v' : '+' ];
    }

    write("Enter server address (irc.freenode.net): ");
    stdout.flush();
    parser.server.address = readln().stripped;
    if (!parser.server.address.length) parser.server.address = "irc.freenode.net";

    enum scissors = "8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<";

    writeln();
    writeln(scissors);
    writeln();
    stdout.lockingTextWriter.formatClientAssignment(parser.client, parser.server);
    writeln();
    writeln("parser.typenums = typenumsOf(parser.server.daemon);");
    writeln();
    writeln(scissors);
    writeln();
    writeln("// Paste a raw event string and hit Enter to generate an assert block. " ~
        "Ctrl+C to exit.");
    writeln();
    stdout.flush();

    IRCClient oldClient = parser.client;
    IRCServer oldServer = parser.server;
    string input;

    while ((input = readln()) !is null)
    {
        import dialect.common : IRCParseException;

        scope(exit)
        {
            // Reset input so double enter doesn't display the same event
            input = string.init;
            stdout.flush();
        }

        input = input
            .strippedLeft(" /")  // Remove indents and commentating slashes
            .chomp; //strippedRight;

        if (!input.length)
        {
            writeln("// ... empty line. (Ctrl+C to exit)");
            continue;
        }

        try
        {
            IRCEvent event = parser.toIRCEvent(input);

            writeln();
            stdout.lockingTextWriter.formatEventAssertBlock(event);
            writeln();

            if (parser.clientUpdated || parser.serverUpdated)
            {
                parser.clientUpdated = false;
                parser.serverUpdated = false;

                writeln("with (parser)");
                writeln("{");
                stdout.lockingTextWriter.formatDeltaInto!(Yes.asserts)(oldClient, parser.client, 1, "client");
                stdout.lockingTextWriter.formatDeltaInto!(Yes.asserts)(oldServer, parser.server, 1, "server");
                writeln("}");
                writeln();

                oldClient = parser.client;
                oldServer = parser.server;
            }
        }
        catch (IRCParseException e)
        {
            writeln();
            writefln("// IRC Parse Exception at %s:%d: %s", e.file, e.line, e.msg);

            version(PrintStacktraces)
            {
                writeln("/*");
                writeln(e.info);
                writeln("*/");
                writeln();
            }
        }
        catch (Exception e)
        {
            writeln();
            writefln("// Exception at %s:%d: %s", e.file, e.line, e.msg);

            version(PrintStacktraces)
            {
                writeln("/*");
                writeln(e.toString);
                writeln("*/");
                writeln();
            }
        }
    }
}
