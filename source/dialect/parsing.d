/++
 +  Functions related to parsing IRC events.
 +
 +  IRC events come in very heterogeneous forms along the lines of:
 +
 +      `:sender.address.tld TYPE [args...] :content`
 +
 +      `:sender!~ident@address.tld 123 [args...] :content`
 +
 +  The number and syntax of arguments for types vary wildly. As such, one
 +  common parsing routine can't be used; there are simply too many exceptions.
 +  The beginning `:sender.address.tld` is *almost* always the same form, but only
 +  almost. It's guaranteed to be followed by the type however, which come either in
 +  alphanumeric name (e.g. `PRIVMSG`, `INVITE`, `MODE`, ...), or in numeric form
 +  of 001 to 999 inclusive.
 +
 +  What we can do then is to parse this type, and interpret the arguments following
 +  as befits it.
 +
 +  This translates to large switches, which can't be helped. There are simply
 +  too many variations, which switches lend themselves well to. You could make
 +  it into long if...else if chains, but it would just be the same thing in a
 +  different form. Likewise a nested function is not essentially different from
 +  a switch case.
 +
 +  ---
 +  IRCParser parser;
 +
 +  string fromServer = ":zorael!~NaN@address.tld MODE #channel +v nickname";
 +  IRCEvent event = parser.toIRCEvent(fromServer);
 +
 +  with (event)
 +  {
 +      assert(type == IRCEvent.Type.MODE);
 +      assert(sender.nickname == "zorael");
 +      assert(sender.ident == "~NaN");
 +      assert(sender.address == "address.tld");
 +      assert(target.nickname == "nickname");
 +      assert(channel == "#channel");
 +      assert(aux = "+v");
 +  }
 +
 +  string alsoFromServer = ":cherryh.freenode.net 435 oldnick newnick #d " ~
 +      ":Cannot change nickname while banned on channel";
 +  IRCEvent event2 = parser.toIRCEvent(alsoFromServer);
 +
 +  with (event2)
 +  {
 +      assert(type == IRCEvent.Type.ERR_BANONCHAN);
 +      assert(sender.address == "cherryh.freenode.net");
 +      assert(channel == "#d");
 +      assert(target.nickname == "oldnick");
 +      assert(content == "Cannot change nickname while banned on channel");
 +      assert(aux == "newnick");
 +      assert(num == 435);
 +  }
 +
 +  string furtherFromServer = ":kameloso^!~ident@81-233-105-99-no80.tbcn.telia.com NICK :kameloso_";
 +  IRCEvent event3 = parser.toIRCEvent(furtherFromServer);
 +
 +  with (event3)
 +  {
 +      assert(type == IRCEvent.Type.NICK);
 +      assert(sender.nickname == "kameloso^");
 +      assert(sender.ident == "~ident");
 +      assert(sender.address == "81-233-105-99-no80.tbcn.telia.com");
 +      assert(target.nickname = "kameloso_");
 +  }
 +  ---
 +
 +  See the `/tests` directory for more example parses.
 +/
module dialect.parsing;

import dialect.defs;
import dialect.common : IRCParseException, Postprocessor;
import lu.string : contains, nom;

package:

@safe:


// toIRCEvent
/++
 +  Parses an IRC string into an `dialect.defs.IRCEvent`.
 +
 +  Parsing goes through several phases (prefix, typestring, specialcases) and
 +  this is the function that calls them, in order.
 +
 +  See the files in `/tests` for unittest examples.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      raw = Raw IRC string to parse.
 +
 +  Returns:
 +      A finished `dialect.defs.IRCEvent`.
 +
 +  Throws: `dialect.common.IRCParseException` if an empty string was passed.
 +/
public IRCEvent toIRCEvent(ref IRCParser parser, const string raw) pure
{
    if (!raw.length) throw new IRCParseException("Tried to parse empty string");

    IRCEvent event;

    // We don't need to .idup here; it has already been done in the Generator
    // when yielding
    event.raw = raw;

    if (raw[0] != ':')
    {
        if (raw[0] == '@')
        {
            // IRCv3 tags
            // @badges=broadcaster/1;color=;display-name=Zorael;emote-sets=0;mod=0;subscriber=0;user-type= :tmi.twitch.tv USERSTATE #zorael
            // @broadcaster-lang=;emote-only=0;followers-only=-1;mercury=0;r9k=0;room-id=22216721;slow=0;subs-only=0 :tmi.twitch.tv ROOMSTATE #zorael
            // @badges=subscriber/3;color=;display-name=asdcassr;emotes=560489:0-6,8-14,16-22,24-30/560510:39-46;id=4d6bbafb-427d-412a-ae24-4426020a1042;mod=0;room-id=23161357;sent-ts=1510059590512;subscriber=1;tmi-sent-ts=1510059591528;turbo=0;user-id=38772474;user-type= :asdcsa!asdcss@asdcsd.tmi.twitch.tv PRIVMSG #lirik :lirikFR lirikFR lirikFR lirikFR :sled: lirikLUL

            // Get rid of the prepended @
            string newRaw = event.raw[1..$];
            immutable tags = newRaw.nom(' ');
            event = .toIRCEvent(parser, newRaw);
            event.tags = tags;
            return event;
        }
        else
        {
            parser.parseBasic(event);
            return event;
        }
    }

    string slice = event.raw[1..$]; // advance past first colon

    // First pass: prefixes. This is the sender
    parser.parsePrefix(event, slice);

    // Second pass: typestring. This is what kind of action the event is of
    parser.parseTypestring(event, slice);

    // Third pass: specialcases. This splits up the remaining bits into
    // useful strings, like sender, target and content
    parser.parseSpecialcases(event, slice);

    // Final cosmetic touches
    import std.uni : toLower;
    event.channel = event.channel.toLower;

    return event;
}

