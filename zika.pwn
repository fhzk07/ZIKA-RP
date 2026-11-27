#include <a_samp>

// ============================================================================
// ZK RP v4.0 - MOBILE ROLEPLAY | BASE NATIVA SA-MP / open.mp
// Dependencias: apenas a_samp.inc. Criar scriptfiles/Contas e scriptfiles/Dados.
// ============================================================================

#define SERVER_NAME "ZK RP"
#define DONO_NICK "Fhzk"
// Troque esta senha antes de publicar o servidor.
#define DONO_SENHA "fhzk333@"
#define COR_BRANCO 0xFFFFFFFF
#define COR_PRETO 0x101018FF
#define COR_ROXO 0x9B59B6FF
#define COR_VERDE 0x2ECC71FF
#define COR_VERMELHO 0xE74C3CFF
#define COR_CINZA 0xBDC3C7FF
#define COR_DOURADO 0xF1C40FFF
#define COR_AZUL 0x3498DBFF
#define COR_LARANJA 0xE67E22FF
#define COR_CIANO 0x1ABC9CFF
#define MAX_CASAS 6
#define MAX_VEH_SERVER 2000
#define PRECO_CNH 1200
#define PAYDAY_MS 1200000
#define FOME_MS 150000
#define INVALID_HOUSE (-1)

#define D_LOGIN 1000
#define D_REGISTRO 1001
#define D_MENU 1002
#define D_RG 1003
#define D_INVENTARIO 1004
#define D_GPS 1005
#define D_EMPREGOS 1006
#define D_BANCO 1007
#define D_BANCO_VALOR 1008
#define D_PREFEITURA 1009
#define D_CONCE 1010
#define D_ROUPAS 1011
#define D_LOJA 1012
#define D_POSTO 1013
#define D_CASA 1014
#define D_CELULAR 1015
#define D_SMS_ID 1016
#define D_SMS_TEXTO 1017
#define D_ANUNCIO 1018
#define D_DONO_LOGIN 1019
#define D_DONO 1020
#define D_DONO_TP 1021
#define D_DONO_VEH 1022
#define D_FACCAO 1023
#define D_POLICIA 1024
#define D_VEICULO 1025
#define D_TRANSFER_ID 1026
#define D_TRANSFER_VALOR 1027
#define D_ADMIN_ID 1028
#define D_ADMIN_VALOR 1029
#define D_ADMIN_ANUNCIO 1030

#define SPAWN_X 1481.0
#define SPAWN_Y -1771.0
#define SPAWN_Z 18.8
#define BANCO_X 1462.3
#define BANCO_Y -1012.5
#define BANCO_Z 26.8
#define CONCE_X 2131.5
#define CONCE_Y -1150.0
#define CONCE_Z 24.1
#define ROUPA_X 2244.3
#define ROUPA_Y -1665.5
#define ROUPA_Z 15.5
#define LOJA_X 1315.4
#define LOJA_Y -898.8
#define LOJA_Z 39.5
#define POSTO_X 1944.0
#define POSTO_Y -1772.5
#define POSTO_Z 13.4
#define DROGA_X 2166.0
#define DROGA_Y -1675.0
#define DROGA_Z 15.0

new Text:gLogo, Text:gMenu, Text:gAcao, Text:gGPS, Text:gFone, Text:gCarro;
new PlayerText:gHUD[MAX_PLAYERS], PlayerText:gStatus[MAX_PLAYERS], PlayerText:gVel[MAX_PLAYERS];
new bool:gHudCriado[MAX_PLAYERS], bool:gVelVisivel[MAX_PLAYERS];
new gDialogAtual[MAX_PLAYERS], gBankMode[MAX_PLAYERS], gTransferTarget[MAX_PLAYERS], gAdminMode[MAX_PLAYERS], gAdminTarget[MAX_PLAYERS];
new gSmsAlvo[MAX_PLAYERS];
new gAnuncioCooldown[MAX_PLAYERS];
new gVeiculo[MAX_PLAYERS], gVeiculoModelo[MAX_PLAYERS], gVeiculoCombustivel[MAX_PLAYERS];
new bool:gMotor[MAX_PLAYERS], bool:gTrancado[MAX_PLAYERS];
new gTrabalho[MAX_PLAYERS], gRota[MAX_PLAYERS], gVeiculoTrabalho[MAX_PLAYERS];
new bool:gTrabalhando[MAX_PLAYERS];
new gFome[MAX_PLAYERS], gSede[MAX_PLAYERS], gDinheiroBanco[MAX_PLAYERS], gNivel[MAX_PLAYERS], gXP[MAX_PLAYERS];
new gCNH[MAX_PLAYERS], gEmprego[MAX_PLAYERS], gFaccao[MAX_PLAYERS], gDrogas[MAX_PLAYERS], gComida[MAX_PLAYERS], gAgua[MAX_PLAYERS], gKit[MAX_PLAYERS], gProcurado[MAX_PLAYERS];
new bool:gLogado[MAX_PLAYERS], bool:gDono[MAX_PLAYERS], bool:gDonoAut[MAX_PLAYERS], bool:gDentroCasa[MAX_PLAYERS];
new gCasaAtual[MAX_PLAYERS], gDinheiroSalvo[MAX_PLAYERS], gSkin[MAX_PLAYERS], gSenha[MAX_PLAYERS][32];
new gNome[MAX_PLAYERS][MAX_PLAYER_NAME];
new gCombustivel[MAX_VEH_SERVER];

new const gNomeEmprego[5][28] = {
    "Desempregado",
    "Entregador iFood",
    "Motorista de Onibus",
    "Policial Militar",
    "Mecanico"
};

new const gNomeVeiculo[6][24] = {
    "Faggio", "Sanchez", "Elegy", "Bullet", "Landstalker", "Infernus"
};

new const gModeloVeiculo[6] = {462, 468, 560, 541, 400, 411};
new const gPrecoVeiculo[6] = {1500, 3000, 12000, 25000, 15000, 45000};
new const gSkinLoja[6] = {7, 14, 21, 23, 29, 240};
new const gModeloDono[5] = {411, 522, 560, 451, 487};

// Casas sem interior forcado: cada casa usa um mundo virtual proprio.
enum E_HOUSE {
    hOwner[MAX_PLAYER_NAME],
    bool:hBought,
    bool:hLocked,
    hPrice,
    Float:hX,
    Float:hY,
    Float:hZ
};

new gHouse[MAX_CASAS][E_HOUSE] = {
    {"Ninguem", false, false, 15000, 2495.0, -1691.2, 13.5},
    {"Ninguem", false, false, 25000, 2468.0, -1698.0, 13.5},
    {"Ninguem", false, false, 40000, 2447.0, -1702.0, 13.5},
    {"Ninguem", false, false, 60000, 2523.0, -1679.0, 15.4},
    {"Ninguem", false, false, 85000, 2486.4, -1645.1, 14.0},
    {"Ninguem", false, false, 120000, 2352.0, -1655.0, 13.4}
};

forward TimerPayday();
forward TimerNeeds();
forward TimerHUD();

