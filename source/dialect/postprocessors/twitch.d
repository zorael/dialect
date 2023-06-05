/++
    The Twitch postprocessor processes [dialect.defs.IRCEvent|IRCEvent]s after
    they are parsed, and deals with Twitch-specifics. Those include extracting
    the colour someone's name should be printed in, their alias/"display name"
    (generally their nickname cased), converting the event to some event types
    unique to Twitch, etc.
 +/
module dialect.postprocessors.twitch;

version(TwitchSupport):

//version = TwitchWarnings;

private:

import dialect.defs;
import dialect.parsing : IRCParser;
import dialect.postprocessors;

version(Postprocessors) {}
else
{
    enum message = "Version `Postprocessors` must be enabled in `dub.sdl` for Twitch support.";
    static assert(0, message);
}


/+
    Mix in [dialect.postprocessors.PostprocessorRegistration] to enable this
    postprocessor and have it be automatically instantiated on library initialisation.
 +/
mixin PostprocessorRegistration!TwitchPostprocessor;


// parseTwitchTags
/++
    Parses a Twitch event's IRCv3 tags.

    The event is passed by ref as many tags necessitate changes to it.

    Params:
        parser = Current [dialect.parsing.IRCParser|IRCParser].
        event = Reference to the [dialect.defs.IRCEvent|IRCEvent] whose tags
            should be parsed.
 +/
