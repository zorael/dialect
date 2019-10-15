module dialect.tests.twitch;

import lu.conv : Enum;
import dialect;
import std.conv : to;

version(TwitchSupport):

void unittest1()
{
    IRCParser parser;
    parser.initPostprocessors();

    with (parser)
    with (parser.client)
    {
        nickname = "kameloso";
        user = "kameloso!";
        server.address = "irc.chat.twitch.tv";
    }

    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv 004 kameloso :-");
        with (event)
        {
            assert((type == IRCEvent.Type.RPL_MYINFO), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((num == 4), num.to!string);
        }
    }

    with (parser)
    {
        assert((server.daemon == IRCServer.Daemon.twitch), Enum!(IRCServer.Daemon).toString(server.daemon));
        assert((server.network == "Twitch"), server.network);
        assert((server.daemonstring == "Twitch"), server.daemonstring);
        assert((server.maxNickLength == 25), server.maxNickLength.to!string);
        assert((server.prefixchars == ['@':'o']), server.prefixchars.to!string);
        assert((server.prefixes == "o"), server.prefixes);
    }

    immutable e18 = parser.toIRCEvent(":tmi.twitch.tv HOSTTARGET #lirik :h1z1 -");
    with (e18)
    {
        assert((type == IRCEvent.Type.TWITCH_HOSTSTART), Enum!(IRCEvent.Type).toString(type));
        assert((sender.address == "tmi.twitch.tv"), sender.address);
        // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
        assert((target.nickname == "h1z1"), sender.nickname);
        assert((channel == "#lirik"), channel);
        assert(!count, count.to!string);
        assert(!num, num.to!string);
    }

    immutable e19 = parser.toIRCEvent(":tmi.twitch.tv HOSTTARGET #lirik :- 178");
    with (e19)
    {
        assert((type == IRCEvent.Type.TWITCH_HOSTEND), Enum!(IRCEvent.Type).toString(type));
        assert((sender.address == "tmi.twitch.tv"), sender.address);
        // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
        assert((channel == "#lirik"), channel);
        assert((count == 178), count.to!string);
        assert(!num, num.to!string);
    }

    immutable e20 = parser.toIRCEvent(":tmi.twitch.tv HOSTTARGET #lirik :chu8 270");
    with (e20)
    {
        assert((type == IRCEvent.Type.TWITCH_HOSTSTART), Enum!(IRCEvent.Type).toString(type));
        assert((sender.address == "tmi.twitch.tv"), sender.address);
        // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
        assert((target.nickname == "chu8"), sender.nickname);
        assert((channel == "#lirik"), channel);
        assert((count == 270), count.to!string);
        assert(!num, num.to!string);
    }

    {
        immutable event = parser.toIRCEvent("@badges=subscriber/3;color=;display-name=asdcassr;emotes=560489:0-6,8-14,16-22,24-30/560510:39-46;id=4d6bbafb-427d-412a-ae24-4426020a1042;mod=0;room-id=23161357;sent-ts=1510059590512;subscriber=1;tmi-sent-ts=1510059591528;turbo=0;user-id=38772474;user-type= :asdcsa!asdcss@asdcsd.tmi.twitch.tv PRIVMSG #lirik :lirikFR lirikFR lirikFR lirikFR :sled: lirikLUL");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "asdcsa"), sender.nickname);
            assert((sender.ident == "asdcss"), sender.ident);
            assert((sender.address == "asdcsd.tmi.twitch.tv"), sender.address);
            assert((sender.class_ != IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#lirik"), channel);
            assert((content == "lirikFR lirikFR lirikFR lirikFR :sled: lirikLUL"), content);
            assert((tags == "badges=subscriber/3;color=;display-name=asdcassr;emotes=560489:0-6,8-14,16-22,24-30/560510:39-46;id=4d6bbafb-427d-412a-ae24-4426020a1042;mod=0;room-id=23161357;sent-ts=1510059590512;subscriber=1;tmi-sent-ts=1510059591528;turbo=0;user-id=38772474;user-type="), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent("@broadcaster-lang=;emote-only=0;followers-only=-1;mercury=0;r9k=0;room-id=22216721;slow=0;subs-only=0 :tmi.twitch.tv ROOMSTATE #zorael");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == ROOMSTATE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#zorael"), channel);
            assert((tags == "broadcaster-lang=;emote-only=0;followers-only=-1;mercury=0;r9k=0;room-id=22216721;slow=0;subs-only=0"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv CAP * LS :twitch.tv/tags twitch.tv/commands twitch.tv/membership");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == CAP), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((content == "twitch.tv/tags twitch.tv/commands twitch.tv/membership"), content);
            assert((aux == "LS"), aux);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv USERSTATE #zorael");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == USERSTATE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert(!content.length, content);
            assert((channel == "#zorael"), channel);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv ROOMSTATE #zorael");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == ROOMSTATE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert(!content.length, content);
            assert((channel == "#zorael"), channel);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv HOSTTARGET #andymilonakis :zombie_barricades -");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == TWITCH_HOSTSTART), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((target.nickname == "zombie_barricades"), sender.nickname);
            assert((channel == "#andymilonakis"), channel);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv USERNOTICE #drdisrespectlive :ooooo weee, it's a meeeee, Moweee!");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == USERNOTICE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#drdisrespectlive"), channel);
            assert((content == "ooooo weee, it's a meeeee, Moweee!"), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv USERNOTICE #lirik");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == USERNOTICE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#lirik"), channel);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv CLEARCHAT #channel :user");
        with (IRCEvent.Type)
        with (event)
        {
            assert((type == TWITCH_BAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#channel"), channel);
            assert((target.nickname == "user"), target.nickname);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv RECONNECT");
        with (event)
        {
            assert((type == IRCEvent.Type.RECONNECT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
        }
    }
    {
        immutable event = parser.toIRCEvent(":kameloso!kameloso@kameloso.tmi.twitch.tv JOIN p4wnyhof");
        with (event)
        {
            assert((type == IRCEvent.Type.SELFJOIN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "kameloso"), sender.nickname);
            assert((sender.ident == "kameloso"), sender.ident);
            assert((sender.address == "kameloso.tmi.twitch.tv"), sender.address);
            assert((channel == "p4wnyhof"), channel);
        }
    }
    {
        immutable event = parser.toIRCEvent(":kameloso!kameloso@kameloso.tmi.twitch.tv PART p4wnyhof");
        with (event)
        {
            assert((type == IRCEvent.Type.SELFPART), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "kameloso"), sender.nickname);
            assert((sender.ident == "kameloso"), sender.ident);
            assert((sender.address == "kameloso.tmi.twitch.tv"), sender.address);
            assert((channel == "p4wnyhof"), channel);
        }
    }
}

void unittest2()
{
    IRCParser parser;
    parser.initPostprocessors();

    with (parser)
    with (parser.client)
    {
        nickname = "zorael";
        user = "zorael!";
        ident = "NaN";
        realName = "kameloso IRC bot";
        server.address = "irc.chat.twitch.tv";
        server.port = 6667;
        server.daemon = IRCServer.Daemon.twitch;
        server.network = "Twitch";
        server.daemonstring = "twitch";
        server.aModes = "eIbq";
        server.bModes = "k";
        server.cModes = "flj";
        server.dModes = "CFLMPQScgimnprstz";
        server.prefixchars = ['v':'+', 'o':'@'];
        server.prefixes = "ov";
    }

    parser.typenums = typenumsOf(parser.server.daemon);

    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=;color=#5F9EA0;display-name=Zorael;emote-sets=0,185411,771823,1511983;user-id=22216721;user-type= :tmi.twitch.tv GLOBALUSERSTATE");
        with (event)
        {
            assert((type == IRCEvent.Type.GLOBALUSERSTATE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
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

    {
        immutable event = parser.toIRCEvent("@msg-id=color_changed :tmi.twitch.tv NOTICE #zorael :Your color has been changed.");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_NOTICE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#zorael"), channel);
            assert((content == "Your color has been changed."), content);
            assert((aux == "color_changed"), aux);
            assert((tags == "msg-id=color_changed"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent(":zorael!zorael@zorael.tmi.twitch.tv JOIN #kameboto");
        with (event)
        {
            assert((type == IRCEvent.Type.SELFJOIN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "zorael"), sender.nickname);
            assert((sender.ident == "zorael"), sender.ident);
            assert((sender.address == "zorael.tmi.twitch.tv"), sender.address);
            assert((sender.account == "zorael"), sender.account);
            assert((channel == "#kameboto"), channel);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=moderator/1;color=#5F9EA0;display-name=Zorael;emote-sets=0,185411,771853,1511983;mod=1;subscriber=0;user-type=mod :tmi.twitch.tv USERSTATE #kameboto");
        with (event)
        {
            assert((type == IRCEvent.Type.USERSTATE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#kameboto"), channel);
            assert((target.nickname == "zorael"), target.nickname);
            assert((target.displayName == "Zorael"), target.displayName);
            assert((target.class_ == IRCUser.Class.unset), Enum!(IRCUser.Class).toString(target.class_));
            assert((target.badges == "moderator/1"), target.badges);
            assert((target.colour == "5F9EA0"), target.colour);
            assert((tags == "badge-info=;badges=moderator/1;color=#5F9EA0;display-name=Zorael;emote-sets=0,185411,771853,1511983;mod=1;subscriber=0;user-type=mod"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=;color=#008000;display-name=今伊勢;emotes=;flags=;id=fde5380d-0fb8-4406-9790-e09fd0a54543;mod=0;room-id=114701382;subscriber=0;tmi-sent-ts=1569001285736;turbo=0;user-id=184077758;user-type= :rezel02!rezel02@rezel02.tmi.twitch.tv PRIVMSG #arunero9029 :海外プレイヤーが見つけたやつ");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "rezel02"), sender.nickname);
            assert((sender.displayName == "今伊勢"), sender.displayName);
            assert((sender.ident == "rezel02"), sender.ident);
            assert((sender.address == "rezel02.tmi.twitch.tv"), sender.address);
            assert((sender.account == "rezel02"), sender.account);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.colour == "008000"), sender.colour);
            assert((channel == "#arunero9029"), channel);
            assert((content == "海外プレイヤーが見つけたやつ"), content);
            assert((tags == "badge-info=;badges=;color=#008000;display-name=今伊勢;emotes=;flags=;id=fde5380d-0fb8-4406-9790-e09fd0a54543;mod=0;room-id=114701382;subscriber=0;tmi-sent-ts=1569001285736;turbo=0;user-id=184077758;user-type="), tags);
            assert((id == "fde5380d-0fb8-4406-9790-e09fd0a54543"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent(":s1faka!s1faka@s1faka.tmi.twitch.tv PART #arunero9029");
        with (event)
        {
            assert((type == IRCEvent.Type.PART), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "s1faka"), sender.nickname);
            assert((sender.ident == "s1faka"), sender.ident);
            assert((sender.address == "s1faka.tmi.twitch.tv"), sender.address);
            assert((sender.account == "s1faka"), sender.account);
            assert((channel == "#arunero9029"), channel);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tnpmen!tnpmen@tnpmen.tmi.twitch.tv JOIN #arunero9029");
        with (event)
        {
            assert((type == IRCEvent.Type.JOIN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "tnpmen"), sender.nickname);
            assert((sender.ident == "tnpmen"), sender.ident);
            assert((sender.address == "tnpmen.tmi.twitch.tv"), sender.address);
            assert((sender.account == "tnpmen"), sender.account);
            assert((channel == "#arunero9029"), channel);
        }
    }
    {
        immutable event = parser.toIRCEvent("@emote-only=0;followers-only=-1;r9k=0;rituals=0;room-id=404208264;slow=0;subs-only=0 :tmi.twitch.tv ROOMSTATE #kameboto");
        with (event)
        {
            assert((type == IRCEvent.Type.ROOMSTATE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#kameboto"), channel);
            assert((tags == "emote-only=0;followers-only=-1;r9k=0;rituals=0;room-id=404208264;slow=0;subs-only=0"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#7403B4;display-name=GunnrySGT_Buck;emotes=;flags=;id=09eddc75-d3ce-4c4f-9f08-37ce43c7d325;mod=0;msg-id=highlighted-message;room-id=74488574;subscriber=1;tmi-sent-ts=1569005180759;turbo=0;user-id=70624578;user-type= :gunnrysgt_buck!gunnrysgt_buck@gunnrysgt_buck.tmi$twitch.tv PRIVMSG #beardageddon :Theres no HWAY");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "gunnrysgt_buck"), sender.nickname);
            assert((sender.displayName == "GunnrySGT_Buck"), sender.displayName);
            assert((sender.ident == "gunnrysgt_buck"), sender.ident);
            assert((sender.address == "gunnrysgt_buck.tmi$twitch.tv"), sender.address);
            assert((sender.account == "gunnrysgt_buck"), sender.account);
            assert((sender.badges == "subscriber/0,premium/1"), sender.badges);
            assert((sender.colour == "7403B4"), sender.colour);
            assert((channel == "#beardageddon"), channel);
            assert((content == "Theres no HWAY"), content);
            assert((aux == "highlighted-message"), aux);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#7403B4;display-name=GunnrySGT_Buck;emotes=;flags=;id=09eddc75-d3ce-4c4f-9f08-37ce43c7d325;mod=0;msg-id=highlighted-message;room-id=74488574;subscriber=1;tmi-sent-ts=1569005180759;turbo=0;user-id=70624578;user-type="), tags);
            assert((id == "09eddc75-d3ce-4c4f-9f08-37ce43c7d325"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent(`@badge-info=subscriber/0;badges=subscriber/0,premium/1;color=#19B336;display-name=IamSlower;emotes=;flags=;id=0a66cc58-57db-4ae6-940d-d46aa315e2d1;login=iamslower;mod=0;msg-id=sub;msg-param-cumulative-months=1;msg-param-months=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=Prime;room-id=69906737;subscriber=1;system-msg=IamSlower\ssubscribed\swith\sTwitch\sPrime.;tmi-sent-ts=1569005836621;user-id=147721858;user-type= :tmi.twitch.tv USERNOTICE #chocotaco`);
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUB), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "iamslower"), sender.nickname);
            assert((sender.displayName == "IamSlower"), sender.displayName);
            assert((sender.account == "iamslower"), sender.account);
            assert((sender.badges == "subscriber/0,premium/1"), sender.badges);
            assert((sender.colour == "19B336"), sender.colour);
            assert((channel == "#chocotaco"), channel);
            assert((content == "IamSlower subscribed with Twitch Prime."), content);
            assert((aux == "Prime"), aux);
            assert((tags == `badge-info=subscriber/0;badges=subscriber/0,premium/1;color=#19B336;display-name=IamSlower;emotes=;flags=;id=0a66cc58-57db-4ae6-940d-d46aa315e2d1;login=iamslower;mod=0;msg-id=sub;msg-param-cumulative-months=1;msg-param-months=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=Prime;room-id=69906737;subscriber=1;system-msg=IamSlower\ssubscribed\swith\sTwitch\sPrime.;tmi-sent-ts=1569005836621;user-id=147721858;user-type=`), tags);
            assert((altcount == 1), altcount.to!string);
            assert((id == "0a66cc58-57db-4ae6-940d-d46aa315e2d1"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent(`@badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=f5446beb-bc54-472c-9539-e495a1250a30;login=nappy5074;mod=0;msg-id=subgift;msg-param-months=6;msg-param-origin-id=da\s39\sa3\see\s5e\s6b\s4b\s0d\s32\s55\sbf\sef\s95\s60\s18\s90\saf\sd8\s07\s09;msg-param-recipient-display-name=buffalo_bison;msg-param-recipient-id=141870891;msg-param-recipient-user-name=buffalo_bison;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\sgifted\sa\sTier\s1\ssub\sto\sbuffalo_bison!;tmi-sent-ts=1569005845776;user-id=230054092;user-type= :tmi.twitch.tv USERNOTICE #chocotaco`);
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUBGIFT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "nappy5074"), sender.nickname);
            assert((sender.displayName == "nappy5074"), sender.displayName);
            assert((sender.account == "nappy5074"), sender.account);
            assert((sender.badges == "subscriber/12,sub-gifter/500"), sender.badges);
            assert((sender.colour == "0000FF"), sender.colour);
            assert((channel == "#chocotaco"), channel);
            assert((target.nickname == "buffalo_bison"), target.nickname);
            assert((target.displayName == "buffalo_bison"), target.displayName);
            assert((content == "nappy5074 gifted a Tier 1 sub to buffalo_bison!"), content);
            assert((aux == "1000"), aux);
            assert((tags == `badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=f5446beb-bc54-472c-9539-e495a1250a30;login=nappy5074;mod=0;msg-id=subgift;msg-param-months=6;msg-param-origin-id=da\s39\sa3\see\s5e\s6b\s4b\s0d\s32\s55\sbf\sef\s95\s60\s18\s90\saf\sd8\s07\s09;msg-param-recipient-display-name=buffalo_bison;msg-param-recipient-id=141870891;msg-param-recipient-user-name=buffalo_bison;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\sgifted\sa\sTier\s1\ssub\sto\sbuffalo_bison!;tmi-sent-ts=1569005845776;user-id=230054092;user-type=`), tags);
            assert((id == "f5446beb-bc54-472c-9539-e495a1250a30"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent(`@badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=d7a1da3b-9ba7-495d-bfd5-9ad4f9f434d2;login=nappy5074;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=20;msg-param-origin-id=ce\s08\s4e\sf5\se9\sf5\s31\s6c\s7a\sb6\sbc\sf9\s71\s8a\sf2\s7f\s90\s4c\s87\s47;msg-param-sender-count=650;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\sis\sgifting\s20\sTier\s1\sSubs\sto\schocoTaco's\scommunity!\sThey've\sgifted\sa\stotal\sof\s650\sin\sthe\schannel!;tmi-sent-ts=1569005843145;user-id=230054092;user-type= :tmi.twitch.tv USERNOTICE #chocotaco`);
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "nappy5074"), sender.nickname);
            assert((sender.displayName == "nappy5074"), sender.displayName);
            assert((sender.account == "nappy5074"), sender.account);
            assert((sender.badges == "subscriber/12,sub-gifter/500"), sender.badges);
            assert((sender.colour == "0000FF"), sender.colour);
            assert((channel == "#chocotaco"), channel);
            assert((content == "nappy5074 is gifting 20 Tier 1 Subs to chocoTaco's community! They've gifted a total of 650 in the channel!"), content);
            assert((aux == "1000"), aux);
            assert((tags == `badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=d7a1da3b-9ba7-495d-bfd5-9ad4f9f434d2;login=nappy5074;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=20;msg-param-origin-id=ce\s08\s4e\sf5\se9\sf5\s31\s6c\s7a\sb6\sbc\sf9\s71\s8a\sf2\s7f\s90\s4c\s87\s47;msg-param-sender-count=650;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\sis\sgifting\s20\sTier\s1\sSubs\sto\schocoTaco's\scommunity!\sThey've\sgifted\sa\stotal\sof\s650\sin\sthe\schannel!;tmi-sent-ts=1569005843145;user-id=230054092;user-type=`), tags);
            assert((count == 20), count.to!string);
            assert((altcount == 650), altcount.to!string);
            assert((id == "d7a1da3b-9ba7-495d-bfd5-9ad4f9f434d2"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent(`@badge-info=subscriber/11;badges=subscriber/9,premium/1;color=;display-name=Noahxcite;emotes=;flags=;id=2e7b0dbc-d6be-4331-903b-17255ae57d5b;login=noahxcite;mod=0;msg-id=resub;msg-param-cumulative-months=11;msg-param-months=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=Noahxcite\ssubscribed\sat\sTier\s1.\sThey've\ssubscribed\sfor\s11\smonths!;tmi-sent-ts=1569006106614;user-id=67751309;user-type= :tmi.twitch.tv USERNOTICE #chocotaco`);
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUB), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "noahxcite"), sender.nickname);
            assert((sender.displayName == "Noahxcite"), sender.displayName);
            assert((sender.account == "noahxcite"), sender.account);
            assert((sender.badges == "subscriber/9,premium/1"), sender.badges);
            assert((channel == "#chocotaco"), channel);
            assert((content == "Noahxcite subscribed at Tier 1. They've subscribed for 11 months!"), content);
            assert((aux == "1000"), aux);
            assert((tags == `badge-info=subscriber/11;badges=subscriber/9,premium/1;color=;display-name=Noahxcite;emotes=;flags=;id=2e7b0dbc-d6be-4331-903b-17255ae57d5b;login=noahxcite;mod=0;msg-id=resub;msg-param-cumulative-months=11;msg-param-months=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=Noahxcite\ssubscribed\sat\sTier\s1.\sThey've\ssubscribed\sfor\s11\smonths!;tmi-sent-ts=1569006106614;user-id=67751309;user-type=`), tags);
            assert((altcount == 11), altcount.to!string);
            assert((id == "2e7b0dbc-d6be-4331-903b-17255ae57d5b"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent(`@badge-info=subscriber/6;badges=subscriber/6,premium/1;color=;display-name=acul1992;emotes=;flags=;id=287de5eb-b93c-4040-86b7-16cddb6cefc8;login=acul1992;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=eb\s39\sea\sd2\sbc\sb4\sd9\sd8\sc9\s51\sd5\s3a\sbb\seb\sd7\s6b\sa8\s2c\sc1\s71;msg-param-sender-count=1;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=acul1992\sis\sgifting\s1\sTier\s1\sSubs\sto\schocoTaco's\scommunity!\sThey've\sgifted\sa\stotal\sof\s1\sin\sthe\schannel!;tmi-sent-ts=1569006134003;user-id=32127247;user-type= :tmi.twitch.tv USERNOTICE #chocotaco`);
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "acul1992"), sender.nickname);
            assert((sender.displayName == "acul1992"), sender.displayName);
            assert((sender.account == "acul1992"), sender.account);
            assert((sender.badges == "subscriber/6,premium/1"), sender.badges);
            assert((channel == "#chocotaco"), channel);
            assert((content == "acul1992 is gifting 1 Tier 1 Subs to chocoTaco's community! They've gifted a total of 1 in the channel!"), content);
            assert((aux == "1000"), aux);
            assert((tags == `badge-info=subscriber/6;badges=subscriber/6,premium/1;color=;display-name=acul1992;emotes=;flags=;id=287de5eb-b93c-4040-86b7-16cddb6cefc8;login=acul1992;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=eb\s39\sea\sd2\sbc\sb4\sd9\sd8\sc9\s51\sd5\s3a\sbb\seb\sd7\s6b\sa8\s2c\sc1\s71;msg-param-sender-count=1;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=acul1992\sis\sgifting\s1\sTier\s1\sSubs\sto\schocoTaco's\scommunity!\sThey've\sgifted\sa\stotal\sof\s1\sin\sthe\schannel!;tmi-sent-ts=1569006134003;user-id=32127247;user-type=`), tags);
            assert((count == 1), count.to!string);
            assert((altcount == 1), altcount.to!string);
            assert((id == "287de5eb-b93c-4040-86b7-16cddb6cefc8"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent(`@badge-info=subscriber/9;badges=subscriber/9,bits/100;color=#2B22B2;display-name=PoggyFifty;emotes=;flags=;id=21bb6867-1e5b-475c-90a4-c21bc5cf42d3;login=poggyfifty;mod=0;msg-id=resub;msg-param-cumulative-months=9;msg-param-months=0;msg-param-should-share-streak=1;msg-param-streak-months=9;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=PoggyFifty\ssubscribed\sat\sTier\s1.\sThey've\ssubscribed\sfor\s9\smonths,\scurrently\son\sa\s9\smonth\sstreak!;tmi-sent-ts=1569006294587;user-id=204550522;user-type= :tmi.twitch.tv USERNOTICE #chocotaco :WAHEEEEY DA CHOCOOOOOOOOOOOO`);
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUB), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "poggyfifty"), sender.nickname);
            assert((sender.displayName == "PoggyFifty"), sender.displayName);
            assert((sender.account == "poggyfifty"), sender.account);
            assert((sender.badges == "subscriber/9,bits/100"), sender.badges);
            assert((sender.colour == "2B22B2"), sender.colour);
            assert((channel == "#chocotaco"), channel);
            assert((content == "WAHEEEEY DA CHOCOOOOOOOOOOOO"), content);
            assert((aux == "1000"), aux);
            assert((tags == `badge-info=subscriber/9;badges=subscriber/9,bits/100;color=#2B22B2;display-name=PoggyFifty;emotes=;flags=;id=21bb6867-1e5b-475c-90a4-c21bc5cf42d3;login=poggyfifty;mod=0;msg-id=resub;msg-param-cumulative-months=9;msg-param-months=0;msg-param-should-share-streak=1;msg-param-streak-months=9;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=PoggyFifty\ssubscribed\sat\sTier\s1.\sThey've\ssubscribed\sfor\s9\smonths,\scurrently\son\sa\s9\smonth\sstreak!;tmi-sent-ts=1569006294587;user-id=204550522;user-type=`), tags);
            assert((count == 9), count.to!string);
            assert((altcount == 9), altcount.to!string);
            assert((id == "21bb6867-1e5b-475c-90a4-c21bc5cf42d3"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=subscriber/13;badges=subscriber/12,twitchconNA2019/1;bits=100;color=#0000FF;display-name=eXpressRR;emotes=757370:0-10;flags=;id=d437ff32-2c98-4c86-b404-85c577e7a63d;mod=0;room-id=69906737;subscriber=1;tmi-sent-ts=1569007507586;turbo=0;user-id=172492216;user-type= :expressrr!expressrr@expressrr.tmi.twitch.tv PRIVMSG #chocotaco :chocotHello Subway100 bonus10 Did you see the chocomerch promo video I made last night??");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_CHEER), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "expressrr"), sender.nickname);
            assert((sender.displayName == "eXpressRR"), sender.displayName);
            assert((sender.ident == "expressrr"), sender.ident);
            assert((sender.address == "expressrr.tmi.twitch.tv"), sender.address);
            assert((sender.account == "expressrr"), sender.account);
            assert((sender.badges == "subscriber/12,twitchconNA2019/1"), sender.badges);
            assert((sender.colour == "0000FF"), sender.colour);
            assert((channel == "#chocotaco"), channel);
            assert((content == "chocotHello Subway100 bonus10 Did you see the chocomerch promo video I made last night??"), content);
            assert((tags == "badge-info=subscriber/13;badges=subscriber/12,twitchconNA2019/1;bits=100;color=#0000FF;display-name=eXpressRR;emotes=757370:0-10;flags=;id=d437ff32-2c98-4c86-b404-85c577e7a63d;mod=0;room-id=69906737;subscriber=1;tmi-sent-ts=1569007507586;turbo=0;user-id=172492216;user-type="), tags);
            assert((count == 100), count.to!string);
            assert((emotes == "757370:0-10"), emotes);
            assert((id == "d437ff32-2c98-4c86-b404-85c577e7a63d"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@ban-duration=600;room-id=79442833;target-user-id=447000332;tmi-sent-ts=1569007534501 :tmi.twitch.tv CLEARCHAT #mithrain :14ahmetkerim");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_TIMEOUT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#mithrain"), channel);
            assert((target.nickname == "14ahmetkerim"), target.nickname);
            assert((tags == "ban-duration=600;room-id=79442833;target-user-id=447000332;tmi-sent-ts=1569007534501"), tags);
            assert((count == 600), count.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#9ACD32;display-name=burakk1912;emotes=;flags=;id=a805a41d-99e5-4a5d-be80-a95ccefc9e73;login=burakk1912;mod=0;msg-id=primepaidupgrade;msg-param-sub-plan=1000;room-id=79442833;subscriber=1;system-msg=burakk1912\\sconverted\\sfrom\\sa\\sTwitch\\sPrime\\ssub\\sto\\sa\\sTier\\s1\\ssub!;tmi-sent-ts=1569008642164;user-id=242099224;user-type= :tmi.twitch.tv USERNOTICE #mithrain");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUBUPGRADE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "burakk1912"), sender.nickname);
            assert((sender.displayName == "burakk1912"), sender.displayName);
            assert((sender.account == "burakk1912"), sender.account);
            assert((sender.badges == "subscriber/0,premium/1"), sender.badges);
            assert((sender.colour == "9ACD32"), sender.colour);
            assert((channel == "#mithrain"), channel);
            assert((content == "burakk1912 converted from a Twitch Prime sub to a Tier 1 sub!"), content);
            assert((aux == "1000"), aux);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#9ACD32;display-name=burakk1912;emotes=;flags=;id=a805a41d-99e5-4a5d-be80-a95ccefc9e73;login=burakk1912;mod=0;msg-id=primepaidupgrade;msg-param-sub-plan=1000;room-id=79442833;subscriber=1;system-msg=burakk1912\\sconverted\\sfrom\\sa\\sTwitch\\sPrime\\ssub\\sto\\sa\\sTier\\s1\\ssub!;tmi-sent-ts=1569008642164;user-id=242099224;user-type="), tags);
            assert((id == "a805a41d-99e5-4a5d-be80-a95ccefc9e73"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=subscriber/2;badges=subscriber/0;color=#7F7F7F;display-name=WaIt;emotes=;flags=;id=16df867b-4cd0-450d-9bd5-f30f4c8a1781;login=wait;mod=0;msg-id=giftpaidupgrade;msg-param-sender-login=fuzwuz;msg-param-sender-name=fuzwuz;room-id=69906737;subscriber=1;system-msg=WaIt\\sis\\scontinuing\\sthe\\sGift\\sSub\\sthey\\sgot\\sfrom\\sfuzwuz!;tmi-sent-ts=1569010405948;user-id=48663198;user-type= :tmi.twitch.tv USERNOTICE #chocotaco");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_GIFTCHAIN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "wait"), sender.nickname);
            assert((sender.displayName == "WaIt"), sender.displayName);
            assert((sender.account == "wait"), sender.account);
            assert((sender.badges == "subscriber/0"), sender.badges);
            assert((sender.colour == "7F7F7F"), sender.colour);
            assert((channel == "#chocotaco"), channel);
            assert((target.nickname == "fuzwuz"), target.nickname);
            assert((target.displayName == "fuzwuz"), target.displayName);
            assert((content == "WaIt is continuing the Gift Sub they got from fuzwuz!"), content);
            assert((tags == "badge-info=subscriber/2;badges=subscriber/0;color=#7F7F7F;display-name=WaIt;emotes=;flags=;id=16df867b-4cd0-450d-9bd5-f30f4c8a1781;login=wait;mod=0;msg-id=giftpaidupgrade;msg-param-sender-login=fuzwuz;msg-param-sender-name=fuzwuz;room-id=69906737;subscriber=1;system-msg=WaIt\\sis\\scontinuing\\sthe\\sGift\\sSub\\sthey\\sgot\\sfrom\\sfuzwuz!;tmi-sent-ts=1569010405948;user-id=48663198;user-type="), tags);
            assert((id == "16df867b-4cd0-450d-9bd5-f30f4c8a1781"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@login=xinotv;room-id=;target-msg-id=e5fb3fd2-8c0f-4468-b45a-c70f0e615507;tmi-sent-ts=1569010639801 :tmi.twitch.tv CLEARMSG #squeezielive :25 euros de cashprize à gagner me mp");
        with (event)
        {
            assert((type == IRCEvent.Type.CLEARMSG), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "xinotv"), sender.nickname);
            assert((sender.account == "xinotv"), sender.account);
            assert((channel == "#squeezielive"), channel);
            assert((content == "25 euros de cashprize à gagner me mp"), content);
            assert((tags == "login=xinotv;room-id=;target-msg-id=e5fb3fd2-8c0f-4468-b45a-c70f0e615507;tmi-sent-ts=1569010639801"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent("@room-id=52130765;target-user-id=458740201;tmi-sent-ts=1569010642754 :tmi.twitch.tv CLEARCHAT #squeezielive :xinotv");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#squeezielive"), channel);
            assert((target.nickname == "xinotv"), target.nickname);
            assert((tags == "room-id=52130765;target-user-id=458740201;tmi-sent-ts=1569010642754"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent("@room-id=52130765;target-user-id=458740201;tmi-sent-ts=1569010642754 :tmi.twitch.tv CLEARCHAT #squeezielive :xinotv");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#squeezielive"), channel);
            assert((target.nickname == "xinotv"), target.nickname);
            assert((tags == "room-id=52130765;target-user-id=458740201;tmi-sent-ts=1569010642754"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv HOSTTARGET #kungentv :esfandtv 5167");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_HOSTSTART), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#kungentv"), channel);
            assert((target.nickname == "esfandtv"), target.nickname);
            assert((count == 5167), count.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent("@msg-id=host_on :tmi.twitch.tv NOTICE #kungentv :Now hosting EsfandTV.");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_NOTICE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#kungentv"), channel);
            assert((content == "Now hosting EsfandTV."), content);
            assert((aux == "host_on"), aux);
            assert((tags == "msg-id=host_on"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=premium/1;color=#67B222;display-name=travslaps;emotes=30259:0-6;flags=;id=a875d520-ba60-4383-925c-4fa09b3fd772;login=travslaps;mod=0;msg-id=ritual;msg-param-ritual-name=new_chatter;room-id=106125347;subscriber=0;system-msg=@travslaps\\sis\\snew\\shere.\\sSay\\shello!;tmi-sent-ts=1569012207274;user-id=183436052;user-type= :tmi.twitch.tv USERNOTICE #couragejd :HeyGuys");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_RITUAL), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "travslaps"), sender.nickname);
            assert((sender.displayName == "travslaps"), sender.displayName);
            assert((sender.account == "travslaps"), sender.account);
            assert((sender.badges == "premium/1"), sender.badges);
            assert((sender.colour == "67B222"), sender.colour);
            assert((channel == "#couragejd"), channel);
            assert((content == "HeyGuys"), content);
            assert((aux == "@travslaps is new here. Say hello!"), aux);
            assert((tags == "badge-info=;badges=premium/1;color=#67B222;display-name=travslaps;emotes=30259:0-6;flags=;id=a875d520-ba60-4383-925c-4fa09b3fd772;login=travslaps;mod=0;msg-id=ritual;msg-param-ritual-name=new_chatter;room-id=106125347;subscriber=0;system-msg=@travslaps\\sis\\snew\\shere.\\sSay\\shello!;tmi-sent-ts=1569012207274;user-id=183436052;user-type="), tags);
            assert((emotes == "30259:0-6"), emotes);
            assert((id == "a875d520-ba60-4383-925c-4fa09b3fd772"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv HOSTTARGET #asmongold :- 0");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_HOSTEND), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            // assert((sender.class_ == IRCUser.Class.special), Enum!(IRCUser.Class).toString(sender.class_));
            assert((channel == "#asmongold"), channel);
        }
    }
    {
        // @badge-info=subscriber/15;badges=subscriber/12;color=;display-name=tayk47_mom;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=tayk47_mom;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\s9d\s3e\s68\sca\s26\se9\s2a\s6e\s44\sd4\s60\s9b\s3d\saa\sb9\s4c\sad\s43\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=tayk47_mom\sis\sgifting\s1\sTier\s1\sSubs\sto\sxQcOW's\scommunity!\sThey've\sgifted\sa\stotal\sof\s4\sin\sthe\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type= :tmi.twitch.tv USERNOTICE #xqcow
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
            assert((tags == "badge-info=subscriber/15;badges=subscriber/12;color=;display-name=tayk47_mom;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=tayk47_mom;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\\s9d\\s3e\\s68\\sca\\s26\\se9\\s2a\\s6e\\s44\\sd4\\s60\\s9b\\s3d\\saa\\sb9\\s4c\\sad\\s43\\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=tayk47_mom\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sxQcOW's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s4\\sin\\sthe\\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type="), tags);
            assert((count == 1), count.to!string);
            assert((altcount == 4), altcount.to!string);
            assert((id == "d6729804-2bf3-495d-80ce-a2fe8ed00a26"), id);
        }
    }
    {
        // @badge-info=;badges=partner/1;color=#004DFF;display-name=NorddeutscherJunge;emotes=;flags=;id=3ced021d-adab-4278-845d-4c8f2c5d6306;login=norddeutscherjunge;mod=0;msg-id=primecommunitygiftreceived;msg-param-gift-name=World\sof\sTanks:\sCare\sPackage;msg-param-middle-man=gabepeixe;msg-param-recipient=m4ggusbruno;msg-param-sender=NorddeutscherJunge;room-id=59799994;subscriber=0;system-msg=A\sviewer\swas\sgifted\sa\sWorld\sof\sTanks:\sCare\sPackage,\scourtesy\sof\sa\sPrime\smember!;tmi-sent-ts=1570346408346;user-id=39548541;user-type= :tmi.twitch.tv USERNOTICE #gabepeixe
        immutable event = parser.toIRCEvent("@badge-info=;badges=partner/1;color=#004DFF;display-name=NorddeutscherJunge;emotes=;flags=;id=3ced021d-adab-4278-845d-4c8f2c5d6306;login=norddeutscherjunge;mod=0;msg-id=primecommunitygiftreceived;msg-param-gift-name=World\\sof\\sTanks:\\sCare\\sPackage;msg-param-middle-man=gabepeixe;msg-param-recipient=m4ggusbruno;msg-param-sender=NorddeutscherJunge;room-id=59799994;subscriber=0;system-msg=A\\sviewer\\swas\\sgifted\\sa\\sWorld\\sof\\sTanks:\\sCare\\sPackage,\\scourtesy\\sof\\sa\\sPrime\\smember!;tmi-sent-ts=1570346408346;user-id=39548541;user-type= :tmi.twitch.tv USERNOTICE #gabepeixe");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_GIFTRECEIVED), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "norddeutscherjunge"), sender.nickname);
            assert((sender.account == "norddeutscherjunge"), sender.account);
            assert((sender.displayName == "NorddeutscherJunge"), sender.displayName);
            assert((sender.badges == "partner/1"), sender.badges);
            assert((sender.colour == "004DFF"), sender.colour);
            assert((channel == "#gabepeixe"), channel);
            assert((target.nickname == "m4ggusbruno"), target.nickname);
            assert((content == "A viewer was gifted a World of Tanks: Care Package, courtesy of a Prime member!"), content);
            assert((aux == "World\\sof\\sTanks:\\sCare\\sPackage"), aux);
            assert((tags == "badge-info=;badges=partner/1;color=#004DFF;display-name=NorddeutscherJunge;emotes=;flags=;id=3ced021d-adab-4278-845d-4c8f2c5d6306;login=norddeutscherjunge;mod=0;msg-id=primecommunitygiftreceived;msg-param-gift-name=World\\sof\\sTanks:\\sCare\\sPackage;msg-param-middle-man=gabepeixe;msg-param-recipient=m4ggusbruno;msg-param-sender=NorddeutscherJunge;room-id=59799994;subscriber=0;system-msg=A\\sviewer\\swas\\sgifted\\sa\\sWorld\\sof\\sTanks:\\sCare\\sPackage,\\scourtesy\\sof\\sa\\sPrime\\smember!;tmi-sent-ts=1570346408346;user-id=39548541;user-type="), tags);
            assert((id == "3ced021d-adab-4278-845d-4c8f2c5d6306"), id);
        }
    }
}
