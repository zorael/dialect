/++
 +  Helper functions needed to parse raw IRC event strings into `dialect.defs.IRCEvent`s.
 +
 +  Also things that don't belong anywhere else.
 +/
module dialect.common;

import dialect.defs;
import dialect.parsing;

public:

import lu.string : contains, nom;

@safe:


// typenumsOf
/++
 +  Returns the `typenums` mapping for a given `dialect.defs.IRCServer.Daemon`.
 +
 +  Example:
 +  ---
 +  IRCParser parser;
 +  IRCServer.Daemon daemon = IRCServer.Daemon.unreal;
 +  string daemonstring = "unreal";
 +
 +  parser.typenums = getTypenums(daemon);
 +  parser.client.daemon = daemon;
 +  parser.client.daemonstring = daemonstring;
 +  ---
 +
 +  Params:
 +      daemon = The `dialect.defs.IRCServer.Daemon` to get the typenums for.
 +
 +  Returns:
 +      A `typenums` array of `dialect.defs.IRCEvent`s mapped to numerics.
 +/
auto typenumsOf(const IRCServer.Daemon daemon) pure nothrow @nogc
{
    import lu.meld : MeldingStrategy, meldInto;
    import std.typecons : Flag, No, Yes;

    /// https://upload.wikimedia.org/wikipedia/commons/d/d5/IRCd_software_implementations3.svg

    IRCEvent.Type[1024] typenums = Typenums.base;

    alias strategy = MeldingStrategy.aggressive;

    with (Typenums)
    with (IRCServer.Daemon)
    final switch (daemon)
    {
    case unreal:
        Typenums.unreal.meldInto!strategy(typenums);
        break;

    case inspircd:
        Typenums.inspIRCd.meldInto!strategy(typenums);
        break;

    case bahamut:
        Typenums.bahamut.meldInto!strategy(typenums);
        break;

    case ratbox:
        Typenums.ratBox.meldInto!strategy(typenums);
        break;

    case u2:
        // unknown!
        break;

    case rizon:
        // Rizon is hybrid but has some own extras
        Typenums.hybrid.meldInto!strategy(typenums);
        Typenums.rizon.meldInto!strategy(typenums);
        break;

    case hybrid:
        Typenums.hybrid.meldInto!strategy(typenums);
        break;

    case ircu:
        Typenums.ircu.meldInto!strategy(typenums);
        break;

    case aircd:
        Typenums.aircd.meldInto!strategy(typenums);
        break;

    case rfc1459:
        Typenums.rfc1459.meldInto!strategy(typenums);
        break;

    case rfc2812:
        Typenums.rfc2812.meldInto!strategy(typenums);
        break;

    case snircd:
        // snircd is based on ircu
        Typenums.ircu.meldInto!strategy(typenums);
        Typenums.snircd.meldInto!strategy(typenums);
        break;

    case nefarious:
        // Both nefarious and nefarious2 are based on ircu
        Typenums.ircu.meldInto!strategy(typenums);
        Typenums.nefarious.meldInto!strategy(typenums);
        break;

    case rusnet:
        Typenums.rusnet.meldInto!strategy(typenums);
        break;

    case austhex:
        Typenums.austHex.meldInto!strategy(typenums);
        break;

    case ircnet:
        Typenums.ircNet.meldInto!strategy(typenums);
        break;

    case ptlink:
        Typenums.ptlink.meldInto!strategy(typenums);
        break;

    case ultimate:
        Typenums.ultimate.meldInto!strategy(typenums);
        break;

    case charybdis:
        Typenums.charybdis.meldInto!strategy(typenums);
        break;

    case ircdseven:
        // Nei | freenode is based in charybdis which is based on ratbox iirc
        Typenums.hybrid.meldInto!strategy(typenums);
        Typenums.ratBox.meldInto!strategy(typenums);
        Typenums.charybdis.meldInto!strategy(typenums);
        break;

    case undernet:
        Typenums.undernet.meldInto!strategy(typenums);
        break;

    case anothernet:
        //Typenums.anothernet.meldInto!strategy(typenums);
        break;

    case sorircd:
        Typenums.charybdis.meldInto!strategy(typenums);
        Typenums.sorircd.meldInto!strategy(typenums);
        break;

    case bdqircd:
        //Typenums.bdqIrcD.meldInto!strategy(typenums);
        break;

    case chatircd:
        //Typenums.chatIRCd.meldInto!strategy(typenums);
        break;

    case irch:
        //Typenums.irch.meldInto!strategy(typenums);
        break;

    case ithildin:
        //Typenums.ithildin.meldInto!strategy(typenums);
        break;

    case twitch:
        // do nothing, their events aren't numerical?
        break;

    case unknown:
    case unset:
        // do nothing...
        break;
    }

    return typenums;
}


// isSpecial
/++
 +  Judges whether or not an `dialect.defs.IRCUser` is *special*.
 +
 +  Special senders include services and staff, administrators and the like. The
 +  use of this is contested and the notion may be removed at a later date.
 +
 +  Params:
 +      parser = Reference to the current `dialect.parsing.IRCParser`.
 +      sender = `dialect.defs.IRCUser` to examine.
 +
 +  Returns:
 +      `true` if it passes the special checks, `false` if not.
 +/
