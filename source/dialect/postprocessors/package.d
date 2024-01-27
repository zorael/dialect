/++
    Postprocessor package module.

    A [Postprocessor] is a class that is passed an [dialect.defs.IRCEvent|IRCEvent]
    after it has been parsed, and allowed to make last-minute modifications to it.

    See_Also:
        [Postprocessor]

    Copyright: [JR](https://github.com/zorael)
    License: [Boost Software License 1.0](https://www.boost.org/users/license.html)

    Authors:
        [JR](https://github.com/zorael)
 +/
module dialect.postprocessors;

private:

version(none)
version(TwitchSupport)
{
    /+
        This is needed for the module constructor mixed in with
        [PostprocessorRegistration] to actually run. Without it, the Twitch
        postprocessor is never instantiated.

        Currently the onus to do this is placed onto the importing project.
        Version this back in if we ever change that stance.
     +/
    import dialect.postprocessors.twitch;
}


// PostprocessorRegistrationEntry
/++
    An entry in [registeredPostprocessors] corresponding to a postprocessor
    registered to be instantiated on library initialisation.
 +/
struct PostprocessorRegistrationEntry
{
    // priority
    /++
        Priority at which to instantiate the postprocessor. A lower priority
        makes it get instantiated before other postprocessors.
     +/
    Priority priority;

    // ctor
    /++
        Function pointer to a "constructor"/builder that instantiates the relevant postprocessor.
     +/
    Postprocessor function() ctor;

    // this
    /++
        Constructor.

        Params:
            priority = [Priority] at which to instantiate the postprocessor.
                A lower priority value makes it get instantiated before other postprocessors.
            ctor = Function pointer to a "constructor"/builder that instantiates
                the relevant postprocessor.
     +/
    this(
        const Priority priority,
        typeof(this.ctor) ctor) pure @safe nothrow @nogc
    {
        this.priority = priority;
        this.ctor = ctor;
    }
}


// registeredPostprocessors
/++
    Array of registered postprocessors, represented by [PostprocessorRegistrationEntry]/-ies,
    to be instantiated on library initialisation.
 +/
shared PostprocessorRegistrationEntry[] registeredPostprocessors;


// module constructor
/++
    Module constructor that merely reserves space for [registeredPostprocessors]
    to grow into.

    Only include this if the compiler is based on 2.095 or later, as the call to
    [object.reserve|reserve] fails with those prior to that.

    This isn't really needed today as we only have one postprocessor.
 +/
version(none)
static if (__VERSION__ >= 2095L)
shared static this()
{
    enum initialSize = 4;
    (cast()registeredPostprocessors).reserve(initialSize);
}


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
private:
    import dialect.defs : IRCEvent;
    import dialect.parsing : IRCParser;

public:
    /++
        Postprocesses an [dialect.defs.IRCEvent|IRCEvent].
     +/
    void postprocess(ref IRCParser, ref IRCEvent) @system;
}


// registerPostprocessor
/++
    Registers a postprocessor to be instantiated on library initialisation by creating
    a [PostprocessorRegistrationEntry] and appending it to [registeredPostprocessors].

    Params:
        priority = Priority at which to instantiate the postprocessor.
            A lower priority makes it get instantiated before other postprocessors.
        ctor = Function pointer to a "constructor"/builder that instantiates
            the relevant postprocessor.
 +/
void registerPostprocessor(
    const Priority priority,
    Postprocessor function() ctor)
{
    registeredPostprocessors ~= PostprocessorRegistrationEntry(
        priority,
        ctor);
}


// instantiatePostprocessors
/++
    Instantiates all postprocessors represented by a [PostprocessorRegistrationEntry]
    in [registeredPostprocessors].

    Postprocessor modules may register their [Postprocessor] classes by mixing in
    [PostprocessorRegistration].

    Returns:
        An array of instantiated [Postprocessor]s.
 +/
auto instantiatePostprocessors()
{
    import std.algorithm.sorting : sort;

    Postprocessor[] postprocessors;
    postprocessors.length = registeredPostprocessors.length;
    uint i;

    auto sortedPostprocessorRegistrations = registeredPostprocessors
        .sort!((a,b) => a.priority.value < b.priority.value);

    foreach (registration; sortedPostprocessorRegistrations)
    {
        postprocessors[i++] = registration.ctor();
    }

    return postprocessors;
}


// PostprocessorRegistration
/++
    Mixes in a module constructor that registers the supplied [Postprocessor]
    class in the module to be instantiated on library initialisation.

    Params:
        ThisPostprocessor = [Postprocessor] class of module.
        priority = Priority at which to instantiate the postprocessor.
            A lower priority makes it get instantiated before other postprocessors.
            Defaults to `0.priority`.
        module_ = String name of the module. Only used in case an error message is needed.
 +/
mixin template PostprocessorRegistration(
    ThisPostprocessor,
    Priority priority = 0.priority,
    string module_ = __MODULE__)
{
    /++
        Module constructor.
     +/
    shared static this()
    {
        static if (__traits(compiles, new ThisPostprocessor))
        {
            static Postprocessor ctor()
            {
                return new ThisPostprocessor;
            }

            registerPostprocessor(priority, &ctor);
        }
        else
        {
            import std.format : format;

            enum pattern = "`%s.%s` constructor does not compile";
            enum message = pattern.format(module_, ThisPostprocessor.stringof);
            static assert(0, message);
        }
    }
}


// Priority
/++
    Embodies the notion of a priority at which a postprocessor should be instantiated,
    and as such, the order in which they will be called to process events.
 +/
struct Priority
{
    /++
        Numerical priority value. Lower is higher.
     +/
    int value;

    /++
        Helper `opUnary` to allow for `-10.priority`, instead of having to do the
        (more correct) `(-10).priority`.

        Example:
        ---
        mixin PostprocessorRegistration!(-10.priority);
        ---

        Params:
            op = Operator.

        Returns:
            A new [Priority] with a [Priority.value|value] equal to the negative of this one's.
     +/
    auto opUnary(string op: "-")() const
    {
        return Priority(-value);
    }
}


// priority
/++
    Helper alias to use the proper style guide and still be able to instantiate
    [Priority] instances with UFCS.

    Example:
    ---
    mixin PostprocessorRegistration!(50.priority);
    ---
 +/
alias priority = Priority;
