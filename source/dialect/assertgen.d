/++
    Interactive assert statement generation from raw IRC strings, for use in
    source code `unittest` blocks.

    Example:

    $(CONSOLE
    $ dub run :assertgen
    (...)

    // Paste a raw event string and hit Enter to generate an assert block. Ctrl+C to exit.

    $(I :silver.libera.chat 338 zorael deadmarshal 2605:6400:10:5bf:6f87:849d:f61e:2c8c :actually using host)

    {
        enum input = ":silver.libera.chat 338 zorael deadmarshal 2605:6400:10:5bf:6f87:849d:f61e:2c8c :actually using host";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.RPL_WHOISACTUALLY), type.toString());
            assert((sender.address == "silver.libera.chat"), sender.address);
            assert((target.nickname == "deadmarshal"), target.nickname);
            assert((content == "actually using host"), content);
            assert((aux[0] == "2605:6400:10:5bf:6f87:849d:f61e:2c8c"), aux[0]);
            assert((num == 338), num.to!string);
        }
    }
    )

    These can be directly copy/pasted into the appropriate files in `/tests`.
    They carry state from the events pasted before it, and the delta between them
    are also expressed as separate asserts.

    Example:

    $(CONSOLE
    $ dub run :assertgen
    (...)

    // Paste a raw event string and hit Enter to generate an assert block. Ctrl+C to exit.

    $(I @badge-info=;badges=;color=#5F9EA0;display-name=Zorael;emote-sets=0,185411,771823,1511983;user-id=22216721;user-type= :tmi.twitch.tv GLOBALUSERSTATE)

    {
        enum input = "@badge-info=;badges=;color=#5F9EA0;display-name=Zorael;emote-sets=0,185411,771823,1511983;user-id=22216721;user-type= :tmi.twitch.tv GLOBALUSERSTATE";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.GLOBALUSERSTATE), type.toString());
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.id == 22216721), sender.id.to!string);
            assert((target.nickname == "dialect"), target.nickname);
            assert((target.account == "dialect"), target.account);
            assert((target.displayName == "Zorael"), target.displayName);
            assert((target.badges == "*"), target.badges);
            assert((target.colour == "5F9EA0"), target.colour);
            assert((tags == "badge-info=;badges=;color=#5F9EA0;display-name=Zorael;emote-sets=0,185411,771823,1511983;user-id=22216721;user-type="), tags);
        }
    }

    with (parser)
    {
        assert((client.displayName == "Zorael"), client.displayName);
    }
    )

    This makes it easy to generate tests that verify wanted side-effects
    incurred by events, and to catch unwanted ones.

    There is a shorthand `--twitch` flag that sets up the parser for Twitch.
    This requires version `TwitchSupport`.

    $(CONSOLE
    $ dub run :assertgen -- --twitch
    (...)

    Server set to Twitch as per command-line argument.

    // Paste a raw event string and hit Enter to generate an assert block. Ctrl+C to exit.

    $(I @badge-info=subscriber/15;badges=subscriber/12;color=;display-name=SomeoneOnTwitch;emotes=;flags=;id=d6229854-2bf3-415d-80ce-a2fe84d00a23;login=someoneontwitch;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\s9d\s3e\s68\sca\s26\se9\s2a\s6e\s44\sd4\s60\s9b\s3d\saa\sb9\s4c\sad\s43\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=SomeoneOnTwitch\sis\sgifting\s1\sTier\s1\sSubs\sto\sSome_Streamer's\scommunity!\sThey've\sgifted\sa\stotal\sof\s4\sin\sthe\schannel!;tmi-sent-ts=1569013433362;user-id=22454856921;user-type= :tmi.twitch.tv USERNOTICE #some_streamer)

    {
        enum input = r"@badge-info=subscriber/15;badges=subscriber/12;color=;display-name=SomeoneOnTwitch;emotes=;flags=;id=d6229854-2bf3-415d-80ce-a2fe84d00a23;login=someoneontwitch;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\s9d\s3e\s68\sca\s26\se9\s2a\s6e\s44\sd4\s60\s9b\s3d\saa\sb9\s4c\sad\s43\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=SomeoneOnTwitch\sis\sgifting\s1\sTier\s1\sSubs\sto\sSome_Streamer's\scommunity!\sThey've\sgifted\sa\stotal\sof\s4\sin\sthe\schannel!;tmi-sent-ts=1569013433362;user-id=22454856921;user-type= :tmi.twitch.tv USERNOTICE #some_streamer";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), type.toString());
            assert((sender.nickname == "someoneontwitch"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "someoneontwitch"), sender.account);
            assert((sender.displayName == "SomeoneOnTwitch"), sender.displayName);
            assert((sender.badges == "subscriber/15"), sender.badges);
            assert((sender.id == 22454856921), sender.id.to!string);
            assert((channel == "#some_streamer"), channel);
            assert((content == "SomeoneOnTwitch is gifting 1 Tier 1 Subs to Some_Streamer's community! They've gifted a total of 4 in the channel!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((count[0] == 1), count[0].to!string);
            assert((count[1] == 4), count[1].to!string);
            assert((tags == "badge-info=subscriber/15;badges=subscriber/12;color=;display-name=SomeoneOnTwitch;emotes=;flags=;id=d6229854-2bf3-415d-80ce-a2fe84d00a23;login=someoneontwitch;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\\s9d\\s3e\\s68\\sca\\s26\\se9\\s2a\\s6e\\s44\\sd4\\s60\\s9b\\s3d\\saa\\sb9\\s4c\\sad\\s43\\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=SomeoneOnTwitch\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sSome_Streamer's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s4\\sin\\sthe\\schannel!;tmi-sent-ts=1569013433362;user-id=22454856921;user-type="), tags);
            assert((id == "d6229854-2bf3-415d-80ce-a2fe84d00a23"), id);
        }
    }
    )

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
import lu.common : Next;

