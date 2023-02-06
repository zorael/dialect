/++
    Postprocessor package module. Only enumerates the postprocessors into an
    [std.meta.AliasSeq|AliasSeq] for easy foreaching.
 +/
module dialect.postprocessors;

private:

import dialect.defs : IRCEvent;
import dialect.parsing : IRCParser;
import std.meta : AliasSeq;

public:


// Postprocessor
/++
    Postprocessor interface for concrete postprocessors to inherit from.

    Postprocessors modify [dialect.defs.IRCEvent|IRCEvent]s after they are parsed,
    before returning the final object to the caller. This is used to provide support
    for Twitch servers, where most information is carried in IRCv3 tags prepended
    to the raw server strings. The normal parser routine just separates the tags
    from the normal string, parses it as per usual, and lets postprocessors
    interpret the tags. Or not, depending on what build configuration was compiled.
 +/
interface Postprocessor
{
    /++
        Postprocesses an [dialect.defs.IRCEvent|IRCEvent].
     +/
    void postprocess(ref IRCParser, ref IRCEvent) @system;
}


// Postprocessors
/++
    A list of all postprocessor modules, by string name so they can be resolved
    even in `singleFile` mode. These will be instantiated in the order listed.
 +/
alias Postprocessors = AliasSeq!(
    "dialect.postprocessors.twitch",
);
