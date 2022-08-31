# GoToggl

This plugin allows you to track your Toggl time directly from the Godot interface! 

## Requirements
- Godot 3+
- togglkey.json file

### togglkey.json

This file can be automatically generated using the GoToggl Wizard, which can be found in Project > Tools > GoToggl Wizard.

```
{
    "api_token": "dfd35235dsfsd24523523",
    "workspace_id": 11000245,
    "project_id": 11100111,
    "description": "GoToggl Entry"
}
```
Get your API Token [here](https://track.toggl.com/profile) listed towards the bottom of the page.

And your ![#f03c15](https://via.placeholder.com/15/f03c15/f03c15.png) workspace and ![#1589F0](https://via.placeholder.com/15/1589F0/1589F0.png) project IDs can be found here in your toggl urls:

![example url](https://i.imgur.com/kigbMh3.png)

Add the following to your .gitignore so that user's togglkeys aren't accidently posted to a public repo or synced across teams
```
# GoToggl specific api key file
*togglkey.json
```