import std.typecons : Flag, No, Yes;


// main
/++
    Entry point when compiling the `assertgen` dub configuration.

    Reads raw server strings from `stdin`, parses them into
    [dialect.defs.IRCEvent|IRCEvent]s and constructs assert blocks of their contents.

    Params:
        args = Command-line arguments.

    Returns:
        `0` on success; non-`0` on failure.
 +/
version(unittest) {}
else
public auto main(string[] args)
{
    import std.getopt : GetOptException;
    import std.stdio : writefln, writeln;

    Configuration configuration;

    try
    {
        configuration = callGetopt(args);
    }
    catch (GetOptException e)
    {
        writeln(e.msg);
        version(PrintStacktraces) writeln(e.info);
        return 1;
    }

    if (configuration.helpWanted) return 0;  // Printed out internally in callGetopt

    if (configuration.outputFile == "-")
    {
        // File output requested disabled
        configuration.outputFile = string.init;
    }

    bool shouldPad;

    if (configuration.outputFile.length)
    {
        enum pattern = "Writing output to %s, overwrite:%s";
        writefln(pattern, configuration.outputFile, configuration.overwrite);
        shouldPad = true;
    }

    if ((configuration.indents < 0) || (configuration.indents > 20))
    {
        enum pattern = "Invalid indents value %d, resetting to 0.";
        writefln(pattern, configuration.indents);
        configuration.indents = 0;
        shouldPad = true;
    }

    if (shouldPad) writeln();

    IRCParser parser;
    immutable actionAfterParserCreation = createParser(parser, configuration);

    if (actionAfterParserCreation != Next.continue_)
    {
        return 1;
    }

    inputLoop(parser, configuration);
    assert(0, "unreachable");
}


