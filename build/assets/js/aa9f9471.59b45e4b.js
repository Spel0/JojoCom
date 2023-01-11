"use strict";(self.webpackChunkdocs=self.webpackChunkdocs||[]).push([[93],{15169:e=>{e.exports=JSON.parse('{"functions":[{"name":"SummonStand","desc":"Summons a Stand and automatically tells the player to initiate and control it\\n    ","params":[{"name":"Player","desc":"","lua_type":"Player"},{"name":"Stand","desc":"","lua_type":"string"}],"returns":[],"function_type":"static","realm":["Server"],"source":{"line":64,"path":"src/shared/JojoCombatMod.lua"}},{"name":"RemoveStand","desc":"Removes the Player Stand\\n    ","params":[{"name":"Player","desc":"","lua_type":"Player"}],"returns":[],"function_type":"static","realm":["Server"],"source":{"line":116,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetStand","desc":"Gets the Player Stand Model or nil if none is found\\n    ","params":[{"name":"Player","desc":"","lua_type":"Player"}],"returns":[{"desc":"","lua_type":"Model\\r\\n"}],"function_type":"static","realm":["Server"],"source":{"line":129,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetModFolder","desc":"Gets the folder that the module is located in\\n    ","params":[],"returns":[{"desc":"","lua_type":"Folder\\r\\n"}],"function_type":"static","realm":["Server"],"source":{"line":139,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetFinisherSignal","desc":"Returns 2 signals:\\nFinisher Signal - Activates upon the Finisher being triggered, passes 3 arguments: Attacker (The one who triggered the finisher), Target (The unfortunate soul with low hp) and the Stand Finisher\\nFinisher Finale Signal - Should be fired when the Finisher is done to kill the Target and return the Attacker to the normal state\\n```lua\\n    local finisher, finisherComplete\\n    finisher, finisherComplete = JojoCombatMod.GetFinisherSignal():Connect(function(Attacker:Player, Target:Player, Finisher:string)\\n        --Make animations and such play out\\n        Animation.Finished:Wait()\\n        finisherComplete.Fire()\\n    end)\\n```\\n    ","params":[],"returns":[{"desc":"","lua_type":"Events.Signal"},{"desc":"","lua_type":"Events.Signal"}],"function_type":"static","realm":["Server"],"source":{"line":159,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetPlayerData","desc":"Gets Player Data of a particular player\\n    ","params":[{"name":"plr","desc":"","lua_type":"Player"}],"returns":[{"desc":"","lua_type":"Data.PlayerData\\r\\n"}],"function_type":"static","realm":["Server"],"source":{"line":169,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetDataMod","desc":"Gets Data Module\\n    ","params":[],"returns":[{"desc":"","lua_type":"{}\\r\\n"}],"function_type":"static","realm":["Server"],"source":{"line":179,"path":"src/shared/JojoCombatMod.lua"}},{"name":"MakePlayerInvincible","desc":"Sets a player invincible status in the Player Data\\n    ","params":[{"name":"plr","desc":"","lua_type":"Player"},{"name":"active","desc":"","lua_type":"boolean"}],"returns":[],"function_type":"static","realm":["Server"],"source":{"line":189,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetBlockSignal","desc":"Gets Block Event Signal which passes a boolean argument to indicate if Block is activated or not\\n```lua\\n    _G.JojoCombatMod.GetBlockSignal():Connect( (Active:boolean)=>() )\\n```","params":[],"returns":[],"function_type":"static","source":{"line":202,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetAttackSignal","desc":"Gets Attack Event Signal","params":[],"returns":[],"function_type":"static","source":{"line":211,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetAbilitySignal","desc":"Gets Ability Event Signal","params":[],"returns":[],"function_type":"static","source":{"line":220,"path":"src/shared/JojoCombatMod.lua"}},{"name":"Fire","desc":"Used to fire an Event","params":[{"name":"Name","desc":"","lua_type":"string"},{"name":"...","desc":"","lua_type":"any"}],"returns":[],"function_type":"static","source":{"line":229,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetEventMod","desc":"Gets Events Module","params":[],"returns":[{"desc":"","lua_type":"{}\\r\\n"}],"function_type":"static","source":{"line":238,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetModSettings","desc":"Gets Module Settings","params":[],"returns":[{"desc":"","lua_type":"{}\\r\\n"}],"function_type":"static","source":{"line":247,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetUtilMod","desc":"Gets Utility Module","params":[],"returns":[{"desc":"","lua_type":"{}\\r\\n"}],"function_type":"static","source":{"line":256,"path":"src/shared/JojoCombatMod.lua"}},{"name":"GetAnimMod","desc":"Gets Animation Module","params":[],"returns":[{"desc":"","lua_type":"{}\\r\\n"}],"function_type":"static","source":{"line":265,"path":"src/shared/JojoCombatMod.lua"}}],"properties":[],"types":[],"name":"Main","desc":"Initializes the whole system and exposes methods to control it","source":{"line":13,"path":"src/shared/JojoCombatMod.lua"}}')}}]);