/++
 +  Postprocessor package module. Conditionally imports any available (defined) postprocessors.
 +/
module dialect.postprocessors;

@safe:


// tryImportMixin
/++
 +  String mixin. If a module is available, import it. If it isn't available,
 +  alias the passed `alias_` to an empty `std.meta.AliasSeq`.
 +
 +  This allows us to import modules if they exist but otherwise silently still
 +  let it work without them.
 +
 +  Example:
 +  ---
 +  mixin(tryImportMixin("proj.some.module_", "SymbolInside"));"
 +  static assert(__traits(compiles, SymbolInside));  // normal import
 +
 +  mixin(tryImportMixin("proj.some.invalidmodule", "FakeSymbol"));"  // failed import
 +  static assert(__traits(compiles, FakeSymbol));  // visible despite that
 +  static assert(is(FakeSymbol == AliasSeq!()));  // ...because it's aliased to nothing
 +  ---
 +
 +  Params:
 +      module_ = Fully qualified string name of the module to evaluate and potentially import.
 +      alias_ = Name of the symbol to create that points to an empty `std.meta.AliasSeq`
 +          iff the module was not imported.
 +
 +  Returns:
 +      A selectively-importing `static if`. Mix this in to use.
 +/
private string tryImportMixin(const string module_, const string alias_)
{
    import std.format : format;

    return q{
        static if (__traits(compiles, __traits(identifier, %1$s.%2$s)))
        {
            //pragma(msg, "Importing postprocessor: %1$s");
            public import %1$s;
        }
        else
        {
            //pragma(msg, "NOT importing: %1$s (missing or doesn't compile)");
            import std.meta : AliasSeq;
            alias %2$s = AliasSeq!();
        }
    }.format(module_, alias_);
}


import std.meta : AliasSeq;

version(TwitchSupport)
{
    //mixin(tryImportMixin("dialect.postprocessors.twitch", "TwitchPostprocessor"));
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
