#include <a_samp>

#define COR_VERDE       0x00FF00FF
#define COR_CIANO       0x00E5FFFF
#define COR_VERMELHO    0xFF3333FF
#define COR_BRANCO      0xFFFFFFFF
#define COR_DOURADO     0xFFD700FF

#define SENHA_DONO "fabricio333@@"

#define PAGAMENTO_ENTREGA 250
#define PRECO_ROUPA 500

#define DIALOG_EMPREGO 1000
#define DIALOG_ROUPAS 1001
#define DIALOG_CONCESSIONARIA 1002
#define DIALOG_DONO_LOGIN 1003
#define DIALOG_DONO_PAINEL 1004
#define DIALOG_DONO_VEICULOS 1005
#define DIALOG_DONO_TELEPORTES 1006

#define AGENCIA_X 1477.5
#define AGENCIA_Y -1771.0
#define AGENCIA_Z 18.8

#define ROUPAS_X 2244.3
#define ROUPAS_Y -1665.5
#define ROUPAS_Z 15.5

#define CONCESSIONARIA_X 2131.5
#define CONCESSIONARIA_Y -1150.0
#define CONCESSIONARIA_Z 24.1

#define SKIN_DONO 217

new Text:ZikaLogo;
new Actor:FuncionarioEmpregos;
new Text3D:TextoAgencia;
new Text3D:TagDono[MAX_PLAYERS];

new bool:TrabalhandoEntrega[MAX_PLAYERS];
new bool:AdminAutenticado[MAX_PLAYERS];

new EntregaVeiculo[MAX_PLAYERS];
new EntregaEtapa[MAX_PLAYERS];
new SkinOriginal[MAX_PLAYERS];
new VeiculoConcessionaria[MAX_PLAYERS];
new VeiculoDono[MAX_PLAYERS];
new Float:MarcacaoX[MAX_PLAYERS];
new Float:MarcacaoY[MAX_PLAYERS];
new Float:MarcacaoZ[MAX_PLAYERS];
new bool:TemMarcacao[MAX_PLAYERS];

main()
{
    print("ZIKA RP - Servidor iniciado!");
}

stock bool:EhDono(playerid)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));

    return (strcmp(nome, "Fhzk", true) == 0);
}

stock MostrarPainelDono(playerid)
{
    ShowPlayerDialog(
        playerid,
        DIALOG_DONO_PAINEL,
        DIALOG_STYLE_LIST,
        "PAINEL DO PROPRIETARIO - ZIKA RP",
        "Equipar skin exclusiva\nPegar veiculo\nTeletransportar\nAtivar/desativar jetpack\nReceber $100.000\nRestaurar vida e colete\nReaparecer no spawn",
        "Selecionar",
        "Fechar"
    );
    return 1;
}

public OnGameModeInit()
{
    SetGameModeText("ZIKA RP - Mobile");

    AddPlayerClass(
        0,
        1481.0, -1771.0, 18.8, 90.0,
        0, 0, 0, 0, 0, 0
    );

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

    FuncionarioEmpregos = CreateActor(
        17,
        AGENCIA_X,
        AGENCIA_Y,
        AGENCIA_Z,
        180.0
    );

    TextoAgencia = Create3DTextLabel(
        "AGENCIA DE EMPREGOS\nDigite /empregos",
        COR_CIANO,
        AGENCIA_X,
        AGENCIA_Y,
        AGENCIA_Z + 1.0,
        15.0,
        0,
        0
    );

    return 1;
}

