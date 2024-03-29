/*
////////////////////////////////////////////////////////////////////////////////
// shoulderGun weapon/item  ////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
credits: 
sprites: banjo software, ramon.dexter
sounds: banjo software
zscript: ramon.dexter, gzdoom.pk3

////////////////////////////////////////////////////////////////////////////////
*/
////////////////////////////////////////////////////////////////////////////////

// puff with decal /////////////////////////////////////////////////////////////
class decalMaulerPuff : MaulerPuff {
	Default {
		//+NODECAL
		Decal "BulletChip";
	}
}
// inventory item with new functionality ///////////////////////////////////////
class shoulderGun : CustomInventory {	
		
	action void W_FireShoulderGun(bool useAmmo, bool doAlertMonsters, int overlayNumber) {        
		if (player == null) {
			return;
		}
		let ownr2 = playerPawn(invoker.owner);
		if (useAmmo) {
			ownr2.takeInventory("shoulderGun_magazine", 1);
		}		
		//  shoot action z blasterStaff lvl.2 altFire  /////////////////////////
		A_StartSound("weapons/shoulderGun/loop", CHAN_5, CHANF_DEFAULT, 1.0, false); 
		int shootHeight = ownr2.viewheight - 24;		
		if ( ownr2.viewHeight == 46.0 ) { shootHeight = 16; } //ashes
		if ( ownr2.viewHeight == 48.0 ) { shootHeight = 19; } //hexen
		if ( ownr2.viewHeight == 56.0 ) { shootHeight = 10; } //ascension
 		A_FireProjectile("greenArcLightning", 0.1*random(20,-20), false, -13, shootHeight, 0, 0);
		A_SpawnItemEx("SHGflashShort", 8, 0, 16, 0);
		if ( doAlertMonsters ) {
			A_AlertMonsters();
		}
		A_OverlayOffset(overlayNumber, random(-2,2), random(-2,2), WOF_INTERPOLATE); //tohle trese s shouldergunem...a shouldergun neni weapon, ale overlay!
		////////////////////////////////////////////////////////////////////////
	}
	
	Default {
		//$Category "Items"
		//$Color 9
		//$Title "ShoulderGun"
		
		+INVENTORY.INVBAR
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE

		Tag "Shouldergun";
		Inventory.Icon "I_SHCN";
		Inventory.Amount 1;
		Inventory.MaxAmount 1;	
		Inventory.InterhubAmount 1;
		Inventory.PickupMessage "You've picked up a Shouldergun!";
		Decal "BulletChip";
		scale 0.35;
	}	
	States {
		Spawn:
			SHG3 V -1;
			Stop;
		Use:
			TNT1 A 0 {			
				statelabel nextstate = "remove";
				let ownr = playerPawn(invoker.owner); 
				if (ownr && ownr.countInv("shoulderGun_magazine") > 0 ) {					
					nextstate = "startoverlay";						 									
				}
				else {
					A_Log("\c[red][ Not enough ammo! ]");
					A_ClearOverlays(6, 6);
					return ResolveState("remove");					
				}
				return resolvestate(nextstate);
			}
			Fail;	  
		startoverlay:
			TNT1 A 0 {
				int layer = 6;
				A_OverLay(layer,"shootShoulderGun");
			}
			wait;
		shootShoulderGun:
			SHCH JIHGFEDCBA 1;
			SHCH AA 1;
			SHCN A 2;
			SHCN I 2 Bright W_FireShoulderGun(true, true, 6);
			SHCN J 2 Bright W_FireShoulderGun(false, false, 6);
			SHCN I 2 Bright W_FireShoulderGun(false, true, 6);
			SHCN J 2 Bright W_FireShoulderGun(false, false, 6);
			SHCN I 2 Bright W_FireShoulderGun(false, true, 6);
			SHCN J 2 Bright W_FireShoulderGun(false, false, 6);
			SHCN B 3;
			SHCN C 3;
			SHCN D 4 A_StartSound("weapons/shoulderGun/stop",5); //cancel shoot sound
			SHCN E 5;
			SHCN F 4;
			SHCN G 4;
			SHCN H 3;
			SHCN A 3;
			SHCH ABCDEFGHIJ 1;
			TNT1 A 0 {
				return resolveState("remove");
			}		
		remove:
			TNT1 A 0 {
				A_ClearOverlays(6, 6);
			}
			Fail;	
	}
}
// weapon/item ammunition //////////////////////////////////////////////////////
class shoulderGun_magazine : CustomInventory {
	Default {
		//$Category "Items"
		//$Title "Shouldercannon Ammo"
		
		+INVENTORY.INVBAR	
		+INVENTORY.UNDROPPABLE
		radius 10;
		height 16;
		Tag "Shouldergun Magazine";
		inventory.icon "I_SHCC";
		inventory.amount 1;
		Inventory.MaxAmount 32;
		inventory.interhubamount 32;
		Inventory.PickupMessage "Shouldergun Magazine acquired.";
		Mass 0;
	}	
	States {
		Spawn:
			SHCC AB 6 Bright;
			Loop;
		Use:
			TNT1 A 0;
			Stop;
	}
}
class shoulderGunMag_item : CustomInventory {
	Default {
		//$Category "Items"
		//$Title "Shouldercannon Ammo pack"
		
		//radius 10;
		//height 16;
		+INVENTORY.INVBAR	
		scale 0.55;
		Tag "Shouldercannon Ammo pack";
		inventory.icon "I_SHMG";
		Inventory.PickupMessage "You've picked up a Shouldercannon Ammo pack!";
		Inventory.Amount 1;
		Inventory.MaxAmount 32;	
		Inventory.InterhubAmount 32;
	}
	States {
		Spawn:
			SHMG V -1;
			Stop;
		Use:
			TNT1 A 0 A_GiveInventory("shoulderGun_magazine", 32);
			Stop;
	}
}
class shoulderGunCharger : CustomInventory {