///
unittest
{
    IRCParser parser;

    // `parser.toIRCEvent` technically calls `IRCParser.toIRCEvent`, but it in turn
    // just passes on to this `.toIRCEvent`

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
 +  Parses the most basic of IRC events; `dialect.defs.IRCEvent.Type.PING`,
 +  `dialect.defs.IRCEvent.Type.ERROR`, `dialect.defs.IRCEvent.Type.PONG`,
 +  `dialect.defs.IRCEvent.Type.NOTICE` (plus `NOTICE AUTH`), and `AUTHENTICATE`.
 +
 +  They syntactically differ from other events in that they are not prefixed
 +  by their sender.
 +
 +  The `dialect.defs.IRCEvent` is finished at the end of this function.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      event = Reference to the `dialect.defs.IRCEvent` to start working on.
 +
 +  Throws: `dialect.common.IRCParseException` if an unknown type was encountered.
 +/
void parseBasic(ref IRCParser parser, ref IRCEvent event) pure @nogc
{
    string slice = event.raw;
    string typestring;

    if (slice.contains(':'))
    {
        typestring = slice.nom(" :");
    }
    else if (slice.contains(' '))
    {
        typestring = slice.nom(' ');
    }
    else
    {
        typestring = slice;
    }

    with (IRCEvent.Type)
    with (parser)
    switch (typestring)
    {
    case "PING":
        // PING :3466174537
        // PING :weber.freenode.net
        event.type = PING;

        if (slice.contains('.'))
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
        import lu.string : beginsWith;

        if (event.raw.beginsWith("NOTICE"))
        {
            // Probably NOTICE <client.nickname>
            // NOTICE kameloso :*** If you are having problems connecting due to ping timeouts, please type /notice F94828E6 nospoof now.
            goto case "NOTICE";
        }
        else
        {
            event.type = UNSET;
            event.aux = event.raw;
            /*throw new IRCParseException("Unknown basic type: " ~
                typestring ~ ": please report this", event);*/
        }
    }

    // All but PING and PONG are sender-less.
    if (!event.sender.address) event.sender.address = parser.server.address;
}

///
unittest
{
    import lu.conv : Enum;

    IRCParser parser;

    IRCEvent e1;
    with (e1)
    {
        raw = "PING :irc.server.address";
        parser.parseBasic(e1);
        assert((type == IRCEvent.Type.PING), Enum!(IRCEvent.Type).toString(type));
        assert((sender.address == "irc.server.address"), sender.address);
        assert(!sender.nickname.length, sender.nickname);
    }

    IRCEvent e2;
    with (e2)
    {
        // QuakeNet and others not having the sending server as prefix
        raw = "NOTICE AUTH :*** Couldn't look up your hostname";
        parser.parseBasic(e2);
        assert((type == IRCEvent.Type.NOTICE), Enum!(IRCEvent.Type).toString(type));
        assert(!sender.nickname.length, sender.nickname);
        assert((content == "*** Couldn't look up your hostname"));
    }

    IRCEvent e3;
    with (e3)
    {
        raw = "ERROR :Closing Link: 81-233-105-62-no80.tbcn.telia.com (Quit: kameloso^)";
        parser.parseBasic(e3);
        assert((type == IRCEvent.Type.ERROR), Enum!(IRCEvent.Type).toString(type));
        assert(!sender.nickname.length, sender.nickname);
        assert((content == "Closing Link: 81-233-105-62-no80.tbcn.telia.com (Quit: kameloso^)"), content);
    }
}


// parsePrefix
/++
 +  Takes a slice of a raw IRC string and starts parsing it into an
 +  `dialect.defs.IRCEvent` struct.
 +
 +  This function only focuses on the prefix; the sender, be it nickname and
 +  ident or server address.
 +
 +  The `dialect.defs.IRCEvent` is not finished at the end of this function.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      event = Reference to the `dialect.defs.IRCEvent` to start working on.
 +      slice = Reference to the *slice* of the raw IRC string.
 +/
void parsePrefix(ref IRCParser parser, ref IRCEvent event, ref string slice) pure
{
    string prefix = slice.nom(' ');

    with (event.sender)
    {
        if (prefix.contains('!'))
        {
            // user!~ident@address
            nickname = prefix.nom('!');
            ident = prefix.nom('@');
            address = prefix;
        }
        else if (prefix.contains('.'))
        {
            // dots signify an address
            address = prefix;
        }
        else
        {
            // When does this happen?
            nickname = prefix;
        }
    }

    import dialect.common : isSpecial;
    if (event.sender.isSpecial(parser)) event.sender.class_ = IRCUser.Class.special;
}

///
unittest
{
    import lu.conv : Enum;

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
        assert((class_ != IRCUser.Class.special), Enum!(IRCUser.Class).toString(class_));
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
        assert((class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(class_));
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
        assert((class_ != IRCUser.Class.special), Enum!(IRCUser.Class).toString(class_));
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
        assert((class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(class_));
    }
}


// parseTypestring
/++
 +  Takes a slice of a raw IRC string and continues parsing it into an
 +  `dialect.defs.IRCEvent` struct.
 +
 +  This function only focuses on the *typestring*; the part that tells what
 +  kind of event happened, like `dialect.defs.IRCEvent.Type.PRIVMSG` or
 +  `dialect.defs.IRCEvent.Type.MODE` or `dialect.defs.IRCEvent.Type.NICK`
 +  or `dialect.defs.IRCEvent.Type.KICK`, etc; in string format.
 +
 +  The `dialect.defs.IRCEvent` is not finished at the end of this function.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      event = Reference to the `dialect.defs.IRCEvent` to continue working on.
 +      slice = Reference to the slice of the raw IRC string.
 +
 +  Throws: `dialect.common.IRCParseException` if conversion from typestring to
 +      `dialect.defs.IRCEvent.Type` or typestring to a number failed.
 +/
void parseTypestring(ref IRCParser parser, ref IRCEvent event, ref string slice) pure
{
    import std.conv : ConvException, to;
    import std.typecons : Flag, No, Yes;

    immutable typestring = slice.nom!(Yes.inherit)(' ');

    if ((typestring[0] >= '0') && (typestring[0] <= '9'))
    {
        immutable number = typestring.to!uint;
        event.num = number;
        event.type = parser.typenums[number];

        alias T = IRCEvent.Type;
        event.type = (event.type == T.UNSET) ? T.NUMERIC : event.type;
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
            throw new IRCParseException("Unknown typestring " ~ typestring,
                event, e.file, e.line);
        }
    }
}

///
unittest
{
    import lu.conv : Enum;
    import std.conv : to;

    IRCParser parser;

    IRCEvent e1;
    with (e1)
    {
        raw = /*":port80b.se.quakenet.org */"421 kameloso åäö :Unknown command";
        string slice = raw;  // mutable
        parser.parseTypestring(e1, slice);
        assert((type == IRCEvent.Type.ERR_UNKNOWNCOMMAND), Enum!(IRCEvent.Type).toString(type));
        assert((num == 421), num.to!string);
    }

    IRCEvent e2;
    with (e2)
    {
        raw = /*":port80b.se.quakenet.org */"353 kameloso = #garderoben :@kameloso'";
        string slice = raw;  // mutable
        parser.parseTypestring(e2, slice);
        assert((type == IRCEvent.Type.RPL_NAMREPLY), Enum!(IRCEvent.Type).toString(type));
        assert((num == 353), num.to!string);
    }

    IRCEvent e3;
    with (e3)
    {
        raw = /*":zorael!~NaN@ns3363704.ip-94-23-253.eu */"PRIVMSG kameloso^ :test test content";
        string slice = raw;  // mutable
        parser.parseTypestring(e3, slice);
        assert((type == IRCEvent.Type.PRIVMSG), Enum!(IRCEvent.Type).toString(type));
    }

    IRCEvent e4;
    with (e4)
    {
        raw = /*`:zorael!~NaN@ns3363704.ip-94-23-253.eu */`PART #flerrp :"WeeChat 1.6"`;
        string slice = raw;  // mutable
        parser.parseTypestring(e4, slice);
        assert((type == IRCEvent.Type.PART), Enum!(IRCEvent.Type).toString(type));
    }
}


// parseSpecialcases
/++
 +  Takes a slice of a raw IRC string and continues parsing it into an
 +  `dialect.defs.IRCEvent` struct.
 +
 +  This function only focuses on specialcasing the remaining line, dividing it
 +  into fields like `target`, `channel`, `content`, etc.
 +
 +  IRC events are *riddled* with inconsistencies and specialcasings, so this
 +  function is very very long, but by necessity.
 +
 +  The `dialect.defs.IRCEvent` is finished at the end of this function.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      event = Reference to the `dialect.defs.IRCEvent` to continue working on.
 +      slice = Reference to the slice of the raw IRC string.
 +
 +  Throws: `dialect.common.IRCParseException` if an unknown to-connect-type event was
 +      encountered, or if the event was not recognised at all, as neither a
 +      normal type nor a numeric.
 +/
void parseSpecialcases(ref IRCParser parser, ref IRCEvent event, ref string slice) pure
{
    import lu.string : beginsWith, strippedRight;
    import std.conv : to;
    import std.typecons : Flag, No, Yes;

    with (parser)
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
        event.type = (event.sender.nickname == client.nickname) ? SELFJOIN : JOIN;

        if (slice.contains(' '))
        {
            // :nick!user@host JOIN #channelname accountname :Real Name
            // :nick!user@host JOIN #channelname * :Real Name
            // :nick!~identh@unaffiliated/nick JOIN #freenode login :realname
            // :kameloso!~NaN@2001:41d0:2:80b4:: JOIN #hirrsteff2 kameloso : kameloso!
            event.channel = slice.nom(' ');
            event.sender.account = slice.nom(" :");
            //event.content = slice.stripped;  // no need for full name...
        }
        else
        {
            event.channel = slice.beginsWith(':') ? slice[1..$] : slice;
        }
        break;

    case PART:
        // :zorael!~NaN@ns3363704.ip-94-23-253.eu PART #flerrp :"WeeChat 1.6"
        // :kameloso^!~NaN@81-233-105-62-no80.tbcn.telia.com PART #flerrp
        // :Swatas!~4--Uos3UH@9e19ee35.915b96ad.a7c9320c.IP4 PART :#cncnet-mo
        // :gallon!~MO.11063@482c29a5.e510bf75.97653814.IP4 PART :#cncnet-yr
        event.type = (event.sender.nickname == client.nickname) ? SELFPART : PART;

        if (slice.contains(' '))
        {
            import lu.string : unquoted;

            event.channel = slice.nom(" :");
            event.content = slice.unquoted;
        }
        else
        {
            // Seen on GameSurge
            if (slice.beginsWith(':')) slice = slice[1..$];
            event.channel = slice;
        }
        break;

    case NICK:
        // :kameloso^!~NaN@81-233-105-62-no80.tbcn.telia.com NICK :kameloso_
        event.target.nickname = slice[1..$];

        if (event.sender.nickname == client.nickname)
        {
            event.type = SELFNICK;
            client.nickname = event.target.nickname;
            version(FlagAsUpdated) parser.clientUpdated = true;
        }
        break;

    case QUIT:
        import lu.string : unquoted;

        // :g7zon!~gertsson@178.174.245.107 QUIT :Client Quit
        event.type = (event.sender.nickname == client.nickname) ? SELFQUIT : QUIT;
        event.content = slice[1..$].unquoted;

        if (event.content.beginsWith("Quit: "))
        {
            event.content.nom("Quit: ");
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
        event.channel = slice.nom(' ');
        event.target.nickname = slice.nom(" :");
        event.type = (event.target.nickname == client.nickname) ? SELFKICK : KICK;
        event.content = slice;
        break;

    case INVITE:
        // (freenode) :zorael!~NaN@2001:41d0:2:80b4:: INVITE kameloso :#hirrsteff
        // (quakenet) :zorael!~zorael@ns3363704.ip-94-23-253.eu INVITE kameloso #hirrsteff
        event.target.nickname = slice.nom(' ');
        event.channel = slice.beginsWith(':') ? slice[1..$] : slice;
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
        // :moon.freenode.net 403 kameloso archlinux :No such channel
        slice.nom(' ');  // bot nickname
        event.channel = slice.nom(" :");
        event.content = slice;
        break;

    case RPL_NAMREPLY: // 353
        // :asimov.freenode.net 353 kameloso^ = #garderoben :kameloso^ ombudsman +kameloso @zorael @maku @klarrt
        slice.nom(' ');  // bot nickname
        slice.nom(' ');
        event.channel = slice.nom(" :");
        event.content = slice.strippedRight;
        break;

    case RPL_WHOREPLY: // 352
        // :moon.freenode.net 352 kameloso ##linux LP9NDWY7Cy gentoo/contributor/Fieldy moon.freenode.net Fieldy H :0 Ni!
        // :moon.freenode.net 352 kameloso ##linux sid99619 gateway/web/irccloud.com/x-eviusxrezdarwcpk moon.freenode.net tjsimmons G :0 T.J. Simmons
        // :moon.freenode.net 352 kameloso ##linux sid35606 gateway/web/irccloud.com/x-rvrdncbvklhxwjrr moon.freenode.net Whisket H :0 Whisket
        // :moon.freenode.net 352 kameloso ##linux ~rahlff b29beb9d.rev.stofanet.dk orwell.freenode.net Axton H :0 Michael Rahlff
        // :moon.freenode.net 352 kameloso ##linux ~wzhang sea.mrow.org card.freenode.net wzhang H :0 wzhang
        // :irc.rizon.no 352 kameloso^^ * ~NaN C2802314.E23AD7D8.E9841504.IP * kameloso^^ H :0  kameloso!
        // :irc.rizon.no 352 kameloso^^ * ~zorael Rizon-64330364.ip-94-23-253.eu * wob^2 H :0 zorael
        // "<channel> <user> <host> <server> <nick> ( "H" / "G" > ["*"] [ ( "@" / "+" ) ] :<hopcount> <real name>"
        slice.nom(' ');  // bot nickname
        event.channel = slice.nom(' ');
        if (event.channel == "*") event.channel = string.init;

        immutable userOrIdent = slice.nom(' ');
        if (userOrIdent.beginsWith('~')) event.target.ident = userOrIdent;

        event.target.address = slice.nom(' ');
        slice.nom(' ');  // server
        event.target.nickname = slice.nom(' ');

        immutable hg = slice.nom(' ');  // H|G
        if (hg.length > 1)
        {
            // H
            // H@
            // H+
            // H@+
            event.aux = hg[1..$];
        }

        import lu.string : strippedLeft;
        slice.nom(' ');  // hopcount
        event.content = slice.strippedLeft;
        break;

    case RPL_ENDOFWHO: // 315
        // :tolkien.freenode.net 315 kameloso^ ##linux :End of /WHO list.
        // :irc.rizon.no 315 kameloso^^ * :End of /WHO list.
        slice.nom(' ');  // bot nickname
        event.channel = slice.nom(" :");
        if (event.channel == "*") event.channel = string.init;
        event.content = slice;
        break;

    case RPL_ISUPPORT: // 005
        parser.onISUPPORT(event, slice);
        break;

    case RPL_MYINFO: // 004
        parser.onMyInfo(event, slice);
        break;

    case RPL_QUIETLIST: // 728, oftc/hybrid 344
        // :niven.freenode.net 728 kameloso^ #flerrp q qqqq!*@asdf.net zorael!~NaN@2001:41d0:2:80b4:: 1514405101
        // :irc.oftc.net 344 kameloso #garderoben harbl!snarbl@* kameloso!~NaN@194.117.188.126 1515418362
        slice.nom(' ');  // bot nickname
        event.channel = slice.contains(" q ") ? slice.nom(" q ") : slice.nom(' ');
        event.content = slice.nom(' ');
        event.aux = slice.nom(' ');
        event.count = slice.to!int;
        break;

    case RPL_WHOISHOST: // 378
        // :wilhelm.freenode.net 378 kameloso^ kameloso^ :is connecting from *@81-233-105-62-no80.tbcn.telia.com 81.233.105.62
        // TRIED TO NOM TOO MUCH:'kameloso :is connecting from NaN@194.117.188.126 194.117.188.126' with ' :is connecting from *@'
        slice.nom(' ');  // bot nickname
        event.target.nickname = slice.nom(" :is connecting from ");
        event.target.ident = slice.nom('@');
        if (event.target.ident == "*") event.target.ident = string.init;
        event.content = slice.nom(' ');
        event.aux = slice;
        break;

    case ERR_UNKNOWNCOMMAND: // 421
        slice.nom(' ');  // bot nickname
        if (slice.contains(':'))
        {
            // :asimov.freenode.net 421 kameloso^ sudo :Unknown command
            event.aux = slice.nom(" :");
            event.content = slice;
        }
        else
        {
            // :karatkievich.freenode.net 421 kameloso^ systemd,#kde,#kubuntu,...
            event.content = slice;
        }
        break;

    case RPL_WHOISIDLE: //  317
        // :rajaniemi.freenode.net 317 kameloso zorael 0 1510219961 :seconds idle, signon time
        slice.nom(' ');  // bot nickname
        event.target.nickname = slice.nom(' ');
        event.count = slice.nom(' ').to!int;
        event.altcount = slice.nom(" :").to!int;
        event.aux = slice;
        break;

    case RPL_LUSEROP: // 252
    case RPL_LUSERUNKNOWN: // 253
    case RPL_LUSERCHANNELS: // 254
    case ERR_ERRONEOUSNICKNAME: // 432
    case ERR_NEEDMOREPARAMS: // 461
    case RPL_LOCALUSERS: // 265
    case RPL_GLOBALUSERS: // 266
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
        slice.nom(' ');  // bot nickname

        if (slice.contains(" :"))
        {
            import std.uni : isNumber;

            string midfield = slice.nom(" :");
            event.content = slice;

            immutable first = midfield.nom!(Yes.inherit)(' ');
            immutable second = midfield;

            if (first.length)
            {
                if (first[0].isNumber)
                {
                    event.count = first.to!int;

                    if (second.length && second[0].isNumber)
                    {
                        event.altcount = second.to!int;
                    }
                }
                else
                {
                    event.aux = first;
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

        // :orwell.freenode.net 311 kameloso^ kameloso ~NaN ns3363704.ip-94-23-253.eu * : kameloso
        slice.nom(' ');  // bot nickname
        event.target.nickname = slice.nom(' ');
        event.target.ident = slice.nom(' ');
        event.target.address = slice.nom(" * :");
        event.content = slice.strippedLeft;
        break;

    case RPL_WHOISSERVER: // 312
        // :asimov.freenode.net 312 kameloso^ zorael sinisalo.freenode.net :SE
        slice.nom(' ');  // bot nickname
        event.target.nickname = slice.nom(' ');
        event.content = slice.nom(" :");
        event.aux = slice;
        break;

    case RPL_WHOISACCOUNT: // 330
        // :asimov.freenode.net 330 kameloso^ xurael zorael :is logged in as
        slice.nom(' ');  // bot nickname
        event.target.nickname = slice.nom(' ');
        event.target.account = slice.nom(" :");
        event.content = event.target.account;
        break;

    case RPL_WHOISREGNICK: // 307
        // :irc.x2x.cc 307 kameloso^^ py-ctcp :has identified for this nick
        // :irc.x2x.cc 307 kameloso^^ wob^2 :has identified for this nick
        // What is the nickname? Are they always the same?
        slice.nom(' '); // bot nickname
        event.target.account = slice.nom(" :");
        event.target.nickname = event.target.account;  // uneducated guess
        event.content = event.target.nickname;
        break;

    case RPL_WHOISACTUALLY: // 75
        // :kinetic.oftc.net 338 kameloso wh00nix 255.255.255.255 :actually using host
        slice.nom(' '); // bot nickname
        event.target.nickname = slice.nom(' ');
        event.target.address = slice.nom(" :");
        event.content = slice;
        break;

    case PONG:
        event.content = string.init;
        break;

    case ERR_NOTREGISTERED: // 451
        if (slice.beginsWith('*'))
        {
            // :niven.freenode.net 451 * :You have not registered
            slice.nom("* :");
            event.content = slice;
        }
        else
        {
            // :irc.harblwefwoi.org 451 WHOIS :You have not registered
            event.aux = slice.nom(" :");
            event.content = slice;
        }
        break;

    case ERR_NEEDPONG: // 513
        /++
         +  "Also known as ERR_NEEDPONG (Unreal/Ultimate) for use during
         +  registration, however it's not used in Unreal (and might not be used
         +  in Ultimate either)."
         +/
        // :irc.uworld.se 513 kameloso :To connect type /QUOTE PONG 3705964477

        if (slice.contains(" :To connect"))
        {
            event.target.nickname = slice.nom(" :To connect");

            if (slice.beginsWith(','))
            {
                // ngircd?
                /* "NOTICE %s :To connect, type /QUOTE PONG %ld",
                    Client_ID(Client), auth_ping)) */
                // :like.so 513 kameloso :To connect, type /QUOTE PONG 3705964477
                // "To connect, type /QUOTE PONG <id>"
                //            ^
                slice = slice[1..$];
            }

            slice.nom(" type /QUOTE ");
            event.content = slice;
        }
        else
        {
            throw new IRCParseException("Unknown variant of to-connect-type?", event);
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
        // :irc.run.net 222 kameloso KOI8-U :is your charset now
        // :leguin.freenode.net 704 kameloso^ index :Help topics available to users:
        // :leguin.freenode.net 705 kameloso^ index :ACCEPT\tADMIN\tAWAY\tCHALLENGE
        // :leguin.freenode.net 706 kameloso^ index :End of /HELP.
        // :livingstone.freenode.net 249 kameloso p :dax (dax@freenode/staff/dax)
        // :livingstone.freenode.net 249 kameloso p :1 staff members
        // :livingstone.freenode.net 219 kameloso p :End of /STATS report
        // :verne.freenode.net 263 kameloso^ STATS :This command could not be completed because it has been used recently, and is rate-limited
        // :verne.freenode.net 262 kameloso^ verne.freenode.net :End of TRACE
        slice.nom(' '); // bot nickname
        event.aux = slice.nom(" :");
        event.content = slice;
        break;

    case RPL_STATSLINKINFO: // 211
        // :verne.freenode.net 211 kameloso^ kameloso^[~NaN@194.117.188.126] 0 109 8 15 0 :40 0 -
        // Without knowing more we can't do much except slice it conservatively
        slice.nom(' '); // bot nickname
        event.content = slice.nom(' ');
        event.aux = slice;
        break;

    case RPL_TRACEUSER: // 205
        // :wolfe.freenode.net 205 kameloso^ User v6users zorael[~NaN@2001:41d0:2:80b4::] (255.255.255.255) 16 :536
        slice.nom(" User "); // bot nickname
        event.aux = slice.nom(' '); // "class"
        event.content = slice.nom(" :");
        event.count = slice.to!int; // unsure
        break;

    case RPL_LINKS: // 364
        // :rajaniemi.freenode.net 364 kameloso^ rajaniemi.freenode.net rajaniemi.freenode.net :0 Helsinki, FI, EU
        slice.nom(' '); // bot nickname
        slice.nom(' '); // "mask"
        event.aux = slice.nom(" :"); // server address
        event.count = slice.nom(' ').to!int; // hop count
        event.content = slice; // "server info"
        break;

    case ERR_BANONCHAN: // 435
        // :cherryh.freenode.net 435 kameloso^ kameloso^^ #d3d9 :Cannot change nickname while banned on channel
        event.target.nickname = slice.nom(' ');
        event.aux = slice.nom(' ');
        event.channel = slice.nom(" :");
        event.content = slice;
        break;

    case CAP:
        if (slice.contains('*'))
        {
            // :tmi.twitch.tv CAP * LS :twitch.tv/tags twitch.tv/commands twitch.tv/membership
            slice.nom("* ");
        }
        else
        {
            // :genesis.ks.us.irchighway.net CAP 867AAF66L LS :away-notify extended-join account-notify multi-prefix sasl tls userhost-in-names
            //immutable id = slice.nom(' ');
            slice.nom(' ');
        }

        event.aux = slice.nom(" :");
        event.content = slice.strippedRight;
        break;

    case RPL_UMODEGMSG:
        // :rajaniemi.freenode.net 718 kameloso Freyjaun ~FREYJAUN@41.39.229.6 :is messaging you, and you have umode +g.
        slice.nom(' '); // bot nickname
        event.target.nickname = slice.nom(' ');
        event.target.ident = slice.nom('@');
        event.target.address = slice.nom(" :");
        event.content = slice;
        break;

    version(TwitchSupport)
    {
        case HOSTTARGET:
            if (slice.contains(" :-"))
            {
                event.type = TWITCH_HOSTEND;
                goto case TWITCH_HOSTEND;
            }
            else
            {
                event.type = TWITCH_HOSTSTART;
                goto case TWITCH_HOSTSTART;
            }

        case TWITCH_HOSTSTART:
            // :tmi.twitch.tv HOSTTARGET #hosting_channel <channel> [<number-of-viewers>]
            // :tmi.twitch.tv HOSTTARGET #andymilonakis :zombie_barricades -
            event.channel = slice.nom(" :");
            event.sender.nickname = event.channel;
            event.target.nickname = slice.nom(' ');  // target channel
            event.count = (slice == "-") ? 0 : slice.to!int;
            break;

        case TWITCH_HOSTEND:
            // :tmi.twitch.tv HOSTTARGET #hosting_channel :- [<number-of-viewers>]
            event.channel = slice.nom(" :- ");
            event.sender.nickname = event.channel;
            event.count = slice.to!int;
            break;

        case CLEARCHAT:
            // :tmi.twitch.tv CLEARCHAT #zorael
            // :tmi.twitch.tv CLEARCHAT #<channel> :<user>
            if (slice.contains(" :"))
            {
                // Banned
                event.channel = slice.nom(" :");
                event.target.nickname = slice;
            }
            else
            {
                event.channel = slice;
            }
            break;
    }

    case RPL_LOGGEDIN: // 900
        // :weber.freenode.net 900 kameloso kameloso!NaN@194.117.188.126 kameloso :You are now logged in as kameloso.
        // :NickServ!NickServ@services. NOTICE kameloso^ :You are now identified for kameloso.
        if (slice.contains('!'))
        {
            event.target.nickname = slice.nom(' ');  // bot nick
            slice.nom('!');  // user
            event.target.ident = slice.nom('@');
            event.target.address = slice.nom(' ');
            event.target.account = slice.nom(" :");
        }
        event.content = slice;
        break;

    case ACCOUNT:
        //:ski7777!~quassel@ip5b435007.dynamic.kabel-deutschland.de ACCOUNT ski7777
        event.sender.account = slice;
        event.aux = slice;  // to make it visible?
        break;

    case RPL_HOSTHIDDEN: // 396
    case RPL_VERSION: // 351
        // :irc.rizon.no 351 kameloso^^ plexus-4(hybrid-8.1.20)(20170821_0-607). irc.rizon.no :TS6ow
        // :TAL.DE.EU.GameSurge.net 396 kameloso ~NaN@1b24f4a7.243f02a4.5cd6f3e3.IP4 :is now your hidden host
        slice.nom(' '); // bot nickname
        event.content = slice.nom(" :");
        event.aux = slice;
        break;

    case RPL_YOURID: // 42
    case ERR_YOUREBANNEDCREEP: // 465
    case ERR_HELPNOTFOUND: // 524, also ERR_QUARANTINED
    case ERR_UNKNOWNMODE: // 472
        // :caliburn.pa.us.irchighway.net 042 kameloso 132AAMJT5 :your unique ID
        // :irc.rizon.no 524 kameloso^^ 502 :Help not found
        // :irc.rizon.no 472 kameloso^^ X :is unknown mode char to me
        // :miranda.chathispano.com 465 kameloso 1511086908 :[1511000504768] G-Lined by ChatHispano Network. Para mas informacion visite http://chathispano.com/gline/?id=<id> (expires at Dom, 19/11/2017 11:21:48 +0100).
        // event.time was 1511000921
        // TRIED TO NOM TOO MUCH:':You are banned from this server- Your irc client seems broken and is flooding lots of channels. Banned for 240 min, if in error, please contact kline@freenode.net. (2017/12/1 21.08)' with ' :'
        string misc = slice.nom(" :");
        event.content = slice;
        misc.nom!(Yes.inherit)(' ');
        event.aux = misc;
        break;

    case RPL_UMODEIS:
        // :lamia.ca.SpotChat.org 221 kameloso :+ix
        // :port80b.se.quakenet.org 221 kameloso +i
        // The general heuristics is good enough for this but places modes in
        // content rather than aux, which is inconsistent with other mode events
        slice.nom(' '); // bot nickname

        if (slice.beginsWith(':'))
        {
            slice = slice[1..$];
        }

        event.aux = slice;
        break;

    case RPL_CHANNELMODEIS: // 324
        // :niven.freenode.net 324 kameloso^ ##linux +CLPcnprtf ##linux-overflow
        // :kornbluth.freenode.net 324 kameloso #flerrp +ns
        slice.nom(' '); // bot nickname
        event.channel = slice.nom(' ');

        if (slice.contains(' '))
        {
            event.aux = slice.nom(' ');
            //event.content = slice.nom(' ');
            event.content = slice.strippedRight;
        }
        else
        {
            event.aux = slice.strippedRight;
        }
        break;

    case RPL_CREATIONTIME: // 329
        // :kornbluth.freenode.net 329 kameloso #flerrp 1512995737
        slice.nom(' ');
        event.channel = slice.nom(' ');
        event.count = slice.to!int;
        break;

    case RPL_LIST: // 322
        // :irc.RomaniaChat.eu 322 kameloso #GameOfThrones 1 :[+ntTGfB]
        // :irc.RomaniaChat.eu 322 kameloso #radioclick 63 :[+ntr]  Bun venit pe #Radioclick! Site oficial www.radioclick.ro sau servere irc.romaniachat.eu, irc.radioclick.ro
        // :eggbert.ca.na.irchighway.net 322 kameloso * 3 :
        /*
            (asterisk channels)
            milky | channel isn't public nor are you a member
            milky | Unreal inserts that instead of not sending the result
            milky | Other IRCd may do same because they are all derivatives
         */
        slice.nom(' '); // bot nickname
        event.channel = slice.nom(' ');
        event.count = slice.nom(" :").to!int;
        event.content = slice;
        break;

    case RPL_LISTSTART: // 321
        // :cherryh.freenode.net 321 kameloso^ Channel :Users  Name
        // none of the fields are interesting...
        break;

    case RPL_ENDOFQUIETLIST: // 729, oftc/hybrid 345
        // :niven.freenode.net 729 kameloso^ #hirrsteff q :End of Channel Quiet List
        // :irc.oftc.net 345 kameloso #garderoben :End of Channel Quiet List
        slice.nom(' ');
        event.channel = slice.contains(" q :") ? slice.nom(" q :") : slice.nom(" :");
        event.content = slice;
        break;

    case RPL_WHOISMODES: // 379
        // :cadance.canternet.org 379 kameloso kameloso :is using modes +ix
        slice.nom(' '); // bot nickname
        event.target.nickname = slice.nom(" :is using modes ");
        event.aux = slice;
        break;

    case RPL_WHOWASUSER: // 314
        import lu.string : stripped;

        // :irc.uworld.se 314 kameloso^^ kameloso ~NaN C2802314.E23AD7D8.E9841504.IP * : kameloso!
        slice.nom(' '); // bot nickname
        event.target.nickname = slice.nom(' ');
        event.content = slice.nom(" :");
        event.aux = slice.stripped;
        break;

    case CHGHOST:
        // :Miyabro!~Miyabro@DA8192E8:4D54930F:650EE60D:IP CHGHOST ~Miyabro Miyako.is.mai.waifu
        event.sender.ident = slice.nom(' ');
        event.sender.address = slice;
        event.content = slice;
        break;

    case RPL_HELLO: // 020
        // :irc.run.net 020 irc.run.net :*** You are connected to RusNet. Please wait...
        // :irc.portlane.se 020 * :Please wait while we process your connection.
        slice.nom(" :");
        event.content = slice;
        parser.server.resolvedAddress = event.sender.address;
        version(FlagAsUpdated) parser.serverUpdated = true;
        break;

    case SPAMFILTERLIST: // 941
    case RPL_BANLIST: // 367
        // :siren.de.SpotChat.org 941 kameloso #linuxmint-help spotify.com/album Butterfly 1513796216
        // ":kornbluth.freenode.net 367 kameloso #flerrp harbl!harbl@snarbl.com zorael!~NaN@2001:41d0:2:80b4:: 1513899521"
        // :irc.run.net 367 kameloso #politics *!*@broadband-46-242-*.ip.moscow.rt.ru
        slice.nom(' '); // bot nickname
        event.channel = slice.nom(' ');

        if (slice.contains(' '))
        {
            event.content = slice.nom(' ');
            event.aux = slice.nom(' ');  // nickname that set the mode
            event.count = slice.to!int;
        }
        else
        {
            event.content = slice;
        }
        break;

    case RPL_AWAY: // 301
        // :hitchcock.freenode.net 301 kameloso^ Morrolan :Auto away at Tue Mar  3 09:43:26 2020
        // Sent if you send a message (or WHOIS) a user who is away
        slice.nom(' '); // bot nickname
        event.sender.nickname = slice.nom(" :");
        event.sender.address = string.init;
        event.sender.class_ = IRCUser.Class.unset;
        event.content = slice;
        break;

    default:
        if ((event.type == NUMERIC) || (event.type == UNSET))
        {
            throw new IRCParseException("Uncaught NUMERIC or UNSET", event);
        }

        return parser.parseGeneralCases(event, slice);
    }
}


// parseGeneralCases
/++
 +  Takes a slice of a raw IRC string and continues parsing it into an
 +  `dialect.defs.IRCEvent` struct.
 +
 +  This function only focuses on applying general heuristics to the remaining
 +  line, dividing it into fields like `target`, `channel`, `content`, etc; not
 +  based by its type but rather by how the string looks.
 +
 +  The `dialect.defs.IRCEvent` is finished at the end of this function.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      event = Reference to the `dialect.defs.IRCEvent` to continue working on.
 +      slice = Reference to the slice of the raw IRC string.
 +/
void parseGeneralCases(const ref IRCParser parser, ref IRCEvent event, ref string slice) pure @nogc
{
    import lu.string : beginsWithOneOf;

    if (slice.contains(" :"))
    {
        // Has colon-content
        string targets = slice.nom(" :");

        if (targets.contains(' '))
        {
            // More than one target
            immutable firstTarget = targets.nom(' ');

            if ((firstTarget == parser.client.nickname) || (firstTarget == "*"))
            {
                // More than one target, first is bot
                // Can't use isChan here since targets may contain spaces

                if (targets.beginsWithOneOf(parser.server.chantypes))
                {
                    // More than one target, first is bot
                    // Second target is/begins with a channel

                    if (targets.contains(' '))
                    {
                        // More than one target, first is bot
                        // Second target is more than one, first is channel
                        // assume third is content
                        event.channel = targets.nom(' ');
                        event.content = targets;
                    }
                    else
                    {
                        // More than one target, first is bot
                        // Only one second

                        if (targets.beginsWithOneOf(parser.server.chantypes))
                        {
                            // First is bot, second is channel
                            event.channel = targets;
                        }
                        else
                        {
                            /*logger.warning("Non-channel second target. Report this.");
                            logger.trace(event.raw);*/
                            event.target.nickname = targets;
                        }
                    }
                }
                else
                {
                    // More than one target, first is bot
                    // Second is not a channel

                    if (targets.contains(' '))
                    {
                        // More than one target, first is bot
                        import std.algorithm.searching : count;

                        if (targets.count(' ') == 1)
                        {
                            // Two extra targets; assume nickname and channel
                            event.target.nickname = targets.nom(' ');
                            event.channel = targets;
                        }
                        else
                        {
                            // A lot of spaces; cannot say for sure what is what
                            event.aux = targets;
                        }
                    }
                    else
                    {
                        // Only one second target

                        if (targets.beginsWithOneOf(parser.server.chantypes))
                        {
                            // Second is a channel
                            event.channel = targets;
                        }
                        else if (targets == event.sender.address)
                        {
                            // Second is sender's address, probably server
                            event.aux = targets;
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

                if (firstTarget.beginsWithOneOf(parser.server.chantypes))
                {
                    // First target is a channel
                    // Assume second is a nickname
                    event.channel = firstTarget;
                    event.target.nickname = targets;
                }
                else
                {
                    // First target is not channel, assume nick
                    // Assume second is channel
                    event.target.nickname = firstTarget;
                    event.channel = targets;
                }
            }
        }
        else if (targets.beginsWithOneOf(parser.server.chantypes))
        {
            // Only one target, it is a channel
            event.channel = targets;
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
        if (slice.contains(' '))
        {
            // More than one target
            immutable target = slice.nom(' ');

            if (target.beginsWithOneOf(parser.server.chantypes))
            {
                // More than one target, first is a channel
                // Assume second is content
                event.channel = target;
                event.content = slice;
            }
            else
            {
                // More than one target, first is not a channel
                // Assume first is nickname and second is aux
                event.target.nickname = target;

                if ((target == parser.client.nickname) && slice.contains(' '))
                {
                    // First target is bot, and there is more
                    // :asimov.freenode.net 333 kameloso^ #garderoben klarrt!~bsdrouter@h150n13-aahm-a11.ias.bredband.telia.com 1476294377
                    // :kornbluth.freenode.net 367 kameloso #flerrp harbl!harbl@snarbl.com zorael!~NaN@2001:41d0:2:80b4:: 1513899521
                    // :niven.freenode.net 346 kameloso^ #flerrp asdf!fdas@asdf.net zorael!~NaN@2001:41d0:2:80b4:: 1514405089
                    // :irc.run.net 367 kameloso #Help *!*@broadband-5-228-255-*.moscow.rt.ru
                    // :irc.atw-inter.net 344 kameloso #debian.de towo!towo@littlelamb.szaf.org

                    if (slice.beginsWithOneOf(parser.server.chantypes))
                    {
                        // Second target is channel
                        event.channel = slice.nom(' ');

                        if (slice.contains(' '))
                        {
                            // Remaining slice has at least two fields;
                            // separate into content and aux
                            event.content = slice.nom(' ');
                            event.aux = slice;
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
                    event.aux = slice;
                }
            }
        }
        else
        {
            // Only one target

            if (slice.beginsWithOneOf(parser.server.chantypes))
            {
                // Target is a channel
                event.channel = slice;
            }
            else
            {
                // Target is a nickname
                event.target.nickname = slice;
            }
        }
    }

    // If content is empty and slice hasn't already been used, assign it
    if (!event.content.length && (slice != event.channel) &&
        (slice != event.target.nickname))
    {
        import lu.string : strippedRight;
        event.content = slice.strippedRight;
    }
}


// postparseSanityCheck
/++
 +  Checks for some specific erroneous edge cases in an `dialect.defs.IRCEvent`.
 +
 +  Descriptions of the errors are stored in `event.errors`.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      event = Reference to the `dialect.defs.IRCEvent` to continue working on.
 +/
public void postparseSanityCheck(const ref IRCParser parser, ref IRCEvent event) pure nothrow
{
    import std.array : Appender;

    Appender!string sink;
    // The sink will very rarely be used; treat it as an edge case and don't reserve

    if (event.target.nickname.contains(' ') || event.channel.contains(' '))
    {
        sink.put("Spaces in target nickname or channel");
    }

    if (event.target.nickname.length && parser.server.chantypes.contains(event.target.nickname[0]))
    {
        if (sink.data.length) sink.put(". ");
        sink.put("Target nickname is a channel");
    }

    if (event.channel.length &&
        !parser.server.chantypes.contains(event.channel[0]) &&
        (event.type != IRCEvent.Type.ERR_NOSUCHCHANNEL) &&
        (event.type != IRCEvent.Type.RPL_ENDOFWHO) &&
        (event.type != IRCEvent.Type.RPL_NAMREPLY) &&
        (event.type != IRCEvent.Type.RPL_ENDOFNAMES) &&
        (event.type != IRCEvent.Type.SELFJOIN) &&  // Twitch
        (event.type != IRCEvent.Type.SELFPART) &&  // Twitch
        (event.type != IRCEvent.Type.RPL_LIST))  // Some channels can be asterisks if they aren't public
    {
        if (sink.data.length) sink.put(". ");
        sink.put("Channel is not a channel");
    }

    if (!sink.data.length) return;

    event.errors = sink.data;
}


// onNotice
/++
 +  Handle `dialect.defs.IRCEvent.Type.NOTICE` events.
 +
 +  These are all(?) sent by the server and/or services. As such they often
 +  convey important `special` things, so parse those.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      event = Reference to the `dialect.defs.IRCEvent` to continue working on.
 +      slice = Reference to the slice of the raw IRC string.
 +/
void onNotice(ref IRCParser parser, ref IRCEvent event, ref string slice) pure
{
    import lu.string : beginsWith, beginsWithOneOf;
    import std.typecons : Flag, No, Yes;

    // :ChanServ!ChanServ@services. NOTICE kameloso^ :[##linux-overflow] Make sure your nick is registered, then please try again to join ##linux.
    // :ChanServ!ChanServ@services. NOTICE kameloso^ :[#ubuntu] Welcome to #ubuntu! Please read the channel topic.
    // :tolkien.freenode.net NOTICE * :*** Checking Ident

    // At least Twitch sends NOTICEs to channels, maybe other daemons do too
    immutable channelOrNickname = slice.nom!(Yes.inherit)(" :");
    event.content = slice;

    if (channelOrNickname.length && channelOrNickname.beginsWithOneOf(parser.server.chantypes))
    {
        event.channel = channelOrNickname;
    }

    with (parser)
    {
        import dialect.common : isAuthService, isSpecial;

        if (!event.content.length) return;

        if (!server.resolvedAddress.length && event.content.beginsWith("***"))
        {
            // This is where we catch the resolved address
            assert(!event.sender.nickname.length, "Unexpected nickname: " ~ event.sender.nickname);
            server.resolvedAddress = event.sender.address;
            version(FlagAsUpdated) parser.serverUpdated = true;
        }

        if (!event.sender.isServer && event.sender.isAuthService(parser))
        {
            import std.algorithm.searching : canFind;
            import std.uni : asLowerCase;

            //event.sender.class_ = IRCUser.Class.special; // by definition

            enum AuthChallenge
            {
                dalnet = "This nick is owned by someone else. Please choose another.",
                oftc = "This nickname is registered and protected.",
            }

            with (event)
            with (AuthChallenge)
            {
                if (content.asLowerCase.canFind("/msg nickserv identify") ||
                    (content == dalnet) ||
                    content.beginsWith(oftc))
                {
                    type = IRCEvent.Type.AUTH_CHALLENGE;
                    return;
                }
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

            with (event)
            with (AuthSuccess)
            {
                if ((content.beginsWith(freenode)) ||
                    (content.beginsWith(quakenet)) || // also Freenode SASL
                    (content.beginsWith(dalnet)) ||
                    (content.beginsWith(oftc)) ||
                    (content == rizon) ||
                    (content == gamesurge))
                {
                    type = IRCEvent.Type.RPL_LOGGEDIN;

                    // Restart with the new type
                    return parser.parseSpecialcases(event, slice);
                }
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

            with (event)
            with (AuthFailure)
            {
                if ((content == rizon) ||
                    (content == quakenet) ||
                    (content == gamesurgeInvalid) ||
                    (content == gamesurgeRejected) ||
                    (content == geekshedRejected) ||
                     content.contains(cast(string)freenodeInvalid) ||
                     content.beginsWith(cast(string)freenodeRejected) ||
                     content.contains(cast(string)dalnetInvalid) ||
                     content.beginsWith(cast(string)dalnetRejected) ||
                     content.contains(cast(string)unreal) ||
                     content.beginsWith(cast(string)oftcRejected))
                {
                    event.type = IRCEvent.Type.AUTH_FAILURE;
                }
            }
        }
    }

    // FIXME: support
    // *** If you are having problems connecting due to ping timeouts, please type /quote PONG j`ruV\rcn] or /raw PONG j`ruV\rcn] now.
}


// onPRIVMSG
/++
 +  Handle `dialect.defs.IRCEvent.Type.QUERY` and `dialect.defs.IRCEvent.Type.CHAN`
 +  messages (`dialect.defs.IRCEvent.Type.PRIVMSG`).
 +
 +  Whether or not it is a private query message or a channel message is only obvious
 +  by looking at the target field of it; if it starts with a `#`, it is a
 +  channel message.
 +
 +  Also handle `ACTION` events (`/me slaps foo with a large trout`), and change
 +  the type to `CTCP_`-types if applicable.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      event = Reference to the `dialect.defs.IRCEvent` to continue working on.
 +      slice = Reference to the slice of the raw IRC string.
 +
 +  Throws: `dialect.common.IRCParseException` on unknown CTCP types.
 +/
void onPRIVMSG(const ref IRCParser parser, ref IRCEvent event, ref string slice) pure
{
    import dialect.common : IRCControlCharacter, isValidChannel;

    immutable target = slice.nom(" :");
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
            IRCEvent.Type.SELFCHAN : IRCEvent.Type.CHAN;
        event.channel = target;
    }
    else
    {
        // :zorael!~NaN@ns3363704.ip-94-23-253.eu PRIVMSG kameloso^ :test test content
        event.type = (event.sender.nickname == parser.client.nickname) ?
            IRCEvent.Type.SELFQUERY : IRCEvent.Type.QUERY;
        event.target.nickname = target;
    }

    if (slice.length < 3) return;

    if ((slice[0] == IRCControlCharacter.ctcp) && (slice[$-1] == IRCControlCharacter.ctcp))
    {
        slice = slice[1..$-1];
        immutable ctcpEvent = slice.contains(' ') ? slice.nom(' ') : slice;
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

        import std.traits : EnumMembers;

        /++
         +  This iterates through all `dialect.defs.IRCEvent.Type`s that
         +  begin with `CTCP_` and generates switch cases for the string of
         +  each. Inside it will assign `event.type` to the corresponding
         +  `dialect.defs.IRCEvent.Type`.
         +
         +  Like so, except automatically generated through compile-time
         +  introspection:
         +
         +      case "CTCP_PING":
         +          event.type = CTCP_PING;
         +          event.aux = "PING";
         +          break;
         +/

        with (IRCEvent.Type)
        top:
        switch (ctcpEvent)
        {
        case "ACTION":
            // We already sliced away the control characters and nommed the
            // "ACTION" ctcpEvent string, so just set the type and break.
            event.type = (event.sender.nickname == parser.client.nickname) ?
                IRCEvent.Type.SELFEMOTE : IRCEvent.Type.EMOTE;
            break;

        foreach (immutable type; EnumMembers!(IRCEvent.Type))
        {
            import lu.conv : Enum;
            import lu.string : beginsWith;

            //enum typestring = type.to!string;
            enum typestring = Enum!(IRCEvent.Type).toString(type);

            static if (typestring.beginsWith("CTCP_"))
            {
                case typestring[5..$]:
                    event.type = type;
                    event.aux = typestring[5..$];
                    if (event.content == event.aux) event.content = string.init;
                    break top;
            }
        }

        default:
            throw new IRCParseException("Unknown CTCP event: " ~ ctcpEvent, event);
        }
    }
}


// onMode
/++
 +  Handle `dialect.defs.IRCEvent.Type.MODE` changes.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      event = Reference to the `dialect.defs.IRCEvent` to continue working on.
 +      slice = Reference to the slice of the raw IRC string.
 +/
void onMode(ref IRCParser parser, ref IRCEvent event, ref string slice) pure
{
    import dialect.common : isValidChannel;

    immutable target = slice.nom(' ');

    if (target.isValidChannel(parser.server))
    {
        event.channel = target;

        if (slice.contains(' '))
        {
            // :zorael!~NaN@ns3363704.ip-94-23-253.eu MODE #flerrp +v kameloso^
            event.aux = slice.nom(' ');
            // save target in content; there may be more than one
            event.content = slice;
        }
        else
        {
            // :zorael!~NaN@ns3363704.ip-94-23-253.eu MODE #flerrp +i
            // :niven.freenode.net MODE #sklabjoier +ns
            //event.type = IRCEvent.Type.USERMODE;
            event.aux = slice;
        }
    }
    else
    {
        import lu.string : beginsWith;
        import std.string : representation;

        // :kameloso^ MODE kameloso^ :+i
        // :<something> MODE kameloso :ix
        // Does not always have the plus sign. Strip it if it's there.

        event.type = IRCEvent.Type.SELFMODE;
        if (slice.beginsWith(':')) slice = slice[1..$];

        bool subtractive;
        string modechange = slice;

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

        event.aux = modechange;

        if (subtractive)
        {
            // Remove the mode from client.modes
            auto mutModes  = parser.client.modes.dup.representation;

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
                .sort()
                .uniq
                .array
                .idup;
        }

        version(FlagAsUpdated) parser.clientUpdated = true;
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
 +  Handles `dialect.defs.IRCEvent.Type.RPL_ISUPPORT` events.
 +
 +  `dialect.defs.IRCEvent.Type.RPL_ISUPPORT` contains a bunch of interesting information that changes how we
 +  look at the `dialect.defs.IRCServer`. Notably which *network* the server
 +  is of and its max channel and nick lengths, and available modes. Then much
 +  more that we're currently ignoring.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      event = Reference to the `dialect.defs.IRCEvent` to continue working on.
 +      slice = Reference to the slice of the raw IRC string.
 +
 +  Throws: `dialect.common.IRCParseException` if something could not be parsed or converted.
 +/
void onISUPPORT(ref IRCParser parser, ref IRCEvent event, ref string slice) pure
{
    import lu.conv : Enum;
    import std.algorithm.iteration : splitter;
    import std.conv : ConvException, to;

    // :cherryh.freenode.net 005 CHANTYPES=# EXCEPTS INVEX CHANMODES=eIbq,k,flj,CFLMPQScgimnprstz CHANLIMIT=#:120 PREFIX=(ov)@+ MAXLIST=bqeI:100 MODES=4 NETWORK=freenode STATUSMSG=@+ CALLERID=g CASEMAPPING=rfc1459 :are supported by this server
    // :cherryh.freenode.net 005 CHARSET=ascii NICKLEN=16 CHANNELLEN=50 TOPICLEN=390 DEAF=D FNC TARGMAX=NAMES:1,LIST:1,KICK:1,WHOIS:1,PRIVMSG:4,NOTICE:4,ACCEPT:,MONITOR: EXTBAN=$,ajrxz CLIENTVER=3.0 CPRIVMSG CNOTICE SAFELIST :are supported by this server
    slice.nom(' ');

    if (slice.contains(" :"))
    {
        event.content = slice.nom(" :");
    }

    try
    {
        foreach (value; event.content.splitter(' '))
        {
            if (!value.contains('='))
            {
                // switch on value for things like EXCEPTS, INVEX, CPRIVMSG, etc
                continue;
            }

            immutable key = value.nom('=');

            /// http://www.irc.org/tech_docs/005.html

            with (parser.server)
            switch (key)
            {
            case "PREFIX":
                // PREFIX=(Yqaohv)!~&@%+
                import std.format : formattedRead;

                string modechars, modesigns;

                // formattedRead can throw but just let the main loop pick it up
                value.formattedRead("(%s)%s", modechars, modesigns);
                prefixes = modechars;

                foreach (immutable i; 0..modechars.length)
                {
                    prefixchars[modesigns[i]] = modechars[i];
                }
                break;

            case "CHANTYPES":
                // CHANTYPES=#
                // ...meaning which characters may prefix channel names.
                chantypes = value;
                break;

            case "CHANMODES":
                /++
                 +  This is a list of channel modes according to 4 types.
                 +
                 +  A = Mode that adds or removes a nick or address to a list.
                 +      Always has a parameter.
                 +  B = Mode that changes a setting and always has a parameter.
                 +  C = Mode that changes a setting and only has a parameter when
                 +      set.
                 +  D = Mode that changes a setting and never has a parameter.
                 +
                 +  Freenode: CHANMODES=eIbq,k,flj,CFLMPQScgimnprstz
                 +/
                string modeslice = value;
                aModes = modeslice.nom(',');
                bModes = modeslice.nom(',');
                cModes = modeslice.nom(',');
                dModes = modeslice;
                assert(!dModes.contains(','), "Bad chanmodes; dModes has comma: " ~ dModes);
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
                version(FlagAsUpdated) parser.serverUpdated = true;
                break;

            case "NICKLEN":
                maxNickLength = value.to!uint;
                break;

            case "CHANNELLEN":
                maxChannelLength = value.to!uint;
                break;

            case "CASEMAPPING":
                caseMapping = Enum!(IRCServer.CaseMapping).fromString(value);
                break;

            case "EXTBAN":
                // EXTBAN=$,ajrxz
                // EXTBAN=
                // no character means implicitly $, I believe?
                immutable prefix = value.nom(',');
                extbanPrefix = prefix.length ? prefix.to!char : '$';
                extbanTypes = value;
                break;

            case "EXCEPTS":
                exceptsChar = value.length ? value.to!char : 'e';
                break;

            case "INVEX":
                invexChar = value.length ? value.to!char : 'I';
                break;

            default:
                break;
            }
        }

        version(FlagAsUpdated) parser.serverUpdated = true;
    }
    catch (ConvException e)
    {
        throw new IRCParseException(e.msg, event, e.file, e.line);
    }
    catch (Exception e)
    {
        throw new IRCParseException(e.msg, event, e.file, e.line);
    }
}


// onMyInfo
/++
 +  Handle `dialect.defs.IRCEvent.Type.RPL_MYINFO` events.
 +
 +  `MYINFO` contains information about which *daemon* the server is running.
 +  We want that to be able to meld together a good `typenums` array.
 +
 +  It fires before `dialect.defs.IRCEvent.Type.RPL_ISUPPORT`.
 +
 +  Params:
 +      parser = Reference to the current `IRCParser`.
 +      event = Reference to the `dialect.defs.IRCEvent` to continue working on.
 +      slice = Reference to the slice of the raw IRC string.
 +/
void onMyInfo(ref IRCParser parser, ref IRCEvent event, ref string slice) pure
{
    import dialect.common : typenumsOf;
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

    slice.nom(' ');  // nickname

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

            version(FlagAsUpdated) parser.serverUpdated = true;
            return;
        }
    }

    slice.nom(' ');  // server address
    immutable daemonstring = slice.nom(' ');
    immutable daemonstringLower = daemonstring.toLower;
    event.content = slice;
    event.aux = daemonstring;

    // https://upload.wikimedia.org/wikipedia/commons/d/d5/IRCd_software_implementations3.svg

    with (IRCServer.Daemon)
    {
        IRCServer.Daemon daemon;

        if (daemonstringLower.contains("unreal"))
        {
            daemon = unreal;
        }
        else if (daemonstringLower.contains("inspircd"))
        {
            daemon = inspircd;
        }
        else if (daemonstringLower.contains("snircd"))
        {
            daemon = snircd;
        }
        else if (daemonstringLower.contains("u2."))
        {
            daemon = u2;
        }
        else if (daemonstringLower.contains("bahamut"))
        {
            daemon = bahamut;
        }
        else if (daemonstringLower.contains("hybrid"))
        {
            daemon = hybrid;
        }
        else if (daemonstringLower.contains("ratbox"))
        {
            daemon = ratbox;
        }
        else if (daemonstringLower.contains("charybdis"))
        {
            daemon = charybdis;
        }
        else if (daemonstringLower.contains("ircd-seven"))
        {
            daemon = ircdseven;
        }
        else if (daemonstring == "BSDUnix")
        {
            daemon = bsdunix;
        }
        else
        {
            daemon = unknown;
        }

        parser.typenums = typenumsOf(daemon);
        parser.server.daemon = daemon;
        parser.server.daemonstring = daemonstring;
        version(FlagAsUpdated) parser.serverUpdated = true;
    }
}


public:

// IRCParser
/++
 +  Parser that takes raw IRC strings and produces `dialect.defs.IRCEvent`s based on them.
 +
 +  Parsing requires state, which means that `IRCParser`s must be equipped with
 +  a `dialect.defs.IRCServer` and a `dialect.defs.IRCClient` for context when parsing.
 +  Because of this it has its postblit `@disable`d, so as not to make copies
 +  when only one instance should exist.
 +
 +  The alternative is to make it a class, which works too.
 +
 +  See the `/tests` directory for unit tests.
 +
 +  Example:
 +  ---
 +  IRCClient client;
 +  client.nickname = "...";
 +
 +  IRCServer server;
 +  server.address = "...";
 +
 +  IRCParser parser = IRCParser(client, server);
 +
 +  string fromServer = ":zorael!~NaN@address.tld MODE #channel +v nickname";
 +  IRCEvent event = parser.toIRCEvent(fromServer);
 +
 +  with (event)
 +  {
 +      assert(type == IRCEvent.Type.MODE);
 +      assert(sender.nickname == "zorael");
 +      assert(sender.ident == "~NaN");
 +      assert(sender.address == "address.tld");
 +      assert(target.nickname == "nickname");
 +      assert(channel == "#channel");
 +      assert(aux = "+v");
 +  }
 +
 +  string alsoFromServer = ":cherryh.freenode.net 435 oldnick newnick #d :Cannot change nickname while banned on channel";
 +  IRCEvent event2 = parser.toIRCEvent(alsoFromServer);
 +
 +  with (event2)
 +  {
 +      assert(type == IRCEvent.Type.ERR_BANONCHAN);
 +      assert(sender.address == "cherryh.freenode.net");
 +      assert(channel == "#d");
 +      assert(target.nickname == "oldnick");
 +      assert(content == "Cannot change nickname while banned on channel");
 +      assert(aux == "newnick");
 +      assert(num == 435);
 +  }
 +
 +  // Requires Twitch support via build configuration "twitch"
 +  string fullExample = "@badge-info=subscriber/15;badges=subscriber/12;color=;display-name=SomeoneOnTwitch;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=someoneontwitch;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\\s9d\\s3e\\s68\\sca\\s26\\se9\\s2a\\s6e\\s44\\sd4\\s60\\s9b\\s3d\\saa\\sb9\\s4c\\sad\\s43\\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=someoneOnTwitch\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sxQcOW's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s4\\sin\\sthe\\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type= :tmi.twitch.tv USERNOTICE #xqcow"
 +  IRCEvent event4 = parser.toIRCEvent(fullExample);
 +
 +  with (event)
 +  {
 +      assert(type == IRCEvent.Type.TWITCH_BULKGIFT);
 +      assert(sender.nickname == "someoneontwitch");
 +      assert(sender.displayName == "SomeoneOnTwitch");
 +      assert(sender.badges == "subscriber/12");
 +      assert(channel == "#xqcow");
 +      assert(content == "SomeoneOnTwitch is gifting 1 Tier 1 Subs to xQcOW's community! They've gifted a total of 4 in the channel!");
 +      assert(aux == "1000");
 +      assert(count == 1);
 +      assert(altcount == 4);
 +  }
 +  ---
 +/
struct IRCParser
{
    @safe:

    /// The current `dialect.defs.IRCClient` with all the context needed for parsing.
    IRCClient client;

    /// The current  dialect.defs.IRCServer` with all the context needed for parsing.
    IRCServer server;

    /// An `dialect.defs.IRCEvent.Type[1024]` reverse lookup table for fast numeric lookups.
    IRCEvent.Type[1024] typenums = Typenums.base;

    /++
     +  Array of active `dialect.common.Postprocessor`s, to be iterated through
     +  and processed after parsing is complete.
     +/
    Postprocessor[] postprocessors;

    // toIRCEvent
    /++
     +  Parses an IRC string into an `dialect.defs.IRCEvent`.
     +
     +  The return type is kept as `auto` to infer purity. It will be `pure` if
     +  there are no postprocessors available, and merely `@safe` if there are.
     +
     +  Proxies the call to the top-level `.toIRCEvent(IRCParser, string)`.
     +
     +  Params:
     +      raw = Raw IRC string as received from a server.
     +
     +  Returns:
     +      A complete `dialect.defs.IRCEvent`.
     +/
    auto toIRCEvent(const string raw)
    {
        IRCEvent event = .toIRCEvent(this, raw);

        // Final pass: sanity check. This verifies some fields and gives
        // meaningful error messages if something doesn't look right.
        postparseSanityCheck(this, event);

        import dialect.postprocessors : EnabledPostprocessors;

        static if (EnabledPostprocessors.length)
        {
            // Epilogue: let postprocessors alter the event
            foreach (postprocessor; postprocessors)
            {
                postprocessor.postprocess(this, event);
            }
        }

        return event;
    }

    /++
     +  Create a new `IRCParser` with the passed `dialect.defs.IRCClient` and
     +  `dialect.defs.IRCServer` as base context for parsing.
     +/
    this(IRCClient client, IRCServer server) pure nothrow
    {
        this.client = client;
        this.server = server;
        initPostprocessors();
    }

    /// Create a new `IRCParser` with the passed `dialect.defs.IRCClient` as base.
    deprecated("Use the `IRCParser(IRCClient, IRCServer)` overload")
    this(IRCClient client) pure nothrow
    {
        this.client = client;
        initPostprocessors();
    }

    /// Disallow copying of this struct.
    @disable this(this);

    /++
     +  Initialises defined postprocessors.
     +/
    void initPostprocessors() pure nothrow
    in (!postprocessors.length, "Tried to double-init postprocessors")
    do
    {
        import dialect.postprocessors : EnabledPostprocessors;

        postprocessors.reserve(EnabledPostprocessors.length);

        foreach (Postprocessor; EnabledPostprocessors)
        {
            postprocessors ~= new Postprocessor;
        }
    }

    version(FlagAsUpdated)
    {
        /// Whether or not parsing updated its internal `dialect.defs.IRCClient`.
        bool clientUpdated;

        /// Whether or not parsing updated its internal `dialect.defs.IRCServer`.
        bool serverUpdated;
    }
}

unittest
{
    import lu.meld : MeldingStrategy, meldInto;

    IRCParser parser;

    alias T = IRCEvent.Type;

    with (parser)
    {
        typenums = Typenums.base;

        assert(typenums[344] == T.init);
        Typenums.hybrid.meldInto!(MeldingStrategy.aggressive)(typenums);
        assert(typenums[344] != T.init);
    }
}
