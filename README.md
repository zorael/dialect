# dialect [![Linux/macOS/Windows](https://img.shields.io/github/actions/workflow/status/zorael/dialect/d.yml?branch=master)](https://github.com/zorael/dialect/actions?query=workflow%3AD) [![Linux](https://img.shields.io/circleci/project/github/zorael/dialect/master.svg?logo=circleci&style=flat&maxAge=3600)](https://circleci.com/gh/zorael/dialect) [![Windows](https://img.shields.io/appveyor/ci/zorael/dialect/master.svg?logo=appveyor&style=flat&maxAge=3600)](https://ci.appveyor.com/project/zorael/dialect) [![Commits since last release](https://img.shields.io/github/commits-since/zorael/dialect/v3.0.0.svg?logo=github&style=flat&maxAge=3600)](https://github.com/zorael/dialect/compare/v3.0.0...master)

IRC parsing library.

## What it looks like

API documentation can be found [here](http://dialect.dpldocs.info).

```d
struct IRCEvent
{
    enum Type { ... }  // large enum of IRC event types

    Type type;
    string raw;
    IRCUser sender;
    IRCUser target;
    string channel;
    string content;
    string[16] aux;
    string tags;
    uint num;
    Nullable!long[16] count;
    long time;
    string errors;
}

struct IRCUser
{
    version(BotElements)
    {
        enum Class { ... }  // enum of IRC user types; operator, staff, and similar
        Class class_;
    }

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
    bool[string][char] mods;
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

## Available build configurations

* `library` is the base configuration
* `twitch` includes extra parsing needed to interface with Twitch servers
* `bot` includes some code specifically useful for bot applications
* `twitchbot` is `twitch` and `bot` combined

It is `pure` and `@safe` in the default `library` configuration.

## How to use

> This assumes you have a program set up to read from an IRC server. This is not a bot framework; for that you're better off with the full reference-implementation [`kameloso`](https://github.com/zorael/kameloso) and writing a plugin for it that suits your needs.

* Create an [`IRCClient`](http://dialect.dpldocs.info/dialect.defs.IRCClient.html) and configure its members. (required for context when parsing)
* Create an [`IRCServer`](http://dialect.dpldocs.info/dialect.defs.IRCServer.html) and configure its members. (it may work without but just give it at minimum a host address)
* Create an [`IRCParser`](http://dialect.dpldocs.info/dialect.parsing.IRCParser.html) with your client and server via constructor. Pass it by `ref` if passed around between functions.
* Read a string from the server and parse it into an [`IRCEvent`](http://dialect.dpldocs.info/dialect.defs.IRCEvent.html) with [`yourParser.toIRCEvent(stringFromServer)`](http://dialect.dpldocs.info/dialect.parsing.toIRCEvent.html).

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
    assert(aux[0] = "+v");
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
    assert(aux[0] == "newnick");
    assert(num == 435);
}

// Requires Twitch support via build configuration "twitch" or "twitchagnostic"
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
    assert(aux[0] == "1000");
    assert(count[0] == 1);
    assert(count[1] == 4);
}
```

See the [`/tests`](/tests) directory for more example parses.

## Unit test generation

Compiling the `assertgen` dub subpackage builds a command-line tool with which it is easy to generate assert blocks like the one above. These can then be pasted into an according file in [`/tests`](/tests) and ideally submitted as a GitHub pull request for upstream inclusion. You can use it to contribute known-good parses and increase coverage of event types.

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

The output will by default also be saved to a `unittest.log` file in the current directory. See the `--help` listing for more details, passed through `dub` with `dub run :assertgen -- --help`.

## Caveats

Note that while IRC is standardised, servers still come in [many flavours](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/IRCd_software_implementations3.svg/1533px-IRCd_software_implementations3.svg.png), some of which [outright conflict](http://defs.ircdocs.horse/defs/numerics.html) with others.

**Please report bugs. Unreported bugs can only be fixed by accident.**

## Roadmap

* nothing right now, ideas needed

## Built with

* [**D**](https://dlang.org)
* [`dub`](https://code.dlang.org)
* [`lu`](https://github.com/zorael/lu) ([dub](http://code.dlang.org/packages/lu))

## License

This project is licensed under the **Boost Software License 1.0** - see the [LICENSE_1_0.txt](LICENSE_1_0.txt) file for details.
