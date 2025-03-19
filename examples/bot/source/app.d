/**
    Simple example of how to use the dialect library.

    This example connects to an IRC server, registers/handshakes, and prints
    out the server's responses. It also responds to PINGs with PONGs to stay connected.

    Servers may send incomplete lines, so the example also demonstrates how to
    handle this by parsing the incoming data line by line, and saving leftover
    data for the next iteration.

    This example does not implement things like `CTCP_VERSION`, which many servers require.
 */
module dialect_example;

import dialect;
import std.algorithm;
import std.socket;
import std.stdio;
import std.string;
import core.stdc.string : memmove;

enum serverAddress = "irc.libera.chat";
enum ushort serverPort = 6667;
enum socketBufferSize = 4096;
enum username = "dialect-test";
enum homeChannel = "#dialect-test";

int main()
{
    // Set up the parser with its constructor taking an IRCClient and an IRCServer
    IRCClient client;
    client.nickname = username;

    IRCServer server;
    server.address = serverAddress;
    server.port = serverPort;

    // Like so
    auto parser = IRCParser(client, server);

    // Create a Socket and a buffer to read into
    auto socket = new TcpSocket();
    auto buffer = new ubyte[socketBufferSize];
    size_t incompleteLineOffset;
    socket.blocking = true;

    void echoAndSend(string lineToSend)
    {
        // Convenience function to send a line to the server and echo it to the terminal
        writeln("> ",  lineToSend);
        socket.send(lineToSend);
        socket.send("\r\n"); // all outgoing lines must end with Windows CRLF "\r\n";
    }

    try
    {
        // Resolve IP, just grab the first one for now (by indexing [0])
        writeln("Resolving IP...");
        auto address = resolveIP(serverAddress, serverPort)[0];
        writefln("%s resolved to %s", serverAddress, address);

        // Connect
        writeln();
        writeln("Connecting...");
        socket.connect(address);
        writeln("Connected!");  // ...since it did not throw
        writeln();
    }
    catch (Exception e)
    {
        // Complain and exit
        writeln(e);
        return 1;
    }

    // We are connected and can start reading from and writing to the server.

    // Register/handshake
    echoAndSend("USER " ~ username ~ " 0 * :dialect test client");
    echoAndSend("NICK " ~ username);
    writeln();

    // Main loop:
    while (true)
    {
        // Read from server into the buffer, starting at offset index incompleteLineOffset
        const bytesReceived = socket.receive(buffer[incompleteLineOffset..$]);

        // Handle basic error cases
        if (bytesReceived == Socket.ERROR) continue;  // benign despite the name
        else if (bytesReceived == 0) return 1;  // connection error

        // Find a newline in the buffer
        const end = cast(ptrdiff_t)(incompleteLineOffset + bytesReceived);
        ptrdiff_t newline = (cast(char[])buffer[0..end]).indexOf('\n');
        size_t pos;

        // Repeat as long as there are newlines in the buffer:
        while (newline > 0)
        {
            // Slice the buffer for a line.
            // Subtract 1 when slicing to get rid of the '\r' in the ending "\r\n"
            string readString = (cast(char[])buffer[pos..pos+newline-1]).idup;

            // Find the next newline in the buffer
            pos += (newline + 1); // slice past the remaining newline
            newline = (cast(char[])buffer[pos..end]).indexOf('\n');

            // Parse the string into an event
            IRCEvent event = parser.toIRCEvent(readString);

            // Echo what was read
            string content = (event.content.length > 0) ?
                event.content :
                event.raw;
            writefln("%-25s %s", event.type, content);

            // Handle events based on their type and contents
            with (IRCEvent.Type)
            switch (event.type)
            {
            case RPL_ENDOFMOTD:
            case RPL_NOMOTD:
                // After the server has sent its Message-Of-The-Day, it's safe to join channels
                echoAndSend("JOIN " ~ homeChannel);
                break;

            case SELFJOIN:
                // SELFJOINs are when the client itself joins a channel
                if (event.channel.name == homeChannel)
                {
                    echoAndSend("PRIVMSG " ~ homeChannel ~ " :Hello, world!");
                }
                break;

            case CHAN:
                // CHANs are channel messages
                if (event.channel.name == homeChannel)
                {
                    if (event.content.startsWith(username ~ ":"))
                    {
                        echoAndSend("PRIVMSG " ~ homeChannel ~ " :I heard you " ~ event.sender.nickname ~ "!");
                    }
                }
                break;

            case QUERY:
                // QUERYs are private messages
                echoAndSend("PRIVMSG " ~ event.sender.nickname ~ " :Watch me spam this reply:");
                break;

            case PING:
                // PINGs must be responded to with PONGs, else you will be disconnected
                string pongTarget = (event.content.length > 0) ?
                    event.content :
                    event.sender.address;
                echoAndSend("PONG :" ~ pongTarget);
                break;

            case QUIT:
                // QUITs are disconnects
                writeln();
                writeln("exiting...");
                return 0;

            /*case ASDF:
                // See the IRCEvent.Type enum in defs.d for more event types
                break;*/

            default:
                break;
            }
        }

        // Was the last line in the buffer a full line?
        if (pos >= end)
        {
            // ...it was, with the last line ending at the end of the read data
            // The next read can thus start at the beginning of the buffer
            incompleteLineOffset = 0;
            continue;
        }

        // ...it was not and the last line that was read was cut off mid-line
        // The remainder of the line should come in the next read
        // Store where we are in the buffer and offset the next read so the line completes
        incompleteLineOffset = (end - pos);

        // Move incomplete line to the start of the buffer
        memmove(buffer.ptr, (buffer.ptr + pos), (ubyte.sizeof * incompleteLineOffset));
    }
}

auto resolveIP(string address, ushort port)
{
    // Don't try forever, but do try more than once
    enum maxTries = 5;

    foreach (immutable i; 0..maxTries)
    {
        try
        {
            return getAddress(address, port);
        }
        catch (SocketOSException e)
        {
            if (e.msg == "getaddrinfo error: Temporary failure in name resolution")
            {
                // Temporary failure, try again
                continue;
            }

            if (i == maxTries-1)
            {
                // Too many tries, give up by rethrowing
                throw e;
            }
        }
    }

    assert(0, "unreachable");
}
