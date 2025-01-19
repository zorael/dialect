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

    Copyright: [JR](https://github.com/zorael)
    License: [Boost Software License 1.0](https://www.boost.org/users/license.html)

    Authors:
        [JR](https://github.com/zorael)
 +/
module dialect.assertgen;

version(AssertGeneration):

private:

import dialect.defs;
import dialect.parsing : IRCParser;
import std.range.primitives : isOutputRange;
import std.typecons : Flag, No, Yes;


// formatClientAssignment
/++
    Constructs statement lines for each changed field of an
    [dialect.defs.IRCClient|IRCClient], including instantiating a fresh one.

    Example:
    ---
    IRCClient client;
    IRCServer server;
    Appender!(char[]) sink;

    sink.formatClientAssignment(client, server);
    ---

    Params:
        sink = Output buffer to write to.
        client = [dialect.defs.IRCClient|IRCClient] to simulate the assignment of.
        server = [dialect.defs.IRCServer|IRCServer] to simulate the assignment of.
        indents = Number of tabs to indent the output by.
 +/
void formatClientAssignment(Sink)
    (auto ref Sink sink,
    const IRCClient client,
    const IRCServer server,
    const uint indents) pure @safe
if (isOutputRange!(Sink, char[]))
{
    import lu.deltastrings : formatDeltaInto;
    import lu.string : tabs;
    import std.format : formattedWrite;

    sink.formattedWrite("%sIRCParser parser;\n\n", indents.tabs);
    sink.formattedWrite("%swith (parser)\n", indents.tabs);
    sink.formattedWrite("%s{\n", indents.tabs);
    sink.formatDeltaInto(IRCClient.init, client, indents+1, "client");
    sink.formatDeltaInto(IRCServer.init, server, indents+1, "server");
    sink.formattedWrite("%s}", indents.tabs);

    static if (!__traits(hasMember, Sink, "data"))
    {
        sink.put('\n');
    }
}

///
pure @safe unittest
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

    sink.formatClientAssignment(client, server, 0);

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
    [dialect.defs.IRCEvent|IRCEvent].

    Example:
    ---
    IRCEvent event;
    Appender!(char[]) sink;
    sink.formatEventAssertBlock(event);
    ---

    Params:
        sink = Output buffer to write to.
        event = [dialect.defs.IRCEvent|IRCEvent] to construct assert statements for.
        indents = Number of tabs to indent the output by.
 +/
void formatEventAssertBlock(Sink)
    (auto ref Sink sink,
    const ref IRCEvent event,
    const uint indents) pure @safe
if (isOutputRange!(Sink, char[]))
{
    import lu.deltastrings : formatDeltaInto;
    import lu.string : tabs;
    import std.array : replace;
    import std.conv : text;
    import std.format : formattedWrite;

    immutable raw = event.tags.length ?
        text('@', event.tags, ' ', event.raw) :
        event.raw;

    immutable escaped = raw
        .replace('\\', `\\`)
        .replace('"', `\"`);

    immutable deeperIndents = indents + 1;

    sink.formattedWrite("%s{\n", indents.tabs);
    if (escaped != raw) sink.formattedWrite("%s// %s\n", deeperIndents.tabs, raw);
    sink.formattedWrite("%senum input = \"%s\";\n", deeperIndents.tabs, escaped);
    sink.formattedWrite("%simmutable event = parser.toIRCEvent(input);\n\n", deeperIndents.tabs);
    sink.formattedWrite("%swith (event)\n", deeperIndents.tabs);
    sink.formattedWrite("%s{\n", deeperIndents.tabs);
    sink.formatDeltaInto!(Yes.asserts)(IRCEvent.init, event, deeperIndents+1);
    sink.formattedWrite("%s}\n", deeperIndents.tabs);
    sink.formattedWrite("%s}", indents.tabs);

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
    sink.reserve(1024);

    IRCClient client;
    IRCServer server;
    auto parser = IRCParser(client, server);

    immutable event = parser.toIRCEvent(":zorael!~NaN@2001:41d0:2:80b4:: PRIVMSG #flerrp :kameloso: 8ball");
    sink.formatEventAssertBlock(event, 0);

    assert(sink.data ==
`{
    enum input = ":zorael!~NaN@2001:41d0:2:80b4:: PRIVMSG #flerrp :kameloso: 8ball";
    immutable event = parser.toIRCEvent(input);

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


// inputServerInformation
/++
    Asks the user to input server information via standard input.

    Params:
        parser = [dialect.parsing.IRCParser] to populate with information.
 +/
void inputServerInformation(ref IRCParser parser) @system
{
    import dialect.common : typenumsOf;
    import lu.conv : Enum;
    import lu.string : advancePast, stripped;
    import std.range : chunks, only;
    import std.traits : EnumMembers;
    import std.stdio : readln, stdin, stdout, write, writefln, writeln;
    import std.uni : toLower;

    writeln("-- Available daemons --");
    writefln("%(%(%-14s%)\n%)", EnumMembers!(IRCServer.Daemon).only.chunks(3));
    writeln();

    write("Enter daemon [optional daemon literal] (solanum): ");
    stdout.flush();
    stdin.flush();
    string slice = readln().stripped;  // mutable so we can advancePast it
    immutable daemonstring = slice.advancePast(' ', inherit: true).toLower;
    immutable daemonLiteral = slice.length ? slice : daemonstring;

    parser.server.daemon = daemonstring.length ?
        Enum!(IRCServer.Daemon).fromString(daemonstring) : IRCServer.Daemon.solanum;
    parser.typenums = typenumsOf(parser.server.daemon);
    parser.server.daemonstring = daemonLiteral;

    write("Enter network (Libera.Chat): ");
    stdout.flush();
    stdin.flush();
    parser.server.network = readln().stripped;
    if (!parser.server.network.length) parser.server.network = "Libera.Chat";

    write("Enter server address (irc.libera.chat): ");
    stdout.flush();
    stdin.flush();
    parser.server.address = readln().stripped;
    if (!parser.server.address.length) parser.server.address = "irc.libera.chat";
}


public:


// main
/++
    Entry point when compiling the `assertgen` dub configuration.

    Reads raw server strings from `stdin`, parses them into
    [dialect.defs.IRCEvent|IRCEvent]s and constructs assert blocks of their contents.
 +/
version(unittest) {}
else
int main(string[] args) @system
{
    import dialect.defs : IRCServer;
    import lu.deltastrings : formatDeltaInto;
    import lu.string : strippedLeft, tabs;
    import std.array : Appender;
    import std.format : formattedWrite;
    import std.getopt : GetOptException, config, getopt;
    import std.stdio : File, readln, stdin, stdout, write, writefln, writeln;
    import std.string : chomp;

    enum defaultOutputFilename = "unittest.log";

    string nicknameOverride;
    string userOverride;
    string identOverride;
    string outputFile = defaultOutputFilename;
    int indents;
    bool overwrite;
    bool twitch;

    try
    {
        version(TwitchSupport)
        {
            enum twitchString = "Shortcut to Twitch input";
        }
        else
        {
            enum twitchString = "(Only available when compiled with Twitch support)";
        }

        auto results = getopt(args,
            config.caseSensitive,
            config.bundling,
            "n|nickname",
                "Override initial nickname",
                &nicknameOverride,
            "u|user",
                "Override initial user",
                &userOverride,
            "i|ident",
                "Override initial ident",
                &identOverride,
            "o|output",
                "Output file (specify '-' to disable) [" ~ defaultOutputFilename ~ "]",
                &outputFile,
            "O|overwrite",
                "Overwrite file instead of appending to it",
                &overwrite,
            "twitch",
                twitchString,
                &twitch,
            "indents",
                "Indentation level for output",
                &indents,
        );

        if (results.helpWanted)
        {
            import std.getopt : defaultGetoptPrinter;
            defaultGetoptPrinter("Available flags:\n", results.options);
            return 0;
        }
    }
    catch (GetOptException e)
    {
        writeln(e.msg);
        return 1;
    }

    IRCParser parser;
    parser.initPostprocessors();  // Normally done in IRCParser(IRCClient) constructor

    Appender!(char[]) buffer;
    buffer.reserve(2048);

    if (outputFile == "-")
    {
        outputFile = string.init;
    }

    if (outputFile.length)
    {
        writefln("Writing output to %s, overwrite:%s", outputFile, overwrite);
    }

    if ((indents < 0) || (indents > 20))
    {
        writefln("Invalid indents value %d, resetting to 0.", indents);
        indents = 0;
    }

    version (TwitchSupport)
    {
        if (twitch)
        {
            import dialect.common : typenumsOf;

            parser.server.daemon = IRCServer.Daemon.twitch;
            parser.typenums = typenumsOf(IRCServer.Daemon.twitch);
            parser.server.network = "Twitch";
            parser.server.daemonstring = "twitch";
            parser.server.address = "irc.chat.twitch.tv";
            parser.server.maxNickLength = 25;

            // Provide skeletal user defaults.
            with (parser.client)
            {
                // nickname, user and ident are always identical
                nickname = nicknameOverride.length ? nicknameOverride : "kameloso";
                user = nickname;
                ident = nickname;
                //realName = "kameloso IRC bot";  // Not used on Twitch
            }

            writeln("Server set to Twitch as per command-line argument.");
        }
    }

    if (!twitch)
    {
        import std.conv : ConvException;

        try
        {
            inputServerInformation(parser);
        }
        catch (ConvException e)
        {
            writeln();
            writeln("-- Conversion exception caught when parsing daemon: ", e.msg);
            version(PrintStacktraces) writeln(e.info);
            stdout.flush();
            return 1;
        }

        // Provide skeletal user defaults.
        with (parser.client)
        {
            nickname = nicknameOverride.length ? nicknameOverride : "kameloso";
            user = userOverride.length ? userOverride : "kameloso";
            ident = identOverride.length ? identOverride : "~kameloso";
            realName = "kameloso IRC bot";
        }

        // Provide Libera.Chat defaults here, now that they're no longer in IRCServer.init
        // If we need different values we'll have to provide a RPL_MYINFO event.
        with (parser.server)
        {
            aModes = "eIbq";
            bModes = "k";
            cModes = "flj";
            dModes = "CFLMPQScgimnprstuz";
            prefixes = "ov";
            prefixchars = [ 'o' : '@', 'v' : '+' ];
        }
    }

    enum scissors = "// 8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<\n";

    buffer.formatClientAssignment(parser.client, parser.server, indents);
    buffer.formattedWrite("\n\n%sparser.typenums = typenumsOf(parser.server.daemon);\n", indents.tabs);

    writeln();
    writeln(scissors);
    writeln(buffer.data);
    writeln(scissors);
    writeln("// Paste a raw event string and hit Enter to generate an assert block. " ~
        "Ctrl+C to exit.");
    writeln();
    stdout.flush();

    File file;

    if (outputFile.length)
    {
        import std.datetime.systime : Clock;
        import std.file : exists;
        import core.time : msecs;

        if (overwrite)
        {
            file = File(outputFile, "w");
        }
        else
        {
            immutable shouldPad = outputFile.exists;

            file = File(outputFile, "a");

            if (shouldPad)
            {
                file.writeln('\n');
            }
        }

        auto now = Clock.currTime;
        now.fracSecs = 0.msecs;
        file.writeln("// ========== ", args[0], ": ", now, '\n');
        file.writeln(buffer.data);
        file.flush();
    }

    buffer.clear();

    IRCClient oldClient = parser.client;
    IRCServer oldServer = parser.server;
    string input;

    while ((input = readln()) !is null)
    {
        import dialect.common : IRCParseException;
        import lu.string : unquoted;
        import std.format : formattedWrite;

        scope(exit)
        {
            // Reset input so double enter doesn't display the same event
            input = string.init;
            stdin.flush();
            stdout.flush();
        }

        input = input
            .strippedLeft(" /")  // Remove indents and commentating slashes
            .chomp //strippedRight;
            .unquoted;

        if (input.length && (input[$-1] == '$')) input = input[0..$-1];
        if (!input.length) continue;

        try
        {
            IRCEvent event = parser.toIRCEvent(input);

            buffer.formatEventAssertBlock(event, indents);

            if (parser.updates != IRCParser.Update.nothing)
            {
                buffer.put("\n\n");
                buffer.formattedWrite("%swith (parser)\n", indents.tabs);
                buffer.formattedWrite("%s{", indents.tabs);
                buffer.formatDeltaInto!(Yes.asserts)(oldClient, parser.client, indents+1, "client");
                buffer.formatDeltaInto!(Yes.asserts)(oldServer, parser.server, indents+1, "server");
                buffer.formattedWrite("%s}", indents.tabs);

                oldClient = parser.client;
                oldServer = parser.server;
                parser.updates = IRCParser.Update.nothing;
            }
        }
        catch (IRCParseException e)
        {
            buffer.formattedWrite("\n// IRC Parse Exception at %s:%d: %s\n", e.file, e.line, e.msg);

            version(PrintStacktraces)
            {
                import std.conv : text;

                buffer.put("/*\n");
                buffer.put(e.info.text);
                buffer.put("\n*/\n");
            }
        }
        catch (Exception e)
        {
            buffer.formattedWrite("\n// Exception at %s:%d: %s\n", e.file, e.line, e.msg);

            version(PrintStacktraces)
            {
                buffer.put("/*\n");
                buffer.put(e.toString);
                buffer.put("\n*/\n");
            }
        }

        if (outputFile.length)
        {
            file.writeln(buffer.data);
            file.flush();
        }

        writeln();
        writeln(buffer.data);
        writeln();
        buffer.clear();
    }

    return 0;
}
