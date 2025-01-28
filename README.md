# dialect [![Linux/macOS/Windows](https://img.shields.io/github/actions/workflow/status/zorael/dialect/d.yml?branch=master)](https://github.com/zorael/dialect/actions?query=workflow%3AD) [![Linux](https://img.shields.io/circleci/project/github/zorael/dialect/master.svg?logo=circleci&style=flat&maxAge=3600)](https://circleci.com/gh/zorael/dialect) [![Windows](https://img.shields.io/appveyor/ci/zorael/dialect/master.svg?logo=appveyor&style=flat&maxAge=3600)](https://ci.appveyor.com/project/zorael/dialect) [![Commits since last release](https://img.shields.io/github/commits-since/zorael/dialect/v3.0.1.svg?logo=github&style=flat&maxAge=3600)](https://github.com/zorael/dialect/compare/v3.0.1...master)

IRC parsing library.

API documentation can be found [here](https://zorael.github.io/dialect/dialect.html).

```d
struct IRCEvent
{
    enum Type { ... }  // large enum of IRC event types

    Type type;
    IRCUser sender;
    IRCUser target;
    string channel;
    string subchannel;
    string content;
    string[16] aux;
    Nullable!long[16] count;
    string tags;
    uint num;
    long time;
    string raw;
    string errors;

    version(TwitchSupport)
    {
        string emotes;
        string id;
    }
}
```

```d
struct IRCUser
{
    version(BotElements)
    {
        enum Class { ... }  // enum of IRC user types in a channel; operator, staff, ...
        Class class_;
    }

    string nickname;
    string realName;
    string ident;
    string address;
    string account;
    long updated;

    version(TwitchSupport)
    {
        string displayName;
        string badges;
        string colour;
        uint id;
    }
}
```

```d
struct IRCChannel
{
    static struct Mode { ... }  // embodies the notion of a channel mode

    string name;
    string topic;
    string modechars;
    Mode[] modes;
    bool[string] users;
    bool[string][char] mods;
    long created;
}
```

```d
struct IRCServer
{
    enum Daemon { ... }  // enum of various IRC daemons

    Daemon daemon;
    string address;
    ushort port;

    // [...]
}
```

```d
struct IRCClient
{
    string nickname;
    string user;
    string realName;
}
```

```d
struct IRCParser
{
    IRCClient client;
    IRCServer server;
    this(IRCClient, IRCServer);
    @disable this(this);

    IRCEvent toIRCEvent(const string);  // <-- entry point of use
}
```

### Available build configurations

* `library` is the base configuration
* `twitch` includes extra parsing needed to interface with Twitch servers
* `bot` includes some code specifically useful for bot applications
* `twitchbot` is `twitch` and `bot` combined

It is `pure` and `@safe` in the default `library` configuration.

### How to use

See the [**/examples**](/examples) directory for a simple bot client that connects to an IRC server and joins a channel.

> This project is not a bot framework; for that you're better off with the reference-implementation [**`kameloso`**](https://github.com/zorael/kameloso) bot and writing a plugin for it that suits your needs.

#### Longer story

* Write a client that connects to an IRC server and reads from it.
* Create an [`IRCClient`](https://zorael.github.io/dialect/dialect.defs.IRCClient.html) and configure its members. (required for context when parsing)
* Create an [`IRCServer`](https://zorael.github.io/dialect/dialect.defs.IRCServer.html) and configure its members. (it may work without but just give it at minimum a host address)
* Create an [`IRCParser`](https://zorael.github.io/dialect/dialect.parsing.IRCParser.html) with your client and server via its constructor. Pass it between functions by `ref`.
* Read a string from the server and parse it into an [`IRCEvent`](https://zorael.github.io/dialect/dialect.defs.IRCEvent.html) with [`yourParser.toIRCEvent(stringFromServer)`](https://zorael.github.io/dialect/dialect.parsing.IRCParser.toIRCEvent.html).
* Switch on the [`IRCEvent.type`](https://zorael.github.io/dialect/dialect.defs.IRCEvent.Type.html) member and handle the event accordingly. Remember to `PONG` on `PING`.
* Draw the rest of the owl.

##### Like so

```d
IRCClient client;
client.nickname = "...";

IRCServer server;
server.address = "...";

IRCParser parser = IRCParser(client, server);

{
    string fromServer = ":zorael!~NaN@address.tld MODE #channel +v nickname";
    auto event = parser.toIRCEvent(fromServer);

    with (event)
    {
        assert(type == IRCEvent.Type.MODE);
        assert(sender.nickname == "zorael");
        assert(sender.ident == "~NaN");
        assert(sender.address == "address.tld");
        assert(channel == "#channel");
        assert(content == "nickname");
        assert(aux[0] == "+v");
    }
}
{
    string fromServer = ":cherryh.freenode.net 435 oldnick newnick #d :Cannot change nickname while banned on channel";
    auto event = parser.toIRCEvent(fromServer);

    with (event)
    {
        assert(type == IRCEvent.Type.ERR_BANONCHAN);
        assert(sender.address == "cherryh.freenode.net");
        assert(target.nickname == "oldnick");
        assert(channel == "#d");
        assert(content == "Cannot change nickname while banned on channel");
        assert(aux[0] == "newnick");
        assert(num == 435);
    }
}
{
    /+
        Requires support for Twitch servers through build configurations
        `twitch` or `twitchbot`.
     +/
    string fromServer = r"@badge-info=;badges=;color=;display-name=AnAnonymousGifter;emotes=;flags=;id=01af180f-5efd-40c8-94fb-d0a346c7fg86;login=ananonymousgifter;mod=0;msg-id=subgift;msg-param-fun-string=FunStringFour;msg-param-gift-months=1;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=15624;msg-param-goal-target-contributions=20000;msg-param-goal-user-contributions=1;msg-param-months=24;msg-param-origin-id=54\s41\s9a\s69\s6c\sb4\s3c\s8b\s0b\se4\sdf\s4c\sba\s5b\s9b\s23\s4c\sa7\s9b\sc4;msg-param-recipient-display-name=SomeoneOnTwitch;msg-param-recipient-id=5472062201;msg-param-recipient-user-name=someoneontwitch;msg-param-sub-plan-name=Channel\sSubscription\s(some_streamer);msg-param-sub-plan=1000;room-id=4920718204;subscriber=0;system-msg=An\sanonymous\suser\sgifted\sa\sTier\s1\ssub\sto\sSomeoneOnTwitch!\s;tmi-sent-ts=1685982143345;user-id=2745918607;user-type= :tmi.twitch.tv USERNOTICE #some_streamer";
    auto event = parser.toIRCEvent(fromServer);

    with (event)
    {
        assert((type == IRCEvent.Type.TWITCH_SUBGIFT), type.toString());
        assert((sender.nickname == "ananonymousgifter"), sender.nickname);
        assert((sender.address == "tmi.twitch.tv"), sender.address);
        assert((sender.account == "ananonymousgifter"), sender.account);
        assert((sender.displayName == "AnAnonymousGifter"), sender.displayName);
        assert((sender.badges == "*"), sender.badges);
        assert((sender.id == 2745918607), sender.id.to!string);
        assert((target.nickname == "someoneontwitch"), target.nickname);
        assert((target.account == "someoneontwitch"), target.account);
        assert((target.displayName == "SomeoneOnTwitch"), target.displayName);
        assert((target.id == 5472062201), target.id.to!string);
        assert((channel == "#some_streamer"), channel);
        assert((content == "An anonymous user gifted a Tier 1 sub to SomeoneOnTwitch!"), content);
        assert((aux[0] == "1000"), aux[0]);
        assert((aux[1] == "FunStringFour"), aux[1]);
        assert((aux[2] == "Channel Subscription (some_streamer)"), aux[2]);
        assert((aux[5] == "SUB_POINTS"), aux[5]);
        assert((count[0] == 1), count[0].to!string);
        assert((count[2] == 20000), count[2].to!string);
        assert((count[3] == 15624), count[3].to!string);
        assert((count[4] == 1), count[4].to!string);
        assert((tags == "badge-info=;badges=;color=;display-name=AnAnonymousGifter;emotes=;flags=;id=01af180f-5efd-40c8-94fb-d0a346c7fg86;login=ananonymousgifter;mod=0;msg-id=subgift;msg-param-fun-string=FunStringFour;msg-param-gift-months=1;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=15624;msg-param-goal-target-contributions=20000;msg-param-goal-user-contributions=1;msg-param-months=24;msg-param-origin-id=54\\s41\\s9a\\s69\\s6c\\sb4\\s3c\\s8b\\s0b\\se4\\sdf\\s4c\\sba\\s5b\\s9b\\s23\\s4c\\sa7\\s9b\\sc4;msg-param-recipient-display-name=SomeoneOnTwitch;msg-param-recipient-id=5472062201;msg-param-recipient-user-name=someoneontwitch;msg-param-sub-plan-name=Channel\\sSubscription\\s(some_streamer);msg-param-sub-plan=1000;room-id=4920718204;subscriber=0;system-msg=An\\sanonymous\\suser\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sSomeoneOnTwitch!\\s;tmi-sent-ts=1685982143345;user-id=2745918607;user-type="), tags);
        assert((id == "01af180f-5efd-40c8-94fb-d0a346c7fg86"), id);
    }
}
```

See the [**`/tests`**](/tests) directory for more example parses.

### Unit test generation

Compiling the `assertgen` dub subpackage builds a command-line tool with which it is easy to generate `assert` blocks like the ones above. These can then be pasted into an appropriate file in [**`/tests`**](tests), and ideally submitted as a GitHub pull request for upstream inclusion. You can use it to contribute known-good parses and increase coverage of event types.

Simply run `dub run :assertgen` and follow the on-screen instructions.

```
Enter daemon [optional daemon literal] (solanum): unreal
Enter network (Libera.Chat): foobar
Enter server address (irc.libera.chat): irc.server.tld

// 8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<  --  8<

[...]

// Paste a raw event string and hit Enter to generate an assert block. Ctrl+C to exit.

:irc.server.tld PRIVMSG #channel :i am a fish

{
    enum input = ":irc.server.tld PRIVMSG #channel :i am a fish";
    immutable event = parser.toIRCEvent(input);

    with (event)
    {
        assert(type == IRCEvent.Type.CHAN), type.toString());
        assert(sender.address == "irc.server.tld"), sender.address);
        assert(channel == "#channel"), channel);
        assert(content == "i am a fish"), content);
    }
}
```

The output will by default also be saved to a `unittest.log` file in the current directory. See the `--help` listing for more details, passed through `dub` with `dub run :assertgen -- --help`.

### Caveats

Starting with `v3.0.0`, a more recent compiler version is required. This is to allow for use of named arguments and to enable some compiler preview switches. You need a compiler based on D version **2.108** or later (April 2024). For **ldc** this translates to a minimum of version **1.38**, while for **gdc** you broadly need release series **14**.

If your repositories (or other software sources) don't have compilers recent enough, you can use the official [`install.sh`](https://dlang.org/install.html) installation script to download current ones, or any version of choice.

Releases of the library prior to `v3.0.0` remain available for older compilers.

Note that while IRC is standardised, servers still come in [many flavours](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/IRCd_software_implementations3.svg/1533px-IRCd_software_implementations3.svg.png), some of which [outright conflict](http://defs.ircdocs.horse/defs/numerics.html) with others.

**Please report bugs. Unreported bugs can only be fixed by accident.**

### Roadmap

* nothing right now, ideas needed

### Built with

* [**D**](https://dlang.org)
* [`lu`](https://github.com/zorael/lu) ([dub](http://code.dlang.org/packages/lu))

### License

This project is licensed under the **Boost Software License 1.0** - see the [LICENSE_1_0.txt](LICENSE_1_0.txt) file for details.