// putClientServerDelta
/++
    Constructs assignment block deltastrings for an
    [dialect.defs.IRCClient|IRCClient] and an [dialect.defs.IRCServer|IRCServer],
    as if they were members of an [dialect.parsing.IRCParser|IRCParser] instance,
    and writes them to an output range.

    The deltastrings express the differences between the two structs compared to
    their `.init` state.

    Example:
    ---
    IRCClient client;
    IRCServer server;
    Appender!(char[]) sink;

    sink.putClientServerDelta(client, server, 0);
    ---

    Params:
        sink = Output range to write to.
        client = [dialect.defs.IRCClient|IRCClient] to simulate the assignment of.
        server = [dialect.defs.IRCServer|IRCServer] to simulate the assignment of.
        indents = Number of tabs to indent the output by.
 +/
void putClientServerDelta(Sink)
    (auto ref Sink sink,
    const IRCClient client,
    const IRCServer server,
    const uint indents) pure @safe
{
    import lu.deltastrings : putDelta;
    import lu.string : tabs;
    import std.format : formattedWrite;
    import std.range.primitives : isOutputRange;

    static if (!isOutputRange!(Sink, char[]))
    {
        enum message = "`putClientServerDelta` output range must accept `char[]`";
        static assert(0, message);
    }

    sink.formattedWrite("%sIRCParser parser;\n\n", indents.tabs);
    sink.formattedWrite("%swith (parser)\n", indents.tabs);
    sink.formattedWrite("%s{\n", indents.tabs);
    sink.putDelta(IRCClient.init, client, indents+1, "client");
    sink.putDelta(IRCServer.init, server, indents+1, "server");
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

    sink.putClientServerDelta(client, server, 0);

    assert(sink[] ==
`IRCParser parser;

with (parser)
{
    client.nickname = "NICKNAME";
    client.user = "UUUUUSER";
    server.address = "something.freenode.net";
    server.port = 6667;
    server.daemon = IRCServer.Daemon.unreal;
    server.aModes = "eIbq";
}`, '\n' ~ sink[]);
}


// putEventAssertBlock
/++
    Constructs assert block deltastrings for an [dialect.defs.IRCEvent|IRCEvent]
    and writes them to an output range.

    The deltastrings express the differences between the struct compared to its
    `.init` state.

    Example:
    ---
    IRCEvent event;
    Appender!(char[]) sink;
    sink.putEventAssertBlock(event, 0);
    ---

    Params:
        sink = Output buffer to write to.
        event = [dialect.defs.IRCEvent|IRCEvent] to construct assert statements for.
        indents = Number of tabs to indent the output by.
 +/
void putEventAssertBlock(Sink)
    (auto ref Sink sink,
    const ref IRCEvent event,
    const uint indents) pure @safe
{
    import lu.deltastrings : putDelta;
    import lu.string : tabs;
    import std.algorithm.searching : canFind;
    import std.conv : text;
    import std.format : formattedWrite;
    import std.range.primitives : isOutputRange;

    static if (!isOutputRange!(Sink, char[]))
    {
        enum message = "`putEventAssertBlock` output range must accept `char[]`";
        static assert(0, message);
    }

    immutable raw = event.tags.length ?
        text('@', event.tags, ' ', event.raw) :
        event.raw;

    immutable enumInputPattern = (raw.canFind('\\') || raw.canFind('"')) ?
        "%senum input = r\"%s\";\n" :  // raw wysiwyg string
        "%senum input = \"%s\";\n";    // normal string

    immutable deeperIndents = indents + 1;

    sink.formattedWrite("%s{\n", indents.tabs);
    sink.formattedWrite(enumInputPattern, deeperIndents.tabs, raw);
    sink.formattedWrite("%simmutable event = parser.toIRCEvent(input);\n\n", deeperIndents.tabs);
    sink.formattedWrite("%swith (event)\n", deeperIndents.tabs);
    sink.formattedWrite("%s{\n", deeperIndents.tabs);
    sink.putDelta!(Yes.asserts)(IRCEvent.init, event, deeperIndents+1);
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
    sink.putEventAssertBlock(event, 0);

    assert(sink[] ==
`{
    enum input = ":zorael!~NaN@2001:41d0:2:80b4:: PRIVMSG #flerrp :kameloso: 8ball";
    immutable event = parser.toIRCEvent(input);

    with (event)
    {
        assert((type == IRCEvent.Type.CHAN), type.toString());
        assert((sender.nickname == "zorael"), sender.nickname);
        assert((sender.ident == "~NaN"), sender.ident);
        assert((sender.address == "2001:41d0:2:80b4::"), sender.address);
        assert((channel == "#flerrp"), channel);
        assert((content == "kameloso: 8ball"), content);
    }
}`, '\n' ~ sink[]);
}