auto parseTwitchTags(ref IRCParser parser, ref IRCEvent event) @safe
{
    import dialect.common : decodeIRCv3String;
    import std.algorithm.iteration : splitter;
    import std.conv : to;

    // https://dev.twitch.tv/docs/v5/guides/irc/#twitch-irc-capability-tags

    if (!event.tags.length) return;

    auto tagRange = event.tags.splitter(";");  // mutable

    version(TwitchWarnings)
    {
        /// Whether or not an error occured and debug information should be printed
        /// upon leaving the function.
        bool printTagsOnExit;

        static void appendToErrors(ref IRCEvent event, const string msg)
        {
            import std.conv : text;
            immutable spacer = (event.errors.length ? " | " : string.init);
            event.errors ~= text(spacer, msg);
        }

        static void printTags(typeof(tagRange) tagRange, const IRCEvent event)
        {
            import lu.string : nom;
            import std.stdio : writefln, writeln;

            writeln('@', event.tags, ' ', event.raw, '$');

            foreach (immutable tagline; tagRange)
            {
                string slice = tagline;  // mutable
                immutable key = slice.nom('=');

                writefln(`%-35s"%s"`, key, slice);
            }
        }

        void warnAboutOverwrittenCount(
            const size_t i,
            const string key,
            const string type = "tag")
        {
            if (!event.count[i].isNull)
            {
                import std.conv : text;
                import std.stdio : writeln;

                immutable msg = text(type, ' ', key, " overwrote `count[", i, "]`: ", event.count[i].get);
                appendToErrors(event, msg);
                writeln(msg);
                printTagsOnExit = true;
            }
        }

        void warnAboutOverwrittenAuxString(
            const size_t i,
            const string key,
            const string type = "tag")
        {
            if (event.aux[i].length)
            {
                import std.conv : text;
                import std.stdio : writeln;

                immutable msg = text(type, ' ', key, " overwrote `aux[", i, "]`: ", event.aux[i]);
                appendToErrors(event, msg);
                writeln(msg);
                printTagsOnExit = true;
            }
        }
    }

    with (IRCEvent.Type)
    foreach (tag; tagRange)
    {
        import lu.string : contains, nom;

        immutable key = tag.nom('=');
        string value = tag;  // mutable

        switch (key)
        {
        case "msg-id":
            // The type of notice (not the ID) / A message ID string.
            // Can be used for i18ln. Valid values: see
            // Msg-id Tags for the NOTICE Commands Capability.
            // https://dev.twitch.tv/docs/irc#msg-id-tags-for-the-notice-commands-capability
            // https://swiftyspiffy.com/TwitchLib/Client/_msg_ids_8cs_source.html
            // https://dev.twitch.tv/docs/irc/msg-id/

            /*
                sub
                resub
                charity
                already_banned          <user> is already banned in this room.
                already_emote_only_off  This room is not in emote-only mode.
                already_emote_only_on   This room is already in emote-only mode.
                already_r9k_off         This room is not in r9k mode.
                already_r9k_on          This room is already in r9k mode.
                already_subs_off        This room is not in subscribers-only mode.
                already_subs_on         This room is already in subscribers-only mode.
                bad_unban_no_ban        <user> is not banned from this room.
                ban_success             <user> is banned from this room.
                emote_only_off          This room is no longer in emote-only mode.
                emote_only_on           This room is now in emote-only mode.
                hosts_remaining         There are <number> host commands remaining this half hour.
                msg_channel_suspended   This channel is suspended.
                r9k_off                 This room is no longer in r9k mode.
                r9k_on                  This room is now in r9k mode.
                slow_off                This room is no longer in slow mode.
                slow_on                 This room is now in slow mode. You may send messages every <slow seconds> seconds.
                subs_off                This room is no longer in subscribers-only mode.
                subs_on                 This room is now in subscribers-only mode.
                timeout_success         <user> has been timed out for <duration> seconds.
                unban_success           <user> is no longer banned from this chat room.
                unrecognized_cmd        Unrecognized command: <command>
                raid                    Raiders from <other channel> have joined!\n
            */

            alias msgID = value;
            if (!msgID.length) continue;  // Rare occurence but happens

            switch (msgID)
            {
            case "sub":
            case "resub":
                // Subscription. Disambiguate subs from resubs by other tags, set
                // in count and altcount.
                event.type = TWITCH_SUB;
                break;

            case "subgift":
                // A gifted subscription.
                // "X subscribed with Twitch Prime."
                // "Y subscribed at Tier 1. They've subscribed for 11 months!"
                // "We added the msg-id “anonsubgift” to the user-notice which
                // defaults the sender to the channel owner"
                /+
                    For anything anonomous
                    The channel ID and Channel name are set as normal
                    The Recipienet is set as normal
                    The person giving the gift is anonomous

                    https://discuss.dev.twitch.tv/t/msg-id-purchase/22067/8
                 +/
                // In reality the sender is "ananonymousgifter".
                event.type = TWITCH_SUBGIFT;
                break;

            case "submysterygift":
                // Gifting several subs to random people in one event.
                // "A is gifting 1 Tier 1 Subs to C's community! They've gifted a total of n in the channel!"
                event.type = TWITCH_BULKGIFT;
                break;

            case "ritual":
                // Oneliner upon joining chat.
                // content: "HeyGuys"
                event.type = TWITCH_RITUAL;
                break;

            case "rewardgift":
                event.type = TWITCH_REWARDGIFT;
                break;

            case "raid":
                // Raid start. Seen in target channel.
                // "3322 raiders from A have joined!"
                event.type = TWITCH_RAID;
                break;

            case "unraid":
                // Manual raid abort.
                // "The raid has been cancelled."
                event.type = TWITCH_UNRAID;
                break;

            case "charity":
                import lu.string : beginsWith;
                import std.algorithm.iteration : filter;
                import std.array : Appender;
                import std.typecons : Flag, No, Yes;

                event.type = TWITCH_CHARITY;

                string[string] charityAA;
                auto charityTags = tagRange
                    .filter!(tagline => tagline.beginsWith("msg-param-charity"));

                foreach (immutable tagline; charityTags)
                {
                    string slice = tagline;  // mutable
                    immutable charityKey = slice.nom('=');
                    charityAA[charityKey] = slice;
                }

                static immutable charityStringTags =
                [
                    "msg-param-charity-learn-more",
                    "msg-param-charity-hashtag",
                ];

                static immutable charityCountTags =
                [
                    //"msg-param-total"
                    "msg-param-charity-hours-remaining",
                    "msg-param-charity-days-remaining",
                ];

                if (const charityName = "msg-param-charity-name" in charityAA)
                {
                    import lu.string : removeControlCharacters, strippedRight;

                    //msg-param-charity-name = Direct\sRelief

                    version(TwitchWarnings) warnAboutOverwrittenAuxString(0, "msg-param-charity-name");
                    event.aux[0] = (*charityName)
                        .decodeIRCv3String
                        .strippedRight
                        .removeControlCharacters;
                }

                foreach (immutable i, charityKey; charityStringTags)
                {
                    if (const charityString = charityKey in charityAA)
                    {
                        //msg-param-charity-learn-more = https://link.twitch.tv/blizzardofbits
                        //msg-param-charity-hashtag = #charity
                        // Pad count by 1 to allow for msg-param-charity-name

                        version(TwitchWarnings) warnAboutOverwrittenAuxString(i+1, charityKey);
                        event.aux[i+1] = *charityString;
                    }
                }

                // Doesn't start with msg-param-charity but it will be set later down
                /*if (const charityTotal = "msg-param-total" in charityAA)
                {
                    //msg-param-charity-hours-remaining = 286
                    event.count[0] = (*charityTotal).to!int;
                }*/

                foreach (immutable i, charityKey; charityCountTags)
                {
                    if (const charityCount = charityKey in charityAA)
                    {
                        //msg-param-charity-hours-remaining
                        //msg-param-charity-days-remaining = 11
                        // Pad count by 1 to allow for msg-param-total

                        version(TwitchWarnings) warnAboutOverwrittenCount(i+1, charityKey);
                        event.count[i+1] = (*charityCount).to!long;
                    }
                }

                // Remove once we have a recorded parse
                version(TwitchWarnings)
                {
                    appendToErrors(event, "RECORD TWITCH CHARITY");
                    printTagsOnExit = true;
                }
                break;

            case "giftpaidupgrade":
            case "anongiftpaidupgrade":
                // "Continuing a gift sub" by gifting a sub you were gifted (?)
                // "A is continuing the Gift Sub they got from B!"
                event.type = TWITCH_GIFTCHAIN;
                break;

            case "primepaidupgrade":
                // User upgrading a prime sub to a normal paid one.
                // "A converted from a Twitch Prime sub to a Tier 1 sub!"
                event.type = TWITCH_SUBUPGRADE;
                break;

            case "bitsbadgetier":
                // User just earned a badge for a tier of bits
                // content is the message body, e.g. "GG"
                event.type = TWITCH_BITSBADGETIER;
                break;

            case "extendsub":
                // User extended their sub, always by a month?
                // "A extended their Tier 1 subscription through April!"
                event.type = TWITCH_EXTENDSUB;
                break;

            case "highlighted-message":
            case "skip-subs-mode-message":
                // These are PRIVMSGs
                version(TwitchWarnings) warnAboutOverwrittenCount(0, msgID, "msg-id");
                event.aux[0] = msgID;
                break;

            case "primecommunitygiftreceived":
                // "A viewer was gifted a World of Tanks: Care Package, courtesy of a Prime member!"
                event.type = TWITCH_GIFTRECEIVED;
                break;

            case "standardpayforward":  // has a target
            case "communitypayforward": // toward community, no target
                // "A is paying forward the Gift they got from B to #channel!"
                event.type = TWITCH_PAYFORWARD;
                break;

            case "crowd-chant":
                // PRIVMSG #fextralife :Clap Clap FeelsBirthdayMan
                // Seemingly no other interesting tags
                event.type = TWITCH_CROWDCHANT;
                break;

            case "announcement":
                // USERNOTICE #zorael :test
                // by /announcement test
                // Unknown Twitch msg-id: announcement
                // Unknown Twitch tag: msg-param-color = PRIMARY
                event.type = TWITCH_ANNOUNCEMENT;
                break;

            case "user-intro":
                // PRIVMSG #ginomachino :yo this is much coller with actual music
                // Unknown Twitch msg-id: user-intro
                event.type = TWITCH_INTRO;
                break;

            /*case "bad_ban_admin":
            case "bad_ban_anon":
            case "bad_ban_broadcaster":
            case "bad_ban_global_mod":
            case "bad_ban_mod":
            case "bad_ban_self":
            case "bad_ban_staff":
            case "bad_commercial_error":
            case "bad_delete_message_broadcaster":
            case "bad_delete_message_mod":
            case "bad_delete_message_error":
            case "bad_marker_client":
            case "bad_mod_banned":
            case "bad_mod_mod":
            case "bad_slow_duration":
            case "bad_timeout_admin":
            case "bad_timeout_broadcaster":
            case "bad_timeout_duration":
            case "bad_timeout_global_mod":
            case "bad_timeout_mod":
            case "bad_timeout_self":
            case "bad_timeout_staff":
            case "bad_unban_no_ban":
            case "bad_unmod_mod":*/

            case "already_banned":
            case "already_emote_only_on":
            case "already_emote_only_off":
            case "already_r9k_on":
            case "already_r9k_off":
            case "already_subs_on":
            case "already_subs_off":
            case "invalid_user":
            case "msg_bad_characters":
            case "msg_channel_blocked":
            case "msg_r9k":
            case "msg_ratelimit":
            case "msg_rejected_mandatory":
            case "msg_room_not_found":
            case "msg_suspended":
            case "msg_timedout":
            case "no_help":
            case "no_permission":
            case "raid_already_raiding":
            case "raid_error_forbidden":
            case "raid_error_self":
            case "raid_error_too_many_viewers":
            case "raid_error_unexpected":
            case "timeout_no_timeout":
            case "unraid_error_no_active_raid":
            case "unraid_error_unexpected":
            case "unrecognized_cmd":
            case "unsupported_chatrooms_cmd":
            case "untimeout_banned":
            case "whisper_banned":
            case "whisper_banned_recipient":
            case "whisper_restricted_recipient":
            case "whisper_invalid_args":
            case "whisper_invalid_login":
            case "whisper_invalid_self":
            case "whisper_limit_per_min":
            case "whisper_limit_per_sec":
            case "whisper_restricted":
            case "msg_subsonly":
            case "msg_verified_email":
            case "msg_slowmode":
            case "tos_ban":
            case "msg_channel_suspended":
            case "msg_banned":
            case "msg_duplicate":
            case "msg_facebook":
            case "turbo_only_color":
            case "unavailable_command":
                // Generic Twitch error.
                event.type = TWITCH_ERROR;

                version(TwitchWarnings) warnAboutOverwrittenAuxString(0, key, "error");
                event.aux[0] = msgID;
                break;

            case "emote_only_on":
            case "emote_only_off":
            case "r9k_on":
            case "r9k_off":
            case "slow_on":
            case "slow_off":
            case "subs_on":
            case "subs_off":
            case "followers_on":
            case "followers_off":
            case "followers_on_zero":

            /*case "usage_ban":
            case "usage_clear":
            case "usage_color":
            case "usage_commercial":
            case "usage_disconnect":
            case "usage_emote_only_off":
            case "usage_emote_only_on":
            case "usage_followers_off":
            case "usage_followers_on":
            case "usage_help":
            case "usage_marker":
            case "usage_me":
            case "usage_mod":
            case "usage_mods":
            case "usage_r9k_off":
            case "usage_r9k_on":
            case "usage_raid":
            case "usage_slow_off":
            case "usage_slow_on":
            case "usage_subs_off":
            case "usage_subs_on":
            case "usage_timeout":
            case "usage_unban":
            case "usage_unmod":
            case "usage_unraid":
            case "usage_untimeout":*/

            case "mod_success":
            case "msg_emotesonly":
            case "msg_followersonly":
            case "msg_followersonly_followed":
            case "msg_followersonly_zero":
            case "msg_rejected":  // "being checked by mods"
            case "raid_notice_mature":
            case "raid_notice_restricted_chat":
            case "room_mods":
            case "timeout_success":
            case "unban_success":
            case "unmod_success":
            case "unraid_success":
            case "untimeout_success":
            case "cmds_available":
            case "color_changed":
            case "commercial_success":
            case "delete_message_success":
            case "ban_success":
            case "no_vips":
            case "no_mods":
                // Generic Twitch server reply.
                event.type = TWITCH_NOTICE;

                version(TwitchWarnings) warnAboutOverwrittenAuxString(0, key, "notice");
                event.aux[0] = msgID;
                break;

            case "midnightsquid":
                // New direct cheer with real currency
                event.type = TWITCH_DIRECTCHEER;

                version(TwitchWarnings) warnAboutOverwrittenAuxString(1, key, "msg-id");
                event.aux[1] = msgID;
                break;

            default:
                import lu.string : beginsWith;

                version(TwitchWarnings) warnAboutOverwrittenAuxString(0, key, "msg-id");
                event.aux[0] = msgID;

                if (msgID.beginsWith("bad_"))
                {
                    event.type = TWITCH_ERROR;
                    break;
                }
                else if (msgID.beginsWith("usage_"))
                {
                    event.type = TWITCH_NOTICE;
                    break;
                }

                version(TwitchWarnings)
                {
                    import std.conv : text;
                    import std.stdio : writeln;

                    immutable msg = text("Unknown Twitch msg-id: ", msgID);
                    appendToErrors(event, msg);
                    writeln(msg);
                    printTagsOnExit = true;
                }
                break;
            }
            break;

        ////////////////////////////////////////////////////////////////////////

         case "display-name":
            // The user’s display name, escaped as described in the IRCv3 spec.
            // This is empty if it is never set.
            import lu.string : strippedRight;

            if (!value.length) break;

            immutable displayName = decodeIRCv3String(value).strippedRight;

            if ((event.type == USERSTATE) || (event.type == GLOBALUSERSTATE))
            {
                // USERSTATE describes the bot in the context of a specific channel,
                // such as what badges are available. It's *always* about the bot,
                // so expose the display name in event.target and let Persistence store it.
                event.target = event.sender;  // get badges etc
                event.target.nickname = parser.client.nickname;
                event.target.displayName = displayName;
                event.target.address = string.init;
                event.sender.colour = string.init;
                event.sender.badges = string.init;

                if (!parser.client.displayName.length)
                {
                    // Also store the alias in the IRCClient, for highlighting purposes
                    // *ASSUME* it never changes during runtime.
                    parser.client.displayName = displayName;
                    version(FlagAsUpdated) parser.updates |= typeof(parser).Update.client;
                }
            }
            else
            {
                // The display name of the sender.
                event.sender.displayName = displayName;
            }
            break;

        case "badges":
            // Comma-separated list of chat badges and the version of each
            // badge (each in the format <badge>/<version>, such as admin/1).
            // Valid badge values: admin, bits, broadcaster, global_mod,
            // moderator, subscriber, staff, turbo.
            // Save the whole list, let the printer deal with which to display
            // Set an empty list to a placeholder asterisk
            event.sender.badges = value.length ? value : "*";
            break;

        case "system-msg":
        case "ban-reason":
            // @ban-duration=<ban-duration>;ban-reason=<ban-reason> :tmi.twitch.tv CLEARCHAT #<channel> :<user>
            // The moderator’s reason for the timeout or ban.
            // system-msg: The message printed in chat along with this notice.
            import lu.string : removeControlCharacters, strippedRight;
            import std.typecons : No, Yes;

            if (!value.length) break;

            immutable message = value
                .decodeIRCv3String
                .strippedRight
                .removeControlCharacters;

            if (event.type == TWITCH_RITUAL)
            {
                version(TwitchWarnings) warnAboutOverwrittenAuxString(0, key);
                event.aux[0] = message;
            }
            else if (!event.content.length)
            {
                event.content = message;
            }
            else if (!event.aux[0].length)
            {
                // If event.content.length but no aux.length, store in aux
                event.aux[0] = message;
            }
            break;

        case "msg-param-recipient-display-name":
        case "msg-param-sender-name":
            // In a GIFTCHAIN the display name of the one who started the gift sub train?
            event.target.displayName = value;
            break;

        case "msg-param-recipient-user-name":
        case "msg-param-sender-login":
        case "msg-param-recipient": // Prime community gift received
            // In a GIFTCHAIN the one who started the gift sub train?
            event.target.nickname = value;
            break;

        case "msg-param-displayName":
        case "msg-param-sender": // Prime community gift received (apparently display name)
            // RAID; sender alias and thus raiding channel cased
            event.sender.displayName = value;
            break;

        case "msg-param-login":
        case "login":
            // RAID; real sender nickname and thus raiding channel lowercased
            // CLEARMSG, SUBGIFT, lots
            event.sender.nickname = value;
            break;

        case "color":
            // Hexadecimal RGB colour code. This is empty if it is never set.
            if (value.length) event.sender.colour = value[1..$];
            break;

        case "bits":
            /*  (Optional) The amount of cheer/bits employed by the user.
                All instances of these regular expressions:

                    /(^\|\s)<emote-name>\d+(\s\|$)/

                (where <emote-name> is an emote name returned by the Get
                Cheermotes endpoint), should be replaced with the appropriate
                emote:

                static-cdn.jtvnw.net/bits/<theme>/<type>/<color>/<size>

                * theme – light or dark
                * type – animated or static
                * color – red for 10000+ bits, blue for 5000-9999, green for
                  1000-4999, purple for 100-999, gray for 1-99
                * size – A digit between 1 and 4
            */
            event.type = TWITCH_CHEER;
            goto case "ban-duration";

        case "msg-param-sub-plan":
            // The type of subscription plan being used.
            // Valid values: Prime, 1000, 2000, 3000.
            // 1000, 2000, and 3000 refer to the first, second, and third
            // levels of paid subscriptions, respectively (currently $4.99,
            // $9.99, and $24.99).
        case "msg-param-promo-name":
            // Promotion name
            // msg-param-promo-name = Subtember
        case "msg-param-trigger-type":
            // reward gift, what kind of event triggered a gifting
            // example values CHEER, SUBGIFT
            // We don't have anywhere to store this without adding altalt
        case "msg-param-gift-name":
            // msg-param-gift-name = "World\sof\sTanks:\sCare\sPackage"
            // Prime community gift name
        case "msg-param-prior-gifter-user-name":
            // msg-param-prior-gifter-user-name = "coopamantv"
            // Prior gifter when a user pays forward a gift
        case "msg-param-color":
            // msg-param-color = PRIMARY
            // msg-param-color = PURPLE
            // seen in a TWITCH_ANNOUNCEMENT
        case "msg-param-currency":
            // New midnightsquid direct cheer currency
        case "message-id":
            // message-id = 3
            // WHISPER, rolling number enumerating messages
        case "reply-parent-msg-body":
            // The body of the message that is being replied to
            // reply-parent-msg-body = she's\sgonna\swin\s2truths\sand\sa\slie\severytime

            /+
                Aux 0
             +/
            version(TwitchWarnings) warnAboutOverwrittenAuxString(0, key);
            event.aux[0] = decodeIRCv3String(value);
            break;

        case "first-msg":
            // first-msg = 0
            // Whether or not it's the user's first message after joining the channel?
            if (value == "0") break;
            value = tag;
            goto case;

        case "msg-param-goal-contribution-type":
            // msg-param-goal-contribution-type = SUB_POINTS
        case "msg-param-gift-theme":
            // msg-param-gift-theme = party
            // Theme of a bulkgift?
        case "msg-param-fun-string":
            // msg-param-fun-string = FunStringTwo
            // [subgift] [#waifugate] AnAnonymousGifter (Asdf): "An anonymous user gifted a Tier 1 sub to Asdf!" (1000) {1}
            // Unsure. Useless.
        case "msg-param-ritual-name":
            // msg-param-ritual-name = 'new_chatter'
        case "msg-param-middle-man":
            // msg-param-middle-man = gabepeixe
            // Prime community gift "middle-man"? Name of the channel?
        case "msg-param-domain":
            // msg-param-domain = owl2018
            // [rewardgift] [#overwatchleague] Asdf [bits]: "A Cheer shared Rewards to 35 others in Chat!" {35}
            // Name of the context?
            // Swapped places with msg-param-trigger-type
        case "msg-param-prior-gifter-display-name":
            // Prior gifter display name when a user pays forward a gift
        case "pinned-chat-paid-currency":
            // elevated message currency

            /+
                Aux 1
             +/
            version(TwitchWarnings) warnAboutOverwrittenAuxString(1, key);
            event.aux[1] = decodeIRCv3String(value);
            break;

        case "msg-param-sub-plan-name":
            // The display name of the subscription plan. This may be a default
            // name or one created by the channel owner.
        case "msg-param-exponent":
            // something with new midnightsquid direct cheers

            /+
                Aux 2
             +/
            version(TwitchWarnings) warnAboutOverwrittenAuxString(2, key);
            event.aux[2] = decodeIRCv3String(value);
            break;

        case "msg-param-goal-description":
            // msg-param-goal-description = Lali-this\sis\sa\sgoal-ho
        case "msg-param-pill-type":
            // something with new midnightsquid direct cheers

            /+
                Aux 3
             +/
            version(TwitchWarnings) warnAboutOverwrittenAuxString(3, key);
            event.aux[3] = decodeIRCv3String(value);
            break;

        case "msg-param-is-highlighted":
            // something with new midnightsquid direct cheers

            /+
                Aux 4
             +/
            version(TwitchWarnings) warnAboutOverwrittenAuxString(4, key);
            event.aux[4] = value;  // no need to decode?
            break;

        case "emotes":
            /++ Information to replace text in the message with emote images.
                This can be empty. Syntax:

                <emote ID>:<first index>-<last index>,
                <another first index>-<another last index>/
                <another emote ID>:<first index>-<last index>...

                * emote ID – The number to use in this URL:
                      http://static-cdn.jtvnw.net/emoticons/v1/:<emote ID>/:<size>
                  (size is 1.0, 2.0 or 3.0.)
                * first index, last index – Character indexes. \001ACTION does
                  not count. Indexing starts from the first character that is
                  part of the user’s actual message. See the example (normal
                  message) below.
             +/
            event.emotes = value;
            break;

        case "msg-param-bits-amount":
            //msg-param-bits-amount = '199'
        case "msg-param-mass-gift-count":
            // Number of subs being gifted
        case "msg-param-total":
            // Total amount donated to this charity
        case "msg-param-threshold":
            // (Sent only on bitsbadgetier) The tier of the bits badge the user just earned; e.g. 100, 1000, 10000.

            // These events are generally present with value of 0, so in most case they're noise
            if (value == "0") break;
            goto case;

        case "ban-duration":
            // @ban-duration=<ban-duration>;ban-reason=<ban-reason> :tmi.twitch.tv CLEARCHAT #<channel> :<user>
            // (Optional) Duration of the timeout, in seconds. If omitted,
            // the ban is permanent.
        case "msg-param-viewerCount":
            // RAID; viewer count of raiding channel
            // msg-param-viewerCount = '9'
        //case "bits": // goto'ed here
        case "msg-param-amount":
            // New midnightsquid direct cheer
        case "pinned-chat-paid-amount":
            // elevated message amount
        case "msg-param-gift-months":
            // ...
        case "msg-param-sub-benefit-end-month":
            /// "...extended their Tier 1 sub to {month}"

            /+
                Count 0
             +/
            version(TwitchWarnings) warnAboutOverwrittenCount(0, key);
            event.count[0] = (value == "0") ? 0 : value.to!long;
            break;

        case "msg-param-selected-count":
            // REWARDGIFT; how many users "the Cheer shared Rewards" with
            // "A Cheer shared Rewards to 20 others in Chat!"
        case "msg-param-promo-gift-total":
            // Number of total gifts this promotion
        case "msg-param-sender-count":
            // Number of gift subs a user has given in the channel, on a SUBGIFT event
        case "pinned-chat-paid-canonical-amount":
            // elevated message, amount in real currency)
            // we can infer it from pinned-chat-paid-amount in event.count[0]
        case "msg-param-cumulative-months":
            // Total number of months subscribed, over time. Replaces msg-param-months

            /+
                Count 1
             +/
            version(TwitchWarnings) warnAboutOverwrittenCount(1, key);

            if (value == "0") break;
            event.count[1] = value.to!long;
            break;

        case "msg-param-gift-month-being-redeemed":
            // Didn't save a description...
        case "msg-param-goal-target-contributions":
            // msg-param-goal-target-contributions = 600
        case "msg-param-min-cheer-amount":
            // REWARDGIFT; of interest?
            // msg-param-min-cheer-amount = '150'
        case "msg-param-charity-hours-remaining":
            // Number of hours remaining in a charity
        case "number-of-viewers":
            // (Optional) Number of viewers watching the host.
        case "msg-param-trigger-amount":
            // reward gift, the "amount" of an event that triggered a gifting
            // (eg "1000" for 1000 bits)
        case "pinned-chat-paid-exponent":
            // something with elevated messages

            /+
                Count 2
             +/
            version(TwitchWarnings) warnAboutOverwrittenCount(2, key);

            if (value == "0") break;
            event.count[2] = value.to!long;
            break;

        case "msg-param-goal-current-contributions":
            // msg-param-goal-current-contributions = 90
        case "msg-param-charity-days-remaining":
            // Number of days remaining in a charity
        case "msg-param-total-reward-count":
            // reward gift, to how many users a reward was gifted
            // alias of msg-param-selected-count?
        case "msg-param-streak-months":
            /// "...extended their Tier 1 sub to {month}"

            /+
                Count 3
             +/
            version(TwitchWarnings) warnAboutOverwrittenCount(3, key);

            if (value == "0") break;
            event.count[3] = value.to!long;
            break;

        case "msg-param-streak-tenure-months":
            /// "...extended their Tier 1 sub to {month}"
        case "msg-param-goal-user-contributions":
            // msg-param-goal-user-contributions = 1

            /+
                Count 4
             +/
            version(TwitchWarnings) warnAboutOverwrittenCount(4, key);

            if (value == "0") break;
            event.count[4] = value.to!long;
            break;

        case "msg-param-cumulative-tenure-months":
            // Ongoing number of subscriptions (in a row)
        case "msg-param-multimonth-duration":
            // msg-param-multimonth-duration = 0
            // Seen in a sub event

            /+
                Count 5
             +/
            version(TwitchWarnings) warnAboutOverwrittenCount(5, key);

            if (value == "0") break;
            event.count[5] = value.to!long;
            break;

        case "msg-param-multimonth-tenure":
            // msg-param-multimonth-tenure = 0
            // Ditto
            // Number of months in a gifted sub?
        case "msg-param-should-share-streak-tenure":
            // Streak resubs

            /+
                Count 6
             +/
            version(TwitchWarnings) warnAboutOverwrittenCount(6, key);

            if (value == "0") break;
            event.count[6] = value.to!long;
            break;

        case "msg-param-should-share-streak":
            // Streak resubs

            /+
                Count 7
             +/
            version(TwitchWarnings) warnAboutOverwrittenCount(7, key);

            if (value == "0") break;
            event.count[7] = value.to!long;
            break;

        case "badge-info":
            /+
                Metadata related to the chat badges in the badges tag.

                Currently this is used only for subscriber, to indicate the exact
                number of months the user has been a subscriber. This number is
                finer grained than the version number in badges. For example,
                a user who has been a subscriber for 45 months would have a
                badge-info value of 45 but might have a badges version number
                for only 3 years.

                https://dev.twitch.tv/docs/irc/tags/
             +/
            // As of yet we're not taking into consideration badge versions values.
            // When/if we do, we'll have to make sure this value overwrites the
            // subscriber/version value in the badges tag.
            // For now, ignore, as "subscriber/*" is repeated in badges.
            break;

        case "id":
            // A unique ID for the message.
            event.id = value;
            break;

        case "msg-param-userID":
        case "user-id":
        case "user-ID":
            // The sender's user ID.
            if (value.length) event.sender.id = value.to!uint;
            break;

        case "target-user-id":
        case "reply-parent-user-id":
        case "msg-param-gifter-id":
            // The target's user ID
            // The user id of the author of the message that is being replied to
            // reply-parent-user-id = 50081302
            if (value.length) event.target.id = value.to!uint;
            break;

        case "room-id":
            // The channel ID.
            if (event.type == ROOMSTATE)
            {
                version(TwitchWarnings) warnAboutOverwrittenAuxString(0, key);
                event.aux[0] = value;
            }
            break;

        case "reply-parent-display-name":
        case "msg-param-gifter-name":
            // The display name of the user that is being replied to
            // reply-parent-display-name = zenArc
            event.target.displayName = value;
            break;

        case "reply-parent-user-login":
        case "msg-param-gifter-login":
            // The account name of the author of the message that is being replied to
            // reply-parent-user-login = zenarc
            event.target.nickname = value;
            break;

        // We only need set cases for every known tag if we want to be alerted
        // when we come across unknown ones, which is version TwitchWarnings.
        // As such, version away all the cases from normal builds, and just let
        // them fall to the default.
        version(TwitchWarnings)
        {
            case "emote-only":
                // We don't conflate ACTION emotes and emote-only messages anymore
                /*if (value == "0") break;
                if (event.type == CHAN) event.type = EMOTE;
                break;*/
            case "broadcaster-lang":
                // The chat language when broadcaster language mode is enabled;
                // otherwise, empty. Examples: en (English), fi (Finnish), es-MX
                // (Mexican variant of Spanish).
            case "subs-only":
                // Subscribers-only mode. If enabled, only subscribers and
                // moderators can chat. Valid values: 0 (disabled) or 1 (enabled).
            case "r9k":
                // R9K mode. If enabled, messages with more than 9 characters must
                // be unique. Valid values: 0 (disabled) or 1 (enabled).
            case "emote-sets":
                // A comma-separated list of emotes, belonging to one or more emote
                // sets. This always contains at least 0. Get Chat Emoticons by Set
                // gets a subset of emoticons.
            case "mercury":
                // ?
            case "followers-only":
                // Probably followers only.
            case "slow":
                // The number of seconds chatters without moderator privileges must
                // wait between sending messages.
            case "sent-ts":
                // ?
            case "tmi-sent-ts":
                // ?
            case "user":
                // The name of the user who sent the notice.
            case "rituals":
                /++
                    "Rituals makes it easier for you to celebrate special moments
                    that bring your community together. Say a viewer is checking out
                    a new channel for the first time. After a minute, she’ll have
                    the choice to signal to the rest of the community that she’s new
                    to the channel. Twitch will break the ice for her in Chat, and
                    maybe she’ll make some new friends.

                    Rituals will help you build a more vibrant community when it
                    launches in November."

                    spotted in the wild as = 0
                +/
            case "msg-param-recipient-id":
                // sub gifts
            case "target-msg-id":
                // banphrase
            case "msg-param-profileImageURL":
                // URL link to profile picture.
            case "flags":
                // Unsure.
                // flags =
                // flags = 4-11:P.5,40-46:P.6
            case "mod":
            case "subscriber":
            case "turbo":
                // 1 if the user has a (moderator|subscriber|turbo) badge; otherwise, 0.
                // Deprecated, use badges instead.
            case "user-type":
                // The user’s type. Valid values: empty, mod, global_mod, admin, staff.
                // Deprecated, use badges instead.
            case "msg-param-origin-id":
                // msg-param-origin-id = 6e\s15\s70\s6d\s34\s2a\s7e\s5b\sd9\s45\sd3\sd2\sce\s20\sd3\s4b\s9c\s07\s49\sc4
                // [subgift] [#savjz] sender [SP] (target): "sender gifted a Tier 1 sub to target! This is their first Gift Sub in the channel!" (1000) {1}
            case "thread-id":
                // thread-id = 22216721_404208264
                // WHISPER, private message session?
            case "msg-param-months":
                // DEPRECATED in favour of msg-param-cumulative-months.
                // The number of consecutive months the user has subscribed for,
                // in a resub notice.
            case "msg-param-charity-hashtag":
                //msg-param-charity-hashtag = #charity
            case "msg-param-charity-name":
                //msg-param-charity-name = Direct\sRelief
            case "msg-param-charity-learn-more":
                //msg-param-charity-learn-more = https://link.twitch.tv/blizzardofbits
                // Do nothing; everything is done at msg-id charity
            case "message":
                // The message.
            case "custom-reward-id":
                // custom-reward-id = f597fc7c-703e-42d8-98ed-f5ada6d19f4b
                // Unsure, was just part of an emote-only PRIVMSG
            case "msg-param-prior-gifter-anonymous":
                // Paying forward gifts, whether or not the prior gifter was anonymous
            case "msg-param-prior-gifter-id":
                // Numeric id of prior gifter when a user pays forward a gift
            case "client-nonce":
                // Opaque nonce ID for this message
            case "reply-parent-msg-id":
                // The msg-id of the message that is being replied to
                // reply-parent-msg-id = 81b6262b-7ce3-4686-be4f-1f5c548c9d16
                // Ignore. Let plugins who want it grep event.tags
            case "msg-param-was-gifted":
                // msg-param-was-gifted = false
                // On subscription events, whether or not the sub was from a gift.
            case "msg-param-anon-gift":
                // msg-param-anon-gift = false
            case "crowd-chant-parent-msg-id":
                // crowd-chant-parent-msg-id = <uuid>
                // Chant? Seems to be a reply/quote
            case "returning-chatter":
                // returning-chatter = 0
                // Unsure.
            case "vip":
                // vip = 1
                // Whether or not the sender is a VIP. Superfluous; we can tell from the badges
            case "msg-param-emote-id":
                // something with new midnightsquid direct cheers

                // Ignore these events.
                break;
        }

        default:
            version(TwitchWarnings)
            {
                import std.conv : text;
                import std.stdio : writeln;

                immutable msg = text("Unknown Twitch tag: ", key, " = ", value);
                appendToErrors(event, msg);
                writeln(msg);
                printTagsOnExit = true;
            }
            break;
        }
    }

    version(TwitchWarnings)
    {
        if (printTagsOnExit)
        {
            import std.stdio : writefln, writeln;

            void printStuffTrusted() @trusted
            {
                /+
                    write{,f}ln is @trusted, but event.aux now being a static string[n]
                    causes it to output a deprecation warning anyway.

                    "Deprecation: `@safe` function `parseTwitchTags` calling `writefln`"
                 +/
                enum pattern = `%-35s%s`;
                writefln(pattern, "event.aux", event.aux);
                writefln(pattern, "event.count", event.count);
                writeln();
            }

            printTags(tagRange, event);
            printStuffTrusted();
            writeln();
        }
    }
}


