import lu.conv : Enum;
import dialect;
import std.conv : to;

version(TwitchSupport):

unittest
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

    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv HOSTTARGET #lirik :h1z1 -");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_HOSTSTART), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "lirik"), sender.nickname);
            assert((sender.account == "lirik"), sender.account);
            assert((channel == "#lirik"), channel);
            assert((target.nickname == "h1z1"), target.nickname);
            assert((target.account == "h1z1"), target.account);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv HOSTTARGET #lirik :- 178");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_HOSTEND), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "lirik"), sender.nickname);
            assert((sender.account == "lirik"), sender.account);
            assert((channel == "#lirik"), channel);
            assert((count == 178), count.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv HOSTTARGET #lirik :chu8 270");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_HOSTSTART), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "lirik"), sender.nickname);
            assert((sender.account == "lirik"), sender.account);
            assert((channel == "#lirik"), channel);
            assert((target.nickname == "chu8"), target.nickname);
            assert((target.account == "chu8"), target.account);
            assert((count == 270), count.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badges=subscriber/3;color=;display-name=asdcassr;emotes=560489:0-6,8-14,16-22,24-30/560510:39-46;id=4d6bbafb-427d-412a-ae24-4426020a1042;mod=0;room-id=23161357;sent-ts=1510059590512;subscriber=1;tmi-sent-ts=1510059591528;turbo=0;user-id=38772474;user-type= :asdcsa!asdcss@asdcsd.tmi.twitch.tv PRIVMSG #lirik :lirikFR lirikFR lirikFR lirikFR :sled: lirikLUL");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "asdcsa"), sender.nickname);
            assert((sender.ident == "asdcss"), sender.ident);
            assert((sender.address == "asdcsd.tmi.twitch.tv"), sender.address);
            assert((sender.account == "asdcsa"), sender.account);
            assert((sender.displayName == "asdcassr"), sender.displayName);
            assert((sender.badges == "subscriber/3"), sender.badges);
            assert((sender.id == 38772474), sender.id.to!string);
            assert((channel == "#lirik"), channel);
            assert((content == "lirikFR lirikFR lirikFR lirikFR :sled: lirikLUL"), content);
            assert((tags == "badges=subscriber/3;color=;display-name=asdcassr;emotes=560489:0-6,8-14,16-22,24-30/560510:39-46;id=4d6bbafb-427d-412a-ae24-4426020a1042;mod=0;room-id=23161357;sent-ts=1510059590512;subscriber=1;tmi-sent-ts=1510059591528;turbo=0;user-id=38772474;user-type="), tags);
            assert((emotes == "560489:0-6,8-14,16-22,24-30/560510:39-46"), emotes);
            assert((id == "4d6bbafb-427d-412a-ae24-4426020a1042"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@broadcaster-lang=;emote-only=0;followers-only=-1;mercury=0;r9k=0;room-id=22216721;slow=0;subs-only=0 :tmi.twitch.tv ROOMSTATE #zorael");
        with (event)
        {
            assert((type == IRCEvent.Type.ROOMSTATE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((channel == "#zorael"), channel);
            assert((aux == "22216721"), aux);
            assert((tags == "broadcaster-lang=;emote-only=0;followers-only=-1;mercury=0;r9k=0;room-id=22216721;slow=0;subs-only=0"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv CAP * LS :twitch.tv/tags twitch.tv/commands twitch.tv/membership");
        with (event)
        {
            assert((type == IRCEvent.Type.CAP), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((content == "twitch.tv/tags twitch.tv/commands twitch.tv/membership"), content);
            assert((aux == "LS"), aux);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv USERSTATE #zorael");
        with (event)
        {
            assert((type == IRCEvent.Type.USERSTATE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((channel == "#zorael"), channel);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv ROOMSTATE #zorael");
        with (event)
        {
            assert((type == IRCEvent.Type.ROOMSTATE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((channel == "#zorael"), channel);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv HOSTTARGET #andymilonakis :zombie_barricades -");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_HOSTSTART), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "andymilonakis"), sender.nickname);
            assert((sender.account == "andymilonakis"), sender.account);
            assert((channel == "#andymilonakis"), channel);
            assert((target.nickname == "zombie_barricades"), target.nickname);
            assert((target.account == "zombie_barricades"), target.account);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv USERNOTICE #drdisrespectlive :ooooo weee, it's a meeeee, Moweee!");
        with (event)
        {
            assert((type == IRCEvent.Type.USERNOTICE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((channel == "#drdisrespectlive"), channel);
            assert((content == "ooooo weee, it's a meeeee, Moweee!"), content);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv USERNOTICE #lirik");
        with (event)
        {
            assert((type == IRCEvent.Type.USERNOTICE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((channel == "#lirik"), channel);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv CLEARCHAT #channel :user");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((channel == "#channel"), channel);
            assert((target.nickname == "user"), target.nickname);
            assert((target.account == "user"), target.account);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv RECONNECT");
        with (event)
        {
            assert((type == IRCEvent.Type.RECONNECT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
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
            assert((sender.account == "kameloso"), sender.account);
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
            assert((sender.account == "kameloso"), sender.account);
            assert((channel == "p4wnyhof"), channel);
        }
    }
}

unittest
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
            assert((sender.nickname == "kungentv"), sender.nickname);
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
            assert((sender.nickname == "asmongold"), sender.nickname);
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
    {
        // @badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#1E90FF;display-name=lil_bytch;emotes=;flags=;id=f9f5c093-ebd3-447b-96f2-64fe94e19c9b;login=lil_bytch;mod=0;msg-id=standardpayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=CoopaManTV;msg-param-prior-gifter-id=444343916;msg-param-prior-gifter-user-name=coopamantv;msg-param-recipient-display-name=Just_Illustrationz;msg-param-recipient-id=236981420;msg-param-recipient-user-name=just_illustrationz;room-id=32787655;subscriber=1;system-msg=lil_bytch\sis\spaying\sforward\sthe\sGift\sthey\sgot\sfrom\sCoopaManTV\sto\sJust_Illustrationz!;tmi-sent-ts=1582159747742;user-id=229842635;user-type= :tmi.twitch.tv USERNOTICE #kitboga
        immutable event = parser.toIRCEvent("@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#1E90FF;display-name=lil_bytch;emotes=;flags=;id=f9f5c093-ebd3-447b-96f2-64fe94e19c9b;login=lil_bytch;mod=0;msg-id=standardpayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=CoopaManTV;msg-param-prior-gifter-id=444343916;msg-param-prior-gifter-user-name=coopamantv;msg-param-recipient-display-name=Just_Illustrationz;msg-param-recipient-id=236981420;msg-param-recipient-user-name=just_illustrationz;room-id=32787655;subscriber=1;system-msg=lil_bytch\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\sCoopaManTV\\sto\\sJust_Illustrationz!;tmi-sent-ts=1582159747742;user-id=229842635;user-type= :tmi.twitch.tv USERNOTICE #kitboga");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_PAYFORWARD), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "lil_bytch"), sender.nickname);
            assert((sender.account == "lil_bytch"), sender.account);
            assert((sender.displayName == "lil_bytch"), sender.displayName);
            assert((sender.badges == "subscriber/0,premium/1"), sender.badges);
            assert((sender.colour == "1E90FF"), sender.colour);
            assert((channel == "#kitboga"), channel);
            assert((target.nickname == "just_illustrationz"), target.nickname);
            assert((target.displayName == "Just_Illustrationz"), target.displayName);
            assert((content == "lil_bytch is paying forward the Gift they got from CoopaManTV to Just_Illustrationz!"), content);
            assert((aux == "coopamantv"), aux);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#1E90FF;display-name=lil_bytch;emotes=;flags=;id=f9f5c093-ebd3-447b-96f2-64fe94e19c9b;login=lil_bytch;mod=0;msg-id=standardpayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=CoopaManTV;msg-param-prior-gifter-id=444343916;msg-param-prior-gifter-user-name=coopamantv;msg-param-recipient-display-name=Just_Illustrationz;msg-param-recipient-id=236981420;msg-param-recipient-user-name=just_illustrationz;room-id=32787655;subscriber=1;system-msg=lil_bytch\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\sCoopaManTV\\sto\\sJust_Illustrationz!;tmi-sent-ts=1582159747742;user-id=229842635;user-type="), tags);
            assert((id == "f9f5c093-ebd3-447b-96f2-64fe94e19c9b"), id);
        }
    }
    {
        // @badge-info=subscriber/1;badges=subscriber/0,premium/1;color=;display-name=havoc_sinz;emotes=;flags=;id=f28a7d4c-5d2a-4182-b9a3-2fbf82eb3883;login=havoc_sinz;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=pytori1;msg-param-prior-gifter-id=35087710;msg-param-prior-gifter-user-name=pytori1;room-id=71190292;subscriber=1;system-msg=havoc_sinz\sis\spaying\sforward\sthe\sGift\sthey\sgot\sfrom\spytori1\sto\sthe\scommunity!;tmi-sent-ts=1582267055759;user-id=223347745;user-type= :tmi.twitch.tv USERNOTICE #trainwreckstv
        immutable event = parser.toIRCEvent("@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=;display-name=havoc_sinz;emotes=;flags=;id=f28a7d4c-5d2a-4182-b9a3-2fbf82eb3883;login=havoc_sinz;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=pytori1;msg-param-prior-gifter-id=35087710;msg-param-prior-gifter-user-name=pytori1;room-id=71190292;subscriber=1;system-msg=havoc_sinz\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\spytori1\\sto\\sthe\\scommunity!;tmi-sent-ts=1582267055759;user-id=223347745;user-type= :tmi.twitch.tv USERNOTICE #trainwreckstv");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_PAYFORWARD), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "havoc_sinz"), sender.nickname);
            assert((sender.account == "havoc_sinz"), sender.account);
            assert((sender.displayName == "havoc_sinz"), sender.displayName);
            assert((sender.badges == "subscriber/0,premium/1"), sender.badges);
            assert((channel == "#trainwreckstv"), channel);
            assert((content == "havoc_sinz is paying forward the Gift they got from pytori1 to the community!"), content);
            assert((aux == "pytori1"), aux);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0,premium/1;color=;display-name=havoc_sinz;emotes=;flags=;id=f28a7d4c-5d2a-4182-b9a3-2fbf82eb3883;login=havoc_sinz;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=pytori1;msg-param-prior-gifter-id=35087710;msg-param-prior-gifter-user-name=pytori1;room-id=71190292;subscriber=1;system-msg=havoc_sinz\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\spytori1\\sto\\sthe\\scommunity!;tmi-sent-ts=1582267055759;user-id=223347745;user-type="), tags);
            assert((id == "f28a7d4c-5d2a-4182-b9a3-2fbf82eb3883"), id);
        }
    }
    {
        // @badge-info=subscriber/19;badges=vip/1,subscriber/12,partner/1;color=#CC0000;display-name=Xari;emotes=;flags=;id=85c3a060-07df-474a-abdc-bae457018dc5;login=xari;mod=0;msg-id=raid;msg-param-displayName=Xari;msg-param-login=xari;msg-param-profileImageURL=https://static-cdn.jtvnw.net/jtv_user_pictures/86214da3-1461-44d1-a2e9-43501af29538-profile_image-70x70.jpeg;msg-param-viewerCount=3322;room-id=147337432;subscriber=1;system-msg=3322\sraiders\sfrom\sXari\shave\sjoined!;tmi-sent-ts=1585054359220;user-id=88301612;user-type= :tmi.twitch.tv USERNOTICE #lestream
        immutable event = parser.toIRCEvent("@badge-info=subscriber/19;badges=vip/1,subscriber/12,partner/1;color=#CC0000;display-name=Xari;emotes=;flags=;id=85c3a060-07df-474a-abdc-bae457018dc5;login=xari;mod=0;msg-id=raid;msg-param-displayName=Xari;msg-param-login=xari;msg-param-profileImageURL=https://static-cdn.jtvnw.net/jtv_user_pictures/86214da3-1461-44d1-a2e9-43501af29538-profile_image-70x70.jpeg;msg-param-viewerCount=3322;room-id=147337432;subscriber=1;system-msg=3322\\sraiders\\sfrom\\sXari\\shave\\sjoined!;tmi-sent-ts=1585054359220;user-id=88301612;user-type= :tmi.twitch.tv USERNOTICE #lestream");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_RAID), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "xari"), sender.nickname);
            assert((sender.account == "xari"), sender.account);
            assert((sender.displayName == "Xari"), sender.displayName);
            assert((sender.badges == "vip/1,subscriber/12,partner/1"), sender.badges);
            assert((sender.colour == "CC0000"), sender.colour);
            assert((channel == "#lestream"), channel);
            assert((content == "3322 raiders from Xari have joined!"), content);
            assert((tags == "badge-info=subscriber/19;badges=vip/1,subscriber/12,partner/1;color=#CC0000;display-name=Xari;emotes=;flags=;id=85c3a060-07df-474a-abdc-bae457018dc5;login=xari;mod=0;msg-id=raid;msg-param-displayName=Xari;msg-param-login=xari;msg-param-profileImageURL=https://static-cdn.jtvnw.net/jtv_user_pictures/86214da3-1461-44d1-a2e9-43501af29538-profile_image-70x70.jpeg;msg-param-viewerCount=3322;room-id=147337432;subscriber=1;system-msg=3322\\sraiders\\sfrom\\sXari\\shave\\sjoined!;tmi-sent-ts=1585054359220;user-id=88301612;user-type="), tags);
            assert((count == 3322), count.to!string);
        }
    }
    {
        // @badge-info=subscriber/8;badges=subscriber/6;color=;display-name=mymii87;emotes=;flags=;id=0ce7f53f-928a-4b71-abe5-e06ff53eb8fe;login=mymii87;mod=0;msg-id=extendsub;msg-param-cumulative-months=8;msg-param-sub-benefit-end-month=4;msg-param-sub-plan=1000;room-id=137687203;subscriber=1;system-msg=mymii87\sextended\stheir\sTier\s1\ssubscription\sthrough\sApril!;tmi-sent-ts=1585061506357;user-id=167733757;user-type= :tmi.twitch.tv USERNOTICE #nokduro
        immutable event = parser.toIRCEvent("@badge-info=subscriber/8;badges=subscriber/6;color=;display-name=mymii87;emotes=;flags=;id=0ce7f53f-928a-4b71-abe5-e06ff53eb8fe;login=mymii87;mod=0;msg-id=extendsub;msg-param-cumulative-months=8;msg-param-sub-benefit-end-month=4;msg-param-sub-plan=1000;room-id=137687203;subscriber=1;system-msg=mymii87\\sextended\\stheir\\sTier\\s1\\ssubscription\\sthrough\\sApril!;tmi-sent-ts=1585061506357;user-id=167733757;user-type= :tmi.twitch.tv USERNOTICE #nokduro");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_EXTENDSUB), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "mymii87"), sender.nickname);
            assert((sender.account == "mymii87"), sender.account);
            assert((sender.displayName == "mymii87"), sender.displayName);
            assert((sender.badges == "subscriber/6"), sender.badges);
            assert((channel == "#nokduro"), channel);
            assert((content == "mymii87 extended their Tier 1 subscription through April!"), content);
            assert((aux == "1000"), aux);
            assert((tags == "badge-info=subscriber/8;badges=subscriber/6;color=;display-name=mymii87;emotes=;flags=;id=0ce7f53f-928a-4b71-abe5-e06ff53eb8fe;login=mymii87;mod=0;msg-id=extendsub;msg-param-cumulative-months=8;msg-param-sub-benefit-end-month=4;msg-param-sub-plan=1000;room-id=137687203;subscriber=1;system-msg=mymii87\\sextended\\stheir\\sTier\\s1\\ssubscription\\sthrough\\sApril!;tmi-sent-ts=1585061506357;user-id=167733757;user-type="), tags);
            assert((count == 4), count.to!string);
            assert((altcount == 8), altcount.to!string);
        }
    }
    {
        // @badge-info=subscriber/28;badges=broadcaster/1,subscriber/12,partner/1;color=#FF0000;display-name=Diegosaurs;emotes=;flags=;id=9ef511d5-b99c-48c5-b32c-d815c66ac6e4;login=diegosaurs;mod=0;msg-id=unraid;room-id=73779954;subscriber=1;system-msg=The\sraid\shas\sbeen\scancelled.;tmi-sent-ts=1585234096906;user-id=73779954;user-type= :tmi.twitch.tv USERNOTICE #diegosaurs
        immutable event = parser.toIRCEvent("@badge-info=subscriber/28;badges=broadcaster/1,subscriber/12,partner/1;color=#FF0000;display-name=Diegosaurs;emotes=;flags=;id=9ef511d5-b99c-48c5-b32c-d815c66ac6e4;login=diegosaurs;mod=0;msg-id=unraid;room-id=73779954;subscriber=1;system-msg=The\\sraid\\shas\\sbeen\\scancelled.;tmi-sent-ts=1585234096906;user-id=73779954;user-type= :tmi.twitch.tv USERNOTICE #diegosaurs");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_UNRAID), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "diegosaurs"), sender.nickname);
            assert((sender.account == "diegosaurs"), sender.account);
            assert((sender.displayName == "Diegosaurs"), sender.displayName);
            assert((sender.badges == "broadcaster/1,subscriber/12,partner/1"), sender.badges);
            assert((sender.colour == "FF0000"), sender.colour);
            assert((channel == "#diegosaurs"), channel);
            assert((content == "The raid has been cancelled."), content);
            assert((tags == "badge-info=subscriber/28;badges=broadcaster/1,subscriber/12,partner/1;color=#FF0000;display-name=Diegosaurs;emotes=;flags=;id=9ef511d5-b99c-48c5-b32c-d815c66ac6e4;login=diegosaurs;mod=0;msg-id=unraid;room-id=73779954;subscriber=1;system-msg=The\\sraid\\shas\\sbeen\\scancelled.;tmi-sent-ts=1585234096906;user-id=73779954;user-type="), tags);
        }
    }
    {
        // @badge-info=subscriber/1;badges=subscriber/0,bits/1000;color=;display-name=High_Depth;emotes=;flags=;id=4ef6d438-dcfc-4435-b63e-730d5c400c10;login=high_depth;mod=0;msg-id=bitsbadgetier;msg-param-threshold=1000;room-id=36769016;subscriber=1;system-msg=bits\sbadge\stier\snotification;tmi-sent-ts=1585240021586;user-id=457965105;user-type= :tmi.twitch.tv USERNOTICE #timthetatman :GG
        immutable event = parser.toIRCEvent("@badge-info=subscriber/1;badges=subscriber/0,bits/1000;color=;display-name=High_Depth;emotes=;flags=;id=4ef6d438-dcfc-4435-b63e-730d5c400c10;login=high_depth;mod=0;msg-id=bitsbadgetier;msg-param-threshold=1000;room-id=36769016;subscriber=1;system-msg=bits\\sbadge\\stier\\snotification;tmi-sent-ts=1585240021586;user-id=457965105;user-type= :tmi.twitch.tv USERNOTICE #timthetatman :GG");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BITSBADGETIER), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "high_depth"), sender.nickname);
            assert((sender.account == "high_depth"), sender.account);
            assert((sender.displayName == "High_Depth"), sender.displayName);
            assert((sender.badges == "subscriber/0,bits/1000"), sender.badges);
            assert((channel == "#timthetatman"), channel);
            assert((content == "GG"), content);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0,bits/1000;color=;display-name=High_Depth;emotes=;flags=;id=4ef6d438-dcfc-4435-b63e-730d5c400c10;login=high_depth;mod=0;msg-id=bitsbadgetier;msg-param-threshold=1000;room-id=36769016;subscriber=1;system-msg=bits\\sbadge\\stier\\snotification;tmi-sent-ts=1585240021586;user-id=457965105;user-type="), tags);
            assert((count == 1000), count.to!string);
        }
    }
    {
        // @badge-info=subscriber/10;badges=subscriber/9,bits/1000;color=;display-name=reykjaviik_;emotes=;flags=;id=efd7886f-45f3-4781-a9aa-dd601fd340eb;login=reykjaviik_;mod=0;msg-id=bitsbadgetier;msg-param-threshold=1000;room-id=181077473;subscriber=1;system-msg=bits\sbadge\stier\snotification;tmi-sent-ts=1585336240505;user-id=248795812;user-type= :tmi.twitch.tv USERNOTICE #gaules :SAFE
        immutable event = parser.toIRCEvent("@badge-info=subscriber/10;badges=subscriber/9,bits/1000;color=;display-name=reykjaviik_;emotes=;flags=;id=efd7886f-45f3-4781-a9aa-dd601fd340eb;login=reykjaviik_;mod=0;msg-id=bitsbadgetier;msg-param-threshold=1000;room-id=181077473;subscriber=1;system-msg=bits\\sbadge\\stier\\snotification;tmi-sent-ts=1585336240505;user-id=248795812;user-type= :tmi.twitch.tv USERNOTICE #gaules :SAFE");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BITSBADGETIER), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "reykjaviik_"), sender.nickname);
            assert((sender.account == "reykjaviik_"), sender.account);
            assert((sender.displayName == "reykjaviik_"), sender.displayName);
            assert((sender.badges == "subscriber/9,bits/1000"), sender.badges);
            assert((channel == "#gaules"), channel);
            assert((content == "SAFE"), content);
            assert((tags == "badge-info=subscriber/10;badges=subscriber/9,bits/1000;color=;display-name=reykjaviik_;emotes=;flags=;id=efd7886f-45f3-4781-a9aa-dd601fd340eb;login=reykjaviik_;mod=0;msg-id=bitsbadgetier;msg-param-threshold=1000;room-id=181077473;subscriber=1;system-msg=bits\\sbadge\\stier\\snotification;tmi-sent-ts=1585336240505;user-id=248795812;user-type="), tags);
            assert((count == 1000), count.to!string);
        }
    }
    {
        // @msg-id=unavailable_command :tmi.twitch.tv NOTICE #zorael :Sorry, "/user" is not available through this client.
        immutable event = parser.toIRCEvent("@msg-id=unavailable_command :tmi.twitch.tv NOTICE #zorael :Sorry, \"/user\" is not available through this client.");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_ERROR), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((channel == "#zorael"), channel);
            assert((content == "Sorry, \"/user\" is not available through this client."), content);
            assert((aux == "unavailable_command"), aux);
            assert((tags == "msg-id=unavailable_command"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent("@msg-id=no_vips :tmi.twitch.tv NOTICE #zorael :This channel does not have any VIPs.");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_NOTICE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((channel == "#zorael"), channel);
            assert((content == "This channel does not have any VIPs."), content);
            assert((aux == "no_vips"), aux);
            assert((tags == "msg-id=no_vips"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=premium/1;color=#00FFAD;display-name=sleepingbeds;emote-only=1;emotes=300787466:0-5,7-12,14-19,21-26,28-33,35-40,42-47,49-54,56-61,63-68,70-75,77-82,84-89,91-96,98-103,105-110,112-117,119-124,126-131,133-138,140-145,147-152,154-159,161-166,168-173,175-180,182-187,189-194,196-201,203-208,210-215,217-222,224-229,231-236,238-243,245-250,252-257,259-264;flags=;id=f9ec222e-1d73-4db4-b67e-3f1857ba204f;mod=0;msg-id=skip-subs-mode-message;room-id=44424631;subscriber=0;tmi-sent-ts=1589991183756;turbo=0;user-id=237489408;user-type= :sleepingbeds!sleepingbeds@sleepingbeds.tmi.twitch.tv PRIVMSG #nickeh30 :gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "sleepingbeds"), sender.nickname);
            assert((sender.ident == "sleepingbeds"), sender.ident);
            assert((sender.address == "sleepingbeds.tmi.twitch.tv"), sender.address);
            assert((sender.account == "sleepingbeds"), sender.account);
            assert((sender.displayName == "sleepingbeds"), sender.displayName);
            assert((sender.badges == "premium/1"), sender.badges);
            assert((sender.colour == "00FFAD"), sender.colour);
            assert((sender.id == 237489408), sender.id.to!string);
            assert((channel == "#nickeh30"), channel);
            assert((content == "gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7 gladd7"), content);
            assert((aux == "skip-subs-mode-message"), aux);
            assert((tags == "badge-info=;badges=premium/1;color=#00FFAD;display-name=sleepingbeds;emote-only=1;emotes=300787466:0-5,7-12,14-19,21-26,28-33,35-40,42-47,49-54,56-61,63-68,70-75,77-82,84-89,91-96,98-103,105-110,112-117,119-124,126-131,133-138,140-145,147-152,154-159,161-166,168-173,175-180,182-187,189-194,196-201,203-208,210-215,217-222,224-229,231-236,238-243,245-250,252-257,259-264;flags=;id=f9ec222e-1d73-4db4-b67e-3f1857ba204f;mod=0;msg-id=skip-subs-mode-message;room-id=44424631;subscriber=0;tmi-sent-ts=1589991183756;turbo=0;user-id=237489408;user-type="), tags);
            assert((emotes == "300787466:0-5,7-12,14-19,21-26,28-33,35-40,42-47,49-54,56-61,63-68,70-75,77-82,84-89,91-96,98-103,105-110,112-117,119-124,126-131,133-138,140-145,147-152,154-159,161-166,168-173,175-180,182-187,189-194,196-201,203-208,210-215,217-222,224-229,231-236,238-243,245-250,252-257,259-264"), emotes);
        }
    }
    {
        // @badge-info=subscriber/4;badges=subscriber/3;client-nonce=354569ede0b9750bdc895a861ddbf341;color=#5F9EA0;display-name=thatgirllalison;emotes=;flags=;id=6ff2d906-536f-4019-9611-cff930d449cb;mod=0;reply-parent-display-name=zenArc;reply-parent-msg-body=she's\sgonna\swin\s2truths\sand\sa\slie\severytime;reply-parent-msg-id=81b6262b-7ce3-4686-be4f-1f5c548c9d16;reply-parent-user-id=50081302;reply-parent-user-login=zenarc;room-id=32393428;subscriber=1;tmi-sent-ts=1597446673211;turbo=0;user-id=525941821;user-type= :thatgirllalison!thatgirllalison@thatgirllalison.tmi.twitch.tv PRIVMSG #sincerelylyn :@zenArc KEKW
        immutable event = parser.toIRCEvent("@badge-info=subscriber/4;badges=subscriber/3;client-nonce=354569ede0b9750bdc895a861ddbf341;color=#5F9EA0;display-name=thatgirllalison;emotes=;flags=;id=6ff2d906-536f-4019-9611-cff930d449cb;mod=0;reply-parent-display-name=zenArc;reply-parent-msg-body=she's\\sgonna\\swin\\s2truths\\sand\\sa\\slie\\severytime;reply-parent-msg-id=81b6262b-7ce3-4686-be4f-1f5c548c9d16;reply-parent-user-id=50081302;reply-parent-user-login=zenarc;room-id=32393428;subscriber=1;tmi-sent-ts=1597446673211;turbo=0;user-id=525941821;user-type= :thatgirllalison!thatgirllalison@thatgirllalison.tmi.twitch.tv PRIVMSG #sincerelylyn :@zenArc KEKW");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "thatgirllalison"), sender.nickname);
            assert((sender.ident == "thatgirllalison"), sender.ident);
            assert((sender.address == "thatgirllalison.tmi.twitch.tv"), sender.address);
            assert((sender.account == "thatgirllalison"), sender.account);
            assert((sender.displayName == "thatgirllalison"), sender.displayName);
            assert((sender.badges == "subscriber/3"), sender.badges);
            assert((sender.colour == "5F9EA0"), sender.colour);
            assert((sender.id == 525941821), sender.id.to!string);
            assert((channel == "#sincerelylyn"), channel);
            assert((target.nickname == "zenarc"), target.nickname);
            assert((target.displayName == "zenArc"), target.displayName);
            assert((target.id == 50081302), target.id.to!string);
            assert((content == "@zenArc KEKW"), content);
            assert((aux == "she's gonna win 2truths and a lie everytime"), aux);
            assert((tags == "badge-info=subscriber/4;badges=subscriber/3;client-nonce=354569ede0b9750bdc895a861ddbf341;color=#5F9EA0;display-name=thatgirllalison;emotes=;flags=;id=6ff2d906-536f-4019-9611-cff930d449cb;mod=0;reply-parent-display-name=zenArc;reply-parent-msg-body=she's\\sgonna\\swin\\s2truths\\sand\\sa\\slie\\severytime;reply-parent-msg-id=81b6262b-7ce3-4686-be4f-1f5c548c9d16;reply-parent-user-id=50081302;reply-parent-user-login=zenarc;room-id=32393428;subscriber=1;tmi-sent-ts=1597446673211;turbo=0;user-id=525941821;user-type="), tags);
            assert((id == "6ff2d906-536f-4019-9611-cff930d449cb"), id);
        }
    }
    {
        // @badge-info=subscriber/8;badges=subscriber/6,bits/100;client-nonce=94d8f991f0ec1dfa346247fcb78c6306;color=#3ED8B3;display-name=zenArc;emotes=301235090:8-11;flags=;id=bb0c7669-7fe9-409d-92e2-29f96cf6b3de;mod=0;reply-parent-display-name=zenArc;reply-parent-msg-body=Ohno\sdid\sthey\schange\sreply?\si\ssee\sit\sagain;reply-parent-msg-id=bc2a2412-356f-4633-aa5b-c85a6ce2906e;reply-parent-user-id=50081302;reply-parent-user-login=zenarc;room-id=32393428;subscriber=1;tmi-sent-ts=1597443237324;turbo=0;user-id=50081302;user-type= :zenarc!zenarc@zenarc.tmi.twitch.tv PRIVMSG #sincerelylyn :@zenArc lynD
        immutable event = parser.toIRCEvent("@badge-info=subscriber/8;badges=subscriber/6,bits/100;client-nonce=94d8f991f0ec1dfa346247fcb78c6306;color=#3ED8B3;display-name=zenArc;emotes=301235090:8-11;flags=;id=bb0c7669-7fe9-409d-92e2-29f96cf6b3de;mod=0;reply-parent-display-name=zenArc;reply-parent-msg-body=Ohno\\sdid\\sthey\\schange\\sreply?\\si\\ssee\\sit\\sagain;reply-parent-msg-id=bc2a2412-356f-4633-aa5b-c85a6ce2906e;reply-parent-user-id=50081302;reply-parent-user-login=zenarc;room-id=32393428;subscriber=1;tmi-sent-ts=1597443237324;turbo=0;user-id=50081302;user-type= :zenarc!zenarc@zenarc.tmi.twitch.tv PRIVMSG #sincerelylyn :@zenArc lynD");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "zenarc"), sender.nickname);
            assert((sender.ident == "zenarc"), sender.ident);
            assert((sender.address == "zenarc.tmi.twitch.tv"), sender.address);
            assert((sender.account == "zenarc"), sender.account);
            assert((sender.displayName == "zenArc"), sender.displayName);
            assert((sender.badges == "subscriber/6,bits/100"), sender.badges);
            assert((sender.colour == "3ED8B3"), sender.colour);
            assert((sender.id == 50081302), sender.id.to!string);
            assert((channel == "#sincerelylyn"), channel);
            assert((target.nickname == "zenarc"), target.nickname);
            assert((target.account == "zenarc"), target.account);
            assert((target.displayName == "zenArc"), target.displayName);
            assert((target.id == 50081302), target.id.to!string);
            assert((content == "@zenArc lynD"), content);
            assert((aux == "Ohno did they change reply? i see it again"), aux);
            assert((tags == "badge-info=subscriber/8;badges=subscriber/6,bits/100;client-nonce=94d8f991f0ec1dfa346247fcb78c6306;color=#3ED8B3;display-name=zenArc;emotes=301235090:8-11;flags=;id=bb0c7669-7fe9-409d-92e2-29f96cf6b3de;mod=0;reply-parent-display-name=zenArc;reply-parent-msg-body=Ohno\\sdid\\sthey\\schange\\sreply?\\si\\ssee\\sit\\sagain;reply-parent-msg-id=bc2a2412-356f-4633-aa5b-c85a6ce2906e;reply-parent-user-id=50081302;reply-parent-user-login=zenarc;room-id=32393428;subscriber=1;tmi-sent-ts=1597443237324;turbo=0;user-id=50081302;user-type="), tags);
            assert((emotes == "301235090:8-11"), emotes);
            assert((id == "bb0c7669-7fe9-409d-92e2-29f96cf6b3de"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=anonymous-cheerer/1;bits=100;color=#8A2BE2;display-name=AnAnonymousCheerer;emotes=;flags=;id=1685dc57-a390-446c-b885-4bdf39c307b9;mod=0;room-id=231070929;subscriber=0;tmi-sent-ts=1597533872078;turbo=0;user-id=407665396;user-type= :ananonymouscheerer!ananonymouscheerer@ananonymouscheerer.tmi.twitch.tv PRIVMSG #hidingkun :Anon100");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_CHEER), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "ananonymouscheerer"), sender.nickname);
            assert((sender.ident == "ananonymouscheerer"), sender.ident);
            assert((sender.address == "ananonymouscheerer.tmi.twitch.tv"), sender.address);
            assert((sender.account == "ananonymouscheerer"), sender.account);
            assert((sender.displayName == "AnAnonymousCheerer"), sender.displayName);
            assert((sender.badges == "anonymous-cheerer/1"), sender.badges);
            assert((sender.colour == "8A2BE2"), sender.colour);
            assert((sender.id == 407665396), sender.id.to!string);
            assert((channel == "#hidingkun"), channel);
            assert((content == "Anon100"), content);
            assert((tags == "badge-info=;badges=anonymous-cheerer/1;bits=100;color=#8A2BE2;display-name=AnAnonymousCheerer;emotes=;flags=;id=1685dc57-a390-446c-b885-4bdf39c307b9;mod=0;room-id=231070929;subscriber=0;tmi-sent-ts=1597533872078;turbo=0;user-id=407665396;user-type="), tags);
            assert((count == 100), count.to!string);
            assert((id == "1685dc57-a390-446c-b885-4bdf39c307b9"), id);
        }
    }
    {
       // @badge-info=subscriber/1;badges=subscriber/0;color=#0000FF;display-name=oYALIYAo;emotes=;flags=;id=92092e7a-c37b-4ad9-b2a7-451f5a8ceca9;login=oyaliyao;mod=0;msg-id=giftpaidupgrade;msg-param-sender-login=hoadone;msg-param-sender-name=HoadOne;room-id=71672341;subscriber=1;system-msg=oYALIYAo\sis\scontinuing\sthe\sGift\sSub\sthey\sgot\sfrom\sHoadOne!;tmi-sent-ts=1597570224001;user-id=467476367;user-type= :tmi.twitch.tv USERNOTICE #p4wnyhof
        immutable event = parser.toIRCEvent("@badge-info=subscriber/1;badges=subscriber/0;color=#0000FF;display-name=oYALIYAo;emotes=;flags=;id=92092e7a-c37b-4ad9-b2a7-451f5a8ceca9;login=oyaliyao;mod=0;msg-id=giftpaidupgrade;msg-param-sender-login=hoadone;msg-param-sender-name=HoadOne;room-id=71672341;subscriber=1;system-msg=oYALIYAo\\sis\\scontinuing\\sthe\\sGift\\sSub\\sthey\\sgot\\sfrom\\sHoadOne!;tmi-sent-ts=1597570224001;user-id=467476367;user-type= :tmi.twitch.tv USERNOTICE #p4wnyhof");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_GIFTCHAIN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "oyaliyao"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "oyaliyao"), sender.account);
            assert((sender.displayName == "oYALIYAo"), sender.displayName);
            assert((sender.badges == "subscriber/0"), sender.badges);
            assert((sender.colour == "0000FF"), sender.colour);
            assert((sender.id == 467476367), sender.id.to!string);
            assert((channel == "#p4wnyhof"), channel);
            assert((target.nickname == "hoadone"), target.nickname);
            assert((target.account == "hoadone"), target.account);
            assert((target.displayName == "HoadOne"), target.displayName);
            assert((content == "oYALIYAo is continuing the Gift Sub they got from HoadOne!"), content);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0;color=#0000FF;display-name=oYALIYAo;emotes=;flags=;id=92092e7a-c37b-4ad9-b2a7-451f5a8ceca9;login=oyaliyao;mod=0;msg-id=giftpaidupgrade;msg-param-sender-login=hoadone;msg-param-sender-name=HoadOne;room-id=71672341;subscriber=1;system-msg=oYALIYAo\\sis\\scontinuing\\sthe\\sGift\\sSub\\sthey\\sgot\\sfrom\\sHoadOne!;tmi-sent-ts=1597570224001;user-id=467476367;user-type="), tags);
            assert((id == "92092e7a-c37b-4ad9-b2a7-451f5a8ceca9"), id);
        }
    }
    {
        // @badge-info=subscriber/1;badges=subscriber/0;color=#0000FF;display-name=oYALIYAo;emotes=;flags=;id=f7339efa-06a5-4708-a1bb-97592158781a;login=oyaliyao;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=HoadOne;msg-param-prior-gifter-id=472732828;msg-param-prior-gifter-user-name=hoadone;room-id=71672341;subscriber=1;system-msg=oYALIYAo\sis\spaying\sforward\sthe\sGift\sthey\sgot\sfrom\sHoadOne\sto\sthe\scommunity!;tmi-sent-ts=1597570304114;user-id=467476367;user-type= :tmi.twitch.tv USERNOTICE #p4wnyhof
        immutable event = parser.toIRCEvent("@badge-info=subscriber/1;badges=subscriber/0;color=#0000FF;display-name=oYALIYAo;emotes=;flags=;id=f7339efa-06a5-4708-a1bb-97592158781a;login=oyaliyao;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=HoadOne;msg-param-prior-gifter-id=472732828;msg-param-prior-gifter-user-name=hoadone;room-id=71672341;subscriber=1;system-msg=oYALIYAo\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\sHoadOne\\sto\\sthe\\scommunity!;tmi-sent-ts=1597570304114;user-id=467476367;user-type= :tmi.twitch.tv USERNOTICE #p4wnyhof");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_PAYFORWARD), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "oyaliyao"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "oyaliyao"), sender.account);
            assert((sender.displayName == "oYALIYAo"), sender.displayName);
            assert((sender.badges == "subscriber/0"), sender.badges);
            assert((sender.colour == "0000FF"), sender.colour);
            assert((sender.id == 467476367), sender.id.to!string);
            assert((channel == "#p4wnyhof"), channel);
            assert((content == "oYALIYAo is paying forward the Gift they got from HoadOne to the community!"), content);
            assert((aux == "hoadone"), aux);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0;color=#0000FF;display-name=oYALIYAo;emotes=;flags=;id=f7339efa-06a5-4708-a1bb-97592158781a;login=oyaliyao;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=HoadOne;msg-param-prior-gifter-id=472732828;msg-param-prior-gifter-user-name=hoadone;room-id=71672341;subscriber=1;system-msg=oYALIYAo\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\sHoadOne\\sto\\sthe\\scommunity!;tmi-sent-ts=1597570304114;user-id=467476367;user-type="), tags);
            assert((id == "f7339efa-06a5-4708-a1bb-97592158781a"), id);
        }
    }
}
