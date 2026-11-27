
#include <a_samp>

#define COR_VERDE       0x00FF00FF
#define COR_CIANO       0x00E5FFFF
#define COR_VERMELHO    0xFF3333FF
#define COR_BRANCO      0xFFFFFFFF
#define COR_DOURADO     0xFFD700FF
#define COR_ROXO        0x9B5CFFFF

// COLOQUE UMA SENHA NOVA AQUI
#define SENHA_DONO "fhzk333@"

#define PAGAMENTO_ENTREGA 250
#define PRECO_ROUPA 500

#define DIALOG_EMPREGO 1000
#define DIALOG_ROUPAS 1001
#define DIALOG_CONCESSIONARIA 1002
#define DIALOG_DONO_LOGIN 1003
#define DIALOG_DONO_PAINEL 1004
#define DIALOG_DONO_VEICULOS 1005
#define DIALOG_DONO_TELEPORTES 1006
#define DIALOG_CASA 1007

#define MAX_CASAS 3
#define PRECO_CASA_1 15000
#define PRECO_CASA_2 25000
#define PRECO_CASA_3 40000

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

new Text:LogoZK;
new Text:LogoRP;
new Text:HUDNome;

new PlayerText:HUDDinheiro[MAX_PLAYERS];
new PlayerText:HUDVida[MAX_PLAYERS];

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

// SISTEMA DE CASAS

new Float:CasaX[MAX_CASAS] = {
    2495.0,
    2468.0,
    2447.0
};

new Float:CasaY[MAX_CASAS] = {
    -1691.2,
    -1698.0,
    -1702.0
};

new Float:CasaZ[MAX_CASAS] = {
    13.5,
    13.5,
    13.5
};

new PrecoCasa[MAX_CASAS] = {
    PRECO_CASA_1,
    PRECO_CASA_2,
    PRECO_CASA_3
};

new bool:CasaComprada[MAX_CASAS];
new bool:CasaTrancada[MAX_CASAS];
new CasaDono[MAX_CASAS][MAX_PLAYER_NAME];
new Text3D:TextoCasa[MAX_CASAS];

new CasaAtual[MAX_PLAYERS];
new bool:JogadorDentroCasa[MAX_PLAYERS];

forward AtualizarHUDGeral();

main()
{
    print("ZK RP - Servidor iniciado!");
}

// VERIFICAR PROPRIETARIO

stock bool:EhDono(playerid)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));

    return (strcmp(nome, "Fhzk", true) == 0);
}

stock bool:EhDonoDaCasa(playerid, casaid)
{
    new nome[MAX_PLAYER_NAME];
    GetPlayerName(playerid, nome, sizeof(nome));

    return (strcmp(nome, CasaDono[casaid], true) == 0);
}

// ATUALIZAR HUD INDIVIDUAL

stock AtualizarHUD(playerid)
{
    if (!IsPlayerConnected(playerid))
        return 1;

    new texto[64];
    new Float:vida;
    new Float:colete;

    format(
        texto,
        sizeof(texto),
        "DINHEIRO: $%d",
        GetPlayerMoney(playerid)
    );

    PlayerTextDrawSetString(
        playerid,
        HUDDinheiro[playerid],
        texto
    );

    GetPlayerHealth(playerid, vida);
    GetPlayerArmour(playerid, colete);

    format(
        texto,
        sizeof(texto),
        "VIDA: %.0f  COLETE: %.0f",
        vida,
        colete
    );

    PlayerTextDrawSetString(
        playerid,
        HUDVida[playerid],
        texto
    );

    return 1;
}

public AtualizarHUDGeral()
{
    for (new playerid = 0; playerid < MAX_PLAYERS; playerid++)
    {
        if (IsPlayerConnected(playerid))
        {
            AtualizarHUD(playerid);
        }
    }

    return 1;
}

// PAINEL DO PROPRIETARIO

stock MostrarPainelDono(playerid)
{
    ShowPlayerDialog(
        playerid,
        DIALOG_DONO_PAINEL,
        DIALOG_STYLE_LIST,
        "PAINEL DO PROPRIETARIO - ZK RP",
        "Equipar skin exclusiva\nPegar veiculo\nTeletransportar\nAtivar/desativar jetpack\nReceber $100.000\nRestaurar vida e colete\nReaparecer no spawn\nTeletransportar para marcacao do mapa",
        "Selecionar",
        "Fechar"
    );

    return 1;
}

// ATUALIZAR PLACA DA CASA

stock AtualizarTextoCasa(casaid)
{
    new texto[160];

    if (!CasaComprada[casaid])
    {
        format(
            texto,
            sizeof(texto),
            "{00E5FF}CASA A VENDA\n{FFFFFF}Preco: $%d\nDigite /casa",
            PrecoCasa[casaid]
        );
    }
    else if (CasaTrancada[casaid])
    {
        format(
            texto,
            sizeof(texto),
            "{FFD700}CASA PARTICULAR\n{FFFFFF}Dono: %s\n{FF3333}PORTA TRANCADA",
            CasaDono[casaid]
        );
    }
    else
    {
        format(
            texto,
            sizeof(texto),
            "{FFD700}CASA PARTICULAR\n{FFFFFF}Dono: %s\n{00FF00}PORTA DESTRANCADA",
            CasaDono[casaid]
        );
    }

    Update3DTextLabelText(
        TextoCasa[casaid],
        COR_CIANO,
        texto
    );

    return 1;
}

// ENCONTRAR CASA PROXIMA

