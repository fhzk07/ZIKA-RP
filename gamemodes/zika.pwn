
#include <a_samp>

main()
{
    print("================================");
    print("       ZIKA RP INICIANDO");
    print("    Cidade Brasileira RP");
    print("================================");
}

public OnGameModeInit()
{
    SetGameModeText("ZIKA RP | Brasil");

    AddPlayerClass(
        0,
        1958.3783, 1343.1572, 15.3746,
        269.1425,
        0, 0, 0, 0, 0, 0
    );

    print("[ZIKA RP] Cidade iniciada!");

    return 1;
}

public OnPlayerConnect(playerid)
{
    SendClientMessage(
        playerid,
        0x00FF00FF,
        "Bem-vindo a ZIKA RP! Sua historia comeca aqui."
    );

    return 1;
}