// inputServerInformation
/++
    Asks the user to enter server information via standard input.

    Params:
        parser = Refrence to [dialect.parsing.IRCParser|IRCParser] to populate
            with server information.
 +/
void inputServerInformation(ref IRCParser parser) @system
{
    import dialect.common : typenumsOf;
    import lu.conv : Enum, toString;
    import lu.string : advancePast, stripped;
    import std.range : chunks, only;
    import std.stdio : readln, stdin, stdout, write, writefln, writeln;
    import std.traits : EnumMembers;
    import std.uni : toLower;

    enum defaultDaemon = IRCServer.Daemon.solanum;
    enum defaultNetwork = "Libera.Chat";
    enum defaultAddress = "irc.libera.chat";

    writeln("-- Available daemons --");
    writefln("%(%(%-14s%)\n%)", EnumMembers!(IRCServer.Daemon).only.chunks(3));
    writeln();

    write("Enter daemon (plus optional daemon literal) [", defaultDaemon.toString(), "]: ");
    stdout.flush();
    stdin.flush();

    string slice = readln().stripped;  // mutable so we can advancePast it
    immutable daemonstring = slice.advancePast(' ', inherit: true).toLower;
    immutable daemonLiteral = slice.length ? slice : daemonstring;

    parser.server.daemon = daemonstring.length ?
        Enum!(IRCServer.Daemon).fromString(daemonstring) :
        defaultDaemon;
    parser.typenums = typenumsOf(parser.server.daemon);
    parser.server.daemonstring = daemonLiteral;

    write("Enter network [", defaultNetwork, "]: ");
    stdout.flush();
    stdin.flush();

    parser.server.network = readln().stripped;
    if (!parser.server.network.length) parser.server.network = defaultNetwork;

    write("Enter server address [", defaultAddress, "]: ");
    stdout.flush();
    stdin.flush();

    parser.server.address = readln().stripped;
    if (!parser.server.address.length) parser.server.address = defaultAddress;
}


// Configuration
/++
    Configuration struct for the `assertgen` tool. An aggregate of the options
    that were passed on the command line.
 +/
struct Configuration
{
    /++
        Default output filename.
     +/
    enum defaultOutputFilename = "unittest.log";

    /++
        Default nickname.
     +/
    enum defaultNickname = "dialect";

    /++
        Default user.
     +/
    enum defaultUser = "dialect";

    /++
        Default ident.
     +/
    enum defaultIdent = "~dialect";

    /++
        Default GECOS "real name".
     +/
    enum defaultRealName = "dialect unit test";

    /++
        Path to the executable; `args[0]`.
     +/
    string args0;

    /++
        Actual nickname.
     +/
    string nickname = defaultNickname;

    /++
        Actual user.
     +/
    string user = defaultUser;

    /++
        Actual ident.
     +/
    string ident = defaultIdent;

    /++
        Actual GECOS "real name".
     +/
    string realName = defaultRealName;

    /++
        Output file.
     +/
    string outputFile = defaultOutputFilename;

    /++
        Indentation level for output.
     +/
    int indents;

    /++
        Overwrite file instead of appending to it.
     +/
    bool overwrite;

    /++
        Shortcut to Twitch input.
     +/
    bool twitch;

    /++
        Whether or not `--help` was passed on the command line.
     +/
    bool helpWanted;
}