stock EncontrarCasaProxima(playerid)
{
    for (new i = 0; i < MAX_CASAS; i++)
    {
        if (IsPlayerInRangeOfPoint(
            playerid,
            4.0,
            CasaX[i],
            CasaY[i],
            CasaZ[i]
        ))
        {
            return i;
        }
    }

    return -1;
}

// ENTRAR NA CASA

stock EntrarCasa(playerid, casaid)
{
    if (!CasaComprada[casaid])
        return 1;

    if (CasaTrancada[casaid] && !EhDonoDaCasa(playerid, casaid))
    {
        SendClientMessage(
            playerid,
            COR_VERMELHO,
            "Esta casa esta trancada!"
        );
        return 1;
    }

    if (IsPlayerInAnyVehicle(playerid))
        RemovePlayerFromVehicle(playerid);

    CasaAtual[playerid] = casaid;
    JogadorDentroCasa[playerid] = true;

    SetPlayerInterior(playerid, 1);
    SetPlayerVirtualWorld(playerid, casaid + 1);

    SetPlayerPos(playerid, 223.0, 1287.0, 1082.1);
    SetPlayerFacingAngle(playerid, 0.0);

    SendClientMessage(
        playerid,
        COR_VERDE,
        "Voce entrou na casa!"
    );

    SendClientMessage(
        playerid,
        COR_CIANO,
        "Digite /casa para sair."
    );

    return 1;
}

// SAIR DA CASA

stock SairCasa(playerid)
{
    if (!JogadorDentroCasa[playerid] || CasaAtual[playerid] == -1)
        return 1;

    new casaid = CasaAtual[playerid];

    SetPlayerInterior(playerid, 0);
    SetPlayerVirtualWorld(playerid, 0);

    SetPlayerPos(
        playerid,
        CasaX[casaid],
        CasaY[casaid],
        CasaZ[casaid]
    );

    CasaAtual[playerid] = -1;
    JogadorDentroCasa[playerid] = false;

    SendClientMessage(
        playerid,
        COR_CIANO,
        "Voce saiu da casa."
    );

    return 1;
}

// MENU DA CASA

stock MostrarMenuCasa(playerid, casaid)
{
    new titulo[80];
    new texto[180];

    format(
        titulo,
        sizeof(titulo),
        "CASA %d - ZK RP",
        casaid + 1
    );

    if (!CasaComprada[casaid])
    {
        format(
            texto,
            sizeof(texto),
            "Comprar casa por $%d",
            PrecoCasa[casaid]
        );
    }
    else if (EhDonoDaCasa(playerid, casaid))
    {
        if (CasaTrancada[casaid])
            format(texto, sizeof(texto), "Entrar na casa\nDestrancar porta");
        else
            format(texto, sizeof(texto), "Entrar na casa\nTrancar porta");
    }
    else
    {
        format(texto, sizeof(texto), "Entrar na casa");
    }

    ShowPlayerDialog(
        playerid,
        DIALOG_CASA,
        DIALOG_STYLE_LIST,
        titulo,
        texto,
        "Selecionar",
        "Fechar"
    );

    return 1;
}

// INICIALIZACAO DO SERVIDOR

public OnGameModeInit()
{
    SetGameModeText("ZK RP - Mobile");

    AddPlayerClass(
        0,
        1481.0, -1771.0, 18.8, 90.0,
        0, 0, 0, 0, 0, 0
    );

    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    ShowNameTags(true);
    SetWorldTime(12);
    SetWeather(1);

    // LOGO MINIMALISTA

    LogoZK = TextDrawCreate(304.0, 12.0, "ZK");
    TextDrawAlignment(LogoZK, 2);
    TextDrawLetterSize(LogoZK, 0.38, 1.45);
    TextDrawColor(LogoZK, COR_BRANCO);
    TextDrawSetOutline(LogoZK, 0);
    TextDrawSetShadow(LogoZK, 0);
    TextDrawFont(LogoZK, 2);
    TextDrawSetProportional(LogoZK, 1);
    TextDrawSetSelectable(LogoZK, 0);

    LogoRP = TextDrawCreate(336.0, 12.0, "RP");
    TextDrawAlignment(LogoRP, 2);
    TextDrawLetterSize(LogoRP, 0.38, 1.45);
    TextDrawColor(LogoRP, COR_ROXO);
    TextDrawSetOutline(LogoRP, 0);
    TextDrawSetShadow(LogoRP, 0);
    TextDrawFont(LogoRP, 2);
    TextDrawSetProportional(LogoRP, 1);
    TextDrawSetSelectable(LogoRP, 0);

    // NOME DO SERVIDOR NO HUD

    HUDNome = TextDrawCreate(320.0, 38.0, "ZK ROLEPLAY");
    TextDrawAlignment(HUDNome, 2);
    TextDrawLetterSize(HUDNome, 0.20, 0.85);
    TextDrawColor(HUDNome, COR_BRANCO);
    TextDrawSetOutline(HUDNome, 0);
    TextDrawSetShadow(HUDNome, 0);
    TextDrawFont(HUDNome, 2);
    TextDrawSetProportional(HUDNome, 1);

    // ATUALIZACAO AUTOMATICA DO HUD A CADA SEGUNDO

    SetTimer("AtualizarHUDGeral", 1000, true);

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

    // CRIAR AS TRES CASAS

    for (new i = 0; i < MAX_CASAS; i++)
    {
        CasaComprada[i] = false;
        CasaTrancada[i] = false;
        CasaDono[i][0] = '\0';

        TextoCasa[i] = Create3DTextLabel(
            "CASA A VENDA",
            COR_CIANO,
            CasaX[i],
            CasaY[i],
            CasaZ[i] + 1.0,
            15.0,
            0,
            0
        );

        AtualizarTextoCasa(i);
    }

    return 1;
}
