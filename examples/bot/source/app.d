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

int main()
{
    enum serverAddress = "irc.libera.chat";
    enum serverPort = 6667;
    enum socketBufferSize = 4096;
    enum username = "dialect-test";
    enum homeChannel = "#dialect-test";

    IRCParser parser;

    auto socket = new TcpSocket();
    auto buffer = new ubyte[socketBufferSize];
    size_t incompleteLineOffset;
    socket.blocking = true;

    void echoAndSend(string lineToSend)
    {
        writeln("> ",  lineToSend);
        socket.send(lineToSend);
        socket.send("\r\n"); // all outgoing lines must end with Windows CRLF "\r\n";
    }

    try
    {
        // Resolve IP, just grab the first one for now
        auto address = getAddress(serverAddress, serverPort)[0];
        writefln("%s resolved to %s", serverAddress, address);

        // Connect
        socket.connect(address);
        writeln("Connected!");  // ...since it did not throw
        writeln();

        // Register/handshake
        echoAndSend("USER " ~ username ~ " 0 * :dialect test client");
        echoAndSend("NICK " ~ username);
        writeln();
    }
    catch (Exception e)
    {
        writeln(e);
        return 1;
    }

    // We are connected and can start reading from the server.

    while (true)
    {
        // Read from server
        const bytesReceived = socket.receive(buffer[incompleteLineOffset..$]);

        // Handle basic error cases
        if (bytesReceived == Socket.ERROR) continue;  // benign despite the name
        else if (bytesReceived == 0) return 1;  // connection error

        // Find the next newline
        const end = cast(ptrdiff_t)(incompleteLineOffset + bytesReceived);
        ptrdiff_t newline = (cast(char[])buffer[0..end]).indexOf('\n');
        size_t pos;

        while (newline > 0)
        {
            // Subtract 1 when slicing to get rid of the '\r' in "\r\n"
            string readString = (cast(char[])buffer[pos..pos+newline-1]).idup;

            // Update the newline position
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
                // After the server has sent its message-of-the-day, it's safe to join channels
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

            case PING:
                // PINGs must be responded to with PONGs, else you get disconnected
                string pongTarget = (event.content.length > 0) ?
                    event.content :
                    event.sender.address;
                echoAndSend("PONG :" ~ pongTarget);
                break;

            case QUIT:
                // QUITs are disconnects
                writeln("exiting...");
                return 0;

            default:
                break;
            }
        }

        // Was the last line a full line?
        if (pos >= end)
        {
            incompleteLineOffset = 0;
            continue;
        }

        // ...it was not, so store where we are in the buffer and offset the next read
        incompleteLineOffset = (end - pos);

        // Move incomplete line to the start of the buffer
        memmove(buffer.ptr, (buffer.ptr + pos), (ubyte.sizeof * incompleteLineOffset));
    }
}
