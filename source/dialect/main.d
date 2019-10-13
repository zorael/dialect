module dialect.main;

import dialect.defs;
import dialect.parsing;

// cat ../../tests/* | grep 'immutable event' | sed 's/ \+immutable event = parser.toIRCEvent(//g' | sed 's/);$/,/' > events.list

static immutable string[] lines = [
    ":NickServ!service@dal.net NOTICE kameloso :This nick is owned by someone else. Please choose another.",
    ":NickServ!service@dal.net NOTICE kameloso :The password supplied for kameloso is incorrect.",
    ":NickServ!service@dal.net NOTICE kameloso :Password accepted for kameloso.",
    "ERROR :Closing Link: 81-233-105-62-no80.tbcn.telia.com (Quit: kameloso^)",
    "NOTICE kameloso :*** If you are having problems connecting due to ping timeouts, please type /notice F94828E6 nospoof now.",
    ":miranda.chathispano.com 465 kameloso 1511086908 :[1511000504768] G-Lined by ChatHispano Network. Para mas informacion visite http://chathispano.com/gline/?id=<id> (expires at Dom, 19/11/2017 11:21:48 +0100).",
    ":irc.RomaniaChat.eu 322 kameloso #GameOfThrones 1 :[+ntTGfB]",
    ":irc.RomaniaChat.eu 322 kameloso #radioclick 63 :[+ntr]  Bun venit pe #Radioclick! Site oficial www.radioclick.ro sau servere irc.romaniachat.eu, irc.radioclick.ro",
    ":cadance.canternet.org 379 kameloso kameloso :is using modes +ix",
    ":Miyabro!~Miyabro@DA8192E8:4D54930F:650EE60D:IP CHGHOST ~Miyabro Miyako.is.mai.waifu",
    ":Iasdf666!~Iasdf666@The.Breakfast.Club PRIVMSG #uk :be more welcoming you negative twazzock",
    ":gallon!~MO.11063@482c29a5.e510bf75.97653814.IP4 PART :#cncnet-yr",
    //":cadance.canternet.org 953 kameloso^ #flerrp :End of channel exemptchanops list",
    ":irc.portlane.se 020 * :Please wait while we process your connection.",
    ":efnet.port80.se 004 kameloso efnet.port80.se ircd-ratbox-3.0.9 oiwszcrkfydnxbauglZCD biklmnopstveIrS bkloveI",
    ":efnet.port80.se 005 kameloso CHANTYPES=&# EXCEPTS INVEX CHANMODES=eIb,k,l,imnpstS CHANLIMIT=&#:50 PREFIX=(ov)@+ MAXLIST=beI:100 MODES=4 NETWORK=EFnet KNOCK STATUSMSG=@+ CALLERID=g :are supported by this server",
    ":bitcoin.uk.eu.dal.net NOTICE AUTH :*** Looking up your hostname...",
    ":bitcoin.uk.eu.dal.net 004 kameloso bitcoin.uk.eu.dal.net bahamut-2.1.4 aAbcCdefFghHiIjkKmnoOPrRsSwxXy AbceiIjklLmMnoOpPrRsStv",
    ":bitcoin.uk.eu.dal.net 005 kameloso NETWORK=DALnet SAFELIST MAXBANS=200 MAXCHANNELS=50 CHANNELLEN=32 KICKLEN=307 NICKLEN=30 TOPICLEN=307 MODES=6 CHANTYPES=# CHANLIMIT=#:50 PREFIX=(ov)@+ STATUSMSG=@+ :are available on this server",
    ":bitcoin.uk.eu.dal.net 005 kameloso CASEMAPPING=ascii WATCH=128 SILENCE=10 ELIST=cmntu EXCEPTS INVEX CHANMODES=beI,k,jl,cimMnOprRsSt MAXLIST=b:200,e:100,I:100 TARGMAX=DCCALLOW:,JOIN:,KICK:4,KILL:20,NOTICE:20,PART:,PRIVMSG:20,WHOIS:,WHOWAS: :are available on this server",
    ":NickServ!service@dal.net NOTICE kameloso :Password accepted for kameloso.",
    ":kameloso MODE kameloso :+i",
    ":kameloso MODE kameloso :+r",
    ":fe-00107.GeekShed.net NOTICE AUTH :*** Looking up your hostname...",
    "PING :E21567FB",
    ":fe-00107.GeekShed.net 004 kameloso fe-00107.GeekShed.net Unreal3.2.10.3-gs iowghraAsORTVSxNCWqBzvdHtGpIDc lvhopsmntikrRcaqOALQbSeIKVfMCuzNTGjUZ",
    ":fe-00107.GeekShed.net 005 kameloso CMDS=KNOCK,MAP,DCCALLOW,USERIP,STARTTLS UHNAMES NAMESX SAFELIST HCN MAXCHANNELS=100 CHANLIMIT=#:100 MAXLIST=b:60,e:60,I:60 NICKLEN=30 CHANNELLEN=32 TOPICLEN=307 KICKLEN=307 AWAYLEN=307 :are supported by this server",
    ":fe-00107.GeekShed.net 005 kameloso MAXTARGETS=20 WALLCHOPS WATCH=128 WATCHOPTS=A SILENCE=15 MODES=12 CHANTYPES=# PREFIX=(qaohv)~&@%+ CHANMODES=beI,kfL,lj,psmntirRcOAQKVCuzNSMTGUZ NETWORK=GeekShed CASEMAPPING=ascii EXTBAN=~,qjncrRaT ELIST=MNUCT :are supported by this server",
    ":kameloso MODE kameloso :+iRx",
    ":sinisalo.freenode.net 004 kameloso^ sinisalo.freenode.net ircd-seven-1.1.7 DOQRSZaghilopswz CFILMPQSbcefgijklmnopqrstvz bkloveqjfI",
    ":sinisalo.freenode.net 005 kameloso^ CHANTYPES=# EXCEPTS INVEX CHANMODES=eIbq,k,flj,CFLMPQScgimnprstz CHANLIMIT=#:120 PREFIX=(ov)@+ MAXLIST=bqeI:100 MODES=4 NETWORK=freenode STATUSMSG=@+ CALLERID=g CASEMAPPING=rfc1459 :are supported by this server",
    ":sinisalo.freenode.net 005 kameloso^ CHARSET=ascii NICKLEN=16 CHANNELLEN=50 TOPICLEN=390 DEAF=D FNC TARGMAX=NAMES:1,LIST:1,KICK:1,WHOIS:1,PRIVMSG:4,NOTICE:4,ACCEPT:,MONITOR: EXTBAN=$,jrxz CLIENTVER=3.0 WHOX KNOCK ETRACE :are supported by this server",
    ":zorael!~NaN@2001:41d0:2:80b4:: KICK #flerrp kameloso^ :kameloso^",
    ":livingstone.freenode.net 249 kameloso p :dax (dax@freenode/staff/dax)",
    ":livingstone.freenode.net 219 kameloso p :End of /STATS report",
    ":rajaniemi.freenode.net 718 kameloso Freyjaun ~FREYJAUN@41.39.229.6 :is messaging you, and you have umode +g.",
    ":nick!~identh@unaffiliated/nick JOIN #freenode login :realname",
    `:zorael!~NaN@ns3363704.ip-94-23-253.eu PART #flerrp :"WeeChat 1.6"`,
    ":kameloso^!~NaN@81-293-105-62-no80.tbcn.telia.com NICK :kameloso_",
    ":g7adszon!~gertsson@938.174.245.107 QUIT :Client Quit",
    ":zorael!~NaN@ns3363704.ip-94-23-253.eu KICK #flerrp kameloso^ :this is a reason",
    ":zorael!~NaN@2001:41d0:2:80b4:: INVITE kameloso :#hirrsteff",
    ":zorael!~zorael@ns3363704.ip-94-23-253.eu INVITE kameloso #hirrsteff",
    ":moon.freenode.net 403 kameloso archlinux :No such channel",
    ":asimov.freenode.net 353 kameloso^ = #garderoben :kameloso^ ombudsma +kameloso @zorael @m @k",
    ":moon.freenode.net 352 kameloso ##linux LP9NDWY7Cy gentoo/contributor/Foldy moon.freenode.net Foldy H :0 Ni!",
    ":tolkien.freenode.net 315 kameloso^ ##linux :End of /WHO list.",
    ":wilhelm.freenode.net 378 kameloso^ kameloso^ :is connecting from *@81-233-105-62-no80.tbcn.telia.com 81.233.105.62",
    ":asimov.freenode.net 421 kameloso^ sudo :Unknown command",
    ":asimov.freenode.net 252 kameloso^ 31 :IRC Operators online",
    ":asimov.freenode.net 253 kameloso^ 13 :unknown connection(s)",
    ":asimov.freenode.net 254 kameloso^ 54541 :channels formed",
    ":asimov.freenode.net 432 kameloso^ @nickname :Erroneous Nickname",
    ":asimov.freenode.net 461 kameloso^ JOIN :Not enough parameters",
    ":asimov.freenode.net 265 kameloso^ 6500 11061 :Current local users 6500, max 11061",
    ":orwell.freenode.net 311 kameloso^ kameloso ~NaN ns3363704.ip-94-23-253.eu * : kameloso",
    ":asimov.freenode.net 312 kameloso^ zorael sinisalo.freenode.net :SE",
    ":asimov.freenode.net 330 kameloso^ xurael zorael :is logged in as",
    ":niven.freenode.net 451 * :You have not registered",
    ":irc.harblwefwoi.org 451 WHOIS :You have not registered",
    ":leguin.freenode.net 704 kameloso^ index :Help topics available to users:",
    ":rajaniemi.freenode.net 364 kameloso^ rajaniemi.freenode.net rajaniemi.freenode.net :0 Helsinki, FI, EU",
    ":wolfe.freenode.net 205 kameloso^ User v6users zorael[~NaN@2001:41d0:2:80b4::] (255.255.255.255) 16 :536",
    ":leguin.freenode.net 706 kameloso^ index :End of /HELP.",
    ":livingstone.freenode.net 249 kameloso p :1 staff members",
    ":verne.freenode.net 263 kameloso^ STATS :This command could not be completed because it has been used recently, and is rate-limited",
    ":verne.freenode.net 262 kameloso^ verne.freenode.net :End of TRACE",
    ":asimov.freenode.net 332 kameloso^ #garderoben :Are you employed, sir?",
    ":asimov.freenode.net 366 kameloso^ #flerrp :End of /NAMES list.",
    ":services. 328 kameloso^ #ubuntu :http://www.ubuntu.com",
    ":cherryh.freenode.net 477 kameloso^ #archlinux :Cannot join channel (+r) - you need to be identified with services",
    ":asimov.freenode.net 353 kameloso^ = #garderoben :kameloso^ ombudsman +kameloso @zorael @maku @klarrt",
    ":moon.freenode.net 352 kameloso ##linux LP9NDWY7Cy gentoo/contributor/Fieldy moon.freenode.net Fieldy H :0 Ni!",
    ":moon.freenode.net 352 kameloso ##linux ~rahlff b29beb9d.rev.stofanet.dk orwell.freenode.net Axton H :0 Michael Rahlff",
    ":tolkien.freenode.net 301 kameloso^ jcjordyn120 :Idle",
    ":asimov.freenode.net 372 kameloso^ :- In particular we would like to thank the sponsor",
    ":cherryh.freenode.net 005 CHANTYPES=# EXCEPTS INVEX MODES=eIbq,k,flj,CFLMPQScgimnprstz CHANLIMIT=#:120 PREFIX=(ov)@+ MAXLIST=bqeI:100 MODES=4 NETWORK=freenode STATUSMSG=@+ CALLERID=g CASEMAPPING=rfc1459 :are supported by this server",
    ":asimov.freenode.net 004 kameloso^ asimov.freenode.net ircd-seven-1.1.4 DOQRSZaghilopswz CFILMPQSbcefgijklmnopqrstvz bkloveqjfI",
    ":asimov.freenode.net 333 kameloso^ #garderoben klarrt!~bsdrouter@h150n13-aahm-a11.ias.bredband.telia.com 1476294377",
    ":karatkievich.freenode.net 421 kameloso^ systemd,#kde,#kubuntu,...",
    ":rajaniemi.freenode.net 317 kameloso zorael 0 1510219961 :seconds idle, signon time",
    ":asimov.freenode.net 266 kameloso^ 85267 92341 :Current global users 85267, max 92341",
    ":weber.freenode.net 265 kameloso 3385 6820 :Current local users 3385, max 6820",
    ":weber.freenode.net 266 kameloso 87056 93012 :Current global users 87056, max 93012",
    ":asimov.freenode.net 671 kameloso^ zorael :is using a secure connection",
    ":asimov.freenode.net 318 kameloso^ zorael :End of /WHOIS list.",
    ":asimov.freenode.net 433 kameloso^ kameloso :Nickname is already in use.",
    ":cherryh.freenode.net 401 kameloso^ cherryh.freenode.net :No such nick/channel",
    ":lightning.ircstorm.net 313 kameloso^ NickServ :is a Network Service",
    ":adams.freenode.net 001 kameloso^ :Welcome to the freenode Internet Relay Chat Network kameloso^",
    ":leguin.freenode.net 705 kameloso^ index :ACCEPT\tADMIN\tAWAY\tCHALLENGE",
    ":leguin.freenode.net 706 kameloso^ index :End of /HELP.// :leguin.freenode.net 706 kameloso^ index :End of /HELP.",
    ":cherryh.freenode.net 435 kameloso^ kameloso^^ #d3d9 :Cannot change nickname while banned on channel",
    ":zorael!~NaN@2001:41d0:2:80b4:: TOPIC #garderoben :en greps av hybris, sen var de bara fyra",
    ":weber.freenode.net 900 kameloso kameloso!NaN@194.117.188.126 kameloso :You are now logged in as kameloso.",
    ":skix77!~quassel@ip5b435007.dynamic.kabel-deutschland.de ACCOUNT skix77",
    ":cherryh.freenode.net 321 kameloso^ Channel :Users  Name",
    ":wolfe.freenode.net 470 kameloso #linux ##linux :Forwarding to another channel",
    ":orwell.freenode.net 443 kameloso^ kameloso #flerrp :is already on channel",
    ":ChanServ!ChanServ@services. NOTICE kameloso^ :[##linux-overflohomeOnlyw] Make sure your nick is registered, then please try again to join ##linux.",
    ":ChanServ!ChanServ@services. NOTICE kameloso^ :[#ubuntu] Welcome to #ubuntu! Please read the channel topic.",
    ":tolkien.freenode.net NOTICE * :*** Checking Ident",
    ":zorael!~NaN@ns3363704.ip-94-23-253.eu PRIVMSG #flerrp :test test content",
    ":zorael!~NaN@ns3363704.ip-94-23-253.eu PRIVMSG kameloso^ :test test content",
    ":zorael!~NaN@ns3363704.ip-94-23-253.eu MODE #flerrp +v kameloso^",
    ":zorael!~NaN@ns3363704.ip-94-23-253.eu MODE #flerrp +i",
    ":niven.freenode.net MODE #sklabjoier +ns",
    ":kameloso^ MODE kameloso^ :+i",
    ":cherryh.freenode.net 005 CHARSET=ascii NICKLEN=16 CHANNELLEN=50 TOPICLEN=390 DEAF=D FNC TARGMAX=NAMES:1,LIST:1,KICK:1,WHOIS:1,PRIVMSG:4,NOTICE:4,ACCEPT:,MONITOR: EXTBAN=$,ajrxz CLIENTVER=3.0 CPRIVMSG CNOTICE SAFELIST :are supported by this server",
    ":server.net 465 kameloso :You are banned from this server- Your irc client seems broken and is flooding lots of channels. Banned for 240 min, if in error, please contact kline@freenode.net. (2017/12/1 21.08)",
    ":ASDphBa|zzZ!~ASDphBa@a.asdphs-tech.com PRIVMSG #d :does anyone know how the unittest stuff is working with cmake-d?",
    ":kornbluth.freenode.net 324 kameloso #flerrp +ns",
    ":kornbluth.freenode.net 329 kameloso #flerrp 1512995737",
    ":kornbluth.freenode.net 367 kameloso #flerrp harbl!harbl@snarbl.com zorael!~NaN@2001:41d0:2:80b4:: 1513899521",
    ":niven.freenode.net 324 kameloso^ ##linux +CLPcnprtf ##linux-overflow",
    ":niven.freenode.net 346 kameloso^ #flerrp asdf!fdas@asdf.net zorael!~NaN@2001:41d0:2:80b4:: 1514405089",
    ":niven.freenode.net 728 kameloso^ #flerrp q qqqq!*@asdf.net zorael!~NaN@2001:41d0:2:80b4:: 1514405101",
    ":NickServ!NickServ@services. NOTICE kameloso :Invalid password for kameloso.",
    ":Portlane.SE.EU.GameSurge.net 004 kameloso Portlane.SE.EU.GameSurge.net u2.10.12.18(gs2) diOoswkgxnI biklmnopstvrDdRcCz bklov",
    ":Portlane.SE.EU.GameSurge.net 005 kameloso WHOX WALLCHOPS WALLVOICES USERIP CPRIVMSG CNOTICE SILENCE=25 MODES=6 MAXCHANNELS=75 MAXBANS=100 NICKLEN=30 :are supported by this server",
    ":Portlane.SE.EU.GameSurge.net 005 kameloso MAXNICKLEN=30 TOPICLEN=300 AWAYLEN=200 KICKLEN=300 CHANNELLEN=200 MAXCHANNELLEN=200 CHANTYPES=#& PREFIX=(ov)@+ STATUSMSG=@+ CHANMODES=b,k,l,imnpstrDdRcC CASEMAPPING=rfc1459 NETWORK=GameSurge :are supported by this server",
    ":TAL.DE.EU.GameSurge.net 396 kameloso ~NaN@1b24f4a7.243f02a4.5cd6f3e3.IP4 :is now your hidden host",
    ":AuthServ!AuthServ@Services.GameSurge.net NOTICE kameloso :Incorrect password; please try again.",
    ":AuthServ!AuthServ@Services.GameSurge.net NOTICE kameloso :I recognize you.",
    ":NickServ!services@geekshed.net NOTICE kameloso :nick, type /msg NickServ IDENTIFY password.  Otherwise,",
    ":NickServ!services@geekshed.net NOTICE kameloso :Password incorrect.",
    ":NickServ!services@geekshed.net NOTICE kameloso :Password accepted - you are now recognized.",
    ":eggbert.ca.na.irchighway.net 004 kameloso eggbert.ca.na.irchighway.net InspIRCd-2.0 BIRSWghiorswx ACDIMNORSTabcdehiklmnopqrstvz Iabdehkloqv",
    ":eggbert.ca.na.irchighway.net 005 kameloso AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=Ibe,k,dl,ACDMNORSTcimnprstz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU ESILENCE EXCEPTS=e EXTBAN=,ACNORSTUcjmz FNC INVEX=I :are supported by this server",
    ":eggbert.ca.na.irchighway.net 005 kameloso KICKLEN=255 MAP MAXBANS=60 MAXCHANNELS=30 MAXPARA=32 MAXTARGETS=20 MODES=20 NAMESX NETWORK=irchighway NICKLEN=31 PREFIX=(qaohv)~&@%+ SILENCE=32 SSL=10.0.30.4:6697 :are supported by this server",
    ":eggbert.ca.na.irchighway.net 005 kameloso STARTTLS STATUSMSG=~&@%+ TOPICLEN=307 UHNAMES USERIP VBANLIST WALLCHOPS WALLVOICES :are supported by this server",
    ":caliburn.pa.us.irchighway.net 042 kameloso 132AAMJT5 :your unique ID",
    ":genesis.ks.us.irchighway.net CAP 867AAF66L LS :away-notify extended-join account-notify multi-prefix sasl tls userhost-in-names",
    ":NickServ!services@services.irchighway.net NOTICE kameloso :nick, type /msg NickServ IDENTIFY password.  Otherwise,",
    ":NickServ!services@services.irchighway.net NOTICE kameloso :Password incorrect.",
    ":NickServ!services@services.irchighway.net NOTICE kameloso :Password accepted - you are now recognized.",
    ":ceres.dk.eu.irchighway.net 900 kameloso kameloso!kameloso@ihw-3lt.aro.117.194.IP kameloso :You are now logged in as kameloso",
    ":irc.nlnog.net 004 kameloso irc.nlnog.net 2.11.2p3 aoOirw abeiIklmnoOpqrRstv",
    ":irc.nlnog.net 005 kameloso RFC2812 PREFIX=(ov)@+ CHANTYPES=#&!+ MODES=3 CHANLIMIT=#&!+:42 NICKLEN=15 TOPICLEN=255 KICKLEN=255 MAXLIST=beIR:64 CHANNELLEN=50 IDCHAN=!:5 CHANMODES=beIR,k,l,imnpstaqr :are supported by this server",
    ":irc.nlnog.net 005 kameloso PENALTY FNC EXCEPTS=e INVEX=I CASEMAPPING=ascii NETWORK=IRCnet :are supported by this server",
    //":irc.atw-inter.net 344 kameloso #debian.de towo!towo@littlelamb.szaf.org",
    ":irc.atw-inter.net 345 kameloso #debian.de :End of Channel Reop List",
    ":helix.oftc.net 004 kameloso helix.oftc.net hybrid-7.2.2+oftc1.7.3 CDGPRSabcdfgijklnorsuwxyz bciklmnopstvzeIMRS bkloveI",
    ":helix.oftc.net 005 kameloso CALLERID CASEMAPPING=rfc1459 DEAF=D KICKLEN=160 MODES=4 NICKLEN=30 PREFIX=(ov)@+ STATUSMSG=@+ TOPICLEN=391 NETWORK=OFTC MAXLIST=beI:100 MAXTARGETS=1 CHANTYPES=# :are supported by this server",
    ":helix.oftc.net 005 kameloso CHANLIMIT=#:90 CHANNELLEN=50 CHANMODES=eIqb,k,l,cimnpstzMRS AWAYLEN=160 KNOCK ELIST=CMNTU SAFELIST EXCEPTS=e INVEX=I :are supported by this server",
    ":helix.oftc.net 042 kameloso 4G4AAA7BH :your unique ID",
    ":kinetic.oftc.net 338 kameloso wh00nix 255.255.255.255 :actually using host",
    ":irc.oftc.net 345 kameloso #garderoben :End of Channel Quiet List",
    //":irc.oftc.net 344 kameloso #garderoben harbl!snarbl@* kameloso!~NaN@194.117.188.126 1515418362",
    ":NickServ!services@services.oftc.net NOTICE kameloso :This nickname is registered and protected.  If it is your nickname, you may",
    ":NickServ!services@services.oftc.net NOTICE kameloso :Identify failed as kameloso.  You may have entered an incorrect password.",
    ":NickServ!services@services.oftc.net NOTICE kameloso :You are successfully identified as kameloso.",
    ":underworld1.no.quakenet.org 004 kameloso underworld1.no.quakenet.org u2.10.12.10+snircd(1.3.4a) dioswkgxRXInP biklmnopstvrDcCNuMT bklov",
    ":underworld1.no.quakenet.org 005 kameloso WHOX WALLCHOPS WALLVOICES USERIP CPRIVMSG CNOTICE SILENCE=15 MODES=6 MAXCHANNELS=20 MAXBANS=45 NICKLEN=15 :are supported by this server",
    ":underworld1.no.quakenet.org 005 kameloso MAXNICKLEN=15 TOPICLEN=250 AWAYLEN=160 KICKLEN=250 CHANNELLEN=200 MAXCHANNELLEN=200 CHANTYPES=#& PREFIX=(ov)@+ STATUSMSG=@+ CHANMODES=b,k,l,imnpstrDducCNMT CASEMAPPING=rfc1459 NETWORK=QuakeNet :are supported by this server$",
    ":port80b.se.quakenet.org 221 kameloso +i",
    ":port80b.se.quakenet.org 353 kameloso = #garderoben :@kameloso",
    ":Q!TheQBot@CServe.quakenet.org NOTICE kameloso :Username or password incorrect.",
    "AUTHENTICATE +",
    ":irc.ircii.net 004 kameloso^^ irc.ircii.net plexus-4(hybrid-8.1.20) CDGNRSUWagilopqrswxyz BCIMNORSabcehiklmnopqstvz Iabehkloqv",
    ":irc.ircii.net 005 kameloso^^ CALLERID CASEMAPPING=rfc1459 DEAF=D KICKLEN=180 MODES=4 PREFIX=(qaohv)~&@%+ STATUSMSG=~&@%+ EXCEPTS=e INVEX=I NICKLEN=30 NETWORK=Rizon MAXLIST=beI:250 MAXTARGETS=4 :are supported by this server",
    ":irc.ircii.net 005 kameloso^^ CHANTYPES=# CHANLIMIT=#:250 CHANNELLEN=50 TOPICLEN=390 CHANMODES=beI,k,l,BCMNORScimnpstz NAMESX UHNAMES AWAYLEN=180 ELIST=CMNTU SAFELIST KNOCK WATCH=60 :are supported by this server",
    ":irc.rizon.no 352 kameloso^^ * ~NaN C2802314.E23AD7D8.E9841504.IP * kameloso^^ H :0  kameloso!",
    ":irc.uworld.se 265 kameloso^^ :Current local users: 14552  Max: 19744",
    ":irc.uworld.se 266 kameloso^^ :Current global users: 14552  Max: 19744",
    ":irc.rizon.no 265 kameloso^^ :Current local users: 16115  Max: 17360",
    ":irc.x2x.cc 307 kameloso^^ py-ctcp :has identified for this nick",
    ":irc.uworld.se 513 kameloso :To connect type /QUOTE PONG 3705964477",
    ":irc.rizon.no 524 kameloso^^ 502 :Help not found",
    ":irc.rizon.no 472 kameloso^^ X :is unknown mode char to me",
    ":irc.uworld.se 314 kameloso^^ kameloso ~NaN C2802314.E23AD7D8.E9841504.IP * : kameloso!",
    ":irc.rizon.no 351 kameloso^^ plexus-4(hybrid-8.1.20)(20170821_0-607). irc.rizon.no :TS6ow",
    ":irc.rizon.no 315 kameloso^^ * :End of /WHO list.",
    ":NickServ!service@rizon.net NOTICE kameloso^ :Password incorrect.",
    ":NickServ!service@rizon.net NOTICE kameloso^ :Password accepted - you are now recognized.",
    ":irc.run.net 004 kameloso irc.run.net 1.5.24/uk_UA.KOI8-U aboOirswx abcehiIklmnoOpqrstvz",
    ":irc.run.net 005 kameloso PREFIX=(ohv)@%+ CODEPAGES MODES=3 CHANTYPES=#&!+ MAXCHANNELS=20 NICKLEN=31 TOPICLEN=255 KICKLEN=255 NETWORK=RusNet CHANMODES=beI,k,l,acimnpqrstz :are supported by this server",
    ":irc.run.net 222 kameloso KOI8-U :is your charset now",
    ":NickServ!service@RusNet NOTICE kameloso :Password incorrect.",
    ":NickServ!service@RusNet NOTICE kameloso :Password accepted for nick kameloso.",
    ":medusa.us.SpotChat.org 004 kameloso medusa.us.SpotChat.org InspIRCd-2.0 BHIRSWcdghikorswx ACIJKMNOPQRSTYabceghiklmnopqrstvz IJYabeghkloqv",
    ":medusa.us.SpotChat.org 005 kameloso AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=Ibeg,k,Jl,ACKMNOPQRSTcimnprstz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU EXCEPTS=e EXTBAN=,ACNOQRSTUcmz FNC INVEX=I KICKLEN=255 :are supported by this server",
    ":medusa.us.SpotChat.org 005 kameloso MAP MAXBANS=60 MAXCHANNELS=20 MAXPARA=32 MAXTARGETS=20 MODES=20 NAMESX NETWORK=SpotChat NICKLEN=31 OVERRIDE PREFIX=(Yqaohv)!~&@%+ REMOVE SECURELIST :are supported by this server",
    ":medusa.us.SpotChat.org 005 kameloso SSL=64.57.93.14:6697 STARTTLS STATUSMSG=!~&@%+ TOPICLEN=307 UHNAMES VBANLIST WALLCHOPS WALLVOICES WATCH=32 :are supported by this server",
    ":lamia.uk.SpotChat.org 926 kameloso #stuffwecantdiscuss :Channel #stuffwecantdiscuss is forbidden: This channel is closed by request of the channel operators.",
    ":lamia.ca.SpotChat.org 940 kameloso #garderoben :End of channel spamfilter list",
    ":lamia.ca.SpotChat.org 221 kameloso :+ix",
    ":Halcy0n!~Halcy0n@SpotChat-rauo6p.dyn.suddenlink.net AWAY :I'm busy",
    ":Halcy0n!~Halcy0n@SpotChat-rauo6p.dyn.suddenlink.net AWAY",
    ":medusa.us.SpotChat.org 005 kameloso AWAYLEN=200 CALLERID=g CASEMAPPING=rfc1459 CHANMODES=Ibeg,k,Jl,ACKMNOPQRSTcimnprstz CHANNELLEN=64 CHANTYPES=# CHARSET=ascii ELIST=MU EXCEPTS=e EXTBAN=,ACNOQRSTUcmz FNC INVEX=I KICKLEN=255 :are supported by this server",
    ":NickServ!services@services.host NOTICE kameloso^ :Nick kameloso^ isn't registered.",
    ":NickServ!services@services.host NOTICE kameloso^ :Password incorrect.",
    ":NickServ!services@services.host NOTICE kameloso^ :Password accepted - you are now recognized.",
    //":tmi.twitch.tv 004 kameloso :-",
    "@badges=subscriber/3;color=;display-name=asdcassr;emotes=560489:0-6,8-14,16-22,24-30/560510:39-46;id=4d6bbafb-427d-412a-ae24-4426020a1042;mod=0;room-id=23161357;sent-ts=1510059590512;subscriber=1;tmi-sent-ts=1510059591528;turbo=0;user-id=38772474;user-type= :asdcsa!asdcss@asdcsd.tmi.twitch.tv PRIVMSG #lirik :lirikFR lirikFR lirikFR lirikFR :sled: lirikLUL",
    "@broadcaster-lang=;emote-only=0;followers-only=-1;mercury=0;r9k=0;room-id=22216721;slow=0;subs-only=0 :tmi.twitch.tv ROOMSTATE #zorael",
    ":tmi.twitch.tv CAP * LS :twitch.tv/tags twitch.tv/commands twitch.tv/membership",
    ":tmi.twitch.tv USERSTATE #zorael",
    ":tmi.twitch.tv ROOMSTATE #zorael",
    ":tmi.twitch.tv HOSTTARGET #andymilonakis :zombie_barricades -",
    ":tmi.twitch.tv USERNOTICE #drdisrespectlive :ooooo weee, it's a meeeee, Moweee!",
    ":tmi.twitch.tv USERNOTICE #lirik",
    ":tmi.twitch.tv CLEARCHAT #channel :user",
    ":tmi.twitch.tv RECONNECT",
    ":kameloso!kameloso@kameloso.tmi.twitch.tv JOIN p4wnyhof",
    ":kameloso!kameloso@kameloso.tmi.twitch.tv PART p4wnyhof",
    "@badge-info=;badges=;color=#5F9EA0;display-name=Zorael;emote-sets=0,185411,771823,1511983;user-id=22216721;user-type= :tmi.twitch.tv GLOBALUSERSTATE",
    "@msg-id=color_changed :tmi.twitch.tv NOTICE #zorael :Your color has been changed.",
    ":zorael!zorael@zorael.tmi.twitch.tv JOIN #kameboto",
    "@badge-info=;badges=moderator/1;color=#5F9EA0;display-name=Zorael;emote-sets=0,185411,771853,1511983;mod=1;subscriber=0;user-type=mod :tmi.twitch.tv USERSTATE #kameboto",
    "@badge-info=;badges=;color=#008000;display-name=今伊勢;emotes=;flags=;id=fde5380d-0fb8-4406-9790-e09fd0a54543;mod=0;room-id=114701382;subscriber=0;tmi-sent-ts=1569001285736;turbo=0;user-id=184077758;user-type= :rezel02!rezel02@rezel02.tmi.twitch.tv PRIVMSG #arunero9029 :海外プレイヤーが見つけたやつ",
    ":s1faka!s1faka@s1faka.tmi.twitch.tv PART #arunero9029",
    ":tnpmen!tnpmen@tnpmen.tmi.twitch.tv JOIN #arunero9029",
    "@emote-only=0;followers-only=-1;r9k=0;rituals=0;room-id=404208264;slow=0;subs-only=0 :tmi.twitch.tv ROOMSTATE #kameboto",
    "@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#7403B4;display-name=GunnrySGT_Buck;emotes=;flags=;id=09eddc75-d3ce-4c4f-9f08-37ce43c7d325;mod=0;msg-id=highlighted-message;room-id=74488574;subscriber=1;tmi-sent-ts=1569005180759;turbo=0;user-id=70624578;user-type= :gunnrysgt_buck!gunnrysgt_buck@gunnrysgt_buck.tmi$twitch.tv PRIVMSG #beardageddon :Theres no HWAY",
    `@badge-info=subscriber/0;badges=subscriber/0,premium/1;color=#19B336;display-name=IamSlower;emotes=;flags=;id=0a66cc58-57db-4ae6-940d-d46aa315e2d1;login=iamslower;mod=0;msg-id=sub;msg-param-cumulative-months=1;msg-param-months=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=Prime;room-id=69906737;subscriber=1;system-msg=IamSlower\ssubscribed\swith\sTwitch\sPrime.;tmi-sent-ts=1569005836621;user-id=147721858;user-type= :tmi.twitch.tv USERNOTICE #chocotaco`,
    `@badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=f5446beb-bc54-472c-9539-e495a1250a30;login=nappy5074;mod=0;msg-id=subgift;msg-param-months=6;msg-param-origin-id=da\s39\sa3\see\s5e\s6b\s4b\s0d\s32\s55\sbf\sef\s95\s60\s18\s90\saf\sd8\s07\s09;msg-param-recipient-display-name=buffalo_bison;msg-param-recipient-id=141870891;msg-param-recipient-user-name=buffalo_bison;msg-param-sender-count=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\sgifted\sa\sTier\s1\ssub\sto\sbuffalo_bison!;tmi-sent-ts=1569005845776;user-id=230054092;user-type= :tmi.twitch.tv USERNOTICE #chocotaco`,
    `@badge-info=subscriber/15;badges=subscriber/12,sub-gifter/500;color=#0000FF;display-name=nappy5074;emotes=;flags=;id=d7a1da3b-9ba7-495d-bfd5-9ad4f9f434d2;login=nappy5074;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=20;msg-param-origin-id=ce\s08\s4e\sf5\se9\sf5\s31\s6c\s7a\sb6\sbc\sf9\s71\s8a\sf2\s7f\s90\s4c\s87\s47;msg-param-sender-count=650;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=nappy5074\sis\sgifting\s20\sTier\s1\sSubs\sto\schocoTaco's\scommunity!\sThey've\sgifted\sa\stotal\sof\s650\sin\sthe\schannel!;tmi-sent-ts=1569005843145;user-id=230054092;user-type= :tmi.twitch.tv USERNOTICE #chocotaco`,
    `@badge-info=subscriber/11;badges=subscriber/9,premium/1;color=;display-name=Noahxcite;emotes=;flags=;id=2e7b0dbc-d6be-4331-903b-17255ae57d5b;login=noahxcite;mod=0;msg-id=resub;msg-param-cumulative-months=11;msg-param-months=0;msg-param-should-share-streak=0;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=Noahxcite\ssubscribed\sat\sTier\s1.\sThey've\ssubscribed\sfor\s11\smonths!;tmi-sent-ts=1569006106614;user-id=67751309;user-type= :tmi.twitch.tv USERNOTICE #chocotaco`,
    `@badge-info=subscriber/6;badges=subscriber/6,premium/1;color=;display-name=acul1992;emotes=;flags=;id=287de5eb-b93c-4040-86b7-16cddb6cefc8;login=acul1992;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=eb\s39\sea\sd2\sbc\sb4\sd9\sd8\sc9\s51\sd5\s3a\sbb\seb\sd7\s6b\sa8\s2c\sc1\s71;msg-param-sender-count=1;msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=acul1992\sis\sgifting\s1\sTier\s1\sSubs\sto\schocoTaco's\scommunity!\sThey've\sgifted\sa\stotal\sof\s1\sin\sthe\schannel!;tmi-sent-ts=1569006134003;user-id=32127247;user-type= :tmi.twitch.tv USERNOTICE #chocotaco`,
    `@badge-info=subscriber/9;badges=subscriber/9,bits/100;color=#2B22B2;display-name=PoggyFifty;emotes=;flags=;id=21bb6867-1e5b-475c-90a4-c21bc5cf42d3;login=poggyfifty;mod=0;msg-id=resub;msg-param-cumulative-months=9;msg-param-months=0;msg-param-should-share-streak=1;msg-param-streak-months=9;msg-param-sub-plan-name=Channel\sSubscription\s(chocotaco);msg-param-sub-plan=1000;room-id=69906737;subscriber=1;system-msg=PoggyFifty\ssubscribed\sat\sTier\s1.\sThey've\ssubscribed\sfor\s9\smonths,\scurrently\son\sa\s9\smonth\sstreak!;tmi-sent-ts=1569006294587;user-id=204550522;user-type= :tmi.twitch.tv USERNOTICE #chocotaco :WAHEEEEY DA CHOCOOOOOOOOOOOO`,
    "@badge-info=subscriber/13;badges=subscriber/12,twitchconNA2019/1;bits=100;color=#0000FF;display-name=eXpressRR;emotes=757370:0-10;flags=;id=d437ff32-2c98-4c86-b404-85c577e7a63d;mod=0;room-id=69906737;subscriber=1;tmi-sent-ts=1569007507586;turbo=0;user-id=172492216;user-type= :expressrr!expressrr@expressrr.tmi.twitch.tv PRIVMSG #chocotaco :chocotHello Subway100 bonus10 Did you see the chocomerch promo video I made last night??",
    "@ban-duration=600;room-id=79442833;target-user-id=447000332;tmi-sent-ts=1569007534501 :tmi.twitch.tv CLEARCHAT #mithrain :14ahmetkerim",
    "@badge-info=subscriber/1;badges=subscriber/0,premium/1;color=#9ACD32;display-name=burakk1912;emotes=;flags=;id=a805a41d-99e5-4a5d-be80-a95ccefc9e73;login=burakk1912;mod=0;msg-id=primepaidupgrade;msg-param-sub-plan=1000;room-id=79442833;subscriber=1;system-msg=burakk1912\\sconverted\\sfrom\\sa\\sTwitch\\sPrime\\ssub\\sto\\sa\\sTier\\s1\\ssub!;tmi-sent-ts=1569008642164;user-id=242099224;user-type= :tmi.twitch.tv USERNOTICE #mithrain",
    "@badge-info=subscriber/2;badges=subscriber/0;color=#7F7F7F;display-name=WaIt;emotes=;flags=;id=16df867b-4cd0-450d-9bd5-f30f4c8a1781;login=wait;mod=0;msg-id=giftpaidupgrade;msg-param-sender-login=fuzwuz;msg-param-sender-name=fuzwuz;room-id=69906737;subscriber=1;system-msg=WaIt\\sis\\scontinuing\\sthe\\sGift\\sSub\\sthey\\sgot\\sfrom\\sfuzwuz!;tmi-sent-ts=1569010405948;user-id=48663198;user-type= :tmi.twitch.tv USERNOTICE #chocotaco",
    "@login=xinotv;room-id=;target-msg-id=e5fb3fd2-8c0f-4468-b45a-c70f0e615507;tmi-sent-ts=1569010639801 :tmi.twitch.tv CLEARMSG #squeezielive :25 euros de cashprize à gagner me mp",
    "@room-id=52130765;target-user-id=458740201;tmi-sent-ts=1569010642754 :tmi.twitch.tv CLEARCHAT #squeezielive :xinotv",
    "@room-id=52130765;target-user-id=458740201;tmi-sent-ts=1569010642754 :tmi.twitch.tv CLEARCHAT #squeezielive :xinotv",
    ":tmi.twitch.tv HOSTTARGET #kungentv :esfandtv 5167",
    "@msg-id=host_on :tmi.twitch.tv NOTICE #kungentv :Now hosting EsfandTV.",
    "@badge-info=;badges=premium/1;color=#67B222;display-name=travslaps;emotes=30259:0-6;flags=;id=a875d520-ba60-4383-925c-4fa09b3fd772;login=travslaps;mod=0;msg-id=ritual;msg-param-ritual-name=new_chatter;room-id=106125347;subscriber=0;system-msg=@travslaps\\sis\\snew\\shere.\\sSay\\shello!;tmi-sent-ts=1569012207274;user-id=183436052;user-type= :tmi.twitch.tv USERNOTICE #couragejd :HeyGuys",
    ":tmi.twitch.tv HOSTTARGET #asmongold :- 0",
    "@badge-info=subscriber/15;badges=subscriber/12;color=;display-name=tayk47_mom;emotes=;flags=;id=d6729804-2bf3-495d-80ce-a2fe8ed00a26;login=tayk47_mom;mod=0;msg-id=submysterygift;msg-param-mass-gift-count=1;msg-param-origin-id=49\\s9d\\s3e\\s68\\sca\\s26\\se9\\s2a\\s6e\\s44\\sd4\\s60\\s9b\\s3d\\saa\\sb9\\s4c\\sad\\s43\\s5c;msg-param-sender-count=4;msg-param-sub-plan=1000;room-id=71092938;subscriber=1;system-msg=tayk47_mom\\sis\\sgifting\\s1\\sTier\\s1\\sSubs\\sto\\sxQcOW's\\scommunity!\\sThey've\\sgifted\\sa\\stotal\\sof\\s4\\sin\\sthe\\schannel!;tmi-sent-ts=1569013433362;user-id=224578549;user-type= :tmi.twitch.tv USERNOTICE #xqcow",
    "@badge-info=;badges=partner/1;color=#004DFF;display-name=NorddeutscherJunge;emotes=;flags=;id=3ced021d-adab-4278-845d-4c8f2c5d6306;login=norddeutscherjunge;mod=0;msg-id=primecommunitygiftreceived;msg-param-gift-name=World\\sof\\sTanks:\\sCare\\sPackage;msg-param-middle-man=gabepeixe;msg-param-recipient=m4ggusbruno;msg-param-sender=NorddeutscherJunge;room-id=59799994;subscriber=0;system-msg=A\\sviewer\\swas\\sgifted\\sa\\sWorld\\sof\\sTanks:\\sCare\\sPackage,\\scourtesy\\sof\\sa\\sPrime\\smember!;tmi-sent-ts=1570346408346;user-id=39548541;user-type= :tmi.twitch.tv USERNOTICE #gabepeixe",
];