stock Msg(playerid, color, const text[]) {
    return SendClientMessage(playerid, color, text);
}

stock bool:IsValidLogged(playerid) {
    return IsPlayerConnected(playerid) && gLogado[playerid];
}

stock bool:IsOwnerName(playerid) {
    return !strcmp(gNome[playerid], DONO_NICK, true);
}

stock SetCash(playerid, amount) {
    if (amount < 0) amount = 0;
    ResetPlayerMoney(playerid);
    GivePlayerMoney(playerid, amount);
    gDinheiroSalvo[playerid] = amount;
    return 1;
}

stock AddCash(playerid, amount) {
    new value = GetPlayerMoney(playerid) + amount;
    if (value < 0) value = 0;
    SetCash(playerid, value);
    return 1;
}

stock SaveAccount(playerid)
{
    if (!gLogado[playerid]) return 0;

    new path[64], line[128];
    format(path, sizeof path, "Contas/%s.ini", gNome[playerid]);

    new File:f = fopen(path, io_write);
    if (!f) return 0;

    #define WRITE_FIELD(%0,%1) format(line,sizeof line,%0,%1); fwrite(f,line)

    format(line, sizeof line, "Senha=%s\r\n", gSenha[playerid]);
    fwrite(f, line);

    WRITE_FIELD("Dinheiro=%d\r\n", GetPlayerMoney(playerid));
    WRITE_FIELD("Banco=%d\r\n", gDinheiroBanco[playerid]);
    WRITE_FIELD("Nivel=%d\r\n", gNivel[playerid]);
    WRITE_FIELD("XP=%d\r\n", gXP[playerid]);
    WRITE_FIELD("Skin=%d\r\n", gSkin[playerid]);
    WRITE_FIELD("Fome=%d\r\n", gFome[playerid]);
    WRITE_FIELD("Sede=%d\r\n", gSede[playerid]);
    WRITE_FIELD("CNH=%d\r\n", gCNH[playerid]);
    WRITE_FIELD("Emprego=%d\r\n", gEmprego[playerid]);
    WRITE_FIELD("Faccao=%d\r\n", gFaccao[playerid]);
    WRITE_FIELD("Drogas=%d\r\n", gDrogas[playerid]);
    WRITE_FIELD("Comida=%d\r\n", gComida[playerid]);
    WRITE_FIELD("Agua=%d\r\n", gAgua[playerid]);
    WRITE_FIELD("Kit=%d\r\n", gKit[playerid]);
    WRITE_FIELD("Procurado=%d\r\n", gProcurado[playerid]);
    WRITE_FIELD("VehModelo=%d\r\n", gVeiculoModelo[playerid]);

    #undef WRITE_FIELD

    fclose(f);
    return 1;
}

stock LoadAccount(playerid)
{
    new path[64], line[128];
    format(path, sizeof path, "Contas/%s.ini", gNome[playerid]);

    new File:f = fopen(path, io_read);
    if (!f) return 0;

    while (fread(f, line))
    {
        for (new i = 0; line[i]; i++) {
            if (line[i] == '\r' || line[i] == '\n') line[i] = 0;
        }

        new p = strfind(line, "=");
        if (p < 1) continue;

        new key[32], val[80];
        strmid(key, line, 0, p, sizeof key);
        strmid(val, line, p + 1, strlen(line), sizeof val);

        if (!strcmp(key, "Senha")) format(gSenha[playerid], 32, "%s", val);
        else if (!strcmp(key, "Dinheiro")) gDinheiroSalvo[playerid] = strval(val);
        else if (!strcmp(key, "Banco")) gDinheiroBanco[playerid] = strval(val);
        else if (!strcmp(key, "Nivel")) gNivel[playerid] = strval(val);
        else if (!strcmp(key, "XP")) gXP[playerid] = strval(val);
        else if (!strcmp(key, "Skin")) gSkin[playerid] = strval(val);
        else if (!strcmp(key, "Fome")) gFome[playerid] = strval(val);
        else if (!strcmp(key, "Sede")) gSede[playerid] = strval(val);
        else if (!strcmp(key, "CNH")) gCNH[playerid] = strval(val);
        else if (!strcmp(key, "Emprego")) gEmprego[playerid] = strval(val);
        else if (!strcmp(key, "Faccao")) gFaccao[playerid] = strval(val);
        else if (!strcmp(key, "Drogas")) gDrogas[playerid] = strval(val);
        else if (!strcmp(key, "Comida")) gComida[playerid] = strval(val);
        else if (!strcmp(key, "Agua")) gAgua[playerid] = strval(val);
        else if (!strcmp(key, "Kit")) gKit[playerid] = strval(val);
        else if (!strcmp(key, "Procurado")) gProcurado[playerid] = strval(val);
        else if (!strcmp(key, "VehModelo")) gVeiculoModelo[playerid] = strval(val);
    }

    fclose(f);
    return 1;
}

stock SaveHouses()
{
    new File:f = fopen("Dados/Casas.ini", io_write);
    if (!f) return 0;

    new line[128];

    for (new i = 0; i < MAX_CASAS; i++)
    {
        format(line, sizeof line, "%d|%s|%d|%d\r\n",
            i,
            gHouse[i][hOwner],
            gHouse[i][hBought],
            gHouse[i][hLocked]
        );
        fwrite(f, line);
    }

    fclose(f);
    return 1;
}

stock LoadHouses()
{
    new File:f = fopen("Dados/Casas.ini", io_read);
    if (!f) return 0;

    new line[128];

    while (fread(f, line))
    {
        for (new q = 0; line[q]; q++) {
            if (line[q] == '\r' || line[q] == '\n') line[q] = 0;
        }

        new p1 = strfind(line, "|"), p2, p3;
        new tmp[16], owner[MAX_PLAYER_NAME], idx, b, l;

        if (p1 < 0) continue;
        p2 = strfind(line, "|", false, p1 + 1);
        if (p2 < 0) continue;
        p3 = strfind(line, "|", false, p2 + 1);
        if (p3 < 0) continue;

        strmid(tmp, line, 0, p1);
        idx = strval(tmp);

        if (idx < 0 || idx >= MAX_CASAS) continue;

        strmid(owner, line, p1 + 1, p2, sizeof owner);
        strmid(tmp, line, p2 + 1, p3);
        b = strval(tmp);
        strmid(tmp, line, p3 + 1, strlen(line));
        l = strval(tmp);

        format(gHouse[idx][hOwner], MAX_PLAYER_NAME, "%s", owner);
        gHouse[idx][hBought] = (b != 0);
        gHouse[idx][hLocked] = (l != 0);
    }

    fclose(f);
    return 1;
}
// ============================================================================
// HUD E BOTOES MOBILE
// ============================================================================

stock Text:CreateMobileButton(Float:x, Float:y, const text[], color)
{
    new Text:t = TextDrawCreate(x, y, _:text);
    TextDrawLetterSize(t, 0.20, 1.0);
    TextDrawTextSize(t, x + 48.0, 18.0);
    TextDrawAlignment(t, 1);
    TextDrawColor(t, COR_BRANCO);
    TextDrawUseBox(t, 1);
    TextDrawBoxColor(t, color);
    TextDrawSetOutline(t, 1);
    TextDrawSetSelectable(t, 1);
    TextDrawFont(t, 1);
    return t;
}

