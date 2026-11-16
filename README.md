# PartyWelcome

PartyWelcome is a World of Warcraft Forever add-on that automatically welcomes new party members in party chat. Welcomes are themed around **both your character's class and the joining member's class**. Each of the nine joining classes has 17 possible welcomes for each player class: 153 per player class. When you join someone else's party, the add-on still selects from 150 English "hi" messages themed around your class alone. If the joining member's class is unavailable, the add-on reports this and uses a general class-themed welcome instead.

Messages are sent two seconds after a join, with a 10-second cooldown between messages. If several members become eligible at the same time, only one message is sent, choosing the lowest party slot. Messages due during the cooldown are not sent later. If the member leaves or the party becomes a raid before the delay ends, the greeting is cancelled.

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

Run the local checks from this directory:

```powershell
npx --yes --package=fengari-node-cli fengari .\tests\Test-Core.lua
.\tests\Test-Install.ps1
```

The installer check uses a temporary directory, not the game installation.