package:


// TwitchPostprocessor
/++
    Twitch-specific postprocessor.

    Twitch events are initially very basic with only skeletal functionality,
    until you enable capabilities that unlock their IRCv3 tags, at which point
    events become a flood of information.
 +/
final class TwitchPostprocessor : Postprocessor
{
    // postprocess
    /++
        Handle Twitch specifics, modifying the [dialect.defs.IRCEvent|IRCEvent]
        to add things like [dialect.defs.IRCEvent.colour|IRCEvent.colour] and
        differentiate between temporary and permanent bans.

        Params:
            parser = Current [dialect.parsing.IRCParser|IRCParser].
            event = [dialect.defs.IRCEvent|IRCEvent] in flight.
     +/
    void postprocess(
        ref IRCParser parser,
        ref IRCEvent event) @system
    {
        if (parser.server.daemon != IRCServer.Daemon.twitch) return;

        parser.parseTwitchTags(event);

        with (IRCEvent.Type)
        {
            if ((event.type == CLEARCHAT) && event.target.nickname.length)
            {
                // Stay CLEARCHAT if no target nickname
                event.type = (!event.count[0].isNull && (event.count[0].get > 0)) ?
                    TWITCH_TIMEOUT :
                    TWITCH_BAN;
            }
        }

        if (event.sender.nickname.length)
        {
            // Twitch nicknames are always the same as the user account; the
            // displayed name/alias is sent separately as a "display-name" IRCv3 tag
            event.sender.account = event.sender.nickname;
        }

        if (event.target.nickname.length)
        {
            // Likewise sync target nickname and account.
            event.target.account = event.target.nickname;
        }
    }
}