public OnPlayerConnect(playerid)
{
    TrabalhandoEntrega[playerid] = false;
    AdminAutenticado[playerid] = false;

    EntregaVeiculo[playerid] = INVALID_VEHICLE_ID;
    EntregaEtapa[playerid] = 0;
    VeiculoConcessionaria[playerid] = INVALID_VEHICLE_ID;
    VeiculoDono[playerid] = INVALID_VEHICLE_ID;

    TagDono[playerid] = Text3D:INVALID_3DTEXT_ID;

    SetPlayerMapIcon(
        playerid,
        10,
        ROUPAS_X,
        ROUPAS_Y,
        ROUPAS_Z,
        45,
        0,
        MAPICON_GLOBAL
    );

    SetPlayerMapIcon(
        playerid,
        11,
        CONCESSIONARIA_X,
        CONCESSIONARIA_Y,
        CONCESSIONARIA_Z,
        55,
        0,
        MAPICON_GLOBAL
    );

    if (EhDono(playerid))
    {
        TagDono[playerid] = Create3DTextLabel(
            "{FFD700}[DONO]\n{FFFFFF}Fhzk",
            COR_DOURADO,
            0.0,
            0.0,
            0.0,
            30.0,
            0,
            1
        );

        Attach3DTextLabelToPlayer(
            TagDono[playerid],
            playerid,
            0.0,
            0.0,
            0.45
        );

        SendClientMessage(
            playerid,
            COR_DOURADO,
            "Voce e o proprietario da ZIKA RP!"
        );

        SendClientMessage(
            playerid,
            COR_BRANCO,
            "Use /dono para acessar seu painel."
        );
    }

    SendClientMessage(
        playerid,
        COR_CIANO,
        "Bem-vindo a ZIKA RP!"
    );

    return 1;
}

public OnPlayerSpawn(playerid)
{
    TextDrawShowForPlayer(playerid, ZikaLogo);

    if (EhDono(playerid))
    {
        SetPlayerColor(playerid, COR_DOURADO);
    }
public OnPlayerClickMap(playerid, Float:fX, Float:fY, Float:fZ)
{
    if (!EhDono(playerid))
        return 1;

    MarcacaoX[playerid] = fX;
    MarcacaoY[playerid] = fY;
    MarcacaoZ[playerid] = fZ;

    TemMarcacao[playerid] = true;

    SendClientMessage(
        playerid,
        COR_DOURADO,
        "Marcacao salva! Use o painel do dono para teleportar."
    );

    return 1;
}

    SendClientMessage(
        playerid,
        COR_CIANO,
        "Divirta-se na cidade ZIKA RP!"
    );

    return 1;
}

// GPS DAS ENTREGAS
stock AtualizarRotaEntrega(playerid)
{
    if (EntregaEtapa[playerid] == 0)
    {
        SetPlayerRaceCheckpoint(
            playerid,
            0,
            1833.0, -1842.0, 13.5,
            2495.0, -1687.0, 13.5,
            5.0
        );
    }
    else if (EntregaEtapa[playerid] == 1)
    {
        SetPlayerRaceCheckpoint(
            playerid,
            0,
            2495.0, -1687.0, 13.5,
            1368.0, -1279.0, 13.5,
            5.0
        );
    }
    else
    {
        SetPlayerRaceCheckpoint(
            playerid,
            0,
            1368.0, -1279.0, 13.5,
            1833.0, -1842.0, 13.5,
            5.0
        );
    }

    return 1;
}

stock IniciarEntrega(playerid)
{
    new Float:x, Float:y, Float:z, Float:angulo;

    if (TrabalhandoEntrega[playerid])
    {
        SendClientMessage(
            playerid,
            COR_VERMELHO,
            "Voce ja esta trabalhando."
        );
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
        -1,
        -1,
        -1
    );

    if (EntregaVeiculo[playerid] == INVALID_VEHICLE_ID)
    {
        SendClientMessage(
            playerid,
            COR_VERMELHO,
            "Nao foi possivel criar a moto."
        );
        return 1;
    }

    SkinOriginal[playerid] = GetPlayerSkin(playerid);
    SetPlayerSkin(playerid, 155);

    TrabalhandoEntrega[playerid] = true;
    EntregaEtapa[playerid] = 0;

    PutPlayerInVehicle(
        playerid,
        EntregaVeiculo[playerid],
        0
    );

    AtualizarRotaEntrega(playerid);

    SendClientMessage(
        playerid,
        COR_VERDE,
        "Emprego iniciado! Cada entrega paga $250."
    );

    return 1;
}