// createParser
/++
    Creates an [dialect.parsing.IRCParser|IRCParser] with values taken from the
    passed [Configuration].

    The user will be asked for more information if Twitch was not explicitly
    asked for on the command line. This requires version `TwitchSupport`.

    Params:
        parser = out-reference [dialect.parsing.IRCParser|IRCParser] to
            create and whose members to populate with information from the
            command line.
        configuration = [Configuration] whose values to use in the parser.

    Returns:
        [Next.continue_] if the parser was successfully created;
        [Next.returnFailure] otherwise.
 +/
auto createParser(
    out IRCParser parser,
    const Configuration configuration)
{
    import dialect.common : typenumsOf;
    import std.conv : ConvException;
    import std.stdio : writeln;

    IRCClient client;
    IRCServer server;

    version (TwitchSupport)
    {
        if (configuration.twitch)
        {
            // --twitch supplied, skip asking for server information
            // nickname, user and ident are always identical
            client.nickname = configuration.nickname;
            client.user = configuration.nickname;
            client.ident = configuration.nickname;
            //client.realName = configuration.realName;  // Not used on Twitch

            server.daemon = IRCServer.Daemon.twitch;
            server.network = "Twitch";
            server.daemonstring = "twitch";
            server.address = "irc.chat.twitch.tv";
            server.maxNickLength = 25;

            writeln("Server set to Twitch as per command-line argument.");

            parser = IRCParser(client, server);  // this initialises postprocessors
            parser.typenums = typenumsOf(IRCServer.Daemon.twitch);
            return Next.continue_;
        }
    }

    try
    {
        inputServerInformation(parser);
    }
    catch (ConvException e)
    {
        writeln();
        writeln("-- Conversion exception caught when parsing daemon: ", e.msg);
        version(PrintStacktraces) writeln(e.info);
        return Next.returnFailure;
    }

    // Inherit getopt values
    client.nickname = configuration.nickname;
    client.user = configuration.user;
    client.ident = configuration.ident;
    client.realName = configuration.realName;

    /+
        Provide Libera.Chat defaults manually here, now that they're no longer
        in IRCServer.init. If we need different values we'll have to provide
        an RPL_MYINFO event, or just, modify the source. Software is malleable.
     +/
    server.aModes = "eIbq";
    server.bModes = "k";
    server.cModes = "flj";
    server.dModes = "CFLMPQScgimnprstuz";
    server.prefixes = "ov";
    server.prefixchars = [ 'o' : '@', 'v' : '+' ];

    parser = IRCParser(client, server);  // this initialises postprocessors
    parser.typenums = typenumsOf(parser.server.daemon);
    return Next.continue_;
}


// inputLoop
/++
    Main input loop for the `assertgen` tool.

    Reads raw server strings from `stdin`, parses them into
    [dialect.defs.IRCEvent|IRCEvent]s and constructs assert blocks of their contents.

    Params:
        parser = [dialect.parsing.IRCParser|IRCParser] to use for parsing.
        configuration = [Configuration] with values derived from command-line arguments.
 +/