stock ShowButtons(playerid)
{
    TextDrawShowForPlayer(playerid, gLogo);
    TextDrawShowForPlayer(playerid, gMenu);
    TextDrawShowForPlayer(playerid, gAcao);
    TextDrawShowForPlayer(playerid, gGPS);
    TextDrawShowForPlayer(playerid, gFone);
    TextDrawShowForPlayer(playerid, gCarro);
    SelectTextDraw(playerid, COR_ROXO);
    return 1;
}

stock CreateHUD(playerid)
{
    if (gHudCriado[playerid]) return 1;

    gHUD[playerid] = CreatePlayerTextDraw(playerid, 12.0, 382.0, "ZK RP");
    PlayerTextDrawLetterSize(playerid, gHUD[playerid], 0.20, 1.0);
    PlayerTextDrawColor(playerid, gHUD[playerid], COR_BRANCO);
    PlayerTextDrawSetOutline(playerid, gHUD[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, gHUD[playerid], COR_PRETO);
    PlayerTextDrawFont(playerid, gHUD[playerid], 1);
    PlayerTextDrawShow(playerid, gHUD[playerid]);

    gStatus[playerid] = CreatePlayerTextDraw(playerid, 500.0, 105.0, "FOME 100 | SEDE 100");
    PlayerTextDrawLetterSize(playerid, gStatus[playerid], 0.19, 0.9);
    PlayerTextDrawColor(playerid, gStatus[playerid], COR_BRANCO);
    PlayerTextDrawSetOutline(playerid, gStatus[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, gStatus[playerid], COR_PRETO);
    PlayerTextDrawFont(playerid, gStatus[playerid], 1);
    PlayerTextDrawShow(playerid, gStatus[playerid]);

    gVel[playerid] = CreatePlayerTextDraw(playerid, 500.0, 370.0, "0 KM/H");
    PlayerTextDrawLetterSize(playerid, gVel[playerid], 0.22, 1.0);
    PlayerTextDrawColor(playerid, gVel[playerid], COR_BRANCO);
    PlayerTextDrawSetOutline(playerid, gVel[playerid], 1);
    PlayerTextDrawFont(playerid, gVel[playerid], 2);

    gHudCriado[playerid] = true;
    UpdateHUD(playerid);
    return 1;
}

stock UpdateHUD(playerid)
{
    if (!IsValidLogged(playerid) || !gHudCriado[playerid]) return 1;

    new a[160], b[120];

    format(a, sizeof a,
        "~p~ZK RP~w~ | %s%s ~y~Nv.%d~n~~g~$%d ~w~| Banco: $%d",
        gDono[playerid] ? "[DONO] " : "",
        gNome[playerid],
        gNivel[playerid],
        GetPlayerMoney(playerid),
        gDinheiroBanco[playerid]
    );
    PlayerTextDrawSetString(playerid, gHUD[playerid], a);

    format(b, sizeof b,
        "~y~FOME:~w~ %d%%~n~~b~SEDE:~w~ %d%%~n~~p~EMPREGO:~w~ %s",
        gFome[playerid],
        gSede[playerid],
        gNomeEmprego[gEmprego[playerid]]
    );
    PlayerTextDrawSetString(playerid, gStatus[playerid], b);

    if (IsPlayerInAnyVehicle(playerid))
    {
        new vid = GetPlayerVehicleID(playerid);
        new Float:x, Float:y, Float:z;
        GetVehicleVelocity(vid, x, y, z);

        new speed = floatround(floatsqroot(x*x + y*y + z*z) * 180.0);

        format(b, sizeof b, "~w~%d KM/H ~y~| GAS: %d%%",
            speed, gCombustivel[vid]);

        PlayerTextDrawSetString(playerid, gVel[playerid], b);

        if (!gVelVisivel[playerid])
        {
            PlayerTextDrawShow(playerid, gVel[playerid]);
            gVelVisivel[playerid] = true;
        }
    }
    else if (gVelVisivel[playerid])
    {
        PlayerTextDrawHide(playerid, gVel[playerid]);
        gVelVisivel[playerid] = false;
    }

    return 1;
}

// ============================================================================
// MENUS E SISTEMAS
// ============================================================================

stock ShowMain(playerid)
{
    ShowPlayerDialog(playerid, D_MENU, DIALOG_STYLE_LIST,
        "{9B59B6}ZK RP | Central",
        "Meu RG / Status\nInventario\nGPS\nEmpregos\nBanco\nMeu Veiculo\nPolicia\nSalvar conta",
        "Abrir", "Fechar"
    );
    return 1;
}

stock ShowHouse(playerid, id)
{
    gCasaAtual[playerid] = id;
    new text[160];

    if (!gHouse[id][hBought])
        format(text, sizeof text, "Comprar casa - $%d", gHouse[id][hPrice]);
    else if (!strcmp(gHouse[id][hOwner], gNome[playerid], true))
        format(text, sizeof text, "Entrar\n%s\nVender por $%d",
            gHouse[id][hLocked] ? "Destrancar" : "Trancar",
            gHouse[id][hPrice] / 2);
    else
        format(text, sizeof text, "Proprietario: %s\nTentar entrar",
            gHouse[id][hOwner]);

    ShowPlayerDialog(playerid, D_CASA, DIALOG_STYLE_LIST,
        "{9B59B6}Imovel", text, "Selecionar", "Fechar");
    return 1;
}

stock StopJob(playerid)
{
    if (!gTrabalhando[playerid]) return 0;

    if (gVeiculoTrabalho[playerid])
        DestroyVehicle(gVeiculoTrabalho[playerid]);

    gVeiculoTrabalho[playerid] = 0;
    gTrabalhando[playerid] = false;
    DisablePlayerCheckpoint(playerid);
    Msg(playerid, COR_LARANJA, "[EMPREGO] Expediente encerrado.");
    return 1;
}

stock StartJob(playerid)
{
    if (gEmprego[playerid] == 0)
        return Msg(playerid, COR_VERMELHO,
            "Voce precisa escolher um emprego primeiro.");

    if (gTrabalhando[playerid])
        return Msg(playerid, COR_VERMELHO,
            "Voce ja esta trabalhando.");

    gTrabalhando[playerid] = true;
    gRota[playerid] = 0;

    if (gEmprego[playerid] == 1)
    {
        gVeiculoTrabalho[playerid] =
            CreateVehicle(462, 1480.0, -1760.0, 13.5, 90.0, 1, 1, -1);

        SetPlayerCheckpoint(playerid, 1510.0, -1750.0, 13.5, 4.0);
    }
    else if (gEmprego[playerid] == 2)
    {
        gVeiculoTrabalho[playerid] =
            CreateVehicle(431, 1480.0, -1760.0, 13.5, 90.0, 1, 1, -1);

        SetPlayerCheckpoint(playerid, 1425.0, -1730.0, 13.5, 5.0);
    }
    else
    {
        gTrabalhando[playerid] = false;
        return Msg(playerid, COR_AZUL,
            "Policial e mecanico sao cargos de servico.");
    }

    PutPlayerInVehicle(playerid, gVeiculoTrabalho[playerid], 0);
    Msg(playerid, COR_VERDE,
        "[EMPREGO] Trabalho iniciado! Siga o checkpoint amarelo.");
    return 1;
}

stock ShowGPS(playerid)
{
    ShowPlayerDialog(playerid, D_GPS, DIALOG_STYLE_LIST,
        "{E67E22}GPS Mobile",
        "Prefeitura\nBanco\nConcessionaria\nLoja de roupas\nMercado 24/7\nPosto / Oficina\nTropa ZK\nCancelar GPS",
        "Marcar", "Fechar");
    return 1;
}

stock LocalMessage(playerid, Float:radius, color, const msg[])
{
    new Float:x, Float:y, Float:z;
    GetPlayerPos(playerid, x, y, z);

    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && gLogado[i] &&
            GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid) &&
            IsPlayerInRangeOfPoint(i, radius, x, y, z))
        {
            SendClientMessage(i, color, msg);
        }
    }
    return 1;
}

