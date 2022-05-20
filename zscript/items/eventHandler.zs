
class shoulderGunEventHandler : EventHandler {

    override void NetworkProcess(ConsoleEvent e) {
        let pawn = playerPawn(players[e.Player].mo);

        if ( e.Name ~== "giveShouldergun" ) {
            pawn.A_GiveInventory("shoulderGun", 1);
            pawn.A_GiveInventory("shoulderGun_magazine", 32);
            pawn.A_GiveInventory("shoulderGunCharger", 1);
        }
    }
    
}