auto inputLoop(
    ref IRCParser parser,
    const Configuration configuration)
{
    import lu.string : tabs;
    import std.array : Appender;
    import std.format : formattedWrite;
    import std.stdio : File, readln, stdin, stdout, writefln, writeln;

    enum scissors = "// 8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<\n";

    Appender!(char[]) buffer;
    buffer.reserve(4096);

    buffer.putClientServerDelta(parser.client, parser.server, configuration.indents);

    enum typenumsOfPattern = "\n\n%sparser.typenums = typenumsOf(parser.server.daemon);\n";
    buffer.formattedWrite(typenumsOfPattern, configuration.indents.tabs);

    writeln();
    writeln(scissors);
    writeln(buffer[]);
    writeln(scissors);
    writeln("// Paste a raw event string and hit Enter to generate an assert block. Ctrl+C to exit.");
    writeln();
    stdout.flush();

    File file;

    if (configuration.outputFile.length)
    {
        import std.datetime.systime : Clock;
        import std.file : exists;
        import core.time : msecs;

        if (configuration.overwrite)
        {
            file = File(configuration.outputFile, "w");
        }
        else
        {
            immutable shouldPad = configuration.outputFile.exists;

            file = File(configuration.outputFile, "a");

            if (shouldPad)
            {
                file.writeln('\n');
            }
        }

        auto now = Clock.currTime;
        now.fracSecs = 0.msecs;

        enum pattern = "// ========== %s: %s\n";
        file.writefln(pattern, configuration.args0, now);
        file.writeln(buffer[]);
        file.flush();
    }

    buffer.clear();

    IRCClient oldClient = parser.client;
    IRCServer oldServer = parser.server;

    while (const lineOfInput = readln())
    {
        import dialect.common : IRCParseException;
        import lu.string : strippedLeft, strippedRight, unquoted;
        import std.format : formattedWrite;

        scope(exit)
        {
            stdin.flush();
            stdout.flush();
        }

        auto input = lineOfInput
            .strippedRight
            .strippedLeft(" /")
            .unquoted;

        if (input.length && (input[$-1] == '$')) input = input[0..$-1];
        if (!input.length) continue;

        try
        {
            IRCEvent event = parser.toIRCEvent(input);

            buffer.putEventAssertBlock(event, configuration.indents);

            if (parser.updates != IRCParser.Update.nothing)
            {
                import lu.deltastrings : putDelta;

                buffer.put("\n\n");
                buffer.formattedWrite("%swith (parser)\n", configuration.indents.tabs);
                buffer.formattedWrite("%s{\n", configuration.indents.tabs);
                buffer.putDelta!(Yes.asserts)(oldClient, parser.client, configuration.indents+1, "client");
                buffer.putDelta!(Yes.asserts)(oldServer, parser.server, configuration.indents+1, "server");
                buffer.formattedWrite("%s}", configuration.indents.tabs);

                oldClient = parser.client;
                oldServer = parser.server;
                parser.updates = IRCParser.Update.nothing;
            }
        }
        catch (IRCParseException e)
        {
            enum pattern = "\n// IRC Parse Exception at %s:%d: %s\n";
            buffer.formattedWrite(pattern, e.file, e.line, e.msg);

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
            enum pattern = "\n// Exception at %s:%d: %s\n";
            buffer.formattedWrite(pattern, e.file, e.line, e.msg);

            version(PrintStacktraces)
            {
                buffer.put("/*\n");
                buffer.put(e.toString);
                buffer.put("\n*/\n");
            }
        }

        if (configuration.outputFile.length)
        {
            file.writeln(buffer[]);
            file.flush();
        }

        writeln();
        writeln(buffer[]);
        writeln();
        buffer.clear();
    }

    assert(0, "unreachable");
}


// callGetopt
/++
    Parses command-line arguments into a [Configuration] struct.

    Params:
        args = Command-line arguments to parse.

    Returns:
        [Configuration] struct with the parsed options.
 +/
auto callGetopt(string[] args)
{
    import std.getopt : config, getopt;

    version(TwitchSupport)
    {
        enum twitchString = "Shortcut to Twitch input";
    }
    else
    {
        enum twitchString = "(Only available when compiled with Twitch support)";
    }

    Configuration configuration;
    configuration.args0 = args[0];

    auto results = getopt(args,
        config.caseSensitive,
        config.bundling,
        "n|nickname",
            "Override initial nickname",
            &configuration.nickname,
        "u|user",
            "Override initial user",
            &configuration.user,
        "i|ident",
            "Override initial ident",
            &configuration.ident,
        "o|output",
            "Output file (specify '-' to disable) [" ~ configuration.outputFile ~ "]",
            &configuration.outputFile,
        "O|overwrite",
            "Overwrite file instead of appending to it",
            &configuration.overwrite,
        "twitch",
            twitchString,
            &configuration.twitch,
        "indents",
            "Indentation level for output",
            &configuration.indents,
    );

    if (results.helpWanted)
    {
        import std.getopt : defaultGetoptPrinter;
        defaultGetoptPrinter("Available flags:\n", results.options);
        configuration.helpWanted = true;
    }

    return configuration;
}
