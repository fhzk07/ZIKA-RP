
#include <a_samp>

#define COR_VERDE 0x00FF00FF
#define COR_CIANO 0x00E5FFFF
#define COR_VERMELHO 0xFF3333FF
#define PAGAMENTO_ENTREGA 250

new Text:ZikaLogo;
new bool:TrabalhandoEntrega[MAX_PLAYERS];
new EntregaVeiculo[MAX_PLAYERS];
new EntregaEtapa[MAX_PLAYERS];

main()
{
    print("ZIKA RP - Servidor iniciado!");
}

public OnGameModeInit()
{
    SetGameModeText("ZIKA RP - Mobile");

    AddPlayerClass(0, 1481.0, -1771.0, 18.8, 90.0,
        0, 0, 0, 0, 0, 0);

    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    ShowNameTags(true);
    SetWorldTime(12);
    SetWeather(1);

    ZikaLogo = TextDrawCreate(320.0, 12.0, "ZIKA RP");
    TextDrawAlignment(ZikaLogo, 2);
    TextDrawLetterSize(ZikaLogo, 0.50, 1.80);
    TextDrawColor(ZikaLogo, COR_CIANO);
    TextDrawSetOutline(ZikaLogo, 2);
    TextDrawSetShadow(ZikaLogo, 1);
    TextDrawFont(ZikaLogo, 2);
    TextDrawSetProportional(ZikaLogo, 1);
    TextDrawSetSelectable(ZikaLogo, 0);

    return 1;
}

public OnPlayerConnect(playerid)
{
    TrabalhandoEntrega[playerid] = false;
    EntregaVeiculo[playerid] = INVALID_VEHICLE_ID;
    EntregaEtapa[playerid] = 0;

    SendClientMessage(playerid, COR_CIANO,
        "Bem-vindo a ZIKA RP!");
    SendClientMessage(playerid, 0xFFFFFFFF,
        "Digite /empregos para conhecer os trabalhos.");

    return 1;
}

public OnPlayerSpawn(playerid)
{
    TextDrawShowForPlayer(playerid, ZikaLogo);
    SendClientMessage(playerid, COR_CIANO,
        "Divirta-se na cidade ZIKA RP!");
    return 1;
}

stock IniciarEntrega(playerid)
{
    new Float:x, Float:y, Float:z, Float:angulo;

    if (TrabalhandoEntrega[playerid])
    {
        SendClientMessage(playerid, COR_VERMELHO,
            "Voce ja esta trabalhando como entregador.");
        return 1;
    }

    GetPlayerPos(playerid, x, y, z);
    GetPlayerFacingAngle(playerid, angulo);

    EntregaVeiculo[playerid] = CreateVehicle(
        448,
        x + (2.5 * floatsin(-angulo, degrees)),
        y + (2.5 * floatcos(-angulo, degrees)),
        z,
        angulo,
        -1, -1, -1
    );

    if (EntregaVeiculo[playerid] == INVALID_VEHICLE_ID)
    {
        SendClientMessage(playerid, COR_VERMELHO,
            "Nao foi possivel criar a moto.");
        return 1;
    }

    TrabalhandoEntrega[playerid] = true;
    EntregaEtapa[playerid] = 0;

    PutPlayerInVehicle(playerid, EntregaVeiculo[playerid], 0);

    SetPlayerCheckpoint(playerid,
        1833.0, -1842.0, 13.5, 5.0);

    SendClientMessage(playerid, COR_VERDE,
        "Emprego iniciado! Voce recebeu uma moto.");
    SendClientMessage(playerid, COR_CIANO,
        "Siga o checkpoint. Cada entrega paga $250.");

    return 1;
}

stock PararEntrega(playerid)
{
    if (!TrabalhandoEntrega[playerid])
    {
        SendClientMessage(playerid, COR_VERMELHO,
            "Voce nao esta trabalhando.");
        return 1;
    }

    DisablePlayerCheckpoint(playerid);

    if (GetPlayerVehicleID(playerid) == EntregaVeiculo[playerid])
        RemovePlayerFromVehicle(playerid);

    if (IsValidVehicle(EntregaVeiculo[playerid]))
        DestroyVehicle(EntregaVeiculo[playerid]);

    EntregaVeiculo[playerid] = INVALID_VEHICLE_ID;
    TrabalhandoEntrega[playerid] = false;
    EntregaEtapa[playerid] = 0;

    SendClientMessage(playerid, COR_CIANO,
        "Expediente encerrado!");

    return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
    if (!TrabalhandoEntrega[playerid])
        return 1;

    if (GetPlayerVehicleID(playerid) != EntregaVeiculo[playerid])
    {
        SendClientMessage(playerid, COR_VERMELHO,
            "Voce precisa estar na moto de entrega.");
        return 1;
    }

    GivePlayerMoney(playerid, PAGAMENTO_ENTREGA);

    SendClientMessage(playerid, COR_VERDE,
        "Entrega concluida! Voce recebeu $250.");

    EntregaEtapa[playerid]++;

    if (EntregaEtapa[playerid] == 1)
        SetPlayerCheckpoint(playerid, 2495.0, -1687.0, 13.5, 5.0);
    else if (EntregaEtapa[playerid] == 2)
        SetPlayerCheckpoint(playerid, 1368.0, -1279.0, 13.5, 5.0);
    else
    {
        EntregaEtapa[playerid] = 0;
        SetPlayerCheckpoint(playerid, 1833.0, -1842.0, 13.5, 5.0);
    }

    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (strcmp(cmdtext, "/ajuda", true) == 0)
    {
        SendClientMessage(playerid, COR_CIANO,
            "COMANDOS: /empregos /entregador /parar /vida /colete /spawn");
        return 1;
    }

    if (strcmp(cmdtext, "/empregos", true) == 0)
    {
        SendClientMessage(playerid, COR_CIANO,
            "===== EMPREGOS ZIKA RP =====");
        SendClientMessage(playerid, 0xFFFFFFFF,
            "Entregador: digite /entregador.");
        return 1;
    }

    if (strcmp(cmdtext, "/entregador", true) == 0)
        return IniciarEntrega(playerid);

    if (strcmp(cmdtext, "/parar", true) == 0)
        return PararEntrega(playerid);

    if (strcmp(cmdtext, "/vida", true) == 0)
    {
        SetPlayerHealth(playerid, 100.0);
        SendClientMessage(playerid, COR_VERDE,
            "Sua vida foi restaurada!");
        return 1;
    }

    if (strcmp(cmdtext, "/colete", true) == 0)
    {
        SetPlayerArmour(playerid, 100.0);
        SendClientMessage(playerid, COR_VERDE,
            "Colete completo!");
        return 1;
    }

    if (strcmp(cmdtext, "/spawn", true) == 0)
    {
        SpawnPlayer(playerid);
        return 1;
    }

    return 0;
}

public OnPlayerDisconnect(playerid, reason)
{
    DisablePlayerCheckpoint(playerid);

    if (IsValidVehicle(EntregaVeiculo[playerid]))
        DestroyVehicle(EntregaVeiculo[playerid]);

    TrabalhandoEntrega[playerid] = false;
    EntregaVeiculo[playerid] = INVALID_VEHICLE_ID;
    EntregaEtapa[playerid] = 0;

    return 1;
}
