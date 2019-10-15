module dialect.tests.benchmark;

import dialect.defs;
import dialect.parsing;

// cat ../../tests/* | grep 'immutable event' | sed 's/ \+immutable event = parser.toIRCEvent(//g' | sed 's/);$/,/' > events.list

__gshared bool go;

enum periodInSeconds = 10;

void spinlockGo()
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

void main()
{
    import std.stdio : writeln;
    import std.random : uniform;
    import std.concurrency : spawn;
    import core.thread : Thread;
    import core.time : msecs;

    writeln("Period: ", periodInSeconds, " seconds");

    IRCServer server;
    IRCClient client;
    IRCParser parser = IRCParser(client, server);
    uint count;

    spawn(&spinlockGo);

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
            dialect.tests.dalnet.unittest1,       // 3
            dialect.tests.events.unittest1,       // 26
            dialect.tests.events.unittest2,       // 26
            dialect.tests.events.unittest3,       // 26
            dialect.tests.events.unittest4,       // 26
            dialect.tests.events.unittest5,       // 26
            dialect.tests.events.unittest6,       // 26
            dialect.tests.freenode.unittest1,     // 89
            dialect.tests.freenode.unittest2,     // 89
            dialect.tests.freenode.unittest3,     // 89
            dialect.tests.gamesurge.unittest1,    // 6
            dialect.tests.gamesurge.unittest2,    // 6
            dialect.tests.geekshed.unittest1,     // 3
            dialect.tests.irchighway.unittest1,   // 10
            dialect.tests.irchighway.unittest2,   // 10
            dialect.tests.ircnet.unittest1,       // 5
            dialect.tests.oftc.unittest1,         // 10
            dialect.tests.oftc.unittest2,         // 10
            dialect.tests.quakenet.unittest1,     // 6
            dialect.tests.quakenet.unittest2,     // 6
            dialect.tests.rizon.unittest1,        // 17
            dialect.tests.rizon.unittest2,        // 17
            dialect.tests.rusnet.unittest1,       // 5
            dialect.tests.rusnet.unittest2,       // 5
            dialect.tests.spotchat.unittest1,     // 10
            dialect.tests.spotchat.unittest2,     // 10
            dialect.tests.swiftirc.unittest1,     // 3
            dialect.tests.twitch.unittest1,       // 41
            dialect.tests.twitch.unittest2,       // 41
        );

        enum numEvents = (3+26+89+6+3+10+5+10+6+17+5+10+3+41);

        static foreach (fun; testFuns)
        {
            fun();
        }

        count += numEvents;
    }

    writeln((count / periodInSeconds), " events per second");
}
