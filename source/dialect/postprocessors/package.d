/++
 +  Postprocessor package module. Only enumerates the postprocessors into an
 +  `std.meta.AliasSeq` for easy foreaching.
 +/
module dialect.postprocessors;

private:

import std.meta : AliasSeq;

public:


// Postprocessors
/++
 +  A list of all postprocessor modules, by string name so they can be resolved
 +  even in `singleFile` mode. These will be instantiated in the order listed.
 +/
alias Postprocessors = AliasSeq!(
    "dialect.postprocessors.twitch",
);