bool isSpecial(const ref IRCParser parser, const IRCUser sender) pure
{
    import lu.string : sharedDomains;
    import std.uni : toLower;

    with (parser)
    {
        if (sender.isServer || (sender.address.length &&
            ((sender.address == server.address) ||
            (sender.address == server.resolvedAddress) ||
            (sender.address == "services."))))
        {
            return true;
        }

        immutable service = sender.nickname.toLower;

        switch (service)
        {
        case "nickserv":
        case "saslserv":
            switch (sender.ident)
            {
            case "NickServ":
            case "SaslServ":
                if (sender.address == "services.") return true;
                break;

            case "services":
            case "service":
                // known idents, drop to after switch
                break;

            default:
                // Unknown ident, try the generic address check after the switch
                break;
            }
            break;

        /*case "chanserv":
        case "operserv":
        case "memoserv":
        case "hostserv":
        case "botserv":
        case "infoserv":
        case "reportserv":
        case "moraleserv":
        case "gameserv":
        case "groupserv":
        case "helpserv":
        case "statserv":
        case "userserv":
        case "spamserv":*/
        case "global":
        case "alis":
        case "chanfix":
        case "c":
        case "services.":
            // Known services that are not nickname services
            return true;

        case "q":
            // :Q!TheQBot@CServe.quakenet.org NOTICE kameloso :You are now logged in as kameloso.
            return ((sender.ident == "TheQBot") && (sender.address == "CServe.quakenet.org"));

        case "authserv":
            // :AuthServ!AuthServ@Services.GameSurge.net NOTICE kameloso :Could not find your account
            return ((sender.ident == "AuthServ") && (sender.address == "Services.GameSurge.net"));

        default:
            import std.algorithm.searching : endsWith;
            return service.endsWith("serv");
        }

        if ((parser.server.daemon != IRCServer.Daemon.twitch) &&
            ((sharedDomains(sender.address, parser.server.address) >= 2) ||
            (sharedDomains(sender.address, parser.server.resolvedAddress) >= 2)))
        {
            return true;
        }
        else if (sender.address.contains("/staff/"))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
}


// isSpecial
/++
 +  Judges whether or not the sender of an `dialect.defs.IRCEvent` is *special*.
 +
 +  Special senders include services and staff, administrators and the like. The
 +  use of this is contested and the notion may be removed at a later date.
 +
 +  Deprecated oveload that takes an `dialect.defs.IRCEvent` instead of the real
 +  overload that takes an `dialect.defs.IRCUser`.
 +
 +  Params:
 +      parser = Reference to the current `dialect.parsing.IRCParser`.
 +      event = `dialect.defs.IRCEvent` to examine.
 +
 +  Returns:
 +      `true` if it passes the special checks, `false` if not.
 +/
deprecated("Use the `isSpecial(IRCParser, IRCUser)` overload")
bool isSpecial(const ref IRCParser parser, const IRCEvent event) pure
{
    return isSpecial(parser, event.sender);
}


// decodeIRCv3String
/++
 +  Decodes an IRCv3 tag string, replacing some characters.
 +
 +  IRCv3 tags need to be free of spaces, so by necessity they're encoded into
 +  `\s`. Likewise; since tags are separated by semicolons, semicolons in tag
 +  string are encoded into `\:`, and literal backslashes `\\`.
 +
 +  Example:
 +  ---
 +  string encoded = `This\sline\sis\sencoded\:\swith\s\\s`;
 +  string decoded = decodeIRCv3String(encoded);
 +  assert(decoded == "This line is encoded; with \\s");
 +  ---
 +
 +  Params:
 +      line = Original line to decode.
 +
 +  Returns:
 +      A decoded string without `\s` in it.
 +/
string decodeIRCv3String(const string line) pure nothrow
{
    import std.array : Appender;
    import std.string : representation;

    /++
     +  - http://ircv3.net/specs/core/message-tags-3.2.html
     +
     +  If a lone \ exists at the end of an escaped value (with no escape
     +  character following it), then there SHOULD be no output character.
     +  For example, the escaped value test\ should unescape to test.
     +/

    if (!line.length) return string.init;

    Appender!string sink;
    sink.reserve(line.length);

    bool escaping;

    foreach (immutable c; line.representation)
    {
        if (escaping)
        {
            switch (c)
            {
            case '\\':
                sink.put('\\');
                break;

            case ':':
                sink.put(';');
                break;

            case 's':
                sink.put(' ');
                break;

            case 'n':
                sink.put('\n');
                break;

            case 't':
                sink.put('\t');
                break;

            case 'r':
                sink.put('\r');
                break;

            case '0':
                sink.put('\0');
                break;

            default:
                // Unknown escape
                sink.put(c);
            }

            escaping = false;
        }
        else
        {
            switch (c)
            {
            case '\\':
                escaping = true;
                break;

            default:
                sink.put(c);
            }
        }
    }

    return sink.data;
}

///
unittest
{
    immutable s1 = decodeIRCv3String(`kameloso\sjust\ssubscribed\swith\sa\s` ~
        `$4.99\ssub.\skameloso\ssubscribed\sfor\s40\smonths\sin\sa\srow!`);
    assert((s1 == "kameloso just subscribed with a $4.99 sub. " ~
        "kameloso subscribed for 40 months in a row!"), s1);

    immutable s2 = decodeIRCv3String(`stop\sspamming\scaps,\sautomated\sby\sNightbot`);
    assert((s2 == "stop spamming caps, automated by Nightbot"), s2);

    immutable s3 = decodeIRCv3String(`\:__\:`);
    assert((s3 == ";__;"), s3);

    immutable s4 = decodeIRCv3String(`\\o/ \\o\\ /o/ ~o~`);
    assert((s4 == `\o/ \o\ /o/ ~o~`), s4);

    immutable s5 = decodeIRCv3String(`This\sis\sa\stest\`);
    assert((s5 == "This is a test"), s5);

    immutable s6 = decodeIRCv3String(`9\sraiders\sfrom\sVHSGlitch\shave\sjoined\n!`);
    assert((s6 == "9 raiders from VHSGlitch have joined\n!"), s6);
}


// isFromAuthService
/++
 +  Inspects an `dialect.defs.IRCUser` and judges whether or not it is services.
 +
 +  Example:
 +  ---
 +  IRCUser user;
 +  if (parser.isFromAuthService(user))
 +  {
 +      // ...
 +  }
 +  ---
 +
 +  Params:
 +      parser = Reference to the current `dialect.parsing.IRCParser`.
 +      sender = `dialect.defs.IRCUser` to examine.
 +
 +  Returns:
 +      `true` if the `sender` is judged to be from nickname services, `false` if not.
 +/
bool isFromAuthService(const ref IRCParser parser, const IRCUser sender) pure
{
    import lu.string : sharedDomains;
    import std.uni : toLower;

    immutable lowerNickname = sender.nickname.toLower;

    switch (lowerNickname)
    {
    case "nickserv":
    case "saslserv":
        switch (sender.ident)
        {
        case "NickServ":
        case "SaslServ":
            if (sender.address == "services.") return true;
            break;

        case "services":
        case "service":
            // known idents, drop to after switch
            break;

        default:
            // Unknown ident, try the generic address check after the switch
            break;
        }
        break;

    /*case "chanserv":
    case "operserv":
    case "memoserv":
    case "hostserv":
    case "botserv":
    case "infoserv":
    case "reportserv":
    case "moraleserv":
    case "gameserv":
    case "groupserv":
    case "helpserv":
    case "statserv":
    case "userserv":
    case "spamserv":*/
    case "global":
    case "alis":
    case "chanfix":
    case "c":
    case "services.":
        // Known services that are not nickname services
        return false;

    case "q":
        // :Q!TheQBot@CServe.quakenet.org NOTICE kameloso :You are now logged in as kameloso.
        return ((sender.ident == "TheQBot") && (sender.address == "CServe.quakenet.org"));

    case "authserv":
        // :AuthServ!AuthServ@Services.GameSurge.net NOTICE kameloso :Could not find your account
        return ((sender.ident == "AuthServ") && (sender.address == "Services.GameSurge.net"));

    default:
        import std.algorithm.searching : endsWith;

        if (sender.address.contains("/staff/"))
        {
            // Staff notice
            return false;
        }
        else if (lowerNickname.endsWith("serv"))
        {
            return false;
        }

        // Not a known nick registration nick
        /*logger.warningf("Unknown nickname service nick: %s!%s@%s",
            sender.nickname, sender.ident, sender.address);
        printObject(event);*/
        return false;
    }

    if ((sharedDomains(sender.address, parser.server.address) >= 2) ||
        (sharedDomains(sender.address, parser.server.resolvedAddress) >= 2))
    {
        return true;
    }
    else
    {
        return false;
    }
}

unittest
{
    IRCParser parser;

    IRCEvent e1;
    with (e1)
    {
        raw = ":Q!TheQBot@CServe.quakenet.org NOTICE kameloso :You are now logged in as kameloso.";
        string slice = raw[1..$];  // mutable
        parser.parsePrefix(e1, slice);
        assert(parser.isFromAuthService(e1.sender));
    }

    IRCEvent e2;
    with (e2)
    {
        raw = ":NickServ!NickServ@services. NOTICE kameloso :This nickname is registered.";
        string slice = raw[1..$];
        parser.parsePrefix(e2, slice);
        assert(parser.isFromAuthService(e2.sender));
    }

    IRCEvent e3;
    with (e3)
    {
        parser.server.address = "irc.rizon.net";
        parser.server.resolvedAddress = "irc.uworld.se";
        raw = ":NickServ!service@rizon.net NOTICE kameloso^^ :nick, type /msg NickServ IDENTIFY password. Otherwise,";
        string slice = raw[1..$];
        parser.parsePrefix(e3, slice);
        assert(parser.isFromAuthService(e3.sender));
    }

    // Enabling this stops us from being alerted of unknown services
    /*IRCEvent e4;
    with (e4)
    {
        raw = ":zorael!~NaN@ns3363704.ip-94-23-253.eu PRIVMSG kameloso^ :sudo privmsg zorael :derp";
        string slice = raw[1..$];
        parser.parsePrefix(e4, slice);
        assert(!parser.isFromAuthService(e4.sender));
    }*/
}


// isFromAuthService
/++
 +  Inspects an `dialect.defs.IRCEvent` and judges whether or not it is from services.
 +
 +  Deprecated oveload that takes an `dialect.defs.IRCEvent` instead of the real
 +  overload that takes an `dialect.defs.IRCUser`.
 +
 +  Example:
 +  ---
 +  IRCEvent event;
 +  if (parser.isFromAuthService(event))
 +  {
 +      // ...
 +  }
 +  ---
 +
 +  Params:
 +      parser = Reference to the current `dialect.parsing.IRCParser`.
 +      event = `dialect.defs.IRCEvent` to examine.
 +
 +  Returns:
 +      `true` if the `sender` is judged to be from nickname services, `false` if not.
 +/
deprecated("Use the `isFromAuthService(IRCParser, IRCUser)` overload")
bool isFromAuthService(const ref IRCParser parser, const IRCEvent event) pure
{
    return isFromAuthService(parser, event.sender);
}


// isValidChannel
/++
 +  Examines a string and judges whether or not it *looks* like a channel.
 +
 +  It needs to be passed an `dialect.defs.IRCServer` to know the max
 +  channel name length. An alternative would be to change the
 +  `dialect.defs.IRCServer` parameter to be an `uint`.
 +
 +  Example:
 +  ---
 +  IRCServer server;
 +  assert("#channel".isValidChannel(server));
 +  assert("##channel".isValidChannel(server));
 +  assert(!"!channel".isValidChannel(server));
 +  assert(!"#ch#annel".isValidChannel(server));
 +  ---
 +
 +  Params:
 +      channel = String of a potential channel name.
 +      server = The current `dialect.defs.IRCServer` with all its settings.
 +
 +  Returns:
 +      `true` if the string content is judged to be a channel, `false` if not.
 +/
bool isValidChannel(const string channel, const IRCServer server) pure nothrow @nogc
in (channel.length, "Tried to determine whether a channel was valid but no channel was given")
do
{
    import lu.string : beginsWithOneOf;
    import std.string : representation;

    /++
     +  Channels names are strings (beginning with a '&' or '#' character) of
     +  length up to 200 characters.  Apart from the the requirement that the
     +  first character being either '&' or '#'; the only restriction on a
     +  channel name is that it may not contain any spaces (' '), a control G
     +  (^G or ASCII 7), or a comma (',' which is used as a list item
     +  separator by the protocol).
     +
     +  - https://tools.ietf.org/html/rfc1459.html
     +/
    if ((channel.length < 2) || (channel.length > server.maxChannelLength))
    {
        // Too short or too long a word
        return false;
    }

    if (!channel.beginsWithOneOf(server.chantypes)) return false;

    if (channel.contains(' ') ||
        channel.contains(',') ||
        channel.contains(7))
    {
        // Contains spaces, commas or byte 7
        return false;
    }

    if (channel.length == 2) return !channel[1].beginsWithOneOf(server.chantypes);
    else if (channel.length == 3) return !channel[2].beginsWithOneOf(server.chantypes);
    else if (channel.length > 3)
    {
        // Allow for two ##s (or &&s) in the name but no more
        foreach (immutable chansign; server.chantypes.representation)
        {
            if (channel[2..$].contains(chansign)) return false;
        }
        return true;
    }
    else
    {
        return false;
    }
}

///
unittest
{
    IRCServer s;
    s.chantypes = "#&";

    assert("#channelName".isValidChannel(s));
    assert("&otherChannel".isValidChannel(s));
    assert("##freenode".isValidChannel(s));
    assert(!"###froonode".isValidChannel(s));
    assert(!"#not a channel".isValidChannel(s));
    assert(!"notAChannelEither".isValidChannel(s));
    assert(!"#".isValidChannel(s));
    //assert(!"".isValidChannel(s));
    assert(!"##".isValidChannel(s));
    assert(!"&&".isValidChannel(s));
    assert("#d".isValidChannel(s));
    assert("#uk".isValidChannel(s));
    assert(!"###".isValidChannel(s));
    assert(!"#a#".isValidChannel(s));
    assert(!"a".isValidChannel(s));
    assert(!" ".isValidChannel(s));
    //assert(!"".isValidChannel(s));
}


// isValidNickname
/++
 +  Examines a string and judges whether or not it *looks* like a nickname.
 +
 +  It only looks for invalid characters in the name as well as it length.
 +
 +  Example:
 +  ---
 +  assert("kameloso".isValidNickname);
 +  assert("kameloso^".isValidNickname);
 +  assert("kamelåså".isValidNickname);
 +  assert(!"#kameloso".isValidNickname);
 +  assert(!"k&&me##so".isValidNickname);
 +  ---
 +
 +  Params:
 +      nickname = String nickname.
 +      server = The current `dialect.defs.IRCServer` with all its settings.
 +
 +  Returns:
 +      `true` if the nickname string is judged to be a nickname, `false` if not.
 +/
bool isValidNickname(const string nickname, const IRCServer server) pure nothrow @nogc
in (nickname.length, "Tried to determine whether a nickname was valid but no nickname was given")
do
{
    import std.string : representation;

    if (!nickname.length || (nickname.length > server.maxNickLength))
    {
        return false;
    }

    foreach (immutable c; nickname.representation)
    {
        if (!c.isValidNicknameCharacter) return false;
    }

    return true;
}

///
unittest
{
    import std.range : repeat;
    import std.conv : to;

    IRCServer s;

    immutable validNicknames =
    [
        "kameloso",
        "kameloso^",
        "zorael-",
        "hirr{}",
        "asdf`",
        "[afk]me",
        "a-zA-Z0-9",
        `\`,
    ];

    immutable invalidNicknames =
    [
        //"",
        "X".repeat(s.maxNickLength+1).to!string,
        "åäöÅÄÖ",
        "\n",
        "¨",
        "@pelle",
        "+calvin",
        "&hobbes",
        "#channel",
        "$deity",
    ];

    foreach (immutable nickname; validNicknames)
    {
        assert(nickname.isValidNickname(s), nickname);
    }

    foreach (immutable nickname; invalidNicknames)
    {
        assert(!nickname.isValidNickname(s), nickname);
    }
}


// isValidNicknameCharacter
/++
 +  Returns whether or not a passed `char` can be part of a nickname.
 +
 +  The IRC standard describes nicknames as being a string of any of the
 +  following characters:
 +
 +  `[a-z] [A-Z] [0-9] _-\[]{}^`|`
 +
 +  Example:
 +  ---
 +  assert('a'.isValidNicknameCharacter);
 +  assert('9'.isValidNicknameCharacter);
 +  assert('`'.isValidNicknameCharacter);
 +  assert(!(' '.isValidNicknameCharacter));
 +  ---
 +
 +  Params:
 +      c = Character to compare with the list of accepted characters in a nickname.
 +
 +  Returns:
 +      `true` if the character is in the list of valid characters for
 +      nicknames, `false` if not.
 +/
pragma(inline)
bool isValidNicknameCharacter(const ubyte c) pure nothrow @nogc
{
    switch (c)
    {
    case 'a':
    ..
    case 'z':
    case 'A':
    ..
    case 'Z':
    case '0':
    ..
    case '9':
    case '_':
    case '-':
    case '\\':
    case '[':
    case ']':
    case '{':
    case '}':
    case '^':
    case '`':
    case '|':
        return true;
    default:
        return false;
    }
}

///
unittest
{
    import std.string : representation;

    {
        immutable line = "abcDEFghi0{}29304_[]`\\^|---";
        foreach (immutable char c; line.representation)
        {
            assert(c.isValidNicknameCharacter, c ~ "");
        }
    }

    assert(!' '.isValidNicknameCharacter);
}


// containsNickname
/++
 +  Searches a string for a substring that isn't surrounded by characters that
 +  can be part of a nickname. This can detect a nickname in a string without
 +  getting false positives from similar nicknames.
 +
 +  Uses `std.string.indexOf` internally with hopes of being more resilient to
 +  weird UTF-8.
 +
 +  Params:
 +      haystack = A string to search for the substring nickname.
 +      needle = The nickname substring to find in `haystack`.
 +
 +  Returns:
 +      True if `haystack` contains `needle` in such a way that it is guaranteed
 +      to not be a different nickname.
 +/
bool containsNickname(const string haystack, const string needle) pure nothrow @nogc
{
    import std.string : indexOf;

    if ((haystack.length == needle.length) && (haystack == needle)) return true;

    // What do we do with empty strings?
    if (!needle.length) return false;

    immutable pos = haystack.indexOf(needle);
    if (pos == -1) return false;

    // Allow for a prepended @, since @mention is commonplace
    if ((pos > 0) && haystack[pos-1].isValidNicknameCharacter &&
        (haystack[pos-1] != '@')) return false;

    immutable end = pos + needle.length;

    if (end > haystack.length)
    {
        return false;
    }
    else if (end == haystack.length)
    {
        return true;
    }

    return (!haystack[end].isValidNicknameCharacter);
}

///
unittest
{
    assert("kameloso".containsNickname("kameloso"));
    assert(" kameloso ".containsNickname("kameloso"));
    assert(!"kam".containsNickname("kameloso"));
    assert(!"kameloso^".containsNickname("kameloso"));
    assert(!string.init.containsNickname("kameloso"));
    assert(!"kameloso".containsNickname(""));  // For now let this be false.
    assert("@kameloso".containsNickname("kameloso"));
}


// stripModesign
/++
 +  Takes a nickname and strips it of any prepended mode signs, like the `@` in
 +  `@nickname`. Saves the stripped signs in the ref string `modesigns`.
 +
 +  Example:
 +  ---
 +  IRCServer server;
 +  immutable signed = "@+kameloso";
 +  string signs;
 +  immutable nickname = server.stripModeSign(signed, signs);
 +  assert((nickname == "kameloso"), nickname);
 +  assert((signs == "@+"), signs);
 +  ---
 +
 +  Params:
 +      server = `dialect.defs.IRCServer`, with all its settings.
 +      nickname = String with a signed nickname.
 +      modesigns = Reference string to write the stripped modesigns to.
 +
 +  Returns:
 +      The nickname without any prepended prefix signs.
 +/
string stripModesign(const IRCServer server, const string nickname,
    ref string modesigns) pure nothrow @nogc
{
    if (!nickname.length) return string.init;

    size_t i;

    for (i = 0; i<nickname.length; ++i)
    {
        if (nickname[i] !in server.prefixchars)
        {
            break;
        }
    }

    modesigns = nickname[0..i];
    return nickname[i..$];
}

///
unittest
{
    IRCServer server;
    server.prefixchars =
    [
        '@' : 'o',
        '+' : 'v',
        '%' : 'h',
    ];

    {
        immutable signed = "@kameloso";
        string signs;
        immutable nickname = server.stripModesign(signed, signs);
        assert((nickname == "kameloso"), nickname);
        assert((signs == "@"), signs);
    }

    {
        immutable signed = "kameloso";
        string signs;
        immutable nickname = server.stripModesign(signed, signs);
        assert((nickname == "kameloso"), nickname);
        assert(!signs.length, signs);
    }

    {
        immutable signed = "@+kameloso";
        string signs;
        immutable nickname = server.stripModesign(signed, signs);
        assert((nickname == "kameloso"), nickname);
        assert((signs == "@+"), signs);
    }
}


// stripModesign
/++
 +  Convenience function to `stripModesign` that doesn't take a ref string
 +  parameter to store the stripped modesign characters in.
 +
 +  Example:
 +  ---
 +  IRCServer server;
 +  immutable signed = "@+kameloso";
 +  immutable nickname = server.stripModeSign(signed);
 +  assert((nickname == "kameloso"), nickname);
 +  assert((signs == "@+"), signs);
 +  ---
 +
 +  Params:
 +      server = The `dialect.defs.IRCServer` whose prefix characters to strip.
 +      nickname = The (potentially) signed nickname to strip the prefix off.
 +
 +  Returns:
 +      The raw nickname, unsigned.
 +/
string stripModesign(const IRCServer server, const string nickname) pure nothrow @nogc
{
    string nothing;
    return stripModesign(server, nickname, nothing);
}

///
unittest
{
    IRCServer server;
    server.prefixchars =
    [
        '@' : 'o',
        '+' : 'v',
        '%' : 'h',
    ];

    {
        immutable signed = "@+kameloso";
        immutable nickname = server.stripModesign(signed);
        assert((nickname == "kameloso"), nickname);
    }
}


// setMode
/++
 +  Sets a new or removes a `dialect.defs.IRCChannel.Mode`.
 +
 +  `dialect.defs.IRCChannel.Mode`s that are merely a character in `modechars` are simply removed if
 +   the *sign* of the mode change is negative, whereas a more elaborate
 +  `dialect.defs.IRCChannel.Mode` in the `modes` array are only replaced or removed if they match a
 +   comparison test.
 +
 +  Several modes can be specified at once, including modes that take a
 +  `data` argument, assuming they are in the proper order (where the
 +  `data`-taking modes are at the end of the string).
 +
 +  Example:
 +  ---
 +  IRCChannel channel;
 +  channel.setMode("+oo zorael!NaN@* kameloso!*@*")
 +  assert(channel.modes.length == 2);
 +  channel.setMode("-o kameloso!*@*");
 +  assert(channel.modes.length == 1);
 +  channel.setMode("-o *!*@*");
 +  assert(!channel.modes.length);
 +  ---
 +
 +  Params:
 +      channel = `dialect.defs.IRCChannel` whose modes are being set.
 +      signedModestring = String of the raw mode command, including the
 +          prefixing sign (+ or -).
 +      data = Appendix to the signed modestring; arguments to the modes that
 +          are being set.
 +      server = The current `dialect.defs.IRCServer` with all its settings.
 +/
void setMode(ref IRCChannel channel, const string signedModestring,
    const string data, IRCServer server) pure
{
    import lu.string : beginsWith;
    import std.array : array;
    import std.algorithm.iteration : splitter;
    import std.range : StoppingPolicy, retro, zip;
    import std.string : representation;

    if (!signedModestring.length) return;

    struct SignedModechar
    {
        char sign;
        char modechar;
    }

    char nextSign = '+';
    SignedModechar[] modecharArray;

    foreach (immutable c; signedModestring.representation)
    {
        if ((c == '+') || (c == '-'))
        {
            nextSign = c;
        }
        else
        {
            modecharArray ~= SignedModechar(nextSign, c);
        }
    }

    if (!modecharArray.length) return;

    auto datalines = data.splitter(" ").array.retro;
    auto moderange = modecharArray.retro;
    auto ziprange = zip(StoppingPolicy.longest, moderange, datalines);

    IRCUser[] carriedExceptions;

    ziploop:
    foreach (immutable signedModechar, immutable datastring; ziprange)
    {
        immutable modechar = signedModechar.modechar;
        immutable sign = signedModechar.sign;

        IRCChannel.Mode newMode;
        newMode.modechar = modechar;

        if ((modechar == server.exceptsChar) || (modechar == server.invexChar))
        {
            // Exception, carry it to the next aMode
            carriedExceptions ~= IRCUser(datastring);
            continue;
        }

        if (!datastring.beginsWith(server.extbanPrefix) && datastring.contains('!') && datastring.contains('@'))
        {
            // Looks like a user and not an extban
            newMode.user = IRCUser(datastring);
        }
        else if (datastring.beginsWith(server.extbanPrefix))
        {
            // extban; https://freenode.net/kb/answer/extbans
            // https://defs.ircdocs.horse/defs/extbans.html
            // Does not support a mix of normal and second form bans
            // e.g. *!*@*$#channel

            /+ extban format:
            "$a:dannylee$##arguments"
            "$a:shr000ms"
            "$a:deadfrogs"
            "$a:b4b"
            "$a:terabits$##arguments"
            // "$x:*0x71*"
            "$a:DikshitNijjer"
            "$a:NETGEAR_WNDR3300"
            "$~a:eir"+/
            string slice = datastring[1..$];

            if (slice[0] == '~')
            {
                // Negated extban
                newMode.negated = true;
                slice = slice[1..$];
            }

            switch (slice[0])
            {
            case 'a':
            case 'R':
                // Match account
                if (slice.contains(':'))
                {
                    // More than one field
                    slice.nom(':');

                    if (slice.contains('$'))
                    {
                        // More than one field, first is account
                        newMode.user.account = slice.nom('$');
                        newMode.data = slice;
                    }
                    else
                    {
                        // Whole slice is an account
                        newMode.user.account = slice;
                    }
                }
                else
                {
                    // "$~a"
                    // "$R"
                    // FIXME: Figure out how to express this.
                    if (slice.length)
                    {
                        newMode.data = slice;
                    }
                    else
                    {
                        newMode.data = datastring;
                    }
                }
                break;

            case 'j':
            //case 'c':  // Conflicts with colour ban
                // Match channel
                slice.nom(':');
                newMode.channel = slice;
                break;

            /*case 'r':
                // GECOS/Real name, which we aren't saving currently.
                // Can be done if there's a use-case for it.
                break;*/

            /*case 's':
                // Which server the user(s) the mode refers to are connected to
                // which we aren't saving either. Can also be fixed.
                break;*/

            default:
                // Unhandled extban mode
                newMode.data = datastring;
                break;
            }
        }
        else
        {
            // Normal, non-user non-extban mode
            newMode.data = datastring;
        }

        if (sign == '+')
        {
            if (server.prefixes.contains(modechar))
            {
                import std.algorithm.searching : canFind;

                // Register users with prefix modes (op, halfop, voice, ...)
                auto prefixedUsers = newMode.modechar in channel.mods;
                if (prefixedUsers && (*prefixedUsers).canFind(newMode.data))
                {
                    continue;
                }

                channel.mods[newMode.modechar] ~= newMode.data;
                continue;
            }
            else if (server.aModes.contains(modechar))
            {
                /++
                 +  A = Mode that adds or removes a nick or address to a
                 +  list. Always has a parameter.
                 +/

                // STACKS.
                // If an identical Mode exists, add exceptions and skip
                foreach (ref listedMode; channel.modes)
                {
                    if (listedMode == newMode)
                    {
                        listedMode.exceptions ~= carriedExceptions;
                        carriedExceptions.length = 0;
                        continue ziploop;
                    }
                }

                newMode.exceptions ~= carriedExceptions;
                carriedExceptions.length = 0;
            }
            else if (server.bModes.contains(modechar) || server.cModes.contains(modechar))
            {
                /++
                 +  B = Mode that changes a setting and always has a
                 +  parameter.
                 +
                 +  C = Mode that changes a setting and only has a
                 +  parameter when set.
                 +/

                // DOES NOT STACK.
                // If an identical Mode exists, overwrite
                foreach (ref listedMode; channel.modes)
                {
                    if (listedMode.modechar == modechar)
                    {
                        listedMode = newMode;
                        continue ziploop;
                    }
                }
            }
            else /*if (server.dModes.contains(modechar))*/
            {
                // Some clients assume that any mode not listed is of type D
                if (!channel.modechars.contains(modechar)) channel.modechars ~= modechar;
                continue;
            }

            channel.modes ~= newMode;
        }
        else if (sign == '-')
        {
            import std.algorithm.mutation : SwapStrategy, remove;

            if (server.prefixes.contains(modechar))
            {
                import std.algorithm.searching : countUntil;

                // Remove users with prefix modes (op, halfop, voice, ...)
                auto prefixedUsers = newMode.modechar in channel.mods;
                if (!prefixedUsers) continue;

                immutable index = (*prefixedUsers).countUntil(newMode.data);
                if (index != -1)
                {
                    *prefixedUsers = (*prefixedUsers).remove!(SwapStrategy.unstable)(index);
                }
            }
            else if (server.aModes.contains(modechar))
            {
                /++
                 +  A = Mode that adds or removes a nick or address to a
                 +  a list. Always has a parameter.
                 +/

                // If a comparison matches, remove
                channel.modes = channel.modes.remove!((listed => listed == newMode), SwapStrategy.unstable);
            }
            else if (server.bModes.contains(modechar) || server.cModes.contains(modechar))
            {
                /++
                 +  B = Mode that changes a setting and always has a
                 +  parameter.
                 +
                 +  C = Mode that changes a setting and only has a
                 +  parameter when set.
                 +/

                // If the modechar matches, remove
                channel.modes = channel.modes.remove!((listed =>
                    listed.modechar == newMode.modechar), SwapStrategy.unstable);
            }
            else /*if (server.dModes.contains(modechar))*/
            {
                // Some clients assume that any mode not listed is of type D
                import std.string : indexOf;

                immutable modecharIndex = channel.modechars.indexOf(modechar);
                if (modecharIndex != -1)
                {
                    import std.string : representation;

                    // Remove the char from the modechar string
                    channel.modechars = cast(string)channel.modechars
                        .dup
                        .representation
                        .remove!(SwapStrategy.unstable)(modecharIndex)
                        .idup;
                }
            }
        }
        else
        {
            assert(0, "Invalid mode sign: " ~ sign);
        }
    }
}

///
unittest
{
    import std.conv;
    import std.stdio;

    IRCServer server;
    // Freenode: CHANMODES=eIbq,k,flj,CFLMPQScgimnprstz
    with (server)
    {
        aModes = "eIbq";
        bModes = "k";
        cModes = "flj";
        dModes = "CFLMPQScgimnprstz";

        // SpotChat: PREFIX=(Yqaohv)!~&@%+
        prefixes = "Yaohv";
        prefixchars =
        [
            '!' : 'Y',
            '&' : 'a',
            '@' : 'o',
            '%' : 'h',
            '+' : 'v',
        ];

        extbanPrefix = '$';
        exceptsChar = 'e';
        invexChar = 'I';
    }

    {
        IRCChannel chan;

        chan.topic = "Huerbla";

        chan.setMode("+b", "kameloso!~NaN@aasdf.freenode.org", server);
        //foreach (i, mode; chan.modes) writefln("%2d: %s", i, mode);
        //writeln("-------------------------------------");
        assert((chan.modes.length == 1), chan.modes.length.to!string);

        chan.setMode("+bbe", "hirrsteff!*@* harblsnarf!ident@* NICK!~IDENT@ADDRESS", server);
        //foreach (i, mode; chan.modes) writefln("%2d: %s", i, mode);
        //writeln("-------------------------------------");
        assert((chan.modes.length == 3), chan.modes.length.to!string);

        chan.setMode("-b", "*!*@*", server);
        //foreach (i, mode; chan.modes) writefln("%2d: %s", i, mode);
        //writeln("-------------------------------------");
        assert((chan.modes.length == 3), chan.modes.length.to!string);

        chan.setMode("+i", string.init, server);
        assert(chan.modechars == "i", chan.modechars);

        chan.setMode("+v", "harbl", server);
        assert(chan.modechars == "i", chan.modechars);

        chan.setMode("-i", string.init, server);
        assert(!chan.modechars.length, chan.modechars);

        chan.setMode("+l", "200", server);
        IRCChannel.Mode lMode;
        lMode.modechar = 'l';
        lMode.data = "200";
        //foreach (i, mode; chan.modes) writefln("%2d: %s", i, mode);
        //writeln("-------------------------------------");
        assert((chan.modes[3] == lMode), chan.modes[3].to!string);

        chan.setMode("+l", "100", server);
        lMode.modechar = 'l';
        lMode.data = "100";
        //foreach (i, mode; chan.modes) writefln("%2d: %s", i, mode);
        //writeln("-------------------------------------");
        assert((chan.modes[3] == lMode), chan.modes[3].to!string);
    }

    {
        IRCChannel chan;

        chan.setMode("+CLPcnprtf", "##linux-overflow", server);
        //foreach (i, mode; chan.modes) writefln("%2d: %s", i, mode);
        //writeln("-------------------------------------");
        assert(chan.modes[0].data == "##linux-overflow");
        assert(chan.modes.length == 1);
        assert(chan.modechars.length == 8);

        chan.setMode("+bee", "mynick!myident@myaddress abc!def@ghi jkl!*@*", server);
        //foreach (i, mode; chan.modes) writefln("%2d: %s", i, mode);
        //writeln("-------------------------------------");
        assert(chan.modes.length == 2);
        assert(chan.modes[1].exceptions.length == 2);
    }

    {
        IRCChannel chan;

        chan.setMode("+ns", string.init, server);
        foreach (i, mode; chan.modes) writefln("%2d: %s", i, mode);
        assert(chan.modes.length == 0);
        assert(chan.modechars == "sn", chan.modechars);

        chan.setMode("-sn", string.init, server);
        foreach (i, mode; chan.modes) writefln("%2d: %s", i, mode);
        assert(chan.modes.length == 0);
        assert(chan.modechars.length == 0);
    }

    {
        IRCChannel chan;
        chan.setMode("+oo", "kameloso zorael", server);
        assert(chan.mods['o'].length == 2);
        chan.setMode("-o", "kameloso", server);
        assert(chan.mods['o'].length == 1);
        chan.setMode("-o", "zorael", server);
        assert(!chan.mods['o'].length);
    }

    {
        IRCChannel chan;
        server.extbanPrefix = '$';

        chan.setMode("+b", "$a:hirrsteff", server);
        assert(chan.modes.length);
        with (chan.modes[0])
        {
            assert((modechar == 'b'), modechar.text);
            assert((user.account == "hirrsteff"), user.account);
        }

        chan.setMode("+q", "$~a:blarf", server);
        assert((chan.modes.length == 2), chan.modes.length.text);
        with (chan.modes[1])
        {
            assert((modechar == 'q'), modechar.text);
            assert((user.account == "blarf"), user.account);
            assert(negated);
            IRCUser blarf;
            blarf.nickname = "blarf";
            blarf.account = "blarf";
            assert(blarf.matchesByMask(user));
        }
    }

    {
        IRCChannel chan;

        chan.setMode("+t", string.init, server);
        assert(!chan.modes.length, chan.modes.length.text);
        assert((chan.modechars == "t"), chan.modechars);

        chan.setMode("-t+nlk", "42 chankey", server);
        assert((chan.modes.length == 2), chan.modes.length.text);
        with (chan.modes[0])
        {
            assert((modechar == 'k'), modechar.text);
            assert((data == "chankey"), data);
        }
        with (chan.modes[1])
        {
            assert((modechar == 'l'), modechar.text);
            assert((data == "42"), data);
        }

        assert((chan.modechars == "n"), chan.modechars);

        chan.setMode("-kl", string.init, server);
        assert(!chan.modes.length, chan.modes.length.text);
    }
}


// IRCParseException
/++
 +  IRC Parsing Exception, thrown when there were errors parsing.
 +
 +  It is a normal `object.Exception` but with an attached `dialect.defs.IRCEvent`.
 +/
final class IRCParseException : Exception
{
@safe:
    /// Bundled `dialect.defs.IRCEvent`, parsing which threw this exception.
    IRCEvent event;

    /++
     +  Create a new `IRCParseException`, without attaching an
     +  `dialect.defs.IRCEvent`.
     +/
    this(const string message, const string file = __FILE__,
        const size_t line = __LINE__) pure nothrow @nogc
    {
        super(message, file, line);
    }

    /++
     +  Create a new `IRCParseException`, attaching an
     +  `dialect.defs.IRCEvent` to it.
     +/
    this(const string message, const IRCEvent event, const string file = __FILE__,
        const size_t line = __LINE__) pure nothrow @nogc
    {
        this.event = event;
        super(message, file, line);
    }
}

///
unittest
{
    import std.exception : assertThrown;

    IRCEvent event;

    assertThrown!IRCParseException((){ throw new IRCParseException("adf"); }());

    assertThrown!IRCParseException(()
    {
        throw new IRCParseException("adf", event);
    }());

    assertThrown!IRCParseException(()
    {
        throw new IRCParseException("adf", event, "somefile.d");
    }());

    assertThrown!IRCParseException(()
    {
        throw new IRCParseException("adf", event, "somefile.d", 9999U);
    }());
}


/// Certain characters that signal specific meaning in an IRC context.
enum IRCControlCharacter
{
    ctcp = 1,       /// Client-to-client Protocol marker.
    bold = 2,       /// Bold text.
    colour = 3,     /// Colour marker.
    reset = 15,     /// Colour/formatting reset marker.
    invert = 22,    /// Inverse text marker.
    italics = 29,   /// Italics marker.
    underlined = 31,/// Underscore marker.
}


// matchesByMask
/++
 +  Compares this `dialect.defs.IRCUser` with a second one, treating fields with
 +  asterisks as glob wildcards, mimicking `*!*@*` mask matching.
 +
 +  Example:
 +  ---
 +  IRCUser u1;
 +  with (u1)
 +  {
 +      nickname = "foo";
 +      ident = "NaN";
 +      address = "asdf.asdf.com";
 +  }
 +
 +  IRCUser u2;
 +  with (u2)
 +  {
 +      nickname = "*";
 +       ident = "NaN";
 +      address = "*";
 +  }
 +
 +  assert(u1.matchesByMask(u2));
 +  assert(u1.matchesByMask("f*!NaN@*.com"));
 +  ---
 +
 +  Params:
 +      this_ = `dialect.defs.IRCUser` to compare.
 +      that = `dialect.defs.IRCUser` to compare `this_` with.
 +      caseMapping = `dialect.defs.IRCServer.CaseMapping` with which to translate
 +          the nicknames in the relevant masks to lowercase.
 +
 +  Returns:
 +      `true` if the `dialect.defs.IRCUser`s are deemed to match, `false` if not.
 +/
auto matchesByMask(const IRCUser this_, const IRCUser that,
    IRCServer.CaseMapping caseMapping = IRCServer.CaseMapping.rfc1459) pure nothrow
{
    // unpatternedGlobMatch
    /++
     +  Performs a glob match without taking special consideration of
     +  bracketed patterns (with [, ], { and }).
     +
     +  Params:
     +      first = First string.
     +      second = Second expression string to glob match with the first.
     +
     +  Returns:
     +      True if `first` matches the `second` glob mask, false if not.
     +/
    static bool unpatternedGlobMatch(const string first, const string second)
    {
        import std.array : replace;
        import std.path : CaseSensitive, globMatch;

        enum caseSetting = CaseSensitive.no;

        enum openBracketSubstitution = "\1";
        enum closedBracketSubstitution = "\2";
        enum openCurlySubstitution = "\3";
        enum closedCurlySubstitution = "\4";

        immutable firstReplaced = first
            .replace("[", openBracketSubstitution)
            .replace("]", closedBracketSubstitution)
            .replace("{", openCurlySubstitution)
            .replace("}", closedCurlySubstitution);

        immutable secondReplaced = second
            .replace("[", openBracketSubstitution)
            .replace("]", closedBracketSubstitution)
            .replace("{", openCurlySubstitution)
            .replace("}", closedCurlySubstitution);

        return firstReplaced.globMatch!caseSetting(secondReplaced);
    }

    // Only ever compare nicknames case-insensitive
    immutable ourLower = this_.nickname.toLowerCase(caseMapping);
    immutable theirLower = that.nickname.toLowerCase(caseMapping);

    // (unpatterned) globMatch in both directions
    // If no match and either is empty, that means they're *

    immutable matchNick = ((ourLower == theirLower) ||
        !this_.nickname.length || !that.nickname.length ||
        unpatternedGlobMatch(ourLower, theirLower) ||
        unpatternedGlobMatch(theirLower, ourLower));
    if (!matchNick) return false;

    immutable matchIdent = ((this_.ident == that.ident) ||
        !this_.ident.length || !that.ident.length ||
        unpatternedGlobMatch(this_.ident, that.ident) ||
        unpatternedGlobMatch(that.ident, this_.ident));
    if (!matchIdent) return false;

    immutable matchAddress = ((this_.address == that.address) ||
        !this_.address.length || !that.address.length ||
        unpatternedGlobMatch(this_.address, that.address) ||
        unpatternedGlobMatch(that.address, this_.address));
    if (!matchAddress) return false;

    return true;
}

///
unittest
{
    IRCUser first = IRCUser("kameloso!NaN@wopkfoewopk.com");

    IRCUser second = IRCUser("*!*@*");
    assert(first.matchesByMask(second));

    IRCUser third = IRCUser("kame*!*@*.com");
    assert(first.matchesByMask(third));

    IRCUser fourth = IRCUser("*loso!*@wop*");
    assert(first.matchesByMask(fourth));

    assert(second.matchesByMask(first));
    assert(third.matchesByMask(first));
    assert(fourth.matchesByMask(first));

    IRCUser fifth = IRCUser("kameloso!*@*");
    IRCUser sixth = IRCUser("KAMELOSO!ident@address.com");
    assert(fifth.matchesByMask(sixth));

    IRCUser seventh = IRCUser("^[0V0]^!ID@ADD");
    IRCUser eight = IRCUser("~{0v0}~!id@add");
    assert(seventh.matchesByMask(eight, IRCServer.CaseMapping.rfc1459));
    assert(!seventh.matchesByMask(eight, IRCServer.CaseMapping.strict_rfc1459));

    IRCUser ninth = IRCUser("*!*@170.233.40.144]");  // Accidental trailing ]
    IRCUser tenth = IRCUser("Joe!Shmoe@*");
    assert(ninth.matchesByMask(tenth, IRCServer.CaseMapping.rfc1459));

    IRCUser eleventh = IRCUser("abc]!*@*");
    IRCUser twelfth = IRCUser("abc}!abc}@abc}");
    assert(eleventh.matchesByMask(twelfth, IRCServer.CaseMapping.rfc1459));
}


// toLowerCase
/++
 +  Produces the passed string in lowercase as per the supplied case
 +  mappings.
 +
 +  Params:
 +      name = String to parse into lowercase.
 +      caseMapping = Server case mapping; maps uppercase to lowercase
 +          characters.
 +
 +  Returns:
 +      The passed `name` string with uppercase characters replaced as per
 +      the case mappings.
 +/
auto toLowerCase(const string name, IRCServer.CaseMapping caseMapping) pure nothrow
{
    import std.string : representation;
    import std.uni : toLower;

    ubyte[] lowercased;
    lowercased.length = name.length;

    foreach (immutable i, immutable c; name.representation)
    {
        if ((caseMapping == IRCServer.CaseMapping.rfc1459) ||
            (caseMapping == IRCServer.CaseMapping.strict_rfc1459))
        {
            switch (c)
            {
            case '[':
                lowercased[i] = '{';
                continue;
            case ']':
                lowercased[i] = '}';
                continue;
            case '\\':
                lowercased[i] = '|';
                continue;
            case '^':
                if (caseMapping == IRCServer.CaseMapping.rfc1459)
                {
                    lowercased[i] = '~';
                    continue;
                }
                break;

            default:
                break;
            }
        }

        lowercased[i] = cast(ubyte)c.toLower;
    }

    return cast(string)lowercased.idup;
}

///
unittest
{
    IRCServer.CaseMapping m = IRCServer.CaseMapping.rfc1459;

    {
        immutable lowercase = toLowerCase("ABCDEF", m);
        assert((lowercase == "abcdef"), lowercase);
    }
    {
        immutable lowercase = toLowerCase("123", m);
        assert((lowercase == "123"), lowercase);
    }
    {
        immutable lowercase = toLowerCase("^[0v0]^", m);
        assert((lowercase == "~{0v0}~"), lowercase);
    }
    {
        immutable lowercase = toLowerCase(`A|\|`, m);
        assert((lowercase == "a|||"), lowercase);
    }

    m = IRCServer.caseMapping.ascii;

    {
        immutable lowercase = toLowerCase("^[0v0]^", m);
        assert((lowercase == "^[0v0]^"), lowercase);
    }
    {
        immutable lowercase = toLowerCase(`A|\|`, m);
        assert((lowercase == `a|\|`), lowercase);
    }

    m = IRCServer.CaseMapping.strict_rfc1459;

    {
        immutable lowercase = toLowerCase("^[0v0]^", m);
        assert((lowercase == "^{0v0}^"), lowercase);
    }
}


// Postprocessor
/++
 +  Postprocessor interface for concrete postprocessors to inherit from.
 +/
interface Postprocessor
{
    /++
     +  Postprocesses an `dialect.defs.IRCEvent`.
     +/
    void postprocess(ref IRCParser, ref IRCEvent);
}
