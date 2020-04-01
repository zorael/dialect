/++
 +  Postprocessor package module. Only enumerates the postprocessors into an
 +  `std.meta.AliasSeq` for easy foreaching.
 +/
module dialect.postprocessors;

@safe:

import std.meta : AliasSeq;

version(TwitchSupport)
{
    import dialect.postprocessors.twitch : TwitchPostprocessor;
}
else
{
    // Non-twitch build but we still need the alias for `EnabledPostprocessors` below.
    alias TwitchPostprocessor = AliasSeq!();
}


/// List of enabled postprocessors.
public alias EnabledPostprocessors = AliasSeq!(
    TwitchPostprocessor,
);