	action void SOA_reloadShoulderGun() {
		if ( player == null ) {
			return;
		}
		int ammoToCharge;
		ammoToCharge = 32 - CountInv("shoulderGun_magazine");
		if ( CountInv("shoulderGun_magazine") == 32 ) {
			A_Log("$M_shgun_chargeFull");
		} else {
			if ( CountInv("shoulderGun_magazine") < 32 ) {
				A_StartSound("weapons/shouldergun/recharge");
				A_GiveInventory("shoulderGun_magazine", ammoToCharge);
				A_Log(String.Format("%s%i%s", stringtable.localize("$M_shgun_recharge1"), ammoToCharge, stringtable.localize("$M_shgun_recharge2")));
			} else {
				A_StartSound("weapons/shouldergun/noAmmo");
				A_Log("$M_shgun_notenoughrecharge");
			}
		}
	}

	Default {
		//$Category "Items"
		//$Color 17
		//$Title "ShoulderGun Charger"
		+INVENTORY.INVBAR
		+INVENTORY.ALWAYSPICKUP
		+INVENTORY.UNDROPPABLE
		Tag "ShoulderGun Charger";
		Inventory.Icon "I_SHCR";
		Inventory.PickupMessage "You've picked up a ShoulderGun Charger!";
		Inventory.Amount 1;
		Inventory.MaxAmount 1;	
		Inventory.InterhubAmount 1;
		Scale 0.35;
	}
	States {
		Spawn:
			SWRP V -1;
			Stop;
		Use:
			TNT1 A 0 SOA_reloadShoulderGun();
			Fail;
	}
}
// projectile //////////////////////////////////////////////////////////////////
class greenArcLightning : FastProjectile {
	Default {
		Speed 50;
		Radius 4;
		Height 4;
		Damage 6;
		Renderstyle "Add";
		MissileType "arcLightningTrailSpawner";
		Decal "DoomImpScorch";
		+CANNOTPUSH
		+BLOODLESSIMPACT
		+THRUGHOST
	}
	states {
		Spawn:
			TNT1 A 2;
		Looplet:
			TNT1 A 0;
			TNT1 A 2 A_ChangeVelocity(frandom(-8,8), frandom(-8,8), frandom(-3, 3), 0);
			TNT1 A 2 A_ChangeVelocity(frandom(-8,8), frandom(-8,8), frandom(-3, 3), 0);
			TNT1 A 2 A_ChangeVelocity(frandom(-6,6), frandom(-6,6), frandom(-3, 3), 0);
			Stop;
		Ded:
			TNT1 A 1;
			stop;
	}
}
class arcLightningTrailSpawner : actor {
	Default {
		+NOINTERACTION
		+NOGRAVITY
		+THRUGHOST
	}
	States {
		Spawn:
			TNT1 A 0;
			TNT1 A 2 A_SpawnItemEx("arcLightningTrail",frandom(2.0,-2.0),frandom(2.0,-2.0),4+frandom(2.0,-2.0),0,0,0,0,0,0);
			Stop;
	}
}
class arcLightningTrail : actor {
	Default {
		RenderStyle "Add";
		Scale 0.175;
		Alpha 0.75;
		+NOINTERACTION
		+NOGRAVITY
		+THRUGHOST
	}
	States {
		Spawn:
			TNT1 A 0;
			PLSG BBCCDD 1 bright light("gl_shouldergun_lightningFlash") A_FadeOut(0.1);
		Trolololo:
			TNT1 A 0 A_SetScale(Scale.X -0.01, Scale.Y -0.01);
			PLSG D 1 bright light("gl_shouldergun_lightningFlash") A_FadeOut(0.08);
			Loop;
	}
}
// flash actor /////////////////////////////////////////////////////////////////
class SHGflashShort : actor { //used for light to spawn
	Default {
		+NOINTERACTION
		+MISSILE
		+NOBLOCKMAP
		+NOGRAVITY
		+DROPOFF
		+NOTELEPORT
		+FORCEXYBILLBOARD
		+NOTDMATCH
		+GHOST		
		Radius 1;
		Height 1;
		Mass 1;
		Damage 0;
		Speed 0;
	}
	States {
		Spawn:
			TNT1 A 3 NODELAY light("gl_shouldergun_greenflash");
			Stop;
	}
}
// dummy decorative items //////////////////////////////////////////////////////
class shoulderGun1_dummy : actor {
	Default {
		//$Category "items/Dummies"
		//$Color 1
		//$Title "shoulderGun1 dummy"
		
		-SOLID		
		Height 24;
		Radius 16;
		Scale 0.35;
	}
	
	States {
		Spawn:
			SHG1 V -1;
			Stop;			
	}
}
class shoulderGun2_dummy : actor {
	Default {
		//$Category "items/Dummies"
		//$Color 1
		//$Title "shoulderGun2 dummy"
		
		-SOLID		
		Height 24;
		Radius 16;
		Scale 0.35;
	}
	States {
		Spawn:
			SHG2 V -1;
			Stop;
	}
}
class shoulderGun3_dummy : actor {
	Default {
		//$Category "items/Dummies"
		//$Color 1
		//$Title "shoulderGun3 dummy"
		
		-SOLID		
		Height 24;
		Radius 16;
		Scale 0.35;
	}
	States {
		Spawn:
			SHG3 V -1;
			Stop;
	}
}
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////