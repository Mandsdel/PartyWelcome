# PartyWelcome

PartyWelcome is a World of Warcraft Forever add-on that automatically welcomes new party members in party chat. It picks a random greeting themed around **your character's class** from 450 greetings (50 per class), and sends it two seconds after the member joins. If the member leaves or the party becomes a raid before then, the greeting is cancelled.

There are no message settings or custom greetings. Disable the add-on to stop greetings. The add-on does not greet members already present when you log in or reload, and it does not send messages while you are in a raid.

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
