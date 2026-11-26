
#include <a_samp>

#define COR_VERDE       0x00FF00FF
#define COR_CIANO       0x00E5FFFF
#define COR_VERMELHO    0xFF3333FF
#define COR_BRANCO      0xFFFFFFFF

#define PAGAMENTO_ENTREGA 250

#define DIALOG_EMPREGO 1000
#define DIALOG_ROUPAS 1001
#define DIALOG_CONCESSIONARIA 1002

#define PRECO_ROUPA 500

// Agencia de empregos
#define AGENCIA_X 1477.5
#define AGENCIA_Y -1771.0
#define AGENCIA_Z 18.8

// Loja de roupas - Binco em Los Santos
#define ROUPAS_X 2244.3
#define ROUPAS_Y -1665.5
#define ROUPAS_Z 15.5

// Concessionaria - Los Santos
#define CONCESSIONARIA_X 2131.5
#define CONCESSIONARIA_Y -1150.0
#define CONCESSIONARIA_Z 24.1

new Text:ZikaLogo;
new Actor:FuncionarioEmpregos;
new Text3D:TextoAgencia;

new bool:TrabalhandoEntrega[MAX_PLAYERS];
new EntregaVeiculo[MAX_PLAYERS];
new EntregaEtapa[MAX_PLAYERS];
new SkinOriginal[MAX_PLAYERS];

new VeiculoConcessionaria[MAX_PLAYERS];

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

    // Logo da cidade
    ZikaLogo = TextDrawCreate(320.0, 12.0, "ZIKA RP");
    TextDrawAlignment(ZikaLogo, 2);
    TextDrawLetterSize(ZikaLogo, 0.50, 1.80);
    TextDrawColor(ZikaLogo, COR_CIANO);
    TextDrawSetOutline(ZikaLogo, 2);
    TextDrawSetShadow(ZikaLogo, 1);
    TextDrawFont(ZikaLogo, 2);
    TextDrawSetProportional(ZikaLogo, 1);
    TextDrawSetSelectable(ZikaLogo, 0);

    // NPC da agencia
    FuncionarioEmpregos = CreateActor(
        17, AGENCIA_X, AGENCIA_Y, AGENCIA_Z, 180.0
    );

    TextoAgencia = Create3DTextLabel(
        "AGENCIA DE EMPREGOS\nDigite /empregos",
        COR_CIANO,
        AGENCIA_X, AGENCIA_Y, AGENCIA_Z + 1.0,
        15.0, 0, 0
    );

    return 1;
}

public OnPlayerConnect(playerid)
{
    TrabalhandoEntrega[playerid] = false;
    EntregaVeiculo[playerid] = INVALID_VEHICLE_ID;
    EntregaEtapa[playerid] = 0;
    VeiculoConcessionaria[playerid] = INVALID_VEHICLE_ID;

    SendClientMessage(playerid, COR_CIANO,
        "Bem-vindo a ZIKA RP!");

    SendClientMessage(playerid, COR_BRANCO,
        "Use /ajuda para conhecer os comandos.");

    return 1;
}

public OnPlayerSpawn(playerid)
{
    TextDrawShowForPlayer(playerid, ZikaLogo);

    SendClientMessage(playerid, COR_CIANO,
        "Divirta-se na cidade ZIKA RP!");

    return 1;
}

// GPS das entregas
stock AtualizarRotaEntrega(playerid)
{
    if (EntregaEtapa[playerid] == 0)
    {
        SetPlayerRaceCheckpoint(playerid, 0,
            1833.0, -1842.0, 13.5,
            2495.0, -1687.0, 13.5,
            5.0
        );
    }
    else if (EntregaEtapa[playerid] == 1)
    {
        SetPlayerRaceCheckpoint(playerid, 0,
            2495.0, -1687.0, 13.5,
            1368.0, -1279.0, 13.5,
            5.0
        );
    }
    else
    {
        SetPlayerRaceCheckpoint(playerid, 0,
            1368.0, -1279.0, 13.5,
            1833.0, -1842.0, 13.5,
            5.0
        );
    }

    return 1;
}

