comment "
    License:
    https://github.com/M9-SD/A3_Tachanka_Unit_Init_Script/blob/main/LICENSE
";
comment "
	Composition:
	https://steamcommunity.com/sharedfiles/filedetails/?id=2889594143
";
comment "
    Tachanka Script
    by M9-SD
";
comment "V1.0A";
_tachanka = this;
comment "[!] UNIT MUST BE LOCAL [!]";
if (!local _tachanka) exitWith {};
comment "Set skills";
_tachanka setSkill 1;
_tachanka setSkill["general", 1];
_tachanka setSkill["courage", 1];
_tachanka setSkill["aimingAccuracy", 1];
_tachanka setSkill["aimingShake", 1];
_tachanka setSkill["aimingSpeed", 1];
_tachanka setSkill["commanding", 1];
_tachanka setSkill["endurance", 1];
_tachanka setSkill["spotDistance", 1];
_tachanka setSkill["spotTime", 1];
_tachanka setSkill["reloadSpeed", 0.7];
_tachanka allowFleeing 0;
comment "Give _tachanka his loadout.";
comment "Exported from Arsenal by Alcatraz";
comment "Remove existing items";
removeAllWeapons _tachanka;
removeAllItems _tachanka;
removeAllAssignedItems _tachanka;
removeUniform _tachanka;
removeVest _tachanka;
removeBackpack _tachanka;
removeHeadgear _tachanka;
removeGoggles _tachanka;
comment "Add weapons";
_tachanka addWeapon "arifle_RPK12_F";
_tachanka addPrimaryWeaponItem "75rnd_762x39_AK12_Lush_Mag_Tracer_F";
comment "Add containers";
_tachanka forceAddUniform "U_O_R_Gorka_01_camo_F";
_tachanka addVest "V_CarrierRigKBT_01_heavy_Olive_F";
_tachanka addBackpack "B_LegStrapBag_black_F";
comment "Add items to containers";
for "_i"
from 1 to 2 do {
    _tachanka addItemToVest "FirstAidKit";
};
for "_i"
from 1 to 3 do {
    _tachanka addItemToVest "75rnd_762x39_AK12_Lush_Mag_Tracer_F";
};
for "_i"
from 1 to 4 do {
    _tachanka addItemToVest "SmokeShell";
};
for "_i"
from 1 to 2 do {
    _tachanka addItemToVest "HandGrenade";
};
for "_i"
from 1 to 3 do {
    _tachanka addItemToBackpack "75rnd_762x39_AK12_Lush_Mag_Tracer_F";
};
_tachanka addHeadgear "H_CrewHelmetHeli_O";
_tachanka addGoggles "G_Aviator";
comment "Add items";
_tachanka linkItem "ItemCompass";
_tachanka linkItem "ChemicalDetector_01_watch_F";
_tachanka linkItem "ItemRadio";
_tachanka linkItem "I_E_UavTerminal";
comment "Set identity";
[_tachanka, "WhiteHead_29", "male01rus"] call BIS_fnc_setIdentity;
[_tachanka, "Spetsnaz223rdDetachment"] call BIS_fnc_setUnitInsignia;
comment "Disable recoil for _tachanka (bullets are scripted inaccurate).";
_tachanka setUnitRecoilCoefficient 0;
comment "Make _tachanka slow.";
[_tachanka, 0.7] remoteExec['setAnimSpeedCoef', 0, (str _tachanka) + 'setAnimSpeedCoefJIP'];
comment "Give _tachanka armor hitpoints (like shield in halo)";
_tachanka setVariable['ArmorHP', 100];
comment "Dammage handling (armor, soundFX, etc).";
comment "Play 3D sound when armor gets hit/depleted.";
_EH_handleDmg = _tachanka addEventHandler['HandleDamage', {
    params["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint"];
    _returnDmg = _damage;
    comment "systemChat _selection;";
    _hitLog = _unit getVariable['hitLog', []];
    _hitLog pushBack[_selection, time];
    _unit setVariable['hitLog', _hitLog];
    _armorHP_pre = _unit getVariable['ArmorHP', 100];
    if (_armorHP_pre > 0) then {
        _armorDmg = _damage * 1;
        _armorHP_post = _armorHP_pre - _armorDmg;
        _unit setVariable['ArmorHP', _armorHP_post];
        comment "dmgInspection = [_armorHP_pre, _damage, _armorDmg, _armorHP_post];";
        comment "systemChat str dmgInspection;";
        if (_selection in ['head']) then {
            _armorHitPFX = createVehicle["#particlesource", ASLToATL(_unit modelToWorldWorld(_unit selectionPosition _selection)), [], 0, "CAN_COLLIDE"];
            _armorHitPFX setParticleClass(selectRandom["ImpactSparksSabot2"]);
            _armorHitPFX attachTo[_unit, [0, -0.05, 0.2], _selection];
            _armorHitPFX spawn {
                sleep 0.1;
                deleteVehicle _this;
            };
            playSound3D[format["A3\sounds_f_tank\arsenal\weapons\launchers\adds\metal0%1.wss", selectRandom[1, 2, 3]], _unit, false, getPosASL _unit, 1.5, random[0.25, 0.75, 1], 1600, 0, false];
            playSound3D["A3\sounds_f_tank\arsenal\weapons\launchers\adds\kick.wss", _unit, false, getPosASL _unit, 0.3, 1, 1600, 0, false];
        };
        _returnDmg = 0;
    } else {
        _returnDmg = _damage;
    };
    _armorHP_post = _unit getVariable['ArmorHP', 100];
    _breakArmor =
    if (_armorHP_post <= 0) then {
        true
    } else {
        false
    };
    if (_breakArmor && (!(_unit getVariable['armorBroken', false]))) then {
        _unit setVariable['armorBroken', true];
        _unit setVariable['armorBreakTime', time];
        if (_selection in ['head']) then {
            comment "armor break 2";
            _armorHitPFX3 = createVehicle["#particlesource", ASLToATL(_unit modelToWorldWorld(_unit selectionPosition 'head')), [], 0, "CAN_COLLIDE"];
            _armorHitPFX3 setParticleClass "FireSparksSmall3";
            _armorHitPFX3 attachTo[_unit, [0, -0.05, 0.2], 'head'];
            _armorHitPFX3 spawn {
                sleep 0.2;
                deleteVehicle _this;
            };
        } else {
            comment "armor break 1";
            _armorHitPFX2 = createVehicle["#particlesource", ASLToATL(_unit modelToWorldWorld(_unit selectionPosition 'head')), [], 0, "CAN_COLLIDE"];
            _armorHitPFX2 setParticleClass selectRandom["FireSparksSmall", "FireSparksSmall1", "FireSparksSmall2"];
            _armorHitPFX2 attachTo[_unit, [0, -0.05, 0.2], 'head'];
            _armorHitPFX2 spawn {
                sleep 0.2;
                deleteVehicle _this;
            };
        };
        playSound3D[format["A3\sounds_f\air\UAV_01\Quad_crash_%1.wss", selectRandom[7, 8, 9]], _unit, false, getPosASL _unit, 5, random[0.9, 1.1, 1.5], 1600, 0, false];
        removeVest _unit;
        removeHeadgear _unit;
    };
    _armorBreakTime = _unit getVariable['armorBreakTime', 0];
    if (_armorBreakTime == 0) then {
        _returnDmg = 0;
    } else {
        if ((time - _armorBreakTime) < 1) then {
            _returnDmg = 0;
        };
    };
    _returnDmg
}];
comment "Prevent _tachanka from going prone.";
_tachanka setUnitPos 'UP';
comment " 
_tachanka spawn {
    while {
        alive _this
    }
    do {
        waitUntil {
            sleep 0.1;
            (unitpos _this == 'Down')
        };
        _this setUnitPos(selectRandom['Up', 'Middle']);
        sleep 0.1;
        _this setUnitPos 'Auto';
    };
};
"; 
comment "Make _tachanka do suppressive fire on his targets";
comment " 
_tachanka spawn {
    while {
        alive _this
    }
    do {
        waitUntil {
            sleep 0.1;
            (not(isNull(getAttackTarget _this)))
        };
        private _atkTgt = getAttackTarget _this;
        if (!isNull(getAttackTarget _this)) then {
            _this doSuppressiveFire _atkTgt;
            _this suppressFor 30;
        };
        waitUntil {
            sleep 0.1;
            (isNull(getAttackTarget _this))
        };
    };
};
"; 
EH_inaccurateFire = _tachanka addEventHandler['firedman', {
    params["_unit", "_weapon", "_muzzle", "_mode", "_ammo", "_magazine", "_projectile", "_vehicle"];
    comment " 
    _weapon = currentWeapon _unit;
    _ammo = _unit ammo _weapon;
    _unit setAmmo[_weapon, 0];
    _unit forceWeaponFire[_weapon, 'Burst'];
    _unit setAmmo[_weapon, _ammo];
    ";  [_unit, _weapon] spawn {
        params['_unit', '_weapon'];
        _unit forceWeaponFire[_weapon, "Burst"];
        sleep 0.15;
        _unit forceWeaponFire[_weapon, "Burst"];
    };
    _v = velocityModelSpace _projectile;
    _v set [0, (selectRandom[-1, 1]) * (random 60) + (_v# 0)];
    _v set [2, (selectRandom[-1, 1]) * (random 30) + (_v# 2)];
    _projectile setVelocityModelSpace _v;
    _unit spawn {
        if !(_this getVariable['suppressing', false]) then {
            if (!isNull(getAttackTarget _this)) then {
                _atkTgt = getAttackTarget _this;
                _this doSuppressiveFire _atkTgt;
                _this suppressFor 30;
                _this setVariable['suppressing', true];
                comment "systemChat 'suppressing';";
                _t30 = [] spawn {
                    sleep 30;
                };
                waitUntil {
                    scriptDone _t30 || !alive _atkTgt
                };
                _this doSuppressiveFire objNull;
                _this suppressFor 0;
                _this setVariable['suppressing', false];
                comment "systemChat 'not suppressing';";

            };
        };
    };
}];
EH_autoRearmOnReload = _tachanka addEventHandler["Reloaded", {
    params["_unit", "_weapon", "_muzzle", "_newMagazine", "_oldMagazine"];
    _unit addMagazineGlobal(_oldMagazine select 0);
    if (_weapon == secondaryWeapon _unit) then {
        _unit addMagazineGlobal((secondaryWeaponMagazine _unit) select 0);
    };
}];
comment "V1.0A";
comment "
    Tachanka Script
    by M9-SD
";
comment "
	Composition:
	https://steamcommunity.com/sharedfiles/filedetails/?id=2889594143
";
comment "
    License:
    https://github.com/M9-SD/A3_Tachanka_Unit_Init_Script/blob/main/LICENSE
";
