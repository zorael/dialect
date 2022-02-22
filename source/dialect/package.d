/++
    $(B dialect) is an IRC parser. It parses strings as read from an IRC server
    into useful [dialect.defs.IRCEvent|IRCEvent] structs.

    It only handles parsing; for a bot, try $(B kameloso) at
    [https://github.com/zorael/kameloso].
 +/
module dialect;

public import dialect.defs;
public import dialect.parsing;
public import dialect.common;
public import dialect.semver;
