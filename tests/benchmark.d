module dialect.tests.benchmark;

__gshared bool go;

void spinlockGo(const int periodInSeconds)
{
    import std.datetime.systime : Clock;
    import core.thread : Thread;
    import core.time : msecs;

    immutable prestartSecond = Clock.currTime.toUnixTime;

    while (Clock.currTime.toUnixTime == prestartSecond) { Thread.sleep(1.msecs); }

    // start immediately
    go = true;

    immutable stopSecond = Clock.currTime.toUnixTime + periodInSeconds;

    while (Clock.currTime.toUnixTime < stopSecond) { Thread.sleep(1.msecs); }

    // periodInSeconds elapsed, stop
    go = false;
}

void main(string[] args)
{
    import std.stdio : writeln;
    import std.concurrency : spawn;
    import std.conv : to;
    import core.thread : Thread;
    import core.time : msecs;

    immutable periodInSeconds = (args.length > 1) ? args[1].to!int : 10;
    uint count;

    writeln("Period: ", periodInSeconds, " seconds");

    spawn(&spinlockGo, periodInSeconds);

    // Wait for spinlockGo to start
    while (!go) { Thread.sleep(1.msecs); }

    while (go)
    {
        import dialect.tests.dalnet;
        import dialect.tests.events;
        import dialect.tests.freenode;
        import dialect.tests.gamesurge;
        import dialect.tests.geekshed;
        import dialect.tests.irchighway;
        import dialect.tests.ircnet;
        import dialect.tests.oftc;
        import dialect.tests.quakenet;
        import dialect.tests.rizon;
        import dialect.tests.rusnet;
        import dialect.tests.spotchat;
        import dialect.tests.swiftirc;
        import dialect.tests.twitch;
        import std.meta : AliasSeq;

        alias testFuns = AliasSeq!(
            // 3
            dialect.tests.dalnet.unittest1,
            // 26
            dialect.tests.events.unittest1,
            dialect.tests.events.unittest2,
            dialect.tests.events.unittest3,
            dialect.tests.events.unittest4,
            dialect.tests.events.unittest5,
            dialect.tests.events.unittest6,
            // 89
            dialect.tests.freenode.unittest1,
            dialect.tests.freenode.unittest2,
            dialect.tests.freenode.unittest3,
            // 6
            dialect.tests.gamesurge.unittest1,
            dialect.tests.gamesurge.unittest2,
            // 3
            dialect.tests.geekshed.unittest1,
            // 10
            dialect.tests.irchighway.unittest1,
            dialect.tests.irchighway.unittest2,
            // 5
            dialect.tests.ircnet.unittest1,
            // 10
            dialect.tests.oftc.unittest1,
            dialect.tests.oftc.unittest2,
            // 6
            dialect.tests.quakenet.unittest1,
            dialect.tests.quakenet.unittest2,
            // 17
            dialect.tests.rizon.unittest1,
            dialect.tests.rizon.unittest2,
            // 5
            dialect.tests.rusnet.unittest1,
            dialect.tests.rusnet.unittest2,
            // 10
            dialect.tests.spotchat.unittest1,
            dialect.tests.spotchat.unittest2,
            // 3
            dialect.tests.swiftirc.unittest1,
            // 41
            dialect.tests.twitch.unittest1,
            dialect.tests.twitch.unittest2,
        );

        // grep -c 'immutable event' tests/*.d
        enum numEvents = (3+26+89+6+3+10+5+10+6+17+5+10+3+41);

        static foreach (fun; testFuns)
        {
            fun();
        }

        count += numEvents;
    }

    writeln((count / periodInSeconds), " events per second");
}
