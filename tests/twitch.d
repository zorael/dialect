import lu.conv : Enum, toString;
import dialect;
import std.conv : to;

version(TwitchSupport):

version(BotElements) {}
else
{
    pragma(msg, "Twitch tests require version `BotElements`; skipping");
}

version(BotElements):


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
            assert((aux[0] == "22216721"), aux[0]);
            assert((tags == "broadcaster-lang=;emote-only=0;followers-only=-1;mercury=0;r9k=0;room-id=22216721;slow=0;subs-only=0"), tags);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv CAP * LS :twitch.tv/tags twitch.tv/commands twitch.tv/membership");
        with (event)
        {
            assert((type == IRCEvent.Type.CAP), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((content == "LS"), content);
            assert((aux[0] == "twitch.tv/tags"), aux[0]);
            assert((aux[1] == "twitch.tv/commands"), aux[1]);
            assert((aux[2] == "twitch.tv/membership"), aux[2]);
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
        server.maxNickLength = 25;
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
            assert((target.class_ == IRCUser.Class.unset), Enum!(IRCUser.Class).toString(target.class_));
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
            assert((aux[0] == "color_changed"), aux[0]);
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
            assert((sender.badges == "subscriber/1,premium/1"), sender.badges);
            assert((sender.colour == "7403B4"), sender.colour);
            assert((channel == "#beardageddon"), channel);
            assert((content == "Theres no HWAY"), content);
            assert((aux[0] == "highlighted-message"), aux[0]);
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
            assert((aux[0] == "Prime"), aux[0]);
            assert((tags == `badge-info=subscriber/0;badges=subscriber/0,premium/1;color=#19B336;display-name=IamSlower;emotes=;flags=;id=0a66cc58-57db-4ae6-940d-d46aa315e2d1;login=iamslower;mod=0;msg-id=sub;msg-param-cumulative-months=1;msg-param-months=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=Prime;room-id=69906737;subscriber=1;system-msg=IamSlower\ssubscribed\swith\sTwitch\sPrime.;tmi-sent-ts=1569005836621;user-id=147721858;user-type=`), tags);
            assert((count[1] == 1), count[1].to!string);
            assert((id == "0a66cc58-57db-4ae6-940d-d46aa315e2d1"), id);
        }
    }
    {
        // @badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=f5446beb-bc54-472c-9539-e495a1250a30;login=nappy5074;mod=0;msg-id=subgift;msg-param-months=6;msg-param-origin-id=da\s39\sa3\see\s5e\s6b\s4b\s0d\s32\s55\sbf\sef\s95\s60\s18\s90\saf\sd8\s07\s09;msg-param-recipient-display-name=buffalo_bison;msg-param-recipient-id=141870891;msg-param-recipient-user-name=buffalo_bison;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\sgifted\sa\sTier\s1\ssub\sto\sbuffalo_bison!;tmi-sent-ts=1569005845776;user-id=230054092;user-type= :tmi.twitch.tv USERNOTICE #chocotaco
        enum input = "@badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=f5446beb-bc54-472c-9539-e495a1250a30;login=nappy5074;mod=0;msg-id=subgift;msg-param-months=6;msg-param-origin-id=da\\s39\\sa3\\see\\s5e\\s6b\\s4b\\s0d\\s32\\s55\\sbf\\sef\\s95\\s60\\s18\\s90\\saf\\sd8\\s07\\s09;msg-param-recipient-display-name=buffalo_bison;msg-param-recipient-id=141870891;msg-param-recipient-user-name=buffalo_bison;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sbuffalo_bison!;tmi-sent-ts=1569005845776;user-id=230054092;user-type= :tmi.twitch.tv USERNOTICE #chocotaco";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUBGIFT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "nappy5074"), sender.nickname);
            assert((sender.id == 230054092), sender.id.to!string);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "nappy5074"), sender.account);
            assert((sender.displayName == "nappy5074"), sender.displayName);
            assert((sender.badges == "subscriber/15,sub-gifter/500"), sender.badges);
            assert((sender.colour == "0000FF"), sender.colour);
            assert((channel == "#chocotaco"), channel);
            assert((target.nickname == "buffalo_bison"), target.nickname);
            assert((target.account == "buffalo_bison"), target.account);
            assert((target.displayName == "buffalo_bison"), target.displayName);
            assert((content == "nappy5074 gifted a Tier 1 sub to buffalo_bison!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[2] == "Channel Subscription (chocotaco)"), aux[2]);
            assert((tags == "badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=f5446beb-bc54-472c-9539-e495a1250a30;login=nappy5074;mod=0;msg-id=subgift;msg-param-months=6;msg-param-origin-id=da\\s39\\sa3\\see\\s5e\\s6b\\s4b\\s0d\\s32\\s55\\sbf\\sef\\s95\\s60\\s18\\s90\\saf\\sd8\\s07\\s09;msg-param-recipient-display-name=buffalo_bison;msg-param-recipient-id=141870891;msg-param-recipient-user-name=buffalo_bison;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sbuffalo_bison!;tmi-sent-ts=1569005845776;user-id=230054092;user-type="), tags);
            assert((id == "f5446beb-bc54-472c-9539-e495a1250a30"), id);
        }
    }
    {
        // @badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=d7a1da3b-9ba7-495d-bfd5-9ad4f9f434d2;login=nappy5074;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=20;msg-param-origin-id=ce\s08\s4e\sf5\se9\sf5\s31\s6c\s7a\sb6\sbc\sf9\s71\s8a\sf2\s7f\s90\s4c\s87\s47;msg-param-sender-count=650;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\sis\sgifting\s20\sTier\s1\sSubs\sto\schocoTaco's\scommunity!\sThey've\sgifted\sa\stotal\sof\s650\sin\sthe\schannel!;tmi-sent-ts=1569005843145;user-id=230054092;user-type= :tmi.twitch.tv USERNOTICE #chocotaco
        enum input = "@badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=d7a1da3b-9ba7-495d-bfd5-9ad4f9f434d2;login=nappy5074;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=20;msg-param-origin-id=ce\\s08\\s4e\\sf5\\se9\\sf5\\s31\\s6c\\s7a\\sb6\\sbc\\sf9\\s71\\s8a\\sf2\\s7f\\s90\\s4c\\s87\\s47;msg-param-sender-count=650;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\\sis\\sgifting\\s20\\sTier\\s1\\sSubs\\sto\\schocoTaco's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s650\\sin\\sthe\\schannel!;tmi-sent-ts=1569005843145;user-id=230054092;user-type= :tmi.twitch.tv USERNOTICE #chocotaco";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "nappy5074"), sender.nickname);
            assert((sender.id == 230054092), sender.id.to!string);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "nappy5074"), sender.account);
            assert((sender.displayName == "nappy5074"), sender.displayName);
            assert((sender.badges == "subscriber/15,sub-gifter/500"), sender.badges);
            assert((sender.colour == "0000FF"), sender.colour);
            assert((channel == "#chocotaco"), channel);
            assert((content == "nappy5074 is gifting 20 Tier 1 Subs to chocoTaco's community! They've gifted a total of 650 in the channel!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((tags == "badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=d7a1da3b-9ba7-495d-bfd5-9ad4f9f434d2;login=nappy5074;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=20;msg-param-origin-id=ce\\s08\\s4e\\sf5\\se9\\sf5\\s31\\s6c\\s7a\\sb6\\sbc\\sf9\\s71\\s8a\\sf2\\s7f\\s90\\s4c\\s87\\s47;msg-param-sender-count=650;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\\sis\\sgifting\\s20\\sTier\\s1\\sSubs\\sto\\schocoTaco's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s650\\sin\\sthe\\schannel!;tmi-sent-ts=1569005843145;user-id=230054092;user-type="), tags);
            assert((count[0] == 20), count[0].to!string);
            assert((count[1] == 650), count[1].to!string);
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
            assert((sender.badges == "subscriber/11,premium/1"), sender.badges);
            assert((channel == "#chocotaco"), channel);
            assert((content == "Noahxcite subscribed at Tier 1. They've subscribed for 11 months!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((tags == `badge-info=subscriber/11;badges=subscriber/9,premium/1;color=;display-name=Noahxcite;emotes=;flags=;id=2e7b0dbc-d6be-4331-903b-17255ae57d5b;login=noahxcite;mod=0;msg-id=resub;msg-param-cumulative-months=11;msg-param-months=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=Noahxcite\ssubscribed\sat\sTier\s1.\sThey've\ssubscribed\sfor\s11\smonths!;tmi-sent-ts=1569006106614;user-id=67751309;user-type=`), tags);
            assert((count[1] == 11), count[1].to!string);
            assert((id == "2e7b0dbc-d6be-4331-903b-17255ae57d5b"), id);
        }
    }
    {
        // @badge-info=subscriber/6;badges=subscriber/6,premium/1;color=;display-name=acul1992;emotes=;flags=;id=287de5eb-b93c-4040-86b7-16cddb6cefc8;login=acul1992;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=eb\s39\sea\sd2\sbc\sb4\sd9\sd8\sc9\s51\sd5\s3a\sbb\seb\sd7\s6b\sa8\s2c\sc1\s71;msg-param-sender-count=1;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=acul1992\sis\sgifting\s1\sTier\s1\sSubs\sto\schocoTaco's\scommunity!\sThey've\sgifted\sa\stotal\sof\s1\sin\sthe\schannel!;tmi-sent-ts=1569006134003;user-id=32127247;user-type= :tmi.twitch.tv USERNOTICE #chocotaco
        enum input = "@badge-info=subscriber/6;badges=subscriber/6,premium/1;color=;display-name=acul1992;emotes=;flags=;id=287de5eb-b93c-4040-86b7-16cddb6cefc8;login=acul1992;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=eb\\s39\\sea\\sd2\\sbc\\sb4\\sd9\\sd8\\sc9\\s51\\sd5\\s3a\\sbb\\seb\\sd7\\s6b\\sa8\\s2c\\sc1\\s71;msg-param-sender-count=1;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=acul1992\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\schocoTaco's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s1\\sin\\sthe\\schannel!;tmi-sent-ts=1569006134003;user-id=32127247;user-type= :tmi.twitch.tv USERNOTICE #chocotaco";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "acul1992"), sender.nickname);
            assert((sender.id == 32127247), sender.id.to!string);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "acul1992"), sender.account);
            assert((sender.displayName == "acul1992"), sender.displayName);
            assert((sender.badges == "subscriber/6,premium/1"), sender.badges);
            assert((channel == "#chocotaco"), channel);
            assert((content == "acul1992 is gifting 1 Tier 1 Subs to chocoTaco's community! They've gifted a total of 1 in the channel!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((tags == "badge-info=subscriber/6;badges=subscriber/6,premium/1;color=;display-name=acul1992;emotes=;flags=;id=287de5eb-b93c-4040-86b7-16cddb6cefc8;login=acul1992;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=eb\\s39\\sea\\sd2\\sbc\\sb4\\sd9\\sd8\\sc9\\s51\\sd5\\s3a\\sbb\\seb\\sd7\\s6b\\sa8\\s2c\\sc1\\s71;msg-param-sender-count=1;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=acul1992\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\schocoTaco's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s1\\sin\\sthe\\schannel!;tmi-sent-ts=1569006134003;user-id=32127247;user-type="), tags);
            assert((count[0] == 1), count[0].to!string);
            assert((count[1] == 1), count[1].to!string);
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
            assert((aux[0] == "1000"), aux[0]);
            assert((tags == `badge-info=subscriber/9;badges=subscriber/9,bits/100;color=#2B22B2;display-name=PoggyFifty;emotes=;flags=;id=21bb6867-1e5b-475c-90a4-c21bc5cf42d3;login=poggyfifty;mod=0;msg-id=resub;msg-param-cumulative-months=9;msg-param-months=0;msg-param-should-share-streak=1;msg-param-streak-months=9;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=PoggyFifty\ssubscribed\sat\sTier\s1.\sThey've\ssubscribed\sfor\s9\smonths,\scurrently\son\sa\s9\smonth\sstreak!;tmi-sent-ts=1569006294587;user-id=204550522;user-type=`), tags);
            assert((count[1] == 9), count[1].to!string);
            assert((count[3] == 9), count[3].to!string);
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
            assert((sender.badges == "subscriber/13,twitchconNA2019/1"), sender.badges);
            assert((sender.colour == "0000FF"), sender.colour);
            assert((channel == "#chocotaco"), channel);
            assert((content == "chocotHello Subway100 bonus10 Did you see the chocomerch promo video I made last night??"), content);
            assert((tags == "badge-info=subscriber/13;badges=subscriber/12,twitchconNA2019/1;bits=100;color=#0000FF;display-name=eXpressRR;emotes=757370:0-10;flags=;id=d437ff32-2c98-4c86-b404-85c577e7a63d;mod=0;room-id=69906737;subscriber=1;tmi-sent-ts=1569007507586;turbo=0;user-id=172492216;user-type="), tags);
            assert((count[0] == 100), count[0].to!string);
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
            assert((count[0] == 600), count[0].to!string);
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
            assert((sender.badges == "subscriber/1,premium/1"), sender.badges);
            assert((sender.colour == "9ACD32"), sender.colour);
            assert((channel == "#mithrain"), channel);
            assert((content == "burakk1912 converted from a Twitch Prime sub to a Tier 1 sub!"), content);
            assert((aux[0] == "1000"), aux[0]);
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
            assert((sender.badges == "subscriber/2"), sender.badges);
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
            assert((aux[0] == "@travslaps is new here. Say hello!"), aux[0]);
            assert((tags == "badge-info=;badges=premium/1;color=#67B222;display-name=travslaps;emotes=30259:0-6;flags=;id=a875d520-ba60-4383-925c-4fa09b3fd772;login=travslaps;mod=0;msg-id=ritual;msg-param-ritual-name=new_chatter;room-id=106125347;subscriber=0;system-msg=@travslaps\\sis\\snew\\shere.\\sSay\\shello!;tmi-sent-ts=1569012207274;user-id=183436052;user-type="), tags);
            assert((emotes == "30259:0-6"), emotes);
            assert((id == "a875d520-ba60-4383-925c-4fa09b3fd772"), id);
        }
    }
    {
        // @badge-info=subscriber/15;badges=subscriber/12;color=;display-name=tayk47_mom;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=tayk47_mom;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\s9d\s3e\s68\sca\s26\se9\s2a\s6e\s44\sd4\s60\s9b\s3d\saa\sb9\s4c\sad\s43\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=tayk47_mom\sis\sgifting\s1\sTier\s1\sSubs\sto\sxQcOW's\scommunity!\sThey've\sgifted\sa\stotal\sof\s4\sin\sthe\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type= :tmi.twitch.tv USERNOTICE #xqcow
        enum input = "@badge-info=subscriber/15;badges=subscriber/12;color=;display-name=tayk47_mom;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=tayk47_mom;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\\s9d\\s3e\\s68\\sca\\s26\\se9\\s2a\\s6e\\s44\\sd4\\s60\\s9b\\s3d\\saa\\sb9\\s4c\\sad\\s43\\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=tayk47_mom\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sxQcOW's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s4\\sin\\sthe\\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type= :tmi.twitch.tv USERNOTICE #xqcow";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "tayk47_mom"), sender.nickname);
            assert((sender.id == 224578549), sender.id.to!string);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "tayk47_mom"), sender.account);
            assert((sender.displayName == "tayk47_mom"), sender.displayName);
            assert((sender.badges == "subscriber/15"), sender.badges);
            assert((channel == "#xqcow"), channel);
            assert((content == "tayk47_mom is gifting 1 Tier 1 Subs to xQcOW's community! They've gifted a total of 4 in the channel!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((tags == "badge-info=subscriber/15;badges=subscriber/12;color=;display-name=tayk47_mom;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=tayk47_mom;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\\s9d\\s3e\\s68\\sca\\s26\\se9\\s2a\\s6e\\s44\\sd4\\s60\\s9b\\s3d\\saa\\sb9\\s4c\\sad\\s43\\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=tayk47_mom\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sxQcOW's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s4\\sin\\sthe\\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type="), tags);
            assert((count[0] == 1), count[0].to!string);
            assert((count[1] == 4), count[1].to!string);
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
            assert((aux[0] == "World of Tanks: Care Package"), aux[0]);
            assert((tags == "badge-info=;badges=partner/1;color=#004DFF;display-name=NorddeutscherJunge;emotes=;flags=;id=3ced021d-adab-4278-845d-4c8f2c5d6306;login=norddeutscherjunge;mod=0;msg-id=primecommunitygiftreceived;msg-param-gift-name=World\\sof\\sTanks:\\sCare\\sPackage;msg-param-middle-man=gabepeixe;msg-param-recipient=m4ggusbruno;msg-param-sender=NorddeutscherJunge;room-id=59799994;subscriber=0;system-msg=A\\sviewer\\swas\\sgifted\\sa\\sWorld\\sof\\sTanks:\\sCare\\sPackage,\\scourtesy\\sof\\sa\\sPrime\\smember!;tmi-sent-ts=1570346408346;user-id=39548541;user-type="), tags);
            assert((id == "3ced021d-adab-4278-845d-4c8f2c5d6306"), id);
        }
    }
    {
        // @badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#1E90FF;display-name=lil_bytch;emotes=;flags=;id=f9f5c093-ebd3-447b-96f2-64fe94e19c9b;login=lil_bytch;mod=0;msg-id=standardpayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=CoopaManTV;msg-param-prior-gifter-id=444343916;msg-param-prior-gifter-user-name=coopamantv;msg-param-recipient-display-name=Just_Illustrationz;msg-param-recipient-id=236981420;msg-param-recipient-user-name=just_illustrationz;room-id=32787655;subscriber=1;system-msg=lil_bytch\sis\spaying\sforward\sthe\sGift\sthey\sgot\sfrom\sCoopaManTV\sto\sJust_Illustrationz!;tmi-sent-ts=1582159747742;user-id=229842635;user-type= :tmi.twitch.tv USERNOTICE #kitboga
        enum input = "@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#1E90FF;display-name=lil_bytch;emotes=;flags=;id=f9f5c093-ebd3-447b-96f2-64fe94e19c9b;login=lil_bytch;mod=0;msg-id=standardpayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=CoopaManTV;msg-param-prior-gifter-id=444343916;msg-param-prior-gifter-user-name=coopamantv;msg-param-recipient-display-name=Just_Illustrationz;msg-param-recipient-id=236981420;msg-param-recipient-user-name=just_illustrationz;room-id=32787655;subscriber=1;system-msg=lil_bytch\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\sCoopaManTV\\sto\\sJust_Illustrationz!;tmi-sent-ts=1582159747742;user-id=229842635;user-type= :tmi.twitch.tv USERNOTICE #kitboga";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_PAYFORWARD), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "lil_bytch"), sender.nickname);
            assert((sender.id == 229842635), sender.id.to!string);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "lil_bytch"), sender.account);
            assert((sender.displayName == "lil_bytch"), sender.displayName);
            assert((sender.badges == "subscriber/1,premium/1"), sender.badges);
            assert((sender.colour == "1E90FF"), sender.colour);
            assert((channel == "#kitboga"), channel);
            assert((target.nickname == "just_illustrationz"), target.nickname);
            assert((target.id == 444343916), target.id.to!string);
            assert((target.account == "just_illustrationz"), target.account);
            assert((target.displayName == "Just_Illustrationz"), target.displayName);
            assert((content == "lil_bytch is paying forward the Gift they got from CoopaManTV to Just_Illustrationz!"), content);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#1E90FF;display-name=lil_bytch;emotes=;flags=;id=f9f5c093-ebd3-447b-96f2-64fe94e19c9b;login=lil_bytch;mod=0;msg-id=standardpayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=CoopaManTV;msg-param-prior-gifter-id=444343916;msg-param-prior-gifter-user-name=coopamantv;msg-param-recipient-display-name=Just_Illustrationz;msg-param-recipient-id=236981420;msg-param-recipient-user-name=just_illustrationz;room-id=32787655;subscriber=1;system-msg=lil_bytch\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\sCoopaManTV\\sto\\sJust_Illustrationz!;tmi-sent-ts=1582159747742;user-id=229842635;user-type="), tags);
            assert((id == "f9f5c093-ebd3-447b-96f2-64fe94e19c9b"), id);
        }
    }
    {
        // @badge-info=subscriber/1;badges=subscriber/0,premium/1;color=;display-name=havoc_sinz;emotes=;flags=;id=f28a7d4c-5d2a-4182-b9a3-2fbf82eb3883;login=havoc_sinz;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=pytori1;msg-param-prior-gifter-id=35087710;msg-param-prior-gifter-user-name=pytori1;room-id=71190292;subscriber=1;system-msg=havoc_sinz\sis\spaying\sforward\sthe\sGift\sthey\sgot\sfrom\spytori1\sto\sthe\scommunity!;tmi-sent-ts=1582267055759;user-id=223347745;user-type= :tmi.twitch.tv USERNOTICE #trainwreckstv
        enum input = "@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=;display-name=havoc_sinz;emotes=;flags=;id=f28a7d4c-5d2a-4182-b9a3-2fbf82eb3883;login=havoc_sinz;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=pytori1;msg-param-prior-gifter-id=35087710;msg-param-prior-gifter-user-name=pytori1;room-id=71190292;subscriber=1;system-msg=havoc_sinz\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\spytori1\\sto\\sthe\\scommunity!;tmi-sent-ts=1582267055759;user-id=223347745;user-type= :tmi.twitch.tv USERNOTICE #trainwreckstv";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_PAYFORWARD), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "havoc_sinz"), sender.nickname);
            assert((sender.id == 223347745), sender.id.to!string);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "havoc_sinz"), sender.account);
            assert((sender.displayName == "havoc_sinz"), sender.displayName);
            assert((sender.badges == "subscriber/1,premium/1"), sender.badges);
            assert((channel == "#trainwreckstv"), channel);
            assert((target.nickname == "pytori1"), target.nickname);
            assert((target.id == 35087710), target.id.to!string);
            assert((target.account == "pytori1"), target.account);
            assert((target.displayName == "pytori1"), target.displayName);
            assert((content == "havoc_sinz is paying forward the Gift they got from pytori1 to the community!"), content);
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
            assert((sender.badges == "subscriber/19,vip/1,partner/1"), sender.badges);
            assert((sender.colour == "CC0000"), sender.colour);
            assert((channel == "#lestream"), channel);
            assert((content == "3322 raiders from Xari have joined!"), content);
            assert((tags == "badge-info=subscriber/19;badges=vip/1,subscriber/12,partner/1;color=#CC0000;display-name=Xari;emotes=;flags=;id=85c3a060-07df-474a-abdc-bae457018dc5;login=xari;mod=0;msg-id=raid;msg-param-displayName=Xari;msg-param-login=xari;msg-param-profileImageURL=https://static-cdn.jtvnw.net/jtv_user_pictures/86214da3-1461-44d1-a2e9-43501af29538-profile_image-70x70.jpeg;msg-param-viewerCount=3322;room-id=147337432;subscriber=1;system-msg=3322\\sraiders\\sfrom\\sXari\\shave\\sjoined!;tmi-sent-ts=1585054359220;user-id=88301612;user-type="), tags);
            assert((count[0] == 3322), count[0].to!string);
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
            assert((sender.badges == "subscriber/8"), sender.badges);
            assert((channel == "#nokduro"), channel);
            assert((content == "mymii87 extended their Tier 1 subscription through April!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((tags == "badge-info=subscriber/8;badges=subscriber/6;color=;display-name=mymii87;emotes=;flags=;id=0ce7f53f-928a-4b71-abe5-e06ff53eb8fe;login=mymii87;mod=0;msg-id=extendsub;msg-param-cumulative-months=8;msg-param-sub-benefit-end-month=4;msg-param-sub-plan=1000;room-id=137687203;subscriber=1;system-msg=mymii87\\sextended\\stheir\\sTier\\s1\\ssubscription\\sthrough\\sApril!;tmi-sent-ts=1585061506357;user-id=167733757;user-type="), tags);
            assert((count[0] == 4), count[0].to!string);
            assert((count[1] == 8), count[1].to!string);
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
            assert((sender.badges == "subscriber/28,broadcaster/1,partner/1"), sender.badges);
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
            assert((sender.badges == "subscriber/1,bits/1000"), sender.badges);
            assert((channel == "#timthetatman"), channel);
            assert((content == "GG"), content);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0,bits/1000;color=;display-name=High_Depth;emotes=;flags=;id=4ef6d438-dcfc-4435-b63e-730d5c400c10;login=high_depth;mod=0;msg-id=bitsbadgetier;msg-param-threshold=1000;room-id=36769016;subscriber=1;system-msg=bits\\sbadge\\stier\\snotification;tmi-sent-ts=1585240021586;user-id=457965105;user-type="), tags);
            assert((count[0] == 1000), count[0].to!string);
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
            assert((sender.badges == "subscriber/10,bits/1000"), sender.badges);
            assert((channel == "#gaules"), channel);
            assert((content == "SAFE"), content);
            assert((tags == "badge-info=subscriber/10;badges=subscriber/9,bits/1000;color=;display-name=reykjaviik_;emotes=;flags=;id=efd7886f-45f3-4781-a9aa-dd601fd340eb;login=reykjaviik_;mod=0;msg-id=bitsbadgetier;msg-param-threshold=1000;room-id=181077473;subscriber=1;system-msg=bits\\sbadge\\stier\\snotification;tmi-sent-ts=1585336240505;user-id=248795812;user-type="), tags);
            assert((count[0] == 1000), count[0].to!string);
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
            assert((aux[0] == "unavailable_command"), aux[0]);
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
            assert((aux[0] == "no_vips"), aux[0]);
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
            assert((aux[0] == "skip-subs-mode-message"), aux[0]);
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
            assert((sender.badges == "subscriber/4"), sender.badges);
            assert((sender.colour == "5F9EA0"), sender.colour);
            assert((sender.id == 525941821), sender.id.to!string);
            assert((channel == "#sincerelylyn"), channel);
            assert((target.nickname == "zenarc"), target.nickname);
            assert((target.displayName == "zenArc"), target.displayName);
            assert((target.id == 50081302), target.id.to!string);
            assert((content == "@zenArc KEKW"), content);
            assert((aux[0] == "she's gonna win 2truths and a lie everytime"), aux[0]);
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
            assert((sender.badges == "subscriber/8,bits/100"), sender.badges);
            assert((sender.colour == "3ED8B3"), sender.colour);
            assert((sender.id == 50081302), sender.id.to!string);
            assert((channel == "#sincerelylyn"), channel);
            assert((target.nickname == "zenarc"), target.nickname);
            assert((target.account == "zenarc"), target.account);
            assert((target.displayName == "zenArc"), target.displayName);
            assert((target.id == 50081302), target.id.to!string);
            assert((content == "@zenArc lynD"), content);
            assert((aux[0] == "Ohno did they change reply? i see it again"), aux[0]);
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
            assert((count[0] == 100), count[0].to!string);
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
            assert((sender.badges == "subscriber/1"), sender.badges);
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
        enum input = "@badge-info=subscriber/1;badges=subscriber/0;color=#0000FF;display-name=oYALIYAo;emotes=;flags=;id=f7339efa-06a5-4708-a1bb-97592158781a;login=oyaliyao;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=HoadOne;msg-param-prior-gifter-id=472732828;msg-param-prior-gifter-user-name=hoadone;room-id=71672341;subscriber=1;system-msg=oYALIYAo\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\sHoadOne\\sto\\sthe\\scommunity!;tmi-sent-ts=1597570304114;user-id=467476367;user-type= :tmi.twitch.tv USERNOTICE #p4wnyhof";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_PAYFORWARD), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "oyaliyao"), sender.nickname);
            assert((sender.id == 467476367), sender.id.to!string);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "oyaliyao"), sender.account);
            assert((sender.displayName == "oYALIYAo"), sender.displayName);
            assert((sender.badges == "subscriber/1"), sender.badges);
            assert((sender.colour == "0000FF"), sender.colour);
            assert((channel == "#p4wnyhof"), channel);
            assert((target.nickname == "hoadone"), target.nickname);
            assert((target.id == 472732828), target.id.to!string);
            assert((target.account == "hoadone"), target.account);
            assert((target.displayName == "HoadOne"), target.displayName);
            assert((content == "oYALIYAo is paying forward the Gift they got from HoadOne to the community!"), content);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0;color=#0000FF;display-name=oYALIYAo;emotes=;flags=;id=f7339efa-06a5-4708-a1bb-97592158781a;login=oyaliyao;mod=0;msg-id=communitypayforward;msg-param-prior-gifter-anonymous=false;msg-param-prior-gifter-display-name=HoadOne;msg-param-prior-gifter-id=472732828;msg-param-prior-gifter-user-name=hoadone;room-id=71672341;subscriber=1;system-msg=oYALIYAo\\sis\\spaying\\sforward\\sthe\\sGift\\sthey\\sgot\\sfrom\\sHoadOne\\sto\\sthe\\scommunity!;tmi-sent-ts=1597570304114;user-id=467476367;user-type="), tags);
            assert((id == "f7339efa-06a5-4708-a1bb-97592158781a"), id);
        }
    }
    {
        // @badge-info=;badges=;color=#1E90FF;display-name=Shaezonai;emotes=;flags=;id=094ae469-6827-4d80-a689-dd1b4a33ba69;login=shaezonai;mod=0;msg-id=rewardgift;msg-param-domain=hyperscape_megacommerce;msg-param-selected-count=5;msg-param-total-reward-count=5;msg-param-trigger-amount=1;msg-param-trigger-type=SUBGIFT;room-id=22510310;subscriber=0;system-msg=Shaezonai's\sGift\sshared\srewards\sto\s5\sothers\sin\sChat!;tmi-sent-ts=1597689523398;user-id=30175011;user-type= :tmi.twitch.tv USERNOTICE #gamesdonequick
        immutable event = parser.toIRCEvent("@badge-info=;badges=;color=#1E90FF;display-name=Shaezonai;emotes=;flags=;id=094ae469-6827-4d80-a689-dd1b4a33ba69;login=shaezonai;mod=0;msg-id=rewardgift;msg-param-domain=hyperscape_megacommerce;msg-param-selected-count=5;msg-param-total-reward-count=5;msg-param-trigger-amount=1;msg-param-trigger-type=SUBGIFT;room-id=22510310;subscriber=0;system-msg=Shaezonai's\\sGift\\sshared\\srewards\\sto\\s5\\sothers\\sin\\sChat!;tmi-sent-ts=1597689523398;user-id=30175011;user-type= :tmi.twitch.tv USERNOTICE #gamesdonequick");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_REWARDGIFT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "shaezonai"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "shaezonai"), sender.account);
            assert((sender.displayName == "Shaezonai"), sender.displayName);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.colour == "1E90FF"), sender.colour);
            assert((sender.id == 30175011), sender.id.to!string);
            assert((channel == "#gamesdonequick"), channel);
            assert((content == "Shaezonai's Gift shared rewards to 5 others in Chat!"), content);
            assert((aux[0] == "SUBGIFT"), aux[0]);
            assert((tags == "badge-info=;badges=;color=#1E90FF;display-name=Shaezonai;emotes=;flags=;id=094ae469-6827-4d80-a689-dd1b4a33ba69;login=shaezonai;mod=0;msg-id=rewardgift;msg-param-domain=hyperscape_megacommerce;msg-param-selected-count=5;msg-param-total-reward-count=5;msg-param-trigger-amount=1;msg-param-trigger-type=SUBGIFT;room-id=22510310;subscriber=0;system-msg=Shaezonai's\\sGift\\sshared\\srewards\\sto\\s5\\sothers\\sin\\sChat!;tmi-sent-ts=1597689523398;user-id=30175011;user-type="), tags);
            assert((count[1] == 5), count[1].to!string);
            assert((id == "094ae469-6827-4d80-a689-dd1b4a33ba69"), id);
        }
    }
    {
        enum input = r"@badge-info=subscriber/1;badges=subscriber/0,bits/1000;color=;display-name=multibatteri;emotes=;flags=;id=e2901dc8-b247-4aaa-8ff2-78e4e472c3a8;login=multibatteri;mod=0;msg-id=rewardgift;msg-param-domain=hyperscape_megacommerce;msg-param-selected-count=25;msg-param-total-reward-count=25;msg-param-trigger-amount=1000;msg-param-trigger-type=CHEER;room-id=22510310;subscriber=1;system-msg=multibatteri's\sCheer\sshared\srewards\sto\s25\sothers\sin\sChat!;tmi-sent-ts=1597689117752;user-id=492403027;user-type= :tmi.twitch.tv USERNOTICE #gamesdonequick";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_REWARDGIFT), type.toString());
            assert((sender.nickname == "multibatteri"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "multibatteri"), sender.account);
            assert((sender.displayName == "multibatteri"), sender.displayName);
            assert((sender.badges == "subscriber/1,bits/1000"), sender.badges);
            assert((sender.id == 492403027), sender.id.to!string);
            assert((channel == "#gamesdonequick"), channel);
            assert((content == "multibatteri's Cheer shared rewards to 25 others in Chat!"), content);
            assert((aux[0] == "CHEER"), aux[0]);
            assert((aux[1] == "hyperscape_megacommerce"), aux[1]);
            assert((count[1] == 25), count[1].to!string);
            assert((count[2] == 1000), count[2].to!string);
            assert((count[3] == 25), count[3].to!string);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0,bits/1000;color=;display-name=multibatteri;emotes=;flags=;id=e2901dc8-b247-4aaa-8ff2-78e4e472c3a8;login=multibatteri;mod=0;msg-id=rewardgift;msg-param-domain=hyperscape_megacommerce;msg-param-selected-count=25;msg-param-total-reward-count=25;msg-param-trigger-amount=1000;msg-param-trigger-type=CHEER;room-id=22510310;subscriber=1;system-msg=multibatteri's\\sCheer\\sshared\\srewards\\sto\\s25\\sothers\\sin\\sChat!;tmi-sent-ts=1597689117752;user-id=492403027;user-type="), tags);
            assert((id == "e2901dc8-b247-4aaa-8ff2-78e4e472c3a8"), id);
        }
    }
    {
        enum input = r"@badge-info=subscriber/3;badges=subscriber/3;color=;display-name=poome;emotes=;flags=;id=8670eeb3-9cf3-4d80-934a-34a0cdc52a76;login=poome;mod=0;msg-id=resub;msg-param-anon-gift=false;msg-param-cumulative-months=3;msg-param-gift-month-being-redeemed=3;msg-param-gift-months=3;msg-param-gifter-id=125181523;msg-param-gifter-login=alaynars;msg-param-gifter-name=alaynars;msg-param-months=0;msg-param-should-share-streak=1;msg-param-streak-months=3;msg-param-sub-plan-name=Channel\sSubscription\s(xqcow);msg-param-sub-plan=1000;msg-param-was-gifted=true;room-id=71092938;subscriber=1;system-msg=poome\ssubscribed\sat\sTier\s1.\sThey've\ssubscribed\sfor\s3\smonths,\scurrently\son\sa\s3\smonth\sstreak!;tmi-sent-ts=1599278081397;user-id=141120106;user-type= :tmi.twitch.tv USERNOTICE #xqcow :WELCOME TO THE JUNGLE Pog";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUB), type.toString());
            assert((sender.nickname == "poome"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "poome"), sender.account);
            assert((sender.displayName == "poome"), sender.displayName);
            assert((sender.badges == "subscriber/3"), sender.badges);
            assert((sender.id == 141120106), sender.id.to!string);
            assert((target.nickname == "alaynars"), target.nickname);
            assert((target.account == "alaynars"), target.account);
            assert((target.displayName == "alaynars"), target.displayName);
            assert((target.id == 125181523), target.id.to!string);
            assert((channel == "#xqcow"), channel);
            assert((content == "WELCOME TO THE JUNGLE Pog"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[2] == "Channel Subscription (xqcow)"), aux[2]);
            assert((count[0] == 3), count[0].to!string);
            assert((count[1] == 3), count[1].to!string);
            assert((count[2] == 3), count[2].to!string);
            assert((count[3] == 3), count[3].to!string);
            assert((count[7] == 1), count[7].to!string);
            assert((tags == "badge-info=subscriber/3;badges=subscriber/3;color=;display-name=poome;emotes=;flags=;id=8670eeb3-9cf3-4d80-934a-34a0cdc52a76;login=poome;mod=0;msg-id=resub;msg-param-anon-gift=false;msg-param-cumulative-months=3;msg-param-gift-month-being-redeemed=3;msg-param-gift-months=3;msg-param-gifter-id=125181523;msg-param-gifter-login=alaynars;msg-param-gifter-name=alaynars;msg-param-months=0;msg-param-should-share-streak=1;msg-param-streak-months=3;msg-param-sub-plan-name=Channel\\sSubscription\\s(xqcow);msg-param-sub-plan=1000;msg-param-was-gifted=true;room-id=71092938;subscriber=1;system-msg=poome\\ssubscribed\\sat\\sTier\\s1.\\sThey've\\ssubscribed\\sfor\\s3\\smonths,\\scurrently\\son\\sa\\s3\\smonth\\sstreak!;tmi-sent-ts=1599278081397;user-id=141120106;user-type="), tags);
            assert((id == "8670eeb3-9cf3-4d80-934a-34a0cdc52a76"), id);
        }
    }
    {
        enum input = r"@badge-info=subscriber/0;badges=subscriber/0,premium/1;color=;display-name=rockoleitor_;emotes=;flags=;id=00433938-cf6b-4435-b427-bc160ccc6a2c;login=rockoleitor_;mod=0;msg-id=sub;msg-param-cumulative-months=1;msg-param-months=0;msg-param-multimonth-duration=0;msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Entrar\sal\scentro\sPOWER\sRANGER\s(bruno_pro21);msg-param-sub-plan=Prime;msg-param-was-gifted=false;room-id=94757023;subscriber=1;system-msg=rockoleitor_\ssubscribed\swith\sTwitch\sPrime.;tmi-sent-ts=1601499733907;user-id=513875830;user-type= :tmi.twitch.tv USERNOTICE #brunenge";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUB), type.toString());
            assert((sender.nickname == "rockoleitor_"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "rockoleitor_"), sender.account);
            assert((sender.displayName == "rockoleitor_"), sender.displayName);
            assert((sender.badges == "subscriber/0,premium/1"), sender.badges);
            assert((sender.id == 513875830), sender.id.to!string);
            assert((channel == "#brunenge"), channel);
            assert((content == "rockoleitor_ subscribed with Twitch Prime."), content);
            assert((aux[0] == "Prime"), aux[0]);
            assert((aux[2] == "Entrar al centro POWER RANGER (bruno_pro21)"), aux[2]);
            assert((count[1] == 1), count[1].to!string);
            assert((tags == "badge-info=subscriber/0;badges=subscriber/0,premium/1;color=;display-name=rockoleitor_;emotes=;flags=;id=00433938-cf6b-4435-b427-bc160ccc6a2c;login=rockoleitor_;mod=0;msg-id=sub;msg-param-cumulative-months=1;msg-param-months=0;msg-param-multimonth-duration=0;msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Entrar\\sal\\scentro\\sPOWER\\sRANGER\\s(bruno_pro21);msg-param-sub-plan=Prime;msg-param-was-gifted=false;room-id=94757023;subscriber=1;system-msg=rockoleitor_\\ssubscribed\\swith\\sTwitch\\sPrime.;tmi-sent-ts=1601499733907;user-id=513875830;user-type="), tags);
            assert((id == "00433938-cf6b-4435-b427-bc160ccc6a2c"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=;color=;custom-reward-id=;display-name=weirdhistory;emotes=;flags=43-46:P.5;id=ea4fae82-d0af-42c1-9990-eff1e40d0816;mod=0;msg-id=;room-id=118170488;subscriber=0;tmi-sent-ts=1605883972498;turbo=0;user-id=424874845;user-type= :weirdhistory!weirdhistory@weirdhistory.tmi.twitch.tv PRIVMSG #epicenter_en1 :Zyori is more and more prettier day by day wtff");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "weirdhistory"), sender.nickname);
            assert((sender.ident == "weirdhistory"), sender.ident);
            assert((sender.address == "weirdhistory.tmi.twitch.tv"), sender.address);
            assert((sender.account == "weirdhistory"), sender.account);
            assert((sender.displayName == "weirdhistory"), sender.displayName);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.id == 424874845), sender.id.to!string);
            assert((channel == "#epicenter_en1"), channel);
            assert((content == "Zyori is more and more prettier day by day wtff"), content);
            assert((tags == "badge-info=;badges=;color=;custom-reward-id=;display-name=weirdhistory;emotes=;flags=43-46:P.5;id=ea4fae82-d0af-42c1-9990-eff1e40d0816;mod=0;msg-id=;room-id=118170488;subscriber=0;tmi-sent-ts=1605883972498;turbo=0;user-id=424874845;user-type="), tags);
            assert((id == "ea4fae82-d0af-42c1-9990-eff1e40d0816"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=;color=;custom-reward-id=;display-name=kabiznal003;emotes=;flags=32-35:S.5;id=bd21ac26-6468-44e8-a119-754c2f21a748;mod=0;msg-id=;room-id=100814397;subscriber=0;tmi-sent-ts=1605887439126;turbo=0;user-id=127958974;user-type= :kabiznal003!kabiznal003@kabiznal003.tmi.twitch.tv PRIVMSG #dota2ruhub :@beermonsterdota Аххаха чел это рофл))");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "kabiznal003"), sender.nickname);
            assert((sender.ident == "kabiznal003"), sender.ident);
            assert((sender.address == "kabiznal003.tmi.twitch.tv"), sender.address);
            assert((sender.account == "kabiznal003"), sender.account);
            assert((sender.displayName == "kabiznal003"), sender.displayName);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.id == 127958974), sender.id.to!string);
            assert((channel == "#dota2ruhub"), channel);
            assert((content == "@beermonsterdota Аххаха чел это рофл))"), content);
            assert((tags == "badge-info=;badges=;color=;custom-reward-id=;display-name=kabiznal003;emotes=;flags=32-35:S.5;id=bd21ac26-6468-44e8-a119-754c2f21a748;mod=0;msg-id=;room-id=100814397;subscriber=0;tmi-sent-ts=1605887439126;turbo=0;user-id=127958974;user-type="), tags);
            assert((id == "bd21ac26-6468-44e8-a119-754c2f21a748"), id);
        }
    }
    {
        enum input = r"@badge-info=subscriber/22;badges=subscriber/12,bits/1000;color=#008000;display-name=ithinkican;emotes=;flags=;id=9ece0157-f458-4e5a-b314-e0bb1674bc2f;login=ithinkican;mod=0;msg-id=submysterygift;msg-param-gift-theme=party;msg-param-mass-gift-count=5;msg-param-origin-id=74\s74\s42\s57\scd\sc4\sf7\s8c\se8\s67\s36\sf3\s43\s29\s8c\s8c\sd1\s61\sbe\s0b;msg-param-sender-count=5;msg-param-sub-plan=1000;room-id=23936415;subscriber=1;system-msg=ithinkican\sis\sgifting\s5\sTier\s1\sSubs\sto\sJerma985's\scommunity!\sThey've\sgifted\sa\stotal\sof\s5\sin\sthe\schannel!;tmi-sent-ts=1629502318806;user-id=471292233;user-type= :tmi.twitch.tv USERNOTICE #jerma985";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), type.toString());
            assert((sender.nickname == "ithinkican"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "ithinkican"), sender.account);
            assert((sender.displayName == "ithinkican"), sender.displayName);
            assert((sender.badges == "subscriber/22,bits/1000"), sender.badges);
            assert((sender.colour == "008000"), sender.colour);
            assert((sender.id == 471292233), sender.id.to!string);
            assert((channel == "#jerma985"), channel);
            assert((content == "ithinkican is gifting 5 Tier 1 Subs to Jerma985's community! They've gifted a total of 5 in the channel!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[4] == "party"), aux[4]);
            assert((count[0] == 5), count[0].to!string);
            assert((count[1] == 5), count[1].to!string);
            assert((tags == "badge-info=subscriber/22;badges=subscriber/12,bits/1000;color=#008000;display-name=ithinkican;emotes=;flags=;id=9ece0157-f458-4e5a-b314-e0bb1674bc2f;login=ithinkican;mod=0;msg-id=submysterygift;msg-param-gift-theme=party;msg-param-mass-gift-count=5;msg-param-origin-id=74\\s74\\s42\\s57\\scd\\sc4\\sf7\\s8c\\se8\\s67\\s36\\sf3\\s43\\s29\\s8c\\s8c\\sd1\\s61\\sbe\\s0b;msg-param-sender-count=5;msg-param-sub-plan=1000;room-id=23936415;subscriber=1;system-msg=ithinkican\\sis\\sgifting\\s5\\sTier\\s1\\sSubs\\sto\\sJerma985's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s5\\sin\\sthe\\schannel!;tmi-sent-ts=1629502318806;user-id=471292233;user-type="), tags);
            assert((id == "9ece0157-f458-4e5a-b314-e0bb1674bc2f"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=;client-nonce=15e0e0fcd371976418dbcf8a729e538a;color=#FF10B8;crowd-chant-parent-msg-id=d85e2b19-7199-4a41-88eb-c763938db2a4;display-name=prtzl_;emotes=;flags=;id=b21bffad-aed3-4906-a83c-2d84eb6888db;mod=0;room-id=23936415;subscriber=0;tmi-sent-ts=1629584274262;turbo=0;user-id=169018557;user-type= :prtzl_!prtzl_@prtzl_.tmi.twitch.tv PRIVMSG #jerma985 :You're doing alright there buddy peepoHappy");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "prtzl_"), sender.nickname);
            assert((sender.ident == "prtzl_"), sender.ident);
            assert((sender.address == "prtzl_.tmi.twitch.tv"), sender.address);
            assert((sender.account == "prtzl_"), sender.account);
            assert((sender.displayName == "prtzl_"), sender.displayName);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.colour == "FF10B8"), sender.colour);
            assert((sender.id == 169018557), sender.id.to!string);
            assert((channel == "#jerma985"), channel);
            assert((content == "You're doing alright there buddy peepoHappy"), content);
            assert((tags == "badge-info=;badges=;client-nonce=15e0e0fcd371976418dbcf8a729e538a;color=#FF10B8;crowd-chant-parent-msg-id=d85e2b19-7199-4a41-88eb-c763938db2a4;display-name=prtzl_;emotes=;flags=;id=b21bffad-aed3-4906-a83c-2d84eb6888db;mod=0;room-id=23936415;subscriber=0;tmi-sent-ts=1629584274262;turbo=0;user-id=169018557;user-type="), tags);
            assert((id == "b21bffad-aed3-4906-a83c-2d84eb6888db"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=subscriber/14;badges=moderator/1,subscriber/3012;color=#DAA520;display-name=gizmozgamer;emotes=;first-msg=0;flags=;id=cfad3699-6d3b-4bbd-8e58-0f1561778b22;mod=1;msg-id=crowd-chant;room-id=156037856;subscriber=1;tmi-sent-ts=1639141977565;turbo=0;user-id=589846663;user-type=mod :gizmozgamer!gizmozgamer@gizmozgamer.tmi.twitch.tv PRIVMSG #fextralife :Clap Clap FeelsBirthdayMan");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_CROWDCHANT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "gizmozgamer"), sender.nickname);
            assert((sender.ident == "gizmozgamer"), sender.ident);
            assert((sender.address == "gizmozgamer.tmi.twitch.tv"), sender.address);
            assert((sender.account == "gizmozgamer"), sender.account);
            assert((sender.displayName == "gizmozgamer"), sender.displayName);
            assert((sender.badges == "subscriber/14,moderator/1"), sender.badges);
            assert((sender.colour == "DAA520"), sender.colour);
            assert((sender.id == 589846663), sender.id.to!string);
            assert((channel == "#fextralife"), channel);
            assert((content == "Clap Clap FeelsBirthdayMan"), content);
            assert((tags == "badge-info=subscriber/14;badges=moderator/1,subscriber/3012;color=#DAA520;display-name=gizmozgamer;emotes=;first-msg=0;flags=;id=cfad3699-6d3b-4bbd-8e58-0f1561778b22;mod=1;msg-id=crowd-chant;room-id=156037856;subscriber=1;tmi-sent-ts=1639141977565;turbo=0;user-id=589846663;user-type=mod"), tags);
        }
    }
    {
        enum input = r"@badge-info=;badges=premium/1;color=;display-name=starblazers;emotes=;flags=;id=550d0b45-dee7-4fa4-9910-7ad1003f0d79;login=starblazers;mod=0;msg-id=sub;msg-param-cumulative-months=1;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=902;msg-param-goal-description=Lali-this\sis\sa\sgoal-ho;msg-param-goal-target-contributions=600;msg-param-goal-user-contributions=1;msg-param-months=0;msg-param-multimonth-duration=0;msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\sSubscription\s(mousierl);msg-param-sub-plan=Prime;msg-param-was-gifted=false;room-id=46969360;subscriber=1;system-msg=starblazers\ssubscribed\swith\sPrime.;tmi-sent-ts=1644090143655;user-id=48760906;user-type= :tmi.twitch.tv USERNOTICE #mousie";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUB), type.toString());
            assert((sender.nickname == "starblazers"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "starblazers"), sender.account);
            assert((sender.displayName == "starblazers"), sender.displayName);
            assert((sender.badges == "premium/1"), sender.badges);
            assert((sender.id == 48760906), sender.id.to!string);
            assert((channel == "#mousie"), channel);
            assert((content == "starblazers subscribed with Prime."), content);
            assert((aux[0] == "Prime"), aux[0]);
            assert((aux[2] == "Channel Subscription (mousierl)"), aux[2]);
            assert((aux[3] == "Lali-this is a goal-ho"), aux[3]);
            assert((aux[5] == "SUB_POINTS"), aux[5]);
            assert((count[1] == 1), count[1].to!string);
            assert((count[2] == 600), count[2].to!string);
            assert((count[3] == 902), count[3].to!string);
            assert((count[4] == 1), count[4].to!string);
            assert((tags == "badge-info=;badges=premium/1;color=;display-name=starblazers;emotes=;flags=;id=550d0b45-dee7-4fa4-9910-7ad1003f0d79;login=starblazers;mod=0;msg-id=sub;msg-param-cumulative-months=1;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=902;msg-param-goal-description=Lali-this\\sis\\sa\\sgoal-ho;msg-param-goal-target-contributions=600;msg-param-goal-user-contributions=1;msg-param-months=0;msg-param-multimonth-duration=0;msg-param-multimonth-tenure=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(mousierl);msg-param-sub-plan=Prime;msg-param-was-gifted=false;room-id=46969360;subscriber=1;system-msg=starblazers\\ssubscribed\\swith\\sPrime.;tmi-sent-ts=1644090143655;user-id=48760906;user-type="), tags);
            assert((id == "550d0b45-dee7-4fa4-9910-7ad1003f0d79"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=broadcaster/1;color=#5F9EA0;display-name=zorael;emotes=;flags=;id=d312a414-a1d3-45b1-abd1-2b3b11b65eb7;login=zorael;mod=0;msg-id=announcement;msg-param-color=PURPLE;room-id=22216721;subscriber=0;system-msg=;tmi-sent-ts=1648851705977;user-id=22216721;user-type= :tmi.twitch.tv USERNOTICE #zorael :this is a test announcement");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_ANNOUNCEMENT), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "zorael"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "zorael"), sender.account);
            assert((sender.displayName == "zorael"), sender.displayName);
            assert((sender.badges == "broadcaster/1"), sender.badges);
            assert((sender.colour == "5F9EA0"), sender.colour);
            assert((sender.id == 22216721), sender.id.to!string);
            assert((channel == "#zorael"), channel);
            assert((content == "this is a test announcement"), content);
            assert((aux[0] == "PURPLE"), aux[0]);
            assert((tags == "badge-info=;badges=broadcaster/1;color=#5F9EA0;display-name=zorael;emotes=;flags=;id=d312a414-a1d3-45b1-abd1-2b3b11b65eb7;login=zorael;mod=0;msg-id=announcement;msg-param-color=PURPLE;room-id=22216721;subscriber=0;system-msg=;tmi-sent-ts=1648851705977;user-id=22216721;user-type="), tags);
            assert((id == "d312a414-a1d3-45b1-abd1-2b3b11b65eb7"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent(":tmi.twitch.tv 421 kamelosobot ZORAEL!ZORAEL@TMI.TWITCH.TV PRIVMSG #ZORAEL :HELLO :Unknown command");
        with (event)
        {
            assert((type == IRCEvent.Type.ERR_UNKNOWNCOMMAND), Enum!(IRCEvent.Type).toString(type));
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((content == "Unknown command"), content);
            assert((aux[0] == "ZORAEL!ZORAEL@TMI.TWITCH.TV PRIVMSG #ZORAEL :HELLO"), aux[0]);
            assert((num == 421), num.to!string);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=subscriber/7;badges=subscriber/6;client-nonce=fc6c123438b3a146a8a6683af5bbb94e;color=#1E90FF;display-name=LonesomeWalker91;emotes=;first-msg=0;flags=;id=1799090a-f43f-4078-a547-d2008552d2d2;mod=0;returning-chatter=0;room-id=22510310;subscriber=1;tmi-sent-ts=1656536970406;turbo=0;user-id=149935854;user-type= :lonesomewalker91!lonesomewalker91@lonesomewalker91.tmi.twitch.tv PRIVMSG #gamesdonequick :take BULBA!");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "lonesomewalker91"), sender.nickname);
            assert((sender.ident == "lonesomewalker91"), sender.ident);
            assert((sender.address == "lonesomewalker91.tmi.twitch.tv"), sender.address);
            assert((sender.account == "lonesomewalker91"), sender.account);
            assert((sender.displayName == "LonesomeWalker91"), sender.displayName);
            assert((sender.badges == "subscriber/7"), sender.badges);
            assert((sender.colour == "1E90FF"), sender.colour);
            assert((sender.id == 149935854), sender.id.to!string);
            assert((channel == "#gamesdonequick"), channel);
            assert((content == "take BULBA!"), content);
            assert((tags == "badge-info=subscriber/7;badges=subscriber/6;client-nonce=fc6c123438b3a146a8a6683af5bbb94e;color=#1E90FF;display-name=LonesomeWalker91;emotes=;first-msg=0;flags=;id=1799090a-f43f-4078-a547-d2008552d2d2;mod=0;returning-chatter=0;room-id=22510310;subscriber=1;tmi-sent-ts=1656536970406;turbo=0;user-id=149935854;user-type="), tags);
            assert((id == "1799090a-f43f-4078-a547-d2008552d2d2"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=subscriber/39;badges=vip/1,subscriber/36,partner/1;client-nonce=fb285f92d8391e2d192e7e6fc7c65cae;color=;display-name=bacter1a_;emotes=;first-msg=0;flags=;id=cba41a74-9335-4bd5-bb95-a9467187c221;mod=0;returning-chatter=0;room-id=49207184;subscriber=1;tmi-sent-ts=1661079096568;turbo=0;user-id=28510438;user-type=;vip=1 :bacter1a_!bacter1a_@bacter1a_.tmi.twitch.tv PRIVMSG #fps_shaka :content");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "bacter1a_"), sender.nickname);
            assert((sender.ident == "bacter1a_"), sender.ident);
            assert((sender.address == "bacter1a_.tmi.twitch.tv"), sender.address);
            assert((sender.account == "bacter1a_"), sender.account);
            assert((sender.displayName == "bacter1a_"), sender.displayName);
            assert((sender.badges == "subscriber/39,vip/1,partner/1"), sender.badges);
            assert((sender.id == 28510438), sender.id.to!string);
            assert((channel == "#fps_shaka"), channel);
            assert((content == "content"), content);
            assert((tags == "badge-info=subscriber/39;badges=vip/1,subscriber/36,partner/1;client-nonce=fb285f92d8391e2d192e7e6fc7c65cae;color=;display-name=bacter1a_;emotes=;first-msg=0;flags=;id=cba41a74-9335-4bd5-bb95-a9467187c221;mod=0;returning-chatter=0;room-id=49207184;subscriber=1;tmi-sent-ts=1661079096568;turbo=0;user-id=28510438;user-type=;vip=1"), tags);
            assert((id == "cba41a74-9335-4bd5-bb95-a9467187c221"), id);
        }
    }
    {
        enum input = r"@badge-info=subscriber/30;badges=subscriber/30,premium/1;color=#00FF7F;display-name=SilvergunRP;emotes=;flags=;id=8071df4a-29c7-4fe2-867e-7558a9e4efb0;login=silvergunrp;mod=0;msg-id=midnightsquid;msg-param-amount=600;msg-param-currency=BRL;msg-param-emote-id=emotesv2_4c4b1157b8d34edba9bcb0aa8198197f;msg-param-exponent=2;msg-param-is-highlighted=false;msg-param-pill-type=Success;room-id=181077473;subscriber=1;system-msg=SilvergunRP\sCheered\swith\sR$6.00;tmi-sent-ts=1665339696298;user-id=238696431;user-type= :tmi.twitch.tv USERNOTICE #gaules";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_DIRECTCHEER), type.toString());
            assert((sender.nickname == "silvergunrp"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "silvergunrp"), sender.account);
            assert((sender.displayName == "SilvergunRP"), sender.displayName);
            assert((sender.badges == "subscriber/30,premium/1"), sender.badges);
            assert((sender.colour == "00FF7F"), sender.colour);
            assert((sender.id == 238696431), sender.id.to!string);
            assert((channel == "#gaules"), channel);
            assert((content == "SilvergunRP Cheered with R$6.00"), content);
            assert((aux[0] == "BRL"), aux[0]);
            assert((aux[1] == "midnightsquid"), aux[1]);
            assert((aux[3] == "Success"), aux[3]);
            assert((aux[4] == "false"), aux[4]);
            assert((count[0] == 600), count[0].to!string);
            assert((tags == "badge-info=subscriber/30;badges=subscriber/30,premium/1;color=#00FF7F;display-name=SilvergunRP;emotes=;flags=;id=8071df4a-29c7-4fe2-867e-7558a9e4efb0;login=silvergunrp;mod=0;msg-id=midnightsquid;msg-param-amount=600;msg-param-currency=BRL;msg-param-emote-id=emotesv2_4c4b1157b8d34edba9bcb0aa8198197f;msg-param-exponent=2;msg-param-is-highlighted=false;msg-param-pill-type=Success;room-id=181077473;subscriber=1;system-msg=SilvergunRP\\sCheered\\swith\\sR$6.00;tmi-sent-ts=1665339696298;user-id=238696431;user-type="), tags);
            assert((id == "8071df4a-29c7-4fe2-867e-7558a9e4efb0"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=glhf-pledge/1;color=#FF69B4;display-name=bethiehem;emotes=;first-msg=0;flags=;id=2ff6d2fb-7a9a-47f3-b64a-01b9abf08765;mod=0;pinned-chat-paid-amount=500;pinned-chat-paid-canonical-amount=5;pinned-chat-paid-currency=USD;pinned-chat-paid-exponent=2;returning-chatter=0;room-id=125387632;subscriber=0;tmi-sent-ts=1665358650971;turbo=0;user-id=478167598;user-type= :bethiehem!bethiehem@bethiehem.tmi.twitch.tv PRIVMSG #amouranth :Can we get a L for the camera guy pls?");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "bethiehem"), sender.nickname);
            assert((sender.ident == "bethiehem"), sender.ident);
            assert((sender.address == "bethiehem.tmi.twitch.tv"), sender.address);
            assert((sender.account == "bethiehem"), sender.account);
            assert((sender.displayName == "bethiehem"), sender.displayName);
            assert((sender.badges == "glhf-pledge/1"), sender.badges);
            assert((sender.colour == "FF69B4"), sender.colour);
            assert((sender.id == 478167598), sender.id.to!string);
            assert((channel == "#amouranth"), channel);
            assert((content == "Can we get a L for the camera guy pls?"), content);
            assert((aux[1] == "USD"), aux[1]);
            assert((tags == "badge-info=;badges=glhf-pledge/1;color=#FF69B4;display-name=bethiehem;emotes=;first-msg=0;flags=;id=2ff6d2fb-7a9a-47f3-b64a-01b9abf08765;mod=0;pinned-chat-paid-amount=500;pinned-chat-paid-canonical-amount=5;pinned-chat-paid-currency=USD;pinned-chat-paid-exponent=2;returning-chatter=0;room-id=125387632;subscriber=0;tmi-sent-ts=1665358650971;turbo=0;user-id=478167598;user-type="), tags);
            assert((count[0] == 500), count[0].to!string);
            assert((id == "2ff6d2fb-7a9a-47f3-b64a-01b9abf08765"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=;color=#D2691E;display-name=Simon_Afflerbach;emotes=;first-msg=1;flags=;id=03c13cd4-225c-4f0c-b85c-6c3a74446f31;mod=0;msg-id=user-intro;returning-chatter=0;room-id=148651829;subscriber=0;tmi-sent-ts=1674068404074;turbo=0;user-id=46140936;user-type= :simon_afflerbach!simon_afflerbach@simon_afflerbach.tmi.twitch.tv PRIVMSG #ginomachino :yo this is much coller with actual music");
        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_INTRO), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "simon_afflerbach"), sender.nickname);
            assert((sender.ident == "simon_afflerbach"), sender.ident);
            assert((sender.address == "simon_afflerbach.tmi.twitch.tv"), sender.address);
            assert((sender.account == "simon_afflerbach"), sender.account);
            assert((sender.displayName == "Simon_Afflerbach"), sender.displayName);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.colour == "D2691E"), sender.colour);
            assert((sender.id == 46140936), sender.id.to!string);
            assert((channel == "#ginomachino"), channel);
            assert((content == "yo this is much coller with actual music"), content);
            assert((tags == "badge-info=;badges=;color=#D2691E;display-name=Simon_Afflerbach;emotes=;first-msg=1;flags=;id=03c13cd4-225c-4f0c-b85c-6c3a74446f31;mod=0;msg-id=user-intro;returning-chatter=0;room-id=148651829;subscriber=0;tmi-sent-ts=1674068404074;turbo=0;user-id=46140936;user-type="), tags);
            assert((id == "03c13cd4-225c-4f0c-b85c-6c3a74446f31"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=;color=;display-name=AnAnonymousGifter;emotes=;flags=;id=01af180f-5efd-40c8-94fb-d0a346c7be86;login=ananonymousgifter;mod=0;msg-id=subgift;msg-param-fun-string=FunStringFour;msg-param-gift-months=1;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=15624;msg-param-goal-target-contributions=20000;msg-param-goal-user-contributions=1;msg-param-months=24;msg-param-origin-id=54\s41\s9a\s69\s6c\sb4\s3c\s8b\s0b\se4\sdf\s4c\sba\s5b\s9b\s23\s4c\sa7\s9b\sc4;msg-param-recipient-display-name=niku4949;msg-param-recipient-id=547206601;msg-param-recipient-user-name=niku4949;msg-param-sub-plan-name=Channel\sSubscription\s(fps_shaka);msg-param-sub-plan=1000;room-id=49207184;subscriber=0;system-msg=An\sanonymous\suser\sgifted\sa\sTier\s1\ssub\sto\sniku4949!\s;tmi-sent-ts=1685982143345;user-id=274598607;user-type= :tmi.twitch.tv USERNOTICE #fps_shaka";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUBGIFT), type.toString());
            assert((sender.nickname == "ananonymousgifter"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "ananonymousgifter"), sender.account);
            assert((sender.displayName == "AnAnonymousGifter"), sender.displayName);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.id == 274598607), sender.id.to!string);
            assert((target.nickname == "niku4949"), target.nickname);
            assert((target.account == "niku4949"), target.account);
            assert((target.displayName == "niku4949"), target.displayName);
            assert((channel == "#fps_shaka"), channel);
            assert((content == "An anonymous user gifted a Tier 1 sub to niku4949!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[1] == "FunStringFour"), aux[1]);
            assert((aux[2] == "Channel Subscription (fps_shaka)"), aux[2]);
            assert((aux[5] == "SUB_POINTS"), aux[5]);
            assert((count[0] == 1), count[0].to!string);
            assert((count[2] == 20000), count[2].to!string);
            assert((count[3] == 15624), count[3].to!string);
            assert((count[4] == 1), count[4].to!string);
            assert((tags == "badge-info=;badges=;color=;display-name=AnAnonymousGifter;emotes=;flags=;id=01af180f-5efd-40c8-94fb-d0a346c7be86;login=ananonymousgifter;mod=0;msg-id=subgift;msg-param-fun-string=FunStringFour;msg-param-gift-months=1;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=15624;msg-param-goal-target-contributions=20000;msg-param-goal-user-contributions=1;msg-param-months=24;msg-param-origin-id=54\\s41\\s9a\\s69\\s6c\\sb4\\s3c\\s8b\\s0b\\se4\\sdf\\s4c\\sba\\s5b\\s9b\\s23\\s4c\\sa7\\s9b\\sc4;msg-param-recipient-display-name=niku4949;msg-param-recipient-id=547206601;msg-param-recipient-user-name=niku4949;msg-param-sub-plan-name=Channel\\sSubscription\\s(fps_shaka);msg-param-sub-plan=1000;room-id=49207184;subscriber=0;system-msg=An\\sanonymous\\suser\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sniku4949!\\s;tmi-sent-ts=1685982143345;user-id=274598607;user-type="), tags);
            assert((id == "01af180f-5efd-40c8-94fb-d0a346c7be86"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=;color=;display-name=AnAnonymousGifter;emotes=;flags=;id=7c1a48d9-f74f-468e-9019-730a5934e636;login=ananonymousgifter;mod=0;msg-id=subgift;msg-param-fun-string=FunStringOne;msg-param-gift-months=1;msg-param-gift-theme=lul;msg-param-months=1;msg-param-origin-id=ca\s71\s60\sb3\sa1\s8a\s8a\sbe\se9\s92\s8e\s6b\s99\s87\s1f\s71\s43\sf8\scf\s2d;msg-param-recipient-display-name=SpecterCRP;msg-param-recipient-id=48357366;msg-param-recipient-user-name=spectercrp;msg-param-sub-plan-name=FextraLITE;msg-param-sub-plan=1000;room-id=156037856;subscriber=0;system-msg=An\sanonymous\suser\sgifted\sa\sTier\s1\ssub\sto\sSpecterCRP!\s;tmi-sent-ts=1686025729209;user-id=274598607;user-type= :tmi.twitch.tv USERNOTICE #fextralife";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUBGIFT), type.toString());
            assert((sender.nickname == "ananonymousgifter"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "ananonymousgifter"), sender.account);
            assert((sender.displayName == "AnAnonymousGifter"), sender.displayName);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.id == 274598607), sender.id.to!string);
            assert((target.nickname == "spectercrp"), target.nickname);
            assert((target.account == "spectercrp"), target.account);
            assert((target.displayName == "SpecterCRP"), target.displayName);
            assert((channel == "#fextralife"), channel);
            assert((content == "An anonymous user gifted a Tier 1 sub to SpecterCRP!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[1] == "FunStringOne"), aux[1]);
            assert((aux[2] == "FextraLITE"), aux[2]);
            assert((aux[4] == "lul"), aux[4]);
            assert((count[0] == 1), count[0].to!string);
            assert((tags == "badge-info=;badges=;color=;display-name=AnAnonymousGifter;emotes=;flags=;id=7c1a48d9-f74f-468e-9019-730a5934e636;login=ananonymousgifter;mod=0;msg-id=subgift;msg-param-fun-string=FunStringOne;msg-param-gift-months=1;msg-param-gift-theme=lul;msg-param-months=1;msg-param-origin-id=ca\\s71\\s60\\sb3\\sa1\\s8a\\s8a\\sbe\\se9\\s92\\s8e\\s6b\\s99\\s87\\s1f\\s71\\s43\\sf8\\scf\\s2d;msg-param-recipient-display-name=SpecterCRP;msg-param-recipient-id=48357366;msg-param-recipient-user-name=spectercrp;msg-param-sub-plan-name=FextraLITE;msg-param-sub-plan=1000;room-id=156037856;subscriber=0;system-msg=An\\sanonymous\\suser\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sSpecterCRP!\\s;tmi-sent-ts=1686025729209;user-id=274598607;user-type="), tags);
            assert((id == "7c1a48d9-f74f-468e-9019-730a5934e636"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=;color=;display-name=AnAnonymousGifter;emotes=;flags=;id=0f0f82ae-0ab1-4a0d-a5b5-edfacc05db7e;login=ananonymousgifter;mod=0;msg-id=subgift;msg-param-fun-string=FunStringThree;msg-param-gift-months=1;msg-param-gift-theme=showlove;msg-param-months=1;msg-param-origin-id=23\s9d\sea\sda\s41\s08\s0e\s3b\se8\s85\scb\s5e\s90\sc8\se6\sd7\s86\se0\s6f\sd0;msg-param-recipient-display-name=apeguard;msg-param-recipient-id=503002485;msg-param-recipient-user-name=apeguard;msg-param-sub-plan-name=FextraLITE;msg-param-sub-plan=1000;room-id=156037856;subscriber=0;system-msg=An\sanonymous\suser\sgifted\sa\sTier\s1\ssub\sto\sapeguard!\s;tmi-sent-ts=1687139215919;user-id=274598607;user-type= :tmi.twitch.tv USERNOTICE #fextralife";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUBGIFT), type.toString());
            assert((sender.nickname == "ananonymousgifter"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "ananonymousgifter"), sender.account);
            assert((sender.displayName == "AnAnonymousGifter"), sender.displayName);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.id == 274598607), sender.id.to!string);
            assert((target.nickname == "apeguard"), target.nickname);
            assert((target.account == "apeguard"), target.account);
            assert((target.displayName == "apeguard"), target.displayName);
            assert((channel == "#fextralife"), channel);
            assert((content == "An anonymous user gifted a Tier 1 sub to apeguard!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[1] == "FunStringThree"), aux[1]);
            assert((aux[2] == "FextraLITE"), aux[2]);
            assert((aux[4] == "showlove"), aux[4]);
            assert((count[0] == 1), count[0].to!string);
            assert((tags == "badge-info=;badges=;color=;display-name=AnAnonymousGifter;emotes=;flags=;id=0f0f82ae-0ab1-4a0d-a5b5-edfacc05db7e;login=ananonymousgifter;mod=0;msg-id=subgift;msg-param-fun-string=FunStringThree;msg-param-gift-months=1;msg-param-gift-theme=showlove;msg-param-months=1;msg-param-origin-id=23\\s9d\\sea\\sda\\s41\\s08\\s0e\\s3b\\se8\\s85\\scb\\s5e\\s90\\sc8\\se6\\sd7\\s86\\se0\\s6f\\sd0;msg-param-recipient-display-name=apeguard;msg-param-recipient-id=503002485;msg-param-recipient-user-name=apeguard;msg-param-sub-plan-name=FextraLITE;msg-param-sub-plan=1000;room-id=156037856;subscriber=0;system-msg=An\\sanonymous\\suser\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sapeguard!\\s;tmi-sent-ts=1687139215919;user-id=274598607;user-type="), tags);
            assert((id == "0f0f82ae-0ab1-4a0d-a5b5-edfacc05db7e"), id);
        }
    }
    {
        enum input = r"@badge-info=subscriber/32;badges=subscriber/30,premium/1;client-nonce=4d9124729220070c5eeb6bd4811e59b3;color=#00FF1F;display-name=creaturesfan72;emotes=;first-msg=0;flags=26-33:A.3/P.3;id=bb439115-71b1-4aa5-820d-8180adf69625;mod=0;reply-parent-display-name=Garvickian;reply-parent-msg-body=THEY\sARE\sGASLIGHTING\sYOU\s@xqc\sTHEY\sARE\sGASLIGHTING\sYOU\s@xqc\sTHEY\sARE\sGASLIGHTING\sYOU\s@xqc\sTHEY\sARE\sGASLIGHTING\sYOU\s@xqc\sTHEY\sARE\sGASLIGHTING\sYOU\s@xqc;reply-parent-msg-id=9859b5a0-4b05-4053-979a-9965bafd5707;reply-parent-user-id=152126453;reply-parent-user-login=garvickian;reply-thread-parent-msg-id=9859b5a0-4b05-4053-979a-9965bafd5707;reply-thread-parent-user-login=garvickian;returning-chatter=0;room-id=71092938;subscriber=1;tmi-sent-ts=1687307715366;turbo=0;user-id=32291538;user-type= :creaturesfan72!creaturesfan72@creaturesfan72.tmi.twitch.tv PRIVMSG #xqc :@Garvickian no they arent dumbass, he used dogwhistling incorrectly";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), type.toString());
            assert((sender.nickname == "creaturesfan72"), sender.nickname);
            assert((sender.ident == "creaturesfan72"), sender.ident);
            assert((sender.address == "creaturesfan72.tmi.twitch.tv"), sender.address);
            assert((sender.account == "creaturesfan72"), sender.account);
            assert((sender.displayName == "creaturesfan72"), sender.displayName);
            assert((sender.badges == "subscriber/32,premium/1"), sender.badges);
            assert((sender.colour == "00FF1F"), sender.colour);
            assert((sender.id == 32291538), sender.id.to!string);
            assert((target.nickname == "garvickian"), target.nickname);
            assert((target.account == "garvickian"), target.account);
            assert((target.displayName == "Garvickian"), target.displayName);
            assert((target.id == 152126453), target.id.to!string);
            assert((channel == "#xqc"), channel);
            assert((content == "@Garvickian no they arent dumbass, he used dogwhistling incorrectly"), content);
            assert((aux[0] == "THEY ARE GASLIGHTING YOU @xqc THEY ARE GASLIGHTING YOU @xqc THEY ARE GASLIGHTING YOU @xqc THEY ARE GASLIGHTING YOU @xqc THEY ARE GASLIGHTING YOU @xqc"), aux[0]);
            assert((tags == "badge-info=subscriber/32;badges=subscriber/30,premium/1;client-nonce=4d9124729220070c5eeb6bd4811e59b3;color=#00FF1F;display-name=creaturesfan72;emotes=;first-msg=0;flags=26-33:A.3/P.3;id=bb439115-71b1-4aa5-820d-8180adf69625;mod=0;reply-parent-display-name=Garvickian;reply-parent-msg-body=THEY\\sARE\\sGASLIGHTING\\sYOU\\s@xqc\\sTHEY\\sARE\\sGASLIGHTING\\sYOU\\s@xqc\\sTHEY\\sARE\\sGASLIGHTING\\sYOU\\s@xqc\\sTHEY\\sARE\\sGASLIGHTING\\sYOU\\s@xqc\\sTHEY\\sARE\\sGASLIGHTING\\sYOU\\s@xqc;reply-parent-msg-id=9859b5a0-4b05-4053-979a-9965bafd5707;reply-parent-user-id=152126453;reply-parent-user-login=garvickian;reply-thread-parent-msg-id=9859b5a0-4b05-4053-979a-9965bafd5707;reply-thread-parent-user-login=garvickian;returning-chatter=0;room-id=71092938;subscriber=1;tmi-sent-ts=1687307715366;turbo=0;user-id=32291538;user-type="), tags);
            assert((id == "bb439115-71b1-4aa5-820d-8180adf69625"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=;badges=bits/25000;color=#00E2E4;display-name=OdraNet;emotes=;first-msg=0;flags=;id=5de67699-6441-4aa5-acd7-40106aeb9b78;mod=0;pinned-chat-paid-amount=120;pinned-chat-paid-canonical-amount=120;pinned-chat-paid-currency=EUR;pinned-chat-paid-exponent=2;pinned-chat-paid-is-system-message=1;pinned-chat-paid-level=ONE;returning-chatter=0;room-id=156037856;subscriber=0;tmi-sent-ts=1687507212838;turbo=0;user-id=265430223;user-type= :odranet!odranet@odranet.tmi.twitch.tv PRIVMSG #fextralife :User sent Hype Chat");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "odranet"), sender.nickname);
            assert((sender.id == 265430223), sender.id.to!string);
            assert((sender.ident == "odranet"), sender.ident);
            assert((sender.address == "odranet.tmi.twitch.tv"), sender.address);
            assert((sender.account == "odranet"), sender.account);
            assert((sender.displayName == "OdraNet"), sender.displayName);
            assert((sender.badges == "bits/25000"), sender.badges);
            assert((sender.colour == "00E2E4"), sender.colour);
            assert((channel == "#fextralife"), channel);
            assert((content == "User sent Hype Chat"), content);
            assert((aux[1] == "EUR"), aux[1]);
            assert((aux[2] == "ONE"), aux[2]);
            assert((tags == "badge-info=;badges=bits/25000;color=#00E2E4;display-name=OdraNet;emotes=;first-msg=0;flags=;id=5de67699-6441-4aa5-acd7-40106aeb9b78;mod=0;pinned-chat-paid-amount=120;pinned-chat-paid-canonical-amount=120;pinned-chat-paid-currency=EUR;pinned-chat-paid-exponent=2;pinned-chat-paid-is-system-message=1;pinned-chat-paid-level=ONE;returning-chatter=0;room-id=156037856;subscriber=0;tmi-sent-ts=1687507212838;turbo=0;user-id=265430223;user-type="), tags);
            assert((count[0] == 120), count[0].to!string);
            assert((count[1] == 120), count[1].to!string);
            assert((count[2] == 2), count[2].to!string);
            assert((id == "5de67699-6441-4aa5-acd7-40106aeb9b78"), id);
        }
    }
    {
        enum input = r"@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#9ACD32;display-name=ch0senpotato;emotes=;flags=;id=0fabf780-4c25-4b2a-84ad-16a79a828d61;login=ch0senpotato;mod=0;msg-id=submysterygift;msg-param-community-gift-id=3310941710135024083;msg-param-mass-gift-count=1;msg-param-origin-id=3310941710135024083;msg-param-sender-count=1;msg-param-sub-plan=1000;room-id=28640725;subscriber=1;system-msg=ch0senpotato\sis\sgifting\s1\sTier\s1\sSubs\sto\sLobosJr's\scommunity!\sThey've\sgifted\sa\stotal\sof\s1\sin\sthe\schannel!;tmi-sent-ts=1700079134099;user-id=249069270;user-type=;vip=0 :tmi.twitch.tv USERNOTICE #lobosjr";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), type.toString());
            assert((sender.nickname == "ch0senpotato"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "ch0senpotato"), sender.account);
            assert((sender.displayName == "ch0senpotato"), sender.displayName);
            assert((sender.badges == "subscriber/1,premium/1"), sender.badges);
            assert((sender.colour == "9ACD32"), sender.colour);
            assert((sender.id == 249069270), sender.id.to!string);
            assert((channel == "#lobosjr"), channel);
            assert((content == "ch0senpotato is gifting 1 Tier 1 Subs to LobosJr's community! They've gifted a total of 1 in the channel!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((count[0] == 1), count[0].to!string);
            assert((count[1] == 1), count[1].to!string);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#9ACD32;display-name=ch0senpotato;emotes=;flags=;id=0fabf780-4c25-4b2a-84ad-16a79a828d61;login=ch0senpotato;mod=0;msg-id=submysterygift;msg-param-community-gift-id=3310941710135024083;msg-param-mass-gift-count=1;msg-param-origin-id=3310941710135024083;msg-param-sender-count=1;msg-param-sub-plan=1000;room-id=28640725;subscriber=1;system-msg=ch0senpotato\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sLobosJr's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s1\\sin\\sthe\\schannel!;tmi-sent-ts=1700079134099;user-id=249069270;user-type=;vip=0"), tags);
            assert((id == "0fabf780-4c25-4b2a-84ad-16a79a828d61"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=premium/1;client-nonce=b5065e6ea4749db330189bde7b381239;color=#2CD1D5;display-name=mojazu;emotes=;first-msg=0;flags=40-49:P.0;id=f8039222-2069-434e-a37e-b5d955425028;mod=0;reply-parent-display-name=TyranosaurusBrett;reply-parent-msg-body=but\sI\scan't\stouch\sit;reply-parent-msg-id=7575d246-43f1-4128-80a5-cb092ae0610f;reply-parent-user-id=172563770;reply-parent-user-login=tyranosaurusbrett;reply-thread-parent-display-name=TyranosaurusBrett;reply-thread-parent-msg-id=7575d246-43f1-4128-80a5-cb092ae0610f;reply-thread-parent-user-id=172563770;reply-thread-parent-user-login=tyranosaurusbrett;returning-chatter=0;room-id=28640725;subscriber=0;tmi-sent-ts=1700104586321;turbo=0;user-id=8216630;user-type= :mojazu!mojazu@mojazu.tmi.twitch.tv PRIVMSG #lobosjr :@TyranosaurusBrett haha we're all there goddammit. So much temptation";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), type.toString());
            assert((sender.nickname == "mojazu"), sender.nickname);
            assert((sender.ident == "mojazu"), sender.ident);
            assert((sender.address == "mojazu.tmi.twitch.tv"), sender.address);
            assert((sender.account == "mojazu"), sender.account);
            assert((sender.displayName == "mojazu"), sender.displayName);
            assert((sender.badges == "premium/1"), sender.badges);
            assert((sender.colour == "2CD1D5"), sender.colour);
            assert((sender.id == 8216630), sender.id.to!string);
            assert((target.nickname == "tyranosaurusbrett"), target.nickname);
            assert((target.account == "tyranosaurusbrett"), target.account);
            assert((target.displayName == "TyranosaurusBrett"), target.displayName);
            assert((target.id == 172563770), target.id.to!string);
            assert((channel == "#lobosjr"), channel);
            assert((content == "@TyranosaurusBrett haha we're all there goddammit. So much temptation"), content);
            assert((aux[0] == "but I can't touch it"), aux[0]);
            assert((tags == "badge-info=;badges=premium/1;client-nonce=b5065e6ea4749db330189bde7b381239;color=#2CD1D5;display-name=mojazu;emotes=;first-msg=0;flags=40-49:P.0;id=f8039222-2069-434e-a37e-b5d955425028;mod=0;reply-parent-display-name=TyranosaurusBrett;reply-parent-msg-body=but\\sI\\scan't\\stouch\\sit;reply-parent-msg-id=7575d246-43f1-4128-80a5-cb092ae0610f;reply-parent-user-id=172563770;reply-parent-user-login=tyranosaurusbrett;reply-thread-parent-display-name=TyranosaurusBrett;reply-thread-parent-msg-id=7575d246-43f1-4128-80a5-cb092ae0610f;reply-thread-parent-user-id=172563770;reply-thread-parent-user-login=tyranosaurusbrett;returning-chatter=0;room-id=28640725;subscriber=0;tmi-sent-ts=1700104586321;turbo=0;user-id=8216630;user-type="), tags);
            assert((id == "f8039222-2069-434e-a37e-b5d955425028"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=bits/1;color=#1E90FF;display-name=まっりゆみ;emotes=;flags=;id=86a3282b-2785-4f4a-a103-3e4fe19eb4d4;login=marriyumi;mod=0;msg-id=viewermilestone;msg-param-category=watch-streak;msg-param-copoReward=350;msg-param-id=c52b7cd6-9fd0-4814-bb7e-b7844665f5b7;msg-param-value=3;room-id=883612928;subscriber=0;system-msg=まっりゆみ\swatched\s3\sconsecutive\sstreams\sthis\smonth\sand\ssparked\sa\swatch\sstreak!;tmi-sent-ts=1700510454678;user-id=244695359;user-type=;vip=0 :tmi.twitch.tv USERNOTICE #nemefy0929 :ネメちゃんこんばんわ";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_MILESTONE), type.toString());
            assert((sender.nickname == "marriyumi"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "marriyumi"), sender.account);
            assert((sender.displayName == "まっりゆみ"), sender.displayName);
            assert((sender.badges == "bits/1"), sender.badges);
            assert((sender.colour == "1E90FF"), sender.colour);
            assert((sender.id == 244695359), sender.id.to!string);
            assert((channel == "#nemefy0929"), channel);
            assert((content == "ネメちゃんこんばんわ"), content);
            assert((aux[0] == "watch-streak"), aux[0]);
            assert((count[0] == 3), count[0].to!string);
            assert((count[1] == 350), count[1].to!string);
            assert((tags == "badge-info=;badges=bits/1;color=#1E90FF;display-name=まっりゆみ;emotes=;flags=;id=86a3282b-2785-4f4a-a103-3e4fe19eb4d4;login=marriyumi;mod=0;msg-id=viewermilestone;msg-param-category=watch-streak;msg-param-copoReward=350;msg-param-id=c52b7cd6-9fd0-4814-bb7e-b7844665f5b7;msg-param-value=3;room-id=883612928;subscriber=0;system-msg=まっりゆみ\\swatched\\s3\\sconsecutive\\sstreams\\sthis\\smonth\\sand\\ssparked\\sa\\swatch\\sstreak!;tmi-sent-ts=1700510454678;user-id=244695359;user-type=;vip=0"), tags);
            assert((id == "86a3282b-2785-4f4a-a103-3e4fe19eb4d4"), id);
        }
    }
    {
        enum input = r"@badge-info=subscriber/12;badges=subscriber/12,sub-gift-leader/1;color=#0000FF;display-name=万年二等兵;emotes=;flags=;id=2cf9322d-609e-4a7b-9d79-f4c7b05458e8;login=nitouheidayo;mod=0;msg-id=subgift;msg-param-community-gift-id=14473467917504761560;msg-param-gift-months=1;msg-param-gift-theme=biblethump;msg-param-months=1;msg-param-origin-id=14473467917504761560;msg-param-recipient-display-name=ドキドキ文芸部レギュラー;msg-param-recipient-id=923831373;msg-param-recipient-user-name=wakarimasitan;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\sSubscription\s(nass_oisii);msg-param-sub-plan=1000;room-id=672917034;subscriber=1;system-msg=万年二等兵\sgifted\sa\sTier\s1\ssub\sto\sドキドキ文芸部レギュラー!;tmi-sent-ts=1701161053456;user-id=158834932;user-type=;vip=0 :tmi.twitch.tv USERNOTICE #nass_oisii";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUBGIFT), type.toString());
            assert((sender.nickname == "nitouheidayo"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "nitouheidayo"), sender.account);
            assert((sender.displayName == "万年二等兵"), sender.displayName);
            assert((sender.badges == "subscriber/12,sub-gift-leader/1"), sender.badges);
            assert((sender.colour == "0000FF"), sender.colour);
            assert((sender.id == 158834932), sender.id.to!string);
            assert((target.nickname == "wakarimasitan"), target.nickname);
            assert((target.account == "wakarimasitan"), target.account);
            assert((target.displayName == "ドキドキ文芸部レギュラー"), target.displayName);
            assert((channel == "#nass_oisii"), channel);
            assert((content == "万年二等兵 gifted a Tier 1 sub to ドキドキ文芸部レギュラー!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[2] == "Channel Subscription (nass_oisii)"), aux[2]);
            assert((aux[4] == "biblethump"), aux[4]);
            assert((count[0] == 1), count[0].to!string);
            assert((tags == "badge-info=subscriber/12;badges=subscriber/12,sub-gift-leader/1;color=#0000FF;display-name=万年二等兵;emotes=;flags=;id=2cf9322d-609e-4a7b-9d79-f4c7b05458e8;login=nitouheidayo;mod=0;msg-id=subgift;msg-param-community-gift-id=14473467917504761560;msg-param-gift-months=1;msg-param-gift-theme=biblethump;msg-param-months=1;msg-param-origin-id=14473467917504761560;msg-param-recipient-display-name=ドキドキ文芸部レギュラー;msg-param-recipient-id=923831373;msg-param-recipient-user-name=wakarimasitan;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(nass_oisii);msg-param-sub-plan=1000;room-id=672917034;subscriber=1;system-msg=万年二等兵\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sドキドキ文芸部レギュラー!;tmi-sent-ts=1701161053456;user-id=158834932;user-type=;vip=0"), tags);
            assert((id == "2cf9322d-609e-4a7b-9d79-f4c7b05458e8"), id);
        }
    }
    {
        enum input = r"@badge-info=subscriber/1;badges=subscriber/0,hype-train/1;color=;display-name=VALORANT;emotes=;flags=;id=363dd13c-3a48-4e06-986e-b9593a26d62d;login=valorant;mod=0;msg-id=submysterygift;msg-param-community-gift-id=11774446910225476645;msg-param-gift-match-bonus-count=5;msg-param-gift-match-extra-count=2;msg-param-gift-match-gifter-display-name=SuszterSpace;msg-param-gift-match=extra;msg-param-mass-gift-count=7;msg-param-origin-id=11774446910225476645;msg-param-sub-plan=1000;room-id=85498365;subscriber=1;system-msg=We\sadded\s5\sGift\sSubs\sAND\s2\sBonus\sGift\sSubs\sto\sSuszterSpace's\sgift!;tmi-sent-ts=1735655630455;user-id=490592527;user-type=;vip=0 :tmi.twitch.tv USERNOTICE #vedal987";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), type.toString());
            assert((sender.nickname == "valorant"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "valorant"), sender.account);
            assert((sender.displayName == "VALORANT"), sender.displayName);
            assert((sender.badges == "subscriber/1,hype-train/1"), sender.badges);
            assert((sender.id == 490592527), sender.id.to!string);
            assert((target.displayName == "SuszterSpace"), target.displayName);
            assert((channel == "#vedal987"), channel);
            assert((content == "We added 5 Gift Subs AND 2 Bonus Gift Subs to SuszterSpace's gift!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[1] == "extra"), aux[1]);
            assert((count[0] == 7), count[0].to!string);
            assert((count[1] == 5), count[1].to!string);
            assert((count[2] == 2), count[2].to!string);
            assert((tags == "badge-info=subscriber/1;badges=subscriber/0,hype-train/1;color=;display-name=VALORANT;emotes=;flags=;id=363dd13c-3a48-4e06-986e-b9593a26d62d;login=valorant;mod=0;msg-id=submysterygift;msg-param-community-gift-id=11774446910225476645;msg-param-gift-match-bonus-count=5;msg-param-gift-match-extra-count=2;msg-param-gift-match-gifter-display-name=SuszterSpace;msg-param-gift-match=extra;msg-param-mass-gift-count=7;msg-param-origin-id=11774446910225476645;msg-param-sub-plan=1000;room-id=85498365;subscriber=1;system-msg=We\\sadded\\s5\\sGift\\sSubs\\sAND\\s2\\sBonus\\sGift\\sSubs\\sto\\sSuszterSpace's\\sgift!;tmi-sent-ts=1735655630455;user-id=490592527;user-type=;vip=0"), tags);
            assert((id == "363dd13c-3a48-4e06-986e-b9593a26d62d"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@badge-info=subscriber/2;badges=subscriber/2;color=#0041CC;display-name=NewUnit;emote-only=1;emotes=emotesv2_e404c6a3a5c349ff90a7bc046ad1f2ea:0-8;first-msg=0;flags=;id=dfea51e0-1176-45a9-b8ac-2afc259fa520;mod=0;msg-id=gigantified-emote-message;returning-chatter=0;room-id=85498365;subscriber=1;tmi-sent-ts=1735662056428;turbo=0;user-id=49283792;user-type= :newunit!newunit@newunit.tmi.twitch.tv PRIVMSG #vedal987 :vedalBwaa");
        with (event)
        {
            assert((type == IRCEvent.Type.EMOTE), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "newunit"), sender.nickname);
            assert((sender.id == 49283792), sender.id.to!string);
            assert((sender.ident == "newunit"), sender.ident);
            assert((sender.address == "newunit.tmi.twitch.tv"), sender.address);
            assert((sender.account == "newunit"), sender.account);
            assert((sender.displayName == "NewUnit"), sender.displayName);
            assert((sender.badges == "subscriber/2"), sender.badges);
            assert((sender.colour == "0041CC"), sender.colour);
            assert((channel == "#vedal987"), channel);
            assert((content == "vedalBwaa"), content);
            assert((aux[0] == "gigantified-emote-message"), aux[0]);
            assert((tags == "badge-info=subscriber/2;badges=subscriber/2;color=#0041CC;display-name=NewUnit;emote-only=1;emotes=emotesv2_e404c6a3a5c349ff90a7bc046ad1f2ea:0-8;first-msg=0;flags=;id=dfea51e0-1176-45a9-b8ac-2afc259fa520;mod=0;msg-id=gigantified-emote-message;returning-chatter=0;room-id=85498365;subscriber=1;tmi-sent-ts=1735662056428;turbo=0;user-id=49283792;user-type="), tags);
            assert((emotes == "emotesv2_e404c6a3a5c349ff90a7bc046ad1f2ea:0-8"), emotes);
            assert((id == "dfea51e0-1176-45a9-b8ac-2afc259fa520"), id);
        }
    }
    {
        immutable event = parser.toIRCEvent("@animation-id=simmer;badge-info=subscriber/5;badges=subscriber/3,raging-wolf-helm/1;color=#008000;display-name=MongusaEye;emotes=emotesv2_20e1e7406e1342f7989227a2942f90b9:41-50;first-msg=0;flags=;id=08cbbd34-835d-4ae0-8b4d-ed5624ab7567;mod=0;msg-id=animated-message;returning-chatter=0;room-id=85498365;subscriber=1;tmi-sent-ts=1735766118589;turbo=0;user-id=151395194;user-type= :mongusaeye!mongusaeye@mongusaeye.tmi.twitch.tv PRIVMSG #vedal987 :my free bits from that one survey i took vedalCheer all i have");
        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "mongusaeye"), sender.nickname);
            assert((sender.id == 151395194), sender.id.to!string);
            assert((sender.ident == "mongusaeye"), sender.ident);
            assert((sender.address == "mongusaeye.tmi.twitch.tv"), sender.address);
            assert((sender.account == "mongusaeye"), sender.account);
            assert((sender.displayName == "MongusaEye"), sender.displayName);
            assert((sender.badges == "subscriber/5,raging-wolf-helm/1"), sender.badges);
            assert((sender.colour == "008000"), sender.colour);
            assert((channel == "#vedal987"), channel);
            assert((content == "my free bits from that one survey i took vedalCheer all i have"), content);
            assert((aux[0] == "animated-message"), aux[0]);
            assert((aux[1] == "simmer"), aux[1]);
            assert((tags == "animation-id=simmer;badge-info=subscriber/5;badges=subscriber/3,raging-wolf-helm/1;color=#008000;display-name=MongusaEye;emotes=emotesv2_20e1e7406e1342f7989227a2942f90b9:41-50;first-msg=0;flags=;id=08cbbd34-835d-4ae0-8b4d-ed5624ab7567;mod=0;msg-id=animated-message;returning-chatter=0;room-id=85498365;subscriber=1;tmi-sent-ts=1735766118589;turbo=0;user-id=151395194;user-type="), tags);
            assert((emotes == "emotesv2_20e1e7406e1342f7989227a2942f90b9:41-50"), emotes);
            assert((id == "08cbbd34-835d-4ae0-8b4d-ed5624ab7567"), id);
        }
    }
    {
        enum input = "@animation-id=cosmic-abyss;badge-info=subscriber/3;badges=subscriber/3,bits/100;color=#FF69B4;display-name=defie_;emotes=;first-msg=0;flags=;id=5737bf6c-7d94-4647-9c65-dd2ccddd6cdb;mod=0;msg-id=animated-message;returning-chatter=0;room-id=85498365;subscriber=1;tmi-sent-ts=1735766193723;turbo=0;user-id=244884001;user-type= :defie_!defie_@defie_.tmi.twitch.tv PRIVMSG #vedal987 :WAIT FOR 3D MODEL GIFT";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "defie_"), sender.nickname);
            assert((sender.id == 244884001), sender.id.to!string);
            assert((sender.ident == "defie_"), sender.ident);
            assert((sender.address == "defie_.tmi.twitch.tv"), sender.address);
            assert((sender.account == "defie_"), sender.account);
            assert((sender.displayName == "defie_"), sender.displayName);
            assert((sender.badges == "subscriber/3,bits/100"), sender.badges);
            assert((sender.colour == "FF69B4"), sender.colour);
            assert((channel == "#vedal987"), channel);
            assert((content == "WAIT FOR 3D MODEL GIFT"), content);
            assert((aux[0] == "animated-message"), aux[0]);
            assert((aux[1] == "cosmic-abyss"), aux[1]);
            assert((tags == "animation-id=cosmic-abyss;badge-info=subscriber/3;badges=subscriber/3,bits/100;color=#FF69B4;display-name=defie_;emotes=;first-msg=0;flags=;id=5737bf6c-7d94-4647-9c65-dd2ccddd6cdb;mod=0;msg-id=animated-message;returning-chatter=0;room-id=85498365;subscriber=1;tmi-sent-ts=1735766193723;turbo=0;user-id=244884001;user-type="), tags);
            assert((id == "5737bf6c-7d94-4647-9c65-dd2ccddd6cdb"), id);
        }
    }
    {
        enum input = "@badge-info=subscriber/14;badges=subscriber/3012,bits/400000;client-nonce=2f902f664b43d410ea3ae2bce9418191;color=#0482FF;display-name=karmsRS;emotes=;first-msg=0;flags=;id=e3d9088c-d4f1-4db4-b92c-020af4cc45a0;mod=0;returning-chatter=0;room-id=469632185;source-badge-info=subscriber/14;source-badges=subscriber/3012,bits/400000;source-id=e3d9088c-d4f1-4db4-b92c-020af4cc45a0;source-room-id=469632185;subscriber=1;tmi-sent-ts=1737072013166;turbo=0;user-id=25528963;user-type= :karmsrs!karmsrs@karmsrs.tmi.twitch.tv PRIVMSG #camila :ok ban bao ";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.CHAN), Enum!(IRCEvent.Type).toString(type));
            assert((sender.nickname == "karmsrs"), sender.nickname);
            assert((sender.id == 25528963), sender.id.to!string);
            assert((sender.ident == "karmsrs"), sender.ident);
            assert((sender.address == "karmsrs.tmi.twitch.tv"), sender.address);
            assert((sender.account == "karmsrs"), sender.account);
            assert((sender.displayName == "karmsRS"), sender.displayName);
            assert((sender.badges == "subscriber/14,bits/400000"), sender.badges);
            assert((sender.colour == "0482FF"), sender.colour);
            assert((channel == "#camila"), channel);
            assert((content == "ok ban bao "), content);
            assert((aux[12] == "469632185"), aux[12]);
            assert((tags == "badge-info=subscriber/14;badges=subscriber/3012,bits/400000;client-nonce=2f902f664b43d410ea3ae2bce9418191;color=#0482FF;display-name=karmsRS;emotes=;first-msg=0;flags=;id=e3d9088c-d4f1-4db4-b92c-020af4cc45a0;mod=0;returning-chatter=0;room-id=469632185;source-badge-info=subscriber/14;source-badges=subscriber/3012,bits/400000;source-id=e3d9088c-d4f1-4db4-b92c-020af4cc45a0;source-room-id=469632185;subscriber=1;tmi-sent-ts=1737072013166;turbo=0;user-id=25528963;user-type="), tags);
            assert((id == "e3d9088c-d4f1-4db4-b92c-020af4cc45a0"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=premium/1;color=#FF0000;display-name=The_Guardian_01;emotes=;flags=;id=44975199-cdff-4e10-aa68-bd67e280660d;login=the_guardian_01;mod=0;msg-id=sharedchatnotice;msg-param-community-gift-id=9333928271658164128;msg-param-gift-months=1;msg-param-months=1;msg-param-origin-id=9333928271658164128;msg-param-recipient-display-name=wofulrumble;msg-param-recipient-id=29716641;msg-param-recipient-user-name=wofulrumble;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\sSubscription\s(hikarustation):\s$4.99\sSub;msg-param-sub-plan=1000;room-id=469632185;source-badge-info=subscriber/1;source-badges=subscriber/0,sub-gift-leader/2;source-id=d3439028-575f-461e-9433-4bb9df3fe566;source-msg-id=subgift;source-room-id=110059426;subscriber=0;system-msg=The_Guardian_01\sgifted\sa\sTier\s1\ssub\sto\swofulrumble!;tmi-sent-ts=1737079293405;user-id=65208525;user-type=;vip=0 :tmi.twitch.tv USERNOTICE #camila";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUBGIFT), type.toString());
            assert((sender.nickname == "the_guardian_01"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "the_guardian_01"), sender.account);
            assert((sender.displayName == "The_Guardian_01"), sender.displayName);
            assert((sender.badges == "premium/1"), sender.badges);
            assert((sender.colour == "FF0000"), sender.colour);
            assert((sender.id == 65208525), sender.id.to!string);
            assert((target.nickname == "wofulrumble"), target.nickname);
            assert((target.account == "wofulrumble"), target.account);
            assert((target.displayName == "wofulrumble"), target.displayName);
            assert((channel == "#camila"), channel);
            assert((content == "The_Guardian_01 gifted a Tier 1 sub to wofulrumble!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[2] == "Channel Subscription (hikarustation): $4.99 Sub"), aux[2]);
            assert((aux[6] == "sharedchatnotice"), aux[6]);
            assert((aux[12] == "110059426"), aux[12]);
            assert((count[0] == 1), count[0].to!string);
            assert((tags == "badge-info=;badges=premium/1;color=#FF0000;display-name=The_Guardian_01;emotes=;flags=;id=44975199-cdff-4e10-aa68-bd67e280660d;login=the_guardian_01;mod=0;msg-id=sharedchatnotice;msg-param-community-gift-id=9333928271658164128;msg-param-gift-months=1;msg-param-months=1;msg-param-origin-id=9333928271658164128;msg-param-recipient-display-name=wofulrumble;msg-param-recipient-id=29716641;msg-param-recipient-user-name=wofulrumble;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(hikarustation):\\s$4.99\\sSub;msg-param-sub-plan=1000;room-id=469632185;source-badge-info=subscriber/1;source-badges=subscriber/0,sub-gift-leader/2;source-id=d3439028-575f-461e-9433-4bb9df3fe566;source-msg-id=subgift;source-room-id=110059426;subscriber=0;system-msg=The_Guardian_01\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\swofulrumble!;tmi-sent-ts=1737079293405;user-id=65208525;user-type=;vip=0"), tags);
            assert((id == "44975199-cdff-4e10-aa68-bd67e280660d"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=turbo/1;color=;display-name=daltonmtaylor03;emotes=;flags=;id=69dd5b2c-dcb6-46f5-baa1-26d042ec219b;login=daltonmtaylor03;mod=0;msg-id=sharedchatnotice;msg-param-cumulative-months=2;msg-param-months=0;msg-param-multimonth-duration=3;msg-param-multimonth-tenure=1;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\sSubscription\s(hikarustation):\s$4.99\sSub;msg-param-sub-plan=1000;msg-param-was-gifted=false;room-id=469632185;source-badge-info=subscriber/2;source-badges=subscriber/2,bits/100;source-id=de71b5e6-7a84-4dd8-b748-821eb1d9ef3a;source-msg-id=resub;source-room-id=110059426;subscriber=0;system-msg=daltonmtaylor03\ssubscribed\sat\sTier\s1.\sThey've\ssubscribed\sfor\s2\smonths!;tmi-sent-ts=1737079135753;user-id=1211304166;user-type=;vip=0 :tmi.twitch.tv USERNOTICE #camila :Bao #1";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUB), type.toString());
            assert((sender.nickname == "daltonmtaylor03"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "daltonmtaylor03"), sender.account);
            assert((sender.displayName == "daltonmtaylor03"), sender.displayName);
            assert((sender.badges == "turbo/1"), sender.badges);
            assert((sender.id == 1211304166), sender.id.to!string);
            assert((channel == "#camila"), channel);
            assert((content == "Bao #1"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[2] == "Channel Subscription (hikarustation): $4.99 Sub"), aux[2]);
            assert((aux[6] == "sharedchatnotice"), aux[6]);
            assert((aux[12] == "110059426"), aux[12]);
            assert((count[1] == 2), count[1].to!string);
            assert((count[5] == 3), count[5].to!string);
            assert((count[6] == 1), count[6].to!string);
            assert((tags == "badge-info=;badges=turbo/1;color=;display-name=daltonmtaylor03;emotes=;flags=;id=69dd5b2c-dcb6-46f5-baa1-26d042ec219b;login=daltonmtaylor03;mod=0;msg-id=sharedchatnotice;msg-param-cumulative-months=2;msg-param-months=0;msg-param-multimonth-duration=3;msg-param-multimonth-tenure=1;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\\sSubscription\\s(hikarustation):\\s$4.99\\sSub;msg-param-sub-plan=1000;msg-param-was-gifted=false;room-id=469632185;source-badge-info=subscriber/2;source-badges=subscriber/2,bits/100;source-id=de71b5e6-7a84-4dd8-b748-821eb1d9ef3a;source-msg-id=resub;source-room-id=110059426;subscriber=0;system-msg=daltonmtaylor03\\ssubscribed\\sat\\sTier\\s1.\\sThey've\\ssubscribed\\sfor\\s2\\smonths!;tmi-sent-ts=1737079135753;user-id=1211304166;user-type=;vip=0"), tags);
            assert((id == "69dd5b2c-dcb6-46f5-baa1-26d042ec219b"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=;color=;display-name=otulakburak;emotes=;flags=;id=8152af89-9351-40ae-9b9c-0069b2a139b5;login=otulakburak;mod=0;msg-id=raid;msg-param-displayName=otulakburak;msg-param-login=otulakburak;msg-param-profileImageURL=https://static-cdn.jtvnw.net/jtv_user_pictures/ef1fc431-e247-4b73-a3d4-d4cc754518b0-profile_image-%s.png;msg-param-viewerCount=3;room-id=852880224;source-badge-info=;source-badges=;source-id=8152af89-9351-40ae-9b9c-0069b2a139b5;source-msg-id=raid;source-room-id=852880224;subscriber=0;system-msg=3\sraiders\sfrom\sotulakburak\shave\sjoined!;tmi-sent-ts=1737079036117;user-id=678750215;user-type=;vip=0 :tmi.twitch.tv USERNOTICE #cerbervt";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_RAID), type.toString());
            assert((sender.nickname == "otulakburak"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "otulakburak"), sender.account);
            assert((sender.displayName == "otulakburak"), sender.displayName);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.id == 678750215), sender.id.to!string);
            assert((channel == "#cerbervt"), channel);
            assert((content == "3 raiders from otulakburak have joined!"), content);
            assert((aux[12] == "852880224"), aux[12]);
            assert((count[0] == 3), count[0].to!string);
            assert((tags == "badge-info=;badges=;color=;display-name=otulakburak;emotes=;flags=;id=8152af89-9351-40ae-9b9c-0069b2a139b5;login=otulakburak;mod=0;msg-id=raid;msg-param-displayName=otulakburak;msg-param-login=otulakburak;msg-param-profileImageURL=https://static-cdn.jtvnw.net/jtv_user_pictures/ef1fc431-e247-4b73-a3d4-d4cc754518b0-profile_image-%s.png;msg-param-viewerCount=3;room-id=852880224;source-badge-info=;source-badges=;source-id=8152af89-9351-40ae-9b9c-0069b2a139b5;source-msg-id=raid;source-room-id=852880224;subscriber=0;system-msg=3\\sraiders\\sfrom\\sotulakburak\\shave\\sjoined!;tmi-sent-ts=1737079036117;user-id=678750215;user-type=;vip=0"), tags);
            assert((id == "8152af89-9351-40ae-9b9c-0069b2a139b5"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=;color=#478937;display-name=circuitbrew;emotes=;flags=;id=ffe48ef9-80f4-4d58-9a7e-cf2982a6da85;login=circuitbrew;mod=0;msg-id=sharedchatnotice;msg-param-sub-plan=1000;room-id=852880224;source-badge-info=subscriber/1;source-badges=subscriber/0;source-id=3a92eb2c-d4de-4ae7-b9b2-16092aa82b8d;source-msg-id=primepaidupgrade;source-room-id=825937345;subscriber=0;system-msg=circuitbrew\sconverted\sfrom\sa\sPrime\ssub\sto\sa\sTier\s1\ssub!;tmi-sent-ts=1737078882888;user-id=79158584;user-type=;vip=0 :tmi.twitch.tv USERNOTICE #cerbervt";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUBUPGRADE), type.toString());
            assert((sender.nickname == "circuitbrew"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "circuitbrew"), sender.account);
            assert((sender.displayName == "circuitbrew"), sender.displayName);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.colour == "478937"), sender.colour);
            assert((sender.id == 79158584), sender.id.to!string);
            assert((channel == "#cerbervt"), channel);
            assert((content == "circuitbrew converted from a Prime sub to a Tier 1 sub!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[6] == "sharedchatnotice"), aux[6]);
            assert((aux[12] == "825937345"), aux[12]);
            assert((tags == "badge-info=;badges=;color=#478937;display-name=circuitbrew;emotes=;flags=;id=ffe48ef9-80f4-4d58-9a7e-cf2982a6da85;login=circuitbrew;mod=0;msg-id=sharedchatnotice;msg-param-sub-plan=1000;room-id=852880224;source-badge-info=subscriber/1;source-badges=subscriber/0;source-id=3a92eb2c-d4de-4ae7-b9b2-16092aa82b8d;source-msg-id=primepaidupgrade;source-room-id=825937345;subscriber=0;system-msg=circuitbrew\\sconverted\\sfrom\\sa\\sPrime\\ssub\\sto\\sa\\sTier\\s1\\ssub!;tmi-sent-ts=1737078882888;user-id=79158584;user-type=;vip=0"), tags);
            assert((id == "ffe48ef9-80f4-4d58-9a7e-cf2982a6da85"), id);
        }
    }
    {
        enum input = r"@badge-info=subscriber/10;badges=vip/1,subscriber/3009;color=#6F66FF;display-name=Nohealforu;emotes=;flags=;id=b9dcc719-e92c-43e7-9e5e-d9b08eaa50f6;login=nohealforu;mod=0;msg-id=subgift;msg-param-gift-months=1;msg-param-months=1;msg-param-origin-id=7277057062304351817;msg-param-recipient-display-name=useful_reptile;msg-param-recipient-id=503395987;msg-param-recipient-user-name=useful_reptile;msg-param-sender-count=5182;msg-param-sub-plan-name=Subscription\s(cerbervt);msg-param-sub-plan=1000;room-id=852880224;source-badge-info=subscriber/10;source-badges=vip/1,subscriber/3009;source-id=b9dcc719-e92c-43e7-9e5e-d9b08eaa50f6;source-msg-id=subgift;source-room-id=852880224;subscriber=1;system-msg=Nohealforu\sgifted\sa\sTier\s1\ssub\sto\suseful_reptile!\sThey\shave\sgiven\s5182\sGift\sSubs\sin\sthe\schannel!;tmi-sent-ts=1737079625135;user-id=84523884;user-type=;vip=1 :tmi.twitch.tv USERNOTICE #cerbervt";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUBGIFT), type.toString());
            assert((sender.nickname == "nohealforu"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "nohealforu"), sender.account);
            assert((sender.displayName == "Nohealforu"), sender.displayName);
            assert((sender.badges == "subscriber/10,vip/1"), sender.badges);
            assert((sender.colour == "6F66FF"), sender.colour);
            assert((sender.id == 84523884), sender.id.to!string);
            assert((target.nickname == "useful_reptile"), target.nickname);
            assert((target.account == "useful_reptile"), target.account);
            assert((target.displayName == "useful_reptile"), target.displayName);
            assert((channel == "#cerbervt"), channel);
            assert((content == "Nohealforu gifted a Tier 1 sub to useful_reptile! They have given 5182 Gift Subs in the channel!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[2] == "Subscription (cerbervt)"), aux[2]);
            assert((aux[12] == "852880224"), aux[12]);
            assert((count[0] == 1), count[0].to!string);
            assert((count[1] == 5182), count[1].to!string);
            assert((tags == "badge-info=subscriber/10;badges=vip/1,subscriber/3009;color=#6F66FF;display-name=Nohealforu;emotes=;flags=;id=b9dcc719-e92c-43e7-9e5e-d9b08eaa50f6;login=nohealforu;mod=0;msg-id=subgift;msg-param-gift-months=1;msg-param-months=1;msg-param-origin-id=7277057062304351817;msg-param-recipient-display-name=useful_reptile;msg-param-recipient-id=503395987;msg-param-recipient-user-name=useful_reptile;msg-param-sender-count=5182;msg-param-sub-plan-name=Subscription\\s(cerbervt);msg-param-sub-plan=1000;room-id=852880224;source-badge-info=subscriber/10;source-badges=vip/1,subscriber/3009;source-id=b9dcc719-e92c-43e7-9e5e-d9b08eaa50f6;source-msg-id=subgift;source-room-id=852880224;subscriber=1;system-msg=Nohealforu\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\suseful_reptile!\\sThey\\shave\\sgiven\\s5182\\sGift\\sSubs\\sin\\sthe\\schannel!;tmi-sent-ts=1737079625135;user-id=84523884;user-type=;vip=1"), tags);
            assert((id == "b9dcc719-e92c-43e7-9e5e-d9b08eaa50f6"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=premium/1;color=#0000FF;display-name=Squeakz_JR;emotes=;flags=;id=57f39065-91f5-492a-afd3-3ee86ccc3c6e;login=squeakz_jr;mod=0;msg-id=sharedchatnotice;msg-param-community-gift-id=14320587522017408183;msg-param-gift-theme=showlove;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=4184;msg-param-goal-description=new\semote\sslot!;msg-param-goal-target-contributions=4400;msg-param-goal-user-contributions=1;msg-param-mass-gift-count=1;msg-param-origin-id=14320587522017408183;msg-param-sender-count=1;msg-param-sub-plan=1000;room-id=852880224;source-badge-info=subscriber/1;source-badges=subscriber/0,premium/1;source-id=8a089acb-013a-480d-9a22-34ce4dcf5ed3;source-msg-id=submysterygift;source-room-id=1004060561;subscriber=0;system-msg=Squeakz_JR\sis\sgifting\s1\sTier\s1\sSubs\sto\sMinikoMew's\scommunity!\sThey've\sgifted\sa\stotal\sof\s1\sin\sthe\schannel!;tmi-sent-ts=1737080421367;user-id=93846483;user-type=;vip=0 :tmi.twitch.tv USERNOTICE #cerbervt";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), type.toString());
            assert((sender.nickname == "squeakz_jr"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "squeakz_jr"), sender.account);
            assert((sender.displayName == "Squeakz_JR"), sender.displayName);
            assert((sender.badges == "premium/1"), sender.badges);
            assert((sender.colour == "0000FF"), sender.colour);
            assert((sender.id == 93846483), sender.id.to!string);
            assert((channel == "#cerbervt"), channel);
            assert((content == "Squeakz_JR is gifting 1 Tier 1 Subs to MinikoMew's community! They've gifted a total of 1 in the channel!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[3] == "new emote slot!"), aux[3]);
            assert((aux[4] == "showlove"), aux[4]);
            assert((aux[5] == "SUB_POINTS"), aux[5]);
            assert((aux[6] == "sharedchatnotice"), aux[6]);
            assert((aux[12] == "1004060561"), aux[12]);
            assert((count[0] == 1), count[0].to!string);
            assert((count[1] == 1), count[1].to!string);
            assert((count[2] == 4400), count[2].to!string);
            assert((count[3] == 4184), count[3].to!string);
            assert((count[4] == 1), count[4].to!string);
            assert((tags == "badge-info=;badges=premium/1;color=#0000FF;display-name=Squeakz_JR;emotes=;flags=;id=57f39065-91f5-492a-afd3-3ee86ccc3c6e;login=squeakz_jr;mod=0;msg-id=sharedchatnotice;msg-param-community-gift-id=14320587522017408183;msg-param-gift-theme=showlove;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=4184;msg-param-goal-description=new\\semote\\sslot!;msg-param-goal-target-contributions=4400;msg-param-goal-user-contributions=1;msg-param-mass-gift-count=1;msg-param-origin-id=14320587522017408183;msg-param-sender-count=1;msg-param-sub-plan=1000;room-id=852880224;source-badge-info=subscriber/1;source-badges=subscriber/0,premium/1;source-id=8a089acb-013a-480d-9a22-34ce4dcf5ed3;source-msg-id=submysterygift;source-room-id=1004060561;subscriber=0;system-msg=Squeakz_JR\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sMinikoMew's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s1\\sin\\sthe\\schannel!;tmi-sent-ts=1737080421367;user-id=93846483;user-type=;vip=0"), tags);
            assert((id == "57f39065-91f5-492a-afd3-3ee86ccc3c6e"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=sub-gift-leader/1;color=;display-name=revelracing66;emotes=;flags=;id=0921d903-e597-42a8-9e57-28e08c922ff0;login=revelracing66;mod=0;msg-id=sharedchatnotice;msg-param-community-gift-id=4540557273074603447;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=4239;msg-param-goal-description=new\semote\sslot!;msg-param-goal-target-contributions=4400;msg-param-goal-user-contributions=55;msg-param-mass-gift-count=55;msg-param-origin-id=4540557273074603447;msg-param-sender-count=55;msg-param-sub-plan=1000;room-id=852880224;source-badge-info=;source-badges=;source-id=d76a0318-3af3-43a3-abc3-3dad20da12de;source-msg-id=submysterygift;source-room-id=1004060561;subscriber=0;system-msg=revelracing66\sis\sgifting\s55\sTier\s1\sSubs\sto\sMinikoMew's\scommunity!\sThey've\sgifted\sa\stotal\sof\s55\sin\sthe\schannel!;tmi-sent-ts=1737083162400;user-id=737286301;user-type=;vip=0 :tmi.twitch.tv USERNOTICE #cerbervt";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_BULKGIFT), type.toString());
            assert((sender.nickname == "revelracing66"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "revelracing66"), sender.account);
            assert((sender.displayName == "revelracing66"), sender.displayName);
            assert((sender.badges == "sub-gift-leader/1"), sender.badges);
            assert((sender.id == 737286301), sender.id.to!string);
            assert((channel == "#cerbervt"), channel);
            assert((content == "revelracing66 is gifting 55 Tier 1 Subs to MinikoMew's community! They've gifted a total of 55 in the channel!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[3] == "new emote slot!"), aux[3]);
            assert((aux[5] == "SUB_POINTS"), aux[5]);
            assert((aux[6] == "sharedchatnotice"), aux[6]);
            assert((aux[12] == "1004060561"), aux[12]);
            assert((count[0] == 55), count[0].to!string);
            assert((count[1] == 55), count[1].to!string);
            assert((count[2] == 4400), count[2].to!string);
            assert((count[3] == 4239), count[3].to!string);
            assert((count[4] == 55), count[4].to!string);
            assert((tags == "badge-info=;badges=sub-gift-leader/1;color=;display-name=revelracing66;emotes=;flags=;id=0921d903-e597-42a8-9e57-28e08c922ff0;login=revelracing66;mod=0;msg-id=sharedchatnotice;msg-param-community-gift-id=4540557273074603447;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=4239;msg-param-goal-description=new\\semote\\sslot!;msg-param-goal-target-contributions=4400;msg-param-goal-user-contributions=55;msg-param-mass-gift-count=55;msg-param-origin-id=4540557273074603447;msg-param-sender-count=55;msg-param-sub-plan=1000;room-id=852880224;source-badge-info=;source-badges=;source-id=d76a0318-3af3-43a3-abc3-3dad20da12de;source-msg-id=submysterygift;source-room-id=1004060561;subscriber=0;system-msg=revelracing66\\sis\\sgifting\\s55\\sTier\\s1\\sSubs\\sto\\sMinikoMew's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s55\\sin\\sthe\\schannel!;tmi-sent-ts=1737083162400;user-id=737286301;user-type=;vip=0"), tags);
            assert((id == "0921d903-e597-42a8-9e57-28e08c922ff0"), id);
        }
    }
    {
        enum input = r"@badge-info=subscriber/14;badges=subscriber/12,bits/1000;color=#9ACD32;display-name=GREENCATdev;emotes=;flags=;id=d0aa66a5-c226-4521-bd74-7ca4b9d26aac;login=greencatdev;mod=0;msg-id=charitydonation;msg-param-charity-name=The\sHumane\sSociety\sof\sthe\sUS;msg-param-donation-amount=500;msg-param-donation-currency=USD;msg-param-exponent=2;room-id=151368796;subscriber=1;system-msg=GREENCATdev:\sDonated\sUSD\s5\sto\ssupport\sThe\sHumane\sSociety\sof\sthe\sUS;tmi-sent-ts=1737131459160;user-id=109998382;user-type=;vip=0 :tmi.twitch.tv USERNOTICE #piratesoftware";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_CHARITYDONATION), type.toString());
            assert((sender.nickname == "greencatdev"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "greencatdev"), sender.account);
            assert((sender.displayName == "GREENCATdev"), sender.displayName);
            assert((sender.badges == "subscriber/14,bits/1000"), sender.badges);
            assert((sender.colour == "9ACD32"), sender.colour);
            assert((sender.id == 109998382), sender.id.to!string);
            assert((channel == "#piratesoftware"), channel);
            assert((content == "GREENCATdev: Donated USD 5 to support The Humane Society of the US"), content);
            assert((aux[0] == "The Humane Society of the US"), aux[0]);
            assert((aux[1] == "USD"), aux[1]);
            assert((count[0] == 500), count[0].to!string);
            assert((tags == "badge-info=subscriber/14;badges=subscriber/12,bits/1000;color=#9ACD32;display-name=GREENCATdev;emotes=;flags=;id=d0aa66a5-c226-4521-bd74-7ca4b9d26aac;login=greencatdev;mod=0;msg-id=charitydonation;msg-param-charity-name=The\\sHumane\\sSociety\\sof\\sthe\\sUS;msg-param-donation-amount=500;msg-param-donation-currency=USD;msg-param-exponent=2;room-id=151368796;subscriber=1;system-msg=GREENCATdev:\\sDonated\\sUSD\\s5\\sto\\ssupport\\sThe\\sHumane\\sSociety\\sof\\sthe\\sUS;tmi-sent-ts=1737131459160;user-id=109998382;user-type=;vip=0"), tags);
            assert((id == "d0aa66a5-c226-4521-bd74-7ca4b9d26aac"), id);
        }
    }
    {
        enum input = r"@badge-info=;badges=;color=;display-name=AnAnonymousGifter;emotes=;flags=;id=01af180f-5efd-40c8-94fb-d0a346c7bf86;login=ananonymousgifter;mod=0;msg-id=subgift;msg-param-fun-string=FunStringFour;msg-param-gift-months=1;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=15624;msg-param-goal-target-contributions=20000;msg-param-goal-user-contributions=1;msg-param-months=24;msg-param-origin-id=54\s41\s9a\s69\s6c\sb4\s3c\s8b\s0b\se4\sdf\s4c\sba\s5b\s9b\s23\s4c\sa7\s9b\sc4;msg-param-recipient-display-name=niku4949;msg-param-recipient-id=547206601;msg-param-recipient-user-name=niku4949;msg-param-sub-plan-name=Channel\sSubscription\s(some_streamer);msg-param-sub-plan=1000;room-id=49207184;subscriber=0;system-msg=An\sanonymous\suser\sgifted\sa\sTier\s1\ssub\sto\sniku4949!\s;tmi-sent-ts=1685982143345;user-id=274598607;user-type= :tmi.twitch.tv USERNOTICE #some_streamer";
        immutable event = parser.toIRCEvent(input);

        with (event)
        {
            assert((type == IRCEvent.Type.TWITCH_SUBGIFT), type.toString());
            assert((sender.nickname == "ananonymousgifter"), sender.nickname);
            assert((sender.address == "tmi.twitch.tv"), sender.address);
            assert((sender.account == "ananonymousgifter"), sender.account);
            assert((sender.displayName == "AnAnonymousGifter"), sender.displayName);
            assert((sender.badges == "*"), sender.badges);
            assert((sender.id == 274598607), sender.id.to!string);
            assert((target.nickname == "niku4949"), target.nickname);
            assert((target.account == "niku4949"), target.account);
            assert((target.displayName == "niku4949"), target.displayName);
            assert((channel == "#some_streamer"), channel);
            assert((content == "An anonymous user gifted a Tier 1 sub to niku4949!"), content);
            assert((aux[0] == "1000"), aux[0]);
            assert((aux[1] == "FunStringFour"), aux[1]);
            assert((aux[2] == "Channel Subscription (some_streamer)"), aux[2]);
            assert((aux[5] == "SUB_POINTS"), aux[5]);
            assert((count[0] == 1), count[0].to!string);
            assert((count[2] == 20000), count[2].to!string);
            assert((count[3] == 15624), count[3].to!string);
            assert((count[4] == 1), count[4].to!string);
            assert((tags == "badge-info=;badges=;color=;display-name=AnAnonymousGifter;emotes=;flags=;id=01af180f-5efd-40c8-94fb-d0a346c7bf86;login=ananonymousgifter;mod=0;msg-id=subgift;msg-param-fun-string=FunStringFour;msg-param-gift-months=1;msg-param-goal-contribution-type=SUB_POINTS;msg-param-goal-current-contributions=15624;msg-param-goal-target-contributions=20000;msg-param-goal-user-contributions=1;msg-param-months=24;msg-param-origin-id=54\\s41\\s9a\\s69\\s6c\\sb4\\s3c\\s8b\\s0b\\se4\\sdf\\s4c\\sba\\s5b\\s9b\\s23\\s4c\\sa7\\s9b\\sc4;msg-param-recipient-display-name=niku4949;msg-param-recipient-id=547206601;msg-param-recipient-user-name=niku4949;msg-param-sub-plan-name=Channel\\sSubscription\\s(some_streamer);msg-param-sub-plan=1000;room-id=49207184;subscriber=0;system-msg=An\\sanonymous\\suser\\sgifted\\sa\\sTier\\s1\\ssub\\sto\\sniku4949!\\s;tmi-sent-ts=1685982143345;user-id=274598607;user-type="), tags);
            assert((id == "01af180f-5efd-40c8-94fb-d0a346c7bf86"), id);
        }
    }
}
