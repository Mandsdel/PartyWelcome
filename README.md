# PartyWelcome

PartyWelcome is a World of Warcraft Forever add-on that sends a configurable message in party chat when a new member appears in your party. The default is `Hey, welcome friend`.

Change the message in **Options > AddOns > PartyWelcome**. The setting is saved between sessions. Clearing the message disables greetings. The add-on does not greet members already present when you log in or reload, and it does not send messages while you are in a raid.

Raid rosters are not scanned. Returning from a raid establishes a new party
baseline without greeting existing members; subsequent party joins are greeted.

## Installation

With the game closed, run:

```powershell
.\Install-PartyWelcome.ps1
```

The default destination is `D:\World of Warcraft\_forever_\Interface\AddOns`. To use another AddOns directory:

```powershell
.\Install-PartyWelcome.ps1 -AddOnsPath 'E:\World of Warcraft\_forever_\Interface\AddOns'
```

Enable **PartyWelcome** at character select. The add-on targets interface `16001`. In-game behavior has not been tested on this development machine.

With a compatible Lua interpreter, run the mocked roster checks from this
directory with `lua .\tests\Test-Core.lua`.
