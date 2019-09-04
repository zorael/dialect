# dialect

IRC parsing library. Used in the [kameloso bot](https://github.com/zorael/kameloso).

It's not `@nogc` but it's largely/fully (?) `@safe`.

# What it looks like

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
    version(RichClient)  // dub configuration "rich" (default)
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

        version(TwitchSupport)
        {
            string colour;
        }

        version(FlagUpdatedClient)
        {
            bool updated;
        }

        // More internals
    }
    else  // dub configuration "plain"
    {
        string nickname;
        IRCServer server;

        version(FlagUpdatedClient)
        {
            bool updated;
        }

        // More internals
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

Instantiate an `IRCClient` and configure its members. Read a string from the server and parse it with `IRCParser.toIRCEvent(string)`.

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

* set up CIs
* investigate `@nogc`