// Iniciar emprego
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

    SkinOriginal[playerid] = GetPlayerSkin(playerid);

    // Uniforme de entregador
    SetPlayerSkin(playerid, 155);

    // Mochila removida nesta versao

    TrabalhandoEntrega[playerid] = true;
    EntregaEtapa[playerid] = 0;

    PutPlayerInVehicle(playerid, EntregaVeiculo[playerid], 0);

    AtualizarRotaEntrega(playerid);

    SendClientMessage(playerid, COR_VERDE,
        "Emprego iniciado! Voce recebeu uma moto.");

    SendClientMessage(playerid, COR_CIANO,
        "Uniforme de entregador equipado.");

    SendClientMessage(playerid, COR_BRANCO,
        "Siga o GPS. Cada entrega paga $250.");

    return 1;
}

// Encerrar emprego
stock PararEntrega(playerid)
{
    if (!TrabalhandoEntrega[playerid])
    {
        SendClientMessage(playerid, COR_VERMELHO,
            "Voce nao esta trabalhando.");
        return 1;
    }

    DisablePlayerRaceCheckpoint(playerid);

    if (GetPlayerVehicleID(playerid) == EntregaVeiculo[playerid])
    {
        RemovePlayerFromVehicle(playerid);
    }

    if (EntregaVeiculo[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(EntregaVeiculo[playerid]);
    }

    SetPlayerSkin(playerid, SkinOriginal[playerid]);

    EntregaVeiculo[playerid] = INVALID_VEHICLE_ID;
    TrabalhandoEntrega[playerid] = false;
    EntregaEtapa[playerid] = 0;

    SendClientMessage(playerid, COR_CIANO,
        "Expediente encerrado!");

    return 1;
}

// Conclusao de entrega
public OnPlayerEnterRaceCheckpoint(playerid)
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

    if (EntregaEtapa[playerid] >= 3)
    {
        EntregaEtapa[playerid] = 0;
    }

    AtualizarRotaEntrega(playerid);

    SendClientMessage(playerid, COR_CIANO,
        "GPS atualizado! Proxima entrega marcada.");

    return 1;
}

// Menus e compras
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (dialogid == DIALOG_EMPREGO)
    {
        if (!response)
            return 1;

        if (listitem == 0)
            IniciarEntrega(playerid);

        return 1;
    }

    // Loja de roupas
    if (dialogid == DIALOG_ROUPAS)
    {
        new skins[5] = {7, 14, 21, 23, 29};

        if (!response)
            return 1;

        if (GetPlayerMoney(playerid) < PRECO_ROUPA)
        {
            SendClientMessage(playerid, COR_VERMELHO,
                "Voce precisa de $500 para comprar essa roupa.");
            return 1;
        }

        GivePlayerMoney(playerid, -PRECO_ROUPA);
        SetPlayerSkin(playerid, skins[listitem]);

        SendClientMessage(playerid, COR_VERDE,
            "Roupa comprada por $500!");

        return 1;
    }

    // Concessionaria
    if (dialogid == DIALOG_CONCESSIONARIA)
    {
        new modelos[5] = {462, 468, 560, 541, 400};
        new precos[5] = {1500, 2500, 8000, 12000, 10000};

        new Float:cores[2] = {1.0, 1.0};
        new Float:x, Float:y, Float:z;

        if (!response)
            return 1;

        if (GetPlayerMoney(playerid) < precos[listitem])
        {
            SendClientMessage(playerid, COR_VERMELHO,
                "Dinheiro insuficiente para comprar esse veiculo.");
            return 1;
        }

        GivePlayerMoney(playerid, -precos[listitem]);

        if (VeiculoConcessionaria[playerid] != INVALID_VEHICLE_ID)
        {
            DestroyVehicle(VeiculoConcessionaria[playerid]);
            VeiculoConcessionaria[playerid] = INVALID_VEHICLE_ID;
        }

        // Ponto de entrega do veiculo
        x = CONCESSIONARIA_X + 5.0;
        y = CONCESSIONARIA_Y;
        z = CONCESSIONARIA_Z;

        VeiculoConcessionaria[playerid] = CreateVehicle(
            modelos[listitem],
            x, y, z,
            90.0,
            -1, -1, -1
        );

        if (VeiculoConcessionaria[playerid] == INVALID_VEHICLE_ID)
        {
            GivePlayerMoney(playerid, precos[listitem]);

            SendClientMessage(playerid, COR_VERMELHO,
                "Erro ao criar veiculo. Seu dinheiro foi devolvido.");
            return 1;
        }

        PutPlayerInVehicle(playerid,
            VeiculoConcessionaria[playerid], 0);

        SendClientMessage(playerid, COR_VERDE,
            "Parabens! Voce comprou seu veiculo.");

        return 1;
    }

    return 0;
}