stock GoTo(playerid, Float:x, Float:y, Float:z, const label[])
{
    SetPlayerCheckpoint(playerid, x, y, z, 4.0);

    new m[96];
    format(m, sizeof m, "GPS marcado: %s. Siga o checkpoint.", label);
    return Msg(playerid, COR_LARANJA, m);
}
// ============================================================================
// INICIALIZACAO DO SERVIDOR
// ============================================================================

public OnGameModeInit()
{
    SetGameModeText("ZK RP v4.0 | Mobile Roleplay");
    ShowNameTags(1);
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    UsePlayerPedAnims();
    EnableStuntBonusForAll(0);
    SetWorldTime(12);
    SetWeather(2);

    AddPlayerClass(7, SPAWN_X, SPAWN_Y, SPAWN_Z, 90.0,
        0, 0, 0, 0, 0, 0);

    gLogo = CreateMobileButton(500.0, 15.0, "ZK RP", COR_ROXO);
    gMenu = CreateMobileButton(550.0, 120.0, "MENU", COR_ROXO);
    gAcao = CreateMobileButton(550.0, 155.0, "ACAO", COR_VERDE);
    gGPS = CreateMobileButton(550.0, 190.0, "GPS", COR_AZUL);
    gFone = CreateMobileButton(550.0, 225.0, "FONE", COR_CIANO);
    gCarro = CreateMobileButton(550.0, 260.0, "CARRO", COR_LARANJA);

    LoadHouses();

    SetTimer("TimerPayday", PAYDAY_MS, true);
    SetTimer("TimerNeeds", FOME_MS, true);
    SetTimer("TimerHUD", 1000, true);

    print("======================================");
    print(" ZK RP v4.0 iniciado!");
    print(" Sistemas mobile carregados.");
    print("======================================");

    return 1;
}

public OnGameModeExit()
{
    SaveHouses();

    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsPlayerConnected(i) && gLogado[i])
            SaveAccount(i);
    }

    return 1;
}

// ============================================================================
// CONEXAO E DESCONEXAO
// ============================================================================

public OnPlayerConnect(playerid)
{
    GetPlayerName(playerid, gNome[playerid], MAX_PLAYER_NAME);

    gLogado[playerid] = false;
    gDono[playerid] = false;
    gDonoAut[playerid] = false;
    gHudCriado[playerid] = false;
    gVelVisivel[playerid] = false;
    gDentroCasa[playerid] = false;

    gCasaAtual[playerid] = INVALID_HOUSE;
    gDinheiroBanco[playerid] = 0;
    gNivel[playerid] = 1;
    gXP[playerid] = 0;
    gFome[playerid] = 100;
    gSede[playerid] = 100;
    gCNH[playerid] = 0;
    gEmprego[playerid] = 0;
    gFaccao[playerid] = 0;
    gDrogas[playerid] = 0;
    gComida[playerid] = 0;
    gAgua[playerid] = 0;
    gKit[playerid] = 0;
    gProcurado[playerid] = 0;
    gVeiculoModelo[playerid] = 0;
    gTrabalhando[playerid] = false;
    gVeiculoTrabalho[playerid] = 0;
    gMotor[playerid] = false;
    gTrancado[playerid] = false;
    gAnuncioCooldown[playerid] = 0;

    ResetPlayerMoney(playerid);
    SetPlayerColor(playerid, COR_BRANCO);
    TogglePlayerSpectating(playerid, true);

    new path[64];
    format(path, sizeof path, "Contas/%s.ini", gNome[playerid]);

    if (fexist(path))
    {
        LoadAccount(playerid);

        ShowPlayerDialog(playerid, D_LOGIN,
            DIALOG_STYLE_PASSWORD,
            "{9B59B6}ZK RP | Login",
            "Digite sua senha para entrar no servidor:",
            "Entrar", "Sair");
    }
    else
    {
        ShowPlayerDialog(playerid, D_REGISTRO,
            DIALOG_STYLE_PASSWORD,
            "{9B59B6}ZK RP | Registro",
            "Bem-vindo ao ZK RP!\nCrie uma senha para sua conta:",
            "Registrar", "Sair");
    }

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    if (gLogado[playerid])
        SaveAccount(playerid);

    if (gTrabalhando[playerid])
        StopJob(playerid);

    if (gHudCriado[playerid])
    {
        PlayerTextDrawDestroy(playerid, gHUD[playerid]);
        PlayerTextDrawDestroy(playerid, gStatus[playerid]);
        PlayerTextDrawDestroy(playerid, gVel[playerid]);
    }

    gLogado[playerid] = false;
    gHudCriado[playerid] = false;

    return 1;
}

// ============================================================================
// SPAWN
// ============================================================================

public OnPlayerRequestClass(playerid, classid)
{
    TogglePlayerSpectating(playerid, true);
    return 1;
}

public OnPlayerSpawn(playerid)
{
    if (!gLogado[playerid])
    {
        TogglePlayerSpectating(playerid, true);
        return 1;
    }

    SetPlayerVirtualWorld(playerid, 0);
    SetPlayerInterior(playerid, 0);
    SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
    SetPlayerFacingAngle(playerid, 90.0);

    SetPlayerSkin(playerid, gSkin[playerid] > 0 ?
        gSkin[playerid] : 7);

    SetCash(playerid, gDinheiroSalvo[playerid]);

    SetPlayerHealth(playerid, 100.0);
    SetPlayerArmour(playerid, 0.0);

    CreateHUD(playerid);
    ShowButtons(playerid);

    Msg(playerid, COR_ROXO,
        "Bem-vindo ao ZK RP! Use o botao MENU para acessar os sistemas.");

    return 1;
}

