# dialect [![Linux/macOS/Windows](https://img.shields.io/github/workflow/status/zorael/dialect/D?logo=github&style=flat&maxAge=3600)](https://github.com/zorael/dialect/actions?query=workflow%3AD) [![Linux](https://img.shields.io/circleci/project/github/zorael/dialect/master.svg?logo=circleci&style=flat&maxAge=3600)](https://circleci.com/gh/zorael/dialect) [![Windows](https://img.shields.io/appveyor/ci/zorael/dialect/master.svg?logo=appveyor&style=flat&maxAge=3600)](https://ci.appveyor.com/project/zorael/dialect) [![Commits since last release](https://img.shields.io/github/commits-since/zorael/dialect/v1.1.1.svg?logo=github&style=flat&maxAge=3600)](https://github.com/zorael/dialect/compare/v1.1.1...master)

IRC parsing library.

It uses exceptions to signal errors during parsing, so it's not `nothrow`. Some parts of it create new strings, so it can't be `@nogc`. It is however `pure` and `@safe` with the default "library" build configuration.

Note that while IRC is standardised, servers still come in [many flavours](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/IRCd_software_implementations3.svg/1533px-IRCd_software_implementations3.svg.png), some of which [outright conflict](http://defs.ircdocs.horse/defs/numerics.html) with others. If something doesn't immediately work, generally it's because we simply haven't encountered that type of event before, and so no rules for how to parse it have yet been written.

**Please report bugs. Unreported bugs can only be fixed by accident.**

# What it looks like

API documentation can be found [here](http://dialect.dpldocs.info).

```d
struct IRCEvent
{
    enum Type { ... }  // *large* enum of IRC event types

    Type type;
    string raw;
    IRCUser sender;
    IRCUser target;
    string channel;
    string content;
    string aux;
    string tags;
    uint num;
    long count;
    long altcount;
    long time;
    string errors;
}

struct IRCUser
{
    enum Class { ... }  // enum of IRC user types; operator, staff, and similar

    Class class_;
    string nickname;
    string realName;
    string ident;
    string address;
    string account;
    long updated;
}

struct IRCChannel
{
    struct Mode { ... }  // embodies the notion of a channel mode

    string name;
    string topic;
    string modechars;
    Mode[] modes;
    bool[string] users;
    string[][char] mods;
    long created;
}

struct IRCServer
{
    enum Daemon { ... } // enum of various IRC daemons

    Daemon daemon;
    string address;
    ushort port;

    // More internals
}

struct IRCClient
{
    string nickname;
    string user;
    string realName;
}

struct IRCParser
{
    IRCClient client;
    IRCServer server;
    this(IRCClient, IRCServer);

    IRCEvent toIRCEvent(const string);  // <-- entry point of use
}
```

# How to use

> This assumes you have a program set up to read from an IRC server. This is not a bot framework; for that you're better off with the full [kameloso](https://github.com/zorael/kameloso) and writing a plugin that suits your needs.

* Instantiate an `IRCClient` and configure its members. (required for context when parsing)
* Instantiate an `IRCServer` and configure its members. (it may work without but just give it at minimum a host address)
* Instantiate an `IRCParser` with your client and server via constructor. Pass it by `ref` if passed around between functions.
* Read a string from the server and parse it into an `IRCEvent` with `yourParser.toIRCEvent(string)`.

```d
IRCClient client;
client.nickname = "...";

IRCServer server;
server.address = "...";

IRCParser parser = IRCParser(client, server);

string fromServer = ":zorael!~NaN@address.tld MODE #channel +v nickname";
IRCEvent event = parser.toIRCEvent(fromServer);

with (event)
{
    assert(type == IRCEvent.Type.MODE);
    assert(sender.nickname == "zorael");
    assert(sender.ident == "~NaN");
    assert(sender.address == "address.tld");
    assert(target.nickname == "nickname");
    assert(channel == "#channel");
    assert(aux = "+v");
}

string alsoFromServer = ":cherryh.freenode.net 435 oldnick newnick #d :Cannot change nickname while banned on channel";
IRCEvent event2 = parser.toIRCEvent(alsoFromServer);

with (event2)
{
    assert(type == IRCEvent.Type.ERR_BANONCHAN);
    assert(sender.address == "cherryh.freenode.net");
    assert(channel == "#d");
    assert(target.nickname == "oldnick");
    assert(content == "Cannot change nickname while banned on channel");
    assert(aux == "newnick");
    assert(num == 435);
}

// Requires Twitch support via build configuration "twitch"
string fullExample = "@badge-info=subscriber/15;badges=subscriber/12;color=;display-name=SomeoneOnTwitch;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=someoneontwitch;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\\s9d\\s3e\\s68\\sca\\s26\\se9\\s2a\\s6e\\s44\\sd4\\s60\\s9b\\s3d\\saa\\sb9\\s4c\\sad\\s43\\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=someoneOnTwitch\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sxQcOW's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s4\\sin\\sthe\\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type= :tmi.twitch.tv USERNOTICE #xqcow"
IRCEvent event3 = parser.toIRCEvent(fullExample);

with (event3)
{
    assert(type == IRCEvent.Type.TWITCH_BULKGIFT);
    assert(sender.nickname == "someoneontwitch");
    assert(sender.displayName == "SomeoneOnTwitch");
    assert(sender.badges == "subscriber/12");
    assert(channel == "#xqcow");
    assert(content == "SomeoneOnTwitch is gifting 1 Tier 1 Subs to xQcOW's community! They've gifted a total of 4 in the channel!");
    assert(aux == "1000");
    assert(count == 1);
    assert(altcount == 4);
}
```

See the [`/tests`](/tests) directory for more example parses.

# Unit test generation

Compiling the `assertgen` dub subpackage builds a command-line tool with which it is easy to generate assert blocks like the one above. These can then be pasted into an according file in [`/tests`](/tests), then ideally submitted as a GitHub pull request for upstream inclusion. You can use it to contribute known-good parses and increase coverage of event types.

Simply run `dub run :assertgen` and follow the on-screen instructions.

```
Enter daemon [optional daemon literal] (ircdseven): unreal
Enter network (freenode): foobar
Enter server address (irc.freenode.net): irc.server.tld

[...]

// Paste a raw event string and hit Enter to generate an assert block. Ctrl+C to exit.

:irc.server.tld PRIVMSG #channel :i am a fish

{
    immutable event = parser.toIRCEvent(":irc.server.tld PRIVMSG #channel :i am a fish");
    with (event)
    {
        assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
        assert((sender.address == "irc.server.tld"), sender.address);
        assert((channel == "#channel"), channel);
        assert((content == "i am a fish"), content);
    }
}
```

The output will by default also be saved to a `unittest.log` file in the current directory. See the `--help` listing for more details, passed through dub with `dub run :assertgen -- --help`.

# Roadmap

* consider ripping out `isAuthService` and related bits (that translate `NOTICE` events into fake `AUTH_{CHALLENGE,SUCCESS,FAILURE}` types) and moving it to importing projects

# Built with

* [**D**](https://dlang.org)
* [`dub`](https://code.dlang.org)
* [`lu`](https://github.com/zorael/lu) ([dub](http://code.dlang.org/packages/lu))

# License

This project is licensed under the **MIT** license - see the [LICENSE](LICENSE) file for details.