void main()
{
    import std.datetime.stopwatch : StopWatch;
    import std.datetime.systime : Clock;
    import core.time;
    import std.stdio;
    import std.random : uniform;

    IRCServer server;
    IRCClient client;
    IRCParser parser = IRCParser(client, server);
    StopWatch watch;

    immutable prestartSecond = Clock.currTime.toUnixTime;
    long startSecond;
    uint count;

    enum limit = 100.msecs;

    pragma(inline, true)
    static void spinlockUntilNextSecond()
    {
        immutable before = Clock.currTime.toUnixTime;
        while (true)
        {
            if (Clock.currTime.toUnixTime > before) return;
        }
    }

    //spinlockUntilNextSecond();

    //uint good;
    //uint bad;
    uint step = 500_000;
    //uint round;
    double mod = 1.5;

    while (true)
    {
        immutable start = Clock.currTime;

        foreach (immutable i; 0..step)
        {
            import std.conv : text;

            enum endIndex = lines.length;
            immutable index = uniform(0,endIndex);
            immutable line = lines[index];
            assert(line.length, i.text);
            immutable event = parser.toIRCEvent(line);
        }

        immutable stop = Clock.currTime;
        immutable delta = stop - start;
        writeln(step, ": ", delta);
        mod -= 0.05;
        if (mod <= 0.0) break;

        if (delta > 1.seconds)
        {
            if ((1.seconds-delta < limit) && (1.seconds-delta > limit))
            {
                writeln(1.seconds-delta);
                break;
            }

            step = cast(uint)(step/mod);
        }
        else
        {
            step = cast(uint)(step*mod);
        }
    }
}