// ============================================================================
// TEXTDRAWS E INTERACOES MOBILE
// ============================================================================

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if (clickedid == INVALID_TEXT_DRAW)
        return 1;

    if (!IsValidLogged(playerid))
        return 1;

    if (clickedid == gMenu)
    {
        ShowMain(playerid);
    }
    else if (clickedid == gGPS)
    {
        ShowGPS(playerid);
    }
    else if (clickedid == gAcao)
    {
        Interact(playerid);
    }
    else if (clickedid == gFone)
    {
        ShowPlayerDialog(playerid, D_CELULAR,
            DIALOG_STYLE_LIST,
            "{1ABC9C}Celular",
            "Enviar SMS\nAnunciar",
            "Selecionar", "Fechar");
    }
    else if (clickedid == gCarro)
    {
        ShowPlayerDialog(playerid, D_VEICULO,
            DIALOG_STYLE_LIST,
            "{E67E22}Veiculo",
            "Ligar / Desligar motor\nTrancar / Destrancar\nGuardar veiculo",
            "Selecionar", "Fechar");
    }

    return 1;
}

stock Interact(playerid)
{
    if (!IsValidLogged(playerid))
        return 0;

    if (IsPlayerInAnyVehicle(playerid))
    {
        Msg(playerid, COR_LARANJA,
            "Use o botao CARRO para controlar seu veiculo.");
        return 1;
    }

    for (new i = 0; i < MAX_CASAS; i++)
    {
        if (IsPlayerInRangeOfPoint(playerid, 3.0,
            gHouse[i][hX], gHouse[i][hY], gHouse[i][hZ]))
        {
            ShowHouse(playerid, i);
            return 1;
        }
    }

    if (IsPlayerInRangeOfPoint(playerid, 4.0,
        BANCO_X, BANCO_Y, BANCO_Z))
    {
        ShowPlayerDialog(playerid, D_BANCO,
            DIALOG_STYLE_LIST, "{3498DB}Banco",
            "Depositar\nSacar",
            "Selecionar", "Fechar");
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 4.0,
        CONCE_X, CONCE_Y, CONCE_Z))
    {
        ShowPlayerDialog(playerid, D_CONCE,
            DIALOG_STYLE_LIST, "{9B59B6}Concessionaria",
            "Faggio - $1.500\nSanchez - $3.000\nElegy - $12.000\nBullet - $25.000\nLandstalker - $15.000\nInfernus - $45.000",
            "Comprar", "Fechar");
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 4.0,
        ROUPA_X, ROUPA_Y, ROUPA_Z))
    {
        ShowPlayerDialog(playerid, D_ROUPAS,
            DIALOG_STYLE_LIST, "{9B59B6}Loja de roupas",
            "Roupa 7\nRoupa 14\nRoupa 21\nRoupa 23\nRoupa 29\nRoupa 240",
            "Vestir", "Fechar");
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 4.0,
        LOJA_X, LOJA_Y, LOJA_Z))
    {
        ShowPlayerDialog(playerid, D_LOJA,
            DIALOG_STYLE_LIST, "{2ECC71}Mercado",
            "Comprar comida - $20\nComprar agua - $15\nComprar kit - $100",
            "Comprar", "Fechar");
        return 1;
    }

    if (IsPlayerInRangeOfPoint(playerid, 4.0,
        POSTO_X, POSTO_Y, POSTO_Z))
    {
        ShowPlayerDialog(playerid, D_POSTO,
            DIALOG_STYLE_LIST, "{E67E22}Posto",
            "Abastecer veiculo - $100",
            "Confirmar", "Fechar");
        return 1;
    }

    Msg(playerid, COR_CINZA,
        "Nao ha nenhuma interacao disponivel neste local.");

    return 1;
}

// ============================================================================
// CHECKPOINTS
// ============================================================================

public OnPlayerEnterCheckpoint(playerid)
{
    if (!IsValidLogged(playerid))
        return 1;

    if (gTrabalhando[playerid])
    {
        new pagamento = 250 + random(151);

        AddCash(playerid, pagamento);
        gXP[playerid] += 10;
        gRota[playerid]++;

        DisablePlayerCheckpoint(playerid);

        new msg[100];
        format(msg, sizeof msg,
            "[EMPREGO] Entrega concluida! Voce recebeu $%d e 10 XP.",
            pagamento);
        Msg(playerid, COR_VERDE, msg);

        if (gEmprego[playerid] == 1)
        {
            SetPlayerCheckpoint(playerid,
                1540.0 + float(random(30)),
                -1700.0 - float(random(30)),
                13.5, 4.0);
        }
        else if (gEmprego[playerid] == 2)
        {
            SetPlayerCheckpoint(playerid,
                1400.0 + float(random(40)),
                -1600.0 - float(random(40)),
                13.5, 5.0);
        }

        UpdateHUD(playerid);
        SaveAccount(playerid);
    }

    return 1;
}

// ============================================================================
// MORTE
// ============================================================================

public OnPlayerDeath(playerid, killerid, reason)
{
    if (gTrabalhando[playerid])
        StopJob(playerid);

    gFome[playerid] -= 5;
    gSede[playerid] -= 5;

    if (gFome[playerid] < 0) gFome[playerid] = 0;
    if (gSede[playerid] < 0) gSede[playerid] = 0;

    SaveAccount(playerid);
    return 1;
}

// ============================================================================
// COMANDOS
// ============================================================================

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!IsValidLogged(playerid))
        return 1;

    if (!strcmp(cmdtext, "/menu", true))
        return ShowMain(playerid);

    if (!strcmp(cmdtext, "/gps", true))
        return ShowGPS(playerid);

    if (!strcmp(cmdtext, "/status", true))
    {
        new msg[180];
        format(msg, sizeof msg,
            "Nivel: %d | XP: %d | Banco: $%d | Fome: %d | Sede: %d",
            gNivel[playerid], gXP[playerid],
            gDinheiroBanco[playerid], gFome[playerid], gSede[playerid]);

        return Msg(playerid, COR_CIANO, msg);
    }

    if (!strcmp(cmdtext, "/trabalhar", true))
        return StartJob(playerid);

    if (!strcmp(cmdtext, "/parar", true))
        return StopJob(playerid);

    if (!strcmp(cmdtext, "/casa", true))
    {
        for (new i = 0; i < MAX_CASAS; i++)
        {
            if (IsPlayerInRangeOfPoint(playerid, 3.0,
                gHouse[i][hX], gHouse[i][hY], gHouse[i][hZ]))
            {
                ShowHouse(playerid, i);
                return 1;
            }
        }

        return Msg(playerid, COR_VERMELHO,
            "Voce nao esta perto de uma casa.");
    }

    if (!strcmp(cmdtext, "/comprarcnh", true))
    {
        if (gCNH[playerid])
            return Msg(playerid, COR_VERDE, "Voce ja possui CNH.");

        if (GetPlayerMoney(playerid) < PRECO_CNH)
            return Msg(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

        AddCash(playerid, -PRECO_CNH);
        gCNH[playerid] = 1;
        SaveAccount(playerid);

        return Msg(playerid, COR_VERDE,
            "Parabens! Sua CNH foi liberada.");
    }

    if (!strcmp(cmdtext, "/salvar", true))
    {
        SaveAccount(playerid);
        SaveHouses();
        return Msg(playerid, COR_VERDE, "Conta salva com sucesso.");
    }

    if (!strcmp(cmdtext, "/saircasa", true))
    {
        if (!gDentroCasa[playerid])
            return Msg(playerid, COR_VERMELHO, "Voce nao esta em uma casa.");

        SetPlayerVirtualWorld(playerid, 0);
        SetPlayerPos(playerid,
            gHouse[gCasaAtual[playerid]][hX],
            gHouse[gCasaAtual[playerid]][hY],
            gHouse[gCasaAtual[playerid]][hZ]);

        gDentroCasa[playerid] = false;
        gCasaAtual[playerid] = INVALID_HOUSE;

        return 1;
    }

    if (!strcmp(cmdtext, "/dono", true))
    {
        if (!IsOwnerName(playerid))
            return Msg(playerid, COR_VERMELHO, "Acesso negado.");

        ShowPlayerDialog(playerid, D_DONO_LOGIN,
            DIALOG_STYLE_PASSWORD,
            "{F1C40F}Painel do proprietario",
            "Digite a senha administrativa:",
            "Entrar", "Fechar");

        return 1;
    }

    return 0;
}

