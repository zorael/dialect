/++
    The Twitch postprocessor processes [dialect.defs.IRCEvent|IRCEvent]s after
    they are parsed, and deals with Twitch-specifics. Those include extracting
    the colour someone's name should be printed in, their alias/"display name"
    (generally their nickname cased), converting the event to some event types
    unique to Twitch, etc.

    Copyright: [JR](https://github.com/zorael)
    License: [Boost Software License 1.0](https://www.boost.org/users/license.html)

    Authors:
        [JR](https://github.com/zorael)
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
    import lu.string : removeControlCharacters, strippedRight;
    import std.algorithm.iteration : splitter;
    import std.conv : to;

    // https://dev.twitch.tv/docs/v5/guides/irc/#twitch-irc-capability-tags

    if (!event.tags.length) return;

    auto tagRange = event.tags.splitter(";");  // mutable

    version(TwitchWarnings)
    {
        /++
            Whether or not an error occurred and debug information should be printed
            upon leaving the function.
         +/
        bool printTagsOnExit;
    }

    with (IRCEvent.Type)
    foreach (immutable tagline; tagRange)
    {
        import lu.string : advancePast;

        string slice = tagline;  // mutable
        immutable key = slice.advancePast('=');
        alias value = slice;

        switch (key)
        {
        case "msg-id":
            if (!value.length) break;

            switchOnMsgID(
                event: event,
                msgID: value,
                onlySetType: false);
            break;

        case "display-name":
            // The user’s display name, escaped as described in the IRCv3 spec.
            // This is empty if it is never set.
            if (!value.length) break;

            if ((event.type == USERSTATE) || (event.type == GLOBALUSERSTATE))
            {
                // USERSTATE describes the bot in the context of a specific channel,
                // such as what badges are available. It's *always* about the bot,
                // so expose the display name in event.target and let Persistence store it.
                immutable displayName = decodeIRCv3String(value).strippedRight;

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
                goto case "msg-param-displayName";
            }
            break;

        case "badges":
            // Comma-separated list of chat badges and the version of each
            // badge (each in the format <badge>/<version>, such as admin/1).
            // Valid badge values: admin, bits, broadcaster, global_mod,
            // moderator, subscriber, staff, turbo.
            // Save the whole list, let the user deal with which to display
            if (!value.length)
            {
                if (!event.sender.badges.length)
                {
                    // Set an empty list to a placeholder asterisk
                    event.sender.badges = "*";
                }
            }
            else
            {
                if (event.sender.badges == "*")
                {
                    // If we have an asterisk, replace it with the new value
                    event.sender.badges = value;
                }
                else
                {
                    // Order badge-info before badges
                    event.sender.badges = event.sender.badges.length ?
                        event.sender.badges ~ ',' ~ value :
                        value;
                }
            }
            break;

        case "system-msg":
        case "ban-reason":
            // @ban-duration=<ban-duration>;ban-reason=<ban-reason> :tmi.twitch.tv CLEARCHAT #<channel> :<user>
            // The moderator’s reason for the timeout or ban.
            // system-msg: The message printed in chat along with this notice.
            if (!value.length) break;

            immutable message = value
                .decodeIRCv3String
                .strippedRight
                .removeControlCharacters;

            if (!event.content.length && (event.type != TWITCH_RITUAL))
            {
                event.content = message;
            }
            else
            {
                version(TwitchWarnings)
                {
                    warnAboutOverwrittenString(
                        event: event,
                        name: "event.altcontent",
                        oldValue: event.altcontent,
                        newValue: message,
                        key: key,
                        tagType: "tag",
                        printTagsOnExit: printTagsOnExit);
                }

                event.altcontent = message;
            }
            break;

        case "msg-param-gift-match-gifter-display-name":
            // msg-param-gift-match-gifter-display-name = SuszterSpace
            // Gifter to whose gifting more gifts were added by a third party
        case "reply-parent-display-name":
        case "msg-param-gifter-name":
            // The display name of the user that is being replied to
            // reply-parent-display-name = zenArc
        case "msg-param-recipient-display-name":
        case "msg-param-sender-name":
            // In a GIFTCHAIN the display name of the one who started the gift sub train?
            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.target.displayName",
                    oldValue: event.target.displayName,
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.target.displayName = value;
            break;

        case "msg-param-recipient-user-name":
        case "msg-param-sender-login":
        case "msg-param-recipient": // Prime community gift received
            // In a GIFTCHAIN the one who started the gift sub train?
            // msg-param-prior-gifter-user-name = "coopamantv"
        case "reply-parent-user-login":
        case "msg-param-gifter-login":
            // The account name of the author of the message that is being replied to
            // reply-parent-user-login = zenarc

            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.target.nickname",
                    oldValue: event.target.nickname,
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.target.nickname = value;
            break;

        case "msg-param-displayName":
        case "msg-param-sender": // Prime community gift received (apparently display name)
            // RAID; sender alias and thus raiding channel cased
            immutable displayName = value
                .decodeIRCv3String
                .strippedRight;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.sender.displayName",
                    oldValue: event.sender.displayName,
                    newValue: displayName,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.sender.displayName = displayName;
            break;

        case "msg-param-login":
        case "login":
            // RAID; real sender nickname and thus raiding channel lowercased
            // CLEARMSG, SUBGIFT, lots
            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.sender.nickname",
                    oldValue: event.sender.nickname,
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

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
            goto case "ban-duration";  // set count[0]

        case "reply-parent-msg-body":
            // The body of the message that is being replied to
            // reply-parent-msg-body = she's\sgonna\swin\s2truths\sand\sa\slie\severytime
            immutable message = value
                .decodeIRCv3String
                .strippedRight
                .removeControlCharacters;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.altcontent",
                    oldValue: event.altcontent,
                    newValue: message,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.altcontent = message;
            break;

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
        case "msg-param-color":
            // msg-param-color = PRIMARY
            // msg-param-color = PURPLE
            // seen in a TWITCH_ANNOUNCEMENT
        case "msg-param-currency":
            // New midnightsquid direct cheer currency
        case "msg-param-category":
            // Viewer milestone thing
        case "msg-param-charity-name":
            // msg-param-charity-name = Direct\sRelief

            /+
                Aux 0
             +/
            immutable message = value
                .decodeIRCv3String
                .strippedRight
                .removeControlCharacters;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.aux[0]",
                    oldValue: event.aux[0],
                    newValue: message,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.aux[0] = message;
            break;

        case "msg-param-prior-gifter-id":
            // Numeric id of prior gifter when a user pays forward a gift
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
        case "pinned-chat-paid-currency":
            // elevated message currency
        case "msg-param-gift-match":
            // msg-param-gift-match = extra
        case "animation-id":
            // Animated message animation ID
            // values like "simmer", "rainbow-eclipse", "cosmic-abyss"
        case "msg-param-charity-learn-more":
            // msg-param-charity-learn-more = https://link.twitch.tv/blizzardofbits
        case "msg-param-donation-currency":
            // msg-param-donation-currency = USD

            /+
                Aux 1
             +/
            immutable decoded = decodeIRCv3String(value);

            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.aux[1]",
                    oldValue: event.aux[1],
                    newValue: decoded,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.aux[1] = decoded;
            break;

        case "msg-param-sub-plan-name":
            // The display name of the subscription plan. This may be a default
            // name or one created by the channel owner.
        //case "msg-param-exponent":
            // something with new midnightsquid direct cheers
        case "pinned-chat-paid-level":
            // pinned-chat-paid-level = ONE
            // Something about hype chat?
        case "msg-param-charity-hashtag":
            // msg-param-charity-hashtag = #charity
        case "msg-param-prior-gifter-user-name":
            // Prior gifter when a user pays forward a gift

            /+
                Aux 2
             +/
            immutable decoded = decodeIRCv3String(value);

            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.aux[2]",
                    oldValue: event.aux[2],
                    newValue: decoded,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.aux[2] = decoded;
            break;

        case "msg-param-goal-description":
            // msg-param-goal-description = Lali-this\sis\sa\sgoal-ho
        case "msg-param-pill-type":
            // something with new midnightsquid direct cheers
        case "msg-param-prior-gifter-display-name":
            // Prior gifter display name when a user pays forward a gift

            /+
                Aux 3
             +/
            immutable decoded = decodeIRCv3String(value);

            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.aux[3]",
                    oldValue: event.aux[3],
                    newValue: decoded,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.aux[3] = decoded;
            break;

        case "msg-param-is-highlighted":
            // something with new midnightsquid direct cheers

            /+
                Aux 4, key as value
             +/
            if (value == "false") break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.aux[4]",
                    oldValue: event.aux[4],
                    newValue: key[10..$],
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.aux[4] = key[10..$];  // slice away "msg-param-"
            break;

        case "msg-param-gift-theme":
            // msg-param-gift-theme = party
            // Theme of a bulkgift?
        case "msg-param-gifter-id":
            // How is this different from msg-param-prior-gifter-id?

            /+
                Aux 4, value as value
             +/
            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.aux[4]",
                    oldValue: event.aux[4],
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.aux[4] = value;  // no need to decode?
            break;

        case "msg-param-goal-contribution-type":
            // msg-param-goal-contribution-type = SUB_POINTS

            /+
                Aux 5
             +/
            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.aux[5]",
                    oldValue: event.aux[5],
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.aux[5] = value;  // no need to decode?
            break;

        case "msg-param-was-gifted":
            // msg-param-was-gifted = false
            // On subscription events, whether or not the sub was from a gift.

            /+
                Aux 6
             +/
            if (value == "false") break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.aux[6]",
                    oldValue: event.aux[6],
                    newValue: key[10..$],
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.aux[6] = key[10..$];  // slice away "msg-param-"
            break;

        case "msg-param-anon-gift":
            // msg-param-anon-gift = false
            // Can happen at the same time as msg-param-was-gifted, so has to be separate

            /+
                Aux 7
             +/
            if (value == "false") break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.aux[7]",
                    oldValue: event.aux[7],
                    newValue: key[10..$],
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.aux[7] = key[10..$];  // slice away "msg-param-"
            break;

        case "first-msg":
            // first-msg = 0
            // Whether or not it's the user's first message after joining the channel
            if (value == "0") break;

            /+
                Aux $-3, key as value

                Reserve this for first-msg. Set the key, not the 0/1 value.
             +/
            version(TwitchWarnings)
            {
                warnAboutOverwrittenString(
                    event: event,
                    name: "event.aux[$-3]",
                    oldValue: event.aux[$-3],
                    newValue: key,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.aux[$-3] = key;
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
            // "...extended their Tier 1 sub to {month}"
        case "msg-param-value":
            // Viewer milestone thing; consecutive streams watched
        case "msg-param-donation-amount":
            // msg-param-donation-amount = 500
            // Real value is 1/100 the number, so here $5
        case "message-id":
            // message-id = 3
            // WHISPER, rolling number enumerating messages

            /+
                Count 0
             +/
            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.count[0]",
                    oldValue: event.count[0],
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.count[0] = value.to!long;
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
        case "msg-param-copoReward":
            // Viewer milestone thing
        case "msg-param-gift-match-bonus-count":
            // msg-param-gift-match-bonus-count = 5
        case "msg-param-charity-hours-remaining":
            // Number of hours remaining in a charity

            /+
                Count 1
             +/
            if (value == "0") break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.count[1]",
                    oldValue: event.count[1],
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.count[1] = value.to!long;
            break;

        case "msg-param-gift-month-being-redeemed":
            // Didn't save a description...
        case "msg-param-goal-target-contributions":
            // msg-param-goal-target-contributions = 600
        case "msg-param-min-cheer-amount":
            // REWARDGIFT; of interest?
            // msg-param-min-cheer-amount = '150'
        case "number-of-viewers":
            // (Optional) Number of viewers watching the host.
        case "msg-param-trigger-amount":
            // reward gift, the "amount" of an event that triggered a gifting
            // (eg "1000" for 1000 bits)
        case "pinned-chat-paid-exponent":
            // something with elevated messages
        case "msg-param-gift-match-extra-count":
            // msg-param-gift-match-extra-count = 2
        case "msg-param-charity-days-remaining":
            // Number of days remaining in a charity

            /+
                Count 2
             +/
            if (value == "0") break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.count[2]",
                    oldValue: event.count[2],
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.count[2] = value.to!long;
            break;

        case "msg-param-goal-current-contributions":
            // msg-param-goal-current-contributions = 90
        case "msg-param-total-reward-count":
            // reward gift, to how many users a reward was gifted
            // alias of msg-param-selected-count?
        case "msg-param-streak-months":
            // "...extended their Tier 1 sub to {month}"

            /+
                Count 3
             +/
            if (value == "0") break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.count[3]",
                    oldValue: event.count[3],
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.count[3] = value.to!long;
            break;

        case "msg-param-streak-tenure-months":
            /// "...extended their Tier 1 sub to {month}"
        case "msg-param-goal-user-contributions":
            // msg-param-goal-user-contributions = 1

            /+
                Count 4
             +/
            if (value == "0") break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.count[4]",
                    oldValue: event.count[4],
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

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
            if (value == "0") break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.count[5]",
                    oldValue: event.count[5],
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

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
            if (value == "0") break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.count[6]",
                    oldValue: event.count[6],
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.count[6] = value.to!long;
            break;

        case "msg-param-should-share-streak":
            // Streak resubs

            /+
                Count 7
             +/
            if (value == "0") break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.count[7]",
                    oldValue: event.count[7],
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

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
            if (!value.length)
            {
                if (!event.sender.badges.length)
                {
                    // Set an empty list to a placeholder asterisk
                    event.sender.badges = "*";
                }
            }
            else
            {
                if (event.sender.badges == "*")
                {
                    // If we have an asterisk, replace it with the new value
                    event.sender.badges = value;
                }
                else
                {
                    // Order badge-info before badges
                    event.sender.badges = event.sender.badges.length ?
                        value ~ ',' ~ event.sender.badges :
                        value;
                }
            }
            break;

        case "id":
            // A unique ID for the message.
            event.id = value;
            break;

        case "msg-param-userID":
        case "user-id":
        case "user-ID":
            // The sender's user ID.
            if (!value.length) break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.sender.id",
                    oldValue: event.sender.id,
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.sender.id = value.to!ulong;
            break;

        case "target-user-id":
            // The target's user ID
        case "reply-parent-user-id":
            // The user id of the author of the message that is being replied to
        case "msg-param-recipient-id":
            // reply-parent-user-id = 50081302
            // sub gift target
            if (!value.length) break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.target.id",
                    oldValue: event.target.id,
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.target.id = value.to!ulong;
            break;

        case "room-id":
            // The channel ID.
            if (!value.length) break;

            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.channel.id",
                    oldValue: event.channel.id,
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.channel.id = value.to!ulong;
            break;

        case "source-msg-id":
            if (!value.length) break;

            switchOnMsgID(
                event: event,
                msgID: value,
                onlySetType: true);
            break;

        case "source-room-id":
            // Origin channel ID of shared chat message
            version(TwitchWarnings)
            {
                warnAboutOverwrittenNumber(
                    event: event,
                    name: "event.subchannel.id",
                    oldValue: event.subchannel.id,
                    newValue: value,
                    key: key,
                    tagType: "tag",
                    printTagsOnExit: printTagsOnExit);
            }

            event.subchannel.id = value.to!ulong;
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
            case "message":
                // The message.
            case "custom-reward-id":
                // custom-reward-id = f597fc7c-703e-42d8-98ed-f5ada6d19f4b
                // Unsure, was just part of an emote-only PRIVMSG
            case "msg-param-prior-gifter-anonymous":
                // Paying forward gifts, whether or not the prior gifter was anonymous
            case "client-nonce":
                // Opaque nonce ID for this message
            case "reply-parent-msg-id":
                // The msg-id of the message that is being replied to
                // reply-parent-msg-id = 81b6262b-7ce3-4686-be4f-1f5c548c9d16
                // Ignore. Let plugins who want it grep event.tags
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
            case "reply-thread-parent-msg-id":
                // Message ID of reply thread parent?
            case "pinned-chat-paid-is-system-message":
                // pinned-chat-paid-is-system-message = 1
                // Something about hype chat. ...what's a system message?
            case "reply-thread-parent-user-login":
                // Login of reply thread parent?
            case "reply-thread-parent-user-id":
                // Parent Twitch ID
            case "reply-thread-parent-display-name":
                // Display name of reply thread parent? We're not interested in the parent at the moment
            case "msg-param-id":
                // Viewer milestone thing. Triggering message id?
            case "msg-param-community-gift-id":
                // submysterygift ID?
            case "source-badge-info":
            case "source-badges":
            case "source-id":
            case "source-only":
            //case "source-room-id":
            case "msg-param-exponent":
            // something with new midnightsquid direct cheers
            // also present in charitydonation events, in which it is noise

                // Ignore these events.
                break;
        }

        default:
            version(TwitchWarnings)
            {
                import std.conv : text;
                import std.stdio : writeln;

                immutable message = text("Unknown Twitch tag: ", key, " = ", value);
                appendToErrors(event, message);
                writeln(message);
                printTagsOnExit = true;
            }
            break;
        }
    }

    // The subscriber badge is often duplicated
    if (event.sender.badges.length) deduplicateBadges(event.sender.badges, "subscriber/");
    if (event.target.badges.length) deduplicateBadges(event.target.badges, "subscriber/");

    version(TwitchWarnings)
    {
        if (printTagsOnExit)
        {
            import lu.conv : toString;
            import std.algorithm.iteration : map;
            import std.conv : to;
            import std.stdio : writefln, writeln;

            enum quotedPattern = `%-35s"%s"`;
            enum plainPattern  = `%-35s%s`;
            enum arrayPattern  = `%-35s[%-(%s, %)]`;

            alias underscoreNull = (n) => n.isNull ? "_" : n.get().to!string;

            writeln();
            printTags(event);
            writeln("---");
            writefln(plainPattern, "event.type", event.type.toString());
            writefln(plainPattern, "event.channel.name", event.channel.name);
            writefln(plainPattern, "event.channel.id", event.channel.id);
            writefln(plainPattern, "event.subchannel.name", event.subchannel.name);
            writefln(plainPattern, "event.subchannel.id", event.subchannel.id);
            writefln(quotedPattern, "event.content", event.content);
            writefln(plainPattern, "event.aux", event.aux[]);  // plain is fine, same output as array
            writefln(arrayPattern, "event.count", event.count[].map!underscoreNull);
            writeln();
        }
    }
}


// appendToErrors
/++
    Appends an error to an [dialect.defs.IRCEvent|IRCEvent]'s error string member.

    Note: Gated behind version `TwitchWarnings`.

    Params:
        event = The [dialect.defs.IRCEvent|IRCEvent] to append the error to.
        message = The error message to append.
 +/
version(TwitchWarnings)
void appendToErrors(ref IRCEvent event, const string message) pure @safe nothrow
{
    enum spacer = " | ";
    event.errors = event.errors.length ?
        event.errors ~ spacer ~ message :
        message;
}


// printTags
/++
    Prints the tags of an [dialect.defs.IRCEvent|IRCEvent] to the console.

    Note: Gated behind version `TwitchWarnings`.

    Params:
        event = The [dialect.defs.IRCEvent|IRCEvent] to print the tags of.
 +/
version(TwitchWarnings)
void printTags(const ref IRCEvent event) @safe
{
    import lu.string : advancePast;
    import std.algorithm.iteration : splitter;
    import std.stdio : writefln, writeln;

    writeln('@', event.tags, ' ', event.raw, '$');
    auto tagRange = event.tags.splitter(";");  // mutable

    if (!tagRange.empty) writeln("---");

    foreach (immutable tagline; tagRange)
    {
        string slice = tagline;  // mutable
        immutable key = slice.advancePast('=');
        alias value = slice;

        enum pattern = `%-35s"%s"`;
        writefln(pattern, key, value);
    }
}


// warnAboutOverwrittenString
/++
    Warns about twhen a string member of an
    [dialect.defs.IRCEvent|IRCEvent] is to be overwritten.

    Note: Gated behind version `TwitchWarnings`.

    Params:
        event = The [dialect.defs.IRCEvent|IRCEvent] whose `aux` element was overwritten.
        value = The value of the string that will be overwritten.
        name = The name of the string being overwritten.
        key = The key of the tag that is overwriting the string.
        tagType = The type of tag that is overwriting the string.
        printTagsOnExit = Whether or not the caller should print the tags of the
            [dialect.defs.IRCEvent|IRCEvent] upon leaving its function.
 +/
version(TwitchWarnings)
void warnAboutOverwrittenString(
    /*const*/ ref IRCEvent event,
    const string name,
    const string oldValue,
    const string newValue,
    const string key,
    const string tagType,
    ref bool printTagsOnExit) @safe
{
    if (oldValue.length && (oldValue != newValue))
    {
        import std.format : format;
        import std.stdio : writeln;

        enum pattern = "%s %s overwrote string `%s`! \"%s\" --> \"%s\"";
        immutable message = pattern.format(
            tagType,
            key,
            name,
            oldValue,
            newValue);

        appendToErrors(event, message);
        writeln(message);
        printTagsOnExit = true;
    }
}


// warnAboutOverwrittenNumber
/++
    Warns about twhen a numeric member of an
    [dialect.defs.IRCEvent|IRCEvent] is to be overwritten.

    Note: Gated behind version `TwitchWarnings`.

    Params:
        event = The [dialect.defs.IRCEvent|IRCEvent] whose `aux` element was overwritten.
        value = The value of the string that will be overwritten.
        name = The name of the string being overwritten.
        key = The key of the tag that is overwriting the string.
        tagType = The type of tag that is overwriting the string.
        printTagsOnExit = Whether or not the caller should print the tags of the
            [dialect.defs.IRCEvent|IRCEvent] upon leaving its function.
 +/
version(TwitchWarnings)
void warnAboutOverwrittenNumber(Old, New)
    (/*const*/ ref IRCEvent event,
    const string name,
    const Old oldValue,
    const New newValue,
    const string key,
    const string tagType,
    ref bool printTagsOnExit) @safe
{
    import std.typecons : Nullable;

    static if (is(Old : Nullable!long))
    {
        immutable old_ = oldValue.isNull ? 0 : oldValue.get();
    }
    else
    {
        alias old_ = oldValue;
    }

    if (old_ != 0)
    {
        import std.format : format;
        import std.stdio : writeln;

        static if (is(New : string))
        {
            import std.conv : to;
            immutable new_ = newValue.to!long;
        }
        else
        {
            alias new_ = newValue;
        }

        enum pattern = "%s %s overwrote numeric `%s`! %d --> %d";
        immutable message = pattern.format(
            tagType,
            key,
            name,
            old_,
            new_);

        appendToErrors(event, message);
        writeln(message);
        printTagsOnExit = true;
    }
}


// switchOnMsgID
/++
    Switches on a message ID string and resolves the type of an
    [dialect.defs.IRCEvent|IRCEvent].

    Broken out of [parseTwitchTags] for readability.

    Params:
        event = The [dialect.defs.IRCEvent|IRCEvent] to resolve the type of.
        msgID = The message ID string to switch on.
        onlySetType = Whether or not to only set the type of the
            [dialect.defs.IRCEvent|IRCEvent]; if `false`, more information is
            set in the [dialect.defs.IRCEvent|IRCEvent].
 +/
void switchOnMsgID(
    ref IRCEvent event,
    const string msgID,
    const bool onlySetType) @safe
{
    import std.conv : to;

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

    version(TwitchWarnings)
    {
        /++
            Whether or not an error occurred and debug information should be printed
            upon leaving the function.
         +/
        bool printTagsOnExit;
    }

    with (IRCEvent.Type)
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
            For anything anonomous [sic]
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
        event.type = TWITCH_CHARITY;
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

    case "gigantified-emote-message":
        // Unknown Twitch msg-id: gigantified-emote-message
        event.type = EMOTE;
        goto case;

    case "highlighted-message":
    case "skip-subs-mode-message":
        // These are PRIVMSGs
    case "animated-message":
        // Unknown Twitch msg-id: animated-message
        // keep the type as PRIVMSG

        if (onlySetType) break;

        version(TwitchWarnings)
        {
            warnAboutOverwrittenString(
                event: event,
                name: "event.aux[0]",
                oldValue: event.aux[0],
                newValue: msgID,
                key: msgID,
                tagType: "msg-id",
                printTagsOnExit: printTagsOnExit);
        }

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

    case "viewermilestone":
        // Unknown Twitch msg-id: viewermilestone
        event.type = TWITCH_MILESTONE;
        break;

    case "msg_warned":
        // Unknown Twitch msg-id: warned
        event.type = TWITCH_WARNED;
        break;

    case "msg_banned":
        event.type = ERR_BANNEDFROMCHAN;
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
    case "msg_duplicate":
    case "msg_facebook":
    case "turbo_only_color":
    case "unavailable_command":
        // Generic Twitch error.
        event.type = TWITCH_ERROR;
        if (onlySetType) break;

        version(TwitchWarnings)
        {
            warnAboutOverwrittenString(
                event: event,
                name: "event.aux[0]",
                oldValue: event.aux[0],
                newValue: msgID,
                key: msgID,
                tagType: "msg-id",
                printTagsOnExit: printTagsOnExit);
        }

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
        if (onlySetType) break;

        version(TwitchWarnings)
        {
            warnAboutOverwrittenString(
                event: event,
                name: "event.aux[0]",
                oldValue: event.aux[0],
                newValue: msgID,
                key: msgID,
                tagType: "msg-id",
                printTagsOnExit: printTagsOnExit);
        }

        event.aux[0] = msgID;
        break;

    case "midnightsquid":
        // New direct cheer with real currency
        event.type = TWITCH_DIRECTCHEER;
        if (onlySetType) break;

        version(TwitchWarnings)
        {
            warnAboutOverwrittenString(
                event: event,
                name: "event.aux[1]",
                oldValue: event.aux[1],
                newValue: msgID,
                key: msgID,
                tagType: "msg-id",
                printTagsOnExit: printTagsOnExit);
        }

        event.aux[1] = msgID;
        break;

    case "sharedchatnotice":
        // Leave event type as it is, it's probably CHAN
        if (onlySetType) break;

        version(TwitchWarnings)
        {
            warnAboutOverwrittenString(
                event: event,
                name: "event.aux[8]",
                oldValue: event.aux[8],
                newValue: msgID,
                key: msgID,
                tagType: "msg-id",
                printTagsOnExit: printTagsOnExit);
        }

        event.aux[8] = msgID;
        break;

    case "charitydonation":
        event.type = TWITCH_CHARITYDONATION;
        break;

    default:
        import std.algorithm.searching : startsWith;

        if (msgID.startsWith("bad_"))
        {
            event.type = TWITCH_ERROR;
            break;
        }
        else if (msgID.startsWith("usage_"))
        {
            event.type = TWITCH_NOTICE;
            break;
        }

        version(TwitchWarnings)
        {
            import std.stdio : writeln;

            immutable message = "Unknown Twitch msg-id: " ~ msgID;
            appendToErrors(event, message);
            writeln(message);
            printTagsOnExit = true;
        }

        if (onlySetType) break;

        version(TwitchWarnings)
        {
            warnAboutOverwrittenString(
                event: event,
                name: "event.aux[0]",
                oldValue: event.aux[0],
                newValue: msgID,
                key: msgID,
                tagType: "msg-id",
                printTagsOnExit: printTagsOnExit);
        }

        event.aux[0] = msgID;
        break;
    }
}


// deduplicateBadges
/++
    Deduplicates a badge in a comma-separated list of badges.

    Note: This only removes one duplicate badge, if present. It can trivially
    be made recursive.

    Params:
        badges = A reference to the comma-separated string of badges to deduplicate in place.
        badge = The badge to deduplicate.
 +/
void deduplicateBadges(ref string badges, const string badge) pure @safe nothrow
{
    import std.string : indexOf;

    if (!badges.length || !badge.length) return;

    immutable firstBadge = badges.indexOf(badge);

    if (firstBadge != -1)
    {
        immutable offset = firstBadge+badge.length + 1;
        immutable secondBadge = badges.indexOf(badge, offset);

        if (secondBadge != -1)
        {
            // There are at least two subscriber badges, one from the badge
            // tag and one from badge-info. The first one is the one we want.
            immutable secondOffset = secondBadge + badge.length + 1;
            immutable secondCommaPos = badges.indexOf(',', secondOffset);

            if (secondCommaPos != -1)
            {
                // Remove the second subscriber badge
                badges =
                    badges[0..secondBadge] ~
                    badges[secondCommaPos+1..$];
            }
            else
            {
                badges = badges[0..secondBadge-1];
            }
        }
    }
}

///
unittest
{
    {
        string badges = "subscriber/14,subscriber/12,bits/30000";
        deduplicateBadges(badges, "subscriber/");
        assert((badges == "subscriber/14,bits/30000"), badges);
    }
    {
        string badges = "subscriber/1,subscriber/0";
        deduplicateBadges(badges, "subscriber/");
        assert((badges == "subscriber/1"), badges);
    }
    {
        string badges = "vip/1,subscriber/19,subscriber/17,partner/1";
        deduplicateBadges(badges, "subscriber/");
        assert((badges == "vip/1,subscriber/19,partner/1"), badges);
    }
    {
        string badges = "subscriber/28,broadcaster/1,subscriber/12,partner/1";
        deduplicateBadges(badges, "subscriber/");
        assert((badges == "subscriber/28,broadcaster/1,partner/1"), badges);
    }
    {
        string badges;
        deduplicateBadges(badges, string.init);
        assert(!badges.length, badges);
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