// Comandos
public OnPlayerCommandText(playerid, cmdtext[])
{
    if (strcmp(cmdtext, "/pos", true) == 0)
    {
        new Float:x, Float:y, Float:z, Float:angulo;
        new mensagem[144];

        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, angulo);

        format(mensagem, sizeof(mensagem),
            "POSICAO: X: %.2f | Y: %.2f | Z: %.2f | ANG: %.2f",
            x, y, z, angulo);

        SendClientMessage(playerid, COR_CIANO, mensagem);
        return 1;
    }

    if (strcmp(cmdtext, "/ajuda", true) == 0)
    {
        SendClientMessage(playerid, COR_CIANO,
            "COMANDOS: /empregos /parar /roupas /concessionaria /pos /vida /colete /spawn");
        return 1;
    }

    if (strcmp(cmdtext, "/empregos", true) == 0)
    {
        if (!IsPlayerInRangeOfPoint(
            playerid, 4.0,
            AGENCIA_X, AGENCIA_Y, AGENCIA_Z))
        {
            SendClientMessage(playerid, COR_VERMELHO,
                "Va ate a agencia de empregos primeiro.");
            return 1;
        }

        ShowPlayerDialog(
            playerid,
            DIALOG_EMPREGO,
            DIALOG_STYLE_LIST,
            "AGENCIA DE EMPREGOS - ZIKA RP",
            "Entregador de delivery",
            "Trabalhar",
            "Fechar"
        );

        return 1;
    }

    if (strcmp(cmdtext, "/roupas", true) == 0)
    {
        if (!IsPlayerInRangeOfPoint(
            playerid, 8.0,
            ROUPAS_X, ROUPAS_Y, ROUPAS_Z))
        {
            SendClientMessage(playerid, COR_VERMELHO,
                "Va ate a loja de roupas em Los Santos.");
            return 1;
        }

        ShowPlayerDialog(
            playerid,
            DIALOG_ROUPAS,
            DIALOG_STYLE_LIST,
            "LOJA DE ROUPAS - ZIKA RP",
            "Roupa 1 - $500\nRoupa 2 - $500\nRoupa 3 - $500\nRoupa 4 - $500\nRoupa 5 - $500",
            "Comprar",
            "Fechar"
        );

        return 1;
    }

    if (strcmp(cmdtext, "/concessionaria", true) == 0)
    {
        if (!IsPlayerInRangeOfPoint(
            playerid, 12.0,
            CONCESSIONARIA_X,
            CONCESSIONARIA_Y,
            CONCESSIONARIA_Z))
        {
            SendClientMessage(playerid, COR_VERMELHO,
                "Va ate a concessionaria em Los Santos.");
            return 1;
        }

        ShowPlayerDialog(
            playerid,
            DIALOG_CONCESSIONARIA,
            DIALOG_STYLE_LIST,
            "CONCESSIONARIA - ZIKA RP",
            "Faggio - $1.500\nSanchez - $2.500\nSultan - $8.000\nBullet - $12.000\nLandstalker - $10.000",
            "Comprar",
            "Fechar"
        );

        return 1;
    }

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
    DisablePlayerRaceCheckpoint(playerid);

    if (EntregaVeiculo[playerid] != INVALID_VEHICLE_ID)
        DestroyVehicle(EntregaVeiculo[playerid]);

    if (VeiculoConcessionaria[playerid] != INVALID_VEHICLE_ID)
        DestroyVehicle(VeiculoConcessionaria[playerid]);

    TrabalhandoEntrega[playerid] = false;
    EntregaVeiculo[playerid] = INVALID_VEHICLE_ID;
    VeiculoConcessionaria[playerid] = INVALID_VEHICLE_ID;
    EntregaEtapa[playerid] = 0;

    return 1;
}