stock PararEntrega(playerid)
{
    if (!TrabalhandoEntrega[playerid])
    {
        SendClientMessage(
            playerid,
            COR_VERMELHO,
            "Voce nao esta trabalhando."
        );
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

    SendClientMessage(
        playerid,
        COR_CIANO,
        "Expediente encerrado!"
    );

    return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
    if (!TrabalhandoEntrega[playerid])
        return 1;

    if (GetPlayerVehicleID(playerid) != EntregaVeiculo[playerid])
        return 1;

    GivePlayerMoney(playerid, PAGAMENTO_ENTREGA);

    SendClientMessage(
        playerid,
        COR_VERDE,
        "Entrega concluida! Voce recebeu $250."
    );

    EntregaEtapa[playerid]++;

    if (EntregaEtapa[playerid] >= 3)
    {
        EntregaEtapa[playerid] = 0;
    }

    AtualizarRotaEntrega(playerid);

    return 1;
}

// DIALOGOS
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (dialogid == DIALOG_EMPREGO)
    {
        if (response && listitem == 0)
        {
            IniciarEntrega(playerid);
        }

        return 1;
    }

    if (dialogid == DIALOG_ROUPAS)
    {
        new skins[5] = {7, 14, 21, 23, 29};

        if (!response)
            return 1;

        if (listitem < 0 || listitem > 4)
            return 1;

        if (GetPlayerMoney(playerid) < PRECO_ROUPA)
        {
            SendClientMessage(
                playerid,
                COR_VERMELHO,
                "Dinheiro insuficiente."
            );
            return 1;
        }

        GivePlayerMoney(playerid, -PRECO_ROUPA);
        SetPlayerSkin(playerid, skins[listitem]);

        SendClientMessage(
            playerid,
            COR_VERDE,
            "Roupa comprada por $500!"
        );

        return 1;
    }

    if (dialogid == DIALOG_CONCESSIONARIA)
    {
        new modelos[5] = {462, 468, 560, 541, 400};
        new precos[5] = {1500, 2500, 8000, 12000, 10000};

        if (!response)
            return 1;

        if (listitem < 0 || listitem > 4)
            return 1;

        if (GetPlayerMoney(playerid) < precos[listitem])
        {
            SendClientMessage(
                playerid,
                COR_VERMELHO,
                "Dinheiro insuficiente."
            );
            return 1;
        }

        GivePlayerMoney(playerid, -precos[listitem]);

        if (VeiculoConcessionaria[playerid] != INVALID_VEHICLE_ID)
        {
            DestroyVehicle(VeiculoConcessionaria[playerid]);
            VeiculoConcessionaria[playerid] = INVALID_VEHICLE_ID;
        }

        VeiculoConcessionaria[playerid] = CreateVehicle(
            modelos[listitem],
            CONCESSIONARIA_X + 5.0,
            CONCESSIONARIA_Y,
            CONCESSIONARIA_Z,
            90.0,
            -1,
            -1,
            -1
        );

        if (VeiculoConcessionaria[playerid] == INVALID_VEHICLE_ID)
        {
            GivePlayerMoney(playerid, precos[listitem]);

            SendClientMessage(
                playerid,
                COR_VERMELHO,
                "Erro ao criar veiculo. Dinheiro devolvido."
            );
            return 1;
        }

        PutPlayerInVehicle(
            playerid,
            VeiculoConcessionaria[playerid],
            0
        );

        SendClientMessage(
            playerid,
            COR_VERDE,
            "Veiculo comprado com sucesso!"
        );

        return 1;
    }

    // LOGIN DO PROPRIETARIO
    if (dialogid == DIALOG_DONO_LOGIN)
    {
        if (!response)
            return 1;

        if (!EhDono(playerid))
            return 1;

        if (strcmp(inputtext, SENHA_DONO, false) != 0)
        {
            SendClientMessage(
                playerid,
                COR_VERMELHO,
                "Senha incorreta!"
            );

            AdminAutenticado[playerid] = false;
            return 1;
        }

        AdminAutenticado[playerid] = true;

        SendClientMessage(
            playerid,
            COR_DOURADO,
            "Acesso de proprietario autorizado!"
        );

        MostrarPainelDono(playerid);

        return 1;
    }

    // PAINEL DO PROPRIETARIO
    if (dialogid == DIALOG_DONO_PAINEL)
    {
        if (!response)
            return 1;

        if (!EhDono(playerid) || !AdminAutenticado[playerid])
            return 1;

        if (listitem == 0)
        {
            SetPlayerSkin(playerid, SKIN_DONO);

            SendClientMessage(
                playerid,
                COR_DOURADO,
                "Skin do proprietario equipada."
            );
        }
        else if (listitem == 1)
        {
            ShowPlayerDialog(
                playerid,
                DIALOG_DONO_VEICULOS,
                DIALOG_STYLE_LIST,
                "VEICULOS DO DONO",
                "Infernus\nNRG-500\nSultan\nTurismo\nMaverick (helicoptero)",
                "Pegar",
                "Voltar"
            );
        }
        else if (listitem == 2)
        {
            ShowPlayerDialog(
                playerid,
                DIALOG_DONO_TELEPORTES,
                DIALOG_STYLE_LIST,
                "TELETRANSPORTE",
                "Centro de Los Santos\nAeroporto\nPraia de Santa Maria\nSan Fierro\nLas Venturas",
                "Ir",
                "Voltar"
            );
        }
        else if (listitem == 3)
        {
            if (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK)
            {
                SetPlayerSpecialAction(
                    playerid,
                    SPECIAL_ACTION_NONE
                );

                SendClientMessage(
                    playerid,
                    COR_CIANO,
                    "Jetpack desativado."
                );
            }
            else
            {
                SetPlayerSpecialAction(
                    playerid,
                    SPECIAL_ACTION_USEJETPACK
                );

                SendClientMessage(
                    playerid,
                    COR_DOURADO,
                    "Jetpack ativado."
                );
            }
        }
        else if (listitem == 4)
        {
            GivePlayerMoney(playerid, 100000);

            SendClientMessage(
                playerid,
                COR_VERDE,
                "Voce recebeu $100.000."
            );
        }
        else if (listitem == 5)
        {
            SetPlayerHealth(playerid, 100.0);
            SetPlayerArmour(playerid, 100.0);

            SendClientMessage(
                playerid,
                COR_VERDE,
                "Vida e colete restaurados."
            );
        }
        else if (listitem == 6)
        {
            SpawnPlayer(playerid);
        }

        return 1;
    }

    // VEICULOS DO PROPRIETARIO
    if (dialogid == DIALOG_DONO_VEICULOS)
    {
        if (!EhDono(playerid) || !AdminAutenticado[playerid])
            return 1;

        if (!response)
        {
            MostrarPainelDono(playerid);
            return 1;
        }

        new modelos[5] = {411, 522, 560, 451, 487};

        if (listitem < 0 || listitem > 4)
            return 1;

        new Float:x, Float:y, Float:z, Float:a;

        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);

        if (VeiculoDono[playerid] != INVALID_VEHICLE_ID)
        {
            DestroyVehicle(VeiculoDono[playerid]);
            VeiculoDono[playerid] = INVALID_VEHICLE_ID;
        }

        VeiculoDono[playerid] = CreateVehicle(
            modelos[listitem],
            x + 3.0,
            y,
            z,
            a,
            0,
            0,
            -1
        );

        if (VeiculoDono[playerid] != INVALID_VEHICLE_ID)
        {
            PutPlayerInVehicle(
                playerid,
                VeiculoDono[playerid],
                0
            );

            SendClientMessage(
                playerid,
                COR_DOURADO,
                "Veiculo do proprietario criado."
            );
        }
        else
        {
            SendClientMessage(
                playerid,
                COR_VERMELHO,
                "Nao foi possivel criar o veiculo."
            );
        }

        return 1;
    }

    // TELETRANSPORTE DO PROPRIETARIO
    if (dialogid == DIALOG_DONO_TELEPORTES)
    {
        if (!EhDono(playerid) || !AdminAutenticado[playerid])
            return 1;

        if (!response)
        {
            MostrarPainelDono(playerid);
            return 1;
        }

        if (listitem < 0 || listitem > 4)
            return 1;

        if (IsPlayerInAnyVehicle(playerid))
        {
            RemovePlayerFromVehicle(playerid);
        }

        SetPlayerInterior(playerid, 0);
        SetPlayerVirtualWorld(playerid, 0);

        switch (listitem)
        {
            case 0: SetPlayerPos(playerid, 1481.0, -1771.0, 18.8);
            case 1: SetPlayerPos(playerid, 1958.0, -2185.0, 13.5);
            case 2: SetPlayerPos(playerid, 342.0, -1808.0, 5.0);
            case 3: SetPlayerPos(playerid, -1985.0, 137.0, 27.7);
            case 4: SetPlayerPos(playerid, 1690.0, 1447.0, 10.7);
        }

        SendClientMessage(
            playerid,
            COR_DOURADO,
            "Teletransporte realizado."
        );

        return 1;
    }

    return 0;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (strcmp(cmdtext, "/dono", true) == 0)
    {
        if (!EhDono(playerid))
        {
            SendClientMessage(
                playerid,
                COR_VERMELHO,
                "Voce nao tem permissao."
            );
            return 1;
        }

        if (AdminAutenticado[playerid])
        {
            MostrarPainelDono(playerid);
            return 1;
        }

        ShowPlayerDialog(
            playerid,
            DIALOG_DONO_LOGIN,
            DIALOG_STYLE_PASSWORD,
            "ACESSO DO PROPRIETARIO",
            "Digite sua senha particular:",
            "Entrar",
            "Cancelar"
        );

        return 1;
    }

    if (strcmp(cmdtext, "/pos", true) == 0)
    {
        new Float:x, Float:y, Float:z, Float:angulo;
        new mensagem[144];

        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, angulo);

        format(
            mensagem,
            sizeof(mensagem),
            "POSICAO: X: %.2f | Y: %.2f | Z: %.2f | ANG: %.2f",
            x, y, z, angulo
        );

        SendClientMessage(playerid, COR_CIANO, mensagem);
        return 1;
    }

    if (strcmp(cmdtext, "/ajuda", true) == 0)
    {
        SendClientMessage(
            playerid,
            COR_CIANO,
            "COMANDOS: /empregos /parar /roupas /concessionaria /pos /dono /vida /colete /spawn"
        );
        return 1;
    }

    if (strcmp(cmdtext, "/empregos", true) == 0)
    {
        if (!IsPlayerInRangeOfPoint(
            playerid,
            4.0,
            AGENCIA_X,
            AGENCIA_Y,
            AGENCIA_Z
        ))
        {
            SendClientMessage(
                playerid,
                COR_VERMELHO,
                "Va ate a agencia de empregos."
            );
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
            playerid,
            8.0,
            ROUPAS_X,
            ROUPAS_Y,
            ROUPAS_Z
        ))
        {
            SendClientMessage(
                playerid,
                COR_VERMELHO,
                "Va ate a loja de roupas."
            );
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
            playerid,
            12.0,
            CONCESSIONARIA_X,
            CONCESSIONARIA_Y,
            CONCESSIONARIA_Z
        ))
        {
            SendClientMessage(
                playerid,
                COR_VERMELHO,
                "Va ate a concessionaria."
            );
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
    {
        return PararEntrega(playerid);
    }

    if (strcmp(cmdtext, "/vida", true) == 0)
    {
        SetPlayerHealth(playerid, 100.0);

        SendClientMessage(
            playerid,
            COR_VERDE,
            "Vida restaurada!"
        );

        return 1;
    }

    if (strcmp(cmdtext, "/colete", true) == 0)
    {
        SetPlayerArmour(playerid, 100.0);

        SendClientMessage(
            playerid,
            COR_VERDE,
            "Colete restaurado!"
        );

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
    {
        DestroyVehicle(EntregaVeiculo[playerid]);
    }

    if (VeiculoConcessionaria[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(VeiculoConcessionaria[playerid]);
    }

    if (VeiculoDono[playerid] != INVALID_VEHICLE_ID)
    {
        DestroyVehicle(VeiculoDono[playerid]);
    }

    if (TagDono[playerid] != Text3D:INVALID_3DTEXT_ID)
    {
        Delete3DTextLabel(TagDono[playerid]);
    }

    TrabalhandoEntrega[playerid] = false;
    AdminAutenticado[playerid] = false;

    EntregaVeiculo[playerid] = INVALID_VEHICLE_ID;
    VeiculoConcessionaria[playerid] = INVALID_VEHICLE_ID;
    VeiculoDono[playerid] = INVALID_VEHICLE_ID;
    EntregaEtapa[playerid] = 0;

    return 1;
}