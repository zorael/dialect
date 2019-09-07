# dialect [![CircleCI Linux/OSX](https://img.shields.io/circleci/project/github/zorael/dialect/master.svg?maxAge=3600&logo=circleci)](https://circleci.com/gh/zorael/dialect) [![Travis Linux/OSX and documentation](https://img.shields.io/travis/zorael/dialect/master.svg?maxAge=3600&logo=travis)](https://travis-ci.org/zorael/dialect) [![Windows](https://img.shields.io/appveyor/ci/zorael/dialect/master.svg?maxAge=3600&logo=appveyor)](https://ci.appveyor.com/project/zorael/dialect) [![GitHub commits since last release](https://img.shields.io/github/commits-since/zorael/dialect/v0.0.3.svg?maxAge=3600&logo=github)](https://github.com/zorael/dialect/compare/v0.0.3...master)

IRC parsing library with support for a wide variety of server daemons.

Note that while IRC is standardised, servers still come in [many flavours](https://upload.wikimedia.org/wikipedia/commons/thumb/d/d5/IRCd_software_implementations3.svg/1533px-IRCd_software_implementations3.svg.png), some of which [outright conflict](http://defs.ircdocs.horse/defs/numerics.html) with others. If something doesn't immediately work, generally it's because we simply haven't encountered that type of event before, and so no rules for how to parse it have yet been written.

**Please report bugs. Unreported bugs can only be fixed by accident.**

# What it looks like

API documentation can be found [here](https://zorael.github.io/dialect).

```d
struct IRCEvent
{
    enum Type { ... }

    Type type;
    string raw;
    IRCUser sender;
    string channel;
    IRCUser target;
    string content;
    string aux;
    string tags;
    uint num;
    int count;
    int altcount;
    long time;
    string errors;

    version(TwitchSupport)
    {
        string emotes;
        string id;
    }
}

struct IRCUser
{
    enum Class { ... }

    Class class_;
    string nickname;
    string alias_;
    string ident;
    string address;
    string account;
    long lastWhois;

    version(TwitchSupport)
    {
        string badges;
        string colour;
    }
}

struct IRCServer
{
    enum Daemon { ... }
    enum CaseMapping { ... }

    string address;
    ushort port;

    // More internals
}

struct IRCClient
{
    version(RichClient)  // dub configuration "rich"
    {
        string nickname;
        string user;
        string ident;
        string realName;
        string quitReason;
        string account;
        string password;
        string pass;

        IRCServer server;

        version(TwitchSupport)  // dub configuration "twitch"
        {
            string colour;
        }

        // More internals
    }
    else  // dub configuration "simple" (default)
    {
        string nickname;
        IRCServer server;

        // More internals
    }

    version(FlagUpdatedClient)
    {
        bool updated;
    }
}

struct IRCParser
{
    IRCClient client;

    IRCEvent toIRCEvent(const string) { ... }  // <--
}
```

# How to use

> This assumes you have a program set up to read information from an IRC server. This is not a bot framework; for that you're better off with the full [kameloso](https://github.com/zorael/kameloso) and writing a plugin that suits your needs.

Instantiate an `IRCParser` and configure its members, notably its `.client`. Read a string from the server and parse it with `IRCParser.toIRCEvent(string)`.

```d
IRCParser parser;

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

string alsoFromServer = ":cherryh.freenode.net 435 oldnick newnick #d " ~
    ":Cannot change nickname while banned on channel";
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

string furtherFromServer = ":kameloso^!~ident@81-233-105-99-no80.tbcn.telia.com NICK :kameloso_";
IRCEvent event3 = parser.toIRCEvent(furtherFromServer);

with (event3)
{
    assert(type == IRCEvent.Type.NICK);
    assert(sender.nickname == "kameloso^");
    assert(sender.ident == "~ident");
    assert(sender.address == "81-233-105-99-no80.tbcn.telia.com");
    assert(target.nickname = "kameloso_");
}
```

See the `/tests` directory for more example parses.

# Roadmap

* investigate `@nogc`
* fix AppVeyor failing to build `lu:core`

# License

This project is licensed under the **MIT** license - see the [LICENSE](LICENSE) file for details.