// ============================================================================
// DIALOGOS
// ============================================================================

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if (!response)
        return 1;

    if (dialogid == D_REGISTRO)
    {
        if (strlen(inputtext) < 4 || strlen(inputtext) > 31)
        {
            ShowPlayerDialog(playerid, D_REGISTRO,
                DIALOG_STYLE_PASSWORD,
                "{9B59B6}ZK RP | Registro",
                "A senha precisa ter entre 4 e 31 caracteres:",
                "Registrar", "Sair");
            return 1;
        }

        format(gSenha[playerid], 32, "%s", inputtext);

        gLogado[playerid] = true;
        gDinheiroSalvo[playerid] = 5000;
        gNivel[playerid] = 1;
        gXP[playerid] = 0;
        gSkin[playerid] = 7;

        SetCash(playerid, 5000);
        SaveAccount(playerid);

        TogglePlayerSpectating(playerid, false);
        SpawnPlayer(playerid);

        return 1;
    }

    if (dialogid == D_LOGIN)
    {
        if (strcmp(inputtext, gSenha[playerid], false))
        {
            ShowPlayerDialog(playerid, D_LOGIN,
                DIALOG_STYLE_PASSWORD,
                "{E74C3C}Senha incorreta",
                "Senha incorreta. Tente novamente:",
                "Entrar", "Sair");
            return 1;
        }

        gLogado[playerid] = true;
        SetCash(playerid, gDinheiroSalvo[playerid]);

        TogglePlayerSpectating(playerid, false);
        SpawnPlayer(playerid);

        return 1;
    }

    if (dialogid == D_MENU)
    {
        switch (listitem)
        {
            case 0:
            {
                new msg[160];
                format(msg, sizeof msg,
                    "Nome: %s | Nivel: %d | XP: %d | CNH: %s",
                    gNome[playerid], gNivel[playerid], gXP[playerid],
                    gCNH[playerid] ? "Sim" : "Nao");
                Msg(playerid, COR_CIANO, msg);
            }
            case 1:
            {
                new msg[150];
                format(msg, sizeof msg,
                    "Comida: %d | Agua: %d | Drogas: %d | Kits: %d",
                    gComida[playerid], gAgua[playerid],
                    gDrogas[playerid], gKit[playerid]);
                Msg(playerid, COR_CIANO, msg);
            }
            case 2: ShowGPS(playerid);
            case 3:
            {
                ShowPlayerDialog(playerid, D_EMPREGOS,
                    DIALOG_STYLE_LIST, "{9B59B6}Empregos",
                    "Entregador iFood\nMotorista de Onibus\nPolicial Militar\nMecanico",
                    "Selecionar", "Fechar");
            }
            case 4:
            {
                ShowPlayerDialog(playerid, D_BANCO,
                    DIALOG_STYLE_LIST, "{3498DB}Banco",
                    "Depositar\nSacar",
                    "Selecionar", "Fechar");
            }
            case 5:
            {
                ShowPlayerDialog(playerid, D_VEICULO,
                    DIALOG_STYLE_LIST, "{E67E22}Veiculo",
                    "Ligar / Desligar motor\nTrancar / Destrancar\nGuardar veiculo",
                    "Selecionar", "Fechar");
            }
            case 6:
            {
                ShowPlayerDialog(playerid, D_POLICIA,
                    DIALOG_STYLE_LIST, "{3498DB}Policia",
                    "Consultar procurados\nPagar CNH",
                    "Selecionar", "Fechar");
            }
            case 7:
            {
                SaveAccount(playerid);
                Msg(playerid, COR_VERDE, "Conta salva.");
            }
        }
        return 1;
    }

    if (dialogid == D_EMPREGOS)
    {
        gEmprego[playerid] = listitem + 1;
        SaveAccount(playerid);

        new msg[100];
        format(msg, sizeof msg,
            "Voce escolheu o emprego: %s. Use /trabalhar.",
            gNomeEmprego[gEmprego[playerid]]);
        return Msg(playerid, COR_VERDE, msg);
    }

    if (dialogid == D_GPS)
    {
        switch (listitem)
        {
            case 0: GoTo(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z, "Prefeitura");
            case 1: GoTo(playerid, BANCO_X, BANCO_Y, BANCO_Z, "Banco");
            case 2: GoTo(playerid, CONCE_X, CONCE_Y, CONCE_Z, "Concessionaria");
            case 3: GoTo(playerid, ROUPA_X, ROUPA_Y, ROUPA_Z, "Loja de roupas");
            case 4: GoTo(playerid, LOJA_X, LOJA_Y, LOJA_Z, "Mercado");
            case 5: GoTo(playerid, POSTO_X, POSTO_Y, POSTO_Z, "Posto");
            case 6: GoTo(playerid, DROGA_X, DROGA_Y, DROGA_Z, "Tropa ZK");
            case 7: DisablePlayerCheckpoint(playerid);
        }
        return 1;
    }

    if (dialogid == D_BANCO)
    {
        gBankMode[playerid] = listitem + 1;

        ShowPlayerDialog(playerid, D_BANCO_VALOR,
            DIALOG_STYLE_INPUT, "{3498DB}Banco",
            "Digite o valor:",
            "Confirmar", "Voltar");
        return 1;
    }

    if (dialogid == D_BANCO_VALOR)
    {
        new valor = strval(inputtext);

        if (valor <= 0)
            return Msg(playerid, COR_VERMELHO, "Valor invalido.");

        if (gBankMode[playerid] == 1)
        {
            if (GetPlayerMoney(playerid) < valor)
                return Msg(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

            AddCash(playerid, -valor);
            gDinheiroBanco[playerid] += valor;
        }
        else
        {
            if (gDinheiroBanco[playerid] < valor)
                return Msg(playerid, COR_VERMELHO, "Saldo insuficiente.");

            gDinheiroBanco[playerid] -= valor;
            AddCash(playerid, valor);
        }

        SaveAccount(playerid);
        return Msg(playerid, COR_VERDE, "Operacao bancaria concluida.");
    }

    if (dialogid == D_CONCE)
    {
        if (listitem < 0 || listitem >= 6)
            return 1;

        if (gVeiculo[playerid] != 0)
            return Msg(playerid, COR_VERMELHO, "Voce ja possui um veiculo ativo.");

        if (GetPlayerMoney(playerid) < gPrecoVeiculo[listitem])
            return Msg(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

        AddCash(playerid, -gPrecoVeiculo[listitem]);

        gVeiculo[playerid] = CreateVehicle(
            gModeloVeiculo[listitem],
            CONCE_X + 5.0, CONCE_Y, CONCE_Z,
            90.0, 1, 1, -1);

        gVeiculoModelo[playerid] = gModeloVeiculo[listitem];

        if (gVeiculo[playerid] != INVALID_VEHICLE_ID)
        {
            gCombustivel[gVeiculo[playerid]] = 100;
            PutPlayerInVehicle(playerid, gVeiculo[playerid], 0);
        }

        SaveAccount(playerid);
        return Msg(playerid, COR_VERDE, "Veiculo comprado!");
    }

    if (dialogid == D_ROUPAS)
    {
        if (listitem < 0 || listitem >= 6)
            return 1;

        gSkin[playerid] = gSkinLoja[listitem];
        SetPlayerSkin(playerid, gSkin[playerid]);
        SaveAccount(playerid);

        return Msg(playerid, COR_VERDE, "Visual atualizado!");
    }

    if (dialogid == D_LOJA)
    {
        if (listitem == 0)
        {
            if (GetPlayerMoney(playerid) < 20)
                return Msg(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

            AddCash(playerid, -20);
            gComida[playerid]++;
        }
        else if (listitem == 1)
        {
            if (GetPlayerMoney(playerid) < 15)
                return Msg(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

            AddCash(playerid, -15);
            gAgua[playerid]++;
        }
        else if (listitem == 2)
        {
            if (GetPlayerMoney(playerid) < 100)
                return Msg(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

            AddCash(playerid, -100);
            gKit[playerid]++;
        }

        SaveAccount(playerid);
        return Msg(playerid, COR_VERDE, "Compra realizada.");
    }

    if (dialogid == D_POSTO)
    {
        if (!IsPlayerInAnyVehicle(playerid))
            return Msg(playerid, COR_VERMELHO, "Entre em um veiculo primeiro.");

        if (GetPlayerMoney(playerid) < 100)
            return Msg(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

        new vid = GetPlayerVehicleID(playerid);

        if (vid < 1 || vid >= MAX_VEH_SERVER)
            return 1;

        AddCash(playerid, -100);
        gCombustivel[vid] = 100;

        return Msg(playerid, COR_VERDE, "Veiculo abastecido.");
    }

    if (dialogid == D_CASA)
    {
        new id = gCasaAtual[playerid];

        if (id < 0 || id >= MAX_CASAS)
            return 1;

        if (!gHouse[id][hBought])
        {
            if (GetPlayerMoney(playerid) < gHouse[id][hPrice])
                return Msg(playerid, COR_VERMELHO, "Dinheiro insuficiente.");

            AddCash(playerid, -gHouse[id][hPrice]);

            format(gHouse[id][hOwner], MAX_PLAYER_NAME, "%s", gNome[playerid]);
            gHouse[id][hBought] = true;
            gHouse[id][hLocked] = false;

            SaveHouses();
            SaveAccount(playerid);

            return Msg(playerid, COR_VERDE, "Casa comprada com sucesso!");
        }

        if (!strcmp(gHouse[id][hOwner], gNome[playerid], true))
        {
            if (listitem == 0)
            {
                SetPlayerVirtualWorld(playerid, id + 1);
                SetPlayerPos(playerid, 2495.0, -1691.0, 1014.7);
                gDentroCasa[playerid] = true;
                gCasaAtual[playerid] = id;
                return 1;
            }

            if (listitem == 1)
            {
                gHouse[id][hLocked] = !gHouse[id][hLocked];
                SaveHouses();
                return Msg(playerid, COR_VERDE,
                    gHouse[id][hLocked] ? "Casa trancada." : "Casa destrancada.");
            }

            if (listitem == 2)
            {
                AddCash(playerid, gHouse[id][hPrice] / 2);
                format(gHouse[id][hOwner], MAX_PLAYER_NAME, "Ninguem");
                gHouse[id][hBought] = false;
                gHouse[id][hLocked] = false;
                SaveHouses();

                return Msg(playerid, COR_VERDE, "Casa vendida.");
            }
        }
        else
        {
            if (gHouse[id][hLocked])
                return Msg(playerid, COR_VERMELHO, "Esta casa esta trancada.");

            SetPlayerVirtualWorld(playerid, id + 1);
            SetPlayerPos(playerid, 2495.0, -1691.0, 1014.7);
            gDentroCasa[playerid] = true;
            gCasaAtual[playerid] = id;
        }

        return 1;
    }

    if (dialogid == D_CELULAR)
    {
        if (listitem == 0)
        {
            ShowPlayerDialog(playerid, D_SMS_ID,
                DIALOG_STYLE_INPUT, "{1ABC9C}SMS",
                "Digite o ID do jogador:",
                "Continuar", "Cancelar");
        }
        else
        {
            ShowPlayerDialog(playerid, D_ANUNCIO,
                DIALOG_STYLE_INPUT, "{1ABC9C}Anuncio",
                "Digite seu anuncio:",
                "Enviar", "Cancelar");
        }
        return 1;
    }

    if (dialogid == D_SMS_ID)
    {
        gSmsAlvo[playerid] = strval(inputtext);

        if (!IsPlayerConnected(gSmsAlvo[playerid]) ||
            !gLogado[gSmsAlvo[playerid]])
            return Msg(playerid, COR_VERMELHO, "Jogador nao encontrado.");

        ShowPlayerDialog(playerid, D_SMS_TEXTO,
            DIALOG_STYLE_INPUT, "{1ABC9C}SMS",
            "Digite sua mensagem:",
            "Enviar", "Cancelar");
        return 1;
    }

    if (dialogid == D_SMS_TEXTO)
    {
        if (strlen(inputtext) < 1 || strlen(inputtext) > 100)
            return Msg(playerid, COR_VERMELHO, "Mensagem invalida.");

        new msg[144];
        format(msg, sizeof msg, "[SMS] %s: %s",
            gNome[playerid], inputtext);

        Msg(gSmsAlvo[playerid], COR_CIANO, msg);
        return Msg(playerid, COR_VERDE, "SMS enviado.");
    }

    if (dialogid == D_ANUNCIO)
    {
        if (strlen(inputtext) < 3 || strlen(inputtext) > 100)
            return Msg(playerid, COR_VERMELHO, "Anuncio invalido.");

        if (GetTickCount() - gAnuncioCooldown[playerid] < 60000)
            return Msg(playerid, COR_VERMELHO,
                "Aguarde antes de publicar outro anuncio.");

        new msg[144];
        format(msg, sizeof msg, "[ANUNCIO] %s: %s",
            gNome[playerid], inputtext);

        SendClientMessageToAll(COR_DOURADO, msg);
        gAnuncioCooldown[playerid] = GetTickCount();

        return 1;
    }

    if (dialogid == D_VEICULO)
    {
        if (listitem == 0)
        {
            if (!IsPlayerInAnyVehicle(playerid))
                return Msg(playerid, COR_VERMELHO, "Entre em um veiculo.");

            gMotor[playerid] = !gMotor[playerid];

            return Msg(playerid, COR_VERDE,
                gMotor[playerid] ? "Motor ligado." : "Motor desligado.");
        }

        if (listitem == 1)
        {
            gTrancado[playerid] = !gTrancado[playerid];

            return Msg(playerid, COR_VERDE,
                gTrancado[playerid] ? "Veiculo trancado." : "Veiculo destrancado.");
        }

        if (listitem == 2)
        {
            if (gVeiculo[playerid])
            {
                DestroyVehicle(gVeiculo[playerid]);
                gVeiculo[playerid] = 0;
                gVeiculoModelo[playerid] = 0;
                return Msg(playerid, COR_VERDE, "Veiculo guardado.");
            }

            return Msg(playerid, COR_VERMELHO, "Voce nao possui veiculo.");
        }

        return 1;
    }

    if (dialogid == D_DONO_LOGIN)
    {
        if (!IsOwnerName(playerid) || strcmp(inputtext, DONO_SENHA, false))
            return Msg(playerid, COR_VERMELHO, "Senha administrativa incorreta.");

        gDono[playerid] = true;
        gDonoAut[playerid] = true;

        ShowPlayerDialog(playerid, D_DONO,
            DIALOG_STYLE_LIST, "{F1C40F}Painel DONO",
            "Curar\nReparar veiculo\nTeleportar\nDar dinheiro\nAnunciar\nCriar veiculo",
            "Selecionar", "Fechar");

        return 1;
    }

    if (dialogid == D_DONO)
    {
        if (!gDonoAut[playerid])
            return 1;

        if (listitem == 0)
        {
            SetPlayerHealth(playerid, 100.0);
            SetPlayerArmour(playerid, 100.0);
            Msg(playerid, COR_VERDE, "Voce foi curado.");
        }
        else if (listitem == 1)
        {
            if (IsPlayerInAnyVehicle(playerid))
                RepairVehicle(GetPlayerVehicleID(playerid));
        }
        else if (listitem == 2)
        {
            ShowPlayerDialog(playerid, D_DONO_TP,
                DIALOG_STYLE_LIST, "{F1C40F}Teleportes",
                "Prefeitura\nBanco\nConcessionaria\nTropa ZK",
                "Ir", "Voltar");
        }
        else if (listitem == 3)
        {
            ShowPlayerDialog(playerid, D_ADMIN_ID,
                DIALOG_STYLE_INPUT, "{F1C40F}Dar dinheiro",
                "Digite o ID do jogador:",
                "Continuar", "Cancelar");
        }
        else if (listitem == 4)
        {
            ShowPlayerDialog(playerid, D_ADMIN_ANUNCIO,
                DIALOG_STYLE_INPUT, "{F1C40F}Anuncio global",
                "Digite o anuncio:",
                "Enviar", "Cancelar");
        }
        else if (listitem == 5)
        {
            ShowPlayerDialog(playerid, D_DONO_VEH,
                DIALOG_STYLE_LIST, "{F1C40F}Veiculos especiais",
                "Infernus\nNRG-500\nElegy\nTurismo\nMaverick",
                "Criar", "Voltar");
        }

        return 1;
    }

    if (dialogid == D_DONO_TP)
    {
        switch (listitem)
        {
            case 0: SetPlayerPos(playerid, SPAWN_X, SPAWN_Y, SPAWN_Z);
            case 1: SetPlayerPos(playerid, BANCO_X, BANCO_Y, BANCO_Z);
            case 2: SetPlayerPos(playerid, CONCE_X, CONCE_Y, CONCE_Z);
            case 3: SetPlayerPos(playerid, DROGA_X, DROGA_Y, DROGA_Z);
        }
        SetPlayerVirtualWorld(playerid, 0);
        return 1;
    }

    if (dialogid == D_ADMIN_ID)
    {
        gAdminTarget[playerid] = strval(inputtext);

        if (!IsPlayerConnected(gAdminTarget[playerid]))
            return Msg(playerid, COR_VERMELHO, "Jogador nao encontrado.");

        ShowPlayerDialog(playerid, D_ADMIN_VALOR,
            DIALOG_STYLE_INPUT, "{F1C40F}Dinheiro",
            "Digite o valor:",
            "Enviar", "Cancelar");
        return 1;
    }

    if (dialogid == D_ADMIN_VALOR)
    {
        new valor = strval(inputtext);

        if (valor <= 0 || valor > 100000000)
            return Msg(playerid, COR_VERMELHO, "Valor invalido.");

        AddCash(gAdminTarget[playerid], valor);
        SaveAccount(gAdminTarget[playerid]);

        return Msg(playerid, COR_VERDE, "Dinheiro entregue.");
    }

    if (dialogid == D_ADMIN_ANUNCIO)
    {
        if (strlen(inputtext) < 1 || strlen(inputtext) > 100)
            return 1;

        new msg[144];
        format(msg, sizeof msg, "[ZK RP - DONO] %s", inputtext);
        SendClientMessageToAll(COR_DOURADO, msg);
        return 1;
    }

    if (dialogid == D_DONO_VEH)
    {
        if (listitem < 0 || listitem >= 5)
            return 1;

        new modelos[5] = {411, 522, 560, 451, 487};

        new Float:x, Float:y, Float:z, Float:a;
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);

        new veh = CreateVehicle(modelos[listitem],
            x + 3.0, y, z, a, 1, 1, -1);

        PutPlayerInVehicle(playerid, veh, 0);
        return 1;
    }

    return 0;
}

// ============================================================================
// TIMERS
// ============================================================================

public TimerPayday()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsValidLogged(i))
            continue;

        new salario = 150 + (gNivel[i] * 25);

        AddCash(i, salario);
        gXP[i] += 5;

        if (gXP[i] >= gNivel[i] * 100)
        {
            gXP[i] = 0;
            gNivel[i]++;

            Msg(i, COR_DOURADO,
                "Parabens! Voce subiu de nivel.");
        }

        Msg(i, COR_VERDE,
            "[PAYDAY] Seu salario foi depositado.");

        SaveAccount(i);
        UpdateHUD(i);
    }

    return 1;
}

public TimerNeeds()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (!IsValidLogged(i))
            continue;

        if (gFome[i] > 0) gFome[i]--;
        if (gSede[i] > 0) gSede[i]--;

        if (gFome[i] <= 0 || gSede[i] <= 0)
        {
            new Float:health;
            GetPlayerHealth(i, health);

            health -= 5.0;

            if (health < 5.0)
                health = 5.0;

            SetPlayerHealth(i, health);
        }

        UpdateHUD(i);
    }

    return 1;
}

public TimerHUD()
{
    for (new i = 0; i < MAX_PLAYERS; i++)
    {
        if (IsValidLogged(i))
            UpdateHUD(i);
    }

    return 1;
}