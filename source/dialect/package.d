/++
    $(B dialect) is an IRC parser. It parses strings as read from an IRC server
    into useful [dialect.defs.IRCEvent|IRCEvent] structs.

    It only handles parsing; for a bot, try $(B kameloso) at
    [https://github.com/zorael/kameloso].

    Copyright: [JR](https://github.com/zorael)
    License: [Boost Software License 1.0](https://www.boost.org/users/license.html)

    Authors:
        [JR](https://github.com/zorael)
 +/
module dialect;

public import dialect.defs;
public import dialect.parsing;
public import dialect.common;
public import dialect.semver;
public import dialect.postprocessors;