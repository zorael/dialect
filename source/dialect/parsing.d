/++
    Functions related to parsing IRC events.

    IRC events come in very heterogeneous forms along the lines of:

        `:sender.address.tld TYPE [args...] :content`

        `:sender!~ident@address.tld 123 [args...] :content`

    The number and syntax of arguments for types vary wildly. As such, one
    common parsing routine can't be used; there are simply too many exceptions.
    The beginning `:sender.address.tld` is *almost* always the same form, but only
    almost. It's guaranteed to be followed by the type however, which come either in
    alphanumeric name (e.g. [dialect.defs.IRCEvent.Type.PRIVMSG|PRIVMSG],
    [dialect.defs.IRCEvent.Type.INVITE|INVITE], [dialect.defs.IRCEvent.Type.MODE|MODE],
    ...), or in numeric form of 001 to 999 inclusive.

    What we can do then is to parse this type, and interpret the arguments
    following as befits it.

    This translates to large switches, which can't be helped. There are simply
    too many variations, which switches lend themselves well to. You could make
    it into long if...else if chains, but it would just be the same thing in a
    different form. Likewise a nested function is not essentially different from
    a switch case.

    ---
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
        assert(aux[0] = "+v");
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
        assert(aux[0] == "newnick");
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
    ---

    See the `/tests` directory for more example parses.

    Copyright: [JR](https://github.com/zorael)
    License: [Boost Software License 1.0](https://www.boost.org/users/license.html)

    Authors:
        [JR](https://github.com/zorael)
 +/
module dialect.parsing;

private:

import dialect.defs;
import dialect.common : IRCParseException;
import dialect.postprocessors : Postprocessor;
import lu.string : advancePast;


// toIRCEvent
/++
    Parses an IRC string into an [dialect.defs.IRCEvent|IRCEvent].

    Parsing goes through several phases (prefix, typestring, specialcases) and
    this is the function that calls them, in order.

    See the files in `/tests` for unittest examples.

    Params:
        parser = Reference to the current [IRCParser].
        raw = Raw IRC string to parse.

    Returns:
        A finished [dialect.defs.IRCEvent|IRCEvent].

    Throws:
        [dialect.common.IRCParseException|IRCParseException] if an empty
        string was passed.

    See_Also:
        [dialect.defs.IRCEvent]
 +/
public IRCEvent toIRCEvent(
    ref IRCParser parser,
    const string raw) pure @safe
{
    import std.uni : toLower;

    if (!raw.length)
    {
        enum message = "Tried to parse an empty string";
        throw new IRCParseException(message);
    }

    if (raw[0] != ':')
    {
        if (raw[0] == '@')
        {
            if (raw.length < 2)
            {
                enum message = "Tried to parse what was only the start of tags";
                throw new IRCParseException(message);
            }

            // IRCv3 tags
            // @badges=broadcaster/1;color=;display-name=Zorael;emote-sets=0;mod=0;subscriber=0;user-type= :tmi.twitch.tv USERSTATE #zorael
            // @broadcaster-lang=;emote-only=0;followers-only=-1;mercury=0;r9k=0;room-id=22216721;slow=0;subs-only=0 :tmi.twitch.tv ROOMSTATE #zorael
            // @badges=subscriber/3;color=;display-name=asdcassr;emotes=560489:0-6,8-14,16-22,24-30/560510:39-46;id=4d6bbafb-427d-412a-ae24-4426020a1042;mod=0;room-id=23161357;sent-ts=1510059590512;subscriber=1;tmi-sent-ts=1510059591528;turbo=0;user-id=38772474;user-type= :asdcsa!asdcss@asdcsd.tmi.twitch.tv PRIVMSG #lirik :lirikFR lirikFR lirikFR lirikFR :sled: lirikLUL
            // @solanum.chat/ip=42.116.30.146 :Guest4!~Guest4@42.116.30.146 QUIT :Quit: Connection closed
            // @account=AdaYuong;solanum.chat/identified :AdaYuong!AdaYuong@user/adayuong PART #libera
            // @account=sna;solanum.chat/ip=2a01:420:17:1::ffff:536;solanum.chat/identified :sna!sna@im.vpsfree.se AWAY :I'm not here right now
            // @solanum.chat/ip=211.51.131.179 :Guest6187!~Guest61@211-51-131-179.fiber7.init7.net NICK :carbo

            // Get rid of the prepended @
            string newRaw = raw[1..$];  // mutable
            immutable tags = newRaw.advancePast(' ');
            auto event = .toIRCEvent(parser, newRaw);
            event.tags = tags;
            applyTags(event);
            return event;
        }
        else
        {
            IRCEvent event;
            event.raw = raw;
            parser.parseBasic(event);
            return event;
        }
    }

    IRCEvent event;
    event.raw = raw;

    string slice = event.raw[1..$]; // mutable. advance past first colon

    // First pass: prefixes. This is the sender
    parser.parsePrefix(event, slice);

    // Second pass: typestring. This is what kind of action the event is of
    parser.parseTypestring(event, slice);

    // Third pass: specialcases. This splits up the remaining bits into
    // useful strings, like sender, target and content
    parser.parseSpecialcases(event, slice);

    // Final cosmetic touches
    event.channel.name = event.channel.name.toLower();

    return event;
}

///
unittest
{
    IRCParser parser;

    /+
        `parser.toIRCEvent` technically calls `IRCParser.toIRCEvent`, but it in
        turn just passes on to this `.toIRCEvent`
     +/

    // See the files in `/tests` for more

    {
        immutable event = parser.toIRCEvent(":adams.freenode.net 001 kameloso^ " ~
            ":Welcome to the freenode Internet Relay Chat Network kameloso^");
        with (IRCEvent.Type)
        with (event)
        {
            assert(type == RPL_WELCOME);
            assert(sender.address == "adams.freenode.net"),
            assert(target.nickname == "kameloso^");
            assert(content == "Welcome to the freenode Internet Relay Chat Network kameloso^");
            assert(num == 1);
        }
    }
    {
        immutable event = parser.toIRCEvent(":irc.portlane.se 020 * :Please wait while we process your connection.");
        with (IRCEvent.Type)
        with (event)
        {
            assert(type == RPL_HELLO);
            assert(sender.address == "irc.portlane.se");
            assert(content == "Please wait while we process your connection.");
            assert(num == 20);
        }
    }
}


// parseBasic
/++
    Parses the most basic of IRC events; [dialect.defs.IRCEvent.Type.PING|PING],
    [dialect.defs.IRCEvent.Type.ERROR|ERROR],
    [dialect.defs.IRCEvent.Type.PONG|PONG],
    [dialect.defs.IRCEvent.Type.NOTICE|NOTICE] (plus `NOTICE AUTH`),
    and `AUTHENTICATE`.

    They syntactically differ from other events in that they are not prefixed
    by their sender.

    The [dialect.defs.IRCEvent|IRCEvent] is finished at the end of this function.

    Params:
        parser = Reference to the current [IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] to start
            working on.

    Throws:
        [dialect.common.IRCParseException|IRCParseException] if an unknown
        type was encountered.

    See_Also:
        [parsePrefix]
        [parseTypestring]
        [parseSpecialcases]
        [parseGeneralCases]
 +/
void parseBasic(
    ref IRCParser parser,
    ref IRCEvent event) pure @safe
{
    import std.algorithm.searching : canFind;

    string slice = event.raw;  // mutable

    immutable typestring = slice.canFind(':') ?
        slice.advancePast(" :") :
        slice.advancePast(' ', inherit: true);

    with (IRCEvent.Type)
    switch (typestring)
    {
    case "PING":
        // PING :3466174537
        // PING :weber.freenode.net
        event.type = PING;

        if (slice.canFind('.'))
        {
            event.sender.address = slice;
        }
        else
        {
            event.content = slice;
        }
        break;

    case "ERROR":
        // ERROR :Closing Link: 81-233-105-62-no80.tbcn.telia.com (Quit: kameloso^)
        event.type = ERROR;
        event.content = slice;
        break;

    case "NOTICE AUTH":
    case "NOTICE":
        // QuakeNet/Undernet
        // NOTICE AUTH :*** Couldn't look up your hostname
        event.type = NOTICE;
        event.content = slice;
        break;

    case "PONG":
        // PONG :tmi.twitch.tv
        event.type = PONG;
        event.sender.address = slice;
        break;

    case "AUTHENTICATE":
        event.type = SASL_AUTHENTICATE;
        event.content = slice;
        break;

    default:
        import std.algorithm.searching : startsWith;

        if (event.raw.startsWith("NOTICE"))
        {
            // Probably NOTICE <client.nickname>
            // NOTICE kameloso :*** If you are having problems connecting due to ping timeouts, please type /notice F94828E6 nospoof now.
            goto case "NOTICE";
        }
        else
        {
            event.type = UNSET;
            event.aux[0] = event.raw;
            event.errors = typestring;
        }
    }

    // All but PING and PONG are sender-less.
    if (!event.sender.address) event.sender.address = parser.server.address;
}

///
unittest
{
    import lu.conv : toString;

    IRCParser parser;

    IRCEvent e1;
    with (e1)
    {
        raw = "PING :irc.server.address";
        parser.parseBasic(e1);
        assert((type == IRCEvent.Type.PING), type.toString());
        assert((sender.address == "irc.server.address"), sender.address);
        assert(!sender.nickname.length, sender.nickname);
    }

    IRCEvent e2;
    with (e2)
    {
        // QuakeNet and others not having the sending server as prefix
        raw = "NOTICE AUTH :*** Couldn't look up your hostname";
        parser.parseBasic(e2);
        assert((type == IRCEvent.Type.NOTICE), type.toString());
        assert(!sender.nickname.length, sender.nickname);
        assert((content == "*** Couldn't look up your hostname"));
    }

    IRCEvent e3;
    with (e3)
    {
        raw = "ERROR :Closing Link: 81-233-105-62-no80.tbcn.telia.com (Quit: kameloso^)";
        parser.parseBasic(e3);
        assert((type == IRCEvent.Type.ERROR), type.toString());
        assert(!sender.nickname.length, sender.nickname);
        assert((content == "Closing Link: 81-233-105-62-no80.tbcn.telia.com (Quit: kameloso^)"), content);
    }
}


// parsePrefix
/++
    Takes a slice of a raw IRC string and starts parsing it into an
    [dialect.defs.IRCEvent|IRCEvent] struct.

    This function only focuses on the prefix; the sender, be it nickname and
    ident or server address.

    The [dialect.defs.IRCEvent|IRCEvent] is not finished at the end of this function.

    Params:
        parser = Reference to the current [IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] to start
            working on.
        slice = Reference to the *slice* of the raw IRC string.

    See_Also:
        [parseBasic]
        [parseTypestring]
        [parseSpecialcases]
        [parseGeneralCases]
 +/
void parsePrefix(
    ref IRCParser parser,
    ref IRCEvent event,
    ref string slice) pure @safe
in (slice.length, "Tried to parse prefix on an empty slice")
{
    import std.algorithm.searching : canFind;

    string prefix = slice.advancePast(' ');  // mutable

    if (prefix.canFind('!'))
    {
        // user!~ident@address
        event.sender.nickname = prefix.advancePast('!');
        event.sender.ident = prefix.advancePast('@');
        event.sender.address = prefix;
    }
    else if (prefix.canFind('.'))
    {
        // dots signify an address
        event.sender.address = prefix;
    }
    else
    {
        // When does this happen?
        event.sender.nickname = prefix;
    }
}

///
unittest
{
    IRCParser parser;

    IRCEvent e1;
    with (e1)
    with (e1.sender)
    {
        raw = ":zorael!~NaN@some.address.org PRIVMSG kameloso :this is fake";
        string slice1 = raw[1..$];  // mutable
        parser.parsePrefix(e1, slice1);
        assert((nickname == "zorael"), nickname);
        assert((ident == "~NaN"), ident);
        assert((address == "some.address.org"), address);
    }

    IRCEvent e2;
    with (e2)
    with (e2.sender)
    {
        raw = ":NickServ!NickServ@services. NOTICE kameloso :This nickname is registered.";
        string slice2 = raw[1..$];  // mutable
        parser.parsePrefix(e2, slice2);
        assert((nickname == "NickServ"), nickname);
        assert((ident == "NickServ"), ident);
        assert((address == "services."), address);
    }

    IRCEvent e3;
    with (e3)
    with (e3.sender)
    {
        raw = ":kameloso^^!~NaN@C2802314.E23AD7D8.E9841504.IP JOIN :#flerrp";
        string slice3 = raw[1..$];  // mutable
        parser.parsePrefix(e3, slice3);
        assert((nickname == "kameloso^^"), nickname);
        assert((ident == "~NaN"), ident);
        assert((address == "C2802314.E23AD7D8.E9841504.IP"), address);
    }

    IRCEvent e4;
    with (parser)
    with (e4)
    with (e4.sender)
    {
        raw = ":Q!TheQBot@CServe.quakenet.org NOTICE kameloso :You are now logged in as kameloso.";
        string slice4 = raw[1..$];  // mutable
        parser.parsePrefix(e4, slice4);
        assert((nickname == "Q"), nickname);
        assert((ident == "TheQBot"), ident);
        assert((address == "CServe.quakenet.org"), address);
    }
}


// parseTypestring
/++
    Takes a slice of a raw IRC string and continues parsing it into an
    [dialect.defs.IRCEvent|IRCEvent] struct.

    This function only focuses on the *typestring*; the part that tells what
    kind of event happened, like [dialect.defs.IRCEvent.Type.PRIVMSG|PRIVMSG] or
    [dialect.defs.IRCEvent.Type.MODE|MODE] or
    [dialect.defs.IRCEvent.Type.NICK|NICK] or
    [dialect.defs.IRCEvent.Type.KICK|KICK], etc; in string format.

    The [dialect.defs.IRCEvent|IRCEvent] is not finished at the end of this function.

    Params:
        parser = Reference to the current [IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] to continue
            working on.
        slice = Reference to the slice of the raw IRC string.

    Throws:
        [dialect.common.IRCParseException|IRCParseException] if conversion from
        typestring to [dialect.defs.IRCEvent.Type|IRCEvent.Type] or typestring
        to a number failed.

    See_Also:
        [parsePrefix]
        [parseBasic]
        [parseSpecialcases]
        [parseGeneralCases]
 +/
void parseTypestring(
    ref IRCParser parser,
    ref IRCEvent event,
    ref string slice) pure @safe
in (slice.length, "Tried to parse typestring on an empty slice")
{
    import std.conv : ConvException, to;

    immutable typestring = slice.advancePast(' ', inherit: true);

    if ((typestring[0] >= '0') && (typestring[0] <= '9'))
    {
        event.num = typestring.to!uint;
        event.type = parser.typenums[event.num];
        if (event.type == IRCEvent.Type.UNSET) event.type = IRCEvent.Type.NUMERIC;
    }
    else
    {
        try
        {
            import lu.conv : Enum;
            event.type = Enum!(IRCEvent.Type).fromString(typestring);
        }
        catch (ConvException e)
        {
            immutable message = "Unknown typestring: " ~ typestring;
            throw new IRCParseException(message, event, e.file, e.line);
        }
    }
}

///
unittest
{
    import lu.conv : toString;
    import std.conv : to;

    IRCParser parser;

    IRCEvent e1;
    with (e1)
    {
        raw = /*":port80b.se.quakenet.org */"421 kameloso åäö :Unknown command";
        string slice = raw;  // mutable
        parser.parseTypestring(e1, slice);
        assert((type == IRCEvent.Type.ERR_UNKNOWNCOMMAND), type.toString());
        assert((num == 421), num.to!string);
    }

    IRCEvent e2;
    with (e2)
    {
        raw = /*":port80b.se.quakenet.org */"353 kameloso = #garderoben :@kameloso'";
        string slice = raw;  // mutable
        parser.parseTypestring(e2, slice);
        assert((type == IRCEvent.Type.RPL_NAMREPLY), type.toString());
        assert((num == 353), num.to!string);
    }

    IRCEvent e3;
    with (e3)
    {
        raw = /*":zorael!~NaN@ns3363704.ip-94-23-253.eu */"PRIVMSG kameloso^ :test test content";
        string slice = raw;  // mutable
        parser.parseTypestring(e3, slice);
        assert((type == IRCEvent.Type.PRIVMSG), type.toString());
    }

    IRCEvent e4;
    with (e4)
    {
        raw = /*`:zorael!~NaN@ns3363704.ip-94-23-253.eu */`PART #flerrp :"WeeChat 1.6"`;
        string slice = raw;  // mutable
        parser.parseTypestring(e4, slice);
        assert((type == IRCEvent.Type.PART), type.toString());
    }
}


// parseSpecialcases
/++
    Takes a slice of a raw IRC string and continues parsing it into an
    [dialect.defs.IRCEvent|IRCEvent] struct.

    This function only focuses on specialcasing the remaining line, dividing it
    into fields like `target`, `channel`, `content`, etc.

    IRC events are *riddled* with inconsistencies and specialcasings, so this
    function is very very long, but by necessity.

    The [dialect.defs.IRCEvent|IRCEvent] is finished at the end of this function.

    Params:
        parser = Reference to the current [IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] to continue
            working on.
        slice = Reference to the slice of the raw IRC string.

    Throws:
        [dialect.common.IRCParseException|IRCParseException] if an unknown
        to-connect-type event was encountered, or if the event was not
        recognised at all, as neither a normal type nor a numeric.

    See_Also:
        [parsePrefix]
        [parseBasic]
        [parseTypestring]
        [parseGeneralCases]
 +/
void parseSpecialcases(
    ref IRCParser parser,
    ref IRCEvent event,
    ref string slice) pure @safe
//in (slice.length, "Tried to parse specialcases on an empty slice")
{
    import lu.string : strippedRight;
    import std.algorithm.searching : canFind, startsWith;
    import std.conv : to;

    with (IRCEvent.Type)
    switch (event.type)
    {
    case NOTICE:
        parser.onNotice(event, slice);
        break;

    case JOIN:
        // :nick!~identh@unaffiliated/nick JOIN #freenode login :realname
        // :kameloso^!~NaN@81-233-105-62-no80.tbcn.telia.com JOIN #flerrp
        // :kameloso^^!~NaN@C2802314.E23AD7D8.E9841504.IP JOIN :#flerrp
        event.type = (event.sender.nickname == parser.client.nickname) ?
            SELFJOIN :
            JOIN;

        if (slice.canFind(' '))
        {
            import lu.string : stripped;

            // :nick!user@host JOIN #channelname accountname :Real Name
            // :nick!user@host JOIN #channelname * :Real Name
            // :nick!~identh@unaffiliated/nick JOIN #freenode login :realname
            // :kameloso!~NaN@2001:41d0:2:80b4:: JOIN #hirrsteff2 kameloso : kameloso!
            event.channel.name = slice.advancePast(' ');
            event.sender.account = slice.advancePast(" :");
            if (event.sender.account == "*") event.sender.account = string.init;
            event.sender.realName = slice.stripped;
        }
        else
        {
            event.channel.name = slice.startsWith(':') ?
                slice[1..$] :
                slice;
        }
        break;

    case PART:
        // :zorael!~NaN@ns3363704.ip-94-23-253.eu PART #flerrp :"WeeChat 1.6"
        // :kameloso^!~NaN@81-233-105-62-no80.tbcn.telia.com PART #flerrp
        // :Swatas!~4--Uos3UH@9e19ee35.915b96ad.a7c9320c.IP4 PART :#cncnet-mo
        // :gallon!~MO.11063@482c29a5.e510bf75.97653814.IP4 PART :#cncnet-yr
        event.type = (event.sender.nickname == parser.client.nickname) ?
            SELFPART :
            PART;

        if (slice.canFind(' '))
        {
            import lu.string : unquoted;
            event.channel.name = slice.advancePast(" :");
            event.content = slice.unquoted;
        }
        else
        {
            // Seen on GameSurge
            if (slice.startsWith(':')) slice = slice[1..$];
            event.channel.name = slice;
        }
        break;

    case NICK:
        // :kameloso^!~NaN@81-233-105-62-no80.tbcn.telia.com NICK :kameloso_
        event.target = event.sender;
        event.target.nickname = slice[1..$];

        if (event.sender.nickname == parser.client.nickname)
        {
            event.type = SELFNICK;
            parser.client.nickname = event.target.nickname;
            version(FlagAsUpdated) parser.updates |= IRCParser.Update.client;
        }
        break;

    case QUIT:
        import lu.string : unquoted;

        // :g7zon!~gertsson@178.174.245.107 QUIT :Client Quit
        event.type = (event.sender.nickname == parser.client.nickname) ?
            SELFQUIT :
            QUIT;
        event.content = slice[1..$].unquoted;

        if (event.content.startsWith("Quit: "))
        {
            event.content = event.content[6..$];
        }
        break;

    case PRIVMSG:
    case WHISPER:  // Twitch private message
        parser.onPRIVMSG(event, slice);
        break;

    case MODE:
        slice = slice.strippedRight;  // RusNet has trailing spaces
        parser.onMode(event, slice);
        break;

    case KICK:
        // :zorael!~NaN@ns3363704.ip-94-23-253.eu KICK #flerrp kameloso^ :this is a reason
        event.channel.name = slice.advancePast(' ');
        event.target.nickname = slice.advancePast(" :");
        event.content = slice;
        event.type = (event.target.nickname == parser.client.nickname) ?
            SELFKICK :
            KICK;
        break;

    case INVITE:
        // (freenode) :zorael!~NaN@2001:41d0:2:80b4:: INVITE kameloso :#hirrsteff
        // (quakenet) :zorael!~zorael@ns3363704.ip-94-23-253.eu INVITE kameloso #hirrsteff
        event.target.nickname = slice.advancePast(' ');
        event.channel.name = slice.startsWith(':') ? slice[1..$] : slice;
        break;

    case AWAY:
        // :Halcy0n!~Halcy0n@SpotChat-rauo6p.dyn.suddenlink.net AWAY :I'm busy
        if (slice.length)
        {
            // :I'm busy
            slice = slice[1..$];
            event.content = slice;
        }
        else
        {
            event.type = BACK;
        }
        break;

    case ERR_NOSUCHCHANNEL: // 403
        // <channel name> :No such channel
        // :moon.freenode.net 403 kameloso archlinux :No such channel
        slice.advancePast(' ');  // bot nickname
        event.channel.name = slice.advancePast(" :");
        event.content = slice;
        break;

    case RPL_NAMREPLY: // 353
        // <channel> :[[@|+]<nick> [[@|+]<nick> [...]]]
        // :asimov.freenode.net 353 kameloso^ = #garderoben :kameloso^ ombudsman +kameloso @zorael @maku @klarrt
        slice.advancePast(' ');  // bot nickname
        slice.advancePast(' ');
        event.channel.name = slice.advancePast(" :");
        event.content = slice.strippedRight;
        break;

    case RPL_WHOREPLY: // 352
        import lu.string : strippedLeft;

        // "<channel> <user> <host> <server> <nick> ( "H" / "G" > ["*"] [ ( "@" / "+" ) ] :<hopcount> <real name>"
        // :moon.freenode.net 352 kameloso ##linux LP9NDWY7Cy gentoo/contributor/Fieldy moon.freenode.net Fieldy H :0 Ni!
        // :moon.freenode.net 352 kameloso ##linux sid99619 gateway/web/irccloud.com/x-eviusxrezdarwcpk moon.freenode.net tjsimmons G :0 T.J. Simmons
        // :moon.freenode.net 352 kameloso ##linux sid35606 gateway/web/irccloud.com/x-rvrdncbvklhxwjrr moon.freenode.net Whisket H :0 Whisket
        // :moon.freenode.net 352 kameloso ##linux ~rahlff b29beb9d.rev.stofanet.dk orwell.freenode.net Axton H :0 Michael Rahlff
        // :moon.freenode.net 352 kameloso ##linux ~wzhang sea.mrow.org card.freenode.net wzhang H :0 wzhang
        // :irc.rizon.no 352 kameloso^^ * ~NaN C2802314.E23AD7D8.E9841504.IP * kameloso^^ H :0  kameloso!
        // :irc.rizon.no 352 kameloso^^ * ~zorael Rizon-64330364.ip-94-23-253.eu * wob^2 H :0 zorael
        slice.advancePast(' ');  // bot nickname
        event.channel.name = slice.advancePast(' ');
        if (event.channel.name == "*") event.channel.name = string.init;

        immutable userOrIdent = slice.advancePast(' ');
        if (userOrIdent.startsWith('~')) event.target.ident = userOrIdent;

        event.target.address = slice.advancePast(' ');
        slice.advancePast(' ');  // server
        event.target.nickname = slice.advancePast(' ');

        immutable hg = slice.advancePast(' ');  // H|G
        if (hg.length > 1)
        {
            // H
            // H@
            // H+
            // H@+
            event.aux[0] = hg[1..$];
        }

        slice.advancePast(' ');  // hopcount
        event.content = slice.strippedLeft;
        event.sender.realName = event.content;
        break;

    case RPL_ENDOFWHO: // 315
        // <name> :End of /WHO list
        // :tolkien.freenode.net 315 kameloso^ ##linux :End of /WHO list.
        // :irc.rizon.no 315 kameloso^^ * :End of /WHO list.
        slice.advancePast(' ');  // bot nickname
        event.channel.name = slice.advancePast(" :");
        if (event.channel.name == "*") event.channel.name = string.init;
        event.content = slice;
        break;

    case RPL_ISUPPORT: // 005
        parser.onISUPPORT(event, slice);
        break;

    case RPL_MYINFO: // 004
        // <server_name> <version> <user_modes> <chan_modes>
        parser.onMyInfo(event, slice);
        break;

    case RPL_QUIETLIST: // 728, oftc/hybrid 344
        // :niven.freenode.net 728 kameloso^ #flerrp q qqqq!*@asdf.net zorael!~NaN@2001:41d0:2:80b4:: 1514405101
        // :irc.oftc.net 344 kameloso #garderoben harbl!snarbl@* kameloso!~NaN@194.117.188.126 1515418362
        slice.advancePast(' ');  // bot nickname
        event.channel.name = slice.canFind(" q ") ?
            slice.advancePast(" q ") :
            slice.advancePast(' ');
        event.content = slice.advancePast(' ');
        event.aux[0] = slice.advancePast(' ');
        event.count[0] = slice.to!long;
        break;

    case RPL_WHOISHOST: // 378
        // <nickname> :is connecting from *@<address> <ip>
        // :wilhelm.freenode.net 378 kameloso^ kameloso^ :is connecting from *@81-233-105-62-no80.tbcn.telia.com 81.233.105.62
        // TRIED TO NOM TOO MUCH:'kameloso :is connecting from NaN@194.117.188.126 194.117.188.126' with ' :is connecting from *@'
        slice.advancePast(' ');  // bot nickname
        event.target.nickname = slice.advancePast(" :is connecting from ");
        event.target.ident = slice.advancePast('@');
        if (event.target.ident == "*") event.target.ident = string.init;
        event.content = slice.advancePast(' ');
        event.aux[0] = slice;
        break;

    case ERR_UNKNOWNCOMMAND: // 421
        // <command> :Unknown command
        slice.advancePast(' ');  // bot nickname

        if (slice.canFind(" :Unknown command"))
        {
            import std.string : lastIndexOf;

            // :asimov.freenode.net 421 kameloso^ sudo :Unknown command
            // :tmi.twitch.tv 421 kamelosobot ZORAEL!ZORAEL@TMI.TWITCH.TV PRIVMSG #ZORAEL :HELLO :Unknown command
            immutable spaceColonPos = slice.lastIndexOf(" :");
            event.aux[0] = slice[0..spaceColonPos];
            event.content = slice[spaceColonPos+2..$];
            slice = string.init;
        }
        else
        {
            // :karatkievich.freenode.net 421 kameloso^ systemd,#kde,#kubuntu,...
            event.content = slice;
        }
        break;

    case RPL_WHOISIDLE: //  317
        // <nick> <integer> :seconds idle
        // :rajaniemi.freenode.net 317 kameloso zorael 0 1510219961 :seconds idle, signon time
        slice.advancePast(' ');  // bot nickname
        event.target.nickname = slice.advancePast(' ');
        event.count[0] = slice.advancePast(' ').to!long;
        event.count[1] = slice.advancePast(" :").to!long;
        event.content = slice;
        break;

    case RPL_LUSEROP: // 252
    case RPL_LUSERUNKNOWN: // 253
    case RPL_LUSERCHANNELS: // 254
    case ERR_ERRONEOUSNICKNAME: // 432
    case ERR_NEEDMOREPARAMS: // 461
    case RPL_LOCALUSERS: // 265
    case RPL_GLOBALUSERS: // 266
        // <integer> :operator(s) online  // 252
        // <integer> :unknown connection(s)  // 253
        // <integer> :channels formed // 254
        // <nick> :Erroneous nickname // 432
        // <command> :Not enough parameters // 461
        // :asimov.freenode.net 252 kameloso^ 31 :IRC Operators online
        // :asimov.freenode.net 253 kameloso^ 13 :unknown connection(s)
        // :asimov.freenode.net 254 kameloso^ 54541 :channels formed
        // :asimov.freenode.net 432 kameloso^ @nickname :Erroneous Nickname
        // :asimov.freenode.net 461 kameloso^ JOIN :Not enough parameters
        // :asimov.freenode.net 265 kameloso^ 6500 11061 :Current local users 6500, max 11061
        // :asimov.freenode.net 266 kameloso^ 85267 92341 :Current global users 85267, max 92341
        // :irc.uworld.se 265 kameloso^^ :Current local users: 14552  Max: 19744
        // :irc.uworld.se 266 kameloso^^ :Current global users: 14552  Max: 19744
        // :weber.freenode.net 265 kameloso 3385 6820 :Current local users 3385, max 6820"
        // :weber.freenode.net 266 kameloso 87056 93012 :Current global users 87056, max 93012
        // :irc.rizon.no 265 kameloso^^ :Current local users: 16115  Max: 17360
        // :irc.rizon.no 266 kameloso^^ :Current global users: 16115  Max: 17360
        slice.advancePast(' ');  // bot nickname

        if (slice.canFind(" :"))
        {
            import std.uni : isNumber;

            string midfield = slice.advancePast(" :");  // mutable
            immutable first = midfield.advancePast(' ', inherit: true);
            alias second = midfield;
            event.content = slice;

            if (first.length)
            {
                if (first[0].isNumber)
                {
                    import std.conv : ConvException;

                    try
                    {
                        event.count[0] = first.to!long;

                        if (second.length && second[0].isNumber)
                        {
                            event.count[1] = second.to!long;
                        }
                    }
                    catch (ConvException e)
                    {
                        // :hitchcock.freenode.net 432 * 1234567890123456789012345 :Erroneous Nickname
                        // Treat as though not a number
                        event.aux[0] = first;
                    }
                }
                else
                {
                    event.aux[0] = first;
                }
            }
        }
        else
        {
            event.content = slice[1..$];
        }
        break;

    case RPL_WHOISUSER: // 311
        import lu.string : strippedLeft;

        // <nick> <user> <host> * :<real name>
        // :orwell.freenode.net 311 kameloso^ kameloso ~NaN ns3363704.ip-94-23-253.eu * : kameloso
        slice.advancePast(' ');  // bot nickname
        event.target.nickname = slice.advancePast(' ');
        event.target.ident = slice.advancePast(' ');
        event.target.address = slice.advancePast(" * :");
        event.content = slice.strippedLeft;
        event.target.realName = event.content;
        break;

    case RPL_WHOISSERVER: // 312
        // <nick> <server> :<server info>
        // :asimov.freenode.net 312 kameloso^ zorael sinisalo.freenode.net :SE
        slice.advancePast(' ');  // bot nickname
        event.target.nickname = slice.advancePast(' ');
        event.content = slice.advancePast(" :");
        event.aux[0] = slice;
        break;

    case RPL_WHOISACCOUNT: // 330
        // <nickname> <account> :is logged in as
        // :asimov.freenode.net 330 kameloso^ xurael zorael :is logged in as
        slice.advancePast(' ');  // bot nickname
        event.target.nickname = slice.advancePast(' ');
        event.target.account = slice.advancePast(" :");
        event.content = event.target.account;
        break;

    case RPL_WHOISREGNICK: // 307
        // <nickname> :has identified for this nick
        // :irc.x2x.cc 307 kameloso^^ py-ctcp :has identified for this nick
        // :irc.x2x.cc 307 kameloso^^ wob^2 :has identified for this nick
        // What is the nickname? Are they always the same?
        slice.advancePast(' '); // bot nickname
        event.target.account = slice.advancePast(" :");
        event.target.nickname = event.target.account;  // uneducated guess
        event.content = event.target.nickname;
        break;

    case RPL_WHOISACTUALLY: // 338
        // :kinetic.oftc.net 338 kameloso wh00nix 255.255.255.255 :actually using host
        // :efnet.port80.se 338 kameloso kameloso 255.255.255.255 :actually using host
        // :irc.rizon.club 338 kameloso^ kameloso^ :is actually ~kameloso@194.117.188.126 [194.117.188.126]
        // :irc.link-net.be 338 zorael zorael is actually ~kameloso@195.196.10.12 [195.196.10.12]
        // :Prothid.NY.US.GameSurge.net 338 zorael zorael ~kameloso@195.196.10.12 195.196.10.12 :Actual user@host, Actual IP$
        // :silver.libera.chat 338 zorael deadmarshal 2605:6400:10:5bf:6f87:849d:f61e:2c8c :actually using host
        import std.algorithm.searching : countUntil;

        slice.advancePast(' '); // bot nickname
        event.target.nickname = slice.advancePast(' ');
        immutable colonPos = slice.countUntil(':');

        if ((colonPos == -1) || (colonPos == 0))
        {
            // :irc.link-net.be 338 zorael zorael is actually ~kameloso@195.196.10.12 [195.196.10.12]
            // :irc.rizon.club 338 kameloso^ kameloso^ :is actually ~kameloso@194.117.188.126 [194.117.188.126]
            slice.advancePast("is actually ");
            event.aux[0] = slice.advancePast(' ');

            if ((slice[0] == '[') && (slice[$-1] == ']'))
            {
                event.target.address = slice[1..$-1];
            }
            else
            {
                event.content = slice;
            }
        }
        else
        {
            if (slice[0..colonPos].canFind('.'))
            {
                string addstring = slice.advancePast(" :");  // mutable

                if (addstring.canFind(' '))
                {
                    // :Prothid.NY.US.GameSurge.net 338 zorael zorael ~kameloso@195.196.10.12 195.196.10.12 :Actual user@host, Actual IP$
                    event.aux[0] = addstring.advancePast(' ');
                    event.target.address = addstring;
                }
                else
                {
                    event.aux[0] = addstring;
                    if (addstring.canFind('@')) addstring.advancePast('@');
                    event.target.address = addstring;
                }

                event.content = slice;
            }
            else if (slice.canFind(" :"))
            {
                // :silver.libera.chat 338 zorael deadmarshal 2605:6400:10:5bf:6f87:849d:f61e:2c8c :actually using host
                event.aux[0] = slice.advancePast(" :");
                event.content = slice;
            }
            else
            {
                // Unsure
                event.content = slice;
            }
        }
        break;

    case PONG:
        // PONG :<address>
        // :<address> PONG <address> :<what was pinged>
        if (slice.canFind(" :"))
        {
            event.aux[0] = slice.advancePast(" :");
        }
        event.content = slice;
        break;

    case ERR_NOTREGISTERED: // 451
        // :You have not registered
        if (slice.startsWith('*'))
        {
            // :niven.freenode.net 451 * :You have not registered
            slice.advancePast("* :");
            event.content = slice;
        }
        else
        {
            // :irc.harblwefwoi.org 451 WHOIS :You have not registered
            event.aux[0] = slice.advancePast(" :");
            event.content = slice;
        }
        break;

    case ERR_NEEDPONG: // 513
        // <nickname> :To connect type /QUOTE PONG <number>
        /++
            "Also known as ERR_NEEDPONG (Unreal/Ultimate) for use during
            registration, however it's not used in Unreal (and might not be used
            in Ultimate either)."
         +/
        // :irc.uworld.se 513 kameloso :To connect type /QUOTE PONG 3705964477

        if (slice.canFind(" :To connect"))
        {
            event.target.nickname = slice.advancePast(" :To connect");

            if (slice.startsWith(','))
            {
                // ngircd?
                /* "NOTICE %s :To connect, type /QUOTE PONG %ld",
                    Client_ID(Client), auth_ping)) */
                // :like.so 513 kameloso :To connect, type /QUOTE PONG 3705964477
                // "To connect, type /QUOTE PONG <id>"
                //            ^
                slice = slice[1..$];
            }

            slice.advancePast(" type /QUOTE ");
            event.content = slice;
        }
        else
        {
            immutable message = "Unknown variant of to-connect-type: " ~ slice;
            throw new IRCParseException(message, event);
        }
        break;

    case RPL_TRACEEND: // 262
    case RPL_TRYAGAIN: // 263
    case RPL_STATSDEBUG: // 249
    case RPL_ENDOFSTATS: // 219
    case RPL_HELPSTART: // 704
    case RPL_HELPTXT: // 705
    case RPL_ENDOFHELP: // 706
    case RPL_CODEPAGE: // 222
        // <server_name> <version>[.<debug_level>] :<info> // 262
        // <command> :<info> // 263
        // <stats letter> :End of /STATS report // 219
        // <nickname> index :Help topics available to users: // 704
        // <nickname> index :ACCEPT\tADMIN\tAWAY\tCHALLENGE // 705
        // <nickname> index :End of /HELP. // 706
        // :irc.run.net 222 kameloso KOI8-U :is your charset now
        // :leguin.freenode.net 704 kameloso^ index :Help topics available to users:
        // :leguin.freenode.net 705 kameloso^ index :ACCEPT\tADMIN\tAWAY\tCHALLENGE
        // :leguin.freenode.net 706 kameloso^ index :End of /HELP.
        // :livingstone.freenode.net 249 kameloso p :dax (dax@freenode/staff/dax)
        // :livingstone.freenode.net 249 kameloso p :1 staff members
        // :livingstone.freenode.net 219 kameloso p :End of /STATS report
        // :verne.freenode.net 263 kameloso^ STATS :This command could not be completed because it has been used recently, and is rate-limited
        // :verne.freenode.net 262 kameloso^ verne.freenode.net :End of TRACE
        // :irc.rizon.no 263 kameloso^ :Server load is temporarily too heavy. Please wait a while and try again.
        slice.advancePast(' '); // bot nickname

        if (!slice.length)
        {
            // Unsure if this ever happens but check before indexing
            break;
        }
        else if (slice[0] == ':')
        {
            slice = slice[1..$];
        }
        else
        {
            event.aux[0] = slice.advancePast(" :");
        }

        event.content = slice;
        break;

    case RPL_STATSLINKINFO: // 211
        // <linkname> <sendq> <sent messages> <sent bytes> <received messages> <received bytes> <time open>
        // :verne.freenode.net 211 kameloso^ kameloso^[~NaN@194.117.188.126] 0 109 8 15 0 :40 0 -
        slice.advancePast(' '); // bot nickname
        event.aux[0] = slice.advancePast(' ');
        event.content = slice;
        break;

    case RPL_TRACEUSER: // 205
        // User <class> <nick>
        // :wolfe.freenode.net 205 kameloso^ User v6users zorael[~NaN@2001:41d0:2:80b4::] (255.255.255.255) 16 :536
        slice.advancePast(" User "); // bot nickname
        event.aux[0] = slice.advancePast(' '); // "class"
        event.content = slice.advancePast(" :");
        event.count[0] = slice.to!long; // unsure
        break;

    case RPL_LINKS: // 364
        // <mask> <server> :<hopcount> <server info>
        // :rajaniemi.freenode.net 364 kameloso^ rajaniemi.freenode.net rajaniemi.freenode.net :0 Helsinki, FI, EU
        slice.advancePast(' '); // bot nickname
        slice.advancePast(' '); // "mask"
        event.aux[0] = slice.advancePast(" :"); // server address
        event.count[0] = slice.advancePast(' ').to!long; // hop count
        event.content = slice; // "server info"
        break;

    case ERR_BANONCHAN: // 435
        // <nickname> <target nickname> <channel> :Cannot change nickname while banned on channel
        // :cherryh.freenode.net 435 kameloso^ kameloso^^ #d3d9 :Cannot change nickname while banned on channel
        event.target.nickname = slice.advancePast(' ');
        event.aux[0] = slice.advancePast(' ');
        event.channel.name = slice.advancePast(" :");
        event.content = slice;
        break;

    case CAP:
        import std.algorithm.iteration : splitter;

        if (slice.canFind('*'))
        {
            // :tmi.twitch.tv CAP * LS :twitch.tv/tags twitch.tv/commands twitch.tv/membership
            // More CAPs follow
            slice.advancePast("* ");
        }
        else
        {
            // :genesis.ks.us.irchighway.net CAP 867AAF66L LS :away-notify extended-join account-notify multi-prefix sasl tls userhost-in-names
            // Final CAP listing
            /*immutable id =*/ slice.advancePast(' ');
        }

        // Store verb in content and caps in aux
        event.content = slice.advancePast(" :");

        uint i;
        foreach (immutable cap; slice.splitter(' '))
        {
            if (i < event.aux.length)
            {
                event.aux[i++] = cap;
            }
            else
            {
                // Overflow! aux is too small.
                if (!event.errors.length) event.errors = "CAP overflow:";
                event.errors ~= ' ' ~ cap;
            }
        }
        break;

    case RPL_UMODEGMSG:
        // :rajaniemi.freenode.net 718 kameloso Freyjaun ~FREYJAUN@41.39.229.6 :is messaging you, and you have umode +g.
        slice.advancePast(' '); // bot nickname
        event.target.nickname = slice.advancePast(' ');
        event.target.ident = slice.advancePast('@');
        event.target.address = slice.advancePast(" :");
        event.content = slice;
        break;

    version(TwitchSupport)
    {
        case CLEARCHAT:
            // :tmi.twitch.tv CLEARCHAT #zorael
            // :tmi.twitch.tv CLEARCHAT #<channel> :<user>
            if (slice.canFind(" :"))
            {
                // Banned
                event.channel.name = slice.advancePast(" :");
                event.target.nickname = slice;
            }
            else
            {
                event.channel.name = slice;
            }
            break;
    }

    case RPL_LOGGEDIN: // 900
        // <nickname>!<ident>@<address> <nickname> :You are now logged in as <nickname>
        // :weber.freenode.net 900 kameloso kameloso!NaN@194.117.188.126 kameloso :You are now logged in as kameloso.
        // :kornbluth.freenode.net 900 * *!unknown@194.117.188.126 kameloso :You are now logged in as kameloso.
        if (slice.canFind('!'))
        {
            event.target.nickname = slice.advancePast(' ');  // bot nick, or an asterisk if unknown
            if (event.target.nickname == "*") event.target.nickname = string.init;
            slice.advancePast('!');  // user
            /*event.target.ident =*/ slice.advancePast('@');  // Doesn't seem to be the true ~ident
            event.target.address = slice.advancePast(' ');
            event.target.account = slice.advancePast(" :");
        }
        event.content = slice;
        break;

    case AUTH_SUCCESS:  // NOTICE
        // //:NickServ!services@services.oftc.net NOTICE kameloso :You are successfully identified as kameloso.$
        event.content = slice;
        break;

    case RPL_WELCOME: // 001
        // :Welcome to <server name> <user>
        // :adams.freenode.net 001 kameloso^ :Welcome to the freenode Internet Relay Chat Network kameloso^
        event.target.nickname = slice.advancePast(" :");
        event.content = slice;

        if (!parser.server.resolvedAddress.length)
        {
            // No RPL_HELLO. Twitch?
            // Inherit the sender address as the resolved server address
            parser.server.resolvedAddress = event.sender.address;
            version(FlagAsUpdated) parser.updates |= IRCParser.Update.server;
        }

        if (parser.client.nickname != event.target.nickname)
        {
            parser.client.nickname = event.target.nickname;
            version(FlagAsUpdated) parser.updates |= IRCParser.Update.client;
        }
        break;

    case ACCOUNT:
        //:ski7777!~quassel@ip5b435007.dynamic.kabel-deutschland.de ACCOUNT ski7777
        event.sender.account = slice;
        event.content = slice;  // to make it visible?
        break;

    case RPL_HOSTHIDDEN: // 396
        // <nickname> <host> :is now your hidden host
        // :TAL.DE.EU.GameSurge.net 396 kameloso ~NaN@1b24f4a7.243f02a4.5cd6f3e3.IP4 :is now your hidden host
        slice.advancePast(' '); // bot nickname
        event.aux[0] = slice.advancePast(" :");
        event.content = slice;
        break;

    case RPL_VERSION: // 351
        // <version>.<debuglevel> <server> :<comments>
        // :irc.rizon.no 351 kameloso^^ plexus-4(hybrid-8.1.20)(20170821_0-607). irc.rizon.no :TS6ow
        slice.advancePast(' '); // bot nickname
        event.content = slice.advancePast(" :");
        event.aux[0] = slice;
        break;

    case RPL_YOURID: // 42
    case ERR_YOUREBANNEDCREEP: // 465
    case ERR_HELPNOTFOUND: // 524, also ERR_QUARANTINED
    case ERR_UNKNOWNMODE: // 472
        // <nickname> <id> :your unique ID // 42
        // :You are banned from this server // 465
        // <char> :is unknown mode char to me // 472
        // :caliburn.pa.us.irchighway.net 042 kameloso 132AAMJT5 :your unique ID
        // :irc.rizon.no 524 kameloso^^ 502 :Help not found
        // :irc.rizon.no 472 kameloso^^ X :is unknown mode char to me
        // :miranda.chathispano.com 465 kameloso 1511086908 :[1511000504768] G-Lined by ChatHispano Network. Para mas informacion visite http://chathispano.com/gline/?id=<id> (expires at Dom, 19/11/2017 11:21:48 +0100).
        // event.time was 1511000921
        // TRIED TO NOM TOO MUCH:':You are banned from this server- Your irc client seems broken and is flooding lots of channels. Banned for 240 min, if in error, please contact kline@freenode.net. (2017/12/1 21.08)' with ' :'
        string misc = slice.advancePast(" :");  // mutable
        event.content = slice;
        misc.advancePast(' ', inherit: true);
        event.aux[0] = misc;
        break;

    case RPL_UMODEIS:
        // <user mode string>
        // :lamia.ca.SpotChat.org 221 kameloso :+ix
        // :port80b.se.quakenet.org 221 kameloso +i
        // The general heuristics is good enough for this but places modes in
        // content rather than aux, which is inconsistent with other mode events
        slice.advancePast(' '); // bot nickname

        if (slice.startsWith(':'))
        {
            slice = slice[1..$];
        }

        event.aux[0] = slice;
        break;

    case RPL_CHANNELMODEIS: // 324
        // <channel> <mode> <mode params>
        // :niven.freenode.net 324 kameloso^ ##linux +CLPcnprtf ##linux-overflow
        // :kornbluth.freenode.net 324 kameloso #flerrp +ns
        slice.advancePast(' '); // bot nickname
        event.channel.name = slice.advancePast(' ');

        if (slice.canFind(' '))
        {
            event.aux[0] = slice.advancePast(' ');
            //event.content = slice.advancePast(' ');
            event.content = slice.strippedRight;
        }
        else
        {
            event.aux[0] = slice.strippedRight;
        }
        break;

    case RPL_CREATIONTIME: // 329
        // :kornbluth.freenode.net 329 kameloso #flerrp 1512995737
        slice.advancePast(' ');
        event.channel.name = slice.advancePast(' ');
        event.count[0] = slice.to!long;
        break;

    case RPL_LIST: // 322
        // <channel> <# visible> :<topic>
        // :irc.RomaniaChat.eu 322 kameloso #GameOfThrones 1 :[+ntTGfB]
        // :irc.RomaniaChat.eu 322 kameloso #radioclick 63 :[+ntr]  Bun venit pe #Radioclick! Site oficial www.radioclick.ro sau servere irc.romaniachat.eu, irc.radioclick.ro
        // :eggbert.ca.na.irchighway.net 322 kameloso * 3 :
        /*
            (asterisk channels)
            milky | channel isn't public nor are you a member
            milky | Unreal inserts that instead of not sending the result
            milky | Other IRCd may do same because they are all derivatives
         */
        slice.advancePast(' '); // bot nickname
        event.channel.name = slice.advancePast(' ');
        event.count[0] = slice.advancePast(" :").to!long;
        event.content = slice;
        break;

    case RPL_LISTSTART: // 321
        // Channel :Users  Name
        // :cherryh.freenode.net 321 kameloso^ Channel :Users  Name
        // none of the fields are interesting...
        break;

    case RPL_ENDOFQUIETLIST: // 729, oftc/hybrid 345
        // :niven.freenode.net 729 kameloso^ #hirrsteff q :End of Channel Quiet List
        // :irc.oftc.net 345 kameloso #garderoben :End of Channel Quiet List
        slice.advancePast(' ');
        event.channel.name = slice.canFind(" q :") ?
            slice.advancePast(" q :") :
            slice.advancePast(" :");
        event.content = slice;
        break;

    case RPL_WHOISMODES: // 379
        // <nickname> :is using modes <modes>
        // :cadance.canternet.org 379 kameloso kameloso :is using modes +ix
        slice.advancePast(' '); // bot nickname
        event.target.nickname = slice.advancePast(" :is using modes ");

        if (slice.canFind(' '))
        {
            event.aux[0] = slice.advancePast(' ');
            event.content = slice;
        }
        else
        {
            event.aux[0] = slice;
        }
        break;

    case RPL_WHOWASUSER: // 314
        import lu.string : stripped;

        // <nick> <user> <host> * :<real name>
        // :irc.uworld.se 314 kameloso^^ kameloso ~NaN C2802314.E23AD7D8.E9841504.IP * : kameloso!
        slice.advancePast(' '); // bot nickname
        event.target.nickname = slice.advancePast(' ');
        event.target.ident = slice.advancePast(' ');
        event.aux[0] = slice.advancePast(" * :");
        if (event.aux[0].length) event.target.address = event.aux[0];
        event.content = slice.stripped;
        event.target.realName = event.content;
        break;

    case CHGHOST:
        // :Miyabro!~Miyabro@DA8192E8:4D54930F:650EE60D:IP CHGHOST ~Miyabro Miyako.is.mai.waifu
        event.sender.ident = slice.advancePast(' ');
        event.sender.address = slice;
        event.content = slice;
        break;

    case RPL_HELLO: // 020
        // :irc.run.net 020 irc.run.net :*** You are connected to RusNet. Please wait...
        // :irc.portlane.se 020 * :Please wait while we process your connection.
        slice.advancePast(" :");
        event.content = slice;
        parser.server.resolvedAddress = event.sender.address;
        version(FlagAsUpdated) parser.updates |= IRCParser.Update.server;
        break;

    case SPAMFILTERLIST: // 941
    case RPL_BANLIST: // 367
        // <channel> <banid> // 367
        // :siren.de.SpotChat.org 941 kameloso #linuxmint-help spotify.com/album Butterfly 1513796216
        // ":kornbluth.freenode.net 367 kameloso #flerrp harbl!harbl@snarbl.com zorael!~NaN@2001:41d0:2:80b4:: 1513899521"
        // :irc.run.net 367 kameloso #politics *!*@broadband-46-242-*.ip.moscow.rt.ru
        slice.advancePast(' '); // bot nickname
        event.channel.name = slice.advancePast(' ');

        if (slice.canFind(' '))
        {
            event.content = slice.advancePast(' ');
            event.aux[0] = slice.advancePast(' ');  // nickname that set the mode
            event.count[0] = slice.to!long;
        }
        else
        {
            event.content = slice;
        }
        break;

    case RPL_AWAY: // 301
        // <nick> :<away message>
        // :hitchcock.freenode.net 301 kameloso^ Morrolan :Auto away at Tue Mar  3 09:43:26 2020
        // Sent if you send a message (or WHOIS) a user who is away
        slice.advancePast(' '); // bot nickname
        event.sender.nickname = slice.advancePast(" :");
        event.sender.address = string.init;
        version(BotElements) event.sender.class_ = IRCUser.Class.unset;
        event.content = slice;
        break;

    case RPL_SASLSUCCESS: // 903
        // :weber.freenode.net 903 * :SASL authentication successful
        slice.advancePast(" :");  // asterisk, possible nickname?
        event.content = slice;
        break;

    case THISSERVERINSTEAD: // 010
        // :irc.link-net.be 010 zorael irc.link-net.be +6697 :Please use this Server/Port instead$
        import std.conv : ConvException, to;

        slice.advancePast(' '); // bot nickname
        event.aux[0] = slice.advancePast(' ');
        string portstring = slice.advancePast(" :");  // mutable
        event.content = slice;

        if (portstring.startsWith('+')) portstring = portstring[1..$];

        event.aux[1] = portstring;

        try
        {
            event.count[0] = portstring.to!int;
        }
        catch (ConvException _)
        {
            // Ignore
        }
        break;

    case ERR_BADCHANNAME: // 479
        // :helix.oftc.net 479 zorael|8 - :Illegal channel name
        slice.advancePast(' '); // bot nickname
        event.aux[0] = slice.advancePast(" :");
        event.content = slice;
        break;

    default:
        if ((event.type == NUMERIC) || (event.type == UNSET))
        {
            enum message = "Uncaught `IRCEvent.Type.NUMERIC` or `IRCEvent.Type.UNSET`";
            throw new IRCParseException(message, event);
        }

        return parser.parseGeneralCases(event, slice);
    }
}


// parseGeneralCases
/++
    Takes a slice of a raw IRC string and continues parsing it into an
    [dialect.defs.IRCEvent|IRCEvent] struct.

    This function only focuses on applying general heuristics to the remaining
    line, dividing it into fields like `target`, `channel`, `content`, etc; not
    based by its type but rather by how the string looks.

    The [dialect.defs.IRCEvent|IRCEvent] is finished at the end of this function.

    Params:
        parser = Reference to the current [IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] to continue
            working on.
        slice = Reference to the slice of the raw IRC string.

    See_Also:
        [parsePrefix]
        [parseBasic]
        [parseTypestring]
        [parseSpecialcases]
 +/
void parseGeneralCases(
    const ref IRCParser parser,
    ref IRCEvent event,
    ref string slice) pure @safe
{
    import std.algorithm.searching : canFind, startsWith;

    if (!slice.length)
    {
        // Do nothing
    }
    else if (slice.startsWith(':'))
    {
        // Merely nickname!ident@address.tld TYPESTRING :content
        event.content = slice[1..$];
    }
    else if (slice.canFind(" :"))
    {
        // Has colon-content
        string targets = slice.advancePast(" :");  // mutable

        if (!targets.length)
        {
            // This should never happen, but ward against range errors
            event.content = slice;
        }
        else if (targets.canFind(' '))
        {
            // More than one target
            immutable firstTarget = targets.advancePast(' ');

            if ((firstTarget == parser.client.nickname) || (firstTarget == "*"))
            {
                // More than one target, first is bot
                // Can't use isChan here since targets may contain spaces

                if (parser.server.chantypes.canFind(targets[0]))
                {
                    // More than one target, first is bot
                    // Second target is/begins with a channel

                    if (targets.canFind(' '))
                    {
                        // More than one target, first is bot
                        // Second target is more than one, first is channel
                        // assume third is content
                        event.channel.name = targets.advancePast(' ');
                        event.content = targets;
                    }
                    else
                    {
                        // More than one target, first is bot
                        // Only one channel
                        event.channel.name = targets;
                    }
                }
                else
                {
                    import std.algorithm.searching : count;

                    // More than one target, first is bot
                    // Second is not a channel

                    immutable numSpaces = targets.count(' ');

                    if (numSpaces == 1)
                    {
                        // Two extra targets; assume nickname and channel
                        event.target.nickname = targets.advancePast(' ');
                        event.channel.name = targets;
                    }
                    else if (numSpaces > 1)
                    {
                        // A lot of spaces; cannot say for sure what is what
                        event.aux[0] = targets;
                    }
                    else /*if (numSpaces == 0)*/
                    {
                        // Only one second target

                        if (parser.server.chantypes.canFind(targets[0]))
                        {
                            // Second is a channel
                            event.channel.name = targets;
                        }
                        else if (targets == event.sender.address)
                        {
                            // Second is sender's address, probably server
                            event.aux[0] = targets;
                        }
                        else
                        {
                            // Second is not a channel
                            event.target.nickname = targets;
                        }
                    }
                }
            }
            else
            {
                // More than one target, first is not bot

                if (parser.server.chantypes.canFind(firstTarget[0]))
                {
                    // First target is a channel
                    // Assume second is a nickname
                    event.channel.name = firstTarget;
                    event.target.nickname = targets;
                }
                else
                {
                    // First target is not channel, assume nick
                    // Assume second is channel
                    event.target.nickname = firstTarget;
                    event.channel.name = targets;
                }
            }
        }
        else if (parser.server.chantypes.canFind(targets[0]))
        {
            // Only one target, it is a channel
            event.channel.name = targets;
        }
        else
        {
            // Only one target, not a channel
            event.target.nickname = targets;
        }
    }
    else
    {
        // Does not have colon-content
        if (slice.canFind(' '))
        {
            // More than one target
            immutable target = slice.advancePast(' ');

            if (!target.length)
            {
                // This should never happen, but ward against range errors
                event.content = slice;
            }
            else if (parser.server.chantypes.canFind(target[0]))
            {
                // More than one target, first is a channel
                // Assume second is content
                event.channel.name = target;
                event.content = slice;
            }
            else
            {
                // More than one target, first is not a channel
                // Assume first is nickname and second is aux
                event.target.nickname = target;

                if ((target == parser.client.nickname) && slice.canFind(' '))
                {
                    // First target is bot, and there is more
                    // :asimov.freenode.net 333 kameloso^ #garderoben klarrt!~bsdrouter@h150n13-aahm-a11.ias.bredband.telia.com 1476294377
                    // :kornbluth.freenode.net 367 kameloso #flerrp harbl!harbl@snarbl.com zorael!~NaN@2001:41d0:2:80b4:: 1513899521
                    // :niven.freenode.net 346 kameloso^ #flerrp asdf!fdas@asdf.net zorael!~NaN@2001:41d0:2:80b4:: 1514405089
                    // :irc.run.net 367 kameloso #Help *!*@broadband-5-228-255-*.moscow.rt.ru
                    // :irc.atw-inter.net 344 kameloso #debian.de towo!towo@littlelamb.szaf.org

                    if (parser.server.chantypes.canFind(slice[0]))
                    {
                        // Second target is channel
                        event.channel.name = slice.advancePast(' ');

                        if (slice.canFind(' '))
                        {
                            // Remaining slice has at least two fields;
                            // separate into content and aux
                            event.content = slice.advancePast(' ');
                            event.aux[0] = slice;
                        }
                        else
                        {
                            // Remaining slice is one bit of text
                            event.content = slice;
                        }
                    }
                    else
                    {
                        // No-channel second target
                        // When does this happen?
                        event.content = slice;
                    }
                }
                else
                {
                    // No second target
                    // :port80b.se.quakenet.org 221 kameloso +i
                    event.aux[0] = slice;
                }
            }
        }
        else
        {
            // Only one target

            if (parser.server.chantypes.canFind(slice[0]))
            {
                // Target is a channel
                event.channel.name = slice;
            }
            else
            {
                // Target is a nickname
                event.target.nickname = slice;
            }
        }
    }

    // If content is empty and slice hasn't already been used, assign it
    if (!event.content.length && (slice != event.channel.name) &&
        (slice != event.target.nickname))
    {
        import lu.string : strippedRight;
        event.content = slice.strippedRight;
    }
}


// postparseSanityCheck
/++
    Checks for some specific erroneous edge cases in an [dialect.defs.IRCEvent|IRCEvent].

    Descriptions of the errors are stored in `event.errors`.

    Params:
        parser = Reference to the current [IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] to continue
            working on.
 +/
void postparseSanityCheck(
    const ref IRCParser parser,
    ref IRCEvent event) pure @safe
{
    import std.algorithm.searching : canFind, startsWith;
    import std.array : Appender;

    Appender!(char[]) sink;
    // The sink will very rarely be used; treat it as an edge case and don't reserve

    if ((event.type == IRCEvent.Type.UNSET) && event.errors.length)
    {
        sink.put("Unknown typestring: ");
        sink.put(event.errors);
        event.errors = string.init;  // clear it, it will be set later below
    }

    if (event.target.nickname.canFind(' ') ||
        event.channel.name.canFind(' '))
    {
        if (sink[].length) sink.put(" | ");
        sink.put("Spaces in target nickname or channel");
    }

    if (event.target.nickname.startsWith(':'))
    {
        if (sink[].length) sink.put(" | ");
        sink.put("Colon in target nickname");
    }

    if (event.target.nickname.length &&
        parser.server.chantypes.canFind(event.target.nickname[0]))
    {
        if (sink[].length) sink.put(" | ");
        sink.put("Target nickname is a channel");
    }

    if (event.channel.name.length &&
        !parser.server.chantypes.canFind(event.channel.name[0]) &&
        (event.type != IRCEvent.Type.ERR_NOSUCHCHANNEL) &&
        (event.type != IRCEvent.Type.RPL_ENDOFWHO) &&
        (event.type != IRCEvent.Type.RPL_NAMREPLY) &&
        (event.type != IRCEvent.Type.RPL_ENDOFNAMES) &&
        (event.type != IRCEvent.Type.SELFJOIN) &&  // Twitch
        (event.type != IRCEvent.Type.SELFPART) &&  // Twitch
        (event.type != IRCEvent.Type.RPL_LIST))  // Some channels can be asterisks if they aren't public
    {
        if (sink[].length) sink.put(" | ");
        sink.put("Channel is not a channel");
    }

    if (sink[].length)
    {
        if (event.errors.length) event.errors ~= " | ";
        event.errors ~= sink[].idup;
    }
}


// onNotice
/++
    Handle [dialect.defs.IRCEvent.Type.NOTICE|NOTICE] events.

    These are all(?) sent by the server and/or services. As such they often
    convey important special things, so parse those.

    Params:
        parser = Reference to the current [IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] to continue
            working on.
        slice = Reference to the slice of the raw IRC string.
 +/
void onNotice(
    ref IRCParser parser,
    ref IRCEvent event,
    ref string slice) pure @safe
in (slice.length, "Tried to process `onNotice` on an empty slice")
{
    import dialect.common : isAuthService;
    import std.algorithm.comparison : among;
    import std.algorithm.searching : canFind, startsWith;

    // :ChanServ!ChanServ@services. NOTICE kameloso^ :[##linux-overflow] Make sure your nick is registered, then please try again to join ##linux.
    // :ChanServ!ChanServ@services. NOTICE kameloso^ :[#ubuntu] Welcome to #ubuntu! Please read the channel topic.
    // :tolkien.freenode.net NOTICE * :*** Checking Ident

    // At least Twitch sends NOTICEs to channels, maybe other daemons do too
    immutable channelOrNickname = slice.advancePast(" :", inherit: true);
    event.content = slice;

    if (channelOrNickname.length &&
        parser.server.chantypes.canFind(channelOrNickname[0]))
    {
        event.channel.name = channelOrNickname;
    }

    if (!event.content.length) return;

    if (!parser.server.resolvedAddress.length && event.content.startsWith("***"))
    {
        // This is where we catch the resolved address
        assert(!event.sender.nickname.length, "Unexpected nickname: " ~ event.sender.nickname);
        parser.server.resolvedAddress = event.sender.address;
        version(FlagAsUpdated) parser.updates |= IRCParser.Update.server;
    }

    if (!event.sender.isServer && event.sender.isAuthService(parser))
    {
        import std.algorithm.searching : canFind;
        import std.algorithm.comparison : among;
        import std.uni : asLowerCase;

        enum AuthChallenge
        {
            dalnet = "This nick is owned by someone else. Please choose another.",
            oftc = "This nickname is registered and protected.",
        }

        if (event.content.asLowerCase.canFind("/msg nickserv identify") ||
            (event.content == AuthChallenge.dalnet) ||
            event.content.startsWith(cast(string)AuthChallenge.oftc))
        {
            event.type = IRCEvent.Type.AUTH_CHALLENGE;
            return;
        }

        enum AuthSuccess
        {
            freenode = "You are now identified for",
            rizon = "Password accepted - you are now recognized.",  // also gimpnet
            quakenet = "You are now logged in as",  // also mozilla, snoonet
            gamesurge = "I recognize you.",
            dalnet = "Password accepted for",
            oftc = "You are successfully identified as",
        }

        alias AS = AuthSuccess;

        if ((event.content.startsWith(cast(string)AS.freenode)) ||
            (event.content.startsWith(cast(string)AS.quakenet)) || // also Freenode SASL
            (event.content.startsWith(cast(string)AS.dalnet)) ||
            (event.content.startsWith(cast(string)AS.oftc)) ||
            event.content.among!(cast(string)AS.rizon, cast(string)AS.gamesurge))
        {
            event.type = IRCEvent.Type.AUTH_SUCCESS;

            // Restart with the new type
            return parser.parseSpecialcases(event, slice);
        }

        enum AuthFailure
        {
            rizon = "Your nick isn't registered.",
            quakenet = "Username or password incorrect.",
            freenodeInvalid = "is not a registered nickname.",
            freenodeRejected = "Invalid password for",
            dalnetInvalid = "is not registered.",  // also OFTC
            dalnetRejected = "The password supplied for",
            unreal = "isn't registered.",
            gamesurgeInvalid = "Could not find your account -- did you register yet?",
            gamesurgeRejected = "Incorrect password; please try again.",
            geekshedRejected = "Password incorrect.",  // also irchighway, rizon, rusnet
            oftcRejected = "Identify failed as",
        }

        alias AF = AuthFailure;

        if (event.content.among!
                (AF.rizon,
                AF.quakenet,
                AF.gamesurgeInvalid,
                AF.gamesurgeRejected,
                AF.geekshedRejected) ||
            event.content.canFind(
                cast(string)AF.freenodeInvalid,
                cast(string)AF.dalnetInvalid,
                cast(string)AF.unreal) ||
            event.content.startsWith(
                cast(string)AF.freenodeRejected,
                cast(string)AF.dalnetRejected,
                cast(string)AF.oftcRejected))
        {
            event.type = IRCEvent.Type.AUTH_FAILURE;
        }
    }

    // FIXME: support
    // *** If you are having problems connecting due to ping timeouts, please type /quote PONG j`ruV\rcn] or /raw PONG j`ruV\rcn] now.
}


// onPRIVMSG
/++
    Handle [dialect.defs.IRCEvent.Type.QUERY|QUERY] and
    [dialect.defs.IRCEvent.Type.CHAN|CHAN] messages
    ([dialect.defs.IRCEvent.Type.PRIVMSG|PRIVMSG]).

    Whether or not it is a private query message or a channel message is only
    obvious by looking at the target field of it; if it starts with a `#`, it is
    a channel message.

    Also handle `ACTION` events (`/me slaps foo with a large trout`), and change
    the type to `CTCP_`-types if applicable.

    Params:
        parser = Reference to the current [IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] to continue
            working on.
        slice = Reference to the slice of the raw IRC string.

    Throws: [dialect.common.IRCParseException|IRCParseException] on unknown CTCP types.
 +/
void onPRIVMSG(
    const ref IRCParser parser,
    ref IRCEvent event,
    ref string slice) pure @safe
in (slice.length, "Tried to process `IRCEvent.Type.PRIVMSG` on an empty slice")
{
    import dialect.common : IRCControlCharacter, isValidChannel;

    string target = slice.advancePast(' ');  // mutable
    if (slice.length && slice[0] == ':') slice = slice[1..$];
    event.content = slice;

    /*  When a server sends a PRIVMSG/NOTICE to someone else on behalf of a
        client connected to it – common when multiple clients are connected to a
        bouncer – it is called a self-message. With the echo-message capability,
        they are also sent in reply to every PRIVMSG/NOTICE a client sends.
        These are represented by a protocol message looking like this:

        :yournick!~foo@example.com PRIVMSG someone_else :Hello world!

        They should be put in someone_else's query and displayed as though they
        they were sent by the connected client themselves. This page displays
        which clients properly parse and display this type of echo'd
        PRIVMSG/NOTICE.

        http://defs.ircdocs.horse/info/selfmessages.html

        (common requested cap: znc.in/self-message)
     */

    if (target.isValidChannel(parser.server))
    {
        // :zorael!~NaN@ns3363704.ip-94-23-253.eu PRIVMSG #flerrp :test test content
        event.type = (event.sender.nickname == parser.client.nickname) ?
            IRCEvent.Type.SELFCHAN :
            IRCEvent.Type.CHAN;
        event.channel.name = target;
    }
    else
    {
        // :zorael!~NaN@ns3363704.ip-94-23-253.eu PRIVMSG kameloso^ :test test content
        event.type = (event.sender.nickname == parser.client.nickname) ?
            IRCEvent.Type.SELFQUERY :
            IRCEvent.Type.QUERY;
        event.target.nickname = target;
    }

    if (slice.length < 3) return;

    if ((slice[0] == IRCControlCharacter.ctcp) && (slice[$-1] == IRCControlCharacter.ctcp))
    {
        import std.traits : EnumMembers;

        slice = slice[1..$-1];  // slice away the control characters
        immutable ctcpEvent = slice.advancePast(' ', inherit: true);
        event.content = slice;

        // :zorael!~NaN@ns3363704.ip-94-23-253.eu PRIVMSG #flerrp :ACTION test test content
        // :zorael!~NaN@ns3363704.ip-94-23-253.eu PRIVMSG kameloso^ :ACTION test test content
        // :py-ctcp!ctcp@ctcp-scanner.rizon.net PRIVMSG kameloso^^ :VERSION
        // :wob^2!~zorael@2A78C947:4EDD8138:3CB17EDC:IP PRIVMSG kameloso^^ :TIME
        // :wob^2!~zorael@2A78C947:4EDD8138:3CB17EDC:IP PRIVMSG kameloso^^ :PING 1495974267 590878
        // :wob^2!~zorael@2A78C947:4EDD8138:3CB17EDC:IP PRIVMSG kameloso^^ :CLIENTINFO
        // :wob^2!~zorael@2A78C947:4EDD8138:3CB17EDC:IP PRIVMSG kameloso^^ :DCC
        // :wob^2!~zorael@2A78C947:4EDD8138:3CB17EDC:IP PRIVMSG kameloso^^ :SOURCE
        // :wob^2!~zorael@2A78C947:4EDD8138:3CB17EDC:IP PRIVMSG kameloso^^ :USERINFO
        // :wob^2!~zorael@2A78C947:4EDD8138:3CB17EDC:IP PRIVMSG kameloso^^ :FINGER

        /++
            This iterates through all [dialect.defs.IRCEvent.Type|IRCEvent.Type]s that
            begin with `CTCP_` and generates switch cases for the string of
            each. Inside it will assign `event.type` to the corresponding
            [dialect.defs.IRCEvent.Type|IRCEvent.Type].

            Like so, except automatically generated through compile-time
            introspection:

                case "CTCP_PING":
                    event.type = CTCP_PING;
                    event.aux[0] = "PING";
                    break;
         +/

        with (IRCEvent.Type)
        top:
        switch (ctcpEvent)
        {
        case "ACTION":
            // We already sliced away the control characters and advanced past the
            // "ACTION" ctcpEvent string, so just set the type and break.
            event.type = (event.sender.nickname == parser.client.nickname) ?
                IRCEvent.Type.SELFEMOTE :
                IRCEvent.Type.EMOTE;
            break;

        foreach (immutable type; EnumMembers!(IRCEvent.Type))
        {
            import lu.conv : toString;
            import std.algorithm.searching : startsWith;

            enum typestring = type.toString();

            static if (typestring.startsWith("CTCP_"))
            {
                case typestring[5..$]:
                    event.type = type;
                    event.aux[0] = typestring[5..$];
                    if (event.content == event.aux[0]) event.content = string.init;
                    break top;
            }
        }

        default:
            immutable message = "Unknown CTCP event: `" ~ ctcpEvent ~ '`';
            throw new IRCParseException(message, event);
        }
    }
}


// onMode
/++
    Handle [dialect.defs.IRCEvent.Type.MODE|MODE] changes.

    Params:
        parser = Reference to the current [IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] to continue
            working on.
        slice = Reference to the slice of the raw IRC string.
 +/
void onMode(
    ref IRCParser parser,
    ref IRCEvent event,
    ref string slice) pure @safe
in (slice.length, "Tried to process `onMode` on an empty slice")
{
    import dialect.common : isValidChannel;
    import std.algorithm.searching : canFind, startsWith;

    immutable target = slice.advancePast(' ');

    if (target.isValidChannel(parser.server))
    {
        event.channel.name = target;

        if (slice.canFind(' '))
        {
            // :zorael!~NaN@ns3363704.ip-94-23-253.eu MODE #flerrp +v kameloso^
            event.aux[0] = slice.advancePast(' ');
            // save target in content; there may be more than one
            event.content = slice;
        }
        else
        {
            // :zorael!~NaN@ns3363704.ip-94-23-253.eu MODE #flerrp +i
            // :niven.freenode.net MODE #sklabjoier +ns
            //event.type = IRCEvent.Type.USERMODE;
            event.aux[0] = slice;
        }
    }
    else
    {
        import std.string : representation;

        // :kameloso^ MODE kameloso^ :+i
        // :<something> MODE kameloso :ix
        // Does not always have the plus sign. Strip it if it's there.

        event.type = IRCEvent.Type.SELFMODE;
        if (slice.startsWith(':')) slice = slice[1..$];

        bool subtractive;
        string modechange = slice;  // mutable

        if (!slice.length) return;  // Just to safeguard before indexing [0]

        switch (slice[0])
        {
        case '-':
            subtractive = true;
            goto case '+';

        case '+':
            slice = slice[1..$];
            break;

        default:
            // No sign, implicitly additive
            modechange = '+' ~ slice;
        }

        event.aux[0] = modechange;

        if (subtractive)
        {
            // Remove the mode from client.modes
            auto mutModes  = parser.client.modes.dup.representation;  // mnutable

            foreach (immutable modechar; slice.representation)
            {
                import std.algorithm.mutation : SwapStrategy, remove;
                mutModes = mutModes.remove!((listedModechar => listedModechar == modechar), SwapStrategy.unstable);
            }

            parser.client.modes = cast(string)mutModes.idup;
        }
        else
        {
            import std.algorithm.iteration : filter, uniq;
            import std.algorithm.sorting : sort;
            import std.array : array;

            // Add the new mode to client.modes
            auto modes = parser.client.modes.dup.representation;
            modes ~= slice;
            parser.client.modes = cast(string)modes
                .sort
                .uniq
                .array
                .idup;
        }

        version(FlagAsUpdated) parser.updates |= IRCParser.Update.client;
    }
}

///
unittest
{
    IRCParser parser;
    parser.client.nickname = "kameloso^";
    parser.client.modes = "x";

    {
        IRCEvent event;
        string slice = /*":kameloso^ MODE */"kameloso^ :+i";
        parser.onMode(event, slice);
        assert((parser.client.modes == "ix"), parser.client.modes);
    }
    {
        IRCEvent event;
        string slice = /*":kameloso^ MODE */"kameloso^ :-i";
        parser.onMode(event, slice);
        assert((parser.client.modes == "x"), parser.client.modes);
    }
    {
        IRCEvent event;
        string slice = /*":kameloso^ MODE */"kameloso^ :+abc";
        parser.onMode(event, slice);
        assert((parser.client.modes == "abcx"), parser.client.modes);
    }
    {
        IRCEvent event;
        string slice = /*":kameloso^ MODE */"kameloso^ :-bx";
        parser.onMode(event, slice);
        assert((parser.client.modes == "ac"), parser.client.modes);
    }
}


// onISUPPORT
/++
    Handles [dialect.defs.IRCEvent.Type.RPL_ISUPPORT|RPL_ISUPPORT] events.

    [dialect.defs.IRCEvent.Type.RPL_ISUPPORT|RPL_ISUPPORT] contains a bunch of
    interesting information that changes how we look at the
    [dialect.defs.IRCServer|IRCServer]. Notably which *network* the server is of
    and its max channel and nick lengths, and available modes. Then much
    more that we're currently ignoring.

    Params:
        parser = Reference to the current [IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] to continue
            working on.
        slice = Reference to the slice of the raw IRC string.

    Throws:
        [dialect.common.IRCParseException|IRCParseException] if something
        could not be parsed or converted.
 +/
void onISUPPORT(
    ref IRCParser parser,
    ref IRCEvent event,
    ref string slice) pure @safe
in (slice.length, "Tried to process `IRCEvent.Type.RPL_ISUPPORT` on an empty slice")
{
    import std.algorithm.iteration : splitter;
    import std.algorithm.searching : canFind;
    import std.conv : /*ConvException,*/ to;

    // :barjavel.freenode.net 005 kameloso^ CHARSET=ascii NICKLEN=16 CHANNELLEN=50 TOPICLEN=390 DEAF=D FNC TARGMAX=NAMES:1,LIST:1,KICK:1,WHOIS:1,PRIVMSG:4,NOTICE:4,ACCEPT:,MONITOR: EXTBAN=$,ajrxz CLIENTVER=3.0 WHOX KNOCK CPRIVMSG :are supported by this server
    // :barjavel.freenode.net 005 kameloso^ CHANTYPES=# EXCEPTS INVEX CHANMODES=eIbq,k,flj,CFLMPQScgimnprstuz CHANLIMIT=#:120 PREFIX=(ov)@+ MAXLIST=bqeI:100 MODES=4 NETWORK=freenode STATUSMSG=@+ CALLERID=g CASEMAPPING=rfc1459 :are supported by this server

    slice.advancePast(' ');  // bot nickname
    if (slice.canFind(" :")) event.content = slice.advancePast(" :");

    if (parser.server.supports.length)
    {
        // Not the first event, add a space first
        parser.server.supports ~= ' ';
    }

    parser.server.supports ~= event.content;

    try
    {
        uint n;

        foreach (value; event.content.splitter(' '))
        {
            if (n < event.aux.length)
            {
                // Include the value-key pairs in aux, now that there's room
                event.aux[n++] = value;
            }

            if (!value.canFind('='))
            {
                // insert switch on value for things like EXCEPTS, INVEX, CPRIVMSG, etc
                continue;
            }

            immutable key = value.advancePast('=');

            /// http://www.irc.org/tech_docs/005.html

            switch (key)
            {
            case "PREFIX":
                // PREFIX=(Yqaohv)!~&@%+
                import std.format : formattedRead;

                string modechars;  // mutable
                string modesigns;  // mutable

                // formattedRead can throw but just let the main loop pick it up
                value.formattedRead("(%s)%s", modechars, modesigns);
                parser.server.prefixes = modechars;

                foreach (immutable i; 0..modechars.length)
                {
                    parser.server.prefixchars[modesigns[i]] = modechars[i];
                }
                break;

            case "CHANTYPES":
                // CHANTYPES=#
                // ...meaning which characters may prefix channel names.
                parser.server.chantypes = value;
                break;

            case "CHANMODES":
                /++
                    This is a list of channel modes according to 4 types.

                    A = Mode that adds or removes a nick or address to a list.
                        Always has a parameter.
                    B = Mode that changes a setting and always has a parameter.
                    C = Mode that changes a setting and only has a parameter when
                        set.
                    D = Mode that changes a setting and never has a parameter.

                    Freenode: CHANMODES=eIbq,k,flj,CFLMPQScgimnprstz
                 +/
                string modeslice = value;  // mutable
                parser.server.aModes = modeslice.advancePast(',');
                parser.server.bModes = modeslice.advancePast(',');
                parser.server.cModes = modeslice.advancePast(',');
                parser.server.dModes = modeslice;
                assert(!parser.server.dModes.canFind(','),
                    "Bad chanmodes; dModes has comma: " ~ parser.server.dModes);
                break;

            case "NETWORK":
                import dialect.common : typenumsOf;

                switch (value)
                {
                case "RusNet":
                    // RusNet servers do not advertise an easily-identifiable
                    // daemonstring like "1.5.24/uk_UA.KOI8-U", so fake the daemon
                    // here.
                    parser.typenums = typenumsOf(IRCServer.Daemon.rusnet);
                    parser.server.daemon = IRCServer.Daemon.rusnet;
                    break;

                case "IRCnet":
                    // Likewise IRCnet only advertises the daemon version and not
                    // the daemon name. (2.11.2p3)
                    parser.typenums = typenumsOf(IRCServer.Daemon.ircnet);
                    parser.server.daemon = IRCServer.Daemon.ircnet;
                    break;

                case "Rizon":
                    // Rizon reports hybrid but actually has some extras
                    // onMyInfo will have already melded typenums for Daemon.hybrid,
                    // but Daemon.rizon just applies on top of it.
                    parser.typenums = typenumsOf(IRCServer.Daemon.rizon);
                    parser.server.daemon = IRCServer.Daemon.rizon;
                    break;

                default:
                    break;
                }

                parser.server.network = value;
                break;

            case "NICKLEN":
                parser.server.maxNickLength = value.to!uint;
                break;

            case "CHANNELLEN":
                parser.server.maxChannelLength = value.to!uint;
                break;

            case "CASEMAPPING":
                import lu.conv : Enum;
                parser.server.caseMapping = Enum!(IRCServer.CaseMapping).fromString(value);
                break;

            case "EXTBAN":
                // EXTBAN=$,ajrxz
                // EXTBAN=
                // no character means implicitly $, I believe?
                immutable prefix = value.advancePast(',');
                parser.server.extbanPrefix = prefix.length ? prefix.to!char : '$';
                parser.server.extbanTypes = value;
                break;

            case "EXCEPTS":
                parser.server.exceptsChar = value.length ? value.to!char : 'e';
                break;

            case "INVEX":
                parser.server.invexChar = value.length ? value.to!char : 'I';
                break;

            default:
                break;
            }
        }

        event.content = string.init;
        version(FlagAsUpdated) parser.updates |= IRCParser.Update.server;
    }
    /*catch (ConvException e)
    {
        throw new IRCParseException(e.msg, event, e.file, e.line);
    }*/
    catch (Exception e)
    {
        throw new IRCParseException(e.msg, event, e.file, e.line);
    }
}


// onMyInfo
/++
    Handle [dialect.defs.IRCEvent.Type.RPL_MYINFO|RPL_MYINFO] events.

    `MYINFO` contains information about which *daemon* the server is running.
    We want that to be able to meld together a good `typenums` array.

    It fires before [dialect.defs.IRCEvent.Type.RPL_ISUPPORT|RPL_ISUPPORT].

    Params:
        parser = Reference to the current [IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] to continue
            working on.
        slice = Reference to the slice of the raw IRC string.
 +/
void onMyInfo(
    ref IRCParser parser,
    ref IRCEvent event,
    ref string slice) pure @safe
in (slice.length, "Tried to process `onMyInfo` on an empty slice")
{
    import dialect.common : typenumsOf;
    import std.algorithm.searching : canFind, countUntil;
    import std.meta : AliasSeq;
    import std.uni : toLower;

    /*
    cadance.canternet.org                   InspIRCd-2.0
    barjavel.freenode.net                   ircd-seven-1.1.4
    irc.uworld.se                           plexus-4(hybrid-8.1.20)
    port80c.se.quakenet.org                 u2.10.12.10+snircd(1.3.4a)
    Ashburn.Va.Us.UnderNet.org              u2.10.12.18
    irc2.unrealircd.org                     UnrealIRCd-4.0.16-rc1
    nonstop.ix.me.dal.net                   bahamut-2.0.7
    TAL.DE.EU.GameSurge.net                 u2.10.12.18(gs2)
    efnet.port80.se                         ircd-ratbox-3.0.9
    conclave.il.us.SwiftIRC.net             Unreal3.2.6.SwiftIRC(10)
    caliburn.pa.us.irchighway.net           InspIRCd-2.0
    (twitch)                                -
    irc.RomaniaChat.eu                      Unreal3.2.10.6
    Defiant.GeekShed.net                    Unreal3.2.10.3-gs
    irc.inn.at.euirc.net                    euIRCd 1.3.4-c09c980819
    irc.krstarica.com                       UnrealIRCd-4.0.9
    XxXChatters.Com                         UnrealIRCd-4.0.3.1
    noctem.iZ-smart.net                     Unreal3.2.10.4-iZ
    fedora.globalirc.it                     InspIRCd-2.0
    ee.ircworld.org                         charybdis-3.5.0.IRCWorld
    Armida.german-elite.net                 Unreal3.2.7
    procrastinate.idlechat.net              Unreal3.2.10.4
    irc2.chattersweb.nl                     UnrealIRCd-4.0.11
    Heol.Immortal-Anime.Net                 Unreal3.2.10.5
    brlink.vircio.net                       InspIRCd-2.2
    MauriChat.s2.de.GigaIRC.net             UnrealIRCd-4.0.10
    IRC.101Systems.Com.BR                   UnrealIRCd-4.0.15
    IRC.Passatempo.Org                      UnrealIRCd-4.0.14
    irc01-green.librairc.net                InspIRCd-2.0
    irc.place2chat.com                      UnrealIRCd-4.0.10
    irc.ircportal.net                       Unreal3.2.10.1
    irc.de.icq-chat.com                     InspIRCd-2.0
    lightning.ircstorm.net                  CR1.8.03-Unreal3.2.10.1
    irc.chat-garden.nl                      UnrealIRCd-4.0.10
    alpha.noxether.net                      UnrealIRCd-4.0-Noxether
    CraZyPaLaCe.Be_ChatFun.Be_Webradio.VIP  CR1.8.03-Unreal3.2.8.1
    redhispana.org                          Unreal3.2.8+UDB-3.6.1
    irc.portlane.se (ircnet)                2.11.2p3
     */

    // :asimov.freenode.net 004 kameloso^ asimov.freenode.net ircd-seven-1.1.4 DOQRSZaghilopswz CFILMPQSbcefgijklmnopqrstvz bkloveqjfI
    // :tmi.twitch.tv 004 zorael :-

    /*if (parser.server.daemon != IRCServer.Daemon.init)
    {
        // Daemon remained from previous connects.
        // Trust that the typenums did as well.
        import std.stdio;
        debug writeln("RETURNING BECAUSE NON-INIT DAEMON: ", parser.server.daemon);
        return;
    }*/

    slice.advancePast(' ');  // nickname

    version(TwitchSupport)
    {
        import std.algorithm.searching : endsWith;

        if ((slice == ":-") && (parser.server.address.endsWith(".twitch.tv")))
        {
            parser.typenums = typenumsOf(IRCServer.Daemon.twitch);

            // Twitch doesn't seem to support any modes other than normal prefix op
            with (parser.server)
            {
                daemon = IRCServer.Daemon.twitch;
                daemonstring = "Twitch";
                network = "Twitch";
                prefixes = "o";
                prefixchars = [ '@' : 'o' ];
                maxNickLength = 25;
            }

            version(FlagAsUpdated) parser.updates |= IRCParser.Update.server;
            return;
        }
    }

    slice.advancePast(' ');  // server address
    immutable daemonstring = slice.advancePast(' ');
    immutable daemonstringLower = daemonstring.toLower;
    event.content = slice;
    event.aux[0] = daemonstring;

    // https://upload.wikimedia.org/wikipedia/commons/d/d5/IRCd_software_implementations3.svg

    alias D = IRCServer.Daemon;

    // Manual care has to be taken that these two stay in sync
    static immutable D[13] daemonMap =
    [
        D.unknown,
        D.unreal,
        D.solanum,
        D.inspircd,
        D.snircd,
        D.u2,
        D.bahamut,
        D.hybrid,
        D.ratbox,
        D.charybdis,
        D.ircdseven,
        D.bsdunix,
        D.mfvx,
    ];

    alias daemonLowerSubstrings = AliasSeq!
    (
        //"unknown",  // should not be in here
        "unreal",
        "solanum",
        "inspircd",
        "snircd",
        "u2.",
        "bahamut",
        "hybrid",
        "ratbox",
        "charybdis",
        "ircd-seven",
        "bsdunix",
        "mfvx",
    );

    static assert(daemonLowerSubstrings.length == daemonMap.length +(-1));

    /+
        snircd is a special case because the full string is something like
        "u2.10.12.10+snircd(1.3.4a)", which matches "u2." before it does "snircd".
     +/
    immutable index = daemonstringLower.canFind("snircd") ?
        daemonMap[].countUntil(D.snircd) :
        daemonstringLower.canFind(daemonLowerSubstrings);

    immutable daemon = daemonMap[index];
    parser.typenums = typenumsOf(daemon);
    parser.server.daemon = daemon;
    parser.server.daemonstring = daemonstring;
    version(FlagAsUpdated) parser.updates |= IRCParser.Update.server;
}


// applyTags
/++
    This is technically a postprocessor but it's small enough that we can just
    keep it in here (and provide the functionality as `pure` and `@safe`).

    Params:
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] whose tags to
            apply to itself.
 +/
void applyTags(ref IRCEvent event) pure @safe
{
    import std.algorithm.iteration : splitter;
    import std.algorithm.searching : canFind;

    foreach (tag; event.tags.splitter(";"))
    {
        import lu.string : advancePast;

        if (tag.canFind('='))
        {
            immutable key = tag.advancePast('=');
            alias value = tag;

            switch (key)
            {
            case "account":
                event.sender.account = value;
                break;

            default:
                // Unknown tag
                break;
            }
        }
        /*else
        {
            switch (tag)
            {
            case "solanum.chat/identify-msg":
                // mquin | I don't think you'd get account tags for an unverified account
                // mquin | yep, account= but no solanum.chat/identified while I was mquin__
                // Currently no use for
                break;

            case "solanum.chat/ip":
                // Currently no use for
                break;

            default:
                // Unknown tag
                break;
            }
        }*/
    }
}


public:


// IRCParser
/++
    Parser that takes raw IRC strings and produces [dialect.defs.IRCEvent|IRCEvent]s based on them.

    Parsing requires state, which means that [IRCParser]s must be equipped with
    a [dialect.defs.IRCServer|IRCServer] and a [dialect.defs.IRCClient|IRCClient] for context when parsing.
    Because of this it has its postblit `@disable`d, so as not to make copies
    when only one instance should exist.

    The alternative is to make it a class, which works too.

    See the `/tests` directory for unit tests.

    Example:
    ---
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

    // Requires Twitch support via build configuration "twitch"
    string fullExample = "@badge-info=subscriber/15;badges=subscriber/12;color=;display-name=SomeoneOnTwitch;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=someoneontwitch;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\\s9d\\s3e\\s68\\sca\\s26\\se9\\s2a\\s6e\\s44\\sd4\\s60\\s9b\\s3d\\saa\\sb9\\s4c\\sad\\s43\\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=someoneOnTwitch\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sxQcOW's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s4\\sin\\sthe\\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type= :tmi.twitch.tv USERNOTICE #xqcow"
    IRCEvent event4 = parser.toIRCEvent(fullExample);

    with (event)
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
    ---
 +/
struct IRCParser
{
    /++
        The current [dialect.defs.IRCClient|IRCClient] with all the context
        needed for parsing.
     +/
    IRCClient client;

    /++
        The current [dialect.defs.IRCServer|IRCServer] with all the context
        needed for parsing.
     +/
    IRCServer server;

    /++
        An `dialect.defs.IRCEvent.Type[1024]` reverse lookup table for fast
        numeric lookups.
     +/
    IRCEvent.Type[1024] typenums = Typenums.base;

    // toIRCEvent
    /++
        Parses an IRC string into an [dialect.defs.IRCEvent|IRCEvent].

        The return type is kept as `auto` to infer attributes. It will be `pure`
        and `@safe` if version `Postprocessors` was not declared, and `@system` otherwise.

        Proxies the call to the top-level [dialect.parsing.toIRCEvent|.toIRCEvent].

        Params:
            raw = Raw IRC string as received from a server.

        Returns:
            A complete [dialect.defs.IRCEvent|IRCEvent].
     +/
    auto toIRCEvent(const string raw)  // infer purity and @safety
    {
        IRCEvent event = .toIRCEvent(this, raw);

        /+
            This verifies some fields and gives meaningful error messages if
            something doesn't look right.
         +/
        postparseSanityCheck(this, event);

        version(Postprocessors)
        {
            // Epilogue: let postprocessors alter the event
            foreach (postprocessor; this.postprocessors)
            {
                postprocessor.postprocess(this, event);
            }
        }

        return event;
    }

    version(Postprocessors)
    {
        // ctor
        /++
            Create a new [IRCParser] with the passed [dialect.defs.IRCClient|IRCClient]
            and [dialect.defs.IRCServer|IRCServer] as base context for parsing.

            Initialises any [dialect.common.Postprocessor|Postprocessor]s available
            iff version `Postprocessors` is declared.

            If it is not declared, this constructor is `pure` and `@safe`.

            See_Also:
                [initPostprocessors]
         +/
        this(
            IRCClient client,
            IRCServer server) /*pure @safe*/
        {
            this.client = client;
            this.server = server;
            initPostprocessors();
        }
    }
    else
    {
        /// Ditto
        this(
            IRCClient client,
            IRCServer server) pure @safe
        {
            this.client = client;
            this.server = server;
            //initPostprocessors();
        }
    }

    /++
        Disallow copying of this struct.
     +/
    @disable this(this);

    version(Postprocessors)
    {
        private import dialect.postprocessors : Postprocessor;

        /++
            Array of active [dialect.common.Postprocessor|Postprocessor]s, to be
            iterated through and processed after parsing is complete.
         +/
        Postprocessor[] postprocessors;

        // initPostprocessors
        /++
            Initialises defined postprocessors.
         +/
        void initPostprocessors() @system
        {
            import dialect.postprocessors : instantiatePostprocessors;

            postprocessors = instantiatePostprocessors();

            version(TwitchSupport)
            {
                enum message = "No postprocessors were instantiated despite version " ~
                    "`TwitchSupport` declared. Make sure to `import dialect.postprocessors.twitch` " ~
                    "somewhere in the importing project.";
                assert(postprocessors.length, message);
            }
        }
    }

    version(FlagAsUpdated)
    {
        // Update
        /++
            Bitfield enum of what member of an instance of `IRCParser` was
            updated (if any).
         +/
        enum Update
        {
            /++
                Nothing marked as updated. Initial value.
             +/
            nothing = 0,
            /++
                Parsing updated the internal [dialect.defs.IRCClient|IRCClient].
             +/
            client = 1 << 0,

            /++
                Parsing updated the internal [dialect.defs.IRCServer|IRCServer].
             +/
            server = 1 << 1,
        }

        // updates
        /++
            Bitfield of in what way the parser's internal state was altered
            during parsing.

            Example:
            ---
            if (parser.updates & IRCParser.Update.client)
            {
                // parser.client was marked as updated
                parser.updates |= IRCParser.Update.server;
                // parser.server now marked as updated
            }
            ---

            See_Also:
                [Update]
                [clientUpdated]
                [serverUpdated]
         +/
        Update updates;

        // clientUpdated
        /++
            Wrapper for backwards compatibility with pre-bitfield update-signaling.

            Returns:
                Whether or not the internal client was updated.
         +/
        pragma(inline, true)
        bool clientUpdated() const pure @safe @nogc nothrow
        {
            return cast(bool)(updates & Update.client);
        }

        // serverUpdated
        /++
            Wrapper for backwards compatibility with pre-bitfield update-signaling.

            Returns:
                Whether or not the internal server was updated.
         +/
        pragma(inline, true)
        bool serverUpdated() const pure @safe @nogc nothrow
        {
            return cast(bool)(updates & Update.server);
        }

        // clientUpdated
        /++
            Wrapper for backwards compatibility with pre-bitfield update-signaling.

            Params:
                updated = Whether or not the internal client should be flagged as updated.
         +/
        pragma(inline, true)
        void clientUpdated(const bool updated) pure @safe @nogc nothrow
        {
            if (updated) updates |= Update.client;
            else updates &= ~Update.client;
        }

        // serverUpdated
        /++
            Wrapper for backwards compatibility with pre-bitfield update-signaling.

            Params:
                updated = Whether or not the internal server should be flagged as updated.
         +/
        pragma(inline, true)
        void serverUpdated(const bool updated) pure @safe @nogc nothrow
        {
            if (updated) updates |= Update.server;
            else updates &= ~Update.server;
        }
    }
}

///
unittest
{
    import lu.meld : MeldingStrategy, meldInto;

    IRCParser parser;

    alias T = IRCEvent.Type;

    parser.typenums = Typenums.base;

    assert(parser.typenums[344] == T.init);
    Typenums.hybrid[].meldInto!(MeldingStrategy.aggressive)(parser.typenums);
    assert(parser.typenums[344] != T.init);
}

///
version(Postprocessors) {}
else
{
    pure @safe unittest
    {
        // Test purity and @safety of IRCParser without postprocessors
        IRCClient client;
        IRCServer server;
        auto parser = IRCParser(client, server);
        parser.toIRCEvent("PING :hello");
    }
}
