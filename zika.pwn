
#include <a_samp>

new Text:ZikaLogo;

main()
{
    print("================================");
    print("          ZIKA ROLEPLAY");
    print("       Servidor iniciado!");
    print("================================");
}

public OnGameModeInit()
{
    SetGameModeText("ZIKA RP - Mobile");

    AddPlayerClass(
        0,
        1481.0, -1771.0, 18.8,
        90.0,
        0, 0, 0, 0, 0, 0
    );

    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    ShowNameTags(true);
    SetWorldTime(12);
    SetWeather(1);

    // LOGOMARCA ZIKA RP
    ZikaLogo = TextDrawCreate(320.0, 12.0, "ZIKA RP");
    TextDrawAlignment(ZikaLogo, 2);
    TextDrawLetterSize(ZikaLogo, 0.50, 1.80);
    TextDrawColor(ZikaLogo, 0x00E5FFFF);
    TextDrawSetOutline(ZikaLogo, 2);
    TextDrawSetShadow(ZikaLogo, 1);
    TextDrawFont(ZikaLogo, 2);
    TextDrawSetProportional(ZikaLogo, 1);
    TextDrawSetSelectable(ZikaLogo, 0);

    print("[ZIKA RP] Gamemode carregado!");

    return 1;
}

public OnPlayerConnect(playerid)
{
    TextDrawShowForPlayer(playerid, ZikaLogo);

    SendClientMessage(playerid, 0x00FF00FF,
        "Bem-vindo a ZIKA RP!");

    SendClientMessage(playerid, 0xFFFFFFFF,
        "Digite /ajuda para conhecer os comandos.");

    return 1;
}

public OnPlayerSpawn(playerid)
{
    TextDrawShowForPlayer(playerid, ZikaLogo);

    SendClientMessage(playerid, 0x00FFFFFF,
        "Divirta-se na cidade ZIKA RP!");

    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (strcmp(cmdtext, "/ajuda", true) == 0)
    {
        SendClientMessage(playerid, 0xFFFF00FF,
            "COMANDOS: /vida /colete /spawn");
        return 1;
    }

    if (strcmp(cmdtext, "/vida", true) == 0)
    {
        SetPlayerHealth(playerid, 100.0);
        SendClientMessage(playerid, 0x00FF00FF,
            "Sua vida foi restaurada!");
        return 1;
    }

    if (strcmp(cmdtext, "/colete", true) == 0)
    {
        SetPlayerArmour(playerid, 100.0);
        SendClientMessage(playerid, 0x00FF00FF,
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
