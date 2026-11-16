# PartyWelcome

PartyWelcome is a World of Warcraft Forever add-on that automatically welcomes new party members in party chat. It picks a random greeting themed around **your character's class**, and sends one message two seconds after the join. There are 60 English "welcomes" per class (used when someone joins your party, in `Core.lua` and `ExtraGreetings.lua`) and 30 English "hi" messages per class (used when you join someone else's party, in `Hallos.lua` and `ExtraGreetings.lua`). Only one message is sent per join, with a 10 second cooldown between messages. If the member leaves or the party becomes a raid before then, the greeting is cancelled.

There are no message settings or custom greetings. Disable the add-on to stop greetings. The add-on does not greet members already present when you log in or reload, and it does not send messages while you are in a raid.

Raid rosters are not scanned. Returning from a raid establishes a new party
baseline without greeting existing members; subsequent party joins are greeted.

When a Warlock begins channeling Ritual of Summoning in a party, PartyWelcome sends
a randomly selected portal announcement from 50 choices, naming the passenger and the
Warlock's current zone. The announcement does not mean the ritual completed or
the passenger accepted. It is not sent in a raid or without a party. If the
passenger or zone cannot be identified, no announcement is sent.

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
npx --yes --package=fengari-node-cli fengari .\tests\Test-SummonAnnouncements.lua
.\tests\Test-Install.ps1
```

The installer check uses a temporary directory, not the game installation.
